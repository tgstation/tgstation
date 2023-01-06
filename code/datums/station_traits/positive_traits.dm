#define PARTY_COOLDOWN_LENGTH_MIN (6 MINUTES)
#define PARTY_COOLDOWN_LENGTH_MAX (12 MINUTES)


/datum/station_trait/lucky_winner
	name = "Lucky winner"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 1
	show_in_report = TRUE
	report_message = "Your station has won the grand prize of the annual station charity event. Free snacks will be delivered to the bar every now and then."
	trait_processes = TRUE
	COOLDOWN_DECLARE(party_cooldown)

/datum/station_trait/lucky_winner/on_round_start()
	. = ..()
	COOLDOWN_START(src, party_cooldown, rand(PARTY_COOLDOWN_LENGTH_MIN, PARTY_COOLDOWN_LENGTH_MAX))

/datum/station_trait/lucky_winner/process(delta_time)
	if(!COOLDOWN_FINISHED(src, party_cooldown))
		return

	COOLDOWN_START(src, party_cooldown, rand(PARTY_COOLDOWN_LENGTH_MIN, PARTY_COOLDOWN_LENGTH_MAX))

	var/area/area_to_spawn_in = pick(GLOB.bar_areas)
	var/turf/T = pick(area_to_spawn_in.contents)

	var/obj/structure/closet/supplypod/centcompod/toLaunch = new()
	var/obj/item/pizzabox/pizza_to_spawn = pick(list(/obj/item/pizzabox/margherita, /obj/item/pizzabox/mushroom, /obj/item/pizzabox/meat, /obj/item/pizzabox/vegetable, /obj/item/pizzabox/pineapple))
	new pizza_to_spawn(toLaunch)
	for(var/i in 1 to 6)
		new /obj/item/reagent_containers/cup/glass/bottle/beer(toLaunch)
	new /obj/effect/pod_landingzone(T, toLaunch)

/datum/station_trait/galactic_grant
	name = "Galactic grant"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Your station has been selected for a special grant. Some extra funds has been made available to your cargo department."

/datum/station_trait/galactic_grant/on_round_start()
	var/datum/bank_account/cargo_bank = SSeconomy.get_dep_account(ACCOUNT_CAR)
	cargo_bank.adjust_money(rand(2000, 5000))

/datum/station_trait/premium_internals_box
	name = "Premium internals boxes"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "The internals boxes for your crew have been upsized and filled with bonus equipment."
	trait_to_give = STATION_TRAIT_PREMIUM_INTERNALS

/datum/station_trait/bountiful_bounties
	name = "Bountiful bounties"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "It seems collectors in this system are extra keen to on bounties, and will pay more to see their completion."

/datum/station_trait/bountiful_bounties/on_round_start()
	SSeconomy.bounty_modifier *= 1.2

/datum/station_trait/strong_supply_lines
	name = "Strong supply lines"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Prices are low in this system, BUY BUY BUY!"
	blacklist = list(/datum/station_trait/distant_supply_lines)


/datum/station_trait/strong_supply_lines/on_round_start()
	SSeconomy.pack_price_modifier *= 0.8

/datum/station_trait/scarves
	name = "Scarves"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	var/list/scarves

/datum/station_trait/scarves/New()
	. = ..()
	report_message = pick(
		"Nanotrasen is experimenting with seeing if neck warmth improves employee morale.",
		"After Space Fashion Week, scarves are the hot new accessory.",
		"Everyone was simultaneously a little bit cold when they packed to go to the station.",
		"The station is definitely not under attack by neck grappling aliens masquerading as wool. Definitely not.",
		"You all get free scarves. Don't ask why.",
		"A shipment of scarves was delivered to the station.",
	)
	scarves = typesof(/obj/item/clothing/neck/scarf) + list(
		/obj/item/clothing/neck/large_scarf/red,
		/obj/item/clothing/neck/large_scarf/green,
		/obj/item/clothing/neck/large_scarf/blue,
	)

	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))


/datum/station_trait/scarves/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER
	var/scarf_type = pick(scarves)

	spawned.equip_to_slot_or_del(new scarf_type(spawned), ITEM_SLOT_NECK, initial = FALSE)


/datum/station_trait/filled_maint
	name = "Filled up maintenance"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Our workers accidentally forgot more of their personal belongings in the maintenace areas."
	blacklist = list(/datum/station_trait/empty_maint)
	trait_to_give = STATION_TRAIT_FILLED_MAINT

	// This station trait is checked when loot drops initialize, so it's too late
	can_revert = FALSE

/datum/station_trait/quick_shuttle
	name = "Quick Shuttle"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Due to proximity to our supply station, the cargo shuttle will have a quicker flight time to your cargo department."
	blacklist = list(/datum/station_trait/slow_shuttle)

/datum/station_trait/quick_shuttle/on_round_start()
	. = ..()
	SSshuttle.supply.callTime *= 0.5

/datum/station_trait/deathrattle_department
	name = "deathrattled department"
	trait_type = STATION_TRAIT_POSITIVE
	show_in_report = TRUE
	trait_flags = STATION_TRAIT_ABSTRACT
	blacklist = list(/datum/station_trait/deathrattle_all)

	var/department_to_apply_to
	var/department_name = "department"
	var/datum/deathrattle_group/deathrattle_group

/datum/station_trait/deathrattle_department/New()
	. = ..()
	deathrattle_group = new("[department_name] group")
	blacklist += subtypesof(/datum/station_trait/deathrattle_department) - type //All but ourselves
	report_message = "All members of [department_name] have received an implant to notify each other if one of them dies. This should help improve job-safety!"
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))


/datum/station_trait/deathrattle_department/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER

	if(!(job.departments_bitflags & department_to_apply_to))
		return

	var/obj/item/implant/deathrattle/implant_to_give = new()
	deathrattle_group.register(implant_to_give)
	implant_to_give.implant(spawned, spawned, TRUE, TRUE)


/datum/station_trait/deathrattle_department/service
	name = "Deathrattled Service"
	trait_flags = NONE
	weight = 1
	department_to_apply_to = DEPARTMENT_BITFLAG_SERVICE
	department_name = "Service"

/datum/station_trait/deathrattle_department/cargo
	name = "Deathrattled Cargo"
	trait_flags = NONE
	weight = 1
	department_to_apply_to = DEPARTMENT_BITFLAG_CARGO
	department_name = "Cargo"

/datum/station_trait/deathrattle_department/engineering
	name = "Deathrattled Engineering"
	trait_flags = NONE
	weight = 1
	department_to_apply_to = DEPARTMENT_BITFLAG_ENGINEERING
	department_name = "Engineering"

/datum/station_trait/deathrattle_department/command
	name = "Deathrattled Command"
	trait_flags = NONE
	weight = 1
	department_to_apply_to = DEPARTMENT_BITFLAG_COMMAND
	department_name = "Command"

/datum/station_trait/deathrattle_department/science
	name = "Deathrattled Science"
	trait_flags = NONE
	weight = 1
	department_to_apply_to = DEPARTMENT_BITFLAG_SCIENCE
	department_name = "Science"

/datum/station_trait/deathrattle_department/security
	name = "Deathrattled Security"
	trait_flags = NONE
	weight = 1
	department_to_apply_to = DEPARTMENT_BITFLAG_SECURITY
	department_name = "Security"

/datum/station_trait/deathrattle_department/medical
	name = "Deathrattled Medical"
	trait_flags = NONE
	weight = 1
	department_to_apply_to = DEPARTMENT_BITFLAG_MEDICAL
	department_name = "Medical"

/datum/station_trait/deathrattle_all
	name = "Deathrattled Station"
	trait_type = STATION_TRAIT_POSITIVE
	show_in_report = TRUE
	weight = 1
	report_message = "All members of the station have received an implant to notify each other if one of them dies. This should help improve job-safety!"
	var/datum/deathrattle_group/deathrattle_group


/datum/station_trait/deathrattle_all/New()
	. = ..()
	deathrattle_group = new("station group")
	blacklist = subtypesof(/datum/station_trait/deathrattle_department)
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))


/datum/station_trait/deathrattle_all/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER

	var/obj/item/implant/deathrattle/implant_to_give = new()
	deathrattle_group.register(implant_to_give)
	implant_to_give.implant(spawned, spawned, TRUE, TRUE)


/datum/station_trait/wallets
	name = "Wallets!"
	trait_type = STATION_TRAIT_POSITIVE
	show_in_report = TRUE
	weight = 10
	report_message = "It has become temporarily fashionable to use a wallet, so everyone on the station has been issued one."

/datum/station_trait/wallets/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))

/datum/station_trait/wallets/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/living_mob, mob/M, joined_late)
	SIGNAL_HANDLER

	var/obj/item/card/id/advanced/id_card = living_mob.get_item_by_slot(ITEM_SLOT_ID)
	if(!istype(id_card))
		return

	living_mob.temporarilyRemoveItemFromInventory(id_card, force=TRUE)

	// "Doc, what's wrong with me?"
	var/obj/item/storage/wallet/wallet = new(src)
	// "You've got a wallet embedded in your chest."
	wallet.add_fingerprint(living_mob, ignoregloves = TRUE)

	living_mob.equip_to_slot_if_possible(wallet, ITEM_SLOT_ID, initial=TRUE)

	id_card.forceMove(wallet)

	var/holochip_amount = id_card.registered_account.account_balance
	new /obj/item/holochip(wallet, holochip_amount)
	id_card.registered_account.adjust_money(-holochip_amount, "System: Withdrawal")

	new /obj/effect/spawner/random/entertainment/wallet_storage(wallet)

	// Put our filthy fingerprints all over the contents
	for(var/obj/item/item in wallet)
		item.add_fingerprint(living_mob, ignoregloves = TRUE)

/datum/station_trait/cybernetic_revolution
	name = "Cybernetic Revolution"
	trait_type = STATION_TRAIT_POSITIVE
	show_in_report = TRUE
	weight = 1
	report_message = "The new trends in cybernetics have come to the station! Everyone has some form of cybernetic implant."
	trait_to_give = STATION_TRAIT_CYBERNETIC_REVOLUTION
	/// List of all job types with the cybernetics they should receive.
	var/static/list/job_to_cybernetic = list(
		/datum/job/assistant = /obj/item/organ/internal/heart/cybernetic, //real cardiac
		/datum/job/atmospheric_technician = /obj/item/organ/internal/cyberimp/mouth/breathing_tube,
		/datum/job/bartender = /obj/item/organ/internal/liver/cybernetic/tier3,
		/datum/job/botanist = /obj/item/organ/internal/cyberimp/chest/nutriment,
		/datum/job/captain = /obj/item/organ/internal/heart/cybernetic/tier3,
		/datum/job/cargo_technician = /obj/item/organ/internal/stomach/cybernetic/tier2,
		/datum/job/chaplain = /obj/item/organ/internal/cyberimp/brain/anti_drop,
		/datum/job/chemist = /obj/item/organ/internal/liver/cybernetic/tier2,
		/datum/job/chief_engineer = /obj/item/organ/internal/cyberimp/chest/thrusters,
		/datum/job/chief_medical_officer = /obj/item/organ/internal/cyberimp/chest/reviver,
		/datum/job/clown = /obj/item/organ/internal/cyberimp/brain/anti_stun, //HONK!
		/datum/job/cook = /obj/item/organ/internal/cyberimp/chest/nutriment/plus,
		/datum/job/curator = /obj/item/organ/internal/eyes/robotic/glow,
		/datum/job/detective = /obj/item/organ/internal/lungs/cybernetic/tier3,
		/datum/job/doctor = /obj/item/organ/internal/cyberimp/arm/surgery,
		/datum/job/geneticist = /obj/item/organ/internal/fly, //we don't care about implants, we have cancer.
		/datum/job/head_of_personnel = /obj/item/organ/internal/eyes/robotic,
		/datum/job/head_of_security = /obj/item/organ/internal/eyes/robotic/thermals,
		/datum/job/janitor = /obj/item/organ/internal/eyes/robotic/xray,
		/datum/job/lawyer = /obj/item/organ/internal/heart/cybernetic/tier2,
		/datum/job/mime = /obj/item/organ/internal/tongue/robot, //...
		/datum/job/paramedic = /obj/item/organ/internal/cyberimp/eyes/hud/medical,
		/datum/job/prisoner = /obj/item/organ/internal/eyes/robotic/shield,
		/datum/job/psychologist = /obj/item/organ/internal/ears/cybernetic/upgraded,
		/datum/job/quartermaster = /obj/item/organ/internal/stomach/cybernetic/tier3,
		/datum/job/research_director = /obj/item/organ/internal/cyberimp/bci,
		/datum/job/roboticist = /obj/item/organ/internal/cyberimp/eyes/hud/diagnostic,
		/datum/job/scientist = /obj/item/organ/internal/ears/cybernetic,
		/datum/job/security_officer = /obj/item/organ/internal/cyberimp/arm/flash,
		/datum/job/shaft_miner = /obj/item/organ/internal/monster_core/rush_gland,
		/datum/job/station_engineer = /obj/item/organ/internal/cyberimp/arm/toolset,
		/datum/job/virologist = /obj/item/organ/internal/lungs/cybernetic/tier2,
		/datum/job/warden = /obj/item/organ/internal/cyberimp/eyes/hud/security,
	)

/datum/station_trait/cybernetic_revolution/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))

/datum/station_trait/cybernetic_revolution/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER

	var/datum/quirk/body_purist/body_purist = /datum/quirk/body_purist
	if(initial(body_purist.name) in player_client.prefs.all_quirks)
		return
	var/cybernetic_type = job_to_cybernetic[job.type]
	if(!cybernetic_type)
		if(isAI(spawned))
			var/mob/living/silicon/ai/ai = spawned
			ai.eyeobj.relay_speech = TRUE //surveillance upgrade. the ai gets cybernetics too.
		return
	var/obj/item/organ/internal/cybernetic = new cybernetic_type()
	cybernetic.Insert(spawned, special = TRUE, drop_if_replaced = FALSE)

/datum/station_trait/luxury_escape_pods
	name = "Luxury Escape Pods"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Due to good performance, we've provided your station with luxury escape pods."
	trait_to_give = STATION_TRAIT_BIGGER_PODS
	blacklist = list(/datum/station_trait/cramped_escape_pods)
