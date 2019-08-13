# overruns_monitor.rb
A script to monitor overruns on the Sangoma cars on MTT's MGs.

#### Testing
Push the output of the ifconfig command into a file called `ifconfig.txt`. Now run your test version of the production script with a `5 second pause`. While the script is running, edit one of the wireless interfaces' overruns - once every `5 seconds`. On the 10th time, the script should echo a message to stdout - "Overruns are incrementing on server_name";


##### Testing output
```
[aguevara@cm-mg0 ~]$ ruby overrunmonitor.rb
w1g1 => 1
w2g1 => 1
w3g1 => 1
w4g1 => 1
w5g1 => 1
w6g1 => 1
w7g1 => 1
w8g1 => 1

w1g1 => 2
w2g1 => 2
w3g1 => 2
w4g1 => 2
w5g1 => 2
w6g1 => 2
w7g1 => 2
w8g1 => 2

w1g1 => 3
w2g1 => 3
w3g1 => 3
w4g1 => 3
w5g1 => 3
w6g1 => 3
w7g1 => 3
w8g1 => 3

w1g1 => 4
w2g1 => 4
w3g1 => 4
w4g1 => 4
w5g1 => 4
w6g1 => 4
w7g1 => 4
w8g1 => 4

w1g1 => 5
w2g1 => 5
w3g1 => 5
w4g1 => 5
w5g1 => 5
w6g1 => 5
w7g1 => 5
w8g1 => 5

w1g1 => 6
w2g1 => 6
w3g1 => 6
w4g1 => 6
w5g1 => 6
w6g1 => 6
w7g1 => 6
w8g1 => 6

w1g1 => 7
w2g1 => 7
w3g1 => 7
w4g1 => 7
w5g1 => 7
w6g1 => 7
w7g1 => 7
w8g1 => 7

w1g1 => 8
w2g1 => 8
w3g1 => 8
w4g1 => 8
w5g1 => 8
w6g1 => 8
w7g1 => 8
w8g1 => 8

w1g1 => 9
w2g1 => 9
w3g1 => 9
w4g1 => 9
w5g1 => 9
w6g1 => 9
w7g1 => 9
w8g1 => 9

w1g1 => 10
NOTICE: Overruns are incrementing on interface w1g1 via cm-mg0.
w2g1 => 10
NOTICE: Overruns are incrementing on interface w2g1 via cm-mg0.
w3g1 => 10
NOTICE: Overruns are incrementing on interface w3g1 via cm-mg0.
w4g1 => 10
NOTICE: Overruns are incrementing on interface w4g1 via cm-mg0.
w5g1 => 10
NOTICE: Overruns are incrementing on interface w5g1 via cm-mg0.
w6g1 => 10
NOTICE: Overruns are incrementing on interface w6g1 via cm-mg0.
w7g1 => 10
NOTICE: Overruns are incrementing on interface w7g1 via cm-mg0.
w8g1 => 10
NOTICE: Overruns are incrementing on interface w8g1 via cm-mg0.

w1g1 => 11
w2g1 => 11
w3g1 => 11
w4g1 => 11
w5g1 => 11
w6g1 => 11
w7g1 => 11
w8g1 => 11
[aguevara@cm-mg0 ~]$  
```

Open ifconfig.txt with vim and use inline vim to modify all overruns with: `:%s/\(overruns:\)\([0-9]\{1,3\}\)/\1100/g`
The `1100` number should be incremented each time the script picks up the changes: 1100, 1101, 1102, etc.
