/// One of the potential shuttle loans you might recieve.
/datum/shuttle_loan_situation
	/// Who sent the shuttle
	var/sender = "Centcom"
	/// What they said about it.
	var/announcement_text = "Unset announcement text"
	/// What the shuttle says about it.
	var/shuttle_transit_text = "Unset transit text"
	/// Supply points earned for taking the deal.
	var/bonus_points = 10000
	/// Response for taking the deal.
	var/thanks_msg = "The cargo shuttle should return in five minutes. Have some supply points for your trouble."
	/// Small description of the loan for easier log reading.
	var/logging_desc

/datum/shuttle_loan_situation/New()
	. = ..()
	if(!logging_desc)
		stack_trace("No logging blurb set for [src.type]!")

/// Spawns paths added to `spawn_list`, and passes empty shuttle turfs so you can spawn more complicated things like dead bodies.
/datum/shuttle_loan_situation/proc/spawn_items(list/spawn_list, list/empty_shuttle_turfs)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("Unimplemented get_spawned_items() on [src.type].")

/datum/shuttle_loan_situation/antidote
	sender = "CentCom Research Initiatives"
	announcement_text = "Your station has been chosen for an epidemiological research project. Send us your cargo shuttle to receive your research samples."
	shuttle_transit_text = "Virus samples incoming."
	logging_desc = "Virus shuttle"

/datum/shuttle_loan_situation/antidote/spawn_items(list/spawn_list, list/empty_shuttle_turfs)
	var/obj/effect/mob_spawn/corpse/human/assistant/infected_assistant = pick(list(
		/obj/effect/mob_spawn/corpse/human/assistant/beesease_infection,
		/obj/effect/mob_spawn/corpse/human/assistant/brainrot_infection,
		/obj/effect/mob_spawn/corpse/human/assistant/spanishflu_infection,
	))
	for(var/i in 1 to 10)
		if(prob(15))
			spawn_list.Add(/obj/item/reagent_containers/cup/bottle)
		else if(prob(15))
			spawn_list.Add(/obj/item/reagent_containers/syringe)
		else if(prob(25))
			spawn_list.Add(/obj/item/shard)
		var/turf/assistant_turf = pick_n_take(empty_shuttle_turfs)
		new infected_assistant(assistant_turf)
	spawn_list.Add(/obj/structure/closet/crate)
	spawn_list.Add(/obj/item/reagent_containers/cup/bottle/pierrot_throat)
	spawn_list.Add(/obj/item/reagent_containers/cup/bottle/magnitis)

/datum/shuttle_loan_situation/department_resupply
	sender = "CentCom Supply Department"
	announcement_text = "Seems we've ordered doubles of our department resupply packages this month. Can we send them to you?"
	shuttle_transit_text = "Department resupply incoming."
	thanks_msg = "The cargo shuttle should return in five minutes."
	bonus_points = 0
	logging_desc = "Resupply packages"

/datum/shuttle_loan_situation/department_resupply/spawn_items(list/spawn_list, list/empty_shuttle_turfs)
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

/datum/shuttle_loan_situation/department_resupply
	sender = "CentCom Counterintelligence"
	announcement_text = "The syndicate are trying to infiltrate your station. If you let them hijack your cargo shuttle, you'll save us a headache."
	shuttle_transit_text = "Syndicate hijack team incoming."
	logging_desc = "Syndicate boarding party"

/datum/shuttle_loan_situation/department_resupply/spawn_items(list/spawn_list, list/empty_shuttle_turfs)
	var/datum/supply_pack/pack = SSshuttle.supply_packs[/datum/supply_pack/emergency/specialops]
	pack.generate(pick_n_take(empty_shuttle_turfs))

	spawn_list.Add(/mob/living/basic/syndicate/ranged/infiltrator)
	spawn_list.Add(/mob/living/basic/syndicate/ranged/infiltrator)
	if(prob(75))
		spawn_list.Add(/mob/living/basic/syndicate/ranged/infiltrator)
	if(prob(50))
		spawn_list.Add(/mob/living/basic/syndicate/ranged/infiltrator)

/datum/shuttle_loan_situation/lots_of_bees
	sender = "CentCom Janitorial Division"
	announcement_text = "One of our freighters carrying a bee shipment has been attacked by eco-terrorists. Can you clean up the mess for us?"
	shuttle_transit_text = "Biohazard cleanup incoming."
	bonus_points = 20000 //Toxin bees can be unbeelievably lethal
	logging_desc = "Shuttle full of bees"

/datum/shuttle_loan_situation/lots_of_bees/spawn_items(list/spawn_list, list/empty_shuttle_turfs)
	var/datum/supply_pack/pack = SSshuttle.supply_packs[/datum/supply_pack/organic/hydroponics/beekeeping_fullkit]
	pack.generate(pick_n_take(empty_shuttle_turfs))

	spawn_list.Add(/obj/effect/mob_spawn/corpse/human/bee_terrorist)
	spawn_list.Add(/obj/effect/mob_spawn/corpse/human/cargo_tech)
	spawn_list.Add(/obj/effect/mob_spawn/corpse/human/cargo_tech)
	spawn_list.Add(/obj/effect/mob_spawn/corpse/human/nanotrasensoldier)
	spawn_list.Add(/obj/item/gun/ballistic/automatic/pistol/no_mag)
	spawn_list.Add(/obj/item/gun/ballistic/automatic/pistol/m1911/no_mag)
	spawn_list.Add(/obj/item/honey_frame)
	spawn_list.Add(/obj/item/honey_frame)
	spawn_list.Add(/obj/item/honey_frame)
	spawn_list.Add(/obj/structure/beebox/unwrenched)
	spawn_list.Add(/obj/item/queen_bee/bought)
	spawn_list.Add(/obj/structure/closet/crate/hydroponics)

	for(var/i in 1 to 8)
		spawn_list.Add(/mob/living/simple_animal/hostile/bee/toxin)

	for(var/i in 1 to 5)
		var/decal = pick(/obj/effect/decal/cleanable/blood, /obj/effect/decal/cleanable/insectguts)
		new decal(pick_n_take(empty_shuttle_turfs))

	for(var/i in 1 to 10)
		var/casing = /obj/item/ammo_casing/spent
		new casing(pick_n_take(empty_shuttle_turfs))

/datum/shuttle_loan_situation/jc_a_bomb
	sender = "CentCom Security Division"
	announcement_text = "We have discovered an active Syndicate bomb near our VIP shuttle's fuel lines. If you feel up to the task, we will pay you for defusing it."
	shuttle_transit_text = "Live explosive ordnance incoming. Exercise extreme caution."
	thanks_msg = "Live explosive ordnance incoming via supply shuttle. Evacuating cargo bay is recommended."
	bonus_points = 45000 //If you mess up, people die and the shuttle gets turned into swiss cheese
	logging_desc = "Shuttle with a ticking bomb"

/datum/shuttle_loan_situation/jc_a_bomb/spawn_items(list/spawn_list, list/empty_shuttle_turfs)
	spawn_list.Add(/obj/machinery/syndicatebomb/shuttle_loan)
	if(prob(95))
		spawn_list.Add(/obj/item/paper/fluff/cargo/bomb)
	else
		spawn_list.Add(/obj/item/paper/fluff/cargo/bomb/allyourbase)

/datum/shuttle_loan_situation/papers_please
	sender = "CentCom Paperwork Division"
	announcement_text = "A neighboring station needs some help handling some paperwork. Could you help process it for us?"
	shuttle_transit_text = "Paperwork incoming."
	thanks_msg = "The cargo shuttle should return in five minutes. Payment will be rendered when the paperwork is processed and returned."
	bonus_points = 0 //Payout is made when the stamped papers are returned
	logging_desc = "Paperwork shipment"

/datum/shuttle_loan_situation/papers_please/spawn_items(list/spawn_list, list/empty_shuttle_turfs)
	spawn_list += subtypesof(/obj/item/paperwork) - typesof(/obj/item/paperwork/photocopy) - typesof(/obj/item/paperwork/ancient)

/datum/shuttle_loan_situation/pizza_delivery
	sender = "CentCom Spacepizza Division"
	announcement_text = "It looks like a neighbouring station accidentally delivered their pizza to you instead."
	shuttle_transit_text = "Pizza delivery!"
	thanks_msg = "The cargo shuttle should return in five minutes."
	bonus_points = 0
	logging_desc = "Pizza delivery"

/datum/shuttle_loan_situation/pizza_delivery/spawn_items(list/spawn_list, list/empty_shuttle_turfs)
	var/naughtypizza = list(/obj/item/pizzabox/bomb, /obj/item/pizzabox/margherita/robo) //oh look another blacklist, for pizza nonetheless!
	var/nicepizza = list(/obj/item/pizzabox/margherita, /obj/item/pizzabox/meat, /obj/item/pizzabox/vegetable, /obj/item/pizzabox/mushroom)
	for(var/i in 1 to 6)
		spawn_list.Add(pick(prob(5) ? naughtypizza : nicepizza))

/datum/shuttle_loan_situation/russian_party
	sender = "CentCom Russian Outreach Program"
	announcement_text = "A group of angry Russians want to have a party. Can you send them your cargo shuttle then make them disappear?"
	shuttle_transit_text = "Partying Russians incoming."
	logging_desc = "Russian party squad"

/datum/shuttle_loan_situation/russian_party/spawn_items(list/spawn_list, list/empty_shuttle_turfs)
	var/datum/supply_pack/pack = SSshuttle.supply_packs[/datum/supply_pack/service/party]
	pack.generate(pick_n_take(empty_shuttle_turfs))

	spawn_list.Add(/mob/living/simple_animal/hostile/russian)
	spawn_list.Add(/mob/living/simple_animal/hostile/russian/ranged) //drops a mateba
	spawn_list.Add(/mob/living/simple_animal/hostile/bear/russian)
	if(prob(75))
		spawn_list.Add(/mob/living/simple_animal/hostile/russian)
	if(prob(50))
		spawn_list.Add(/mob/living/simple_animal/hostile/bear/russian)

/datum/shuttle_loan_situation/spider_gift
	sender = "CentCom Diplomatic Corps"
	announcement_text = "The Spider Clan has sent us a mysterious gift. Can we ship it to you to see what's inside?"
	shuttle_transit_text = "Spider Clan gift incoming."
	logging_desc = "Shuttle full of spiders"

/datum/shuttle_loan_situation/spider_gift/spawn_items(list/spawn_list, list/empty_shuttle_turfs)
	var/datum/supply_pack/pack = SSshuttle.supply_packs[/datum/supply_pack/emergency/specialops]
	pack.generate(pick_n_take(empty_shuttle_turfs))

	spawn_list.Add(/mob/living/basic/giant_spider)
	spawn_list.Add(/mob/living/basic/giant_spider)
	spawn_list.Add(/mob/living/basic/giant_spider/nurse)
	if(prob(50))
		spawn_list.Add(/mob/living/basic/giant_spider/hunter)

	var/turf/victim_turf = pick_n_take(empty_shuttle_turfs)

	new /obj/effect/decal/remains/human(victim_turf)
	new /obj/item/clothing/shoes/jackboots/fast(victim_turf)
	new /obj/item/clothing/mask/balaclava(victim_turf)

	for(var/i in 1 to 5)
		var/turf/web_turf = pick_n_take(empty_shuttle_turfs)
		new /obj/structure/spider/stickyweb(web_turf)
