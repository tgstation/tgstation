//Crew has to create dna vault
// Cargo can order DNA samplers + DNA vault boards
// DNA vault requires x animals, y plants, z human dna
// DNA vaults require high tier stock parts
// After completion each crewmember can receive single upgrade chosen out of 2 for the mob.
#define VAULT_TOXIN "Toxin Adaptation"
#define VAULT_NOBREATH "Lung Enhancement"
#define VAULT_FIREPROOF "Thermal Regulation"
#define VAULT_STUNTIME "Neural Repathing"
#define VAULT_ARMOUR "Bone Reinforcement"
#define VAULT_SPEED "Leg Muscle Stimulus"
#define VAULT_QUICK "Arm Muscle Stimulus"

/datum/station_goal/dna_vault
	name = "DNA Vault"
	var/animal_count
	var/human_count
	var/plant_count

/datum/station_goal/dna_vault/New()
	..()
	animal_count = rand(15,20) //might be too few given ~15 roundstart stationside ones
	human_count = rand(round(0.75 * SSticker.totalPlayersReady) , SSticker.totalPlayersReady) // 75%+ roundstart population.
	var/non_standard_plants = non_standard_plants_count()
	plant_count = rand(round(0.5 * non_standard_plants),round(0.7 * non_standard_plants))

/datum/station_goal/dna_vault/proc/non_standard_plants_count()
	. = 0
	for(var/T in subtypesof(/obj/item/seeds)) //put a cache if it's used anywhere else
		var/obj/item/seeds/S = T
		if(initial(S.rarity) > 0)
			.++

/datum/station_goal/dna_vault/get_report()
	return list(
		"<blockquote>Our long term prediction systems indicate a 99% chance of system-wide cataclysm in the near future.",
		"We need you to construct a DNA Vault aboard your station.",
		"",
		"The DNA Vault needs to contain samples of:",
		"* [animal_count] unique animal data",
		"* [plant_count] unique non-standard plant data",
		"* [human_count] unique sapient humanoid DNA data",
		"",
		"Base vault parts are available for shipping via cargo.</blockquote>",
	).Join("\n")


/datum/station_goal/dna_vault/on_report()
	var/datum/supply_pack/P = SSshuttle.supply_packs[/datum/supply_pack/engineering/dna_vault]
	P.special_enabled = TRUE

	P = SSshuttle.supply_packs[/datum/supply_pack/engineering/dna_probes]
	P.special_enabled = TRUE

/datum/station_goal/dna_vault/check_completion()
	if(..())
		return TRUE
	for(var/obj/machinery/dna_vault/V in GLOB.machines)
		if(V.animals.len >= animal_count && V.plants.len >= plant_count && V.dna.len >= human_count)
			return TRUE
	return FALSE


/obj/machinery/dna_vault
	name = "DNA Vault"
	desc = "Break glass in case of apocalypse."
	icon = 'icons/obj/machines/dna_vault.dmi'
	icon_state = "vault"
	density = TRUE
	anchored = TRUE
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 5
	pixel_x = -32
	pixel_y = -64
	light_range = 3
	light_power = 1.5
	light_color = LIGHT_COLOR_CYAN

	//High defaults so it's not completed automatically if there's no station goal
	var/animals_max = 100
	var/plants_max = 100
	var/dna_max = 100
	var/list/animals = list()
	var/list/plants = list()
	var/list/dna = list()

	var/completed = FALSE
	var/list/power_lottery = list()

	var/list/obj/structure/fillers = list()

/obj/machinery/dna_vault/Initialize(mapload)
	//TODO: Replace this,bsa and gravgen with some big machinery datum
	var/list/occupied = list()
	for(var/direct in list(EAST,WEST,SOUTHEAST,SOUTHWEST))
		occupied += get_step(src,direct)
	occupied += locate(x+1,y-2,z)
	occupied += locate(x-1,y-2,z)

	for(var/T in occupied)
		var/obj/structure/filler/F = new(T)
		F.parent = src
		fillers += F

	if(SSticker.mode)
		var/datum/station_goal/dna_vault/dna_vault_goal = locate() in GLOB.station_goals
		if (!isnull(dna_vault_goal))
			animals_max = dna_vault_goal.animal_count
			plants_max = dna_vault_goal.plant_count
			dna_max = dna_vault_goal.human_count
	return ..()

/obj/machinery/dna_vault/Destroy()
	for(var/obj/structure/filler/filler as anything in fillers)
		filler.parent = null
		qdel(filler)
	return ..()

/obj/machinery/dna_vault/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		roll_powers(user)
		ui = new(user, src, "DnaVault", name)
		ui.open()

/obj/machinery/dna_vault/proc/roll_powers(mob/user)
	var/datum/weakref/user_weakref = WEAKREF(user)
	if((user_weakref in power_lottery) || isdead(user))
		return
	var/list/L = list()
	var/list/possible_powers = list(VAULT_TOXIN,VAULT_NOBREATH,VAULT_FIREPROOF,VAULT_STUNTIME,VAULT_ARMOUR,VAULT_SPEED,VAULT_QUICK)
	L += pick_n_take(possible_powers)
	L += pick_n_take(possible_powers)
	power_lottery[user_weakref] = L

/obj/machinery/dna_vault/ui_data(mob/user) //TODO Make it % bars maybe
	var/list/data = list()
	data["plants"] = plants.len
	data["plants_max"] = plants_max
	data["animals"] = animals.len
	data["animals_max"] = animals_max
	data["dna"] = dna.len
	data["dna_max"] = dna_max
	data["completed"] = completed
	data["used"] = TRUE
	data["choiceA"] = ""
	data["choiceB"] = ""
	if(user && completed)
		var/list/L = power_lottery[WEAKREF(user)]
		if(L?.len)
			data["used"] = FALSE
			data["choiceA"] = L[1]
			data["choiceB"] = L[2]
	return data

/obj/machinery/dna_vault/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("gene")
			upgrade(usr,params["choice"])
			. = TRUE

/obj/machinery/dna_vault/proc/check_goal()
	if(plants.len >= plants_max && animals.len >= animals_max && dna.len >= dna_max)
		completed = TRUE


/obj/machinery/dna_vault/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/dna_probe))
		var/obj/item/dna_probe/P = I
		var/uploaded = 0
		for(var/plant in P.stored_dna_plants)
			if(!plants[plant])
				uploaded++
				plants[plant] = 1
		for(var/animal in P.stored_dna_animal)
			if(!animals[animal])
				uploaded++
				animals[animal] = 1
		for(var/ui in P.stored_dna_human)
			if(!dna[ui])
				uploaded++
				dna[ui] = 1
		check_goal()
		to_chat(user, span_notice("[uploaded] new datapoints uploaded."))
	else
		return ..()

/obj/machinery/dna_vault/proc/upgrade(mob/living/carbon/human/H, upgrade_type)
	var/datum/weakref/human_weakref = WEAKREF(H)
	if(!(upgrade_type in power_lottery[human_weakref]) || (HAS_TRAIT(H, TRAIT_USED_DNA_VAULT)))
		return
	var/datum/species/S = H.dna.species
	switch(upgrade_type)
		if(VAULT_TOXIN)
			to_chat(H, span_notice("You feel resistant to airborne toxins."))
			if(locate(/obj/item/organ/internal/lungs) in H.internal_organs)
				var/obj/item/organ/internal/lungs/L = H.internal_organs_slot[ORGAN_SLOT_LUNGS]
				L.plas_breath_dam_min = 0
				L.plas_breath_dam_max = 0
			ADD_TRAIT(H, TRAIT_VIRUSIMMUNE, DNA_VAULT_TRAIT)
		if(VAULT_NOBREATH)
			to_chat(H, span_notice("Your lungs feel great."))
			ADD_TRAIT(H, TRAIT_NOBREATH, DNA_VAULT_TRAIT)
		if(VAULT_FIREPROOF)
			to_chat(H, span_notice("You feel fireproof."))
			S.burnmod = 0.5
			ADD_TRAIT(H, TRAIT_RESISTHEAT, DNA_VAULT_TRAIT)
			ADD_TRAIT(H, TRAIT_NOFIRE, DNA_VAULT_TRAIT)
		if(VAULT_STUNTIME)
			to_chat(H, span_notice("Nothing can keep you down for long."))
			S.stunmod = 0.5
		if(VAULT_ARMOUR)
			to_chat(H, span_notice("You feel tough."))
			S.armor = 30
			ADD_TRAIT(H, TRAIT_PIERCEIMMUNE, DNA_VAULT_TRAIT)
		if(VAULT_SPEED)
			to_chat(H, span_notice("Your legs feel faster."))
			H.add_movespeed_modifier(/datum/movespeed_modifier/dna_vault_speedup)
		if(VAULT_QUICK)
			to_chat(H, span_notice("Your arms move as fast as lightning."))
			H.next_move_modifier = 0.5
	ADD_TRAIT(H, TRAIT_USED_DNA_VAULT, DNA_VAULT_TRAIT)
	power_lottery[human_weakref] = list()
	use_power(active_power_usage)
