/obj/effect/proc_holder/spell/targeted/charge
	name = "Charge"
	desc = "This spell can be used to recharge a variety of things in your hands, \
		from magical artifacts to electrical components. A creative wizard can even use it \
		to grant magical power to a fellow magic user."
	sound = 'sound/magic/charge.ogg'
	action_icon_state = "charge"

	school = SCHOOL_TRANSMUTATION
	charge_max = 600
	clothes_req = FALSE
	invocation = "DIRI CEL"
	invocation_type = INVOCATION_WHISPER
	range = -1
	cooldown_min = 400 //50 deciseconds reduction per rank
	include_user = TRUE

/obj/effect/proc_holder/spell/targeted/charge/cast(list/targets, mob/user = usr)
	// Charge people we're pulling first and foremost
	if(isliving(user.pulling))
		var/mob/living/pulled_living = user.pulling
		var/pulled_has_spells = FALSE

		for(var/obj/effect/proc_holder/spell/spell in pulled_living.mob_spell_list | pulled_living.mind?.spell_list)
			spell.charge_counter = spell.charge_max
			spell.recharging = FALSE
			spell.update_appearance()
			pulled_has_spells = TRUE

		if(pulled_has_spells)
			to_chat(pulled_living, span_notice("You feel raw magic flowing through you. It feels good!"))
			to_chat(user, span_notice("[pulled_living] suddenly feels very warm!"))
			return

		to_chat(pulled_living, span_notice("You feel very strange for a moment, but then it passes."))

	// Then charge their main hand item, then charge their offhand item
	var/obj/item/to_charge = user.get_active_held_item() || user.get_inactive_held_item()
	if(!to_charge)
		to_chat(user, span_notice("You feel magical power surging through your hands, but the feeling rapidly fades."))
		return

	var/charge_return = SEND_SIGNAL(to_charge, COMSIG_ITEM_MAGICALLY_CHARGED, src, user)

	if(QDELETED(to_charge))
		to_chat(user, span_warning("[src] seems to react adversely with [to_charge]!"))
		return

	if(charge_return & COMPONENT_ITEM_BURNT_OUT)
		to_chat(user, span_warning("[to_charge] seems to react negatively to [src], becoming uncomfortably warm!"))

	else if(charge_return & COMPONENT_ITEM_CHARGED)
		to_chat(user, span_notice("[to_charge] suddenly feels very warm!"))

	else
		to_chat(user, span_notice("[to_charge] doesn't seem to be react to [src]."))
