/// This provides different types of magic resistance on an object
/datum/component/anti_magic
	/// A bitflag with the types of magic resistance on the object
	var/antimagic_flags
	/// The amount of times the object can protect the user from magic
	var/charges
	/// The inventory slot the object must be located at in order to activate
	var/inventory_flags
	/// The proc that is triggered when an object has been drained a antimagic charge
	var/datum/callback/drain_antimagic
	/// The proc that is triggered when the object is depleted of charges
	var/datum/callback/expiration
	/// If we have already sent a notification message to the mob picking up an antimagic item
	var/casting_restriction_alert = FALSE

/**
 * Adds magic resistances to an object
 *
 * Magic resistance will prevent magic from affecting the user if it has the correct resistance
 * against the type of magic being used
 *
 * args:
 * * antimagic_flags (optional) A bitflag with the types of magic resistance on the object
 * * charges (optional) The amount of times the object can protect the user from magic
 * * inventory_flags (optional) The inventory slot the object must be located at in order to activate
 * * drain_antimagic (optional) The proc that is triggered when an object has been drained a antimagic charge
 * * expiration (optional) The proc that is triggered when the object is depleted of charges
 * *
 * antimagic bitflags: (see code/__DEFINES/magic.dm)
 * * MAGIC_RESISTANCE - Default magic resistance that blocks normal magic (wizard, spells, staffs)
 * * MAGIC_RESISTANCE_MIND - Tinfoil hat magic resistance that blocks mental magic (telepathy, abductors, jelly people)
 * * MAGIC_RESISTANCE_HOLY - Holy magic resistance that blocks unholy magic (revenant, cult, vampire, voice of god)
**/
/datum/component/anti_magic/Initialize(
		antimagic_flags = MAGIC_RESISTANCE,
		charges = INFINITY,
		inventory_flags = ~ITEM_SLOT_BACKPACK, // items in a backpack won't activate, anywhere else is fine
		datum/callback/drain_antimagic,
		datum/callback/expiration
	)

	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
		RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	else if(ismob(parent))
		RegisterSignal(parent, COMSIG_MOB_RECEIVE_MAGIC, PROC_REF(block_receiving_magic), override = TRUE)
		RegisterSignal(parent, COMSIG_MOB_RESTRICT_MAGIC, PROC_REF(restrict_casting_magic), override = TRUE)
		if(!HAS_TRAIT(parent, TRAIT_ANTIMAGIC_NO_SELFBLOCK))
			to_chat(parent, span_warning("Magic seems to flee from you. You are immune to spells but are unable to cast magic."))
	else
		return COMPONENT_INCOMPATIBLE

	src.antimagic_flags = antimagic_flags
	src.charges = charges
	src.inventory_flags = inventory_flags
	src.drain_antimagic = drain_antimagic
	src.expiration = expiration

/datum/component/anti_magic/Destroy(force, silent)
	QDEL_NULL(drain_antimagic)
	QDEL_NULL(expiration)
	return ..()

/datum/component/anti_magic/proc/on_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if(!(inventory_flags & slot)) //Check that the slot is valid for antimagic
		UnregisterSignal(equipper, COMSIG_MOB_RECEIVE_MAGIC)
		UnregisterSignal(equipper, COMSIG_MOB_RESTRICT_MAGIC)
		return
	RegisterSignal(equipper, COMSIG_MOB_RECEIVE_MAGIC, PROC_REF(block_receiving_magic), override = TRUE)
	RegisterSignal(equipper, COMSIG_MOB_RESTRICT_MAGIC, PROC_REF(restrict_casting_magic), override = TRUE)

	if(!casting_restriction_alert)
		// Check to see if we have any spells that are blocked due to antimagic
		for(var/datum/action/cooldown/spell/magic_spell in equipper.actions)
			if(!(magic_spell.spell_requirements & SPELL_REQUIRES_NO_ANTIMAGIC))
				continue

			if(antimagic_flags & magic_spell.antimagic_flags)
				to_chat(equipper, span_warning("[parent] is interfering with your ability to cast magic!"))
				casting_restriction_alert = TRUE
				break

/datum/component/anti_magic/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER

	UnregisterSignal(user, COMSIG_MOB_RECEIVE_MAGIC)
	UnregisterSignal(user, COMSIG_MOB_RESTRICT_MAGIC)
	casting_restriction_alert = FALSE

/datum/component/anti_magic/proc/block_receiving_magic(mob/living/carbon/user, casted_magic_flags, charge_cost, list/protection_was_used)
	SIGNAL_HANDLER

	// if any protection sources exist in our list then we already blocked the magic
	if(!istype(user) || protection_was_used.len)
		return

	// disclaimer - All anti_magic sources will be drained a charge_cost
	if(casted_magic_flags & antimagic_flags)
		var/mutable_appearance/antimagic_effect
		var/antimagic_color
		// im a programmer not shakesphere to the future grammar nazis that come after me for this
		var/visible_subject = ismob(parent) ? "[user.p_they()]" : "[parent]"
		var/self_subject = ismob(parent) ? "you" : "[parent]"

		if(casted_magic_flags & antimagic_flags & MAGIC_RESISTANCE)
			user.visible_message(
				span_warning("[user] pulses red as [visible_subject] absorbs magic energy!"),
				span_userdanger("An intense magical aura pulses around [self_subject] as it dissipates into the air!"),
			)
			antimagic_effect = mutable_appearance('icons/effects/effects.dmi', "shield-red", MOB_SHIELD_LAYER)
			antimagic_color = LIGHT_COLOR_BLOOD_MAGIC
			playsound(user, 'sound/magic/magic_block.ogg', 50, TRUE)
		else if(casted_magic_flags & antimagic_flags & MAGIC_RESISTANCE_HOLY)
			user.visible_message(
				span_warning("[user] starts to glow as [visible_subject] emits a halo of light!"),
				span_userdanger("A feeling of warmth washes over [self_subject] as rays of light surround your body and protect you!"),
			)
			antimagic_effect = mutable_appearance('icons/effects/genetics.dmi', "servitude", -MUTATIONS_LAYER)
			antimagic_color = LIGHT_COLOR_HOLY_MAGIC
			playsound(user, 'sound/magic/magic_block_holy.ogg', 50, TRUE)
		else if(casted_magic_flags & antimagic_flags & MAGIC_RESISTANCE_MIND)
			user.visible_message(
				span_warning("[user] forehead shines as [visible_subject] repulses magic from their mind!"),
				span_userdanger("A feeling of cold splashes on [self_subject] as your forehead reflects magic usering your mind!"),
			)
			antimagic_effect = mutable_appearance('icons/effects/genetics.dmi', "telekinesishead", MOB_SHIELD_LAYER)
			antimagic_color = LIGHT_COLOR_DARK_BLUE
			playsound(user, 'sound/magic/magic_block_mind.ogg', 50, TRUE)

		user.mob_light(_range = 2, _color = antimagic_color, _duration = 5 SECONDS)
		user.add_overlay(antimagic_effect)
		addtimer(CALLBACK(user, TYPE_PROC_REF(/atom, cut_overlay), antimagic_effect), 50)

		if(ismob(parent))
			return COMPONENT_MAGIC_BLOCKED

		var/has_limited_charges = !(charges == INFINITY)
		var/charge_was_drained = charge_cost > 0
		if(has_limited_charges && charge_was_drained)
			protection_was_used += parent
			drain_antimagic?.Invoke(user, parent)
			charges -= charge_cost
			if(charges <= 0)
				expiration?.Invoke(user, parent)
				qdel(src)
		return COMPONENT_MAGIC_BLOCKED
	return NONE

/// cannot cast magic with the same type of antimagic present
/datum/component/anti_magic/proc/restrict_casting_magic(mob/user, magic_flags)
	SIGNAL_HANDLER

	if(magic_flags & antimagic_flags)
		if(HAS_TRAIT(user, TRAIT_ANTIMAGIC_NO_SELFBLOCK)) // this trait bypasses magic casting restrictions
			return NONE
		return COMPONENT_MAGIC_BLOCKED

	return NONE
