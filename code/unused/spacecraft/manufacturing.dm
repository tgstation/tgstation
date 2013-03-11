//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

// Entirely unfinished. Mostly just bouncing ideas off the code.


// Smelting
// Grinding
// Spraying
// Crate

/obj/deploycrate
	icon = 'icons/obj/mining.dmi'
	icon_state = "deploycrate"
	density = 1
	var/payload

/obj/deploycrate/attack_hand(mob/user as mob)
	switch(payload)
		if(null)
			return
		//if("cloner")
		//	make a cloner
		// blah blah
	for (var/mob/V in hearers(src))
		V.show_message("[src] lets out a pneumatic hiss, its panels rapdily unfolding and expanding to produce its payload.", 2)
	del(src)


/obj/machinery/nanosprayer
	icon = 'icons/obj/mining.dmi'
	icon_state = "sprayer"
	density = 1
	anchored = 1
	var/payload
	var/hacked = 0
	var/temp = 100

	var/usr_density = 5
	var/usr_lastupdate = 0

	var/time_started = 0

	var/points = 0
	var/totalpoints = 0

	var/state = 0 // 0 - Idle, 1 - Spraying, 2 - Done, 3 - Overheated

obj/machinery/nanosprayer/proc/update_temp()
	// 1 second : 1 degree
	if(src.state == 0)
		var/diff = (world.time - usr_lastupdate) * 10
		temp -= diff
		if(temp < 100)
			temp = 100
		usr_lastupdate = world.time
		return temp
	else if(src.state == 1)
		var/diff = (world.time - usr_lastupdate) * 10
		diff = diff * usr_density
		temp += diff
		usr_lastupdate = world.time
		return temp

obj/machinery/nanosprayer/process()
	src.time_started = world.time
	totalpoints = lentext(payload) * rand(5,10)
	if(!totalpoints)
		totalpoints = 1
	while(src.state == 1)
		// Each unit of cost is 20 seconds - density
		temp += density * rand(1,4)
		sleep(200 - (usr_density * 10))
		if(src.temp > 350)
			src.state = 3
			src.overheat()
			return 0
		points += usr_density
		if(points >= totalpoints)
			src.state = 2
			src.complete()
			return 1


obj/machinery/nanosprayer/proc/cooldown()
	while(state != 1)
		sleep(200)
		temp -= rand(5,20)
		if(temp < 100)
			temp = 100
			return

obj/machinery/nanosprayer/proc/overheat()
	return

obj/machinery/nanosprayer/proc/complete()
	src.totalpoints = 0
	src.points = 0
	spawn() cooldown()
	return

obj/machinery/nanosprayer/attack_hand(user as mob)
	var/dat
	if(..())
		return
	dat += text("Core Temp: [temp]�C<BR>")
	dat += text("Nanocloud Density: [usr_density] million<BR>")
	dat += text("\[<A href='?src=\ref[src];minus=1'>-</A> / <A href='?src=\ref[src];plus=1'>+</A>\]<BR>")
	if(payload)
		dat += text("<BR>Task: [payload]<BR>")
	switch(state)
		if(0)
			dat += text("Status: Idling<BR>")
		if(1)
			dat += text("Status: Spraying<BR>")
		if(2)
			dat += text("Status: Spray Task Complete<BR>")
		if(3)
			dat += text("Status: <B><FONT COLOR=RED>OVERHEATED</FONT><BR>")
	if(state == 1)
		if(points <= 0)
			points = 1
		var/complete = (points * 100)/totalpoints
		if(complete < 0)
			complete = 0
		if(complete > 100)
			complete = 100
		dat += text("Progress: <B>[complete]%</B><BR>")
	if(state == 2)
		dat += text("Progress: <B>100%</B><BR>")
		dat += text("\[<A href='?src=\ref[src];release=1'>Release Payload</A>\]<BR>")
	dat += text("<HR><BR><A href='?src=\ref[src];settask=1'>Set Task</A><BR>")
	dat += text("<A href='?src=\ref[src];start=1'>Start Spray</A><BR>")
	dat += text("<A href='?src=\ref[src];stop=1'>Cancel Spray</A>")
	dat += text("<BR><BR><A href='?src=\ref[src];refresh=1'>Refresh</A>")
	user << browse("<HEAD><TITLE>NANO SPRAY 1.1</TITLE></HEAD><TT>[dat]</TT>", "window=nanosprayer")
	onclose(user, "nanosprayer")

obj/machinery/nanosprayer/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["plus"])
		usr_density += 1
	if(href_list["minus"])
		usr_density -= 1
		if(usr_density < 1)
			usr_density = 1
	if(href_list["start"])
		if(state == 0)
			state = 1
			spawn() src.process()
	if(href_list["stop"])
		if(state == 1)
			state = 0
			points = 0
			totalpoints = 0
			spawn() cooldown()
	if(href_list["settask"])
		if(state == 0)
			var/temppayload = input("Set a Task:", "Job Assignment") as text|null
			if(temppayload)
				payload = temppayload
	//if(href_list["release"])
	//	if(state == 2)
			// Create the crate somewhere
	src.updateUsrDialog()

/obj/machinery/smelter
	icon = 'icons/obj/mining.dmi'
	icon_state = "sprayer"
	density = 1
	anchored = 1
	var/locked = 0
	var/closed = 0
	var/state = 0 // 0 - Idle, 1 - Smelt, 2 - Cool, 3 - Clean
	var/slag = 0
	var/hacked = 0

obj/machinery/smelter/attack_hand(user as mob)
	var/dat
	if(..())
		return
	dat += text("<h2>Smelt-o-Matic Control Interface</h2>")
	dat += text("The red light is [src.closed ? "off" : "on"].<BR>")
	dat += text("The green light is [src.locked ? "on" : "off"].<BR>")
	switch(slag)
		if(0)
			dat += text("The meter is resting at zero.<BR>")
		if(1 to 2)
			dat += text("The meter is wobbling at the mid-point marker.<BR>")
		if(3)
			dat += text("The meter strains, displaying its maximum value.<BR>")
		else
			dat += text("The meter has broken.<BR>")
	switch(state)
		if(0)
			dat += text("<b>Status</b>:<i>Idle</i><BR>")
		if(1)
			dat += text("<b>Status</b>:<i>Smelting</i><BR>")
		if(2)
			dat += text("<b>Status</b>:<i>Cooling</i><BR>")
		if(3)
			dat += text("<b>Status</b>:<i>Cleaning</i><BR>")
	dat += text("<HR /><BR>Turn key <A href='?src=\ref[src];key=1'>[src.locked ? "to upper-left position" : "to upper-right position"]</A><BR>")
	dat += text("Flip switch <A href='?src=\ref[src];switch=1'>[src.closed ? "up" : "down"]</A><BR>")
	dat += text("<A href='?src=\ref[src];button=1'>Push large flashing yellow button</A><BR>")
	user << browse("<HEAD><TITLE>SMELTOMATIC</TITLE></HEAD><TT>[dat]</TT>", "window=smelter")
	onclose(user, "smelter")


obj/machinery/smelter/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["key"])
		src.locked = !src.locked
	if(href_list["switch"])
		src.closed = !src.closed
	if(href_list["button"])
		//Do stuff to actually smelt shit or something I don't know
		return
	src.updateUsrDialog()


/obj/machinery/slaggrinder
	icon = 'icons/obj/mining.dmi'

	density = 1
	anchored = 1



/obj/machinery/adminmachine
	icon = 'icons/obj/mining.dmi'
	icon_state = "sprayer"
	density = 1
	anchored = 1

	var/gameticker
	var/gameworld

	New()
		..()
		gameticker = ticker
		gameworld = world
