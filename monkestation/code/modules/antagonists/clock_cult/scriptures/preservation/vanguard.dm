/datum/scripture/slab/vanguard
	name = "Vanguard"
	use_time = 30 SECONDS
	slab_overlay = "vanguard"
	desc = "Provides the user with 30 seconds of stun immunity, however other scriptures cannot be invoked while it is active."
	tip = "Gain temporary immunity against batons and disablers."
	invocation_text = list("With Eng'ine's power coursing through me...", "I will stop them in their tracks!")
	invocation_time = 2 SECONDS
	button_icon_state = "Vanguard"
	category = SPELLTYPE_PRESERVATION
	cogs_required = 2
	power_cost = 150

/datum/scripture/slab/vanguard/apply_effects(atom/applied_atom)
	return FALSE

/datum/scripture/slab/vanguard/invoke()
	. = ..()
	invoker.add_traits(list(TRAIT_STUNIMMUNE,
							TRAIT_PUSHIMMUNE,
							TRAIT_IGNOREDAMAGESLOWDOWN,
							TRAIT_NOLIMBDISABLE), VANGUARD_TRAIT)
	to_chat(invoker, span_notice("You feel like nothing can stop you!"))

/datum/scripture/slab/vanguard/count_down()
	. = ..()
	if(time_left == 5 SECONDS)
		to_chat(invoker, span_warning("You start to feel tired again."))

/datum/scripture/slab/vanguard/end_invocation(silent)
	. = ..()
	invoker.remove_traits(list(TRAIT_STUNIMMUNE,
							   TRAIT_PUSHIMMUNE,
							   TRAIT_IGNOREDAMAGESLOWDOWN,
							   TRAIT_NOLIMBDISABLE), VANGUARD_TRAIT)
	to_chat(invoker, span_userdanger("You feel the last of the energy from \the [invoking_slab] leave you."))
