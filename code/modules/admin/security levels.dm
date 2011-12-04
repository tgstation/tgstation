/var/security_level = 0
//0 = code green
//1 = code blue
//2 = code red
//3 = code delta

/proc/set_security_level(var/level)
	switch(level)
		if("green")
			level = 0
		if("blue")
			level = 1
		if("red")
			level = 2
		if("delta")
			level = 3

	if(level >= 0 && level <= 3)
		switch(level)
			if(0)
				world << "<font size=4 color='red'>Attention! security level lowered to green</font>"
				world << "<font color='red'>All threats to the station have passed. Security may not have weapons visible, privacy laws are once again fully enforced.</font>"
				security_level = 0
				for(var/obj/machinery/firealarm/FA in world)
					if(FA.z == 1)
						FA.overlays = list()
						FA.overlays += image('monitors.dmi', "overlay_green")
			if(1)
				if(security_level < 1)
					world << "<font size=4 color='red'>Attention! security level elevated to blue</font>"
					world << "<font color='red'>The station has received reliable information about possible hostle activity on the station. Security staff may have weapons visible, random searches are permitted.</font>"
				else
					world << "<font size=4 color='red'>Attention! security level lowered to blue</font>"
					world << "<font color='red'>The immediate threat has passed. Security may no longer have weapons drawn at all times, but may continue to have them visible. Random searches are still allowed.</font>"
				security_level = 1
				for(var/obj/machinery/firealarm/FA in world)
					if(FA.z == 1)
						FA.overlays = list()
						FA.overlays += image('monitors.dmi', "overlay_blue")
			if(2)
				if(security_level < 2)
					world << "<font size=4 color='red'>Attention! Code red!</font>"
					world << "<font color='red'>There is an immediate serious threat to the station. Security may have weapons unholstered at all times. Random searches are allowed and advised.</font>"
				else
					world << "<font size=4 color='red'>Attention! Code red!</font>"
					world << "<font color='red'>The self-destruct mechanism has been deactivated, there is still however an immediate serious threat to the station. Security may have weapons unholstered at all times, random searches are allowed and advised.</font>"
				security_level = 2
				for(var/obj/machinery/firealarm/FA in world)
					if(FA.z == 1)
						FA.overlays = list()
						FA.overlays += image('monitors.dmi', "overlay_red")
			if(3)
				world << "<font size=4 color='red'>Attention! Delta security level reached!</font>"
				world << "<font color='red'>The ship's self-destruct mechanism has been engaged. All crew are instructed to obey all instructions given by heads of staff. Any violations of these orders can be punished by death. This is not a drill.</font>"
				security_level = 3
				for(var/obj/machinery/firealarm/FA in world)
					if(FA.z == 1)
						FA.overlays = list()
						FA.overlays += image('monitors.dmi', "overlay_delta")
	else
		return


/*DEBUG
/mob/verb/set_thing0()
	set_security_level(0)
/mob/verb/set_thing1()
	set_security_level(1)
/mob/verb/set_thing2()
	set_security_level(2)
/mob/verb/set_thing3()
	set_security_level(3)
*/