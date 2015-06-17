module Celluloid::SMTP::Server::Connection::Event

  # get event on CONNECTION
  def on_connect
    #de logger.debug("Client connect from #{ctx[:server][:remote_ip]}:#{ctx[:server][:remote_port]}")
  end

  # get event before DISONNECT
  def on_disconnect
    #de logger.debug("Client disconnect from #{ctx[:server][:remote_ip]}:#{ctx[:server][:remote_port]}")
  end

  # get event on HELO:
  def on_helo(ctx, helo_data)

  end

  # get address send in MAIL FROM:
  # if any value returned, that will be used for ongoing processing
  # otherwise the original value will be used 
  def on_mail_from(ctx, mail_from_data)
  end

  # get each address send in RCPT TO:
  # if any value returned, that will be used for ongoing processing
  # otherwise the original value will be used 
  def on_rcpt_to(ctx, rcpt_to_data)

  end

  # get each message after DATA <message> .
  def on_message

  end
end
