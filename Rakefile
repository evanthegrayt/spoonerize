INSTALL_PATH = File.expand_path(File.join(File.dirname(__FILE__)), '..').freeze
LINK_TO = File.join('/', 'usr', 'local', 'bin', 'spoonerise').freeze
LINK_FROM = File.join(INSTALL_PATH, 'bin', 'spoonerise').freeze

task :default => :install

desc "Install to `/usr/local/bin`"
task :install do
  File.symlink(LINK_FROM, LINK_TO)
end

desc "Uninstall..."
task :uninstall do
  File.delete(LINK_TO) if File.symlink?(LINK_TO)
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

