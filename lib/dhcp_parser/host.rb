
class Host

  attr_reader :host, :hardware_ethernet, :fixed_address
  
  def initialize(host, hardware_ethernet, fixed_address)
    @host = host
    @hardware_ethernet = hardware_ethernet
    @fixed_address = fixed_address
  end
end