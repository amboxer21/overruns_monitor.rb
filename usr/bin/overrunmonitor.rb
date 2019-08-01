#!/usr/local/bin/ruby
 
@round    = 0
@count    = 0
@hostname = `/bin/hostname`.gsub(/\n/,'')
final_arr, old, arr_old, arr_new = [], [], [], []

  def grab_range(command,array)
    command.each_line {|x| array.push(x).flatten if x =~ /w[0-9]g1/ .. x =~ /TX/}
  end

  def push_values(old_array,final_array)
    old_array.each {|lines| lines.scan(/overruns:[0-9]+/).to_s.scan(/\d+/).each {|x| final_array.push x}}
  end

  # Compare arrays for values that differ.
  def self.incremented?(a,b)
    a.each_index do |i|

      if b[i] > a[i]
         a[i] = b[i]
         puts @count += 1
      end

      if @count == 5
        ##puts "NOTICE: Overruns are incrementing on #{@hostname}."
	`/bin/echo "NOTICE: Overruns are incrementing on #{@hostname}."  | /usr/bin/logger -t overruns`
        exit
      end

    end
  end

  # This is the initial push. It takes the overrun values and pushed them into an array
  # These values will never change unless they differ from the second push inside the loop below. 
  # In which case they will inherit the loop iterations values.
  ##grab_range(ifconfig = `/bin/cat /home/aguevara/ifconfig.txt`,arr_old)
  grab_range(ifconfig = `/sbin/ifconfig`,arr_old)
  push_values(arr_old,old)
 
  while true do
 
    # Checks values of overruns at each pass. They are cleared at the end of the loop. 
    # After comparing to the initial values
    ##grab_range(ifconfig = `/bin/cat /home/aguevara/ifconfig.txt`,arr_new)
    grab_range(ifconfig = `/sbin/ifconfig`,arr_new)
    push_values(arr_new,final_arr)
 
    incremented?(old,final_arr)
 
    arr_new.clear
    final_arr.clear
    # 1 Second sleep in between checks.
    sleep 1
    # Check 5 times then exit
    (@round == 6) ? (exit) : (@round += 1)

  end
