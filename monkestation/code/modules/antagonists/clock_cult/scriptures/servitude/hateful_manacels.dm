/datum/scripture/slab/hateful_manacles
	name = "Hateful Manacles"
	desc = "Forms replicant manacles around a target's wrists that function like handcuffs, restraining the target."
	tip = "Handcuff a target at close range to subdue them for vitality extraction."
	button_icon_state = "Hateful Manacles"
	power_cost = 50
	invocation_time = 2 SECONDS // 2 to invoke, 3 to cuff
	invocation_text = list("Shackle the heretic...", "Break them in body and spirit!")
	slab_overlay = "hateful_manacles"
	use_time = 20 SECONDS
	cogs_required = 1
	category = SPELLTYPE_SERVITUDE


/datum/scripture/slab/hateful_manacles/apply_effects(mob/living/carbon/target_carbon)
	. = ..()
	if(!istype(target_carbon) || IS_CLOCK(target_carbon))
		return FALSE

	if(target_carbon.handcuffed)
		target_carbon.balloon_alert(invoker, "already restrained!")
		return FALSE

	playsound(target_carbon, 'sound/weapons/handcuffs.ogg', 30, TRUE, -2)
	target_carbon.visible_message(span_danger("[invoker] forms a well of energy around [target_carbon], brass appearing at their wrists!"),\
						span_userdanger("[invoker] is trying to restrain you!"))

	if(!do_after(invoker, 3 SECONDS, target = target_carbon))
		return FALSE

	if(target_carbon.handcuffed)
		return FALSE

	target_carbon.handcuffed = new /obj/item/restraints/handcuffs/clockwork(target_carbon)
	target_carbon.update_handcuffed()
	log_combat(invoker, target_carbon, "handcuffed")

	return TRUE


/obj/item/restraints/handcuffs/clockwork
	name = "replicant manacles"
	desc = "Heavy manacles made out of freezing-cold metal. It looks like brass, but feels much more solid."
	icon_state = "brass_manacles"
	item_flags = DROPDEL
