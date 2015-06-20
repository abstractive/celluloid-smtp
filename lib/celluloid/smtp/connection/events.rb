class Celluloid::SMTP::Connection

  def event!(method,*args)
    debug("Executing event: #{method}")
    send(method,*args)
  rescue => ex
    exception(ex, "Failure in event processor: #{method}")
    nil
  end

  def on_connection
    debug("Client connected.") if DEBUG
  end

  def on_disconnect
    debug("Disconnecting client.") if DEBUG
  end

  def on_helo(helo)
    debug("HELO: #{helo}") if DEBUG
    return helo
  end

  def on_mail_from(from)
    debug("MAIL FROM: #{from}") if DEBUG
    return from
  end

  def on_rcpt_to(to)
    debug("RCPT TO: #{to}") if DEBUG
    return to
  end

  def on_message(message)
    return message[:data]
  end
end
