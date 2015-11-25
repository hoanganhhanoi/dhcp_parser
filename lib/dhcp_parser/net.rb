require_relative "writeconf.rb"
require_relative "host.rb"

class Net

  attr_accessor :subnet, :netmask, :option, :differ, :pool

  def initialize
    @subnet = ""
    @netmask = ""
    @option = {}
    @differ = {}
    @pool = { "range" => "",
              "allow" => "", 
              "denny" => "",
              "hosts" => []
            }
  end

  def test
    net1 = Net.new
    net2 = Net.new
    # Set subnet
    net1.subnet = "192.168.1.0"
    net1.netmask = "255.255.255.0"
    # Set option
    net1.option["routers"] = "192.168.1.1"
    net1.option["subnet-mask"] = "255.255.255.0"
    net1.option["broadcast-address"] = "192.168.1.255"
    net1.option["domain-name-servers"] = "194.168.4.100"
    net1.differ["authoritative"] = "true"
    net1.differ["default-lease-time"] = "2"
    net1.differ['max-lease-time'] = "86400"
    # Set pool
    net1.pool["range"] = { "min" => "192.168.25.20", "max" => "192.168.25.200" }
    net1.pool["allow"] = "unknown-clients"
    net1.pool["hosts"] << Host.new("bla1", "DD:GH:DF:E5:F7:D7", "192.168.1.2")
    net1.pool["hosts"] << Host.new("bla2", "00:JJ:YU:38:AC:45", "192.168.1.20")

    # Set subnet
    net2.subnet = "192.168.1.0"
    net2.netmask = "255.255.255.0"
    # Set option
    net2.option["routers"] = "192.168.1.1"
    net2.option["subnet-mask"] = "255.255.255.0"
    net2.option["broadcast-address"] = "192.168.1.255"
    net2.option["domain-name-servers"] = "194.168.4.100"
    net2.differ["default-lease-time"] = "2"
    net2.differ['max-lease-time'] = "86400"
    # Set pool
    net2.pool["range"] = { "min" => "192.168.25.20", "max" => "192.168.25.200" }
    net2.pool["denny"] = "unknown-clients"
    net2.pool["hosts"] << Host.new("bla1", "DD:GH:DF:E5:F7:D7", "192.168.1.2")
    net2.pool["hosts"] << Host.new("bla2", "00:JJ:YU:38:AC:45", "192.168.1.20")
    return [net1,net2]
  end

end