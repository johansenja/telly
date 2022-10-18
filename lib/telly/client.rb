require "uri"
require "net/http"

module Telly
  class Client
    class FailedRequestError < StandardError; end

    class NotFoundError < StandardError; end

    def initialize(base_url)
      @base_url = base_url.gsub /\/\z/, ""
    end

    def method(class_name, method_name)
      get_path "/constant/#{class_name}/method/#{method_name}"
    rescue NotFoundError
      nil
    end

    def reflection(model_name, reflection_name)
      get_path "/model/#{model_name}/reflection/#{reflection_name}"
    rescue NotFoundError
      nil
    end

    private

    def get_path(path)
      uri = construct_uri path
      res = Net::HTTP.get_response(uri)
      json_response res
    end

    def json_response(res)
      case res
      when Net::HTTPSuccess
        JSON.parse res.body
      when Net::HTTPNotFound
        raise NotFoundError
      else
        raise FailedRequestError, res.code
      end
    end

    def construct_uri(path)
      URI(@base_url + path)
    end
  end
end
