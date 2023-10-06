/// Helper for checking of someone's shapeshifted currently.
#define is_shifted(mob) mob.has_status_effect(/datum/status_effect/shapechange_mob/from_spell)

/**
 * Shapeshift spells.
 *
 * Allows the caster to transform to and from a different mob type.
 */
/datum/action/cooldown/spell/shapeshift
	button_icon_state = "shapeshift"
	school = SCHOOL_TRANSMUTATION
	cooldown_time = 10 SECONDS

	/// Our spell's requrements before we shapeshifted. Stored on shapeshift so we can restore them after unshifting.
	var/pre_shift_requirements

	/// Whether we revert to our human form on death.
	var/revert_on_death = TRUE
	/// Whether we die when our shapeshifted form is killed
	var/die_with_shapeshifted_form = TRUE
	/// Whether we convert our health from one form to another
	var/convert_damage = TRUE
	/// If convert damage is true, the damage type we deal when converting damage back and forth
	var/convert_damage_type = BRUTE

	/// Our chosen type.
	var/mob/living/shapeshift_type
	/// All possible types we can become.
	/// This should be implemented even if there is only one choice.
	var/list/atom/possible_shapes

/datum/action/cooldown/spell/shapeshift/Remove(mob/remove_from)
	unshift_owner()
	return ..()

/datum/action/cooldown/spell/shapeshift/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/shapeshift/before_cast(mob/living/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	if(shapeshift_type)
		// If another shapeshift spell was casted while we're already shifted, they could technically go to do_unshapeshift().
		// However, we don't really want people casting shapeshift A to un-shapeshift from shapeshift B,
		// as it could cause bugs or unintended behavior. So we'll just stop them here.
		if(is_shifted(cast_on) && !is_type_in_list(cast_on, possible_shapes))
			to_chat(cast_on, span_warning("This spell won't un-shapeshift you from this form!"))
			return . | SPELL_CANCEL_CAST

		return

	if(length(possible_shapes) == 1)
		shapeshift_type = possible_shapes[1]
		return

	// Not bothering with caching these as they're only ever shown once
	var/list/shape_names_to_types = list()
	var/list/shape_names_to_image = list()
	if(!length(shape_names_to_types) || !length(shape_names_to_image))
		for(var/atom/path as anything in possible_shapes)
			var/shape_name = initial(path.name)
			shape_names_to_types[shape_name] = path
			shape_names_to_image[shape_name] = image(icon = initial(path.icon), icon_state = initial(path.icon_state))

	var/picked_type = show_radial_menu(
		cast_on,
		cast_on,
		shape_names_to_image,
		custom_check = CALLBACK(src, PROC_REF(check_menu), cast_on),
		radius = 38,
	)

	if(!picked_type)
		return . | SPELL_CANCEL_CAST

	var/atom/shift_type = shape_names_to_types[picked_type]
	if(!ispath(shift_type))
		return . | SPELL_CANCEL_CAST

	shapeshift_type = shift_type || pick(possible_shapes)
	if(QDELETED(src) || QDELETED(owner) || !can_cast_spell(feedback = FALSE))
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/shapeshift/cast(mob/living/cast_on)
	. = ..()
	cast_on.buckled?.unbuckle_mob(cast_on, force = TRUE)

	var/currently_ventcrawling = (cast_on.movement_type & VENTCRAWLING)
	var/mob/living/resulting_mob

	// Do the shift back or forth
	if(is_shifted(cast_on))
		resulting_mob = do_unshapeshift(cast_on)
	else
		resulting_mob = do_shapeshift(cast_on)

	// The shift is done, let's make sure they're in a valid state now
	// If we're not ventcrawling, we don't need to mind
	if(!currently_ventcrawling || !resulting_mob)
		return

	// We are ventcrawling - can our new form support ventcrawling?
	if(HAS_TRAIT(resulting_mob, TRAIT_VENTCRAWLER_ALWAYS) || HAS_TRAIT(resulting_mob, TRAIT_VENTCRAWLER_NUDE))
		return

	// Uh oh. You've shapeshifted into something that can't fit into a vent, while ventcrawling.
	eject_from_vents(resulting_mob)

/// Whenever someone shapeshifts within a vent,
/// and enters a state in which they are no longer a ventcrawler,
/// they are brutally ejected from the vents. In the form of gibs.
/datum/action/cooldown/spell/shapeshift/proc/eject_from_vents(mob/living/cast_on)
	var/obj/machinery/atmospherics/pipe_you_die_in = cast_on.loc
	var/datum/pipeline/our_pipeline
	var/pipenets = pipe_you_die_in.return_pipenets()
	if(islist(pipenets))
		our_pipeline = pipenets[1]
	else
		our_pipeline = pipenets

	to_chat(cast_on, span_userdanger("Casting [src] inside of [pipe_you_die_in] quickly turns you into a bloody mush!"))
	var/obj/effect/gib_type = isalien(cast_on) ? /obj/effect/gibspawner/xeno : /obj/effect/gibspawner/generic

	for(var/obj/machinery/atmospherics/components/unary/possible_vent in range(10, get_turf(cast_on)))
		if(length(possible_vent.parents) && possible_vent.parents[1] == our_pipeline)
			new gib_type(get_turf(possible_vent))
			playsound(possible_vent, 'sound/effects/reee.ogg', 75, TRUE)

	priority_announce("We detected a pipe blockage around [get_area(get_turf(cast_on))], please dispatch someone to investigate.", "Central Command")
	// Gib our caster, and make sure to leave nothing behind
	// (If we leave something behind, it'll drop on the turf of the pipe, which is kinda wrong.)
	cast_on.investigate_log("has been gibbed by shapeshifting while ventcrawling.", INVESTIGATE_DEATHS)
	cast_on.gib()

/// Callback for the radial that allows the user to choose their species.
/datum/action/cooldown/spell/shapeshift/proc/check_menu(mob/living/caster)
	if(QDELETED(src))
		return FALSE
	if(QDELETED(caster))
		return FALSE

	return !caster.incapacitated()

/// Actually does the shapeshift, for the caster.
/datum/action/cooldown/spell/shapeshift/proc/do_shapeshift(mob/living/caster)
	var/mob/living/new_shape = create_shapeshift_mob(caster.loc)
	var/datum/status_effect/shapechange_mob/shapechange = new_shape.apply_status_effect(/datum/status_effect/shapechange_mob/from_spell, caster, src)
	if(!shapechange)
		// We failed to shift, maybe because we were already shapeshifted?
		// Whatver the case, this shouldn't happen, so throw a stack trace.
		to_chat(caster, span_warning("You can't shapeshift in this form!"))
		stack_trace("[type] do_shapeshift was called when the mob was already shapeshifted (from a spell).")
		return

	// Make sure it's castable even in their new form.
	pre_shift_requirements = spell_requirements
	spell_requirements &= ~(SPELL_REQUIRES_HUMAN|SPELL_REQUIRES_WIZARD_GARB)
	ADD_TRAIT(new_shape, TRAIT_DONT_WRITE_MEMORY, SHAPESHIFT_TRAIT) // If you shapeshift into a pet subtype we don't want to update Poly's deathcount or something when you die

	// Make sure that if you shapechanged into a bot, the AI can't just turn you off.
	var/mob/living/simple_animal/bot/polymorph_bot = new_shape
	if (istype(polymorph_bot))
		polymorph_bot.bot_cover_flags |= BOT_COVER_EMAGGED
		polymorph_bot.bot_mode_flags &= ~BOT_MODE_REMOTE_ENABLED

	return new_shape

/// Actually does the un-shapeshift, from the caster. (Caster is a shapeshifted mob.)
/datum/action/cooldown/spell/shapeshift/proc/do_unshapeshift(mob/living/caster)
	var/datum/status_effect/shapechange_mob/shapechange = caster.has_status_effect(/datum/status_effect/shapechange_mob/from_spell)
	if(!shapechange)
		// We made it to do_unshapeshift without having a shapeshift status effect, this shouldn't happen.
		to_chat(caster, span_warning("You can't un-shapeshift from this form!"))
		stack_trace("[type] do_unshapeshift was called when the mob wasn't even shapeshifted (from a spell).")
		return

	// Restore the requirements.
	spell_requirements = pre_shift_requirements
	pre_shift_requirements = null

	var/mob/living/unshapeshifted_mob = shapechange.caster_mob
	caster.remove_status_effect(/datum/status_effect/shapechange_mob/from_spell)
	return unshapeshifted_mob

/// Helper proc that instantiates the mob we shapeshift into.
/// Returns an instance of a living mob. Can be overridden.
/datum/action/cooldown/spell/shapeshift/proc/create_shapeshift_mob(atom/loc)
	return new shapeshift_type(loc)

/// Removes an active shapeshift effect from the owner
/datum/action/cooldown/spell/shapeshift/proc/unshift_owner()
	if (isnull(owner))
		return
	if (is_shifted(owner))
		do_unshapeshift(owner)

#undef is_shifted
