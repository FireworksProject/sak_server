task :default => :build

desc "Build SAKS"
build_deps = [
    'dist/monitor/monitor.js'
]
task :build => build_deps do
    puts "Built SAKS"
end

task :install => :build do
    sh 'bin/install' do |ok, id|
        ok or fail "could not deploy SAKS locally"
    end
    puts "Locally deployed SAKS"
end

file 'installed' => 'package.json' do |task|
    Rake::Task[:clean].invoke
    system 'npm install'
    FileUtils.cp task.prerequisites.first, task.name
end

desc "Setup development environment"
task :devsetup => 'installed' do
    puts "Development environment ready"
end

desc "Run Treadmill tests"
task :test => [:devsetup, :install] do
    puts "Start Monitor Tests"
    system 'sudo bin/monitor/runtests'
end

task :clean do
    rm_rf 'node_modules'
    rm_rf 'dist'
    rm_rf 'installed'
end

def brew_javascript(source, target)
    File.open(target, 'w') do |fd|
        fd << %x[coffee -pb #{source}]
    end
end
