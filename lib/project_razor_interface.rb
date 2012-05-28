require "#{File.dirname(__FILE__)}/project_razor"

class ProjectRazorInterface
  class NoSliceFound < Exception; end;

  attr_accessor :web_command, :arguments, :debug, :verbose, :namespace, :slice_array, :logger

  # We set a constant for our Slice root Namespace. We use this to pull the slice
  # names back out from objectspace
  SLICE_PREFIX = "ProjectRazor::Slice::"

  def version
    @obj.get_razor_version
  end

  def initialize
    @obj = ProjectRazor::Object.new
    @logger = @obj.get_logger
    @verbose = false
    @debug = false
    @web_command = false
    @slice_array = Array.new
    @arguments = Array.new

    @slice_array = ProjectRazor::Slice.class_children.map do |object_class|
      object_class.to_s.gsub(/#{SLICE_PREFIX}/, '')
    end
  end

  # Call the slice
  def call_razor_slice
    raise NoSliceFound unless is_slice?

    razor_module = Object.full_const_get(SLICE_PREFIX + namespace.capitalize).new(arguments)
    razor_module.web_command = web_command
    razor_module.verbose = verbose
    razor_module.debug = debug
    razor_module.slice_call
  end

  # Validate slice
  def is_slice?
    return false unless namespace
    slice_array.find { |slice| namespace.downcase == slice.downcase }
  end
end
