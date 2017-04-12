//T   H   E      W   O   R   L   D   .   -   Z   A      W   A   R   U   D   O   .
//somebody once told me the world was gonna roll me
/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/sutando
	invocation = null
	summon_type = list(/obj/effect/timestop/wizard/sutando)
	clothes_req = 0

/datum/sutando_abilities/timestop
	id = "timestop"
	name = "Time Stop"
	value = 5

/datum/sutando_abilities/timestop/handle_stats()
	. = ..()
	var/obj/effect/proc_holder/spell/S = new/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/sutando
	stand.mind.AddSpell(S)
	stand.melee_damage_lower += 5
	stand.melee_damage_upper += 5
	stand.obj_damage += 40
	stand.next_move_modifier -= 0.1 //attacks 10% faster

