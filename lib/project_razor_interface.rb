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

    get_slices_loaded
  end

  # Call the slice
  def call_razor_slice
    raise NoSliceFound unless is_slice?

    begin
      razor_module = Object.full_const_get(SLICE_PREFIX + namespace.capitalize).new(arguments)
      razor_module.web_command = web_command
      razor_module.verbose = verbose
      razor_module.debug = debug
      razor_module.slice_call
    rescue => e
      raise if debug
      print_header
      if namespace
        print "\n [#{namespace.capitalize}] ".red
        print "<-#{e.message} \n".yellow
      end
    end
  end

  # Load slices
  def get_slices_loaded
    temp_hash = Hash.new
    ObjectSpace.each_object do |object_class|
      if object_class.to_s.start_with?(SLICE_PREFIX) && object_class.to_s != SLICE_PREFIX
        @slice_array << object_class.to_s.sub(SLICE_PREFIX,"").strip
      end
    end

    @slice_array.uniq!
  end

  # Validate slice
  def is_slice?
    return false unless namespace
    slice_array.find { |slice| namespace.downcase == slice.downcase }
  end
end
