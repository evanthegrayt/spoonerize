EXECUTABLE = File.join('/', 'usr', 'local', 'bin', 'pakjib')
INSTALL_PATH = File.expand_path(File.join(File.dirname(__FILE__)), '..')

task :default => :install

desc "Install to `/usr/local/bin`"
task :install do
  sh("ln -s #{File.join(INSTALL_PATH, 'bin', 'pakjib')} #{EXECUTABLE}")
end

desc "Uninstall..."
task :uninstall do
  File.delete(EXECUTABLE) if File.exist?(EXECUTABLE)
end

desc "Tagging and pulling from master"
task :update do
  sh("git tag #{Time.now.strftime('%Y-%m-%d-%H%M')}")
  sh("git pull origin master")
end

desc "Checking out last deployment tag"
task :rollback do
  tags = `git tag`.strip.split("\n")
  sh("git checkout #{tags.last}")
end

