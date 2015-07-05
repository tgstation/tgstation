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
	announceWhen	= 1

/datum/round_event/shuttle_loan/start()
	dispatch_type = pick(HIJACK_SYNDIE, RUSKY_PARTY, SPIDER_GIFT, DEPARTMENT_RESUPPLY)

/datum/round_event/shuttle_loan/announce()
	SSshuttle.shuttle_loan = src
	switch(dispatch_type)
		if(HIJACK_SYNDIE)
			priority_announce("Cargo: The syndicate are trying to infiltrate your station. If you let them hijack your cargo shuttle, you'll save us a headache.","Centcom Counter Intelligence")
		if(RUSKY_PARTY)
			priority_announce("Cargo: A group of angry russians want to have a party, can you send them your cargo shuttle then make them disappear?","Centcom Russian Outreach Program")
		if(SPIDER_GIFT)
			priority_announce("Cargo: The Spider Clan has sent us a mysterious gift, can we ship it to you to see what's inside?","Centcom Diplomatic Corps")
		if(DEPARTMENT_RESUPPLY)
			priority_announce("Cargo: Seems we've ordered doubles of our department resupply packages this month. Can we send them to you?","Centcom Supply Department")
			thanks_msg = "The shuttle will be returned in 5 minutes."
			bonus_points = 0

/datum/round_event/shuttle_loan/proc/loan_shuttle()
	priority_announce(thanks_msg, "Cargo shuttle commandeered by Centcom.")

	dispatched = 1
	SSshuttle.points += bonus_points
	endWhen = activeFor + 1

	SSshuttle.supply.sell()
	SSshuttle.supply.enterTransit()
	SSshuttle.supply.mode = SHUTTLE_RECALL
	SSshuttle.supply.setTimer(3000)

	switch(dispatch_type)
		if(HIJACK_SYNDIE)
			SSshuttle.centcom_message += "<font color=blue>Syndicate hijack team incoming.</font>"
		if(RUSKY_PARTY)
			SSshuttle.centcom_message += "<font color=blue>Partying Russians incoming.</font>"
		if(SPIDER_GIFT)
			SSshuttle.centcom_message += "<font color=blue>Spider Clan gift incoming.</font>"
		if(DEPARTMENT_RESUPPLY)
			SSshuttle.centcom_message += "<font color=blue>Department resupply incoming.</font>"

/datum/round_event/shuttle_loan/tick()
	if(dispatched)
		if(SSshuttle.supply.mode != SHUTTLE_IDLE)
			endWhen = activeFor
		else
			endWhen = activeFor + 1

//whomever coded this didn't even bother to follow the supply ordering code as an example.
//So I had to waste time rewriting it. Thanks for that >:[
/datum/round_event/shuttle_loan/end()
	if(SSshuttle.shuttle_loan && SSshuttle.shuttle_loan.dispatched)
		//make sure the shuttle was dispatched in time
		SSshuttle.shuttle_loan = null

		var/list/empty_shuttle_turfs = list()
		for(var/turf/simulated/floor/T in SSshuttle.supply.areaInstance)
			if(T.density || T.contents.len)	continue
			empty_shuttle_turfs += T
		if(!empty_shuttle_turfs.len)
			return

		var/list/shuttle_spawns = list()
		switch(dispatch_type)
			if(HIJACK_SYNDIE)
				SSshuttle.generateSupplyOrder(/datum/supply_packs/emergency/specialops, "Syndicate")

				shuttle_spawns.Add(/mob/living/simple_animal/hostile/syndicate)
				shuttle_spawns.Add(/mob/living/simple_animal/hostile/syndicate)
				if(prob(75))
					shuttle_spawns.Add(/mob/living/simple_animal/hostile/syndicate)
				if(prob(50))
					shuttle_spawns.Add(/mob/living/simple_animal/hostile/syndicate)

			if(RUSKY_PARTY)
				SSshuttle.generateSupplyOrder(/datum/supply_packs/organic/party, "Russian Confederation")

				shuttle_spawns.Add(/mob/living/simple_animal/hostile/russian)
				shuttle_spawns.Add(/mob/living/simple_animal/hostile/russian/ranged)	//drops a mateba
				shuttle_spawns.Add(/mob/living/simple_animal/hostile/bear)
				if(prob(75))
					shuttle_spawns.Add(/mob/living/simple_animal/hostile/russian)
				if(prob(50))
					shuttle_spawns.Add(/mob/living/simple_animal/hostile/bear)

			if(SPIDER_GIFT)
				SSshuttle.generateSupplyOrder(/datum/supply_packs/emergency/specialops, "Spider Clan")

				shuttle_spawns.Add(/mob/living/simple_animal/hostile/poison/giant_spider)
				shuttle_spawns.Add(/mob/living/simple_animal/hostile/poison/giant_spider)
				shuttle_spawns.Add(/mob/living/simple_animal/hostile/poison/giant_spider/nurse)
				if(prob(50))
					shuttle_spawns.Add(/mob/living/simple_animal/hostile/poison/giant_spider/hunter)

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
				var/list/crate_types = list(
					/datum/supply_packs/emergency/evac,
					/datum/supply_packs/security/supplies,
					/datum/supply_packs/organic/food,
					/datum/supply_packs/emergency/weedcontrol,
					/datum/supply_packs/engineering/tools,
					/datum/supply_packs/engineering/engiequipment,
					/datum/supply_packs/science/robotics,
					/datum/supply_packs/science/plasma,
					/datum/supply_packs/medical/supplies
					)

				for(var/spawn_type in crate_types)
					SSshuttle.generateSupplyOrder(spawn_type, "Centcom")

				for(var/i=0,i<3,i++)
					var/turf/T = pick(empty_shuttle_turfs)
					var/spawn_type = pick(/obj/effect/decal/cleanable/flour, /obj/effect/decal/cleanable/robot_debris, /obj/effect/decal/cleanable/oil)
					new spawn_type(T)

		var/false_positive = 0
		while(shuttle_spawns.len && empty_shuttle_turfs.len)
			var/turf/T = pick_n_take(empty_shuttle_turfs)
			if(T.contents.len && false_positive < 5)
				false_positive++
				continue

			var/spawn_type = pick_n_take(shuttle_spawns)
			new spawn_type(T)


#undef HIJACK_SYNDIE
#undef RUSKY_PARTY
#undef SPIDER_GIFT
#undef DEPARTMENT_RESUPPLY
