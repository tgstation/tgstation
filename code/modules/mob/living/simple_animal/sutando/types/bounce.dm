
//oingo boingo

/datum/sutando_abilities/bounce
	id = "bounce"
	name = "Rubbery Skin"
	value = 1
	var/bounce_distance = 5

/datum/sutando_abilities/bounce/handle_stats()
	. = ..()
	stand.range += 3
	stand.melee_damage_lower += 3
	stand.melee_damage_upper += 3

/datum/sutando_abilities/bounce/ability_act(atom/movable/A)
	var/atom/throw_target = get_edge_target_turf(A, stand.dir)
	A.throw_at(throw_target, bounce_distance, 14, stand)

/datum/sutando_abilities/bounce/boom_act(severity)
	stand.visible_message("<span class='danger'>The explosive force bounces off [stand]'s rubbery surface!</span>")
	for(var/mob/M in range(7,stand))
		if(M != user)
			M.ex_act(severity) //reflect
			M.visible_message("<span class='danger'>The explosive force bounces onto [M]!</span>")