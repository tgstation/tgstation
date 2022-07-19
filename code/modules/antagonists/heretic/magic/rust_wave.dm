// Shoots out in a wave-like, what rust heretics themselves get
/datum/action/cooldown/spell/cone/staggered/entropic_plume
	name = "Entropic Plume"
	desc = "Spews forth a disorienting plume that causes enemies to strike each other, briefly blinds them(increasing with range) and poisons them(decreasing with range). Also spreads rust in the path of the plume."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "entropic_plume"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "'NTR'P'C PL'M'"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cone_levels = 5
	respect_density = TRUE

/datum/action/cooldown/spell/cone/staggered/entropic_plume/cast(atom/cast_on)
	. = ..()
	new /obj/effect/temp_visual/dir_setting/entropic(get_step(cast_on, cast_on.dir), cast_on.dir)

/datum/action/cooldown/spell/cone/staggered/entropic_plume/do_turf_cone_effect(turf/target_turf, atom/caster, level)
	target_turf.rust_heretic_act()

/datum/action/cooldown/spell/cone/staggered/entropic_plume/do_mob_cone_effect(mob/living/victim, atom/caster, level)
	if(victim.can_block_magic(antimagic_flags) || IS_HERETIC_OR_MONSTER(victim))
		return
	victim.apply_status_effect(/datum/status_effect/amok)
	victim.apply_status_effect(/datum/status_effect/cloudstruck, (level * 1 SECONDS))
	if(iscarbon(victim))
		var/mob/living/carbon/carbon_victim = victim
		carbon_victim.reagents?.add_reagent(/datum/reagent/eldritch, min(1, 6 - level))

/datum/action/cooldown/spell/cone/staggered/entropic_plume/calculate_cone_shape(current_level)
	if(current_level == cone_levels)
		return 5
	else if(current_level == cone_levels - 1)
		return 3
	else
		return 2

/obj/effect/temp_visual/dir_setting/entropic
	icon = 'icons/effects/160x160.dmi'
	icon_state = "entropic_plume"
	duration = 3 SECONDS

/obj/effect/temp_visual/dir_setting/entropic/setDir(dir)
	. = ..()
	switch(dir)
		if(NORTH)
			pixel_x = -64
		if(SOUTH)
			pixel_x = -64
			pixel_y = -128
		if(EAST)
			pixel_y = -64
		if(WEST)
			pixel_y = -64
			pixel_x = -128

// Shoots a straight line of rusty stuff ahead of the caster, what rust monsters get
/datum/action/cooldown/spell/basic_projectile/rust_wave
	name = "Patron's Reach"
	desc = "Channels energy into your hands to release a wave of rust."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "rust_wave"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 35 SECONDS

	invocation = "SPR'D TH' WO'D"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	projectile_type = /obj/projectile/magic/aoe/rust_wave

/obj/projectile/magic/aoe/rust_wave
	name = "Patron's Reach"
	icon_state = "eldritch_projectile"
	alpha = 180
	damage = 30
	damage_type = TOX
	hitsound = 'sound/weapons/punch3.ogg'
	trigger_range = 0
	ignored_factions = list(FACTION_HERETIC)
	range = 15
	speed = 1

/obj/projectile/magic/aoe/rust_wave/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	playsound(src, 'sound/items/welder.ogg', 75, TRUE)
	var/list/turflist = list()
	var/turf/T1
	turflist += get_turf(src)
	T1 = get_step(src,turn(movement_dir,90))
	turflist += T1
	turflist += get_step(T1,turn(movement_dir,90))
	T1 = get_step(src,turn(movement_dir,-90))
	turflist += T1
	turflist += get_step(T1,turn(movement_dir,-90))
	for(var/turf/T as anything in turflist)
		if(!T || prob(25))
			continue
		T.rust_heretic_act()

/datum/action/cooldown/spell/basic_projectile/rust_wave/short
	name = "Lesser Patron's Reach"
	projectile_type = /obj/projectile/magic/aoe/rust_wave/short

/obj/projectile/magic/aoe/rust_wave/short
	range = 7
	speed = 2
