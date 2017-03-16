

/*
CONTAINS:
RCD
ARCD
*/
/obj/item/weapon/rcd
	name = "rapid-construction-device (RCD)"
	desc = "A device used to rapidly build and deconstruct walls and floors."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd"
	opacity = 0
	density = 0
	anchored = 0
	flags = CONDUCT | NOBLUDGEON
	force = 0
	throwforce = 10
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL=100000)
	origin_tech = "engineering=4;materials=2"
	req_access_txt = "11"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF
	var/datum/effect_system/spark_spread/spark_system
	var/matter = 0
	var/max_matter = 160
	var/working = 0
	var/mode = 1
	var/canRturf = 0
	var/airlock_type = /obj/machinery/door/airlock
	var/window_type = /obj/structure/window/fulltile

	var/advanced_airlock_setting = 1 //Set to 1 if you want more paintjobs available
	var/sheetmultiplier	= 4			 //Controls the amount of matter added for each glass/metal sheet, triple for plasteel
	var/plasteelmultiplier = 3 //Plasteel is worth 3 times more than glass or metal

	var/list/conf_access = null
	var/use_one_access = 0 //If the airlock should require ALL or only ONE of the listed accesses.

	/* Construction costs */

	var/wallcost = 16
	var/floorcost = 2
	var/grillecost = 4
	var/girderupgradecost = 8
	var/windowcost = 8
	var/reinforcedwindowcost = 12
	var/airlockcost = 16
	var/decongirdercost = 13
	var/deconwallcost = 26
	var/deconfloorcost = 33
	var/decongrillecost = 4
	var/deconwindowcost = 8
	var/deconairlockcost = 32

	/* Build delays (deciseconds) */

	var/walldelay = 20
	var/floordelay = null //space wind's a bitch
	var/grilledelay = 40
	var/windowdelay = 40
	var/airlockdelay = 50
	var/decongirderdelay = 20
	var/deconwalldelay = 40
	var/deconfloordelay = 50
	var/decongrilledelay = null //as rapid as wirecutters
	var/deconwindowdelay = 50
	var/deconairlockdelay = 50

	var/no_ammo_message = "<span class='warning'>The \'Low Ammo\' light on \
		the RCD blinks yellow.</span>"

/obj/item/weapon/rcd/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] sets the RCD to 'Wall' and points it down [user.p_their()] throat! It looks like [user.p_theyre()] trying to commit suicide..</span>")
	return (BRUTELOSS)

/obj/item/weapon/rcd/verb/toggle_window_type()
	set name = "Toggle Window Type"
	set category = "Object"
	set src in usr // What does this do?

	var window_type_name

	if (window_type == /obj/structure/window/fulltile)
		window_type = /obj/structure/window/reinforced/fulltile
		window_type_name = "reinforced glass"
	else
		window_type = /obj/structure/window/fulltile
		window_type_name = "glass"

	to_chat(usr, "<span class='notice'>You change \the [src]'s window mode to [window_type_name].</span>")

/obj/item/weapon/rcd/verb/change_airlock_access()
	set name = "Change Airlock Access"
	set category = "Object"
	set src in usr

	if (!ishuman(usr) && !usr.has_unlimited_silicon_privilege)
		return ..(usr)

	var/mob/living/carbon/human/H = usr
	if(H.getBrainLoss() >= 60)
		return

	var/t1 = text("")



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
	if (usr.stat || usr.restrained())
		return
	if (href_list["close"])
		usr << browse(null, "window=airlock")
		return

	if (href_list["access"])
		toggle_access(href_list["access"])

	change_airlock_access()

/obj/item/weapon/rcd/proc/toggle_access(acc)
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

	airlockcost = initial(airlockcost)
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
						airlockcost += 2 * sheetmultiplier	//extra cost
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
	..()

	desc = "An RCD. It currently holds [matter]/[max_matter] matter-units."
	src.spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	rcd_list += src


/obj/item/weapon/rcd/Destroy()
	qdel(spark_system)
	spark_system = null
	rcd_list -= src
	. = ..()

/obj/item/weapon/rcd/attackby(obj/item/weapon/W, mob/user, params)
	if(iscyborg(user))	//Make sure cyborgs can't load their RCDs
		return
	var/loaded = 0
	if(istype(W, /obj/item/weapon/rcd_ammo))
		var/obj/item/weapon/rcd_ammo/R = W
		if((matter + R.ammoamt) > max_matter)
			to_chat(user, "<span class='warning'>The RCD can't hold any more matter-units!</span>")
			return
		qdel(W)
		matter += R.ammoamt
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		loaded = 1
	else if(istype(W, /obj/item/stack/sheet/metal) || istype(W, /obj/item/stack/sheet/glass))
		loaded = loadwithsheets(W, sheetmultiplier, user)
	else if(istype(W, /obj/item/stack/sheet/plasteel))
		loaded = loadwithsheets(W, plasteelmultiplier*sheetmultiplier, user) //Plasteel is worth 3 times more than glass or metal
	if(loaded)
		to_chat(user, "<span class='notice'>The RCD now holds [matter]/[max_matter] matter-units.</span>")
		desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
	else
		return ..()

/obj/item/weapon/rcd/proc/loadwithsheets(obj/item/stack/sheet/S, value, mob/user)
	var/maxsheets = round((max_matter-matter)/value)    //calculate the max number of sheets that will fit in RCD
	if(maxsheets > 0)
		var/amount_to_use = min(S.amount, maxsheets)
		S.use(amount_to_use)
		matter += value*amount_to_use
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		to_chat(user, "<span class='notice'>You insert [amount_to_use] [S.name] sheets into the RCD. </span>")
		return 1
	to_chat(user, "<span class='warning'>You can't insert any more [S.name] sheets into the RCD!")
	return 0

/obj/item/weapon/rcd/attack_self(mob/user)
	//Change the mode
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
	switch(mode)
		if(1)
			mode = 2
			to_chat(user, "<span class='notice'>You change RCD's mode to 'Airlock'.</span>")
		if(2)
			mode = 3
			to_chat(user, "<span class='notice'>You change RCD's mode to 'Deconstruct'.</span>")
		if(3)
			mode = 4
			to_chat(user, "<span class='notice'>You change RCD's mode to 'Grilles & Windows'.</span>")
		if(4)
			mode = 1
			to_chat(user, "<span class='notice'>You change RCD's mode to 'Floor & Walls'.</span>")

	if(prob(20))
		src.spark_system.start()

/obj/item/weapon/rcd/proc/activate()
	playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)


/obj/item/weapon/rcd/afterattack(atom/A, mob/user, proximity)
	if(!proximity) return 0
	if(istype(A,/turf/open/space/transit))
		return 0
	if(!(isturf(A) || istype(A, /obj/machinery/door/airlock) || istype(A, /obj/structure/grille) || istype(A, /obj/structure/window) || istype(A, /obj/structure/girder)))
		return 0

	switch(mode)
		if(1)
			if(isspaceturf(A))
				var/turf/open/space/S = A
				if(useResource(floorcost, user))
					to_chat(user, "<span class='notice'>You start building a floor...</span>")
					activate()
					S.ChangeTurf(/turf/open/floor/plating)
					return 1
				return 0

			if(isfloorturf(A))
				var/turf/open/floor/F = A
				if(checkResource(wallcost, user))
					to_chat(user, "<span class='notice'>You start building a wall...</span>")
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, walldelay, target = A))
						if(!istype(F)) return 0
						if(!useResource(wallcost, user)) return 0
						activate()
						F.ChangeTurf(/turf/closed/wall)
						return 1
				return 0

			if(istype(A, /obj/structure/girder))
				var/turf/open/floor/F = get_turf(A)
				if(checkResource(girderupgradecost, user))
					to_chat(user, "<span class='notice'>You start finishing the wall...</span>")
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, walldelay, target = A))
						if(!istype(A)) return 0
						if(!useResource(girderupgradecost, user)) return 0
						activate()
						qdel(A)
						F.ChangeTurf(/turf/closed/wall)
						return 1
				return 0

		if(2)
			if(isfloorturf(A))
				if(checkResource(airlockcost, user))
					var/door_check = 1
					for(var/obj/machinery/door/D in A)
						if(!D.sub_door)
							door_check = 0
							break

					if(door_check)
						to_chat(user, "<span class='notice'>You start building an airlock...</span>")
						playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
						if(do_after(user, airlockdelay, target = A))
							if(!useResource(airlockcost, user)) return 0
							activate()
							var/obj/machinery/door/airlock/T = new airlock_type( A )

							T.electronics = new/obj/item/weapon/electronics/airlock( src.loc )

							if(conf_access)
								T.electronics.accesses = conf_access.Copy()
							T.electronics.one_access = use_one_access

							if(T.electronics.one_access)
								T.req_one_access = T.electronics.accesses
							else
								T.req_access = T.electronics.accesses

							if(!T.checkForMultipleDoors())
								qdel(T)
								useResource(-airlockcost, user)
								return 0
							T.autoclose = 1
							return 1
						return 0
					else
						to_chat(user, "<span class='warning'>There is another door here!</span>")
						return 0
				return 0

		if(3)
			if(iswallturf(A))
				var/turf/closed/wall/W = A
				if(istype(W, /turf/closed/wall/r_wall) && !canRturf)
					return 0
				if(checkResource(deconwallcost, user))
					to_chat(user, "<span class='notice'>You start deconstructing [W]...</span>")
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, deconwalldelay, target = A))
						if(!useResource(deconwallcost, user)) return 0
						activate()
						W.ChangeTurf(/turf/open/floor/plating)
						return 1
				return 0

			if(isfloorturf(A))
				var/turf/open/floor/F = A
				if(istype(F, /turf/open/floor/engine) && !canRturf)
					return 0
				if(istype(F, F.baseturf))
					to_chat(user, "<span class='notice'>You can't dig any deeper!</span>")
					return 0
				else if(checkResource(deconfloorcost, user))
					to_chat(user, "<span class='notice'>You start deconstructing floor...</span>")
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, deconfloordelay, target = A))
						if(!useResource(deconfloorcost, user)) return 0
						activate()
						F.ChangeTurf(F.baseturf)
						return 1
				return 0

			if(istype(A, /obj/machinery/door/airlock))
				if(checkResource(deconairlockcost, user))
					to_chat(user, "<span class='notice'>You start deconstructing airlock...</span>")
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, deconairlockdelay, target = A))
						if(!useResource(deconairlockcost, user)) return 0
						activate()
						qdel(A)
						return 1
				return	0

			if(istype(A, /obj/structure/window))
				if(checkResource(deconwindowcost, user))
					to_chat(user, "<span class='notice'>You start deconstructing the window...</span>")
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, deconwindowdelay, target = A))
						if(!useResource(deconwindowcost, user)) return 0
						activate()
						qdel(A)
						return 1
				return	0

			if(istype(A, /obj/structure/grille))
				var/obj/structure/grille/G = A
				if(!G.shock(user, 90)) //if it's shocked, try to shock them
					if(useResource(decongrillecost, user))
						to_chat(user, "<span class='notice'>You start deconstructing the grille...</span>")
						activate()
						playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
						qdel(A)
						return 1
					return 0

			if(istype(A, /obj/structure/girder))
				if(useResource(decongirdercost, user))
					to_chat(user, "<span class='notice'>You start deconstructing [A]...</span>")
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, decongirderdelay, target = A))
						if(!useResource(decongirdercost, user)) return 0
						activate()
						qdel(A)
						return 1

		if (4)
			if(isfloorturf(A))
				if(checkResource(grillecost, user))
					if(locate(/obj/structure/grille) in A)
						to_chat(user, "<span class='warning'>There is already a grille there!</span>")
						return 0
					to_chat(user, "<span class='notice'>You start building a grille...</span>")
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, grilledelay, target = A))
						if(locate(/obj/structure/grille) in A)
							return 0
						if(!useResource(grillecost, user)) return 0
						activate()
						var/obj/structure/grille/G = new/obj/structure/grille(A)
						G.anchored = 1
						return 1
					return 0
				return 0
			if(istype(A, /obj/structure/grille))
				var wname = "window?"
				var cost = 0
				if (window_type == /obj/structure/window/fulltile)
					cost = windowcost
					wname = "window"
				else if (window_type == /obj/structure/window/reinforced/fulltile)
					cost = reinforcedwindowcost
					wname = "reinforced window"

				if(checkResource(cost, user))
					to_chat(user, "<span class='notice'>You start building a [wname]...</span>")
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, windowdelay, target = A))
						if(locate(/obj/structure/window) in A.loc) return 0
						if(!useResource(cost, user)) return 0
						activate()
						var /obj/structure/window/WD = new window_type(A.loc)
						WD.anchored = 1
						return 1
					return 0
				return 0

		else
			to_chat(user, "ERROR: RCD in MODE: [mode] attempted use by [user]. Send this text #coderbus or an admin.")
			return 0

/obj/item/weapon/rcd/proc/useResource(amount, mob/user)
	if(matter < amount)
		if(user)
			to_chat(user, no_ammo_message)
		return 0
	matter -= amount
	desc = "An RCD. It currently holds [matter]/[max_matter] matter-units."
	return 1

/obj/item/weapon/rcd/proc/checkResource(amount, mob/user)
	. = matter >= amount
	if(!. && user)
		to_chat(user, no_ammo_message)
	return .

/obj/item/weapon/rcd/proc/detonate_pulse()
	audible_message("<span class='danger'><b>[src] begins to vibrate and \
		buzz loudly!</b></span>","<span class='danger'><b>[src] begins \
		vibrating violently!</b></span>")
	// 5 seconds to get rid of it
	addtimer(CALLBACK(src, .proc/detonate_pulse_explode), 50)

/obj/item/weapon/rcd/proc/detonate_pulse_explode()
	explosion(src, 0, 0, 3, 1, flame_range = 1)
	qdel(src)


/obj/item/weapon/rcd/borg/New()
	..()
	no_ammo_message = "<span class='warning'>Insufficient charge.</span>"
	desc = "A device used to rapidly build walls and floors."
	canRturf = 1

/obj/item/weapon/rcd/borg/useResource(amount, mob/user)
	if(!iscyborg(user))
		return 0
	var/mob/living/silicon/robot/borgy = user
	if(!borgy.cell)
		if(user)
			to_chat(user, no_ammo_message)
		return 0
	. = borgy.cell.use(amount * 72) //borgs get 1.3x the use of their RCDs
	if(!. && user)
		to_chat(user, no_ammo_message)
	return .

/obj/item/weapon/rcd/borg/checkResource(amount, mob/user)
	if(!iscyborg(user))
		return 0
	var/mob/living/silicon/robot/borgy = user
	if(!borgy.cell)
		if(user)
			to_chat(user, no_ammo_message)
		return 0
	. = borgy.cell.charge >= (amount * 72)
	if(!. && user)
		to_chat(user, no_ammo_message)
	return .

/obj/item/weapon/rcd/loaded
	matter = 160

/obj/item/weapon/rcd/combat
	name = "industrial RCD"
	max_matter = 500
	matter = 500
	canRturf = 1

/obj/item/weapon/rcd_ammo
	name = "compressed matter cartridge"
	desc = "Highly compressed matter for the RCD."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "rcd"
	item_state = "rcdammo"
	origin_tech = "materials=3"
	materials = list(MAT_METAL=12000, MAT_GLASS=8000)
	var/ammoamt = 40

/obj/item/weapon/rcd_ammo/large
	origin_tech = "materials=4"
	materials = list(MAT_METAL=48000, MAT_GLASS=32000)
	ammoamt = 160

/obj/item/weapon/rcd/arcd
	name = "advanced rapid-construction-device (ARCD)"
	max_matter = 300
	matter = 300
	color = "red"

	/* Build delays (deciseconds) */

	walldelay = 10
	grilledelay = 5
	windowdelay = 5
	airlockdelay = 20
	decongirderdelay = 10
	deconwalldelay = 20
	deconfloordelay = 30
	deconwindowdelay = 20
	deconairlockdelay = 20


/obj/item/weapon/rcd/arcd/afterattack(atom/A, mob/user, proximity)
	proximity = 1
	if(!(A in view(7, get_turf(user))))
		to_chat(user, "<span class='warning'>The \'Out of Range\' light on the RCD blinks red.</span>")
		return 0
	if(isturf(A) || istype(A, /obj/machinery/door/airlock) || istype(A, /obj/structure/grille) || istype(A, /obj/structure/window) || istype(A, /obj/structure/girder))
		user.Beam(A,icon_state="rped_upgrade",time=20)
		..()
	else
		return




// RAPID LIGHT GENERATOR






/obj/item/weapon/rld
	name = "rapid-light-device (RLD)"
	desc = "A device used to rapidly provide lighting sources to an area."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rld-5"
	opacity = FALSE
	density = FALSE
	anchored = FALSE
	flags = CONDUCT | NOBLUDGEON
	force = 0
	throwforce = 10
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL=100000)
	origin_tech = "engineering=4;materials=2"
	req_access_txt = "11"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF
	var/datum/effect_system/spark_spread/spark_system
	var/matter = 200
	var/max_matter = 200
	var/working = 0
	var/mode = 1
	actions_types = list(/datum/action/item_action/pick_color)

	var/wallcost = 10
	var/floorcost = 15
	var/launchcost = 5
	var/deconcost = 10

	var/walldelay = 10
	var/floordelay = 10
	var/decondelay = 15

	var/sheetmultiplier	= 4

	var/color_choice = null

	var/no_ammo_message = "<span class='warning'>The \'Low Ammo\' light on \
		the RLD blinks yellow.</span>"

/obj/item/weapon/rld/ui_action_click(mob/user, var/datum/action/A)
	if(istype(A, /datum/action/item_action/pick_color))
		choose_color()
	else
		..()

/obj/item/weapon/rld/proc/choose_color()
	set name = "Choose Light Color"
	set category = "Object"
	color_choice = input(usr,"Choose Color") as color


/obj/item/weapon/rld/New()
	..()

	desc = "An RLD. It currently holds [matter]/[max_matter] matter-units."
	src.spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)


/obj/item/weapon/rld/Destroy()
	qdel(spark_system)
	spark_system = null
	. = ..()

/obj/item/weapon/rld/attackby(obj/item/weapon/W, mob/user, params)
	var/loaded = 0
	if(istype(W, /obj/item/weapon/rcd_ammo))
		var/obj/item/weapon/rcd_ammo/R = W
		if((matter + R.ammoamt) > max_matter)
			to_chat(user, "<span class='warning'>The RLD can't hold any more matter-units!</span>")
			return
		qdel(W)
		matter += R.ammoamt
		icon_state = "rld-[round(matter/35)]"
		update_icon()
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		loaded = 1
	else if(istype(W, /obj/item/stack/sheet/glass))
		loaded = loadwithsheets(W, sheetmultiplier, user)
	if(loaded)
		to_chat(user, "<span class='notice'>The RLD now holds [matter]/[max_matter] matter-units.</span>")
		desc = "An RLD. It currently holds [matter]/[max_matter] matter-units."
	else
		return ..()

/obj/item/weapon/rld/proc/loadwithsheets(obj/item/stack/sheet/S, value, mob/user)
	var/maxsheets = round((max_matter-matter)/value)    //calculate the max number of sheets that will fit in RLD
	if(maxsheets > 0)
		var/amount_to_use = min(S.amount, maxsheets)
		S.use(amount_to_use)
		matter += value*amount_to_use
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		to_chat(user, "<span class='notice'>You insert [amount_to_use] [S.name] sheets into the RLD. </span>")
		icon_state = "rld-[round(matter/35)]"
		update_icon()
		return 1
	to_chat(user, "<span class='warning'>You can't insert any more [S.name] sheets into the RLD!")
	return 0

/obj/item/weapon/rld/attack_self(mob/user)
	//Change the mode
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
	switch(mode)
		if(1)
			mode = 2
			to_chat(user, "<span class='notice'>You change RLD's mode to 'Permanent Light Construction'.</span>")
		if(2)
			mode = 3
			to_chat(user, "<span class='notice'>You change RLD's mode to 'Light Launcher'.</span>")
		if(3)
			mode = 1
			to_chat(user, "<span class='notice'>You change RLD's mode to 'Deconstruct'.</span>")
	if(prob(20))
		src.spark_system.start()

/obj/item/weapon/rld/proc/activate(atom/A)
	playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)

/obj/item/weapon/rld/proc/checkdupes(var/target)
	. = list()
	var/turf/checking = get_turf(target)
	for(var/obj/machinery/light/dupe in checking)
		if(istype(dupe, /obj/machinery/light))
			. |= dupe


/obj/item/weapon/rld/afterattack(atom/A, mob/user)
	var/turf/start = get_turf(src)
	if(!(A in view(7, get_turf(start))))
		to_chat(user, "<span class='warning'>The \'Out of Range\' light on the RLD blinks red.</span>")
		return 0
	switch(mode)
		if(1)
			if(istype(A, /obj/machinery/light/))
				if(checkResource(deconcost, user))
					to_chat(user, "<span class='notice'>You start deconstructing [A]...</span>")
					user.Beam(A,icon_state="nzcrentrs_power",time=15)
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, decondelay, target = A))
						if(!useResource(deconcost, user)) return 0
						activate()
						qdel(A)
						return 1
				return 0

		if(2)
			if(iswallturf(A))
				var/turf/closed/wall/W = A
				if(checkResource(floorcost, user))
					to_chat(user, "<span class='notice'>You start building a wall light...</span>")
					user.Beam(A,icon_state="nzcrentrs_power",time=15)
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					playsound(src.loc, 'sound/effects/light_flicker.ogg', 50, 0)
					if(do_after(user, floordelay, target = A))
						if(!istype(W))
							return 0
						var/list/candidates = list()
						var/turf/open/winner = null
						var/winning_dist = null
						for(var/direction in cardinal)
							var/turf/C = get_step(W, direction)
							var/list/dupes = checkdupes(C)
							if(start.CanAtmosPass(C) && !dupes.len)
								candidates += C
						if(!candidates.len)
							to_chat(user, "<span class='warning'>Valid target not found...</span>")
							user << 'sound/misc/compiler-failure.ogg'
							return 0
						for(var/turf/open/O in candidates)
							if(istype(O))
								var/x0 = O.x
								var/y0 = O.y
								var/contender = cheap_hypotenuse(start.x, start.y, x0, y0)
								if(!winner)
									winner = O
									winning_dist = contender
								else
									if(contender < winning_dist) // lower is better
										winner = O
										winning_dist = contender
						activate()
						if(!useResource(wallcost, user))
							return 0
						var/light = get_turf(winner)
						var/align = get_dir(winner, A)
						var/obj/machinery/light/L = new /obj/machinery/light(light)
						L.dir = align
						L.color = color_choice
						L.light_color = L.color
						return 1

				return 0

			if(isfloorturf(A))
				var/turf/open/floor/F = A
				if(checkResource(floorcost, user))
					to_chat(user, "<span class='notice'>You start building a floor light...</span>")
					user.Beam(A,icon_state="nzcrentrs_power",time=15)
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					playsound(src.loc, 'sound/effects/light_flicker.ogg', 50, 1)
					if(do_after(user, floordelay, target = A))
						if(!istype(F)) return 0
						if(!useResource(floorcost, user)) return 0
						activate()
						var/destination = get_turf(A)
						var/obj/machinery/light/floor/FL = new /obj/machinery/light/floor(destination)
						FL.color = color_choice
						FL.light_color = FL.color
						return 1

				return 0

		if(3)
			if(useResource(launchcost, user))
				activate()
				to_chat(user, "<span class='notice'>You fire a glowstick!</span>")
				var/obj/item/device/flashlight/glowstick/G  = new /obj/item/device/flashlight/glowstick(start)
				G.color = color_choice
				G.light_color = G.color
				G.throw_at(A, 9, 3, user)
				G.activate()
				G.update_brightness()
				return 1
			return 0



/obj/item/weapon/rld/proc/useResource(amount, mob/user)
	if(matter < amount)
		if(user)
			to_chat(user, no_ammo_message)
			user << 'sound/misc/compiler-failure.ogg'
		return 0
	matter -= amount
	desc = "An RLD. It currently holds [matter]/[max_matter] matter-units."
	icon_state = "rld-[round(matter/35)]"
	update_icon()
	return 1

/obj/item/weapon/rld/proc/checkResource(amount, mob/user)
	. = matter >= amount
	if(!. && user)
		to_chat(user, no_ammo_message)
		user << 'sound/misc/compiler-failure.ogg'
	return .
