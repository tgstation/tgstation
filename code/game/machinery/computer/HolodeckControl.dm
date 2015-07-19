/obj/machinery/computer/HolodeckControl
	name = "holodeck control console"
	desc = "A computer used to control a nearby holodeck."
	icon_screen = "holocontrol"
	icon_keyboard = "tech_key"
	var/area/linkedholodeck = null
	var/area/target = null
	var/active = 0
	var/list/holographic_items = list()
	var/damaged = 0
	var/last_change = 0

/obj/machinery/computer/HolodeckControl/attack_hand(mob/user)

	if(..())
		return
	user.set_machine(src)

	var/dat = "<h3>Current Loaded Programs</h3>"
	dat += "<A href='?src=\ref[src];emptycourt=1'>((Empty Court)</font>)</A><BR>"
	dat += "<A href='?src=\ref[src];boxingcourt=1'>((Dodgeball Arena)</font>)</A><BR>"
	dat += "<A href='?src=\ref[src];basketball=1'>((Basketball Court)</font>)</A><BR>"
	dat += "<A href='?src=\ref[src];thunderdomecourt=1'>((Thunderdome Court)</font>)</A><BR>"
	dat += "<A href='?src=\ref[src];beach=1'>((Beach)</font>)</A><BR>"
//	dat += "<A href='?src=\ref[src];turnoff=1'>((Shutdown System)</font>)</A><BR>"

	dat += "<span class='notice'>Please ensure that only holographic weapons are used in the holodeck if a combat simulation has been loaded.</span><BR>"

	if(emagged)
		dat += "<A href='?src=\ref[src];burntest=1'>(<font color=red>Begin Atmospheric Burn Simulation</font>)</A><BR>"
		dat += "Ensure the holodeck is empty before testing.<BR>"
		dat += "<BR>"
		dat += "<A href='?src=\ref[src];wildlifecarp=1'>(<font color=red>Begin Wildlife Simulation</font>)</A><BR>"
		dat += "Ensure the holodeck is empty before testing.<BR>"
		dat += "<BR>"
		if(issilicon(user))
			dat += "<A href='?src=\ref[src];AIoverride=1'>(<font color=green>Re-Enable Safety Protocols?</font>)</A><BR>"
		dat += "Safety Protocols are <font class='bad'>DISABLED</font><BR>"
	else
		if(issilicon(user))
			dat += "<A href='?src=\ref[src];AIoverride=1'>(<font color=red>Override Safety Protocols?</font>)</A><BR>"
		dat += "<BR>"
		dat += "Safety Protocols are <font class='good'>ENABLED</font><BR>"

	//user << browse(dat, "window=computer;size=400x500")
	//onclose(user, "computer")
	var/datum/browser/popup = new(user, "computer", name, 400, 500)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return


/obj/machinery/computer/HolodeckControl/Topic(href, href_list)
	if(..())
		return
	if((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)

		if(href_list["emptycourt"])
			target = locate(/area/holodeck/source_emptycourt)
			if(target)
				loadProgram(target)

		else if(href_list["boxingcourt"])
			target = locate(/area/holodeck/source_boxingcourt)
			if(target)
				loadProgram(target)

		else if(href_list["basketball"])
			target = locate(/area/holodeck/source_basketball)
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
			emagged = !emagged
			if(emagged)
				message_admins("[key_name_admin(usr)] overrode the holodeck's safeties")
				log_game("[key_name(usr)] overrided the holodeck's safeties")
			else
				message_admins("[key_name_admin(usr)] restored the holodeck's safeties")
				log_game("[key_name(usr)] restored the holodeck's safeties")

		src.add_fingerprint(usr)
	src.updateUsrDialog()
	return



/obj/machinery/computer/HolodeckControl/emag_act(mob/user)
	if(!emagged)
		playsound(src.loc, 'sound/effects/sparks4.ogg', 75, 1)
		emagged = 1
		user << "<span class='warning'>You vastly increase projector power and override the safety and security protocols.</span>"
		user << "Warning.  Automatic shutoff and derezing protocols have been corrupted.  Please call Nanotrasen maintenance and do not use the simulator."
		log_game("[key_name(user)] emagged the Holodeck Control Console")
		src.updateUsrDialog()

/obj/machinery/computer/HolodeckControl/New()
	..()
	linkedholodeck = locate(/area/holodeck/alphadeck)
	//if(linkedholodeck)
	//	target = locate(/area/holodeck/source_emptycourt)
	//	if(target)
	//		loadProgram(target)

//This could all be done better, but it works for now.
/obj/machinery/computer/HolodeckControl/Destroy()
	emergencyShutdown()
	..()


/obj/machinery/computer/HolodeckControl/emp_act(severity)
	emergencyShutdown()
	..()


/obj/machinery/computer/HolodeckControl/ex_act(severity, target)
	emergencyShutdown()
	..()


/obj/machinery/computer/HolodeckControl/blob_act()
	emergencyShutdown()
	..()


/obj/machinery/computer/HolodeckControl/process()

	if(!..())
		return
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



/obj/machinery/computer/HolodeckControl/proc/derez(obj/obj , silent = 1)
	holographic_items.Remove(obj)

	if(obj == null)
		return

	if(isobj(obj))
		var/mob/M = obj.loc
		if(ismob(M))
			M.unEquip(obj, 1) //Holoweapons should always drop.

	if(!silent)
		var/obj/oldobj = obj
		visible_message("The [oldobj.name] fades away!")
	qdel(obj)

/obj/machinery/computer/HolodeckControl/proc/checkInteg(area/A)
	for(var/turf/T in A)
		if(istype(T, /turf/space))
			return 0

	return 1

/obj/machinery/computer/HolodeckControl/power_change()
	..()
	if(stat & NOPOWER)
		emergencyShutdown()

/obj/machinery/computer/HolodeckControl/proc/loadProgram(area/A)

	if(world.time < (last_change + 25))
		if(world.time < (last_change + 15))//To prevent super-spam clicking, reduced process size and annoyance -Sieve
			return
		for(var/mob/M in range(3,src))
			M.show_message("\b ERROR. Recalibrating projection apparatus.")
			last_change = world.time
			return

	last_change = world.time
	active = 1

	for(var/item in holographic_items)
		derez(item)

	holographic_items = A.copy_contents_to(linkedholodeck , 1)

	if(emagged)
		for(var/obj/item/weapon/holo/esword/H in linkedholodeck)
			H.damtype = BRUTE

	spawn(30)
		for(var/obj/effect/landmark/L in linkedholodeck)
			if(L.name=="Atmospheric Test Start")
				spawn(20)
					if(istype(target,/area/holodeck/source_burntest))
						var/turf/T = get_turf(L)
						var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
						s.set_up(2, 1, T)
						s.start()
						if(T)
							T.temperature = 5000
							T.hotspot_expose(50000,50000,1)
			if(L.name=="Holocarp Spawn")
				new /mob/living/simple_animal/hostile/carp/holocarp(L.loc)


/obj/machinery/computer/HolodeckControl/proc/emergencyShutdown()
	if(!istype(target,/area/holodeck/source_plating))
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

/turf/simulated/floor/holofloor
	icon_state = "floor"
	thermal_conductivity = 0

/turf/simulated/floor/holofloor/attackby(obj/item/weapon/W, mob/user, params)
	return
	// HOLOFLOOR DOES NOT GIVE A FUCK

/turf/simulated/floor/grass/holo
	thermal_conductivity = 0
	gender = PLURAL
	name = "lush grass"

/turf/simulated/floor/grass/holo/attackby(obj/item/weapon/W, mob/user, params)
	return
	// HOLOGRASS DOES NOT GIVE A FUCK

/obj/structure/table/holotable
	name = "table"

/obj/structure/table/holotable/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/table/holotable/attack_alien(mob/user) //Removed code for larva since it doesn't work. Previous code is now a larva ability. /N
	return attack_hand(user)

/obj/structure/table/holotable/attack_animal(mob/living/simple_animal/user) //Removed code for larva since it doesn't work. Previous code is now a larva ability. /N
	return attack_hand(user)

/obj/structure/table/holotable/attack_hand(mob/user)
	return // HOLOTABLE DOES NOT GIVE A FUCK


/obj/structure/table/holotable/attackby(obj/item/weapon/W, mob/user, params)
	if (istype(W, /obj/item/weapon/grab) && get_dist(src,user)<2)
		var/obj/item/weapon/grab/G = W
		if(G.state < GRAB_AGGRESSIVE)
			user << "<span class='warning'>You need a better grip to do that!</span>"
			return
		G.affecting.loc = src.loc
		G.affecting.Weaken(5)
		visible_message("<span class='danger'>[G.assailant] puts [G.affecting] on the table.</span>")
		qdel(W)
		return

	if (istype(W, /obj/item/weapon/wrench))
		user << "It's a holotable!  There are no bolts!"
		return

	if(isrobot(user))
		return

/obj/structure/holowindow
	name = "reinforced window"
	icon = 'icons/obj/structures.dmi'
	icon_state = "rwindow"
	desc = "A window."
	density = 1
	layer = 3.2//Just above doors
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = 1.0
	flags = ON_BORDER


/obj/item/weapon/holo
	damtype = STAMINA

/obj/item/weapon/holo/esword
	name = "holographic energy sword"
	desc = "May the force be with you. Sorta"
	icon_state = "sword0"
	force = 3.0
	throw_speed = 2
	throw_range = 5
	throwforce = 0
	w_class = 2.0
	hitsound = "swing_hit"
	flags = NOSHIELD
	var/active = 0

/obj/item/weapon/holo/esword/green
	New()
		item_color = "green"

/obj/item/weapon/holo/esword/red
	New()
		item_color = "red"

/obj/item/weapon/holo/esword/IsShield()
	if(active)
		return 1
	return 0

/obj/item/weapon/holo/esword/attack(mob/target, mob/user)
	..()

/obj/item/weapon/holo/esword/New()
	item_color = pick("red","blue","green","purple")

/obj/item/weapon/holo/esword/attack_self(mob/living/user)
	active = !active
	if (active)
		force = 30
		icon_state = "sword[item_color]"
		w_class = 4
		hitsound = 'sound/weapons/blade1.ogg'
		playsound(user, 'sound/weapons/saberon.ogg', 20, 1)
		user << "<span class='warning'>[src] is now active.</span>"
	else
		force = 3
		icon_state = "sword0"
		w_class = 2
		hitsound = "swing_hit"
		playsound(user, 'sound/weapons/saberoff.ogg', 20, 1)
		user << "<span class='warning'>[src] can now be concealed.</span>"
	return

//BASKETBALL OBJECTS

/obj/item/toy/beach_ball/holoball
	name = "basketball"
	icon = 'icons/obj/basketball.dmi'
	icon_state = "basketball"
	item_state = "basketball"
	desc = "Here's your chance, do your dance at the Space Jam."

/obj/item/toy/beach_ball/holoball/dodgeball
	name = "dodgeball"
	icon_state = "dodgeball"
	item_state = "dodgeball"
	desc = "Used for playing the most violent and degrading of childhood games."

/obj/item/toy/beach_ball/holoball/dodgeball/throw_impact(atom/hit_atom)
	..()
	if((ishuman(hit_atom)))
		var/mob/living/carbon/M = hit_atom
		playsound(src, 'sound/items/dodgeball.ogg', 50, 1)
		M.apply_damage(10, STAMINA)
		loc = get_turf(hit_atom) //drop at the target's feet
		if(prob(5))
			M.Weaken(3)
			visible_message("<span class='danger'>[M] is knocked right off \his feet!</span>", 3)

/obj/structure/holohoop
	name = "basketball hoop"
	desc = "Boom, shakalaka!"
	icon = 'icons/obj/basketball.dmi'
	icon_state = "hoop"
	anchored = 1
	density = 1

/obj/structure/holohoop/attackby(obj/item/weapon/W, mob/user, params)
	if (istype(W, /obj/item/weapon/grab) && get_dist(src,user)<2)
		var/obj/item/weapon/grab/G = W
		if(G.state < GRAB_AGGRESSIVE)
			user << "<span class='warning'>You need a better grip to do that!</span>"
			return
		G.affecting.loc = src.loc
		G.affecting.Weaken(5)
		visible_message("<span class='danger'>[G.assailant] dunks [G.affecting] into \the [src]!</span>", 3)
		qdel(W)
		return
	else if (istype(W, /obj/item) && get_dist(src,user)<2)
		user.drop_item(src)
		visible_message("<span class='warning'>[user] dunks [W] into \the [src]!</span>", 3)
		return

/obj/structure/holohoop/CanPass(atom/movable/mover, turf/target, height=0)
	if (istype(mover,/obj/item) && mover.throwing)
		var/obj/item/I = mover
		if(istype(I, /obj/item/projectile))
			return
		if(prob(50))
			I.loc = src.loc
			visible_message("<span class='warning'>Swish! \the [I] lands in \the [src].</span>", 3)
		else
			visible_message("<span class='danger'>\the [I] bounces off of \the [src]'s rim!</span>", 3)
		return 0
	else
		return ..(mover, target, height)


/obj/machinery/readybutton
	name = "ready declaration device"
	desc = "This device is used to declare ready. If all devices in an area are ready, the event will begin!"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "auth_off"
	var/ready = 0
	var/area/currentarea = null
	var/eventstarted = 0

	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON

/obj/machinery/readybutton/attack_ai(mob/user)
	user << "The station AI is not to interact with these devices"
	return

/obj/machinery/readybutton/attack_paw(mob/user)
	user << "<span class='warning'>You are too primitive to use this device!</span>"
	return

/obj/machinery/readybutton/New()
	..()


/obj/machinery/readybutton/attackby(obj/item/weapon/W, mob/user, params)
	user << "The device is a solid button, there's nothing you can do with it!"

/obj/machinery/readybutton/attack_hand(mob/user)
	if(user.stat || stat & (NOPOWER|BROKEN))
		user << "<span class='warning'>This device is not powered!</span>"
		return

	currentarea = get_area(src.loc)
	if(!currentarea)
		qdel(src)

	if(eventstarted)
		usr << "<span class='warning'>The event has already begun!</span>"
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
		qdel(W)

	for(var/mob/M in currentarea)
		M << "FIGHT!"
