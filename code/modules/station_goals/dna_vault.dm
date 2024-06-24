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
	animal_count = rand(10,15) //might be too few given ~15 roundstart stationside ones
	human_count = rand(round(0.75 * SSticker.totalPlayersReady) , SSticker.totalPlayersReady) // 75%+ roundstart population.
	var/non_standard_plants = non_standard_plants_count()
	plant_count = rand(round(0.2 * non_standard_plants),round(0.4 * non_standard_plants))

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
	for(var/obj/machinery/dna_vault/V as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/dna_vault))
		if(V.animal_dna.len >= animal_count && V.plant_dna.len >= plant_count && V.human_dna.len >= human_count)
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
	var/list/animal_dna = list()
	var/list/plant_dna = list()
	var/list/human_dna = list()

	var/completed = FALSE
	var/list/power_lottery = list()
	var/list/possible_powers

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

	var/datum/station_goal/dna_vault/dna_vault_goal = SSstation.get_station_goal(/datum/station_goal/dna_vault)
	if(!isnull(dna_vault_goal))
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

//Generate a unique set of mutation for each person
/obj/machinery/dna_vault/proc/roll_powers(mob/user)
	var/datum/weakref/user_weakref = WEAKREF(user)
	if((user_weakref in power_lottery) || isdead(user))
		return
	possible_powers = list(
		/datum/mutation/human/breathless,
		/datum/mutation/human/dextrous,
		/datum/mutation/human/quick,
		/datum/mutation/human/fire_immunity,
		/datum/mutation/human/plasmocile,
		/datum/mutation/human/quick_recovery,
		/datum/mutation/human/tough,
	)
	var/list/gained_mutation = list()
	gained_mutation += pick_n_take(possible_powers)
	gained_mutation += pick_n_take(possible_powers)

	power_lottery[user_weakref] = gained_mutation

/obj/machinery/dna_vault/ui_data(mob/user)
	var/list/data = list()
	data["plants"] = plant_dna.len
	data["plants_max"] = plants_max
	data["animals"] = animal_dna.len
	data["animals_max"] = animals_max
	data["dna"] = human_dna.len
	data["dna_max"] = dna_max
	data["completed"] = completed
	data["used"] = TRUE
	data["choiceA"] = ""
	data["choiceB"] = ""
	if(user && completed)
		var/list/mutation_options = power_lottery[WEAKREF(user)]
		if(length(mutation_options))
			var/datum/mutation/human/mutation1 = mutation_options[1]
			var/datum/mutation/human/mutation2 = mutation_options[2]
			data["used"] = FALSE
			data["choiceA"] = initial(mutation1.name)
			data["choiceB"] = initial(mutation2.name)
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
	if(plant_dna.len >= plants_max && animal_dna.len >= animals_max && human_dna.len >= dna_max)
		completed = TRUE

/obj/machinery/dna_vault/proc/upgrade(mob/living/carbon/human/H, upgrade_type)
	var/datum/weakref/human_weakref = WEAKREF(H)
	var/static/list/associated_mutation = list(
		"Breathless" = /datum/mutation/human/breathless,
		"Dextrous" = /datum/mutation/human/dextrous,
		"Quick" = /datum/mutation/human/quick,
		"Fire Immunity" = /datum/mutation/human/fire_immunity,
		"Plasmocile" = /datum/mutation/human/plasmocile,
		"Quick Recovery" = /datum/mutation/human/quick_recovery,
		"Tough" = /datum/mutation/human/tough,
	)
	if(!(associated_mutation[upgrade_type] in power_lottery[human_weakref])	||	(HAS_TRAIT(H, TRAIT_USED_DNA_VAULT)))
		return
	H.dna.add_mutation(associated_mutation[upgrade_type], MUT_OTHER, 0)
	ADD_TRAIT(H, TRAIT_USED_DNA_VAULT, DNA_VAULT_TRAIT)
	power_lottery[human_weakref] = list()
	use_energy(active_power_usage)

#undef VAULT_TOXIN
#undef VAULT_NOBREATH
#undef VAULT_FIREPROOF
#undef VAULT_STUNTIME
#undef VAULT_ARMOUR
#undef VAULT_SPEED
#undef VAULT_QUICK
