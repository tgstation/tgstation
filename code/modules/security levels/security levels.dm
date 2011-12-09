/var/security_level = 0
//0 = code green
//1 = code blue
//2 = code red
//3 = code delta

/proc/set_security_level(var/level)
	switch(level)
		if("green")
			level = SEC_LEVEL_GREEN
		if("blue")
			level = SEC_LEVEL_BLUE
		if("red")
			level = SEC_LEVEL_RED
		if("delta")
			level = SEC_LEVEL_DELTA

	//Will not be announced if you try to set to the same level as it already is
	if(level >= SEC_LEVEL_GREEN && level <= SEC_LEVEL_DELTA && level != security_level)
		switch(level)
			if(SEC_LEVEL_GREEN)
				world << "<font size=4 color='red'>Attention! security level lowered to green</font>"
				world << "<font color='red'>All threats to the station have passed. Security may not have weapons visible, privacy laws are once again fully enforced.</font>"
				security_level = SEC_LEVEL_GREEN
				for(var/obj/machinery/firealarm/FA in world)
					if(FA.z == 1)
						FA.overlays = list()
						FA.overlays += image('monitors.dmi', "overlay_green")
			if(SEC_LEVEL_BLUE)
				if(security_level < SEC_LEVEL_BLUE)
					world << "<font size=4 color='red'>Attention! security level elevated to blue</font>"
					world << "<font color='red'>The station has received reliable information about possible hostile activity on the station. Security staff may have weapons visible, random searches are permitted.</font>"
				else
					world << "<font size=4 color='red'>Attention! security level lowered to blue</font>"
					world << "<font color='red'>The immediate threat has passed. Security may no longer have weapons drawn at all times, but may continue to have them visible. Random searches are still allowed.</font>"
				security_level = SEC_LEVEL_BLUE
				for(var/obj/machinery/firealarm/FA in world)
					if(FA.z == 1)
						FA.overlays = list()
						FA.overlays += image('monitors.dmi', "overlay_blue")
			if(SEC_LEVEL_RED)
				if(security_level < SEC_LEVEL_RED)
					world << "<font size=4 color='red'>Attention! Code red!</font>"
					world << "<font color='red'>There is an immediate serious threat to the station. Security may have weapons unholstered at all times. Random searches are allowed and advised.</font>"
				else
					world << "<font size=4 color='red'>Attention! Code red!</font>"
					world << "<font color='red'>The self-destruct mechanism has been deactivated, there is still however an immediate serious threat to the station. Security may have weapons unholstered at all times, random searches are allowed and advised.</font>"
				security_level = SEC_LEVEL_RED

				/*	- At the time of commit, setting status displays didn't work properly
				var/obj/machinery/computer/communications/CC = locate(/obj/machinery/computer/communications,world)
				if(CC)
					CC.post_status("alert", "redalert")*/

				for(var/obj/machinery/firealarm/FA in world)
					if(FA.z == 1)
						FA.overlays = list()
						FA.overlays += image('monitors.dmi', "overlay_red")
			if(SEC_LEVEL_DELTA)
				world << "<font size=4 color='red'>Attention! Delta security level reached!</font>"
				world << "<font color='red'>The ship's self-destruct mechanism has been engaged. All crew are instructed to obey all instructions given by heads of staff. Any violations of these orders can be punished by death. This is not a drill.</font>"
				security_level = SEC_LEVEL_DELTA
				for(var/obj/machinery/firealarm/FA in world)
					if(FA.z == 1)
						FA.overlays = list()
						FA.overlays += image('monitors.dmi', "overlay_delta")
	else
		return

/proc/get_security_level()
	switch(security_level)
		if(SEC_LEVEL_GREEN)
			return "green"
		if(SEC_LEVEL_BLUE)
			return "blue"
		if(SEC_LEVEL_RED)
			return "red"
		if(SEC_LEVEL_DELTA)
			return "delta"

/proc/num2seclevel(var/num)
	switch(num)
		if(SEC_LEVEL_GREEN)
			return "green"
		if(SEC_LEVEL_BLUE)
			return "blue"
		if(SEC_LEVEL_RED)
			return "red"
		if(SEC_LEVEL_DELTA)
			return "delta"

/proc/seclevel2num(var/seclevel)
	switch( lowertext(seclevel) )
		if("green")
			return SEC_LEVEL_GREEN
		if("blue")
			return SEC_LEVEL_BLUE
		if("red")
			return SEC_LEVEL_RED
		if("delta")
			return SEC_LEVEL_DELTA


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