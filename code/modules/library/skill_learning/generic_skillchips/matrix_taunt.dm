#define TAUNT_STAMINA_COST 19

/obj/item/skillchip/matrix_taunt
	name = "BULLET_DODGER skillchip"
	skill_name = "Taunt 2 Dodge"
	skill_description = "At the cost of stamina, your taunts can also be used to dodge incoming projectiles."
	skill_icon = FA_ICON_SPINNER
	activate_message = span_notice("You feel the urge to taunt scenically as if you are the 'Chosen One'.")
	deactivate_message = span_notice("The urge to taunt goes away.")

/obj/item/skillchip/matrix_taunt/on_activate(mob/living/carbon/user, silent = FALSE)
	. = ..()
	RegisterSignal(user, COMSIG_MOB_EMOTED("taunt"), PROC_REF(on_taunt))
	RegisterSignal(user, COMSIG_MOB_PRE_EMOTED, PROC_REF(check_if_we_can_taunt))

/obj/item/skillchip/matrix_taunt/on_deactivate(mob/living/carbon/user, silent=FALSE)
	UnregisterSignal(user, list(COMSIG_MOB_EMOTED("taunt"), COMSIG_MOB_PRE_EMOTED))
	return ..()

///Prevent players from stamcritting from INTENTIONAL flips. 1.4s of bullet immunity isn't worth several secs of stun.
/obj/item/skillchip/matrix_taunt/proc/check_if_we_can_taunt(mob/living/source, key, params, type_override, intentional, datum/emote/emote)
	SIGNAL_HANDLER
	if(key != "taunt" || !intentional)
		return
	if((source.maxHealth - (source.getStaminaLoss() + TAUNT_STAMINA_COST)) <= source.crit_threshold)
		source.balloon_alert(source, "too tired!")
		return COMPONENT_CANT_EMOTE

/obj/item/skillchip/matrix_taunt/proc/on_taunt(mob/living/source)
	SIGNAL_HANDLER
	if(HAS_TRAIT_FROM(source, TRAIT_UNHITTABLE_BY_PROJECTILES, SKILLCHIP_TRAIT))
		return
	ADD_TRAIT(source, TRAIT_UNHITTABLE_BY_PROJECTILES, SKILLCHIP_TRAIT)
	source.adjustStaminaLoss(TAUNT_STAMINA_COST)
	addtimer(TRAIT_CALLBACK_REMOVE(source, TRAIT_UNHITTABLE_BY_PROJECTILES, SKILLCHIP_TRAIT), TAUNT_EMOTE_DURATION * 1.5)

#undef TAUNT_STAMINA_COST
