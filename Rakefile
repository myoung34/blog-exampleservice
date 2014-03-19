require 'yaml'

@pulp_config_file = File.join(ENV['HOME'], '.pulp.yml')
@pulp_config = YAML.load_file(@pulp_config_file)
@epoch = 1
@version = File.open('version', &:readline).strip!.split(/-/)

task :stable do
  raise "Missing pulp configuration file" unless File.exist? @pulp_config_file
  if @version[1].nil? or @version[1].empty?
    @version[1] = '1'
  else
    @version[1] = "#{@version[1]}"
  end
  created_rpm = create_package(@version)
  upload_package('stable', created_rpm, @pulp_config['username'], @pulp_config['password'])
end


task :unstable do
  raise "Missing pulp configuration file" unless File.exist? @pulp_config_file
  time = Time.new.strftime("%y%m%d%H%M%S")
  if @version[1].nil? or @version[1].empty?
    @version[1] =  time
  else
    @version[1] = "#{@version[1]}.#{time}"
  end
  created_rpm = create_package(@version)
  upload_package('unstable', created_rpm, @pulp_config['username'], @pulp_config['password'])
end

def create_package(version_info)
  rpm_output = %x[
    fpm \
      --after-install "rpm/post-install.sh" \
      --after-remove "rpm/post-uninstall.sh" \
      --before-install "rpm/pre-install.sh" \
      --before-remove "rpm/pre-uninstall.sh" \
      -d 'python' \
      --epoch #{@epoch} \
      --iteration #{version_info[1]} \
      -n 'myapp' \
      -s dir  \
      -t rpm \
      -v #{version_info[0]} \
      ./usr \
      ./etc \
  ]
  rpm_filename = rpm_output.match(/path=>"(.+?)"/)[1]
  FileUtils.move(rpm_filename, 'rpm')
  rpm_filename
end

def upload_package(repository, rpm, pulp_username, pulp_password)
  %x[pulp-admin login -u#{pulp_username} -p#{pulp_password}]
  upload_output = %x[pulp-admin rpm repo uploads rpm --repo-id=#{repository} --file=#{File.join('rpm',rpm)}]
  %x[pulp-admin rpm repo publish run --repo-id=#{repository}]
  %x[pulp-admin logout]
end

task :default => :unstable
