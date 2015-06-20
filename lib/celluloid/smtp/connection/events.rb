class Celluloid::SMTP::Connection

  def event!(method,*args)
    debug("Executing event: #{method}") if DEBUG_EVENTS
    send(method,*args)
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
