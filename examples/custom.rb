require 'celluloid/smtp'

Celluloid::SMTP::Logger = Celluloid[:logger]

