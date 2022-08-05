/datum/action/cooldown/spell/shapeshift
	button_icon_state = "shapeshift"
	school = SCHOOL_TRANSMUTATION
	cooldown_time = 10 SECONDS

	/// Our spell's requrements before we shapeshifted. Stored on shapeshift.
	var/pre_shift_requirements

	/// Whehter we revert to our human form on death.
	var/revert_on_death = TRUE
	/// Whether we die when our shapeshifted form is killed
	var/die_with_shapeshifted_form = TRUE
	/// Whether we convert our health from one form to another
	var/convert_damage = TRUE
	/// If convert damage is true, the damage type we deal when converting damage back and forth
	var/convert_damage_type = BRUTE

	/// Our chosen type
	var/mob/living/shapeshift_type
	/// All possible types we can become
	var/list/atom/possible_shapes

/datum/action/cooldown/spell/shapeshift/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/shapeshift/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	if(shapeshift_type)
		return

	if(length(possible_shapes) == 1)
		shapeshift_type = possible_shapes[1]
		return

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
		custom_check = CALLBACK(src, .proc/check_menu, cast_on),
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

	// Do the shift back or forth
	if(is_shifted(cast_on))
		do_unshapeshift(cast_on)
	else
		do_shapeshift(cast_on)

	// The shift is done, let's make sure they're in a valid state now
	// If we're not ventcrawling, we don't need to mind
	if(!currently_ventcrawling)
		return

	// We are ventcrawling - can our new form support ventcrawling?
	if(HAS_TRAIT(cast_on, TRAIT_VENTCRAWLER_ALWAYS) || HAS_TRAIT(cast_on, TRAIT_VENTCRAWLER_NUDE))
		return

	// Uh oh. You've shapeshifted into something that can't fit into a vent, while ventcrawling.
	eject_from_vents(cast_on)

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
	cast_on.death()
	qdel(cast_on)

/// Callback for the radial that allows the user to choose their species.
/datum/action/cooldown/spell/shapeshift/proc/check_menu(mob/living/caster)
	if(QDELETED(src))
		return FALSE
	if(QDELETED(caster))
		return FALSE

	return !caster.incapacitated()

/// Check if we're currently shifted by trying to find the shapechange status effect in our loc
/// Returns a truthy value (a status_effect instance) if we're shapeshifted, or null if we're not.
/datum/action/cooldown/spell/shapeshift/proc/is_shifted(mob/living/cast_on)
	var/mob/living/shape = cast_on.loc
	if(!istype(shape))
		return null

	return shape.has_status_effect(/datum/status_effect/shapechange_mob)

/// Actually does the shapeshift, for the caster.
/datum/action/cooldown/spell/shapeshift/proc/do_shapeshift(mob/living/caster)
	if(is_shifted(caster))
		to_chat(caster, span_warning("You're already shapeshifted, but for some reason casting this tried to shapeshift you again!"))
		CRASH("[type] called do_shapeshift while shapeshifted.")


	// Make sure it's castable even in their new form.
	pre_shift_requirements = spell_requirements
	spell_requirements &= ~(SPELL_REQUIRES_HUMAN|SPELL_REQUIRES_WIZARD_GARB)

	var/mob/living/new_shape = create_shapeshift_mob(caster.loc)
	return new_shape.apply_status_effect(/datum/status_effect/shapechange_mob, caster, src)

/// Actually does the un-shapeshift, from the caster. (Caster is a shapeshifted mob.)
/datum/action/cooldown/spell/shapeshift/proc/do_unshapeshift(mob/living/caster)
	// Restore the requirements. Might mess with admin memes.
	spell_requirements = pre_shift_requirements
	pre_shift_requirements = null

	return caster.remove_status_effect(/datum/status_effect/shapechange_mob)

/// Helper proc that instantiates the mob we shapeshift into.
/// Returns an instance of a living mob. Can be overridden.
/datum/action/cooldown/spell/shapeshift/proc/create_shapeshift_mob(atom/loc)
	return new shapeshift_type(loc)
