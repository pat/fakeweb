module FakeWeb
  module Matchers
    def have_requested(*args)
      FakeWeb::RequestMatcher.new(*args)
    end
  end
  
  class RequestMatcher
    def initialize(*args)
      @method, @url = args_split(*args)
    end
  
    def matches?(fakeweb)
      !fakeweb.requests.detect { |req|
        method, url = args_split(*req)
        match_method(method) && url == @url
      }.nil?
    end
  
    def failure_message
      if @method == :any
        "The URL #{@url} was not requested."
      else
        "The URL #{@url} was not requested using #{formatted_method}."
      end
    end
  
    def negative_failure_message
      if @method == :any
        "The URL #{@url} was requested and should not have been."
      else
        "The URL #{@url} was requested using #{formatted_method} and should not have been."
      end
    end
  
    private
  
    def match_method(method)
      @method == :any || method == :any || method == @method
    end
    
    def formatted_method
      @method.to_s.upcase
    end
  
    def args_split(*args)
      method  = :any
      uri     = nil
      
      case args.length
      when 1 then uri         = URI.parse(args[0])
      when 2 then method, uri = args[0], URI.parse(args[1])
      else
        raise ArgumentError.new("wrong number of arguments")
      end
      
      uri.query = nil if FakeWeb.ignore_query_params?
      return method, uri
    end
  end
end
