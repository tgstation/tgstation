/obj/machinery/computer/HolodeckControl
	name = "Holodeck Control Computer"
	desc = "A computer used to control a nearby holodeck."
	icon_state = "computer_generic"
	var/area/linkedholodeck = null
	var/area/target = null
	var/active = 0
	var/list/holographic_items = list()
	var/damaged = 0
	var/last_change = 0
	var/safety = 1

	attack_ai(var/mob/user as mob)
		return src.attack_hand(user)

	attack_paw(var/mob/user as mob)
		return

	attack_hand(var/mob/user as mob)

		if(..())
			return
		user.machine = src
		var/dat


		dat += "<B>Holodeck Control System</B><BR>"
		dat += "<HR>Current Loaded Programs:<BR>"

		dat += "<A href='?src=\ref[src];emptycourt=1'>((Empty Court)</font>)</A><BR>"
		dat += "<A href='?src=\ref[src];boxingcourt=1'>((Boxing Court)</font>)</A><BR>"
		dat += "<A href='?src=\ref[src];thunderdomecourt=1'>((Thunderdome Court)</font>)</A><BR>"
		dat += "<A href='?src=\ref[src];beach=1'>((Beach)</font>)</A><BR>"
//		dat += "<A href='?src=\ref[src];turnoff=1'>((Shutdown System)</font>)</A><BR>"

		dat += "Please ensure that only holographic weapons are used in the holodeck if a combat simulation has been loaded.<BR>"

		if(!safety)
			if(issilicon(user) && (emagged))
				dat += "<font color=red>ERROR: SAFETY PROTOCOLS UNRESPONSIVE</font><BR>"
			else if(issilicon(user) && (!emagged))
				dat += "<A href='?src=\ref[src];AIrelock=1'>(<font color=red>Enable Safety Protocols?</font>)</A><BR>"
			dat += "<A href='?src=\ref[src];burntest=1'>(<font color=red>Begin Atmospheric Burn Simulation</font>)</A><BR>"
			dat += "Ensure the holodeck is empty before testing.<BR>"
			dat += "<BR>"
			dat += "<A href='?src=\ref[src];wildlifecarp=1'>(<font color=red>Begin Wildlife Simulation</font>)</A><BR>"
			dat += "Ensure the holodeck is empty before testing.<BR>"
			dat += "<BR>"
			dat += "Safety Protocols are <font color=red> DISABLED </font><BR>"
		else if(safety)
			if(issilicon(user))
				dat += "<A href='?src=\ref[src];AIoverride=1'>(<font color=red>Disable Safety Protocols?</font>)</A><BR>"
			dat += "<BR>"
			dat += "Safety Protocols are <font color=green> ENABLED </font><BR>"

		user << browse(dat, "window=computer;size=400x500")
		onclose(user, "computer")


		return


	Topic(href, href_list)
		if(..())
			return
		if((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
			usr.machine = src

			if(href_list["emptycourt"])
				target = locate(/area/holodeck/source_emptycourt)
				if(target)
					loadProgram(target)

			else if(href_list["boxingcourt"])
				target = locate(/area/holodeck/source_boxingcourt)
				if(target)
					loadProgram(target)

			else if(href_list["thunderdomecourt"])
				target = locate(/area/holodeck/source_thunderdomecourt)
				if(target)
					loadProgram(target)

			else if(href_list["beach"])
				target = locate(/area/holodeck/source_beach)
				if(target)
					loadProgram(target)

			else if(href_list["turnoff"])
				target = locate(/area/holodeck/source_plating)
				if(target)
					loadProgram(target)

			else if(href_list["burntest"])
				if(!emagged)	return
				target = locate(/area/holodeck/source_burntest)
				if(target)
					loadProgram(target)

			else if(href_list["wildlifecarp"])
				if(!emagged)	return
				target = locate(/area/holodeck/source_wildlife)
				if(target)
					loadProgram(target)

			else if(href_list["AIoverride"])
				if(!issilicon(usr))	return
				safety = 0
				log_admin("[usr] ([usr.ckey]) disabled Holodeck Safeties.")
				message_admins("[usr] ([usr.ckey]) disabled Holodeck Safeties.")

			else if(href_list["AIrelock"])
				if(!issilicon(usr))	return
				safety = 1

			src.add_fingerprint(usr)
		src.updateUsrDialog()
		return



/obj/machinery/computer/HolodeckControl/attackby(var/obj/item/weapon/D as obj, var/mob/user as mob)
//Warning, uncommenting this can have concequences. For example, deconstructing the computer may cause holographic eswords to never derez

/*		if(istype(D, /obj/item/weapon/screwdriver))
			playsound(src.loc, 'Screwdriver.ogg', 50, 1)
			if(do_after(user, 20))
				if (src.stat & BROKEN)
					user << "\blue The broken glass falls out."
					var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
					new /obj/item/weapon/shard( src.loc )
					var/obj/item/weapon/circuitboard/comm_traffic/M = new /obj/item/weapon/circuitboard/comm_traffic( A )
					for (var/obj/C in src)
						C.loc = src.loc
					A.circuit = M
					A.state = 3
					A.icon_state = "3"
					A.anchored = 1
					del(src)
				else
					user << "\blue You disconnect the monitor."
					var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
					var/obj/item/weapon/circuitboard/comm_traffic/M = new /obj/item/weapon/circuitboard/comm_traffic( A )
					for (var/obj/C in src)
						C.loc = src.loc
					A.circuit = M
					A.state = 4
					A.icon_state = "4"
					A.anchored = 1
					del(src)

*/
	if(istype(D, /obj/item/weapon/card/emag) && !emagged)
		playsound(src.loc, 'sparks4.ogg', 75, 1)
		emagged = 1
		safety = 0
		user << "\blue You vastly increase projector power and override the safety and security protocols."
		user << "Warning.  Automatic shutoff and derezing protocols have been corrupted.  Please call Nanotrasen maintence and do not use the simulator."
		log_admin("[user] ([user.ckey]) emagged Holodeck Safeties.")
		message_admins("[user] ([user.ckey]) emagged Holodeck Safeties.")
	src.updateUsrDialog()
	return

/obj/machinery/computer/HolodeckControl/New()
	..()
	linkedholodeck = locate(/area/holodeck/alphadeck)
	//if(linkedholodeck)
	//	target = locate(/area/holodeck/source_emptycourt)
	//	if(target)
	//		loadProgram(target)

//This could all be done better, but it works for now.
/obj/machinery/computer/HolodeckControl/Del()
	emergencyShutdown()
	..()

/obj/machinery/computer/HolodeckControl/meteorhit(var/obj/O as obj)
	emergencyShutdown()
	..()


/obj/machinery/computer/HolodeckControl/emp_act(severity)
	emergencyShutdown()
	..()


/obj/machinery/computer/HolodeckControl/ex_act(severity)
	emergencyShutdown()
	..()


/obj/machinery/computer/HolodeckControl/blob_act()
	emergencyShutdown()
	..()


/obj/machinery/computer/HolodeckControl/process()

	if(active)

		if(!checkInteg(linkedholodeck))
			damaged = 1
			target = locate(/area/holodeck/source_plating)
			if(target)
				loadProgram(target)
			active = 0
			for(var/mob/M in range(10,src))
				M.show_message("The holodeck overloads!")


			for(var/turf/T in linkedholodeck)
				if(prob(30))
					var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
					s.set_up(2, 1, T)
					s.start()
				T.ex_act(3)
				T.hotspot_expose(1000,500,1)


		for(var/item in holographic_items)
			if(!(get_turf(item) in linkedholodeck))
				derez(item, 0)



/obj/machinery/computer/HolodeckControl/proc/derez(var/obj , var/silent = 1)
	holographic_items.Remove(obj)

	if(istype(obj , /obj/))
		if(istype(obj:loc , /mob/))
			var/mob/M = obj:loc
			M.drop_from_slot(obj)

	if(!silent)
		var/obj/oldobj = obj
		for(var/mob/M in viewers(world.view,get_turf(obj)))
			M << "The [oldobj.name] fades away!"
	del(obj)

/obj/machinery/computer/HolodeckControl/proc/checkInteg(var/area/A)
	for(var/turf/T in A)
		if(istype(T, /turf/space))
			return 0

	return 1

/obj/machinery/computer/HolodeckControl/proc/togglePower(var/toggleOn = 0)

	if(toggleOn)
		var/area/targetsource = locate(/area/holodeck/source_emptycourt)
		holographic_items = targetsource.copy_contents_to(linkedholodeck)

		spawn(30)
			for(var/obj/effect/landmark/L in linkedholodeck)
				if(L.name=="Atmospheric Test Start")
					spawn(20)
						var/turf/T = get_turf(L)
						var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
						s.set_up(2, 1, T)
						s.start()
						if(T)
							T.temperature = 5000
							T.hotspot_expose(50000,50000,1)

		active = 1
	else
		for(var/item in holographic_items)
			derez(item)
		var/area/targetsource = locate(/area/holodeck/source_plating)
		targetsource.copy_contents_to(linkedholodeck , 1)
		active = 0


/obj/machinery/computer/HolodeckControl/proc/loadProgram(var/area/A)

	if(world.time < (last_change + 25))
		if(world.time < (last_change + 15))//To prevent super-spam clicking, reduced process size and annoyance -Sieve
			return
		for(var/mob/M in range(3,src))
			M.show_message("\b ERROR. Recalibrating projetion apparatus.")
			last_change = world.time
			return

	last_change = world.time
	active = 1

	for(var/item in holographic_items)
		derez(item)

	for(var/obj/effect/decal/cleanable/blood/B in linkedholodeck)
		del(B)

	holographic_items = A.copy_contents_to(linkedholodeck , 1)

	if(emagged)
		for(var/obj/item/weapon/melee/energy/sword/holosword/H in linkedholodeck)
			H.damtype = BRUTE

	spawn(30)
		for(var/obj/effect/landmark/L in linkedholodeck)
			if(L.name=="Atmospheric Test Start")
				spawn(20)
					var/turf/T = get_turf(L)
					var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
					s.set_up(2, 1, T)
					s.start()
					if(T)
						T.temperature = 5000
						T.hotspot_expose(50000,50000,1)


/obj/machinery/computer/HolodeckControl/proc/emergencyShutdown()
	//Get rid of any items
	for(var/item in holographic_items)
		derez(item)
	//Turn it back to the regular non-holographic room
	target = locate(/area/holodeck/source_plating)
	if(target)
		loadProgram(target)

	var/area/targetsource = locate(/area/holodeck/source_plating)
	targetsource.copy_contents_to(linkedholodeck , 1)
	active = 0







// Holographic Items!

/turf/simulated/floor/holofloor/
	thermal_conductivity = 0

/turf/simulated/floor/holofloor/grass
	name = "Lush Grass"
	icon_state = "grass1"
	floor_tile = new/obj/item/stack/tile/grass

	New()
		floor_tile.New() //I guess New() isn't run on objects spawned without the definition of a turf to house them, ah well.
		icon_state = "grass[pick("1","2","3","4")]"
		..()
		spawn(4)
			update_icon()
			for(var/direction in cardinal)
				if(istype(get_step(src,direction),/turf/simulated/floor))
					var/turf/simulated/floor/FF = get_step(src,direction)
					FF.update_icon() //so siding get updated properly

/turf/simulated/floor/holofloor/attackby(obj/item/weapon/W as obj, mob/user as mob)
	return
	// HOLOFLOOR DOES NOT GIVE A FUCK










/obj/structure/table/holotable
	name = "table"
	desc = "A square piece of metal standing on four metal legs. It can not move."
	icon = 'structures.dmi'
	icon_state = "table"
	density = 1
	anchored = 1.0
	layer = 2.8
//	throwpass = 1	//You can throw objects over this, despite it's density.


/obj/structure/table/holotable/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/structure/table/holotable/attack_alien(mob/user as mob) //Removed code for larva since it doesn't work. Previous code is now a larva ability. /N
	return attack_hand(user)

/obj/structure/table/holotable/attack_animal(mob/living/simple_animal/user as mob) //Removed code for larva since it doesn't work. Previous code is now a larva ability. /N
	return attack_hand(user)

/obj/structure/table/holotable/attack_hand(mob/user as mob)
	return // HOLOTABLE DOES NOT GIVE A FUCK


/obj/structure/table/holotable/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/grab) && get_dist(src,user)<2)
		var/obj/item/weapon/grab/G = W
		if(G.state<2)
			if(ishuman(G.affecting))
				var/mob/living/carbon/human/H = G.affecting
				var/datum/organ/external/affecting = H.get_organ("head")
				//Fucking hacky, but whatever.
				var/obj/machinery/computer/HolodeckControl/HC = locate() in world
				if(istype(HC) && HC.safety) //If the computer exists, and the safety is active...
					if(prob(25))
						add_blood(G.affecting)
						H.halloss += rand(10, 15)
						G.assailant.visible_message("\red \The [G.assailant] smashes \the [H]'s head on \the [src] with enough force to engage \the [src]'s safeties!",\
						"\red You smash \the [H]'s head on \the [src] with enough force to engage \the [src]'s safeties!",\
						"\red You hear a whine as \the [src]'s engage.")
					else
						H.halloss += rand(5, 10)
						G.assailant.visible_message("\red \The [G.assailant] smashes \the [H]'s head on \the [src]!",\
						"\red You smash \the [H]'s head on \the [src]!",\
						"\red You hear a whine as \the [src]'s is hit by something dense.")
					H.UpdateDamageIcon()
					H.updatehealth()
					H.update_clothing()
					playsound(src.loc, 'tablehit1.ogg', 50, 1, -3)
				else //Lets do REAL DAMAGE, YEAH!
					G.affecting.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been smashed on a table by [G.assailant.name] ([G.assailant.ckey])</font>")
					G.assailant.attack_log += text("\[[time_stamp()]\] <font color='red'>Smashed [G.affecting.name] ([G.affecting.ckey]) on a table.</font>")

					log_admin("ATTACK: [G.assailant] ([G.assailant.ckey]) smashed [G.affecting] ([G.affecting.ckey]) on a table.")
					message_admins("ATTACK: [G.assailant] ([G.assailant.ckey]) smashed [G.affecting] ([G.affecting.ckey]) on a table.")
					log_attack("<font color='red'>[G.assailant] ([G.assailant.ckey]) smashed [G.affecting] ([G.affecting.ckey]) on a table.</font>")
					if(prob(25))
						add_blood(G.affecting)
						affecting.take_damage(rand(10,15), 0)
						H.Weaken(2)
						if(prob(20)) // One chance in 20 to DENT THE TABLE
							affecting.take_damage(rand(0,5), 0) //Extra damage
							if(dented)
								G.assailant.visible_message("\red \The [G.assailant] smashes \the [H]'s head on \the [src] with enough force to further deform \the [src]!\nYou wish you could unhear that sound.",\
								"\red You smash \the [H]'s head on \the [src] with enough force to leave another dent!\n[prob(50)?"That was a satisfying noise." : "That sound will haunt your nightmares"]",\
								"\red You hear the nauseating crunch of bone and gristle on solid metal and the squeal of said metal deforming.")
							else
								dented = 1
								G.assailant.visible_message("\red \The [G.assailant] smashes \the [H]'s head on \the [src] so hard it left a dent!\nYou wish you could unhear that sound.",\
								"\red You smash \the [H]'s head on \the [src] with enough force to leave a dent!\n[prob(5)?"That was a satisfying noise." : "That sound will haunt your nightmares"]",\
								"\red You hear the nauseating crunch of bone and gristle on solid metal and the squeal of said metal deforming.")
						else if(prob(50))
							G.assailant.visible_message("\red [G.assailant] smashes \the [H]'s head on \the [src], [H.gender == MALE? "his" : "her"] bone and cartilage making a loud crunch!",\
							"\red You smash \the [H]'s head on \the [src], [H.gender == MALE? "his" : "her"] bone and cartilage making a loud crunch!",\
							"\red You hear the nauseating crunch of bone and gristle on solid metal, the noise echoing through the room.")
						else
							G.assailant.visible_message("\red [G.assailant] smashes \the [H]'s head on \the [src], [H.gender == MALE? "his" : "her"] nose smashed and face bloodied!",\
							"\red You smash \the [H]'s head on \the [src], [H.gender == MALE? "his" : "her"] nose smashed and face bloodied!",\
							"\red You hear the nauseating crunch of bone and gristle on solid metal and the gurgling gasp of someone who is trying to breathe through their own blood.")
					else
						affecting.take_damage(rand(5,10), 0)
						G.assailant.visible_message("\red [G.assailant] smashes \the [H]'s head on \the [src]!",\
						"\red You smash \the [H]'s head on \the [src]!",\
						"\red You hear the nauseating crunch of bone and gristle on solid metal.")
					H.UpdateDamageIcon()
					H.updatehealth()
					H.update_clothing()
					playsound(src.loc, 'tablehit1.ogg', 50, 1, -3)
			return
		G.affecting.loc = src.loc
		G.affecting.Weaken(5)
		for(var/mob/O in viewers(world.view, src))
			if (O.client)
				O << text("\red [] puts [] on the table.", G.assailant, G.affecting)
		del(W)
		return

	if (istype(W, /obj/item/weapon/wrench))
		user << "It's a holotable!  There are no bolts!"
		return

	if(isrobot(user))
		return



/obj/item/clothing/gloves/boxing/hologlove
	name = "boxing gloves"
	desc = "Because you really needed another excuse to punch your crewmates."
	icon_state = "boxing"
	item_state = "boxing"

/obj/structure/holowindow
	name = "reinforced window"
	icon = 'structures.dmi'
	icon_state = "rwindow"
	desc = "A window."
	density = 1
	layer = 3.2//Just above doors
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = 1.0
	flags = ON_BORDER


/obj/structure/holowindow/Del()
	..()


/obj/item/weapon/melee/energy/sword/holosword
	damtype = HALLOSS

/obj/item/weapon/melee/energy/sword/holosword/green
	New()
		color = "green"

/obj/item/weapon/melee/energy/sword/holosword/red
	New()
		color = "red"






/obj/machinery/readybutton
	name = "Ready Declaration Device"
	desc = "This device is used to declare ready.  If all devices in an area are ready, the event will begin!"
	icon = 'monitors.dmi'
	icon_state = "auth_off"
	var/ready = 0
	var/area/currentarea = null
	var/eventstarted = 0

	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON

/obj/machinery/readybutton/attack_ai(mob/user as mob)
	user << "The station AI is not to interact with these devices"
	return

/obj/machinery/readybutton/attack_paw(mob/user as mob)
	user << "You are too primitive to use this device"
	return

/obj/machinery/readybutton/New()
	..()


/obj/machinery/readybutton/attackby(obj/item/weapon/W as obj, mob/user as mob)
	user << "The device is a solid button, there's nothing you can do with it!"

/obj/machinery/readybutton/attack_hand(mob/user as mob)
	if(user.stat || stat & (NOPOWER|BROKEN))
		user << "This device is not powered."
		return

	currentarea = get_area(src.loc)
	if(!currentarea)
		del(src)

	if(eventstarted)
		usr << "The event has already begun!"
		return

	ready = !ready

	update_icon()

	var/numbuttons = 0
	var/numready = 0
	for(var/obj/machinery/readybutton/button in currentarea)
		numbuttons++
		if (button.ready)
			numready++

	if(numbuttons == numready)
		begin_event()

/obj/machinery/readybutton/update_icon()
	if(ready)
		icon_state = "auth_on"
	else
		icon_state = "auth_off"

/obj/machinery/readybutton/proc/begin_event()

	eventstarted = 1

	for(var/obj/structure/holowindow/W in currentarea)
		del(W)

	for(var/mob/M in currentarea)
		M << "FIGHT!"