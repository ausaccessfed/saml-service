class APIConstraints
  def initialize(version:, default: false)
    @version = version
    @default = default
  end

  def matches?(req)
    @default || req.headers['Accept'].include?(version_string)
  end

  private

  def version_string
    app = 'saml'
    "application/vnd.aaf.#{app}.v#{@version}+json"
  end
end
