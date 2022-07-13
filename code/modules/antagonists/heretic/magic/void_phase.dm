/datum/action/cooldown/spell/pointed/void_phase
	name = "Void Phase"
	desc = "Let's you blink to your pointed destination, causes 3x3 aoe damage bubble \
		around your pointed destination and your current location. \
		It has a minimum range of 3 tiles and a maximum range of 9 tiles."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "voidblink"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "RE'L'TY PH'S'E"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cast_range = 9
	/// The minimum range to cast the phase.
	var/min_cast_range = 3
	/// The radius of damage around the void bubble
	var/damage_radius = 1

/datum/action/cooldown/spell/pointed/void_phase/is_valid_target(atom/cast_on)
	// We do the close range check first
	if(get_dist(get_turf(owner), get_turf(cast_on)) < min_cast_range)
		owner.balloon_alert(owner, "too close!")
		return FALSE

	return ..()

/datum/action/cooldown/spell/pointed/void_phase/cast(atom/cast_on)
	. = ..()
	var/turf/source_turf = get_turf(owner)
	var/turf/targeted_turf = get_turf(cast_on)

	new /obj/effect/temp_visual/voidin(source_turf)
	new /obj/effect/temp_visual/voidout(targeted_turf)

	// We handle sounds here so we can disable vary
	playsound(source_turf, 'sound/magic/voidblink.ogg', 60, FALSE)
	playsound(targeted_turf, 'sound/magic/voidblink.ogg', 60, FALSE)

	for(var/mob/living/living_mob in range(damage_radius, source_turf))
		if(IS_HERETIC_OR_MONSTER(living_mob) || living_mob == cast_on)
			continue
		living_mob.apply_damage(40, BRUTE, wound_bonus = CANT_WOUND)

	for(var/mob/living/living_mob in range(damage_radius, targeted_turf))
		if(IS_HERETIC_OR_MONSTER(living_mob) || living_mob == cast_on)
			continue
		living_mob.apply_damage(40, BRUTE, wound_bonus = CANT_WOUND)

	do_teleport(
		owner,
		targeted_turf,
		precision = 1,
		no_effects = TRUE,
		channel = TELEPORT_CHANNEL_MAGIC,
	)

/obj/effect/temp_visual/voidin
	icon = 'icons/effects/96x96.dmi'
	icon_state = "void_blink_in"
	alpha = 150
	duration = 6
	pixel_x = -32
	pixel_y = -32

/obj/effect/temp_visual/voidout
	icon = 'icons/effects/96x96.dmi'
	icon_state = "void_blink_out"
	alpha = 150
	duration = 6
	pixel_x = -32
	pixel_y = -32
