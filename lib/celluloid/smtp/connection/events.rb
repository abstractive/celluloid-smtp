class Celluloid::SMTP::Connection

  def on_connection
    debug("Client connected.")
  end

  def on_disconnect
    debug("Disconnecting client.")
  end

  def on_helo(helo)
    debug("HELO: #{helo}")
    return helo
  end

  def on_mail_from(from)
    debug("MAIL FROM: #{from}")
    return from
  end

  def on_rcpt_to(to)
    debug("RCPT TO: #{to}")
    return to
  end

  def on_message(message)
    return message[:data]
  end
end
