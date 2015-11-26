
module XMLConvert

  def self.to_xml(arr_net)
    if arr_net.empty?
      return false
    else
      xml = "<subnets>\n"

      arr_net.each do |net|
        xml += "\s\s<subnet>\n"
        # Set subnet
        xml += "\s\s\s\s<net>#{net.subnet}</net>\n"
        # Set netmask
        xml += "\s\s\s\s<mask>#{net.netmask}</mask>\n"

        # Set option
        xml += "\s\s\s\s<option>\n"
        net.option.each do |key, value|
          xml += "\s\s\s\s\s\s<#{key}>#{value}</#{key}>\n"
        end 
        xml += "\s\s\s\s</option>\n"

        # Set differ
        if net.differ["authoritative"].nil?
          xml += "\s\s\s\s<authoritative>false<authoritative>\n"
        end
        net.differ.each do |key, value|
          xml += "\s\s\s\s<#{key}>#{value}</#{key}>\n"
        end

        # Set pool
        xml += "\s\s\s\s<pool>\n"
        net.pool.each do |key, value|
          if key.eql?("range")
            xml += "\s\s\s\s\s\s<#{key}>\n"
            xml += "\s\s\s\s\s\s\s\s<min>#{value["min"]}</min>\n"
            xml += "\s\s\s\s\s\s\s\s<max>#{value["max"]}</max>\n"
            xml += "\s\s\s\s\s\s</#{key}>\n"
          elsif key.eql?("hosts")
            xml += "\s\s\s\s\s\s<#{key}>\n"
            value.each do |h|
              xml += "\s\s\s\s\s\s\s\s<host>\n"
              xml += "\s\s\s\s\s\s\s\s\s\s<name>#{h.host}</name>\n"
              xml += "\s\s\s\s\s\s\s\s\s\s<ethernet>#{h.hardware_ethernet}</ethernet>\n"
              xml += "\s\s\s\s\s\s\s\s\s\s<address>#{h.fixed_address}</address>\n"
              xml += "\s\s\s\s\s\s\s\s</host>\n"
            end
            xml += "\s\s\s\s\s\s</#{key}>\n"
          else
            xml += "\s\s\s\s\s\s<#{key}>#{value}</#{key}>\n"
          end
        end
        xml += "\s\s\s\s</pool>\n"

        # end subnet
        xml += "\s\s</subnet>\n"
      end

      # end subnets
      xml += "</subnets>"
    end
  end

  def self.write_file_xml(file_name, xml_string)
    if xml_string.empty? && file_name.empty?
      return false
    else
      File.open("#{file_name}", "w+") do |file|
        file.write(xml_string)
      end
      return true
    end
  end
end 