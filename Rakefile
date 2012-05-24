ROOT = File.dirname __FILE__

task :default => :build

directory 'dist/monitor'

file 'dist/monitor/package.json' => ['monitor-package.json', 'dist/monitor'] do |task|
    FileUtils.cp task.prerequisites.first, task.name
    Dir.chdir 'dist/monitor'
    sh 'npm install' do |ok, id|
        ok or fail "npm could not install the monitor dependencies"
    end
    Dir.chdir ROOT
end

file 'dist/monitor/default-conf.json' => ['monitor/default-conf.json', 'dist/monitor'] do |task|
    FileUtils.cp task.prerequisites.first, task.name
end

file 'dist/monitor/monitor.js' => ['monitor/monitor.coffee', 'dist/monitor'] do |task|
    brew_javascript task.prerequisites.first, task.name, true
end

desc "Build SAKS"
build_deps = [
    'dist/monitor/package.json',
    'dist/monitor/monitor.js',
    'dist/monitor/default-conf.json'
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

desc "Run live Monitor tests"
task :testlive_monitor, [:confpath] => [:devsetup, :install] do |task, args|
    system "sudo bin/monitor/runtests #{args[:confpath]}"
end

task :clean do
    rm_rf 'node_modules'
    rm_rf 'dist'
    rm_rf 'installed'
end

def brew_javascript(source, target, node_exec)
    File.open(target, 'w') do |fd|
        if node_exec
            fd << "#!/usr/bin/env node\n\n"
        end
        fd << %x[coffee -pb #{source}]
    end
end
