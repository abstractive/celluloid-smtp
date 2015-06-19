class Celluloid::SMTP::Connection

  include Celluloid::SMTP

  def handle!
    context!(true)
    if process!
      transition :handled
    else
      transition :disconnecting
    end
  rescue => ex
    exception(ex, "Error handling command session")
    transition :closed
  end

  [:data, :quit, :helo, :mail, :rcpt, :rset].each { |command|
    define_method(:"#{command}?") { @sequence == command }
    define_method(:"#{command}!") { @sequence = command }
  }

  def context!(first=false)
    @helo = nil if first
    @sequence = first ? :helo : :rset
    @context = {} if first || @context.nil?
    @context[:envelope] = {from: "", to: []}
    @context[:message] = {delivered: -1, bytesize: -1, data: ""}
  end

  def envelope;   @context[:envelope] ||= {}   end
  def message;    @context[:message] ||= {}    end

  def process!
    print! "220 #{@configuration[:hostname]} says welcome!"
    begin
      loop {
        output = begin
          data = @socket.readline
          debug(">> #{data.chomp}") unless data?
          line! data
        rescue Celluloid::SMTP::Exception => ex
          exception(ex, "Processing error")
        rescue => ex
          exception(ex, "Unknown exception")
          Error500.new.result
        end
        unless output.empty?
          debug("<< #{output}")
          print! output
        end
        break if quit? || closed?
      }
      print! "221 Service closing transmission channel" unless closed?
      return true
    rescue EOFError
      debug("Lost connection due to client abort.")
    rescue Exception => ex
      exception(ex, "Error parsing command session")
      print! Error421.new.result unless closed?
    end
    false
  end

  def line!(data)
    unless data?
      case data 
      when (/^(HELO|EHLO)(\s+.*)?$/i) # HELO/EHLO    
        # 250 Requested mail action okay, completed
        # 421 <domain> Service not available, closing transmission channel
        # 500 Syntax error, command unrecognised
        # 501 Syntax error in parameters or arguments
        # 504 Command parameter not implemented
        # 521 <domain> does not accept mail [rfc1846]
        raise Error503 unless helo?
        data = data.gsub(/^(HELO|EHLO)\ /i, '').strip
        if return_value = on_helo(data)
          data = return_value
        end
        @helo = data
        rset!
        return "250 OK"
      when (/^NOOP\s*$/i) # NOOP
        # 250 Requested mail action okay, completed
        # 421 <domain> Service not available, closing transmission channel
        # 500 Syntax error, command unrecognised
        return "250 OK"
      when (/^RSET\s*$/i) # RSET
        # 250 Requested mail action okay, completed
        # 421 <domain> Service not available, closing transmission channel
        # 500 Syntax error, command unrecognised
        # 501 Syntax error in parameters or arguments
        raise Error503 if helo?
        # handle command
        context!
        return "250 OK"        
      when (/^QUIT\s*$/i) # QUIT
        # 221 <domain> Service closing transmission channel
        # 500 Syntax error, command unrecognised
        quit!
        return ""
      when (/^MAIL FROM\:/i) # MAIL
        # 250 Requested mail action okay, completed
        # 421 <domain> Service not available, closing transmission channel
        # 451 Requested action aborted: local error in processing
        # 452 Requested action not taken: insufficient system storage
        # 500 Syntax error, command unrecognised
        # 501 Syntax error in parameters or arguments
        # 552 Requested mail action aborted: exceeded storage allocation
        raise Error503 unless rset?
        data = data.gsub(/^MAIL FROM\:/i, '').strip
        if return_value = on_mail_from(data)
          data = return_value
        end
        envelope[:from] = data
        mail!
        return "250 OK"        
      when (/^RCPT TO\:/i) # RCPT
        # 250 Requested mail action okay, completed
        # 251 User not local; will forward to <forward-path>
        # 421 <domain> Service not available, closing transmission channel
        # 450 Requested mail action not taken: mailbox unavailable
        # 451 Requested action aborted: local error in processing
        # 452 Requested action not taken: insufficient system storage
        # 500 Syntax error, command unrecognised
        # 501 Syntax error in parameters or arguments
        # 503 Bad sequence of commands
        # 521 <domain> does not accept mail [rfc1846]
        # 550 Requested action not taken: mailbox unavailable
        # 551 User not local; please try <forward-path>
        # 552 Requested mail action aborted: exceeded storage allocation
        # 553 Requested action not taken: mailbox name not allowed
        raise Error503 unless mail? || rset?
        data = data.gsub(/^RCPT TO\:/i, '').strip
        if return_value = on_rcpt_to(data)
          data = return_value
        end
        envelope[:to] << data
        rset!
        return "250 OK"        
      when (/^DATA\s*$/i) # DATA
        # 354 Start mail input; end with <CRLF>.<CRLF>
        # 250 Requested mail action okay, completed
        # 421 <domain> Service not available, closing transmission channel received data
        # 451 Requested action aborted: local error in processing
        # 452 Requested action not taken: insufficient system storage
        # 500 Syntax error, command unrecognised
        # 501 Syntax error in parameters or arguments
        # 503 Bad sequence of commands
        # 552 Requested mail action aborted: exceeded storage allocation
        # 554 Transaction failed
        raise Error503 unless rset?
        data!
        return "354 Enter message, ending with \".\" on a data by itself"
      else
        raise Error500
      end
    else # Data mode.
      if (data.chomp =~ /^\.$/) # Line with only a period; being told to exit data mode.
        message[:data] += data
        message[:data].gsub!(/\r\n\Z/, '').gsub!(/\.\Z/, '')    # remove ending line .
        begin
          if return_value = on_message(@context)
            message[:data] = return_value
          end
          message[:delivered] = Time.now.utc                    # save delivered time
          message[:bytesize] = message[:data].bytesize          # save bytesize of message data
          return "250 Requested mail action okay, completed"

        rescue Celluloid::SMTP::Exception
          raise
        rescue Exception => ex
          raise Error451.new("#{ex}")
        ensure
          context!
        end
      else
        message[:data] += data
        return ""
      end

    end
  end
  
end
