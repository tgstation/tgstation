/obj/item/organ/internal/heart/gland/egg
	abductor_hint = "roe/enzymatic synthesizer. The abductee will periodically lay eggs filled with random reagents."
	cooldown_low = 300
	cooldown_high = 400
	uses = -1
	icon_state = "egg"
	lefthand_file = 'icons/mob/inhands/items/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/food_righthand.dmi'
	mind_control_uses = 2
	mind_control_duration = 1800

/obj/item/organ/internal/heart/gland/egg/activate()
	owner.visible_message(span_alertalien("[owner] [pick(EGG_LAYING_MESSAGES)]"))
	var/turf/T = owner.drop_location()
	new /obj/item/food/egg/gland(T)
