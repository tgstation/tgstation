/obj/item/book/granter/action/spell

/obj/item/book/granter/action/spell/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_MAGICALLY_CHARGED, PROC_REF(on_magic_charge))

/**
 * Signal proc for [COMSIG_ITEM_MAGICALLY_CHARGED]
 *
 * Refreshes uses on our spell granter, or make it quicker to read if it's already infinite use
 */
/obj/item/book/granter/action/spell/proc/on_magic_charge(datum/source, datum/action/cooldown/spell/spell, mob/living/caster)
	SIGNAL_HANDLER

	// What're the odds someone uses 2000 uses of an infinite use book?
	if(uses >= INFINITY - 2000)
		to_chat(caster, span_notice("This book is infinite use and can't be recharged, \
			yet the magic has improved it somehow..."))
		pages_to_mastery = max(pages_to_mastery - 1, 1)
		return COMPONENT_ITEM_CHARGED|COMPONENT_ITEM_BURNT_OUT

	if(prob(80))
		caster.dropItemToGround(src, TRUE)
		visible_message(span_warning("[src] catches fire and burns to ash!"))
		new /obj/effect/decal/cleanable/ash(drop_location())
		qdel(src)
		return COMPONENT_ITEM_BURNT_OUT

	uses++
	return COMPONENT_ITEM_CHARGED

/obj/item/book/granter/action/spell/can_learn(mob/living/user)
	if(!granted_action)
		CRASH("Someone attempted to learn [type], which did not have an spell set.")
	if(locate(granted_action) in user.actions)
		if(HAS_MIND_TRAIT(user, TRAIT_MAGICALLY_GIFTED))
			to_chat(user, span_warning("You're already far more versed in the spell [action_name] \
				than this flimsy how-to book can provide!"))
		else
			to_chat(user, span_warning("You've already know the spell [action_name]!"))
		return FALSE
	return TRUE

/obj/item/book/granter/action/spell/on_reading_start(mob/living/user)
	to_chat(user, span_notice("You start reading about casting [action_name]..."))
	return TRUE

/obj/item/book/granter/action/spell/on_reading_finished(mob/living/user)
	to_chat(user, span_notice("You feel like you've experienced enough to cast [action_name]!"))
	var/datum/action/cooldown/spell/new_spell = new granted_action(user.mind || user)
	new_spell.Grant(user)
	user.log_message("learned the spell [action_name] ([new_spell])", LOG_ATTACK, color = "orange")
	if(uses <= 0)
		user.visible_message(span_warning("[src] glows dark for a second!"))

/obj/item/book/granter/action/spell/recoil(mob/living/user)
	user.visible_message(span_warning("[src] glows in a black light!"))

/// Simple granter that's replaced with a random spell granter on Initialize.
/obj/item/book/granter/action/spell/random
	icon_state = "random_book"

/obj/item/book/granter/action/spell/random/Initialize(mapload)
	. = ..()
	var/static/list/banned_spells = list(
		/obj/item/book/granter/action/spell/true_random,
	) + typesof(/obj/item/book/granter/action/spell/mime)

	var/real_type = pick(subtypesof(/obj/item/book/granter/action/spell) - banned_spells)
	new real_type(loc)

	return INITIALIZE_HINT_QDEL

/// A more volatile granter that can potentially have any spell within. Use wisely.
/obj/item/book/granter/action/spell/true_random
	icon_state = "random_book"
	desc = "You feel as if anything could be gained from this book."
	/// A list of schools we probably shouldn't grab, for various reasons
	var/static/list/blacklisted_schools = list(SCHOOL_UNSET, SCHOOL_HOLY, SCHOOL_MIME)

/obj/item/book/granter/action/spell/true_random/Initialize(mapload)
	. = ..()

	var/static/list/spell_options
	if(!spell_options)
		spell_options = subtypesof(/datum/action/cooldown/spell)
		for(var/datum/action/cooldown/spell/spell as anything in spell_options)
			if(initial(spell.school) in blacklisted_schools)
				spell_options -= spell
			if(initial(spell.name) == "Spell") // Abstract types
				spell_options -= spell

	granted_action = pick(spell_options)
	action_name = lowertext(initial(granted_action.name))
