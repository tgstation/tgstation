#define HIJACK_SYNDIE "syndies"
#define RUSKY_PARTY "ruskies"
#define SPIDER_GIFT "spiders"
#define DEPARTMENT_RESUPPLY "resupplies"
#define ANTIDOTE_NEEDED "disease"
#define PIZZA_DELIVERY "pizza"
#define ITS_HIP_TO "bees"
#define MY_GOD_JC "bomb"
#define PAPERS_PLEASE "paperwork"

/datum/round_event_control/shuttle_loan
	name = "Shuttle Loan"
	typepath = /datum/round_event/shuttle_loan
	max_occurrences = 3
	earliest_start = 7 MINUTES
	category = EVENT_CATEGORY_BUREAUCRATIC
	description = "If cargo accepts the offer, fills the shuttle with loot and/or enemies."
	///The types of loan offers that the crew can recieve.
	var/list/shuttle_loan_offers = list(
		ANTIDOTE_NEEDED,
		DEPARTMENT_RESUPPLY,
		HIJACK_SYNDIE,
		ITS_HIP_TO,
		MY_GOD_JC,
		PIZZA_DELIVERY,
		RUSKY_PARTY,
		SPIDER_GIFT,
		PAPERS_PLEASE,
	)
	///The types of loan events already run (and to be excluded if the event triggers).
	var/list/run_events = list()
	///The admin-selected loan offer ID.
	var/chosen_event

/datum/round_event_control/shuttle_loan/can_spawn_event(players_amt)
	. = ..()

	for(var/datum/round_event/running_event in SSevents.running)
		if(istype(running_event, /datum/round_event/shuttle_loan)) //Make sure two of these don't happen at once.
			return FALSE

/datum/round_event_control/shuttle_loan/admin_setup()
	if(!check_rights(R_FUN))
		return ADMIN_CANCEL_EVENT

	if(tgui_alert(usr, "Select a loan offer?", "Trade Offer:", list("Yes", "No")) == "Yes")
		chosen_event = tgui_input_list(usr, "What deal would you like to offer the crew?", "Throw them a bone.", shuttle_loan_offers)

	for(var/datum/round_event/shuttle_loan/loan_event in SSevents.running)
		loan_event.kill() //Force out the old event for a new one to take its place

/datum/round_event/shuttle_loan
	announce_when = 1
	end_when = 500
	var/dispatched = FALSE
	var/dispatch_type = "none"
	var/bonus_points = 10000
	var/thanks_msg = "The cargo shuttle should return in five minutes. Have some supply points for your trouble."
	var/loan_type //for logging

/datum/round_event/shuttle_loan/setup()
	for(var/datum/round_event_control/shuttle_loan/loan_event_control in SSevents.control) //We can't call control, because it hasn't been set yet
		if(loan_event_control.chosen_event) //Pass down the admin selection and clean it for future use.
			dispatch_type = loan_event_control.chosen_event
			loan_event_control.chosen_event = null
		else //Otherwise, generate and pick from the list of offerable offers.
			var/list/loan_list = list()
			loan_list += loan_event_control.shuttle_loan_offers
			var/list/run_events = loan_event_control.run_events //Ask the round_event_control which loans have already been offered
			loan_list -= run_events //Remove the already offered loans from the candidate list
			if(!length(loan_list)) //If we somehow run out of loans, they all become available again
				loan_list += loan_event_control.shuttle_loan_offers
				run_events.Cut()
			dispatch_type = pick(loan_list) //Pick a loan to offer
		loan_event_control.run_events += dispatch_type //Regardless of admin selection, we add the event being run to the run_events list

/datum/round_event/shuttle_loan/announce(fake)
	switch(dispatch_type)
		if(HIJACK_SYNDIE)
			priority_announce("Cargo: The syndicate are trying to infiltrate your station. If you let them hijack your cargo shuttle, you'll save us a headache.","CentCom Counterintelligence")
		if(RUSKY_PARTY)
			priority_announce("Cargo: A group of angry Russians want to have a party. Can you send them your cargo shuttle then make them disappear?","CentCom Russian Outreach Program")
		if(SPIDER_GIFT)
			priority_announce("Cargo: The Spider Clan has sent us a mysterious gift. Can we ship it to you to see what's inside?","CentCom Diplomatic Corps")
		if(DEPARTMENT_RESUPPLY)
			priority_announce("Cargo: Seems we've ordered doubles of our department resupply packages this month. Can we send them to you?","CentCom Supply Department")
			thanks_msg = "The cargo shuttle should return in five minutes."
			bonus_points = 0
		if(ANTIDOTE_NEEDED)
			priority_announce("Cargo: Your station has been chosen for an epidemiological research project. Send us your cargo shuttle to receive your research samples.", "CentCom Research Initiatives")
		if(PIZZA_DELIVERY)
			priority_announce("Cargo: It looks like a neighbouring station accidentally delivered their pizza to you instead.", "CentCom Spacepizza Division")
			thanks_msg = "The cargo shuttle should return in five minutes."
			bonus_points = 0
		if(ITS_HIP_TO)
			priority_announce("Cargo: One of our freighters carrying a bee shipment has been attacked by eco-terrorists. Can you clean up the mess for us?", "CentCom Janitorial Division")
			bonus_points = 20000 //Toxin bees can be unbeelievably lethal
		if(MY_GOD_JC)
			priority_announce("Cargo: We have discovered an active Syndicate bomb near our VIP shuttle's fuel lines. If you feel up to the task, we will pay you for defusing it.", "CentCom Security Division")
			thanks_msg = "Live explosive ordnance incoming via supply shuttle. Evacuating cargo bay is recommended."
			bonus_points = 45000 //If you mess up, people die and the shuttle gets turned into swiss cheese
		if(PAPERS_PLEASE)
			priority_announce("Cargo: A neighboring station needs some help handling some paperwork. Could you help process it for us?", "CentCom Paperwork Division")
			thanks_msg = "The cargo shuttle should return in five minutes. Payment will be rendered when the paperwork is processed and returned."
			bonus_points = 0 //Payout is made when the stamped papers are returned
		else
			log_game("Shuttle Loan event could not find [dispatch_type] event to offer.")
			kill()
			return
	SSshuttle.shuttle_loan = src

/datum/round_event/shuttle_loan/proc/loan_shuttle()
	priority_announce(thanks_msg, "Cargo shuttle commandeered by CentCom.")

	dispatched = TRUE
	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
	if(D)
		D.adjust_money(bonus_points)
	end_when = activeFor + 1

	SSshuttle.supply.mode = SHUTTLE_CALL
	SSshuttle.supply.destination = SSshuttle.getDock("cargo_home")
	SSshuttle.supply.setTimer(3000)

	switch(dispatch_type)
		if(HIJACK_SYNDIE)
			SSshuttle.centcom_message += "Syndicate hijack team incoming."
			loan_type = "Syndicate boarding party"
		if(RUSKY_PARTY)
			SSshuttle.centcom_message += "Partying Russians incoming."
			loan_type = "Russian party squad"
		if(SPIDER_GIFT)
			SSshuttle.centcom_message += "Spider Clan gift incoming."
			loan_type = "Shuttle full of spiders"
		if(DEPARTMENT_RESUPPLY)
			SSshuttle.centcom_message += "Department resupply incoming."
			loan_type = "Resupply packages"
		if(ANTIDOTE_NEEDED)
			SSshuttle.centcom_message += "Virus samples incoming."
			loan_type = "Virus shuttle"
		if(PIZZA_DELIVERY)
			SSshuttle.centcom_message += "Pizza delivery for [station_name()]"
			loan_type = "Pizza delivery"
		if(ITS_HIP_TO)
			SSshuttle.centcom_message += "Biohazard cleanup incoming."
			loan_type = "Shuttle full of bees"
		if(MY_GOD_JC)
			SSshuttle.centcom_message += "Live explosive ordnance incoming. Exercise extreme caution."
			loan_type = "Shuttle with a ticking bomb"
		if(PAPERS_PLEASE)
			SSshuttle.centcom_message += "Paperwork incoming."
			loan_type = "Paperwork shipment"

	log_game("Shuttle loan event firing with type '[loan_type]'.")

/datum/round_event/shuttle_loan/tick()
	if(dispatched)
		if(SSshuttle.supply.mode != SHUTTLE_IDLE)
			end_when = activeFor
		else
			end_when = activeFor + 1

/datum/round_event/shuttle_loan/end()
	if(SSshuttle.shuttle_loan && SSshuttle.shuttle_loan.dispatched)
		//make sure the shuttle was dispatched in time
		SSshuttle.shuttle_loan = null

		var/list/empty_shuttle_turfs = list()
		var/list/area/shuttle/shuttle_areas = SSshuttle.supply.shuttle_areas
		for(var/place in shuttle_areas)
			var/area/shuttle/shuttle_area = place
			for(var/turf/open/floor/T in shuttle_area)
				if(T.is_blocked_turf())
					continue
				empty_shuttle_turfs += T
		if(!empty_shuttle_turfs.len)
			return

		var/list/shuttle_spawns = list()
		switch(dispatch_type)
			if(HIJACK_SYNDIE)
				var/datum/supply_pack/pack = SSshuttle.supply_packs[/datum/supply_pack/emergency/specialops]
				pack.generate(pick_n_take(empty_shuttle_turfs))

				shuttle_spawns.Add(/mob/living/basic/syndicate/ranged/infiltrator)
				shuttle_spawns.Add(/mob/living/basic/syndicate/ranged/infiltrator)
				if(prob(75))
					shuttle_spawns.Add(/mob/living/basic/syndicate/ranged/infiltrator)
				if(prob(50))
					shuttle_spawns.Add(/mob/living/basic/syndicate/ranged/infiltrator)

			if(RUSKY_PARTY)
				var/datum/supply_pack/pack = SSshuttle.supply_packs[/datum/supply_pack/service/party]
				pack.generate(pick_n_take(empty_shuttle_turfs))

				shuttle_spawns.Add(/mob/living/simple_animal/hostile/russian)
				shuttle_spawns.Add(/mob/living/simple_animal/hostile/russian/ranged) //drops a mateba
				shuttle_spawns.Add(/mob/living/simple_animal/hostile/bear/russian)
				if(prob(75))
					shuttle_spawns.Add(/mob/living/simple_animal/hostile/russian)
				if(prob(50))
					shuttle_spawns.Add(/mob/living/simple_animal/hostile/bear/russian)

			if(SPIDER_GIFT)
				var/datum/supply_pack/pack = SSshuttle.supply_packs[/datum/supply_pack/emergency/specialops]
				pack.generate(pick_n_take(empty_shuttle_turfs))

				shuttle_spawns.Add(/mob/living/simple_animal/hostile/giant_spider)
				shuttle_spawns.Add(/mob/living/simple_animal/hostile/giant_spider)
				shuttle_spawns.Add(/mob/living/simple_animal/hostile/giant_spider/nurse)
				if(prob(50))
					shuttle_spawns.Add(/mob/living/simple_animal/hostile/giant_spider/hunter)

				var/turf/T = pick_n_take(empty_shuttle_turfs)

				new /obj/effect/decal/remains/human(T)
				new /obj/item/clothing/shoes/jackboots/fast(T)
				new /obj/item/clothing/mask/balaclava(T)

				for(var/i in 1 to 5)
					T = pick_n_take(empty_shuttle_turfs)
					new /obj/structure/spider/stickyweb(T)

			if(ANTIDOTE_NEEDED)
				var/obj/effect/mob_spawn/corpse/human/assistant/infected_assistant = pick(/obj/effect/mob_spawn/corpse/human/assistant/beesease_infection, /obj/effect/mob_spawn/corpse/human/assistant/brainrot_infection, /obj/effect/mob_spawn/corpse/human/assistant/spanishflu_infection)
				var/turf/T
				for(var/i in 1 to 10)
					if(prob(15))
						shuttle_spawns.Add(/obj/item/reagent_containers/cup/bottle)
					else if(prob(15))
						shuttle_spawns.Add(/obj/item/reagent_containers/syringe)
					else if(prob(25))
						shuttle_spawns.Add(/obj/item/shard)
					T = pick_n_take(empty_shuttle_turfs)
					new infected_assistant(T)
				shuttle_spawns.Add(/obj/structure/closet/crate)
				shuttle_spawns.Add(/obj/item/reagent_containers/cup/bottle/pierrot_throat)
				shuttle_spawns.Add(/obj/item/reagent_containers/cup/bottle/magnitis)

			if(DEPARTMENT_RESUPPLY)
				var/list/crate_types = list(
					/datum/supply_pack/emergency/equipment,
					/datum/supply_pack/security/supplies,
					/datum/supply_pack/organic/food,
					/datum/supply_pack/emergency/weedcontrol,
					/datum/supply_pack/engineering/tools,
					/datum/supply_pack/engineering/engiequipment,
					/datum/supply_pack/science/robotics,
					/datum/supply_pack/science/plasma,
					/datum/supply_pack/medical/supplies
					)
				for(var/crate in crate_types)
					var/datum/supply_pack/pack = SSshuttle.supply_packs[crate]
					pack.generate(pick_n_take(empty_shuttle_turfs))

				for(var/i in 1 to 5)
					var/decal = pick(/obj/effect/decal/cleanable/food/flour, /obj/effect/decal/cleanable/robot_debris, /obj/effect/decal/cleanable/oil)
					new decal(pick_n_take(empty_shuttle_turfs))
			if(PIZZA_DELIVERY)
				var/naughtypizza = list(/obj/item/pizzabox/bomb,/obj/item/pizzabox/margherita/robo) //oh look another blaklist, for pizza nonetheless!
				var/nicepizza = list(/obj/item/pizzabox/margherita, /obj/item/pizzabox/meat, /obj/item/pizzabox/vegetable, /obj/item/pizzabox/mushroom)
				for(var/i in 1 to 6)
					shuttle_spawns.Add(pick(prob(5) ? naughtypizza : nicepizza))
			if(ITS_HIP_TO)
				var/datum/supply_pack/pack = SSshuttle.supply_packs[/datum/supply_pack/organic/hydroponics/beekeeping_fullkit]
				pack.generate(pick_n_take(empty_shuttle_turfs))

				shuttle_spawns.Add(/obj/effect/mob_spawn/corpse/human/bee_terrorist)
				shuttle_spawns.Add(/obj/effect/mob_spawn/corpse/human/cargo_tech)
				shuttle_spawns.Add(/obj/effect/mob_spawn/corpse/human/cargo_tech)
				shuttle_spawns.Add(/obj/effect/mob_spawn/corpse/human/nanotrasensoldier)
				shuttle_spawns.Add(/obj/item/gun/ballistic/automatic/pistol/no_mag)
				shuttle_spawns.Add(/obj/item/gun/ballistic/automatic/pistol/m1911/no_mag)
				shuttle_spawns.Add(/obj/item/honey_frame)
				shuttle_spawns.Add(/obj/item/honey_frame)
				shuttle_spawns.Add(/obj/item/honey_frame)
				shuttle_spawns.Add(/obj/structure/beebox/unwrenched)
				shuttle_spawns.Add(/obj/item/queen_bee/bought)
				shuttle_spawns.Add(/obj/structure/closet/crate/hydroponics)

				for(var/i in 1 to 8)
					shuttle_spawns.Add(/mob/living/simple_animal/hostile/bee/toxin)

				for(var/i in 1 to 5)
					var/decal = pick(/obj/effect/decal/cleanable/blood, /obj/effect/decal/cleanable/insectguts)
					new decal(pick_n_take(empty_shuttle_turfs))

				for(var/i in 1 to 10)
					var/casing = /obj/item/ammo_casing/spent
					new casing(pick_n_take(empty_shuttle_turfs))

			if(MY_GOD_JC)
				shuttle_spawns.Add(/obj/machinery/syndicatebomb/shuttle_loan)
				if(prob(95))
					shuttle_spawns.Add(/obj/item/paper/fluff/cargo/bomb)
				else
					shuttle_spawns.Add(/obj/item/paper/fluff/cargo/bomb/allyourbase)

			if(PAPERS_PLEASE)
				shuttle_spawns += subtypesof(/obj/item/paperwork) - typesof(/obj/item/paperwork/photocopy) - typesof(/obj/item/paperwork/ancient)

		var/false_positive = 0
		while(shuttle_spawns.len && empty_shuttle_turfs.len)
			var/turf/T = pick_n_take(empty_shuttle_turfs)
			if(T.contents.len && false_positive < 5)
				false_positive++
				continue

			var/spawn_type = pick_n_take(shuttle_spawns)
			new spawn_type(T)

//items that appear only in shuttle loan events

/obj/item/storage/belt/fannypack/yellow/bee_terrorist/PopulateContents()
	new /obj/item/grenade/c4 (src)
	new /obj/item/reagent_containers/pill/cyanide(src)
	new /obj/item/grenade/chem_grenade/facid(src)

/obj/item/paper/fluff/bee_objectives
	name = "Objectives of a Bee Liberation Front Operative"
	default_raw_text = "<b>Objective #1</b>. Liberate all bees on the NT transport vessel 2416/B. <b>Success!</b>  <br><b>Objective #2</b>. Escape alive. <b>Failed.</b>"

/obj/machinery/syndicatebomb/shuttle_loan/Initialize(mapload)
	. = ..()
	set_anchored(TRUE)
	timer_set = rand(480, 600) //once the supply shuttle docks (after 5 minutes travel time), players have between 3-5 minutes to defuse the bomb
	activate()
	update_appearance()

/obj/item/paper/fluff/cargo/bomb
	name = "hastly scribbled note"
	default_raw_text = "GOOD LUCK!"

/obj/item/paper/fluff/cargo/bomb/allyourbase
	default_raw_text = "Somebody set us up the bomb!"

#undef HIJACK_SYNDIE
#undef RUSKY_PARTY
#undef SPIDER_GIFT
#undef DEPARTMENT_RESUPPLY
#undef ANTIDOTE_NEEDED
#undef PIZZA_DELIVERY
#undef ITS_HIP_TO
#undef MY_GOD_JC
