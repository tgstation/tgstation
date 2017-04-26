//T   H   E      W   O   R   L   D   .   -   Z   A      W   A   R   U   D   O   .
//somebody once told me the world was gonna roll me
/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/guardian
	invocation = null
	summon_type = list(/obj/effect/timestop/wizard/guardian)
	clothes_req = 0

/datum/guardian_abilities/timestop
	id = "timestop"
	name = "Time Stop"
	value = 5

/datum/guardian_abilities/timestop/handle_stats()
	. = ..()
	var/obj/effect/proc_holder/spell/S = new/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/guardian
	guardian.mind.AddSpell(S)
	guardian.melee_damage_lower += 5
	guardian.melee_damage_upper += 5
	guardian.obj_damage += 40
	guardian.next_move_modifier -= 0.1 //attacks 10% faster

