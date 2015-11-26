require "dhcp_parser/writeconf"
require "dhcp_parser/xml"
require "dhcp_parser/net"
require "dhcp_parser/host"
require "dhcp_parser/version"
require "rubygems"

module DHCPParser
  class Conf

    attr_accessor :datas

    # Function constructor of DHCP
    def initialize(path)
      @datas = DHCPParser::Conf.read_file(path)
      @array_net = []

    end

    # Read file config return Net. Net is hash
    def self.read_file(path)
                
      str = ""
      count = 0
      counter = 0
      object = Hash.new

      begin
        if path.nil? || path.empty?
          path = "#{Gem.default_path[1]}/gems/dhcp_parser-#{DhcpParser::VERSION}/examples/default_dhcp.conf"
        end
        file = File.new("#{path}", "r")
        while (line = file.gets)
          if !line.eql?("\n") && !line.eql?("")
            element = line.strip.split
            if !element.include?("#")
              # Set new net
              if counter == 0
                count += 1
                checkoption = false 
                checkhost = false
                checkpool = true
                checksub = true
                object["net#{count}"] = { "subnet" => "",
                                          "option" => "",
                                          "pool"   => "" 
                                        }

              end

              # Filter subnet 
              last = line.strip.slice(-1,1)
              checkoption = true if !checksub
              checkhost = true if !checkpool
              checkpool = true if 
              if last.eql?("{")
                counter -= 1
                if counter == -1
                  object["net#{count}"]["subnet"] = line.gsub("\{\n","")
                  checksub = false
                end
                if counter == -2
                  checkpool = false
                end
              elsif last.eql?("}")
                counter += 1
              end

              # Get data
              if counter == -1 && checkoption
                object["net#{count}"]["option"] = object["net#{count}"]["option"] + "#{line}" 
              elsif checkhost
                object["net#{count}"]["pool"]   = object["net#{count}"]["pool"] + "#{line}"
              end
            end
          end
        end
        file.close
      rescue => err
        puts "Exception: #{err}"
        err
      end

      return object
    end

    # Get subnet and netmask
    def self.get_sub_mask(subnet)
      if subnet.nil?
        return false
      else
        array = subnet["subnet"].split
        address = { "#{array[0]}" => array[1],
                    "#{array[2]}" => array[3] }
      end
    end

    def self.get_subnet(subnet)
      if subnet.nil?
        return false
      else
        array = subnet["subnet"].split
        address = array[1]
      end
    end

    def self.get_netmask(subnet)
      if subnet.nil?
        return false
      else
        array = subnet["subnet"].split
        address = array[3]
      end
    end

    def self.get_authoritative(subnet)
      if subnet.nil?
        return false
      else
        authori = DHCPParser::Conf.get_list_option(subnet)
        if !authori["authoritative"].nil?
          return true
        else
          return false
        end
      end
    end

    # Get all config option of subnet
    def self.get_list_option(subnet, condition = false)
      if subnet.nil?
        return false
      else
        option = {}
        differ = {}
        i = 0
        line_number = subnet["option"].lines.count
        if !condition
          while i < line_number do
            if !subnet["option"].lines[i].strip.eql?("")
              substring = subnet["option"].lines[i].gsub("\;","")
              array = substring.split
              if array.include?("option")
                option["#{array[1]}"] = "#{array[2]}"
              elsif array.include?("authoritative")
                option["#{array[0]}"] = true
              else
                option["#{array[0]}"] = "#{array[1]}"
              end
            end
            i += 1
          end

          # Delete trash element  
          option.delete("}")

          return option
        else 
          while i < line_number do 
            if !subnet["option"].lines[i].strip.eql?("")
              substring = subnet["option"].lines[i].gsub("\;","")
              array = substring.split
              if array.include?("option")
                option["#{array[1]}"] = "#{array[2]}"
              elsif array.include?("authoritative")
                differ["#{array[0]}"] = true
              else
                differ["#{array[0]}"] = "#{array[1]}"
              end
            end
            i += 1
          end

          # Delete trash element  
          differ.delete("}")

          return [option, differ]
        end
      end
    end

    # Get host. Host is Hash
    def self.get_pool(subnet) 
      if subnet.nil?
        return false
      else
        pool = { "hosts" => {} }
        count = 0
        counter = 0
        check_first = true
        checkhost = true
        i = 0
        line_number = subnet["pool"].lines.count
        lines = subnet["pool"].lines

        while i < line_number do
          if !lines[i].eql?("\n")
            line = lines[i].gsub("\n","")
            # valid block 
            last = line.strip.slice(-1,1)
            if last.eql?("{")
              check_first = false
              count   += 1
              counter -= 1
              pool["hosts"]["host#{count}"] = {}
              if counter == -1
                item = line.split
                pool["hosts"]["host#{count}"]["#{item[0]}"] = item [1]
                checkhost = false
              end
            elsif last.eql?("}")
              counter += 1
            end

            # Create new host
            if counter == 0 && !line.eql?("}")
              if check_first
                substring = line.gsub("\;","")
                item = substring.split
                if item.include?("range")
                  pool["#{item[0]}"] = { "min" => item[1], "max" => item[2] }
                else
                  pool["#{item[0]}"] = item[1]
                end
              end
            end
            # Get data
            if !checkhost
              substring = line.gsub("\;","")
              item = substring.split
              if item.include?("hardware")
                pool["hosts"]["host#{count}"]["#{item[0]}_#{item[1]}"] = item[2]
              else
                pool["hosts"]["host#{count}"]["#{item[0]}"] = item[1]
              end
            end
          end
          i += 1
        end
        
        # Delete trash element
        [*1..count].each do |i|
          pool["hosts"]["host#{i}"].tap {|key| 
            key.delete("}")
          }
        end

        return pool
      end
    end

    # Get list subnet
    def subnets
      subnet = []
      index = 0
      while index < @datas.count
        index += 1
        subnet << DHCPParser::Conf.get_subnet(@datas["net#{index}"])
      end
      return subnet
    end

    # Get list netmask
    def netmasks
      netmask = []
      index = 0
      while index < @datas.count
        index += 1
        netmask << DHCPParser::Conf.get_netmask(@datas["net#{index}"])
      end
      return netmask
    end

    # Get list option
    def options
      option = []
      index = 0
      while index < @datas.count
        index += 1
        option << DHCPParser::Conf.get_list_option(@datas["net#{index}"])
      end
      return option
    end

    # Get value authoritative
    def authoritative
      authori = []
      index = 0
      while index < @datas.count
        index += 1
        authori << DHCPParser::Conf.get_authoritative(@datas["net#{index}"])
      end
      return authori
    end

    # Get pool
    def pools
      pool  = []
      index = 0
      while index < @datas.count
        index += 1
        data = DHCPParser::Conf.get_pool(@datas["net#{index}"])
        i = 0
        tmp_hash = {}
        while i < data["hosts"].count
          i += 1
          tmp_hash["#{i}"] = data["hosts"]["host#{i}"]
        end
        pool << tmp_hash
      end
      return pool
    end

    # Get range
    def ranges
      range = []
      index = 0
      while index < @datas.count
        index += 1
        data = DHCPParser::Conf.get_pool(@datas["net#{index}"])
        range << "#{data["range"]["min"]} #{data["range"]["max"]}"
      end
      return range
    end

    # Get allow
    def allow
      allow = []
      index = 0
      while index < @datas.count
        index += 1
        data = DHCPParser::Conf.get_pool(@datas["net#{index}"])
        if !data["allow"].nil?
          allow << data["allow"]
        end
      end
      return allow
    end

    # Get allow
    def denny
      denny = []
      index = 0
      while index < @datas.count
        index += 1
        data = DHCPParser::Conf.get_pool(@datas["net#{index}"])
        if !data["denny"].nil?
          denny << data["denny"]
        end
      end
      return denny
    end

    # Return data in file
    def data
      @datas
    end

    # Set data in object
    def net

      i = 0
      while i < @datas.count
        i += 1
        new_net = Net.new 
        new_net.subnet  = DHCPParser::Conf.get_subnet(@datas["net#{i}"])
        new_net.netmask = DHCPParser::Conf.get_netmask(@datas["net#{i}"])

        list_option = DHCPParser::Conf.get_list_option(@datas["net#{i}"], true)
        new_net.option  = list_option[0]
        new_net.differ  = list_option[1]

        pool        = DHCPParser::Conf.get_pool(@datas["net#{i}"])
        new_net.pool["range"] = pool["range"]
        new_net.pool["allow"] = pool["allow"]
        new_net.pool["denny"] = pool["denny"]
        # set host
        index = 0 
        while index < pool["hosts"].count
          index += 1
          host_name = pool["hosts"]["host#{index}"]["host"]
          ethernet  = pool["hosts"]["host#{index}"]["hardware_ethernet"]
          address   = pool["hosts"]["host#{index}"]["fixed-address"] 
          host      = Host.new(host_name, ethernet, address)
          new_net.pool["hosts"] << host
        end
        @array_net << new_net
      end
      return @array_net
    end

    # Write file
    def write_file_conf(file_name, arr_net)
      if !arr_net.empty?
        result = WriteConf.write_file_conf(file_name, arr_net)
      end
    end

    # Convert xml
    def to_xml(arr_net)
      xml = XMLConvert.to_xml(arr_net)
    end

    # Write file xml 
    def write_file_xml(file_name, xml_string)
      result = XMLConvert.write_file_xml(file_name, xml_string)
    end
  end
end
