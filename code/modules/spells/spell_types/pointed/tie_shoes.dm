
/datum/action/cooldown/spell/pointed/tie_shoes
	name = "Tie Shoes"
	desc = "This unassuming spell unties and then knots the target's shoes."
	ranged_mousepointer = 'icons/effects/mouse_pointers/lace.dmi'
	button_icon_state = "lace"

	school = SCHOOL_CONJURATION
	cooldown_time = 5 SECONDS
	cooldown_reduction_per_rank = 2 SECONDS

	spell_max_level = 5
	invocation = "Acetato!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY

	cast_range = INFINITY
	active_msg = "You prepare to tie your target's shoes!"

	/// Adds this amount to the next cooldown when cast, per tile.
	var/cooldown_per_tile = 1 SECONDS
	var/bypass_tie_status = FALSE
	var/summons_shoes = FALSE

/datum/action/cooldown/spell/pointed/tie_shoes/level_spell(bypass_cap)
	. = ..()
	cooldown_per_tile = 1 SECONDS - (spell_level * 0.1) // 1 to 0.5
	if(spell_level == 2)
		bypass_tie_status = TRUE
		to_chat(owner, span_notice("You will now be able to tie laceless shoes, such as jackboots."))

	if(spell_level == 3)
		invocation_type = INVOCATION_WHISPER
		to_chat(owner, span_notice("You will now be whisper your incantations."))

	if(spell_level == 4)
		summons_shoes = TRUE
		to_chat(owner, span_notice("You will now summon shoes if your target has none."))

	if(spell_level == 5)
		invocation = null
		invocation_type = INVOCATION_NONE
		to_chat(owner, span_boldnotice("Your invocations are now silent!"))

/datum/action/cooldown/spell/pointed/tie_shoes/is_valid_target(atom/cast_on)
	return isliving(cast_on)

// We need to override this, as trying to change next_use_time in cast() will just result in it being overridden.
/datum/action/cooldown/spell/touch/before_cast(atom/cast_on)
	return ..() | SPELL_NO_IMMEDIATE_COOLDOWN

/datum/action/cooldown/spell/pointed/tie_shoes/cast(mob/living/carbon/cast_on)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(owner, span_warning("The spell had no effect!"))
		return FALSE

	if(isanimal_or_basicmob(cast_on))
		cast_on.add_movespeed_modifier(/datum/movespeed_modifier/magic_ties)
		addtimer(CALLBACK(cast_on, TYPE_PROC_REF(/mob/living, remove_movespeed_modifier), /datum/movespeed_modifier/magic_ties), 3 SECONDS * spell_level, TIMER_UNIQUE|TIMER_OVERRIDE)
		to_chat(owner, span_warning("You tie [cast_on] with weak, magic laces!"))
		return TRUE

	var/obj/item/clothing/shoes/shoes_to_tie = cast_on.shoes

	if(isnull(shoes_to_tie))
		if(summons_shoes)
			shoes_to_tie = new /obj/item/clothing/shoes/sneakers/random(cast_on)
			if(!cast_on.equip_to_slot_or_del(shoes_to_tie, ITEM_SLOT_FEET))
				to_chat(owner, span_warning("Couldn't equip shoes on [cast_on]!"))
				return FALSE
			else
				playsound(cast_on, 'sound/magic/summonitems_generic.ogg', 50, TRUE)
		else
			to_chat(owner, span_warning("[cast_on] isn't wearing any shoes!"))
			return FALSE

	switch(shoes_to_tie.tied)
		if(SHOES_TIED)
			if(!bypass_tie_status && !shoes_to_tie.can_be_tied)
				to_chat(owner, span_warning("[cast_on] is wearing laceless shoes!"))
				return FALSE
			to_chat(owner, span_warning("You untie [cast_on]'s shoes!"))
			shoes_to_tie.adjust_laces(SHOES_UNTIED, force_lacing = TRUE)
		if(SHOES_UNTIED)
			to_chat(owner, span_warning("You knot [cast_on]'s laces!"))
			shoes_to_tie.adjust_laces(SHOES_KNOTTED, force_lacing = TRUE)
		if(SHOES_KNOTTED)
			to_chat(owner, span_warning("[cast_on]'s laces are already knotted!"))
			return FALSE

// We need to override this, as trying to change next_use_time in cast() will just result in it being overridden.
/datum/action/cooldown/spell/pointed/tie_shoes/after_cast(atom/cast_on)
	. = ..()
	var/distance = get_dist(cast_on, owner)
	if(cast_on.z != owner.z)
		distance += 15 // :)

	var/extra_time = distance * cooldown_per_tile

	StartCooldown(cooldown_time + extra_time)
