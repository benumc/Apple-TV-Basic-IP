# Apple-TV-Basic-IP

*** pairing script should be run from a machine on the same subnet as the apple tv ***

*** make sure you have an alternative way (ir or already paired remote app) to control the apple tv during the setup process ***

Download and extract: https://github.com/benumc/Apple-TV-Basic-IP/archive/master.zip

Open a terminal and run: `ruby ~/Downloads/Apple-TV-Basic-IP-master/AppleTVpairing.rb`

Import AppleTV profile into config

Connect A/V and Ethernet

Enter IP Address on Wire (Doesn't support hostname)

Upload project file and confirm that Savant is attempting to poll the appletv

Run the ruby script AppleTVpairing.rb from a terminal prompt

While the script is running, (Using any other control method), browse to Settings->General->Remotes

Select Savant and enter 0000 done

Savant should now be able to control the apple tv via ip.
