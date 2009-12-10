require "rubygems"
require "yaml"
require "scanf"

class Skyline
  
  @as_groups = {}
  @instances = {}
  @selected = nil
  @config = {}
  
  class << self
    attr_accessor :as_groups
    attr_accessor :instances
    attr_accessor :selected
    attr_accessor :config
  end
  
  def self.load_config
    if File.exist?("skyline_config.yml")
      @config = YAML.load_file("skyline_config.yml")
      return true
    end
    return false
  end
  
  def self.init(force = false)
    get_instances if @instances.size == 0 || force
    get_as_groups if @as_groups.size == 0 || force
    return
  end
  
  def self.use(group = nil)
    if !group.nil?
      if @as_groups.has_key?(group.to_s)
        @selected = group.to_s
        puts "Selected AutoScaling group: #{group}"
        return true
      elsif group == :all
        @selected = :all
        puts "NOTICE: You have selected all AutoScaling groups"
        return true
      else
        puts "ERROR: AutoScaling group #{group} doesn't seem to exist"
        return false
      end
    end
  end
  
  def self.cmd(command)
    ssh_key = ""
    ssh_key = "-i " + @config["ssh_key"] if @config.has_key?("ssh_key") && !@config["ssh_key"].nil?
    template = "ssh #{ssh_key} root@{REMOTE_IP} " + 
      "\"export PATH=\\\"/opt/ruby-enterprise/bin:$PATH\\\"; {CMD}\""
    cmds = []
    if @selected.nil?
      puts "ERROR: No AS Group selected."
      return
    end
    @as_groups.each do |name, group|
      if @selected.to_s == name.to_s || @selected == :all
        group[:instances].each do |instance|
          if instance[:state] == "InService" && !instance[:public_ip].nil?
            cmds << template.gsub("{REMOTE_IP}", instance[:public_ip]).gsub("{CMD}", command.gsub(/(")/, "\\\\\\1"))
          end
        end
      end
    end
    if cmds.size > 0
      puts "\nRunning command on all machines"
      self.call_parallel(cmds) do |results|
        results.each do |result|
          puts "------------------------------------------"
          puts "   Command: #{result[0]}"
          puts " Exit code: #{result[2].to_i}"
          puts "    Output: "
          puts "#{result[1]}"
        end
        puts "------------------------------------------"
      end
    else
      puts "No machines available under current AS Group."
    end
    return
  end
  
  def self.call_parallel(cmds = [], check_interval = nil)
    if cmds.size > 0
      threads, results = [], []
      cmds.each do |cmd|
        threads << Thread.new { results << [cmd, `#{cmd}`, $?] }
      end
      is_done = false
      check_interval = 0.2 if check_interval.nil?
      while is_done == false do
        sleep check_interval
        done = true
        threads.each { |thread| done = false if thread.status != false }
        is_done = true if done
      end
      yield(results)
    end
  end
  
  def self.get_instances
    print "Loading EC2 instance information. "
    raw = `ec2-describe-instances`
    if raw =~ /service error/i
      puts "ERROR: EC2 Service error."
      return false
    end
    lines = raw.split("\n")
    lines.each do |line|
      line = line.strip.split(/\s/)
      if line[0].downcase == "instance" && !line[5].nil? && line[5].downcase == "running"
        @instances[line[1]] = {
          :id => line[1], :ami => line[2], :public_dns => line[3], :private_dns => line[4],
          :status => line[5], :ssh_key => line[6], :idx => line[7], :type => line[9],
          :launch_date => line[10], :zone => line[11], :aki => line[12], :ari => line[13],
          :monitoring => (line[15] == "monitoring-enabled") ? true : false,
          :public_ip => line[16], :private_ip => line[17],
        }
      end
    end
    puts "DONE."
    return
  end
  
  def self.get_as_groups
    print "Loading EC2 AutoScaling Groups information. "
    if @instances.size == 0
      puts "ERROR: Instances not loaded, or no running instances."
      return false
    end
    raw = `as-describe-auto-scaling-groups`
    if raw =~ /service error/i
      puts "ERROR: EC2 Service error"
      return false
    end
    raw = raw.strip.split("AUTO-SCALING-GROUP")
    raw.delete("")
    raw.each do |group|
      lines = group.split("\n")
      head = lines.shift.strip.split(/\s+/)
      instances = []
      lines.each do |line|
        line = line.split(/\s+/)
        instance = {
          :id => line[1],
          :group => line[2],
          :zone => line[3],
          :state => line[4],
          :public_ip => nil, :private_ip => nil, :ami => nil, :type => nil,
          :status => nil, :ssh_key => nil, :public_dns => nil,
          :private_dns => nil, :launch_date => nil
        }
        if !@instances[line[1]].nil?
          instance = instance.merge({
            :public_ip => @instances[line[1]][:public_ip],
            :private_ip => @instances[line[1]][:private_ip],
            :ami => @instances[line[1]][:ami],
            :type => @instances[line[1]][:type],
            :status => @instances[line[1]][:status],
            :ssh_key => @instances[line[1]][:ssh_key],
            :public_dns => @instances[line[1]][:public_dns],
            :private_dns => @instances[line[1]][:private_dns],
            :launch_date => @instances[line[1]][:launch_date]            
          })
        end
        instances << instance
      end
      @as_groups[head[0]] = {
        :name => head[0], :launch_config => head[1], :zone => head[2], :load_balancer => head[3],
        :min_size => head[4], :max_size => head[5], :current_size => head[6],
        :instances => instances
      }
    end
    puts "DONE."
    return
  end
  
end