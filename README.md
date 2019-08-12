# overruns_monitor.rb
A script to monitor overruns on the Sangoma cars on MTT's MGs.

#### Testing
Push the output of the ifconfig command into a file called `ifconfig.txt`. Now run your test version of the production script with a 5 second pause. While the script is running, edit one of the wireless interfaces' overruns - once every 5 seconds. On the 10th time, the script should echo a message to stdout - "Overruns are incrementing on server_name";


##### Testing output
```
[aguevara@cm-mg0 ~]$ ruby overrunmonitor.rb 
1
2
3
4
5
6
7
8
9
10
NOTICE: Overruns are incrementing on cm-mg0.
[aguevara@cm-mg0 ~]$ ruby overrunmonitor.rb 
1
2
3
4
5
6
7
8
9
10
NOTICE: Overruns are incrementing on cm-mg0.
[aguevara@cm-mg0 ~]$ 
```

##### Testing script VS Production script
```
[aguevara@cm-mg0 ~]$ diff -u /usr/bin/overrunmonitor.rb overrunmonitor.rb 
--- /usr/bin/overrunmonitor.rb	2019-08-01 13:09:08.000000000 -0400
+++ overrunmonitor.rb	2019-08-12 08:58:51.000000000 -0400
@@ -23,8 +23,8 @@
       end
 
       if @count == 10
-        ##puts "NOTICE: Overruns are incrementing on #{@hostname}."
-	       `/bin/echo "NOTICE: Overruns are incrementing on #{@hostname}."  | /usr/bin/logger -t overruns`
+        puts "NOTICE: Overruns are incrementing on #{@hostname}."
+	       #`/bin/echo "NOTICE: Overruns are incrementing on #{@hostname}."  | /usr/bin/logger -t overruns`
         exit
       end
 
@@ -34,16 +34,16 @@
   # This is the initial push. It takes the overrun values and pushed them into an array
   # These values will never change unless they differ from the second push inside the loop below. 
   # In which case they will inherit the loop iterations values.
-  ##grab_range(ifconfig = `/bin/cat /home/aguevara/ifconfig.txt`,arr_old)
-  grab_range(ifconfig = `/sbin/ifconfig`,arr_old)
+  grab_range(ifconfig = `/bin/cat /home/aguevara/ifconfig.txt`,arr_old)
+  ##grab_range(ifconfig = `/sbin/ifconfig`,arr_old)
   push_values(arr_old,old)
  
   while true do
  
     # Checks values of overruns at each pass. They are cleared at the end of the loop. 
     # After comparing to the initial values
-    ##grab_range(ifconfig = `/bin/cat /home/aguevara/ifconfig.txt`,arr_new)
-    grab_range(ifconfig = `/sbin/ifconfig`,arr_new)
+    grab_range(ifconfig = `/bin/cat /home/aguevara/ifconfig.txt`,arr_new)
+    ##grab_range(ifconfig = `/sbin/ifconfig`,arr_new)
     push_values(arr_new,final_arr)
  
     incremented?(old,final_arr)
@@ -51,7 +51,7 @@
     arr_new.clear
     final_arr.clear
     # 1 Second sleep in between checks.
-    sleep 1
+    sleep 5
     # Check 5 times then exit
     (@round == 11) ? (exit) : (@round += 1)
 
[aguevara@cm-mg0 ~]$
```
