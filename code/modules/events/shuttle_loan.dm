#define HIJACK_SYNDIE 1
#define RUSKY_PARTY 2
#define SPIDER_GIFT 3
#define DEPARTMENT_RESUPPLY 4

/datum/round_event_control/shuttle_loan
	name = "Shuttle loan"
	typepath = /datum/round_event/shuttle_loan
	max_occurrences = 1
	earliest_start = 0

/datum/round_event/shuttle_loan
	endWhen = 500
	var/dispatch_type = 4
	var/bonus_points = 100
	var/thanks_msg = "Have some supply points as thanks (the shuttle will be returned in 5 minutes)."
	var/dispatched = 0

/datum/round_event/shuttle_loan/start()
	dispatch_type = pick(HIJACK_SYNDIE, RUSKY_PARTY, SPIDER_GIFT, DEPARTMENT_RESUPPLY)

/datum/round_event/shuttle_loan/announce()
	supply_shuttle.shuttle_loan = src
	switch(dispatch_type)
		if(HIJACK_SYNDIE)
			command_alert("The syndicate are trying to infiltrate your station. If you let them hijack your shuttle, you'll save us a headache.","Centcom Counter Intelligence")
		if(RUSKY_PARTY)
			command_alert("A group of angry russians want to have a party, can you send them your cargo shuttle then make them disappear?","Centcom Russian Outreach Program")
		if(SPIDER_GIFT)
			command_alert("The Spider Clan has sent us a mysterious gift, can we ship it to you to see what's inside?","Centcom Diplomatic Corps")
		if(DEPARTMENT_RESUPPLY)
			command_alert("Seems we've ordered doubles of our department resupply packages this month. Can we send them to you?","Centcom Supply Department")
			thanks_msg = "The shuttle will be returned in 5 minutes."
			bonus_points = 0

/datum/round_event/shuttle_loan/proc/loan_shuttle()
	command_alert(thanks_msg, "Cargo shuttle commandeered by Centcom.")

	dispatched = 1
	supply_shuttle.points += bonus_points
	endWhen = activeFor + 1
	supply_shuttle.eta_timeofday = (world.timeofday + 3000) % 2160000
	supply_shuttle.moving = 1

	switch(dispatch_type)
		if(HIJACK_SYNDIE)
			supply_shuttle.centcom_message += "<font color=blue>Syndicate hijack team incoming.</font>"
		if(RUSKY_PARTY)
			supply_shuttle.centcom_message += "<font color=blue>Partying Russians incoming.</font>"
		if(SPIDER_GIFT)
			supply_shuttle.centcom_message += "<font color=blue>Spider Clan gift incoming.</font>"
		if(DEPARTMENT_RESUPPLY)
			supply_shuttle.centcom_message += "<font color=blue>Department resupply incoming.</font>"

/datum/round_event/shuttle_loan/tick()
	if(dispatched)
		if(supply_shuttle.moving)
			endWhen = activeFor
		else
			endWhen = activeFor + 1

/datum/round_event/shuttle_loan/end()
	if(supply_shuttle.shuttle_loan && supply_shuttle.shuttle_loan.dispatched)
		//make sure the shuttle was dispatched in time
		supply_shuttle.shuttle_loan = null

		//spawn some stuff as reward
		var/area/shuttle_at = locate(SUPPLY_DOCK_AREATYPE)
		var/list/empty_shuttle_turfs = list()
		for(var/turf/simulated/shuttle/T in shuttle_at)
			if(T.density)
				continue
			empty_shuttle_turfs.Add(T)

		var/list/shuttle_spawns = list()
		switch(dispatch_type)
			if(HIJACK_SYNDIE)
				var/datum/supply_order/O = new /datum/supply_order()
				O.ordernum = supply_shuttle.ordernum
				O.object = new /datum/supply_packs/emergency/specialops()
				O.orderedby = "Syndicate"
				supply_shuttle.shoppinglist += O

				shuttle_spawns.Add(/mob/living/simple_animal/hostile/syndicate)
				shuttle_spawns.Add(/mob/living/simple_animal/hostile/syndicate)
				if(prob(75))
					shuttle_spawns.Add(/mob/living/simple_animal/hostile/syndicate)
				if(prob(50))
					shuttle_spawns.Add(/mob/living/simple_animal/hostile/syndicate)

				var/turf/T = pick(empty_shuttle_turfs)
				new /obj/effect/decal/cleanable/blood(T)
				T = pick(empty_shuttle_turfs)
				new /obj/effect/decal/cleanable/blood(T)
				T = pick(empty_shuttle_turfs)
				new /obj/effect/decal/cleanable/blood(T)
				T = pick(empty_shuttle_turfs)
				new /obj/effect/decal/cleanable/oil(T)

			if(RUSKY_PARTY)
				var/datum/supply_order/O = new /datum/supply_order()
				O.ordernum = supply_shuttle.ordernum
				O.object = new /datum/supply_packs/organic/party()
				O.orderedby = "Russian Confederation"
				supply_shuttle.shoppinglist += O

				shuttle_spawns.Add(/mob/living/simple_animal/hostile/russian)
				shuttle_spawns.Add(/mob/living/simple_animal/hostile/russian/ranged)	//drops a mateba
				shuttle_spawns.Add(/mob/living/simple_animal/hostile/bear)
				if(prob(75))
					shuttle_spawns.Add(/mob/living/simple_animal/hostile/russian)
				if(prob(50))
					shuttle_spawns.Add(/mob/living/simple_animal/hostile/bear)

				var/turf/T = pick(empty_shuttle_turfs)
				new /obj/effect/decal/cleanable/vomit(T)
				T = pick(empty_shuttle_turfs)
				new /obj/effect/decal/cleanable/vomit(T)
				T = pick(empty_shuttle_turfs)
				new /obj/effect/decal/cleanable/vomit(T)
				T = pick(empty_shuttle_turfs)
				new /obj/effect/decal/cleanable/vomit(T)
				T = pick(empty_shuttle_turfs)
				new /obj/effect/decal/cleanable/ash(T)
				T = pick(empty_shuttle_turfs)
				new /obj/effect/decal/cleanable/ash(T)

			if(SPIDER_GIFT)
				var/datum/supply_order/O = new /datum/supply_order()
				O.ordernum = supply_shuttle.ordernum
				O.object = new /datum/supply_packs/emergency/specialops()
				O.orderedby = "Spider Clan"
				supply_shuttle.shoppinglist += O

				shuttle_spawns.Add(/mob/living/simple_animal/hostile/giant_spider)
				shuttle_spawns.Add(/mob/living/simple_animal/hostile/giant_spider)
				shuttle_spawns.Add(/mob/living/simple_animal/hostile/giant_spider/nurse)
				if(prob(50))
					shuttle_spawns.Add(/mob/living/simple_animal/hostile/giant_spider/hunter)

				var/turf/T = pick(empty_shuttle_turfs)
				empty_shuttle_turfs.Remove(T)

				new /obj/effect/decal/remains/human(T)
				new /obj/item/clothing/shoes/space_ninja(T)
				new /obj/item/clothing/mask/balaclava(T)

				T = pick(empty_shuttle_turfs)
				new /obj/effect/spider/stickyweb(T)
				T = pick(empty_shuttle_turfs)
				new /obj/effect/spider/stickyweb(T)
				T = pick(empty_shuttle_turfs)
				new /obj/effect/spider/stickyweb(T)
				T = pick(empty_shuttle_turfs)
				new /obj/effect/spider/stickyweb(T)
				T = pick(empty_shuttle_turfs)
				new /obj/effect/spider/stickyweb(T)

			if(DEPARTMENT_RESUPPLY)
				var/list/crate_types = list()

				crate_types.Add(/datum/supply_packs/emergency/evac)
				crate_types.Add(/datum/supply_packs/security/supplies)
				crate_types.Add(/datum/supply_packs/organic/food)
				crate_types.Add(/datum/supply_packs/emergency/weedcontrol)
				crate_types.Add(/datum/supply_packs/engineering/tools)
				crate_types.Add(/datum/supply_packs/engineering/engiequipment)
				crate_types.Add(/datum/supply_packs/science/robotics)
				crate_types.Add(/datum/supply_packs/science/plasma)
				crate_types.Add(/datum/supply_packs/medical/supplies)

				while(crate_types.len > 0)
					var/datum/supply_order/O = new /datum/supply_order()
					O.ordernum = supply_shuttle.ordernum
					O.orderedby = "Centcom"
					supply_shuttle.shoppinglist += O

					var/spawn_type = crate_types[crate_types.len]
					O.object = new spawn_type()
					crate_types.Cut(crate_types.len, crate_types.len + 1)

				for(var/i=0,i<3,i++)
					var/turf/T = pick(empty_shuttle_turfs)
					var/spawn_type = pick(/obj/effect/decal/cleanable/flour, /obj/effect/decal/cleanable/robot_debris, /obj/effect/decal/cleanable/oil)
					new spawn_type(T)

		var/false_positive = 0
		while(shuttle_spawns.len > 0 && empty_shuttle_turfs.len > 0)
			var/turf/T = pick(empty_shuttle_turfs)
			if(T.contents.len && false_positive < 5)
				false_positive++
				continue

			var/spawn_type = shuttle_spawns[1]
			shuttle_spawns.Cut(1, 2)
			empty_shuttle_turfs.Remove(T)
			new spawn_type(T)

		supply_shuttle.buy()
		//supply_shuttle.send()
		//supply_shuttle.moving = 0

#undef HIJACK_SYNDIE
#undef RUSKY_PARTY
#undef SPIDER_GIFT
#undef DEPARTMENT_RESUPPLY
