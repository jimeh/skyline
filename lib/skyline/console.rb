def load_config
  Skyline.load_config
end

def init
  Skyline.init
end

def reload
  Skyline.init(true)
end

def list(what = nil)
  case what
  when :all
    Skyline.as_groups.each do |name, group|
      puts name.to_s
      group[:instances].each do |instance|
        puts "   #{instance[:id].ljust(10)}  " +
             "#{instance[:public_ip].ljust(15)}  " +
             "#{instance[:private_ip].ljust(15)}  " +
             "#{instance[:ami].ljust(10)}  " +
             "#{instance[:type].ljust(10)}  " +
             "#{instance[:state].ljust(15)}  " +
             "#{instance[:launch_date].ljust(15)}"
      end
    end    
  when :instances
    Skyline.instances.each do |i, instance|
      puts "   #{instance[:id].ljust(10)}  " +
           "#{instance[:public_ip].ljust(15)}  " +
           "#{instance[:private_ip].ljust(15)}  " +
           "#{instance[:ami].ljust(10)}  " +
           "#{instance[:type].ljust(10)}  " +
           "#{instance[:status].ljust(15)}  " +
           "#{instance[:launch_date].ljust(15)}"
    end
  else
    Skyline.as_groups.each { |name, group| puts name.to_s }
  end
  return
end

def selected
  puts Skyline.selected
end

def cmd(command)
  Skyline.cmd(command)
end

def icmd
  if Skyline.selected.nil?
    puts "ERROR: No AS Group selected. Please use"
    puts "the \"use\" command to select one."
    return nil
  end
  exit = false
  started = false
  while !exit
    if !started
        puts "Entering interactive remote-terminal mode."
        puts ""
        puts "All entered commands are executed on all remote"
        puts "instances within selected auto-scaling group."
        puts ""
        puts "Type \"exit\"\" or \"halt\"\" to exit IRT mode."
        puts ""
        started = true
    end
    print "irt$ "
    input = STDIN.readline.strip
    if !input.nil? && input != ""
      if input =~ /^exit|halt$/
        exit = true
      else
        cmd(input)
      end
    end
  end
end

def use
  groups = ["All"] + Skyline.as_groups.map { |name, group| name }
  valid_choice = false
  while !valid_choice
    puts "Please choose a group to use:"
    groups.each_with_index { |group, i| puts "#{i}. #{group}" }
    print "Enter your choice (0-9) or press Ctrl-C to abort: "
    s = STDIN.readline.strip
    s = (s =~ /^[\d]+$/) ? s.to_i : nil
    if !s.nil? && !groups[s].nil?
      valid_choice = true
      groups[0] = :all if s == 0
      puts groups[s].inspect
      return Skyline.use(groups[s])
    else
      puts "\nERROR: Not a valid choice\n\n"
    end
  end
end

def help_me
  cmds = [
    [:reload, "Force-reload instance and AutoScaling Group info."],
    [:list, <<-hd
List loaded information. Options are:
  :all            List AS Groups with instances.
  :instances      List all instances in your EC2 account.
hd
],
    [:use, "Call without any arguments to choose which AS Group to work with."],
    [:cmd, "Run a command on all selected remote machines."],
    [:icmd, "Enter an interactive shell which runs entered commands on selected remote machines."]
  ]
  puts "Available Skyline commands:"
  cmds.each do |cmd, desc|
    print "  #{cmd.to_s.ljust(10)}   "
    desc = desc.split("\n")
    if desc.size == 1
      puts desc[0]
    else
      puts desc.shift
      desc.each do |line|
        puts "                #{line}"
      end
    end
  end
  return
end


#
# Skyhook related commands
#

def skyhook(command)
  cmd("skyhook #{command}")
end

def update(project = nil, rev = nil)
  if project.nil?
    puts "Please specify a project."
    return
  end
  rev = rev.gsub(/[^0-9]/, "") if rev.is_a?(String)
  commands = [
    [ "skyhook update",
      "Updating Skyhook on remote machines..." ],
    [ "skyhook update.#{project} #{rev}",
      "Fetching latest files for #{project} project on remote machines..." ],
    [ "skyhook mode +maintenance", 
      "Putting remote machines in maintenance mode..." ],
    [ "skyhook activate.#{project} #{rev}",
      "Activating newly fetched version of #{project} on remote machines..." ],
    [ "skyhook mode -maintenance",
      "Disabling maintenance mode on remote machines" ]
  ]
  commands.each do |command|
    puts command[1] if !command[1].nil?
    if !command[0].nil?
      puts "  Executing: #{command[0]}"
      cmd command[0]
    end
  end
  return
end

