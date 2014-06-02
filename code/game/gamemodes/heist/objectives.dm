//Vox heist objectives.

/datum/objective/heist
	proc/choose_target()
		return

/datum/objective/heist/kidnap
	choose_target()
		var/list/roles = list("Chief Engineer","Research Director","Roboticist","Chemist","Station Engineer")
		var/list/possible_targets = list()
		var/list/priority_targets = list()

		for(var/datum/mind/possible_target in ticker.minds)
			if(possible_target != owner && ishuman(possible_target.current) && (possible_target.current.stat != 2) && (possible_target.assigned_role != "MODE"))
				possible_targets += possible_target
				for(var/role in roles)
					if(possible_target.assigned_role == role)
						priority_targets += possible_target
						continue

		if(priority_targets.len > 0)
			target = pick(priority_targets)
		else if(possible_targets.len > 0)
			target = pick(possible_targets)

		if(target && target.current)
			explanation_text = "The Shoal has a need for [target.current.real_name], the [target.assigned_role]. Take them alive."
		else
			explanation_text = "Free Objective"
		return target

	check_completion()
		if(target && target.current)
			if (target.current.stat == 2)
				return 0 // They're dead. Fail.
			//if (!target.current.restrained())
			//	return 0 // They're loose. Close but no cigar.

			var/area/shuttle/vox/station/A = locate()
			for(var/mob/living/carbon/human/M in A)
				if(target.current == M)
					return 1 //They're restrained on the shuttle. Success.
		else
			return 0


////////////////////////////////////////////////
// THEFT
////////////////////////////////////////////////

/datum/objective/steal/heist
	target_category = "heist"
	format_explanation()
		return "We are lacking in hardware. Steal [steal_target.name]."

/datum/theft_objective/heist
	areas = list(/area/shuttle/vox/station)

/datum/theft_objective/number/heist
	areas = list(/area/shuttle/vox/station)

/datum/theft_objective/number/heist/particle_accelerator
	name = "complete particle accelerator"
	min = 6
	max = 6
	typepath = /obj/structure/particle_accelerator

/datum/theft_objective/number/heist/singulogen
	name = "gravitational generator"
	min = 1
	max = 1
	typepath = /obj/machinery/the_singularitygen

/datum/theft_objective/number/heist/singulogen
	name = "gravitational generator"
	min = 1
	max = 1
	typepath = /obj/machinery/the_singularitygen

/datum/theft_objective/number/heist/emitters
	name = "emitters"
	min = 4
	max = 4
	typepath = /obj/machinery/power/emitter

/datum/theft_objective/number/heist/nuke
	name = "thermonuclear device"
	min = 1
	max = 1
	typepath = /obj/machinery/nuclearbomb

/datum/theft_objective/number/heist/gun
	name = "guns"
	min = 6
	max = 6
	typepath = /obj/item/weapon/gun

/datum/objective/steal/salvage
	target_category = "salvage"
	format_explanation()
		return "Ransack the station and escape with [steal_target.name]."

/datum/theft_objective/number/salvage
	areas = list(/area/shuttle/vox/station)

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


datum/objective/heist/inviolate_crew
	explanation_text = "Do not leave any Vox behind, alive or dead."

	check_completion()
		var/datum/game_mode/heist/H = ticker.mode
		if(H.is_raider_crew_safe()) return 1
		return 0

datum/objective/heist/inviolate_death
	explanation_text = "Follow the Inviolate. Minimise death and loss of resources."
	check_completion()
		if(vox_kills>5) return 0
		return 1