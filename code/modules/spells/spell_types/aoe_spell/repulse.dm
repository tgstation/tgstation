/datum/action/cooldown/spell/aoe/repulse
	/// The max throw range of the repulsioon.
	var/max_throw = 5
	/// A visual effect to be spawned on people who are thrown away.
	var/obj/effect/sparkle_path = /obj/effect/temp_visual/gravpush
	/// The moveforce of the throw done by the repulsion.
	var/repulse_force = MOVE_FORCE_EXTREMELY_STRONG

/datum/action/cooldown/spell/aoe/repulse/get_caster_from_target(atom/target)
	if(istype(target.loc, /obj/structure/closet))
		return target

	return ..()

/datum/action/cooldown/spell/aoe/repulse/is_valid_target(atom/cast_on)
	return ..() || istype(cast_on.loc, /obj/structure/closet)

/datum/action/cooldown/spell/aoe/repulse/cast(atom/cast_on)
	if(istype(cast_on.loc, /obj/structure/closet))
		var/obj/structure/closet/open_closet = cast_on.loc
		open_closet.open(force = TRUE)
		open_closet.visible_message(span_warning("[open_closet] suddenly flies open!"))

	return ..()

/datum/action/cooldown/spell/aoe/repulse/get_things_to_cast_on(atom/center)
	var/list/things = list()
	for(var/atom/movable/nearby_movable in view(aoe_radius, center))
		if(nearby_movable == owner || nearby_movable == center)
			continue
		if(nearby_movable.anchored)
			continue

		things += nearby_movable

	return things

/datum/action/cooldown/spell/aoe/repulse/cast_on_thing_in_aoe(atom/movable/victim, atom/caster)
	if(ismob(victim))
		var/mob/victim_mob = victim
		if(victim_mob.can_block_magic(antimagic_flags))
			return

	var/turf/throwtarget = get_edge_target_turf(caster, get_dir(caster, get_step_away(victim, caster)))
	var/dist_from_caster = get_dist(victim, caster)

	if(dist_from_caster == 0)
		if(isliving(victim))
			var/mob/living/victim_living = victim
			victim_living.Paralyze(10 SECONDS)
			victim_living.adjustBruteLoss(5)
			to_chat(victim, span_userdanger("You're slammed into the floor by [caster]!"))
	else
		if(sparkle_path)
			// Created sparkles will disappear on their own
			new sparkle_path(get_turf(victim), get_dir(caster, victim))

		if(isliving(victim))
			var/mob/living/victim_living = victim
			victim_living.Paralyze(4 SECONDS)
			to_chat(victim, span_userdanger("You're thrown back by [caster]!"))

		// So stuff gets tossed around at the same time.
		victim.safe_throw_at(
			target = throwtarget,
			range = clamp((max_throw - (clamp(dist_from_caster - 2, 0, dist_from_caster))), 3, max_throw),
			speed = 1,
			thrower = ismob(caster) ? caster : null,
			force = repulse_force,
		)

/datum/action/cooldown/spell/aoe/repulse/wizard
	name = "Repulse"
	desc = "This spell throws everything around the user away."
	button_icon_state = "repulse"
	sound = 'sound/magic/repulse.ogg'

	school = SCHOOL_EVOCATION
	invocation = "GITTAH WEIGH"
	invocation_type = INVOCATION_SHOUT
	aoe_radius = 5

	cooldown_time = 40 SECONDS
	cooldown_reduction_per_rank = 6.25 SECONDS

/datum/action/cooldown/spell/aoe/repulse/xeno
	name = "Tail Sweep"
	desc = "Throw back attackers with a sweep of your tail."
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	button_icon = 'icons/mob/actions/actions_xeno.dmi'
	button_icon_state = "tailsweep"
	panel = "Alien"
	sound = 'sound/magic/tail_swing.ogg'

	cooldown_time = 15 SECONDS
	spell_requirements = NONE

	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	invocation_type = INVOCATION_NONE
	antimagic_flags = NONE
	aoe_radius = 2

	sparkle_path = /obj/effect/temp_visual/dir_setting/tailsweep

/datum/action/cooldown/spell/aoe/repulse/xeno/cast(atom/cast_on)
	if(iscarbon(cast_on))
		var/mob/living/carbon/carbon_caster = cast_on
		playsound(get_turf(carbon_caster), 'sound/voice/hiss5.ogg', 80, TRUE, TRUE)
		carbon_caster.spin(6, 1)

	return ..()
