/datum/xenoflora_plant
	var/name = "Bugplant"
	var/desc = "A strange plant that's made out of colorful rectangles, this species originates from the planet named Coderbus."

	var/icon = 'icons/obj/xenobiology/xenoflora_pod.dmi'
	var/icon_state = "error"
	var/ground_icon_state = "dirt"
	var/seeds_icon_state = "xenoseeds"

	var/list/required_gases = list()
	var/list/produced_gases = list()
	var/min_safe_temp = -1
	var/max_safe_temp = INFINITY

	var/list/required_chems = list()
	var/list/produced_chems = list()

	var/max_progress = 300
	var/max_stage = 4

	var/max_health = 300
	var/health = 300

	var/stage = 1
	var/progress = 0

	var/produce_type = /obj/item/food/xenoflora
	var/min_produce = 1
	var/max_produce = 3
	var/interaction_sound = 'sound/effects/footstep/grass3.ogg'

	var/obj/machinery/atmospherics/components/binary/xenoflora_pod/parent_pod

/datum/xenoflora_plant/New(pod)
	. = ..()
	parent_pod = pod

/datum/xenoflora_plant/proc/Life()
	if(health <= 0)
		parent_pod.plant = null
		qdel(src)
		return FALSE

	var/gases_satisfied = TRUE
	var/chems_satisfied = TRUE

	var/datum/gas_mixture/gas_mix = parent_pod.internal_gases
	if(!parent_pod.dome_extended)
		var/turf/tile = get_turf(parent_pod)
		gas_mix = tile.return_air()

	if(LAZYLEN(required_gases))
		for(var/gas_type in required_gases)
			if(!gas_mix.gases[gas_type] || !gas_mix.gases[gas_type][MOLES] || gas_mix.gases[gas_type][MOLES] < required_gases[gas_type])
				gases_satisfied = FALSE
				continue
			gas_mix.remove_specific(gas_type, required_gases[gas_type])

	if(LAZYLEN(required_chems))
		for(var/chem_type in required_chems)
			if(!parent_pod.reagents.remove_reagent(chem_type, required_chems[chem_type]))
				chems_satisfied = FALSE

	if(!gases_satisfied)
		health = max(0, health - 1)
		return FALSE

	if(!chems_satisfied)
		health = max(0, health - 1)
		return FALSE

	if(!parent_pod.on || !parent_pod.is_operational)
		health = max(0, health - 1)
		return FALSE

	if(gas_mix.return_volume() > 0 && (gas_mix.return_temperature() >= max_safe_temp || gas_mix.return_temperature() <= min_safe_temp))
		health = max(0, health - 3)
		return FALSE

	if(parent_pod.reagents.total_volume > 0 && (parent_pod.reagents.chem_temp >= max_safe_temp || parent_pod.reagents.chem_temp <= min_safe_temp))
		health = max(0, health - 3)
		return FALSE

	health = min(max_health, health + 1)
	progress += 1

	if(progress >= max_progress && stage < max_stage)
		progress = 0
		stage += 1
		parent_pod.update_icon()

	if(LAZYLEN(produced_gases))
		for(var/gas_type in produced_gases)
			if(parent_pod.internal_gases.return_volume() >= XENOFLORA_MAX_MOLES)
				break

			parent_pod.internal_gases.assert_gas(gas_type)
			parent_pod.internal_gases.gases[gas_type][MOLES] += min(produced_gases[gas_type], XENOFLORA_MAX_MOLES - parent_pod.internal_gases.return_volume()) //It'll get spread anyways


	if(LAZYLEN(produced_chems))
		for(var/chem_type in produced_chems)
			parent_pod.reagents.add_reagent(chem_type, required_chems[chem_type])

	return TRUE

/datum/xenoflora_plant/proc/harvested(mob/harvester)
	stage -= 1
	for(var/i = min_produce to max_produce)
		new produce_type(get_turf(harvester))

/obj/item/food/xenoflora
	name = "bugged xenoflora"
	desc = "Looks like someone did an oopsie! Report this to coderbus."
	icon = 'icons/obj/xenobiology/xenoflora_harvest.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/seed_type = /obj/item/xeno_seeds
