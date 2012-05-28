require 'sinatra/base'
require "#{File.dirname(__FILE__)}/project_razor_interface"
require "#{File.dirname(__FILE__)}/project_razor_api/sinatra_helpers"

class ProjectRazorAPI < Sinatra::Base
  helpers SinatraHelpers

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
    send_file result['response'] + params[:splat].first
  end

  post '/razor/api/*' do
    commands = params[:splat].first.split('/') << 'add'
    api_call commands, params['json_hash']
  end

  put '/razor/api/*' do
    commands = params[:splat].first.split('/') << 'update'
    api_call commands, params['json_hash']
  end

  delete '/razor/api/*' do
    commands = params[:splat].first.split('/') << 'remove'
    api_call commands, params['json_hash']
  end
end
