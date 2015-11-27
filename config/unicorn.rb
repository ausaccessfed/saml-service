ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

worker_processes 2
preload_app true
pid File.join(ROOT, 'tmp', 'pids', 'unicorn.pid')
stdout_path '/var/log/aaf/saml/unicorn/stdout.log'
stderr_path '/var/log/aaf/saml/unicorn/stderr.log'

before_fork do |server, _worker|
  Sequel::Model.db.disconnect

  old_pid = File.join(ROOT, 'tmp', 'pids', 'unicorn.pid.oldbin')
  if File.exist?(old_pid) && server.pid != old_pid
    begin
      Process.kill('QUIT', File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      :not_running
    end
  end
end

class Unicorn::HttpServer # rubocop:disable ClassAndModuleChildren
  def proc_name(tag)
    $0 = ([File.basename(START_CTX[0]), 'saml',
           tag]).concat(START_CTX[:argv]).join(' ')
  end
end
