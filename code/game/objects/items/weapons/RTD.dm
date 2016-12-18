#define NO_AMMO_MESSAGE "Insufficient Matter"

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
	desc = "A bulky, prototype industrial device based on RCD and compressed matter technology that is designed for rapid terraforming of hostile planetary environments. \
	Has safeguards to not work on station. Automatically synthesizes compressed air to pressurize colonies. A label on the side reads: WARNING: DO NOT USE DEVICE WITHOUT INSULATED GLOVES!"
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
	actions_types = list(/datum/action/item_action/rtd/gas,/datum/action/item_action/rtd/type,/datum/action/item_action/rtd/access)
	var/datum/effect_system/spark_spread/spark_system
	var/matter = 400
	var/maxmatter = 400
	var/gas = 10
	var/maxgas = 10
	var/working = 0
	var/mode = 1
	var/canRturf = 0
	var/airlock_type = /obj/machinery/door/airlock
	var/range_catwalk = 4
	var/range_plating = 3
	var/o2ratio = 0.2
	var/n2ratio = 0.8
	var/gas_use = 1
	var/mob/living/user = null

	var/advanced_airlock_setting = 1
	var/sheetmultiplier	= 8
	var/plasteelmultiplier = 5
	var/ironoreworth = 2.5
	var/gas_amount = (MOLES_CELLSTANDARD * 2)
	var/gas_regen_delay = 5

	var/list/conf_access = null
	var/use_one_access = 0 //If the airlock should require ALL or only ONE of the listed accesses.

	var/safety = 1
	/*
	Construction costs
	COST| FUNCTION
	10	|Asteroid walls to walls
	5	|Lavaland floors to plating
	20	|Builds catwalks on lava.
	SEPARATE FROM OTHERS - Blasts compressed air to pressurize areas
	25	|Builds airlocks with higher health than normal airlocks, but the same security level.
	2	|Build membrane barriers - Basically walls that will break in a single hit from just about anything and is best left for emergency usage.
	0	|Remove Catwalks - Just incase antags get ahold of it or you really need a lava disposals bin. Honk.
	*/

	var/wallcost = 10
	var/floorcost = 5
	var/catwalkcost = 30
	var/airlockcost = 25
	var/membranecost = 2
	var/removecatwalkcost = 0
	var/processtick = 0

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
	var/obj/machinery/door/airlock/A = new /obj/machinery/door/airlock/glass_command(get_turf(src))
	A.max_integrity = 500
	A.obj_integrity = 500
	A.name = user.name
	return (BRUTELOSS)

/obj/item/weapon/rtd/proc/change_airlock_access(mob/living/L)
	if(!L)
		return 0
	user = L
	var/mob/living/carbon/human/H = L
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
	var/datum/browser/popup = new(L, "airlock_electronics", "Access Control", 900, 500)
	popup.set_content(t1)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	onclose(user, "airlock")

/obj/item/weapon/rtd/Topic(href, href_list)
	..()
	if (user.stat || user.restrained())
		return
	if (href_list["close"])
		user << browse(null, "window=airlock")
		return
	if (href_list["access"])
		toggle_access(href_list["access"])
	change_airlock_access(user)

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

/obj/item/weapon/rtd/proc/toggle_gas_enrichment(mob/living/L)
	L << "Higher settings use more synthesized gas."
	var/enrich = input(user, "Select oxygen injection amount.") in list ("NONE", "Standard", "Slightly Enriched", "Highly Enriched", "Half-Half O2-N2", "75%", "Full O2")
	switch(enrich)
		if("NONE")
			o2ratio = 0
			n2ratio = 1
			gas_use = 0.5
		if("Standard")
			o2ratio = 0.2
			n2ratio = 0.8
			gas_use = 1
		if("Slightly Enriched")
			o2ratio = 0.3
			n2ratio = 0.7
			gas_use = 1.2
		if("Highly Enriched")
			o2ratio = 0.4
			n2ratio = 0.6
			gas_use = 1.5
		if("Half-Half O2-N2")
			o2ratio = 0.5
			n2ratio = 0.5
			gas_use = 1.75
		if("75%")
			o2ratio = 0.75
			n2ratio = 0.25
			gas_use = 2
		if("Full O2")
			o2ratio = 1
			n2ratio = 0
			gas_use = 2.5

/obj/item/weapon/rtd/proc/change_airlock_setting(mob/living/L)
	airlockcost = initial(airlockcost)
	var airlockcat = input(L, "Select whether the airlock is solid or glass.") in list("Solid", "Glass")
	switch(airlockcat)
		if("Solid")
			if(advanced_airlock_setting == 1)
				var airlockpaint = input(L, "Select the paintjob of the airlock.") in list("Default", "Engineering", "Atmospherics", "Security", "Command", "Medical", "Research", "Mining", "Maintenance", "External", "High Security")
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
				var airlockpaint = input(L, "Select the paintjob of the airlock.") in list("Default", "Engineering", "Atmospherics", "Security", "Command", "Medical", "Research", "Mining")
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

/obj/item/weapon/rtd/proc/electrocute_check(P, mob/living/user)
	var/S = 0.5
	if(prob(P))
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.gloves)
				var/obj/item/clothing/gloves/G = H.gloves
				S = G.siemens_coefficient
				if(G.siemens_coefficient == 0)
					return 0
		user.electrocute_act(10, src, S)

/obj/item/weapon/rtd/New()
	..()
	src.spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	rcd_list += src
	START_PROCESSING(SSobj, src)

/obj/item/weapon/rtd/examine(mob/user)
	..()
	user << "<span class='boldnotice'>Its matter indicator reads [matter]/[maxmatter] units left.</span>"
	user << "<span class='boldnotice'>Its gas indicator reads [gas]/[maxgas].</span>"

/obj/item/weapon/rtd/Destroy()
	qdel(spark_system)
	spark_system = null
	rcd_list -= src
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/weapon/rtd/process()
	processtick++
	if(processtick < gas_regen_delay)
		return
	if(gas < maxgas)
		gas++

/obj/item/weapon/rtd/attackby(obj/item/weapon/W, mob/user, params)
	if(iscyborg(user))	//Make sure cyborgs can't load their rtds
		return
	var/loaded = 0
	if(istype(W, /obj/item/weapon/storage/bag/ore))
		var/obj/item/weapon/storage/bag/ore/B = W
		var/A = 0
		for(var/obj/O in B)
			if(istype(O, /obj/item/weapon/ore/iron))
				if((matter + ironoreworth) <= maxmatter)
					qdel(O)
					matter += ironoreworth
					A++
				else
					break
		user << "<span class='notice'>Loaded [A] pieces of iron ore. The RTD now has [matter]/[maxmatter] matter left.</span>"
	if(istype(W, /obj/item/weapon/rcd_ammo))
		var/obj/item/weapon/rcd_ammo/R = W
		if((matter + R.ammoamt) > maxmatter)
			user << "<span class='warning'>The RTD can't hold any more matter-units!</span>"
			return
		if(!user.unEquip(W))
			return
		qdel(W)
		matter += R.ammoamt
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		loaded = 1
	else if(istype(W, /obj/item/weapon/ore/iron))
		if((matter + ironoreworth) > maxmatter)
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
		user << "<span class='notice'>The RTD now holds [matter]/[maxmatter] matter-units.</span>"
	else
		return ..()

/obj/item/weapon/rtd/proc/loadwithsheets(obj/item/stack/sheet/S, value, mob/user)
	var/maxsheets = round((maxmatter-matter)/value)
	if(maxsheets > 0)
		if(S.amount > maxsheets)
			S.use(maxsheets)
			matter += value*maxsheets
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
			user << "<span class='notice'>You insert [maxsheets] [S.name] sheets into the RTD. </span>"
		else
			matter += value*(S.amount)
			user.unEquip()
			S.use(S.amount)
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
			user << "<span class='notice'>You insert [S.amount] [S.name] sheets into the RTD. </span>"
		return 1
	user << "<span class='warning'>You can't insert any more [S.name] sheets into the RTD!"
	return 0

/obj/item/weapon/rtd/attack_self(mob/user)
	//Change the mode
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
	mode++
	if(mode > 7)
		mode = 1
	switch(mode)
		if(1)
			user << "<span class='notice'>The Rapid Terraforming Device is now converting natural ground to plating. Ranged matter projection activated.</span>"
		if(2)
			user << "<span class='notice'>The Rapid Terraforming Device is now building catwalks over lava and chasms. Ranged matter projection activated.</span>"
		if(3)
			user << "<span class='notice'>The Rapid Terraforming Device is now building airlocks.</span>"
		if(4)
			user << "<span class='notice'>The Rapid Terraforming Device is now changing rock to walls.</span>"
		if(5)
			user << "<span class='notice'>The Rapid Terraforming Device is now building airtight membranes.</span>"
		if(6)
			user << "<span class='notice'>The Rapid Terraforming Device is now removing constructions.</span>"
		if(7)
			user << "<span class='notice'>The Rapid Terraforming Device is now pressurizing with compressed air.</span>"

	if(prob(50))
		src.spark_system.start()
	electrocute_check(15, user)

/obj/item/weapon/rtd/proc/activate(mob/living/user)
	playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
	electrocute_check(30, user)


/obj/item/weapon/rtd/afterattack(atom/A, mob/user, proximity)
	if(user.z == 1)
		user << "<span class='warning'>This device can not be used in the station!</span>"
		return 0
	if(!proximity && mode > 2)
		return 0
	if(mode == 1)
		if(get_dist(A, get_turf(src)) > range_plating)
			return 0
	if(mode == 2)
		if(get_dist(A, get_turf(src)) > range_catwalk)
			return 0
	if(istype(A,/turf/open/space/transit))
		return 0

	switch(mode)
		if(1)
			if(isminingturf(A))
				var/turf/open/space/S = A
				if(useResource(floorcost, user))
					user << "<span class='notice'>You start to fabricate plating over the rocky ground...</span>"
					activate(user)
					S.ChangeTurf(/turf/open/floor/plating)
					return 1
				return 0
			return 0

		if(2)
			if(islavaturf(A))
				if(useResource(catwalkcost, user))
					user << "<span class='notice'>You start to fabricate a catwalk over the lava...</span>"
					activate(user)
					new /obj/structure/lattice/catwalk/lava(get_turf(A))
					return 1
				return 0
			return 0
		if(3)
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
							activate(user)
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
			return 0
		if(4)
			if(ismineralturf(A))
				var/turf/closed/mineral/M = A
				if(checkResource(wallcost, user))
					user << "<span class='notice'>You start converting the [A] to a metal wall...</span>"
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					activate(user)
					if(do_after(user, walldelay, target = M))
						if(useResource(wallcost, user))
							M.ChangeTurf(/turf/closed/wall)
							return 1
			return 0
		if(5)
			if(isfloorturf(A))
				if(checkResource(membranecost, user))
					var/turf/open/floor/F = A
					user << "<span class='notice'>You start fabricating an airtight membrane...</span>"
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					activate(user)
					for(var/obj/O in F.contents)
						if(istype(O, /obj/structure/destructible/airwall))
							user << "<span class='notice'>There is already an inflated membrane wall here!</span>"
							return 0
					if(do_after(user, membranedelay, target = F))
						if(useResource(membranecost, user))
							new /obj/structure/destructible/airwall(get_turf(F))
							return 1
			return 0
		if(6)
			if(istype(A, /obj/structure/lattice/catwalk))
				activate(user)
				user << "<span class='warning'>You start disintegrating the catwalk...</span>"
				if(do_after(user, removedelay, target = A))
					qdel(A)
					return 1
			return 0
		if(7)
			if(gas < gas_use)
				user << "<span class='notice'>Not enough gas stored! Wait a while for internal compressors to regenerate enough gas...</span>"
				return 0
			if(isfloorturf(A))
				var/turf/open/floor/F = A
				if((F.air.return_pressure() > 4.5*ONE_ATMOSPHERE) && safety)
					user << "<span class='warning'>Danger! Air pressure too high to inject any more compressed air with safety interlocks active!</span>"
					return 0
				user << "<span class='notice'>You blast a jet of compressed airmix onto [F] with your terraforming device!</span>"
				var/datum/gas_mixture/OUT = new /datum/gas_mixture
				OUT.assert_gas("o2")
				OUT.assert_gas("n2")
				OUT.gases["o2"][MOLES] += gas_amount*o2ratio
				OUT.gases["n2"][MOLES] += gas_amount*n2ratio
				OUT.temperature = 300	//Room temperature + 6.85
				F.air.merge(OUT)
				gas = (gas - gas_use)
			return 0
		else
			user << "ERROR: RAPID_TERRAFORMING_DEVICE in MODE: [mode] attempted use by [user]. Send this text #coderbus or an admin."
			return 0

/obj/item/weapon/rtd/proc/useResource(amount, mob/user)
	if(matter < amount)
		if(user)
			user << NO_AMMO_MESSAGE
		return 0
	matter -= amount
	desc = "An rtd. It currently holds [matter]/[maxmatter] matter-units."
	return 1

/obj/item/weapon/rtd/proc/checkResource(amount, mob/user)
	. = matter >= amount
	if(!. && user)
		user << NO_AMMO_MESSAGE
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

/obj/item/weapon/rtd/borg/useResource(amount, mob/user)
	if(!iscyborg(user))
		return 0
	var/mob/living/silicon/robot/borgy = user
	if(!borgy.cell)
		if(user)
			user << NO_AMMO_MESSAGE
		return 0
	. = borgy.cell.use(amount * 50)
	if(!. && user)
		user << NO_AMMO_MESSAGE
	return .

/obj/item/weapon/rtd/borg/checkResource(amount, mob/user)
	if(!iscyborg(user))
		return 0
	var/mob/living/silicon/robot/borgy = user
	if(!borgy.cell)
		if(user)
			user << NO_AMMO_MESSAGE
		return 0
	. = borgy.cell.charge >= (amount * 72)
	if(!. && user)
		user << NO_AMMO_MESSAGE
	return .

/datum/action/item_action/rtd
	name = "RTD Action Generic"
	var/obj/item/weapon/rtd/I

/datum/action/item_action/rtd/Trigger()
	if(target)
		if(istype(target, /obj/item/weapon/rtd))
			I = target
	if(I.user != owner)
		I.user = owner

/datum/action/item_action/rtd/access
	name = "RTD: Set Airlock Access"
	button_icon_state = "rcd_access"
	background_icon_state = "bg_default"

/datum/action/item_action/rtd/access/Trigger()
	..()
	I.change_airlock_access(owner)

/datum/action/item_action/rtd/type
	name = "RTD: Set Airlock Type"
	button_icon_state = "rcd_type"
	background_icon_state = "bg_default"

/datum/action/item_action/rtd/type/Trigger()
	..()
	I.change_airlock_setting(owner)

/datum/action/item_action/rtd/gas
	name = "RTD: Set O2 Concentration"
	button_icon_state = "rtd_gas"
	background_icon_state = "bg_default"

/datum/action/item_action/rtd/gas/Trigger()
	..()
	I.toggle_gas_enrichment(owner)
