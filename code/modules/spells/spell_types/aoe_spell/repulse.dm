/datum/action/cooldown/spell/aoe/repulse
	/// The max throw range of the repulsioon.
	var/max_throw = 5
	/// A visual effect to be spawned on people who are thrown away.
	var/obj/effect/sparkle_path = /obj/effect/temp_visual/gravpush
	/// The moveforce of the throw done by the repulsion.
	var/repulse_force = MOVE_FORCE_EXTREMELY_STRONG

/datum/action/cooldown/spell/aoe/repulse/is_valid_target(atom/cast_on)
	if(cast_on == owner)
		return FALSE

	if(cast_on.anchored)
		return FALSE

	return ismovable(cast_on)

/datum/action/cooldown/spell/aoe/repulse/get_things_to_cast_on(atom/center)
	return view(outer_radius, center)

/datum/action/cooldown/spell/aoe/repulse/cast_on_thing_in_aoe(atom/cast_on)
	if(ismob(cast_on))
		var/mob/cast_on_mob = cast_on
		if(cast_on_mob.anti_magic_check(anti_magic_check))
			return

	var/turf/throwtarget = get_edge_target_turf(owner, get_dir(owner, get_step_away(cast_on_mob, owner)))
	var/dist_from_caster = get_dist(owner, cast_on_mob)

	if(dist_from_caster == 0)
		if(isliving(cast_on))
			var/mob/living/cast_on_living = cast_on
			cast_on_living.Paralyze(10 SECONDS)
			cast_on_living.adjustBruteLoss(5)
			to_chat(M, span_userdanger("You're slammed into the floor by [owner]!"))
	else
		if(sparkle_path)
			new sparkle_path(get_turf(cast_on), get_dir(user, cast_on)) // Created sparkles will disappear on their own

		if(isliving(cast_on))
			var/mob/living/cast_on_living = cast_on
			cast_on_living.Paralyze(4 SECONDS)
			to_chat(cast_on, span_userdanger("You're thrown back by [owner]!"))

		// So stuff gets tossed around at the same time.
		owner.safe_throw_at(throwtarget, ((clamp((maxthrow - (clamp(dist_from_caster - 2, 0, dist_from_caster))), 3, maxthrow))), 1, owner, force = repulse_force)

/datum/action/cooldown/spell/aoe/repulse/wizard
	name = "Repulse"
	desc = "This spell throws everything around the user away."
	action_icon_state = "repulse"
	sound = 'sound/magic/repulse.ogg'

	school = SCHOOL_EVOCATION
	invocation = "GITTAH WEIGH"
	invocation_type = INVOCATION_SHOUT
	outer_radius = 5

	cooldown_time = 40 SECONDS
	cooldown_reduction_per_rank = 6.25 SECONDS

/datum/action/cooldown/spell/aoe/repulse/wizard/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE

	if(isliving(cast_on))
		var/mob/living/cast_on_living = cast_on
		if(cast_on_living.anti_magic_check())
			return FALSE

	return TRUE

/datum/action/cooldown/spell/aoe/repulse/xeno
	name = "Tail Sweep"
	desc = "Throw back attackers with a sweep of your tail."
	action_icon = 'icons/mob/actions/actions_xeno.dmi'
	action_icon_state = "tailsweep"
	action_background_icon_state = "bg_alien"
	sound = 'sound/magic/tail_swing.ogg'

	cooldown_time =  = 15 SECONDS

	invocation_type = INVOCATION_NONE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	outer_radius = 2

	sparkle_path = /obj/effect/temp_visual/dir_setting/tailsweep

/datum/action/cooldown/spell/aoe/repulse/xeno/cast(atom/cast_on)
	if(iscarbon(user))
		var/mob/living/carbon/carbon_caster = cast_on
		playsound(get_turf(carbon_caster), 'sound/voice/hiss5.ogg', 80, TRUE, TRUE)
		carbon_caster.spin(6, 1)

	return ..()
