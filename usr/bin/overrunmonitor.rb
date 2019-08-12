#!/usr/local/bin/ruby
 
class OverrunsMonitor

  @@errors_found = false

  ORIGINAL_STATE, INITIAL_STATE = [], []

  def initialize

    @final_state, @new_state = [], []
    @final_rx_state, @final_tx_state = [], []

    @round      = 0 # Loop iteration counter
    @hostname   = `/bin/hostname`.gsub(/\n/,'')

    @interfaces = {
      "w1g1" => 0, "w2g1" => 0, "w3g1" => 0, "w4g1" => 0,
      "w5g1" => 0, "w6g1" => 0, "w7g1" => 0, "w8g1" => 0,
    }

  end

  def query_interfaces(command,array)
    command.each_line do |line|
      array.push(line).flatten if line =~ /w[1-8]g1/ .. line =~ /TX/
    end
  end

  def populate_final_array(old_array,final_array,dx='RX')
    old_array.each do |lines|
      lines.scan(/\A\s+#{dx.upcase} packets.*(overruns:[0-9]+)/).to_s.scan(/\d+/).each do |line|
        puts "line => (#{dx.upcase}) :- #{line}"
        final_array.push line
      end
    end
  end

  # Compare arrays for values that differ.
  def incremented?(original_array,new_array)
    original_array.each_index do |index|
      if new_array[index] > original_array[index]
         original_array[index] = new_array[index]
         @interfaces[@interfaces.keys[index]] += 1
         # For testing when you want to see how many times an iface is incrementing.
         puts "#{@interfaces.keys[index]} => #{@interfaces[@interfaces.keys[index]]}"
      end

      if @interfaces[@interfaces.keys[index]] == 10
        puts "NOTICE: Overruns are incrementing on interface #{@interfaces.keys[index]} via #{@hostname}."
	#`/bin/echo "NOTICE: Overruns are incrementing on #{@hostname}."  | /usr/bin/logger -t overruns`
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
      ##query_interfaces(ifconfig,@new_state)

      populate_final_array(@new_state,@final_rx_state,'RX')
      #populate_final_array(@new_state,@final_tx_state,'TX')
 
      incremented?(ORIGINAL_STATE,@final_rx_state)
      #incremented?(ORIGINAL_STATE,@final_tx_state)
 
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
##overruns.query_interfaces(ifconfig,OverrunsMonitor::INITIAL_STATE)
overruns.populate_final_array(OverrunsMonitor::INITIAL_STATE,OverrunsMonitor::ORIGINAL_STATE)

overruns.monitor
