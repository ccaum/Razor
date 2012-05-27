require 'sinatra/base'
require "#{File.dirname(__FILE__)}/project_razor_interface"

class ProjectRazorAPI < Sinatra::Base
  helpers do
    def razor
      @razor ||= ProjectRazorInterface.new
    end

    def config
      unless @config
        razor.web_command = true
        razor.namespace = 'config'
        razor.arguments = ['read']

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
      rescue ProjectRazorInterface::NoSliceFound
        error 406 do
          JSON.dump({"slice" => "ProjectRazor::Slice", "result" => "InvalidSlice", 'http_error_code' => '406'})
        end
      rescue => e
        error 500 do
          e.message
        end
      end
    end

    def api_call(slice = String.new, params)
      args = [ *slice ]

      if params.size < 3
        args << 'default'
      end

      args << params.to_json

      run_razor args
    end
  end

  get '/razor/api/boot' do
    api_call 'boot', params
  end

  get '/razor/api/:slice' do
    api_call params[:slice], params.delete!(:slice)
  end

  get '/razor/image/mk/:kernel' do
    send_file run_razor(['image', 'path', params[:kernel]])
  end

  get '/razor/image/:image' do
    send_file File.join(config['@image_svc_path'], params[:image])
  end

  post '/razor/api/*' do
    puts params[:splat]
    #run_razor(params[:splat])
  end

  put '/razor/api/*' do
    puts params[:splat]
    #run_razor(params[:splat])
  end

  delete '/razor/api/*' do
    puts parmas[:splat]
    #run_razor(params[:splat])
  end

end
