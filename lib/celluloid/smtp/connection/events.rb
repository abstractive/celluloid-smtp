class Celluloid::SMTP::Connection

  def event!(method,*args)
    start = Time.now
    debug("Executing event: #{method}") if DEBUG_EVENTS
    result = send(method,*args)
    debug("TIMER: #{"%0.4f" %(Time.now-start)} on event: #{method}") if DEBUG_TIMING
    result
  rescue => ex
    exception(ex, "Failure in event processor: #{method}")
    nil
  end

  def on_connection
    debug("Client connected.") if DEBUG_EVENTS
  end

  def on_disconnect
    debug("Disconnecting client.") if DEBUG_EVENTS
  end

  def on_helo(helo)
    debug("HELO: #{helo}") if DEBUG_EVENTS
    return helo
  end

  def on_mail_from(from)
    debug("MAIL FROM: #{from}") if DEBUG_EVENTS
    return from
  end

  def on_rcpt_to(to)
    debug("RCPT TO: #{to}") if DEBUG_EVENTS
    return to
  end

  def on_message(message)
    debug("MESSAGE") if DEBUG_EVENTS
    return message[:data]
  end
end
