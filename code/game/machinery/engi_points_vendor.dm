/obj/machinery/engi_points_manager
	name = "Intergalactic Energy Point Exchange"
	desc = "A cutting edge market that trades energy and simple matter on a FTL basis."
	icon = 'icons/obj/machines/engi_points.dmi'
	icon_state = "store"
	verb_say = "states"
	density = TRUE
	anchored = TRUE
	req_access = list(access_engine)
	var/restricted_access = FALSE
	var/obj/item/device/radio/radio
	var/GBP = 0
	var/GBPearned = 0
	var/power_export_bonus = 0
	var/air_alarm_bonus = 0
	var/power_alarm_bonus = 0
	var/fire_alarm_bonus = 0
	var/alarm_rating = ""
	var/prior_bonus = 2500
	var/total_bonus = 0
	var/GBP_alarm_cooldown = 4500
	var/static/list/prize_list = list(
		new /datum/GBP_equipment("Tendie",				/obj/item/weapon/reagent_containers/food/snacks/nugget,				50,		1),
		new /datum/GBP_equipment("Cigar",				/obj/item/clothing/mask/cigarette/cigar/havana,						50,		1),
		new /datum/GBP_equipment("Fulton Beacon",		/obj/item/fulton_core,												50,		1),
		new /datum/GBP_equipment("Soap",				/obj/item/weapon/soap/nanotrasen,									250,	1),
		new /datum/GBP_equipment("Advanced Indoor Fulton Pack",			/obj/item/weapon/extraction_pack/advanced,			300,	1),
		new /datum/GBP_equipment("Insulated Gloves",				/obj/item/clothing/gloves/color/yellow,					400,	1),
		new /datum/GBP_equipment("50 metal sheets",			/obj/item/stack/sheet/metal/fifty,								500,	1),
		new /datum/GBP_equipment("50 glass sheets",			/obj/item/stack/sheet/glass/fifty,								500,	1),
		new /datum/GBP_equipment("50 cardboard sheets",			/obj/item/stack/sheet/cardboard/fifty,						500,	1),
		new /datum/GBP_equipment("Space Cash",			/obj/item/stack/spacecash/c1000,									600,	1),
		new /datum/GBP_equipment("Hardsuit x3",			/obj/item/clothing/suit/space/hardsuit,								750,	3),
		new /datum/GBP_equipment("Jetpack Upgrade x3",		/obj/item/weapon/tank/jetpack/suit,								1000,	3),
		new /datum/GBP_equipment("Forcefield Projector x3",		/obj/item/device/forcefield,								1500,	3),
		new /datum/GBP_equipment("Powertools x4",			/obj/item/weapon/storage/belt/utility/chief/full,				2000,	4),
		new /datum/GBP_equipment("Freon Canister",			/obj/machinery/portable_atmospherics/canister/freon,			2500,	1),
		new /datum/GBP_equipment("Prototype Canister",		/obj/machinery/portable_atmospherics/canister/proto/default,	2500,	1),
		new /datum/GBP_equipment("Advanced Magboot x3",			/obj/item/clothing/shoes/magboots/advance,					3000,	3),
		new /datum/GBP_equipment("Reflector Box x3",			/obj/structure/reflector/box,								3500,	3),
		new /datum/GBP_equipment("Radiation Collector x3",			/obj/machinery/power/rad_collector,						4000,	3),
		new /datum/GBP_equipment("ERT Hardsuit x5",		/obj/item/clothing/suit/space/hardsuit/ert/engi,					7500,	5),
		new /datum/GBP_equipment("Ranged RCD x4",			/obj/item/weapon/rcd/arcd,										9000,	4),
		new /datum/GBP_equipment("Prototype Atmos Vehicle x2",			/obj/vehicle/space/speedbike/atmos,					10000,	2),
		new /datum/GBP_equipment("Reactive Decoy Armor x5",		/obj/item/clothing/suit/armor/reactive/stealth,				11000,	5),
		new /datum/GBP_equipment("Prototype Repair Vehicle x3",		/obj/vehicle/space/speedbike/repair,					15000,	3),
		new /datum/GBP_equipment("Chrono Suit x5",			/obj/item/clothing/suit/space/chronos,							20000,	5),
		new /datum/GBP_equipment("Nuclear Construction Device",			/obj/machinery/construction_nuke,					25000,	1),
		new /datum/GBP_equipment("Engineer's Pinnacle X5",		/obj/vehicle/space/speedbike/memewagon,						30000,	5),
		)

/datum/GBP_equipment
	var/equipment_name = "generic"
	var/equipment_path = null
	var/cost = 0
	var/amount = 0

/datum/GBP_equipment/New(name, path, cost, amount)
	equipment_name = name
	equipment_path = path
	src.cost = cost
	src.amount = amount

/obj/machinery/engi_points_manager/Initialize()
	engi_points_list += src
	radio = new(src)
	radio.listening = FALSE
	radio.frequency = 1357
	..()

/obj/machinery/engi_points_manager/Destroy()
	engi_points_list -= src
	if(radio)
		qdel(radio)
		radio = null
	return ..()


/obj/machinery/engi_points_manager/power_change()
	..()
	update_icon()

/obj/machinery/engi_points_manager/update_icon()
	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

/obj/machinery/engi_points_manager/interact(mob/user)
	if(!allowed(user))
		user << "<span class='warning'>Error - Unauthorized User</span>"
		playsound(src, 'sound/misc/compiler-failure.ogg', 50, 1)
		return
	var/list/dat = list()
	dat +="<div class='statusDisplay'>"
	dat += "You currently have <td>[round(GBP)]</td> engineering voucher points<br>"
	dat += "You have earned a total of <td>[round(GBPearned)]</td> this shift<br>"
	dat += "</div>"
	dat += 	"<b><A href='?src=\ref[src];choice=restrict'>[restricted_access ? "Open Access to all Engineering Personnel" : "Restrict Access to Chief Engineer"]</A></b><br>"
	dat += "<br><b>Equipment point cost list:</b><BR><table border='0' width='300'>"
	for(var/datum/GBP_equipment/prize in prize_list)
		dat += "<tr><td>[prize.equipment_name]</td><td>[prize.cost]</td><td><A href='?src=\ref[src];purchase=\ref[prize]'>Purchase</A></td></tr>"
	dat += "</table>"

	var/datum/browser/popup = new(user, "vending", "Engineering Point Redemption", 400, 350)
	popup.set_content(dat.Join())
	popup.open()

/obj/machinery/engi_points_manager/Topic(href, href_list)
	if(..())
		return
	if(href_list["choice"])
		playsound(loc, 'sound/machines/terminal_prompt.ogg', 75, 1)
		restricted_access = !restricted_access
		if(restricted_access)
			req_access = list(access_ce)
		else
			req_access = list(access_engine)
		updateUsrDialog()
	if(href_list["purchase"])
		var/datum/GBP_equipment/prize = locate(href_list["purchase"])
		if (!prize || !(prize in prize_list))
			return
		if(prize.cost > GBP)
			playsound(src, 'sound/misc/compiler-failure.ogg', 50, 1)
			return
		else if(prize.cost <= GBP)
			GBP -= prize.cost
			for(var/obj/machinery/engi_points_delivery/D in deliverer_list)
				D.icon_state = "geardist-load"
				playsound(D, 'sound/machines/Ding.ogg', 100, 1)
				sleep(10)
				if(!D || QDELETED(D))
					return
				spawn_atom_to_turf(prize.equipment_path, D, prize.amount, FALSE)
				D.icon_state = "geardist"
				if(prize.equipment_path == /obj/item/clothing/suit/space/chronos)
					spawn_atom_to_turf(/obj/item/clothing/head/helmet/space/chronos, D, prize.amount, FALSE)
				if(prize.cost >= 1000)
					radio.talk_into(src, "[usr] has bought [prize.equipment_name] for [prize.cost] points")
				feedback_add_details("Engi_equipment_bought","[src.type]|[prize.equipment_path]")
	updateUsrDialog()

/obj/machinery/engi_points_manager/process()
	power_export_bonus = 0
	for(var/obj/machinery/power/exporter/PE in power_exporter_list)
		power_export_bonus = PE.drain_rate/200 // basically controls the balance of the current point system
	if(GBP_alarm_cooldown <= world.time)
		for(var/obj/machinery/computer/station_alert/SA in machines)
			if(SA.z == src.z)
				air_alarm_bonus = max(0,(1000 - (LAZYLEN(SA.alarms["Atmosphere"])) * 200))
				power_alarm_bonus = max(0,(1000 - (LAZYLEN(SA.alarms["Power"])) * 200))
				fire_alarm_bonus = max(0,(500 - (LAZYLEN(SA.alarms["Fire"])) * 200))
				total_bonus = air_alarm_bonus + power_alarm_bonus + fire_alarm_bonus
				break
		switch(total_bonus)
			if(0)
				alarm_rating = "GREYTIDE IN YELLOW JUMPSUITS"
				playsound(src, 'sound/misc/compiler-failure.ogg', 100, 1)
			if(100 to 900)
				alarm_rating = "COMPLICIT IN THE STATION'S DOWNFALL"
				playsound(src, 'sound/misc/compiler-failure.ogg', 100, 1)
			if(1000 to 1500)
				alarm_rating = "HALF-ASSED"
				playsound(src, 'sound/misc/compiler-stage1.ogg', 100, 1)
			if(1600 to 2000)
				alarm_rating = "ADEQUATE AND UNREMARKABLE"
				playsound(src, 'sound/misc/compiler-stage1.ogg', 100, 1)
			if(2100 to 2400)
				alarm_rating = "IMPRESSIVE"
				playsound(src, 'sound/misc/compiler-stage2.ogg', 100, 1)
			if(2500 to 9999999)
				alarm_rating = "ABSOLUTELY FLAWLESS"
				playsound(src, 'sound/misc/compiler-stage2.ogg', 100, 1)
		radio.talk_into(src,"UPDATE: The engineering department has been awarded [air_alarm_bonus] points for the state of the station's air, [power_alarm_bonus] points for the state of the station's power, and [fire_alarm_bonus] points for the state of the station's fire alarms.")
		radio.talk_into(src,"This bonus represents [((total_bonus)/2500)*100]% of the total possible bonus. Your rating is: [alarm_rating]. Consult the station alert console for details.")
		if((total_bonus - prior_bonus) >= 1600)
			radio.talk_into(src,"Congratulations! Due to the significant repairs made by the engineering team, your bonus has been doubled this cycle!")
			total_bonus = total_bonus*2
		prior_bonus = total_bonus
		GBP_alarm_cooldown = world.time + 4000
		power_export_bonus += (air_alarm_bonus + power_alarm_bonus + fire_alarm_bonus)
	GBP += power_export_bonus
	GBPearned += power_export_bonus

/obj/machinery/engi_points_delivery
	name = "Engineering Reward Fabricator"
	desc = "Tapping into an almost infinite network of energy that transcends space and time... for goodies"
	icon = 'icons/obj/machines/engi_points.dmi'
	icon_state = "geardist"
	density = TRUE
	anchored = TRUE

/obj/machinery/engi_points_delivery/Initialize()
	..()
	deliverer_list += src

/obj/machinery/engi_points_delivery/Destroy()
	deliverer_list -= src
	return ..()




// Construction "nuke"


/obj/machinery/construction_nuke
	name = "nuclear fission construction device"
	desc = "The next level of interior redecoration."
	icon = 'icons/obj/machines/nuke.dmi'
	icon_state = "nuclearbomb0"
	density = TRUE

	var/timer_set = 90
	var/ui_style = "nanotrasen"
	var/range = 160

	var/timing = FALSE
	var/detonation_timer = null
	var/cooldown = 0
	var/safety = TRUE
	use_power = 0

	var/bomb_set = FALSE
	var/exploding = FALSE
	var/quiet = FALSE
	var/payload = "plasteel"
	var/payload_wall = /turf/closed/wall/r_wall
	var/payload_floor = /turf/open/floor/engine
	var/static/list/possible_payloads = list("wood", "sand", "ice", "silver","gold","bananium", "abductor", "plasma","uranium","diamond", "plasteel", "titanium", "plastitanium", )

/obj/machinery/nuclearbomb/Initialize()
	..()
	poi_list |= src

/obj/machinery/nuclearbomb/examine(mob/user)
	. = ..()
	if(timing)
		to_chat(user, "There are [get_time_left()] seconds until detonation.")

/obj/machinery/construction_nuke/process()
	if(timing)
		bomb_set = TRUE
		if(detonation_timer < world.time && !exploding)
			explode()
			qdel(src)
		else
			switch(get_time_left())
				if (30 to 3600)
					playsound(loc, 'sound/items/timer.ogg', 5, 0)
				if (15 to 29)
					playsound(loc, 'sound/items/timer.ogg', 30, 0)
				if (0 to 14)
					icon_state = "nuclearbomb3"
					quiet  = !quiet
					if(!quiet)
						return
					else
						playsound(loc, 'sound/machines/engine_alert2.ogg', 100, 0)

/obj/machinery/construction_nuke/interact(mob/user)
	user.set_machine(src)
	var/list/dat = list()
	dat +="<div class='statusDisplay'>"
	dat += "Timer: [get_time_left()] seconds<br>"
	dat += "</div>"
	dat += "<b><u>Detonation Payload</u>: <A href='?src=\ref[src];action=payload'>[payload]</A></b><br><br>"
	dat += "<A href='?src=\ref[src];action=set'>Set Timer</A><br>"
	dat += "<A href='?src=\ref[src];action=anchor'>[anchored ? "Anchored" : "Not Anchored"]</A><br>"
	dat += "<A href='?src=\ref[src];action=safety'>[safety ? "Safety On" : "Safety Off"]</A><br><br>"
	dat += "<b><A href='?src=\ref[src];action=activate'>[bomb_set ? "DEACTIVATE" : "ACTIVATE"]</A><b><br>"
	var/datum/browser/popup = new(user, "vending", "Construction Nuke", 300, 275)
	popup.set_content(dat.Join())
	popup.open()


/obj/machinery/construction_nuke/Topic(href, href_list)
	if(..())
		return
	switch(href_list["action"])
		if ("payload")
			set_payload()
			updateUsrDialog()
		if ("set")
			set_timer()
			updateUsrDialog()
		if ("anchor")
			set_anchor()
			updateUsrDialog()
		if ("safety")
			set_safety()
			updateUsrDialog()
		if ("activate")
			set_active()
			updateUsrDialog()

/obj/machinery/construction_nuke/proc/set_payload()
	playsound(loc, 'sound/machines/terminal_prompt.ogg', 75, 1)
	if(timing || bomb_set)
		to_chat(usr, "<span class='danger'>Error: Payload cannot be altered while the device is armed.</span>")
		playsound(loc, 'sound/machines/defib_failed.ogg', 75, 1)
		return
	payload = input(usr, "Choose your Payload", "Payload:") as null|anything in possible_payloads
	if (!src || QDELETED(src))
		return
	playsound(loc, 'sound/machines/terminal_prompt_confirm.ogg', 75, 1)
	switch(payload)
		if("plasteel")
			payload_wall = /turf/closed/wall/r_wall
			payload_floor = /turf/open/floor/engine
		if("wood")
			payload_wall = /turf/closed/wall/mineral/wood
			payload_floor = /turf/open/floor/wood
		if("sand")
			payload_wall = /turf/closed/wall/mineral/sandstone
			payload_floor = /turf/open/floor/plating/beach/sand
		if("ice")
			payload_wall = /turf/closed/wall/ice
			payload_floor = /turf/open/floor/plating/ice
		else
			payload_wall = text2path("/turf/closed/wall/mineral/[payload]")
			payload_floor = text2path("/turf/open/floor/mineral/[payload]")


/obj/machinery/construction_nuke/proc/set_timer()
	playsound(loc, 'sound/machines/terminal_prompt.ogg', 75, 1)
	timer_set = input("Set timer in seconds:", name, timer_set)
	if (!src || QDELETED(src))
		return
	playsound(loc, 'sound/machines/terminal_prompt_confirm.ogg', 75, 1)
	if(timer_set < 90)
		timer_set = 90
	if(timer_set > 300)
		timer_set = 300

/obj/machinery/construction_nuke/proc/set_anchor()
	if(timing || !safety)
		to_chat(usr, "<span class='warning'>Cannot remove anchors while the safety is off!</span>")
		return
	if(!isinspace())
		anchored = !anchored
		playsound(loc, 'sound/items/Deconstruct.ogg', 75, 1)
		icon_state = "nuclearbomb2"
	else
		to_chat(usr, "<span class='warning'>There is nothing to anchor to!</span>")
/obj/machinery/construction_nuke/proc/set_safety()
	if(!anchored)
		to_chat(usr, "<span class='danger'>Error: Safety cannot be altered on an unanchored device.</span>")
		playsound(loc, 'sound/machines/defib_failed.ogg', 75, 1)
		return
	safety = !safety
	if(safety)
		if(timing)
			priority_announce("Radioactive energy levels are normalizing, please submit an incident report as soon as possible.","Central Command Nuclear Safety Division", 'sound/AI/attention.ogg')
		timing = FALSE
		bomb_set = FALSE
		detonation_timer = null
		icon_state = "nuclearbomb2"
		playsound(loc, 'sound/machines/terminal_prompt.ogg', 75, 1)
	else
		playsound(loc, 'sound/machines/engine_alert1.ogg', 50, 1)
		icon_state = "nuclearbomb1"
	update_icon()

/obj/machinery/construction_nuke/proc/set_active()
	var/area/A = get_area(src)
	if(safety && !bomb_set)
		to_chat(usr, "<span class='danger'>Error: The safety is still on.</span>")
		playsound(loc, 'sound/machines/defib_failed.ogg', 75, 1)
		return
	if(!A.blob_allowed)
		to_chat(usr, "<span class='danger'>Error: The device's safety countermeasures flash red: you cannot arm this device outside of the station.</span>")
		playsound(loc, 'sound/machines/defib_failed.ogg', 75, 1)
		return
	timing = !timing
	if(timing)
		if(cooldown > world.time)
			to_chat(usr, "<span class='danger'>Error: The device is still resetting from the last activation, it will be ready again in [(cooldown-world.time)/10] seconds.</span>")
			playsound(loc, 'sound/machines/defib_failed.ogg', 75, 1)
			return
		bomb_set = TRUE
		priority_announce("We are detecting a massive spike of radioactive energy originating from [A.map_name]. If this is not a scheduled occurrence, please investigate immediately.","Nanotrasen Nuclear Safety Division", 'sound/machines/engine_alert2.ogg')
		cooldown = world.time + 1200
		detonation_timer = world.time + (timer_set * 10)
		icon_state = "nuclearbombc"
	else
		bomb_set = FALSE
		priority_announce("Radioactive energy levels are normalizing, please submit an incident report as soon as possible.","Central Command Nuclear Safety Division", 'sound/AI/attention.ogg')
		detonation_timer = null
		icon_state = "nuclearbomb1"
		playsound(loc, 'sound/machines/terminal_off.ogg', 75, 1)
	update_icon()

/obj/machinery/construction_nuke/proc/get_time_left()
	if(timing)
		. = round(max(0, detonation_timer - world.time) / 10, 1)
	else
		. = timer_set

/obj/machinery/construction_nuke/proc/explode()
	if(safety || !bomb_set)
		timing = FALSE
		return
	exploding = TRUE
	update_icon()
	for(var/mob/M in player_list)
		M << 'sound/machines/Alarm.ogg'
	var/turf/startpoint = get_turf(src)
	sleep(100)
	for(var/mob/M in player_list)
		M << 'sound/effects/explosionfar.ogg'
	spawn_atom_to_turf(/obj/effect/overlay/temp/big_explosion, startpoint, 1, FALSE)
	qdel(src)
	for(var/I in spiral_range_turfs(range, startpoint))
		var/turf/T = I
		if(!T)
			continue
		if(istype(T, /turf/open/floor/))
			T.ChangeTurf(payload_floor)
			spawn_atom_to_turf(/obj/effect/overlay/temp/fire, T, 1, FALSE)
		else if(istype(T, /turf/closed/wall/))
			T.ChangeTurf(payload_wall)
			spawn_atom_to_turf(/obj/effect/overlay/temp/fire, T, 1, FALSE)
		CHECK_TICK
