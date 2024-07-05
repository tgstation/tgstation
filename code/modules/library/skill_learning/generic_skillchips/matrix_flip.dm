#define FLIP_STAMINA_COST 19

/obj/item/skillchip/matrix_flip
	name = "BULLET_DODGER skillchip"
	skill_name = "Flip 2 Dodge"
	skill_description = "At the cost of stamina, your flips can also be used to dodge incoming projectiles."
	skill_icon = FA_ICON_SPINNER
	activate_message = span_notice("You feel the urge to flip scenically as if you are the 'Chosen One'.")
	deactivate_message = span_notice("The urge to flip goes away.")

/obj/item/skillchip/matrix_flip/on_activate(mob/living/carbon/user, silent = FALSE)
	. = ..()
	ADD_TRAIT(user, TRAIT_SLOW_FLIP, SKILLCHIP_TRAIT)
	RegisterSignal(user, COMSIG_MOB_EMOTED("flip"), PROC_REF(on_flip))
	RegisterSignal(user, COMSIG_MOB_PRE_EMOTED, PROC_REF(check_if_we_can_flip))

/obj/item/skillchip/matrix_flip/on_deactivate(mob/living/carbon/user, silent=FALSE)
	REMOVE_TRAIT(user, TRAIT_SLOW_FLIP, SKILLCHIP_TRAIT)
	UnregisterSignal(user, list(COMSIG_MOB_EMOTED("flip"), COMSIG_MOB_PRE_EMOTED))
	return ..()

///Prevent players from stamcritting from INTENTIONAL flips. 1.4s of bullet immunity isn't worth several secs of stun.
/obj/item/skillchip/matrix_flip/proc/check_if_we_can_flip(mob/living/source, key, params, type_override, intentional, datum/emote/emote)
	SIGNAL_HANDLER
	if(key != "flip" || !intentional)
		return
	if((source.maxHealth - (source.getStaminaLoss() + FLIP_STAMINA_COST)) <= source.crit_threshold)
		source.balloon_alert(source, "too tired!")
		return COMPONENT_CANT_EMOTE

/obj/item/skillchip/matrix_flip/proc/on_flip(mob/living/source)
	SIGNAL_HANDLER
	if(HAS_TRAIT_FROM(source, TRAIT_UNHITTABLE_BY_PROJECTILES, SKILLCHIP_TRAIT))
		return
	playsound(source, 'sound/weapons/fwoosh.ogg', 90, FALSE, frequency = 0.7)
	ADD_TRAIT(source, TRAIT_UNHITTABLE_BY_PROJECTILES, SKILLCHIP_TRAIT)
	source.adjustStaminaLoss(FLIP_STAMINA_COST)
	addtimer(TRAIT_CALLBACK_REMOVE(source, TRAIT_UNHITTABLE_BY_PROJECTILES, SKILLCHIP_TRAIT), FLIP_EMOTE_DURATION * 2)

#undef FLIP_STAMINA_COST
