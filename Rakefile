require 'yaml'
require 'fileutils'

namespace :release do
  EPOCH = 1

  desc "Package and release stable"
  task :stable, [:upload] => [:clean, :pulp_configuration, :bin_directory, :parse_stable_version] do |t, args|
    created_rpm = create_package
    upload_package('stable', created_rpm) if args[:upload] == 'upload'
  end

  desc "Package and release unstable"
  task :unstable, [:upload] => [:clean, :pulp_configuration, :bin_directory, :parse_unstable_version] do |t, args|
    created_rpm = create_package
    upload_package('unstable', created_rpm) if args[:upload] == 'upload'
  end

  task :pulp_configuration do
    pulp_config_file = File.join(ENV['HOME'], '.pulp.yml')
    raise "Missing pulp configuration file" unless File.exist? pulp_config_file
    @pulp_config = YAML.load_file(pulp_config_file)
    @version = File.open('version', &:readline).strip!.split(/-/)
  end

  task :parse_stable_version do
    if @version[1].nil? or @version[1].empty?
      @version[1] = '1'
    else
      @version[1] = "#{@version[1]}"
    end
  end

  task :parse_unstable_version do
    time = Time.new.strftime("%y%m%d%H%M%S")
    if @version[1].nil? or @version[1].empty?
      @version[1] =  time
    else
      @version[1] = "#{@version[1]}.#{time}"
    end
  end

  task :bin_directory do
    dirname = 'bin'
    unless File.directory?(dirname)
      FileUtils.mkdir_p(dirname)
    end
  end

  task :clean do
    dirname = 'bin'
    FileUtils.rm_rf(dirname) if File.directory?(dirname)
  end

  def create_package
    rpm_output = %x[
      fpm \
        --after-install "rpm/post-install.sh" \
        --after-remove "rpm/post-uninstall.sh" \
        --before-install "rpm/pre-install.sh" \
        --before-remove "rpm/pre-uninstall.sh" \
        -d 'python' \
        --epoch #{EPOCH} \
        --iteration #{@version[1]} \
        -n 'myapp' \
        -s dir  \
        -t rpm \
        -v #{@version[0]} \
        ./usr \
        ./etc \
    ]
    rpm_filename = rpm_output.match(/path=>"(.+?)"/)[1]
    puts rpm_output
    FileUtils.move(rpm_filename, 'bin')
    puts "Created RPM at: bin/#{rpm_filename}"
    rpm_filename
  end
  
  def upload_package(repository, rpm)
    %x[pulp-admin login -u#{@pulp_config['username']} -p#{@pulp_config['password']}]
    upload_output = %x[pulp-admin rpm repo uploads rpm --repo-id=#{repository} --file=#{File.join('bin', rpm)}]
    puts upload_output
    %x[pulp-admin rpm repo publish run --repo-id=#{repository}]
    %x[pulp-admin logout]
  end

end
