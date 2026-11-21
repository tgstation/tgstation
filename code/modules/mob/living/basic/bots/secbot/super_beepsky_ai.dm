/datum/ai_controller/basic_controller/bot/secbot/super_beepsky

/datum/ai_controller/basic_controller/bot/secbot/super_beepsky/on_target_set()
	. = ..()
	var/mob/living/basic/bot/secbot/grievous/super_beeps = pawn
	if(!super_beeps.sword_active)
		INVOKE_ASYNC(super_beeps.weapon, TYPE_PROC_REF(/obj/item, attack_self), super_beeps)
	super_beeps.visible_message("<b>[super_beeps]</b> points at [blackboard[BB_CURRENT_TARGET]]!")
