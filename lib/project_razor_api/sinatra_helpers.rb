module SinatraHelpers
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

    if params and params.size < 3
      args << 'default'
    end

    args << params

    # XXX We really need to pick one class
    # that gets returned
    result = run_razor(args)
    result.is_a?(String) ? result : result.to_json
  end
end
