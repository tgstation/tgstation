/datum/action/spell_action/New(Target)
	..()
	var/obj/effect/proc_holder/spell/S = Target
	icon_icon = S.action_icon
