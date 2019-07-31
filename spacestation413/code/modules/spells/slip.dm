/obj/effect/proc_holder/spell/aoe_turf/slip
	name = "Slip"
	desc = "Causes the floor within three tiles to become slippery."
	clothes_req = TRUE
	human_req = FALSE
	charge_max = 300
	cooldown_min = 100 //50 deciseconds reduction per level
	range = 3
	invocation = "OO'BANAN'A!"
	invocation_type = "shout"
	action_icon = 'yogstation/icons/mob/actions.dmi'
	action_icon_state = "slip"

/obj/effect/proc_holder/spell/aoe_turf/slip/cast(list/targets,mob/user = usr)
	for(var/turf/open/T in targets)
		T.MakeSlippery(TURF_WET_LUBE, 30 SECONDS, 30 SECONDS)

/datum/spellbook_entry/slip
	name = "Slip"
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/slip
	category = "Offensive"
