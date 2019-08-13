#!/usr/local/bin/ruby
 
class OverrunsMonitor

  ORIGINAL_RX_STATE, ORIGINAL_TX_STATE, INITIAL_STATE = [], [], []

  def initialize

    @final_state, @new_state = [], []
    @final_rx_state, @final_tx_state = [], []

    @round      = 0 # Loop iteration counter
    @hostname   = `/bin/hostname`.gsub(/\n/,'')

    # @hash_structure = {interface => [count, skip_tx_overrun]}
    @interfaces = {
      "w1g1" => [0, false], "w2g1" => [0, false], "w3g1" => [0, false], "w4g1" => [0, false],
      "w5g1" => [0, false], "w6g1" => [0, false], "w7g1" => [0, false], "w8g1" => [0, false],
    }

  end

  # Reset bool values in the interfaces hash
  def reset_interface_boolean_values(nested_hash)
    nested_hash.each_with_index do |interface,index|
      nested_hash[nested_hash.keys[index]][1] = false
    end
  end

  # This method queries the interface up until the TX line
  # SAMPLE OUTPUT BELOW:
  #w1g1 Link encap:Point-to-Point Protocol
  #UP POINTOPOINT RUNNING NOARP  MTU:8  Metric:1
  #RX packets:22551337 errors:0 dropped:0 overruns:17 frame:8
  #TX packets:22551308 errors:0 dropped:0 overruns:59 carrier:5
  def query_interfaces(command,array)
    command.each_line do |line|
      array.push(line).flatten if line =~ /w[1-8]g1/ .. line =~ /TX/
    end
  end

  def populate_final_array(old_array,final_array,dx='RX')
    old_array.each do |lines|
      lines.scan(/\A\s+#{dx.upcase} packets.*(overruns:[0-9]+)/).to_s.scan(/\d+/).each do |line|
        final_array.push line
      end
    end
  end

  def push_xymon_notice(interface="")
    puts "NOTICE: Overruns are incrementing on interface #{interface} via #{@hostname}."
    #`/bin/echo "NOTICE: Overruns are incrementing on interface #{interface} via #{@hostname}."  | /usr/bin/logger -t overruns`
  end

  # Compare arrays for values that differ.
  def incremented?(original_array,new_array)
    original_array.each_index do |index|
      if new_array[index] > original_array[index] and ! @interfaces[@interfaces.keys[index]][1]
        original_array[index] = new_array[index]
        @interfaces[@interfaces.keys[index]][0] += 1
        @interfaces[@interfaces.keys[index]][1] = true
        # For testing when you want to see how many times an iface is incrementing.
        # puts "#{@interfaces.keys[index]} => #{@interfaces[@interfaces.keys[index]][0]}"
        push_xymon_notice(@interfaces.keys[index]) if @interfaces[@interfaces.keys[index]][0] == 10
      end
    end
  end

  # Main method
  def monitor

    while true do
 
      ##ifconfig = `/sbin/ifconfig`
      ifconfig = `/bin/cat /home/aguevara/ifconfig.txt`

      # Checks values of overruns at each pass. They are cleared at the end of the loop. 
      # After comparing to the initial values
      query_interfaces(ifconfig,@new_state)
      populate_final_array(@new_state,@final_rx_state,'RX') # RX arg not needed but used to balance out with the method below
      populate_final_array(@new_state,@final_tx_state,'TX')
 
      incremented?(ORIGINAL_RX_STATE,@final_rx_state)
      incremented?(ORIGINAL_TX_STATE,@final_tx_state)

      reset_interface_boolean_values(@interfaces)
 
      # clear all overrun tracking arrays
      for state in [@new_state, @final_rx_state, @final_tx_state] do
        state.clear
      end

      # 1 Second sleep in between checks.
      sleep 15

      # Check 10 times then exit
      (@round == 11) ? (exit) : (@round += 1)

    end

  end

end

##ifconfig = `/sbin/ifconfig`
ifconfig = `/bin/cat /home/aguevara/ifconfig.txt`

overruns = OverrunsMonitor.new

# This is the initial push. It takes the overrun values and pushed them into an array
# These values will never change unless they differ from the second push inside the loop below. 
# In which case they will inherit the loop iterations values.
overruns.query_interfaces(ifconfig,OverrunsMonitor::INITIAL_STATE)
overruns.populate_final_array(OverrunsMonitor::INITIAL_STATE,OverrunsMonitor::ORIGINAL_RX_STATE,'RX')
overruns.populate_final_array(OverrunsMonitor::INITIAL_STATE,OverrunsMonitor::ORIGINAL_TX_STATE,'TX')

overruns.monitor
