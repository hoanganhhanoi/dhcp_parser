# DhcpParser

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/dhcp_parser`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dhcp_parser'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dhcp_parser

## Usage

#### With file dhcp.conf

```ruby
subnet 192.168.1.0 netmask 255.255.255.0 {
  
  # config file 
  # config file
  option routers                  192.168.1.1;
  option subnet-mask              255.255.255.0;
  option broadcast-address        192.168.1.255;
  option domain-name-servers      194.168.4.100;
  option ntp-servers              192.168.1.1;
  option netbios-name-servers     192.168.1.1;
  option netbios-node-type 2;
  default-lease-time 86400;
  max-lease-time 86400;
  authoritative;

  # config file
  # config file
  pool {
    # config file
    range 192.168.25.20 192.168.25.200; 
    allow unknown-clients; 
    host bla1 {
      # comment .......
      hardware ethernet DD:GH:DF:E5:F7:D7;
      fixed-address 192.168.1.2;
    }
    host bla2 {
      # comment .......
      hardware ethernet 00:JJ:YU:38:AC:45;
      fixed-address 192.168.1.20;
    }
  }
}

subnet  10.152.187.0 netmask 255.255.255.0 {

  option routers                  10.152.187.1;
  option subnet-mask              255.255.255.0;
  option broadcast-address        10.150.168.255;
  option domain-name-servers      192.168.4.101;
  option ntp-servers              10.152.187.10;
  option netbios-name-servers     10.152.187.12;
  option netbios-node-type 2;

  default-lease-time 86400;
  max-lease-time 86400;
  pool {
    range 192.168.25.20 192.168.25.30; 
    denny unknown-clients;
    host bla3 {
      hardware ethernet 00:KK:HD:66:55:9B;
      fixed-address 10.152.187.2;
    }
  }
}
```

#### 1. Read file

* The first, create object dhcp with param: the path to file config

```ruby
dhcp = DHCPParser::Conf.new(path)
```

* Get subnet

```ruby
dhcp.subnets
#Result
=> ["192.168.1.0", "10.152.187.0"]
```

* Get netmask

```ruby
dhcp.netmasks
#Result
=> ["255.255.255.0"]
```

* Get list pool

```ruby
dhcp.pools
#Result
=> [{"1"=>
   {"host"=>"bla1",
    "hardware_ethernet"=>"DD:GH:DF:E5:F7:D7",
    "fixed-address"=>"192.168.1.2"},
  "2"=>
   {"host"=>"bla2",
    "hardware_ethernet"=>"00:JJ:YU:38:AC:45",
    "fixed-address"=>"192.168.1.20"}},
 {"1"=>
   {"host"=>"bla3",
    "hardware_ethernet"=>"00:KK:HD:66:55:9B",
    "fixed-address"=>"10.152.187.2"}}]
```

* Get list option

```ruby
dhcp.options
=> [{"routers"=>"192.168.1.1",
  "subnet-mask"=>"255.255.255.0",
  "broadcast-address"=>"192.168.1.255",
  "domain-name-servers"=>"194.168.4.100",
  "ntp-servers"=>"192.168.1.1",
  "netbios-name-servers"=>"192.168.1.1",
  "netbios-node-type"=>"2",
  "default-lease-time"=>"86400",
  "max-lease-time"=>"86400",
  "authoritative"=>true},
 {"routers"=>"10.152.187.1",
  "subnet-mask"=>"255.255.255.0",
  "broadcast-address"=>"10.150.168.255",
  "domain-name-servers"=>"192.168.4.101",
  "ntp-servers"=>"10.152.187.10",
  "netbios-name-servers"=>"10.152.187.12",
  "netbios-node-type"=>"2",
  "default-lease-time"=>"86400",
  "max-lease-time"=>"86400"}]
```

* Get range, allow, denny in pool

```ruby
dhcp.ranges
#Result
=> ["192.168.25.20 192.168.25.200", "192.168.25.20 192.168.25.30"]

dhcp.allow
#Result
=> ["unknown-clients"]

dhcp.denny
#Result
=> ["unknown-clients"]
```

* Get data to object array

```ruby
array_net = dhcp.net
# Result
array_net[0]
=> [#<Net:0xb98d1594
  @differ=
   {"default-lease-time"=>"60400",
    "max-lease-time"=>"60400",
    "authoritative"=>true},
  @netmask="255.255.255.0",
  @option=
   {"routers"=>"192.168.1.1",
    "subnet-mask"=>"255.255.255.0",
    "broadcast-address"=>"192.168.1.255",
    "domain-name-servers"=>"194.168.4.100",
    "ntp-servers"=>"192.168.1.1",
    "netbios-name-servers"=>"192.168.1.1"},
  @pool=
   {"range"=>{"min"=>"192.168.25.20", "max"=>"192.168.25.200"},
    "allow"=>"unknown-clients",
    "denny"=>nil,
    "hosts"=>
     [#<Host:0xb98d8a24
       @fix_address="192.168.1.2",
       @hardware_ethernet="DD:GH:DF:E5:F7:D7",
       @host="bla1">,
      #<Host:0xb98d88a8

```

* Set array net

```ruby
#
# Create object 
net1 = Net.new
net2 = Net.new

# the object's attribute list
subnet = ""
netmask = ""
option = {}
differ = {}
pool = { "range" => "",
         "allow" => "", 
         "denny" => "",
         "hosts" => []
       }

# Set attributes: 
net1.attribute              
net2.attribute
```

#### 2. Write file

Create object net, then set attribute for object. Then call method write_file in module WriteConf with param: "path/file_name", "array_net"

```ruby
array_net = dhcp.net
result = dhcp.write_file_conf(path/file_name.type, array_net)
# Success
  => true
# Fail
  => false 
```

#### 3. Convert to XML and write file xml

```ruby
# Convert to XML
array_net = dhcp.net
xml = dhcp.to_xml(array_net)

# Write file
result = dhcp.write_file_xml(path/filename.type, xml)

# Success
  => true
# Fail
  => false 
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake false` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/dhcp_parser.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

