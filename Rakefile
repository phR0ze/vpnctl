task :default => :build

task :build do
  system('bundler install --system')
  exit(1) if not system("./test/test.rb -p")
end

# vim: ft=ruby:ts=2:sw=2:sts=2