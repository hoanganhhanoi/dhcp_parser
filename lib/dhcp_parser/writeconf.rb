module WriteConf

  def self.write_file_conf(file_name,nets)
    if nets.nil?
      return false
    else
      data = ""
      nets.each do |net|
        data += WriteConf.set_data(net)
      end
      file = File.open("#{file_name}","a+")
      file.puts(data)
      file.close
      return true
    end
  end

  def self.test(file_name) 
    file = File.open("#{file_name}","w+") do |file|
      file.write("test") 
    end
  end

  def self.set_data(net)

    data = "subnet #{net.subnet} netmask #{net.netmask} {\n"

    # set option
    net.option.each do |key, value|
      data += "\s\soption #{key}\s\s\s\s\s\s\s\s\s #{value};\n"
    end

    # set differ
    net.differ.each do |key, value|
      if key == "authoritative"
        if value
          data += "\s\s#{key};\n"
        end
      else
        data += "\s\s#{key}\s\s\s\s\s\s\s\s\s#{value};\n"
      end
    end

    # set pool
    data += "\s\spool {\n"
    net.pool.each do |key, value|
      if key.eql?("range")
        data += "\s\s\s\srange #{value["min"]} #{value["max"]};\n"
      elsif key.eql?("hosts")
        value.each do |h|
          data += "\s\s\s\shost #{h.host} {\n"
          data += "\s\s\s\s\s\shardware ethernet #{h.hardware_ethernet};\n"
          data += "\s\s\s\s\s\sfixed-address #{h.fixed_address}\n"
          data += "\s\s\s\s}\n" 
        end
      elsif !value.nil? && !value.empty?
        data += "\s\s\s\s#{key} #{value};\n"
      end
    end
    data += "\s\s}\n"
    data += "}\n\n"

    return data
  end
end