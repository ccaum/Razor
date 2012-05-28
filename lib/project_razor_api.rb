require 'sinatra/base'
require "#{File.dirname(__FILE__)}/project_razor_interface"

class ProjectRazorAPI < Sinatra::Base
  helpers do
    def razor
      @razor ||= ProjectRazorInterface.new
    end

    def config
      unless @config
        config = ProjectRazor::Data.instance
        config.check_init
        config.to_hash['@razor_config']
      end
    end

    def run_razor(params = Array.new)
      razor.web_command = true
      razor.namespace = params.shift
      razor.arguments = params

      begin
        razor.call_razor_slice
      rescue => e
        error 406 do
          e.message
        end
      end
    end

    def api_call(slice = String.new, params)
      args = [ *slice ]

      if params.size < 3
        args << 'default'
      end

      args << params

      # XXX We really need to pick one class
      # that gets returned
      result = run_razor(args)
      result.is_a?(String) ? result : result.to_json
    end
  end

  get '/razor/api/boot' do
    api_call 'boot', params.to_json
  end

  get '/razor/api/:slice' do
    slice = params[:slice]
    params.delete :slice
    api_call slice, params.to_json
  end

  get '/razor/api/*' do
    commands = params[:splat].first.split('/')
    params.delete(:splat)
    api_call commands, params.to_json
  end

  get '/razor/image/mk/:image' do
    result = run_razor(['image', 'path', 'mk', params[:image]])
    status result['status']
    send_file result['response']
  end

  get '/razor/image/os/:image/*' do
    result = run_razor(['image', 'path', params[:image]])
    status result['status']
    puts result['response'] + params[:splat].first
    send_file result['response'] + params[:splat].first
  end

  post '/razor/api/*' do
    commands = params[:splat].first.split('/')
    api_call commands, params['json_hash']
  end

  put '/razor/api/*' do
    commands = params[:splat].first.split('/')
    api_call commands, params['json_hash']
  end

  delete '/razor/api/*' do
    commands = params[:splat].first.split('/')
    api_call commands, params['json_hash']
  end
end
