module Celluloid::SMTP
  class Exception < ::Exception
    attr_reader :code, :text
    def initialize(msg=nil, code, text)
      @code = code
      @text = text
      super msg
    end
    def result
      "#{@code} #{@text}"
    end    
  end

  class Error421 < Exception
    def initialize(msg="")
      super msg, 421, "Service not available, closing transmission channel"
    end
  end

  class Error450 < Exception
    def initialize(msg="")
      super msg, 450, "Requested mail action not taken: mailbox unavailable"
    end
  end

  class Error451 < Exception
    def initialize(msg="")
      super msg, 451, "Requested action aborted: local error in processing"
    end
  end

  class Error452 < Exception
    def initialize(msg="")
      super msg, 452, "Requested action not taken: insufficient system storage"
    end
  end

  class Error500 < Exception
    def initialize(msg="")
      super msg, 500, "Syntax error, command unrecognised or error in parameters or arguments"
    end
  end

  class Error501 < Exception
    def initialize(msg="")
      super msg, 501, "Syntax error in parameters or arguments"
    end
  end

  class Error502 < Exception
    def initialize(msg="")
      super msg, 502, "Command not implemented"
    end
  end

  class Error503 < Exception
    def initialize(msg="")
      super msg, 503, "Bad sequence of commands"
    end
  end

  class Error504 < Exception
    def initialize(msg="")
      super msg, 504, "Command parameter not implemented"
    end
  end

  class Error521 < Exception
    def initialize(msg="")
      super msg, 521, "Service does not accept mail"
    end
  end

  class Error550 < Exception
    def initialize(msg="")
      super msg, 550, "Requested action not taken: mailbox unavailable"
    end
  end

  class Error552 < Exception
    def initialize(msg="")
      super msg, 552, "Requested mail action aborted: exceeded storage allocation"
    end
  end

  class Error553 < Exception
    def initialize(msg="")
      super msg, 553, "Requested action not taken: mailbox name not allowed"
    end
  end

  class Error554 < Exception
    def initialize(msg="")
      super msg, 554, "Transaction failed"
    end
  end
end