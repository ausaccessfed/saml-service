# frozen_string_literal: true

require 'yaml'

config = YAML.load_file(File.expand_path('deploy.yml', __dir__))
puma_config = config['puma']

preload_app!

bind puma_config['bind']
workers 3
threads 1, 1
tag 'saml'
pidfile 'tmp/pids/puma.pid'

stdout_redirect puma_config['stdout'],
                puma_config['stderr'],
                :append
