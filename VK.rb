require 'net/http'
require 'digest'
require 'json'

class VK
  def initialize access_token, secret = nil
    @access_token = access_token
    @secret = secret
  end
  
  def callMethod name, params
    params.update("access_token" => @access_token){ |_, b, c| b || c } #если access_token указан то оставим его, иначе добавим локальный
    
    params["sig"] = Digest::MD5.hexdigest("/method/#{name}?#{URI.encode_www_form(params)}" + @secret) #для работы без https
    
    JSON.parse(Net::HTTP.get(URI::HTTP.build({:host => "api.vk.com", :path => "/method/#{name}", :query => URI.encode_www_form(params)})))
    
  end
end