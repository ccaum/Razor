require 'rack'
require "#{File.dirname(__FILE__)}/lib/project_razor_api.rb"

$:.unshift "#{File.dirname(__FILE__)}/lib"
$:.unshift "#{File.dirname(__FILE__)}/lib/project_razor"

run ProjectRazorAPI
