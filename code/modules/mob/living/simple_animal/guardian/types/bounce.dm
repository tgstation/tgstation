
//oingo boingo

/datum/guardian_abilities/bounce
	id = "bounce"
	name = "Rubbery Skin"
	value = 1
	var/bounce_distance = 5

/datum/guardian_abilities/bounce/handle_stats()
	. = ..()
	guardian.range += 3
	guardian.melee_damage_lower += 3
	guardian.melee_damage_upper += 3

/datum/guardian_abilities/bounce/ability_act(atom/movable/A)
	var/atom/throw_target = get_edge_target_turf(A, guardian.dir)
	A.throw_at(throw_target, bounce_distance, 14, guardian)

/datum/guardian_abilities/bounce/boom_act(severity)
	guardian.visible_message("<span class='danger'>The explosive force bounces off [guardian]'s rubbery surface!</span>")
	for(var/mob/M in range(7,guardian))
		if(M != user)
			M.ex_act(severity) //reflect
			M.visible_message("<span class='danger'>The explosive force bounces onto [M]!</span>")