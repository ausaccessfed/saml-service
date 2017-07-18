# frozen_string_literal: true

require 'yaml'

config = YAML.load_file(File.expand_path('../deploy.yml', __FILE__))
puma_config = config['puma']

preload_app!
daemonize

bind puma_config['bind']
workers 2
threads 8, 32
tag 'hostedidp'
pidfile 'tmp/pids/puma.pid'

stdout_redirect puma_config['stdout'],
                puma_config['stderr'],
                :append
