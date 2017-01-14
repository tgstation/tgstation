//Crew has to create dna vault
// Cargo can order DNA samplers + DNA vault boards
// DNA vault requires x animals ,y plants, z human dna
// DNA vaults require high tier stock parts and cold
// After completion each crewmember can receive single upgrade chosen out of 2 for the mob.
#define VAULT_TOXIN "Toxin Adaptation"
#define VAULT_NOBREATH "Lung Enhancement"
#define VAULT_FIREPROOF "Thermal Regulation"
#define VAULT_STUNTIME "Neural Repathing"
#define VAULT_ARMOUR "Bone Reinforcement"

/datum/station_goal/dna_vault
	name = "DNA Vault"
	var/animal_count
	var/human_count
	var/plant_count

/datum/station_goal/dna_vault/New()
	..()
	animal_count = rand(15,20) //might be too few given ~15 roundstart stationside ones
	human_count = rand(round(0.75 * ticker.totalPlayersReady) , ticker.totalPlayersReady) // 75%+ roundstart population.
	var/non_standard_plants = non_standard_plants_count()
	plant_count = rand(round(0.5 * non_standard_plants),round(0.7 * non_standard_plants))

/datum/station_goal/dna_vault/proc/non_standard_plants_count()
	. = 0
	for(var/T in subtypesof(/obj/item/seeds)) //put a cache if it's used anywhere else
		var/obj/item/seeds/S = T
		if(initial(S.rarity) > 0)
			.++

/datum/station_goal/dna_vault/get_report()
	return {"Our long term prediction systems say there's 99% chance of system-wide cataclysm in near future.
	 We need you to construct DNA Vault aboard your station.

	 DNA Vault needs to contain samples of:
	 [animal_count] unique animal data
	 [plant_count] unique non-standard plant data
	 [human_count] unique sapient humanoid DNA data

	 Base vault parts should be availible for shipping by your cargo shuttle."}


/datum/station_goal/dna_vault/on_report()
	var/datum/supply_pack/P = SSshuttle.supply_packs[/datum/supply_pack/misc/dna_vault]
	P.special_enabled = TRUE

	P = SSshuttle.supply_packs[/datum/supply_pack/misc/dna_probes]
	P.special_enabled = TRUE

/datum/station_goal/dna_vault/check_completion()
	if(..())
		return TRUE
	for(var/obj/machinery/dna_vault/V in machines)
		if(V.animals.len >= animal_count && V.plants.len >= plant_count && V.dna.len >= human_count)
			return TRUE
	return FALSE


/obj/item/device/dna_probe
	name = "DNA Sampler"
	desc = "Can be used to take chemical and genetic samples of pretty much anything."
	icon = 'icons/obj/syringe.dmi'
	item_state = "hypo"
	icon_state = "hypo"
	flags = NOBLUDGEON
	var/list/animals = list()
	var/list/plants = list()
	var/list/dna = list()

/obj/item/device/dna_probe/proc/clear_data()
	animals = list()
	plants = list()
	dna = list()

var/list/non_simple_animals = typecacheof(list(/mob/living/carbon/monkey,/mob/living/carbon/alien))

/obj/item/device/dna_probe/afterattack(atom/target, mob/user, proximity)
	..()
	if(!proximity || !target)
		return
	//tray plants
	if(istype(target,/obj/machinery/hydroponics))
		var/obj/machinery/hydroponics/H = target
		if(!H.myseed)
			return
		if(!H.harvest)// So it's bit harder.
			user << "<span clas='warning'>Plants needs to be ready to harvest to perform full data scan.</span>" //Because space dna is actually magic
			return
		if(plants[H.myseed.type])
			user << "<span class='notice'>Plant data already present in local storage.<span>"
			return
		plants[H.myseed.type] = 1
		user << "<span class='notice'>Plant data added to local storage.<span>"

	//animals
	if(isanimal(target) || is_type_in_typecache(target,non_simple_animals))
		if(isanimal(target))
			var/mob/living/simple_animal/A = target
			if(!A.healable)//simple approximation of being animal not a robot or similar
				user << "<span class='warning'>No compatibile DNA detected</span>"
				return
		if(animals[target.type])
			user << "<span class='notice'>Animal data already present in local storage.<span>"
			return
		animals[target.type] = 1
		user << "<span class='notice'>Animal data added to local storage.<span>"

	//humans
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(dna[H.dna.uni_identity])
			user << "<span class='notice'>Humanoid data already present in local storage.<span>"
			return
		dna[H.dna.uni_identity] = 1
		user << "<span class='notice'>Humanoid data added to local storage.<span>"


/obj/item/weapon/circuitboard/machine/dna_vault
	name = "DNA Vault (Machine Board)"
	build_path = /obj/machinery/dna_vault
	origin_tech = "engineering=2;combat=2;bluespace=2" //No freebies!
	req_components = list(
							/obj/item/weapon/stock_parts/capacitor/quadratic = 5,
							/obj/item/stack/cable_coil = 2)

/obj/machinery/dna_vault
	name = "DNA Vault"
	desc = "Break glass in case of apocalypse."
	icon = 'icons/obj/machines/dna_vault.dmi'
	icon_state = "vault"
	density = 1
	anchored = 1
	idle_power_usage = 5000
	pixel_x = -32
	pixel_y = -64
	luminosity = 1

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

/obj/machinery/dna_vault/New()
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

	if(ticker.mode)
		for(var/datum/station_goal/dna_vault/G in ticker.mode.station_goals)
			animals_max = G.animal_count
			plants_max = G.plant_count
			dna_max = G.human_count
			break

/obj/machinery/dna_vault/Destroy()
	for(var/V in fillers)
		var/obj/structure/filler/filler = V
		filler.parent = null
		qdel(filler)
	. = ..()


/obj/machinery/dna_vault/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = physical_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		roll_powers(user)
		ui = new(user, src, ui_key, "dna_vault", name, 350, 400, master_ui, state)
		ui.open()


/obj/machinery/dna_vault/proc/roll_powers(mob/user)
	if(user in power_lottery)
		return
	var/list/L = list()
	var/list/possible_powers = list(VAULT_TOXIN,VAULT_NOBREATH,VAULT_FIREPROOF,VAULT_STUNTIME,VAULT_ARMOUR)
	L += pick_n_take(possible_powers)
	L += pick_n_take(possible_powers)
	power_lottery[user] = L

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
		var/list/L = power_lottery[user]
		if(L && L.len)
			data["used"] = FALSE
			data["choiceA"] = L[1]
			data["choiceB"] = L[2]
	return data

/obj/machinery/dna_vault/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("gene")
			upgrade(usr,params["choice"])
			. = TRUE

/obj/machinery/dna_vault/proc/check_goal()
	if(plants.len >= plants_max && animals.len >= animals_max && dna.len >= dna_max)
		completed = TRUE


/obj/machinery/dna_vault/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/dna_probe))
		var/obj/item/device/dna_probe/P = I
		var/uploaded = 0
		for(var/plant in P.plants)
			if(!plants[plant])
				uploaded++
				plants[plant] = 1
		for(var/animal in P.animals)
			if(!animals[animal])
				uploaded++
				animals[animal] = 1
		for(var/ui in P.dna)
			if(!dna[ui])
				uploaded++
				dna[ui] = 1
		check_goal()
		user << "<span class='notice'>[uploaded] new datapoints uploaded.</span>"
	else
		return ..()



/obj/machinery/dna_vault/proc/upgrade(mob/living/carbon/human/H,upgrade_type)
	if(!(upgrade_type in power_lottery[H]))
		return
	var/datum/species/S = H.dna.species
	switch(upgrade_type)
		if(VAULT_TOXIN)
			H << "<span class='notice'>You feel resistant to airborne toxins.</span>"
			if(locate(/obj/item/organ/lungs) in H.internal_organs)
				var/obj/item/organ/lungs/L = H.internal_organs_slot["lungs"]
				L.tox_breath_dam_min = 0
				L.tox_breath_dam_max = 0
			S.species_traits |= VIRUSIMMUNE
		if(VAULT_NOBREATH)
			H << "<span class='notice'>Your lungs feel great.</span>"
			S.species_traits |= NOBREATH
		if(VAULT_FIREPROOF)
			H << "<span class='notice'>Your feel fireproof.</span>"
			S.burnmod = 0.5
			S.heatmod = 0
		if(VAULT_STUNTIME)
			H << "<span class='notice'>Nothing can keep you down for long.</span>"
			S.stunmod = 0.5
		if(VAULT_ARMOUR)
			H << "<span class='notice'>Your feel tough.</span>"
			S.armor = 30
	power_lottery[H] = list()