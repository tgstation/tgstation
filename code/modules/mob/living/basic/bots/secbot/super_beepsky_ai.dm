/datum/ai_controller/basic_controller/bot/secbot/super_beepsky

/datum/ai_controller/basic_controller/bot/secbot/on_target_set()
	. = ..()
	var/mob/living/controller_pawn = pawn
	playsound(controller_pawn ,'sound/items/weapons/saberon.ogg', 50, TRUE, -1)
	controller_pawn.visible_message(span_warning("[controller_pawn] ignites his energy swords!"))
	controller_pawn.visible_message("<b>[controller_pawn]</b> points at [blackboard[BB_BASIC_MOB_CURRENT_TARGET]]!")
