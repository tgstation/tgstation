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
		power_export_bonus = sqrt(PE.drain_rate)/3 // basically controls the balance of the current point system
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
		if(total_bonus > prior_bonus)
			radio.talk_into(src,"Congratulations! Your team has been awarded an extra [total_bonus - prior_bonus] points for improvements from the previous evaluation.")
			total_bonus = (total_bonus * 2 - prior_bonus)
		prior_bonus = air_alarm_bonus + power_alarm_bonus + fire_alarm_bonus
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
	var/static/list/possible_payloads = list("wood", "sand", "ice", "mining", "silver","gold","bananium", "abductor", "plasma","uranium","diamond", "plasteel", "titanium", "plastitanium", )

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
		if("mining")
			payload_wall = /turf/closed/wall/shuttle/survival/pod
			payload_floor = /turf/open/floor/plating/asteroid/basalt/lava
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
			to_chat(usr, "<span class='danger'>Error: The device is still resetting from the last activation, it will be ready again in [round((cooldown-world.time)/10)] seconds.</span>")
			playsound(loc, 'sound/machines/defib_failed.ogg', 75, 1)
			timing = FALSE
			return
		bomb_set = TRUE
		priority_announce("We are detecting a massive spike of radioactive energy originating from [A.map_name]. If this is not a scheduled occurrence, please investigate immediately.","Nanotrasen Nuclear Safety Division", 'sound/misc/airraid.ogg')
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


// DISCO BALL


/obj/machinery/disco
	name = "disco ball"
	desc = "Funky."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "disco0"
	density = TRUE
	anchored = FALSE
	verb_say = "states"
	density = TRUE
	req_access = list(access_engine)
	var/active = FALSE
	var/cooldown = 0
	var/list/rangers = list()
	var/list/listeners = list()
	var/stop = 0
	var/song = "beep"
	req_access = list(access_engine)
	var/list/spotlights = list()
	var/list/sparkles = list()


/obj/machinery/disco/attackby(obj/item/O, mob/user, params)
	if(!active)
		if(istype(O, /obj/item/weapon/wrench))
			if(!anchored && !isinspace())
				user << "<span class='notice'>You secure the [src] to the floor.</span>"
				anchored = TRUE
			else if(anchored)
				user << "<span class='notice'>You unsecure and disconnect the [src].</span>"
				anchored = FALSE
			playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
			return
	return ..()


/obj/machinery/disco/Destroy()
	dance_over()
	return ..()

/obj/machinery/disco/interact(mob/user)
	if (!anchored)
		user << "<span class='warning'>This device must be anchored by a wrench!</span>"
		return
	if(!allowed(user))
		user << "<span class='warning'>You stare at the complex interface and are overwhelmed by the raw amount of data being displayed... only an engineer could operate such a sophisticated device.</span>"
		playsound(src, 'sound/misc/compiler-failure.ogg', 50, 1)
		return
	if(!Adjacent(user))
		if(!isAI(user))
			return
	user.set_machine(src)
	var/list/dat = list()
	dat += ("<b>Basic Funk</b><br>")
	dat +="<div class='statusDisplay'>"
	dat += ("<A href='?src=\ref[src];action=toggle1'>[!active ? "Enable Funk" : "Disable Funk"]</A><br>")
	dat +="</div ><br>"
	var/datum/browser/popup = new(user, "vending", "Disco Ball", 400, 350)
	popup.set_content(dat.Join())
	popup.open()


/obj/machinery/disco/Topic(href, href_list)
	if(..())
		return
	add_fingerprint(usr)
	switch(href_list["action"])
		if("toggle1")
			if(!active && !crit_fail)
				if(cooldown > world.time)
					to_chat(usr, "<span class='danger'>Error: The device is still resetting from the last activation, it will be ready again in [round((cooldown-world.time)/10)] seconds.</span>")
					playsound(src, 'sound/misc/compiler-failure.ogg', 50, 1)
					return
				active = TRUE
				icon_state = "disco1"
				lights_on()
				cooldown = world.time + 1200
				stop = world.time + 590
				START_PROCESSING(SSobj, src)
				lights_spin()
				src.updateUsrDialog()
			else if(active)
				active = FALSE
				STOP_PROCESSING(SSobj, src)
				playsound(src,'sound/machines/terminal_off.ogg',50,1)
				icon_state = "disco0"
				dance_over()
				src.updateUsrDialog()

/obj/machinery/disco/proc/bless(var/mob/living/carbon/M)
	switch(rand(0,10))
		if(0 to 1)
			set waitfor = 0
			for(var/i = 1, i < 10, i++)
				M.SpinAnimation(7,1)
				M.setDir(pick(cardinal))
				sleep(10)
		if(2 to 3)
			set waitfor = 0
			for(var/i in 1 to 8)
				if (!M)
					return
				M.SpinAnimation(7,1)
				M.setDir(pick(cardinal))
				for (var/x in 1 to 12)
					sleep(1)
					if (!M)
						return
					if (i<5)
						M.pixel_y += 2
					if (i>4)
						M.pixel_y -= 2
					M.setDir(turn(M.dir, 90))
					switch (M.dir)
						if (NORTH)
							M.pixel_y += 3
						if (SOUTH)
							M.pixel_y -= 3
						if (EAST)
							M.pixel_x -= 3
						if (WEST)
							M.pixel_x += 3
				sleep(12)
			M.pixel_x = 0
			M.pixel_y = 0

		if(4 to 5)
			M.throw_at(get_turf(src),3,7)
			M.setDir(get_dir(M, src))
			for (var/i = 0, i < 25, i++)
				var/delay = 5
				switch (i)
					if (17 to INFINITY)
						delay = 0.25
					if (14 to 16)
						delay = 0.5
					if (9 to 13)
						delay = 1
					if (5 to 8)
						delay = 2
					if (0 to 4)
						delay = 3

				if (M)
					src.setDir(turn(src.dir, 90))
					var/turf/T = get_step(src, src.dir)
					var/turf/S = M.loc
					if ((S && isturf(S) && S.Exit(M)) && (T && isturf(T) && T.Enter(src)))
						M.forceMove(T)
						M.setDir(get_dir(M, src))
						if(i>17)
							M.SpinAnimation(2,1)
				else
					return 0
				sleep(delay)
			M.throw_at(get_edge_target_turf(src,pick(M.dir)), 3,6)
		if(6 to 7)
			var/speed = rand(1,3)
			set waitfor = 0
			var/time = 30
			while(time)
				sleep(speed)
				for(var/i in 1 to speed)
					M.setDir(pick(cardinal))
					M.lay_down()
				 time--

		if(8 to 10)
			M.setDir(get_dir(M, src))
			spawn (0)
				if (M)
					animate(M, transform = matrix(180, MATRIX_ROTATE), time = 1, loop = 0)
				sleep (70)
				if (M)
					animate(M, transform = null, time = 1, loop = 0)

			for (var/i = 0, i < 60, i++)
				if (!M)
					return
				if (i<31)
					M.pixel_y += 2
				if (i>30)
					M.pixel_y -= 2
				M.setDir(turn(M.dir, 90))
				switch (M.dir)
					if (NORTH)
						M.pixel_y += 3
					if (SOUTH)
						M.pixel_y -= 3
					if (EAST)
						M.pixel_x -= 3
					if (WEST)
						M.pixel_x += 3
				sleep (1)
			M.pixel_x = 0
			M.pixel_y = 0

/obj/machinery/disco/proc/lights_on()
	var/turf/cen = get_turf(src)
	for(var/turf/t in view(src,3))
		if(t.x == cen.x && t.y > cen.y)
			var/obj/machinery/light/floor/spotlight/L = new /obj/machinery/light/floor/spotlight(t)
			L.light_color = "yellow"
			visible_message("<span class='boldannounce'>The [L.light_color] [L] warps in! It is currently [get_dir(src,L)] of the machine!</span>")
			spotlights+=L
			continue
		if(t.x == cen.x && t.y < cen.y)
			var/obj/machinery/light/floor/spotlight/L = new /obj/machinery/light/floor/spotlight(t)
			L.light_color = "green"
			spotlights+=L
			continue
		if(t.x > cen.x && t.y == cen.y)
			var/obj/machinery/light/floor/spotlight/L = new /obj/machinery/light/floor/spotlight(t)
			L.light_color = "purple"
			visible_message("<span class='boldannounce'>The [L.light_color] [L] warps in! It is currently [get_dir(src,L)] of the machine!</span>")
			spotlights+=L
			continue
		if(t.x < cen.x && t.y == cen.y)
			var/obj/machinery/light/floor/spotlight/L = new /obj/machinery/light/floor/spotlight(t)
			L.light_color = "#00ffff"
			spotlights+=L
			continue
		if((t.x+1 == cen.x && t.y+1 == cen.y) || (t.x+2==cen.x && t.y+2 == cen.y))
			var/obj/machinery/light/floor/spotlight/L = new /obj/machinery/light/floor/spotlight(t)
			L.light_color = "sw"
			spotlights+=L
			continue
		if((t.x-1 == cen.x && t.y-1 == cen.y) || (t.x-2==cen.x && t.y-2 == cen.y))
			var/obj/machinery/light/floor/spotlight/L = new /obj/machinery/light/floor/spotlight(t)
			L.light_color = "ne"
			spotlights+=L
			visible_message("<span class='boldannounce'>The [L.light_color] [L] warps in! It is currently [get_dir(src,L)] of the machine!</span>")
			continue
		if((t.x-1 == cen.x && t.y+1 == cen.y) || (t.x-2==cen.x && t.y+2 == cen.y))
			var/obj/machinery/light/floor/spotlight/L = new /obj/machinery/light/floor/spotlight(t)
			L.light_color = "se"
			spotlights+=L
			continue
		if((t.x+1 == cen.x && t.y-1 == cen.y) || (t.x+2==cen.x && t.y-2 == cen.y))
			var/obj/machinery/light/floor/spotlight/L = new /obj/machinery/light/floor/spotlight(t)
			L.light_color = "nw"
			spotlights+=L
			continue
		continue

/obj/machinery/disco/proc/lights_spin()
	for(var/i in 1 to 24)
		var/obj/effect/overlay/sparkles/S = new /obj/effect/overlay/sparkles(src)
		S.alpha = 0
		sparkles += S
		switch(i)
			if(1 to 8)
				S.orbit(src, 30, FALSE, 60, 36, TRUE, FALSE)
			if(9 to 16)
				S.orbit(src, 62, FALSE, 60, 36, TRUE, FALSE)
			if(17 to 24)
				S.orbit(src, 95, FALSE, 60, 36, TRUE, FALSE)
		sleep(7)
	for(var/obj/reveal in sparkles)
		reveal.alpha = 160
	for(var/n in 1 to 120)
		for(var/obj/machinery/light/glow in spotlights)
			if(glow.light_color == "yellow")
				glow.light_color = "nw"
				glow.update_light()
				continue
			if(glow.light_color == "nw")
				glow.light_color = "purple"
				glow.update_light()
				continue
			if(glow.light_color == "purple")
				glow.light_color = "sw"
				glow.update_light()
				continue
			if(glow.light_color == "sw")
				glow.light_color = "green"
				glow.update_light()
				continue
			if(glow.light_color == "green")
				glow.light_color = "se"
				glow.update_light()
				continue
			if(glow.light_color == "se")
				glow.light_color = "#00ffff"
				glow.update_light()
				continue
			if(glow.light_color == "#00ffff")
				glow.light_color = "ne"
				glow.update_light()
				continue
			if(glow.light_color == "ne")
				glow.light_color = "yellow"
				glow.update_light()
				visible_message("<span class='boldannounce'>The [glow] has just turned [glow.light_color]! It is currently [get_dir(src,glow)] of the machine!</span>")
				continue
		sleep(100)

/obj/machinery/disco/proc/dance_over()
	for(var/obj/machinery/light/floor/spotlight/SL in spotlights)
		qdel(SL)
	spotlights.Cut()
	for(var/obj/effect/overlay/sparkles/SP in sparkles)
		qdel(SP)
	sparkles.Cut()
	rangers.Cut()
	for(var/mob/living/L in listeners)
		if(!L || !L.client)
			continue
		L.client.stop_client_sounds()
	listeners.Cut()


/obj/machinery/disco/process()
	if(world.time < stop && active)
		rangers = list()
		for(var/mob/living/M in range(9,src))
			rangers += M
			if(!(M in listeners))
				M << 'sound/misc/disco.ogg'
				listeners += M
			if(prob(5))
				bless(M)
			else if(allowed(M)) // Engineers over 100% more groovy than normal crew
				if(prob(7))
					bless(M)
		for(var/mob/living/L in listeners)
			if(!(L in rangers))
				listeners -= L
				if(!L || !L.client)
					continue
				L.client.stop_client_sounds()

	else if(active)
		STOP_PROCESSING(SSobj, src)
		playsound(src,'sound/machines/terminal_off.ogg',50,1)
		dance_over()
		active = FALSE
		icon_state = "disco0"


// Bonus gloves for power export goal, won't be seen in 99% of rounds



/obj/item/clothing/gloves/krav_maga/engi
	name = "fists of the singulo"
	desc = "You have spent so much time managing power that your fists have become one with the powernet."
	icon_state = "singulo"
	item_state = "yellow"
	item_color="yellow"
	permeability_coefficient = 0.05
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = 0