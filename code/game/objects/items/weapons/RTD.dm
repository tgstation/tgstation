//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/*
CONTAINS
RAPID TERRAFORMING DEVICE
Only works on lavaland
Transforms lavalandish things into stationish things
Can rapidly collect iron ore to be used as matter.
Holds 400 matter!
EMAGGED FUNCTIONS - TODO
*/
/obj/item/weapon/rtd
	name = "rapid-terraforming device (RTD)"
	desc = "A bulky industrial device based on RCD and compressed matter technology that is designed for rapid terraforming of hostile planetary environments. Has safeguards to not work on station. Automatically synthesizes compressed air to pressurize colonies."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rtd"
	opacity = 0
	density = 0
	anchored = 0
	flags = CONDUCT
	force = 15
	throwforce = 10
	throw_speed = 3
	throw_range = 5
	w_class = 4
	materials = list(MAT_METAL=100000)
	origin_tech = "engineering=5;materials=5"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/datum/effect_system/spark_spread/spark_system
	var/matter = 0
	var/max_matter = 400
	var/gas = 40
	var/maxgas = 40
	var/working = 0
	var/mode = 1
	var/canRturf = 0
	var/airlock_type = /obj/machinery/door/airlock

	var/advanced_airlock_setting = 1
	var/sheetmultiplier	= 8
	var/plasteelmultiplier = 5
	var/ironoreworth = 5
	var/gasamount = 20

	var/list/conf_access = null
	var/use_one_access = 0 //If the airlock should require ALL or only ONE of the listed accesses.

	/*
	Construction costs
	COST| FUNCTION
	10	|Asteroid walls to walls
	5	|Lavaland floors to plating
	5	|Builds catwalks on lava.
	SEPARATE FROM OTHERS - Blasts compressed air to pressurize areas
	25	|Builds airlocks with higher health than normal airlocks, but the same security level.
	15	|Catwalks over chasms
	2	|Build membrane barriers - Basically walls that will break in a single hit from just about anything and is best left for emergency usage.
	0	|Remove Catwalks - Just incase antags get ahold of it or you really need a lava disposals bin. Honk.
	*/

	var/wallcost = 10
	var/floorcost = 5
	var/catwalkcost = 5
	var/chasmcatwalkcost = 15
	var/airlockcost = 25
	var/membranecost = 2
	var/removecatwalkcost = 0

	/* Build delays (deciseconds) */

	var/walldelay = 20
	var/floordelay = 10
	var/catwalkdelay = null
	var/chasmcatwalkdelay = null
	var/airlockdelay = 30
	var/membranedelay = 5
	var/removedelay = 40

/obj/item/weapon/rtd/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] sets the RTD to 'Airlock' and points it down [user.p_their()] throat! It looks like [user.p_theyre()] trying to commit suicide..</span>")
	var/obj/machinery/door/airlock/A = new obj/machinery/door/airlock/glass_command(get_turf(src))
	A.maxhealth = 500
	A.health = 500
	A.name = user.name
	return (BRUTELOSS)

/obj/item/weapon/rtd/verb/change_airlock_access()
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

/obj/item/weapon/rtd/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return
	if (href_list["close"])
		usr << browse(null, "window=airlock")
		return

	if (href_list["access"])
		toggle_access(href_list["access"])

	change_airlock_access()

/obj/item/weapon/rtd/proc/toggle_access(acc)
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

/obj/item/weapon/rtd/verb/change_airlock_setting()
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


/obj/item/weapon/rtd/New()
	..()
	src.spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	rcd_list += src

/obj/item/weapon/rtd/examine(mob/user)
	..()
	user << "<span class='boldnotice'>Its matter indicator reads [matter]/[maxmatter] units left.</span>"
	user << "<span class='boldnotice'>Its gas indicator reads [gas]/[maxgas].</span>"

/obj/item/weapon/rtd/Destroy()
	qdel(spark_system)
	spark_system = null
	rcd_list -= src
	. = ..()

/obj/item/weapon/rtd/attackby(obj/item/weapon/W, mob/user, params)
	if(iscyborg(user))	//Make sure cyborgs can't load their rtds
		return
	var/loaded = 0
	if(istype(W, /obj/item/weapon/rcd_ammo))
		var/obj/item/weapon/rcd_ammo/R = W
		if((matter + R.ammoamt) > max_matter)
			user << "<span class='warning'>The RTD can't hold any more matter-units!</span>"
			return
		if(!user.unEquip(W))
			return
		qdel(W)
		matter += R.ammoamt
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		loaded = 1
	else if(istype(W, /obj/item/weapon/ore/iron))
		if((matter + ironoreworth) > max_matter)
			user << "<span class='warning'>The RTD can't hold any more matter-units!</span>"
			return
		if(!user.unEquip(W))
			return
		qdel(W)
		matter += ironoreworth
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		loaded = 1
	else if(istype(W, /obj/item/stack/sheet/metal) || istype(W, /obj/item/stack/sheet/glass))
		loaded = loadwithsheets(W, sheetmultiplier, user)
	else if(istype(W, /obj/item/stack/sheet/plasteel))
		loaded = loadwithsheets(W, plasteelmultiplier*sheetmultiplier, user)
	if(loaded)
		user << "<span class='notice'>The RTD now holds [matter]/[max_matter] matter-units.</span>"
	else
		return ..()

/obj/item/weapon/rtd/proc/loadwithsheets(obj/item/stack/sheet/S, value, mob/user)
    var/maxsheets = round((max_matter-matter)/value)
    if(maxsheets > 0)
        if(S.amount > maxsheets)
            S.use(maxsheets)
			matter += value*maxsheets
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
			user << "<span class='notice'>You insert [maxsheets] [S.name] sheets into the rtd. </span>"
		else
			matter += value*(S.amount)
			user.unEquip()
			S.use(S.amount)
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
			user << "<span class='notice'>You insert [S.amount] [S.name] sheets into the rtd. </span>"
		return 1
	user << "<span class='warning'>You can't insert any more [S.name] sheets into the rtd!"
	return 0

/obj/item/weapon/rtd/attack_self(mob/user)
	//Change the mode
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
	switch(mode)
		if(1)
			mode = 2
			user << "<span class='notice'>You change rtd's mode to 'Airlock'.</span>"
		if(2)
			mode = 3
			user << "<span class='notice'>You change rtd's mode to 'Deconstruct'.</span>"
		if(3)
			mode = 4
			user << "<span class='notice'>You change rtd's mode to 'Grilles & Windows'.</span>"
		if(4)
			mode = 1
			user << "<span class='notice'>You change rtd's mode to 'Floor & Walls'.</span>"

	if(prob(20))
		src.spark_system.start()

/obj/item/weapon/rtd/proc/activate()
	playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)


/obj/item/weapon/rtd/afterattack(atom/A, mob/user, proximity)
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
					user << "<span class='notice'>You start building floor...</span>"
					activate()
					S.ChangeTurf(/turf/open/floor/plating)
					return 1
				return 0

			if(isfloorturf(A))
				var/turf/open/floor/F = A
				if(checkResource(wallcost, user))
					user << "<span class='notice'>You start building wall...</span>"
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
					user << "<span class='notice'>You start finishing the \
						wall...</span>"
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
						user << "<span class='notice'>You start building airlock...</span>"
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
						user << "<span class='warning'>There is another door here!</span>"
						return 0
				return 0

		if(3)
			if(iswallturf(A))
				var/turf/closed/wall/W = A
				if(istype(W, /turf/closed/wall/r_wall) && !canRturf)
					return 0
				if(checkResource(deconwallcost, user))
					user << "<span class='notice'>You start deconstructing [W]...</span>"
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
					user << "<span class='notice'>You can't dig any deeper!</span>"
					return 0
				else if(checkResource(deconfloorcost, user))
					user << "<span class='notice'>You start deconstructing floor...</span>"
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, deconfloordelay, target = A))
						if(!useResource(deconfloorcost, user)) return 0
						activate()
						F.ChangeTurf(F.baseturf)
						return 1
				return 0

			if(istype(A, /obj/machinery/door/airlock))
				if(checkResource(deconairlockcost, user))
					user << "<span class='notice'>You start deconstructing airlock...</span>"
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, deconairlockdelay, target = A))
						if(!useResource(deconairlockcost, user)) return 0
						activate()
						qdel(A)
						return 1
				return	0

			if(istype(A, /obj/structure/window))
				if(checkResource(deconwindowcost, user))
					user << "<span class='notice'>You start deconstructing the window...</span>"
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
						user << "<span class='notice'>You start deconstructing the grille...</span>"
						activate()
						playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
						qdel(A)
						return 1
					return 0

			if(istype(A, /obj/structure/girder))
				if(useResource(decongirdercost, user))
					user << "<span class='notice'>You start deconstructing \
						[A]...</span>"
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
						user << "<span class='warning'>There is already a grille there!</span>"
						return 0
					user << "<span class='notice'>You start building a grille...</span>"
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
					user << "<span class='notice'>You start building a \
						[wname]...</span>"
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
			user << "ERROR: rtd in MODE: [mode] attempted use by [user]. Send this text #coderbus or an admin."
			return 0

/obj/item/weapon/rtd/proc/useResource(amount, mob/user)
	if(matter < amount)
		if(user)
			user << no_ammo_message
		return 0
	matter -= amount
	desc = "An rtd. It currently holds [matter]/[max_matter] matter-units."
	return 1

/obj/item/weapon/rtd/proc/checkResource(amount, mob/user)
	. = matter >= amount
	if(!. && user)
		user << no_ammo_message
	return .

/obj/item/weapon/rtd/proc/detonate_pulse()
	audible_message("<span class='danger'><b>[src] begins to vibrate and \
		buzz loudly!</b></span>","<span class='danger'><b>[src] begins \
		vibrating violently!</b></span>")
	// 5 seconds to get rid of it
	addtimer(src, "detonate_pulse_explode", 50)

/obj/item/weapon/rtd/proc/detonate_pulse_explode()
	explosion(src, 0, 0, 3, 1, flame_range = 1)
	qdel(src)


/obj/item/weapon/rtd/borg/New()
	..()
	no_ammo_message = "<span class='warning'>Insufficient charge.</span>"
	desc = "A device used to rapidly build walls and floors."
	canRturf = 1

/obj/item/weapon/rtd/borg/useResource(amount, mob/user)
	if(!iscyborg(user))
		return 0
	var/mob/living/silicon/robot/borgy = user
	if(!borgy.cell)
		if(user)
			user << no_ammo_message
		return 0
	. = borgy.cell.use(amount * 72) //borgs get 1.3x the use of their rtds
	if(!. && user)
		user << no_ammo_message
	return .

/obj/item/weapon/rtd/borg/checkResource(amount, mob/user)
	if(!iscyborg(user))
		return 0
	var/mob/living/silicon/robot/borgy = user
	if(!borgy.cell)
		if(user)
			user << no_ammo_message
		return 0
	. = borgy.cell.charge >= (amount * 72)
	if(!. && user)
		user << no_ammo_message
	return .

/obj/item/weapon/rtd/loaded
	matter = 160

/obj/item/weapon/rtd/combat
	name = "industrial rtd"
	max_matter = 500
	matter = 500
	canRturf = 1

/obj/item/weapon/rtd_ammo
	name = "compressed matter cartridge"
	desc = "Highly compressed matter for the rtd."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "rtd"
	item_state = "rtdammo"
	origin_tech = "materials=3"
	materials = list(MAT_METAL=3000, MAT_GLASS=2000)
	var/ammoamt = 40

/obj/item/weapon/rtd_ammo/large
	origin_tech = "materials=4"
	materials = list(MAT_METAL=12000, MAT_GLASS=8000)
	ammoamt = 160
