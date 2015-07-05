//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/*
CONTAINS:
RCD
*/
/obj/item/weapon/rcd
	name = "rapid-construction-device (RCD)"
	desc = "A device used to rapidly build and deconstruct walls and floors."
	icon = 'icons/obj/items.dmi'
	icon_state = "rcd"
	opacity = 0
	density = 0
	anchored = 0.0
	flags = CONDUCT
	force = 10.0
	throwforce = 10.0
	throw_speed = 3
	throw_range = 5
	w_class = 3.0
	m_amt = 100000
	origin_tech = "engineering=4;materials=2"
	var/datum/effect/effect/system/spark_spread/spark_system
	var/matter = 0
	var/max_matter = 160
	var/working = 0
	var/mode = 1
	var/canRwall = 0
	var/disabled = 0
	var/airlock_type = /obj/machinery/door/airlock
	var/advanced_airlock_setting = 1 //Set to 1 if you want more paintjobs available
	var/sheetmultiplier	= 4			 //Controls the amount of matter added for each glass/metal sheet, triple for plasteel

	var/list/conf_access = null
	var/use_one_access = 0 //If the airlock should require ALL or only ONE of the listed accesses.
	var/last_configurator = null
	var/locked = 1

/obj/item/weapon/rcd/verb/change_airlock_access()
	set name = "Change Airlock Access"
	set category = "Object"
	set src in usr

	if (!ishuman(usr))
		return ..(usr)

	var/mob/living/carbon/human/H = usr
	if(H.getBrainLoss() >= 60)
		return

	var/t1 = text("")


	if (last_configurator)
		t1 += "Operator: [last_configurator]<br>"

	if (locked)
		t1 += "<a href='?src=\ref[src];login=1'>Swipe ID</a><hr>"
	else
		t1 += "<a href='?src=\ref[src];logout=1'>Lock Interface</a><hr>"

		if(use_one_access)
			t1 += "Restriction Type: <a href='?src=\ref[src];access=one'>At least one access required</a><br>"
		else
			t1 += "Restriction Type: <a href='?src=\ref[src];access=one'>All accesses required</a><br>"

		t1 += "<a href='?src=\ref[src];access=all'>Remove All</a><br>"

		var/accesses = ""
		accesses += "<div align='center'><b>Access</b></div>"
		accesses += "<table style='width:100%'>"
		accesses += "<tr>"
		for(var/i = 1; i <= 7; i++)
			accesses += "<td style='width:14%'><b>[get_region_accesses_name(i)]:</b></td>"
		accesses += "</tr><tr>"
		for(var/i = 1; i <= 7; i++)
			accesses += "<td style='width:14%' valign='top'>"
			for(var/A in get_region_accesses(i))
				if(A in conf_access)
					accesses += "<a href='?src=\ref[src];access=[A]'><font color=\"red\">[replacetext(get_access_desc(A), " ", "&nbsp")]</font></a> "
				else
					accesses += "<a href='?src=\ref[src];access=[A]'>[replacetext(get_access_desc(A), " ", "&nbsp")]</a> "
				accesses += "<br>"
			accesses += "</td>"
		accesses += "</tr></table>"
		t1 += "<tt>[accesses]</tt>"

	t1 += text("<p><a href='?src=\ref[];close=1'>Close</a></p>\n", src)

	var/datum/browser/popup = new(usr, "airlock_electronics", "Access Control", 900, 500)
	popup.set_content(t1)
	popup.set_title_image(usr.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	onclose(usr, "airlock")

/obj/item/weapon/rcd/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained() || !ishuman(usr))
		return
	if (href_list["close"])
		usr << browse(null, "window=airlock")
		return

	if (href_list["login"])
		var/obj/item/I = usr.get_active_hand()
		if (istype(I, /obj/item/device/pda))
			var/obj/item/device/pda/pda = I
			I = pda.id
		if (I && src.check_access(I))
			src.locked = 0
			src.last_configurator = I:registered_name

	if (locked)
		return

	if (href_list["logout"])
		locked = 1

	if (href_list["access"])
		toggle_access(href_list["access"])

	change_airlock_access()

/obj/item/weapon/rcd/proc/toggle_access(var/acc)
	if (acc == "all")
		conf_access = null
	else if(acc == "one")
		use_one_access = !use_one_access
	else
		var/req = text2num(acc)

		if (conf_access == null)
			conf_access = list()

		if (!(req in conf_access))
			conf_access += req
		else
			conf_access -= req
			if (!conf_access.len)
				conf_access = null

/obj/item/weapon/rcd/verb/change_airlock_setting()
	set name = "Change Airlock Setting"
	set category = "Object"
	set src in usr

	var airlockcat = input(usr, "Select whether the airlock is solid or glass.") in list("Solid", "Glass")
	switch(airlockcat)
		if("Solid")
			if(advanced_airlock_setting == 1)
				var airlockpaint = input(usr, "Select the paintjob of the airlock.") in list("Default", "Engineering", "Atmospherics", "Security", "Command", "Medical", "Research", "Mining", "Maintenance", "External", "High Security")
				switch(airlockpaint)
					if("Default")
						airlock_type = /obj/machinery/door/airlock
					if("Engineering")
						airlock_type = /obj/machinery/door/airlock/engineering
					if("Atmospherics")
						airlock_type = /obj/machinery/door/airlock/atmos
					if("Security")
						airlock_type = /obj/machinery/door/airlock/security
					if("Command")
						airlock_type = /obj/machinery/door/airlock/command
					if("Medical")
						airlock_type = /obj/machinery/door/airlock/medical
					if("Research")
						airlock_type = /obj/machinery/door/airlock/research
					if("Mining")
						airlock_type = /obj/machinery/door/airlock/mining
					if("Maintenance")
						airlock_type = /obj/machinery/door/airlock/maintenance
					if("External")
						airlock_type = /obj/machinery/door/airlock/external
					if("High Security")
						airlock_type = /obj/machinery/door/airlock/highsecurity
			else
				airlock_type = /obj/machinery/door/airlock

		if("Glass")
			if(advanced_airlock_setting == 1)
				var airlockpaint = input(usr, "Select the paintjob of the airlock.") in list("Default", "Engineering", "Atmospherics", "Security", "Command", "Medical", "Research", "Mining")
				switch(airlockpaint)
					if("Default")
						airlock_type = /obj/machinery/door/airlock/glass
					if("Engineering")
						airlock_type = /obj/machinery/door/airlock/glass_engineering
					if("Atmospherics")
						airlock_type = /obj/machinery/door/airlock/glass_atmos
					if("Security")
						airlock_type = /obj/machinery/door/airlock/glass_security
					if("Command")
						airlock_type = /obj/machinery/door/airlock/glass_command
					if("Medical")
						airlock_type = /obj/machinery/door/airlock/glass_medical
					if("Research")
						airlock_type = /obj/machinery/door/airlock/glass_research
					if("Mining")
						airlock_type = /obj/machinery/door/airlock/glass_mining
			else
				airlock_type = /obj/machinery/door/airlock/glass
		else
			airlock_type = /obj/machinery/door/airlock


/obj/item/weapon/rcd/New()
	desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
	src.spark_system = new /datum/effect/effect/system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	return


/obj/item/weapon/rcd/Destroy()
	qdel(spark_system)
	spark_system = null
	return ..()

/obj/item/weapon/rcd/attackby(obj/item/weapon/W, mob/user, params)
	..()
	if(isrobot(user))	//Make sure cyborgs can't load their RCDs
		return
	var/loaded = 0
	if(istype(W, /obj/item/weapon/rcd_ammo))
		var/obj/item/weapon/rcd_ammo/R = W
		if((matter + R.ammoamt) > max_matter)
			user << "<span class='warning'>The RCD can't hold any more matter-units!</span>"
			return
		user.drop_item()
		qdel(W)
		matter += R.ammoamt
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		loaded = 1
	else if(istype(W, /obj/item/stack/sheet/metal) || istype(W, /obj/item/stack/sheet/glass))
		loaded = loadwithsheets(W, sheetmultiplier, user)
	else if(istype(W, /obj/item/stack/sheet/plasteel))
		loaded = loadwithsheets(W, 3*sheetmultiplier, user) //Plasteel is worth 3 times more than glass or metal
	if(loaded)
		user << "<span class='notice'>The RCD now holds [matter]/[max_matter] matter-units.</span>"
		desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
	return

/obj/item/weapon/rcd/proc/loadwithsheets(obj/item/stack/sheet/S, var/value, mob/user)
    var/maxsheets = round((max_matter-matter)/value)    //calculate the max number of sheets that will fit in RCD
    if(maxsheets > 0)
        if(S.amount > maxsheets)
            //S.amount -= maxsheets
            S.use(maxsheets)
            matter += value*maxsheets
            playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
            user << "<span class='notice'>You insert [maxsheets] [S.name] sheets into the RCD. </span>"
        else
            matter += value*(S.amount)
            playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
            user << "<span class='notice'>You insert [S.amount] [S.name] sheets into the RCD. </span>"
            user.unEquip()
            qdel(S)
        return 1
    user << "<span class='warning'>You can't insert any more [S.name] sheets into the RCD!"
    return 0

/obj/item/weapon/rcd/attack_self(mob/user)
	//Change the mode
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
	switch(mode)
		if(1)
			mode = 2
			user << "<span class='notice'>You change RCD's mode to 'Airlock'.</span>"
		if(2)
			mode = 3
			user << "<span class='notice'>You change RCD's mode to 'Deconstruct'.</span>"
		if(3)
			mode = 4
			user << "<span class='notice'>You change RCD's mode to 'Grilles & Windows'.</span>"
		if(4)
			mode = 1
			user << "<span class='notice'>You change RCD's mode to 'Floor & Walls'.</span>"

	if(prob(20))
		src.spark_system.start()
	return

/obj/item/weapon/rcd/proc/activate()
	playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)


/obj/item/weapon/rcd/afterattack(atom/A, mob/user, proximity)
	if(!proximity) return 0
	if(disabled && !isrobot(user))
		return 0
	if(istype(A,/area/shuttle)||istype(A,/turf/space/transit))
		return 0
	if(!(istype(A, /turf) || istype(A, /obj/machinery/door/airlock) || istype(A, /obj/structure/grille) || istype(A, /obj/structure/window)))
		return 0

	switch(mode)
		if(1)
			if(istype(A, /turf/space))
				var/turf/space/S = A
				if(useResource(1, user))
					user << "<span class='notice'>You start building floor...</span>"
					activate()
					S.ChangeTurf(/turf/simulated/floor/plating)
					return 1
				return 0

			if(istype(A, /turf/simulated/floor))
				var/turf/simulated/floor/F = A
				if(checkResource(3, user))
					user << "<span class='notice'>You start building wall...</span>"
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, 20))
						if(!useResource(3, user)) return 0
						activate()
						F.ChangeTurf(/turf/simulated/wall)
						return 1
				return 0

		if(2)
			if(istype(A, /turf/simulated/floor))
				if(checkResource(10, user))
					var/door_check = 1
					for(var/obj/machinery/door/D in A)
						if(!D.sub_door)
							door_check = 0
							break

					if(door_check)
						if (!conf_access)
							user << "<span class='warning'>Configure access first!</span>"
							return 0
						user << "<span class='notice'>You start building airlock...</span>"
						playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
						if(do_after(user, 50))
							if(!useResource(10, user)) return 0
							activate()
							var/obj/machinery/door/airlock/T = new airlock_type( A )

							T.electronics = new/obj/item/weapon/airlock_electronics( src.loc )

							T.electronics.conf_access = conf_access.Copy()
							T.electronics.use_one_access = use_one_access
							T.electronics.last_configurator = last_configurator
							T.electronics.locked = locked

							if(T.electronics.use_one_access)
								T.req_one_access = T.electronics.conf_access
							else
								T.req_access = T.electronics.conf_access

							if(!T.checkForMultipleDoors())
								qdel(T)
								useResource(-10, user)
								return 0
							T.autoclose = 1
							return 1
						return 0
					else
						user << "<span class='warning'>There is another door here!</span>"
						return 0
				return 0

		if(3)
			if(istype(A, /turf/simulated/wall))
				var/turf/simulated/wall/W = A
				if(istype(W, /turf/simulated/wall/r_wall) && !canRwall)
					return 0
				if(checkResource(5, user))
					user << "<span class='notice'>You start deconstructing wall...</span>"
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, 40))
						if(!useResource(5, user)) return 0
						activate()
						W.ChangeTurf(/turf/simulated/floor/plating)
						return 1
				return 0

			if(istype(A, /turf/simulated/floor))
				var/turf/simulated/floor/F = A
				if(istype(F, F.baseturf))
					user << "<span class='notice'>You can't dig any deeper!</span>"
					return 0
				else if(checkResource(5, user))
					user << "<span class='notice'>You start deconstructing floor...</span>"
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, 50))
						if(!useResource(5, user)) return 0
						activate()
						F.ChangeTurf(F.baseturf)
						return 1
				return 0

			if(istype(A, /obj/machinery/door/airlock))
				if(checkResource(20, user))
					user << "<span class='notice'>You start deconstructing airlock...</span>"
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, 50))
						if(!useResource(20, user)) return 0
						activate()
						qdel(A)
						return 1
				return	0

			if(istype(A, /obj/structure/window))
				if(checkResource(5, user))
					user << "<span class='notice'>You start deconstructing the window...</span>"
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, 50))
						if(!useResource(5, user)) return 0
						activate()
						qdel(A)
						return 1
				return	0

			if(istype(A, /obj/structure/grille))
				if(checkResource(5, user))
					user << "<span class='notice'>You start deconstructing the grille...</span>"
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, 50))
						if(!useResource(5, user)) return 0
						activate()
						qdel(A)
						return 1
				return	0
			return 0

		if (4)
			if(istype(A, /turf/simulated/floor))
				if(checkResource(5, user))
					for(var/obj/structure/grille/GRILLE in A)
						user << "<span class='warning'>There is already a grille there!</span>"
						return 0
					user << "<span class='notice'>You start building a grille...</span>"
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, 40))
						if(!useResource(5, user)) return 0
						activate()
						var/obj/structure/grille/G = new/obj/structure/grille(A)
						G.anchored = 1
						return 1
					return 0
				return 0
			if(istype(A, /obj/structure/grille))
				if(checkResource(5, user))
					user << "<span class='notice'>You start building a window...</span>"
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, 40))
						if(!useResource(5, user)) return 0
						activate()
						var/obj/structure/window/WD = new/obj/structure/window/fulltile(A.loc)
						WD.anchored = 1
						return 1
					return 0
				return 0

		else
			user << "ERROR: RCD in MODE: [mode] attempted use by [user]. Send this text #coderbus or an admin."
			return 0

/obj/item/weapon/rcd/proc/useResource(var/amount, var/mob/user)
	if(matter < amount)
		return 0
	matter -= amount
	desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
	return 1

/obj/item/weapon/rcd/proc/checkResource(var/amount, var/mob/user)
	return matter >= amount
/obj/item/weapon/rcd/borg/useResource(var/amount, var/mob/user)
	if(!isrobot(user))
		return 0
	return user:cell:use(amount * 160)

/obj/item/weapon/rcd/borg/checkResource(var/amount, var/mob/user)
	if(!isrobot(user))
		return 0
	return user:cell:charge >= (amount * 160)

/obj/item/weapon/rcd/borg/New()
	..()
	advanced_airlock_setting = 0 //Borgs can't set the access levels, so they only get the defaults!
	desc = "A device used to rapidly build walls/floor."
	canRwall = 1

/obj/item/weapon/rcd/loaded
	matter = 160

/obj/item/weapon/rcd/combat
	name = "combat RCD"
	max_matter = 500
	matter = 500
	canRwall = 1

/obj/item/weapon/rcd_ammo
	name = "compressed matter cartridge"
	desc = "Highly compressed matter for the RCD."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "rcd"
	item_state = "rcdammo"
	opacity = 0
	density = 0
	anchored = 0.0
	origin_tech = "materials=2"
	m_amt = 16000
	g_amt = 8000
	var/ammoamt = 20

/obj/item/weapon/rcd_ammo/large
	ammoamt = 100