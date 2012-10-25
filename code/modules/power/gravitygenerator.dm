// It.. uses a lot of power.  Everything under power is engineering stuff, at least.

/obj/machinery/computer/gravity_control_computer
	name = "Gravity Generator Control"
	desc = "A computer to control a local gravity generator.  Qualified personnel only."
	icon = 'icons/obj/computer.dmi'
	icon_state = "airtunnel0e"
	anchored = 1
	density = 1
	var/obj/machinery/gravity_generator = null


/obj/machinery/gravity_generator/
	name = "Gravitational Generator"
	desc = "A device which produces a gravaton field when set up."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "TheSingGen"
	anchored = 1
	density = 1
	use_power = 1
	idle_power_usage = 200
	active_power_usage = 1000
	var/on = 1
	var/list/localareas = list()
	var/effectiverange = 25

	// Borrows code from cloning computer
/obj/machinery/computer/gravity_control_computer/New()
	..()
	spawn(5)
		updatemodules()
		return
	return

/obj/machinery/gravity_generator/New()
	..()
	spawn(5)
		locatelocalareas()
		return
	return



/obj/machinery/computer/gravity_control_computer/proc/updatemodules()
	src.gravity_generator = findgenerator()



/obj/machinery/gravity_generator/proc/locatelocalareas()
	for(var/area/A in range(src,effectiverange))
		if(A.name == "Space")
			continue // No (de)gravitizing space.
		if(A.master && !( A.master in localareas) )
			localareas += A.master

/obj/machinery/computer/gravity_control_computer/proc/findgenerator()
	var/obj/machinery/gravity_generator/foundgenerator = null
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		//world << "SEARCHING IN [dir]"
		foundgenerator = locate(/obj/machinery/gravity_generator/, get_step(src, dir))
		if (!isnull(foundgenerator))
			//world << "FOUND"
			break
	return foundgenerator


/obj/machinery/computer/gravity_control_computer/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/gravity_control_computer/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/gravity_control_computer/attack_hand(mob/user as mob)
	user.set_machine(src)
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return

	updatemodules()

	var/dat = "<h3>Generator Control System</h3>"
	//dat += "<font size=-1><a href='byond://?src=\ref[src];refresh=1'>Refresh</a></font>"
	if(gravity_generator)
		if(gravity_generator:on)
			dat += "<font color=green><br><tt>Gravity Status: ON</tt></font><br>"
		else
			dat += "<font color=red><br><tt>Gravity Status: OFF</tt></font><br>"

		dat += "<br><tt>Currently Supplying Gravitons To:</tt><br>"

		for(var/area/A in gravity_generator:localareas)
			if(A.has_gravity && gravity_generator:on)
				dat += "<tt><font color=green>[A]</tt></font><br>"

			else if (A.has_gravity)
				dat += "<tt><font color=yellow>[A]</tt></font><br>"

			else
				dat += "<tt><font color=red>[A]</tt></font><br>"

		dat += "<br><tt>Maintainence Functions:</tt><br>"
		if(gravity_generator:on)
			dat += "<a href='byond://?src=\ref[src];gentoggle=1'><font color=red> TURN GRAVITY GENERATOR OFF. </font></a>"
		else
			dat += "<a href='byond://?src=\ref[src];gentoggle=1'><font color=green> TURN GRAVITY GENERATOR ON. </font></a>"

	else
		dat += "No local gravity generator detected!"

	user << browse(dat, "window=gravgen")
	onclose(user, "gravgen")


/obj/machinery/computer/gravity_control_computer/Topic(href, href_list)
	set background = 1
	..()

	if ( (get_dist(src, usr) > 1 ))
		if (!istype(usr, /mob/living/silicon))
			usr.unset_machine()
			usr << browse(null, "window=air_alarm")
			return

	if(href_list["gentoggle"])
		if(gravity_generator:on)
			gravity_generator:on = 0

			for(var/area/A in gravity_generator:localareas)
				var/obj/machinery/gravity_generator/G
				for(G in world)
					if((A.master in G.localareas) && (G.on))
						break
				if(!G)
					A.gravitychange(0,A)


		else
			for(var/area/A in gravity_generator:localareas)
				gravity_generator:on = 1
				A.gravitychange(1,A)

		src.updateUsrDialog()
		return