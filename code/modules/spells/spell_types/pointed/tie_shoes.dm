
/datum/action/cooldown/spell/pointed/untie_shoes
	name = "Untie Shoes"
	desc = "This unassuming spell unties and then knots the target's shoes."
	ranged_mousepointer = 'icons/effects/mouse_pointers/lace.dmi'
	button_icon_state = "lace"

	school = SCHOOL_CONJURATION
	cooldown_time = 3 SECONDS
	cooldown_reduction_per_rank = 0.2 SECONDS

	spell_max_level = 4
	invocation = "Acetato!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY

	cast_range = INFINITY
	active_msg = "You prepare to tie your target's shoes!"

	/// Ignores inability to tie laces, such as jackboots, magboots, or sandals.
	var/bypass_tie_status = FALSE
	/// Summons shoes to untie if the target has none.
	var/summons_shoes = FALSE

/datum/action/cooldown/spell/pointed/untie_shoes/New(Target)
	. = ..()
	// tgs first spell with multiple invocations!!!!!!
	invocation = pick("Acetato!", "Agaletto!")

/datum/action/cooldown/spell/pointed/untie_shoes/level_spell(bypass_cap)
	. = ..()
	if(spell_level == 2)
		bypass_tie_status = TRUE
		to_chat(owner, span_notice("You will now summon laces on laceless shoes, such as jackboots."))

	if(spell_level == 3)
		summons_shoes = TRUE
		to_chat(owner, span_notice("You will now summon shoes if your target has none."))

	if(spell_level == 4)
		invocation_type = INVOCATION_NONE
		to_chat(owner, span_boldnotice("Your invocations are now silent!"))

/datum/action/cooldown/spell/pointed/untie_shoes/is_valid_target(atom/cast_on)
	return isliving(cast_on)

// We need to override this, as trying to change next_use_time in cast() will just result in it being overridden.
/datum/action/cooldown/spell/pointed/untie_shoes/before_cast(atom/cast_on)
	return ..() | SPELL_NO_IMMEDIATE_COOLDOWN

/datum/action/cooldown/spell/pointed/untie_shoes/cast(mob/living/carbon/cast_on)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(owner, span_warning("The spell had no effect!"))
		return FALSE

	if(isanimal_or_basicmob(cast_on))
		cast_on.add_movespeed_modifier(/datum/movespeed_modifier/magic_ties)
		addtimer(CALLBACK(cast_on, TYPE_PROC_REF(/mob/living, remove_movespeed_modifier), /datum/movespeed_modifier/magic_ties), 3 SECONDS * spell_level, TIMER_UNIQUE|TIMER_OVERRIDE)
		to_chat(owner, span_warning("You tie [cast_on] with weak, magic laces!"))
		if(invocation_type != INVOCATION_NONE) // extra feedback since it's weird for them
			cast_on.balloon_alert_to_viewers("magically tied!")
		else
			cast_on.balloon_alert(owner, "magically tied!")
		playsound(cast_on, 'sound/effects/magic/summonitems_generic.ogg', 50, TRUE)
		return TRUE

	var/shoe_to_cast = /obj/item/clothing/shoes/sneakers/random

	if(HAS_TRAIT(owner, TRAIT_CHUUNIBYOU))
		shoe_to_cast = /obj/item/clothing/shoes/sneakers/marisa
	if(HAS_TRAIT(owner, TRAIT_SPLATTERCASTER))
		shoe_to_cast = /obj/item/clothing/shoes/laceup

	var/obj/item/clothing/shoes/shoes_to_tie = cast_on.shoes

	if(isnull(shoes_to_tie))
		if(!summons_shoes)
			to_chat(owner, span_warning("[cast_on] isn't wearing any shoes!"))
			return FALSE

		shoes_to_tie = new shoe_to_cast(cast_on)
		if(!cast_on.equip_to_slot_or_del(shoes_to_tie,	ITEM_SLOT_FEET))
			to_chat(owner, span_warning("Couldn't equip shoes on [cast_on]!"))
			return FALSE

		if(invocation_type != INVOCATION_NONE)
			playsound(cast_on, 'sound/effects/magic/summonitems_generic.ogg', 50, TRUE)

	switch(shoes_to_tie.tied)
		if(SHOES_TIED)
			if(!shoes_to_tie.can_be_tied)
				if(bypass_tie_status)
					to_chat(owner, span_warning("You magically grant laces to [cast_on]'s shoes!"))
					cast_on.balloon_alert(owner, "laced!")
					shoes_to_tie.can_be_tied = TRUE
					if(invocation_type != INVOCATION_NONE)
						playsound(cast_on, 'sound/effects/magic/summonitems_generic.ogg', 50, TRUE)
					return TRUE
				else
					to_chat(owner, span_warning("[cast_on] is wearing laceless shoes!"))
					cast_on.balloon_alert(owner, "laceless!")
					return FALSE

			to_chat(owner, span_warning("You untie [cast_on]'s shoes!"))
			cast_on.balloon_alert(owner, "untied!")
			shoes_to_tie.adjust_laces(SHOES_UNTIED, force_lacing = TRUE)
		if(SHOES_UNTIED)
			to_chat(owner, span_warning("You knot [cast_on]'s laces!"))
			cast_on.balloon_alert(owner, "knotted!")
			shoes_to_tie.adjust_laces(SHOES_KNOTTED, force_lacing = TRUE)
		if(SHOES_KNOTTED)
			to_chat(owner, span_warning("[cast_on]'s laces are already knotted!"))
			return FALSE

// We need to override this, as trying to change next_use_time in cast() will just result in it being overridden.
/datum/action/cooldown/spell/pointed/untie_shoes/after_cast(atom/cast_on)
	. = ..()
	var/extra_time = 0 SECONDS
	if((cast_on.z != owner.z) || get_dist(cast_on, owner) > 7)
		extra_time += cooldown_time * 10 // :)

	StartCooldown(cooldown_time + extra_time)

/datum/action/cooldown/spell/pointed/untie_shoes/get_spell_title()
	switch(spell_level)
		if(2)
			return "Laceless "
		if(3)
			return "Prankster's "
		if(4)
			return "Sneakerly "
		if(5)
			return "Clown's Own "

	return ""
