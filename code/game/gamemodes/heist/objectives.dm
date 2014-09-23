/**
 * vox heist objectives
 */

#define MAX_VOX_KILLS 5 // number of kills during the round before the inviolate is broken
						// would be nice to use vox-specific kills but is currently not feasible

/*
 * heist
 */

/datum/objective/heist/proc/choose_target()
	return

/*
 * kidnap
 */

/datum/objective/heist/kidnap/choose_target()
	var/list/roles = list("Chief Engineer", "Research Director", "Roboticist", "Chemist", "Station Engineer")

	for(var/role in shuffle(roles))
		find_target_by_role(role)

		if(target)
			break

	if(isnull(target)) // if we cannot find some target at certain roles
		find_target()

	if(target)
		explanation_text = "The Shoal has a need for [target.current.real_name], the [target.assigned_role]. Take them alive."
	else
		explanation_text = "Free Objective"

	return target

/datum/objective/heist/kidnap/check_completion()
	if(target)
		if(isnull(target.current) || target.current.stat == DEAD)
			return FALSE // they're destroyed or dead. fail.

		var/end_area = get_area_master(locate(/area/shuttle/vox/station))

		if(get_area_master(target.current) != end_area)
			return FALSE

		//if(!target.current.restrained())
			//return FALSE // they're loose. close but no cigar.

		return TRUE // they're restrained on the shuttle. success.

/*
 * inviolate
 */

/datum/objective/heist/inviolate_crew
	explanation_text = "Do not leave any Vox behind, alive or dead."

/datum/objective/heist/inviolate_crew/check_completion()
	var/datum/game_mode/heist/H = ticker.mode
	return H.is_raider_crew_safe()

/datum/objective/heist/inviolate_death
	explanation_text = "Follow the Inviolate. Minimise death and loss of resources."

/datum/objective/heist/inviolate_death/check_completion()
	if(vox_kills > MAX_VOX_KILLS)
		return FALSE

	return TRUE

#undef MAX_VOX_KILLS

/*
 * theft
 */

/*
 * heist
 */

/datum/objective/steal/heist
	target_category = "heist"

/datum/objective/steal/heist/format_explanation()
	return "We are lacking in hardware. Steal [steal_target.name]."

/datum/theft_objective/number/heist
	areas = list(/area/shuttle/vox/station)

/datum/theft_objective/number/heist/check_completion()
	var/found_amount = 0

	var/list/all_contents = new

	for(var/datum/mind/raider in raiders)
		if(raider && raider.current && isliving(raider.current))
			var/mob/living/body = raider.current

			var/list/body_contents = body.get_contents()

			if(body_contents && body_contents.len > 0)
				all_contents |= body_contents

	for(var/area_type in areas)
		for(var/obj/o in area_contents(locate(area_type)))
			all_contents |= get_contents(o)
			all_contents |= o

	for(var/obj/content in all_contents)
		if(istype(content, typepath))
			if(areas && areas.len > 0)
				if(!is_type_in_list(get_area_master(content), areas))
					continue

				found_amount++

	return found_amount >= required_amount

/datum/theft_objective/number/heist/particle_accelerator
	name = "complete particle accelerator"
	typepath = /obj/structure/particle_accelerator
	min = 1
	max = 1

/datum/theft_objective/number/heist/particle_accelerator/check_completion()
	var/found_end_cap = 0
	var/found_fuel_chamber = 0
	var/found_particle_emitter_center = 0
	var/found_particle_emitter_left = 0
	var/found_particle_emitter_right = 0
	var/found_power_box = 0

	var/list/all_contents = new

	for(var/datum/mind/raider in raiders)
		if(raider && raider.current && isliving(raider.current))
			var/mob/living/body = raider.current

			var/list/body_contents = body.get_contents()

			if(body_contents && body_contents.len > 0)
				all_contents |= body_contents

	for(var/area_type in areas)
		for(var/obj/o in area_contents(locate(area_type)))
			all_contents |= get_contents(o)
			all_contents |= o

	for(var/obj/content in all_contents)
		if(istype(content, typepath))
			if(areas && areas.len > 0)
				if(!is_type_in_list(get_area_master(content), areas))
					continue

				switch(content.type)
					if(/obj/structure/particle_accelerator/end_cap)
						found_end_cap++
					if(/obj/structure/particle_accelerator/fuel_chamber)
						found_fuel_chamber++
					if(/obj/structure/particle_accelerator/particle_emitter/center)
						found_particle_emitter_center++
					if(/obj/structure/particle_accelerator/particle_emitter/left)
						found_particle_emitter_left++
					if(/obj/structure/particle_accelerator/particle_emitter/right)
						found_particle_emitter_right++
					if(/obj/structure/particle_accelerator/power_box)
						found_power_box++

	if( \
		--found_end_cap >= 0 && \
		--found_fuel_chamber >= 0  && \
		--found_particle_emitter_center >= 0 && \
		--found_particle_emitter_left >= 0 && \
		--found_particle_emitter_right >= 0 && \
		--found_power_box >= 0 \
	)
		return TRUE

	return FALSE

/datum/theft_objective/number/heist/singulogen
	name = "gravitational generator"
	typepath = /obj/machinery/the_singularitygen
	min = 1
	max = 1

/datum/theft_objective/number/heist/singulogen
	name = "gravitational generator"
	typepath = /obj/machinery/the_singularitygen
	min = 1
	max = 1

/datum/theft_objective/number/heist/emitters
	name = "emitters"
	typepath = /obj/machinery/power/emitter
	min = 4
	max = 4

/datum/theft_objective/number/heist/nuke
	name = "thermonuclear device"
	typepath = /obj/machinery/nuclearbomb
	min = 1
	max = 1

/datum/theft_objective/number/heist/gun
	name = "guns"
	typepath = /obj/item/weapon/gun
	min = 6
	max = 6

/*
 * salvage
 */

/datum/objective/steal/salvage
	target_category = "salvage"

/datum/objective/steal/salvage/format_explanation()
	return "Ransack the station and escape with [steal_target.name]."

/datum/theft_objective/number/salvage
	areas = list(/area/shuttle/vox/station)

/datum/theft_objective/number/salvage/check_completion()
	var/found_amount = 0
	var/list/all_contents

	for(var/datum/mind/raider in raiders)
		if(raider && raider.current && isliving(raider.current))
			var/mob/living/body = raider.current

			var/list/body_contents = body.get_contents()

			if(body_contents && body_contents.len > 0)
				all_contents |= body_contents

	for(var/area_type in areas)
		for(var/obj/o in area_contents(locate(area_type)))
			all_contents |= get_contents(o)
			all_contents |= o

	for(var/obj/content in all_contents)
		if(istype(content, typepath))
			if(areas && areas.len > 0)
				if(!is_type_in_list(get_area_master(content), areas))
					continue

				found_amount += getAmountStolen(content)

	return found_amount >= required_amount

/datum/theft_objective/number/salvage/metal
	name = "metal"
	typepath = /obj/item/stack/sheet/metal
	min = 300
	max = 300

/datum/theft_objective/number/salvage/glass
	name = "glass"
	typepath = /obj/item/stack/sheet/glass
	min = 200
	max = 200

/datum/theft_objective/number/salvage/plasteel
	name = "plasteel"
	typepath = /obj/item/stack/sheet/plasteel
	min = 100
	max = 100

/datum/theft_objective/number/salvage/plasma
	name = "plasma"
	typepath = /obj/item/stack/sheet/mineral/plasma
	min = 100
	max = 100

/datum/theft_objective/number/salvage/silver
	name = "silver"
	typepath = /obj/item/stack/sheet/mineral/silver
	min = 50
	max = 50

/datum/theft_objective/number/salvage/gold
	name = "gold"
	typepath = /obj/item/stack/sheet/mineral/gold
	min = 20
	max = 20

/datum/theft_objective/number/salvage/uranium
	name = "uranium"
	typepath = /obj/item/stack/sheet/mineral/uranium
	min = 20
	max = 20

/datum/theft_objective/number/salvage/diamond
	name = "diamond"
	typepath = /obj/item/stack/sheet/mineral/diamond
	min = 20
	max = 20
