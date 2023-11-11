/obj/projectile/temp/ice_demon
	name = "ice blast"
	icon_state = "ice_2"
	damage = 5
	damage_type = BURN
	armor_flag = ENERGY
	speed = 1
	pixel_speed_multiplier = 0.25
	temperature = -75

/datum/action/cooldown/mob_cooldown/ice_demon_teleport
	name = "Bluespace Teleport"
	desc = "Teleport towards a destination target!"
	button_icon = 'icons/obj/ore.dmi'
	button_icon_state = "bluespace_crystal"
	cooldown_time = 3 SECONDS
	melee_cooldown_time = 0 SECONDS
	///time delay before teleport
	var/time_delay = 0.5 SECONDS

/datum/action/cooldown/mob_cooldown/ice_demon_teleport/Activate(atom/target_atom)
	if(isclosedturf(get_turf(target_atom)))
		owner.balloon_alert(owner, "blocked!")
		return FALSE
	animate(owner, transform = matrix().Scale(0.8), time = time_delay, easing = SINE_EASING)
	addtimer(CALLBACK(src, PROC_REF(teleport_to_turf), target_atom), time_delay)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/ice_demon_teleport/proc/teleport_to_turf(atom/target)
	animate(owner, transform = matrix(), time = 0.5 SECONDS, easing = SINE_EASING)
	do_teleport(teleatom = owner, destination = target, channel = TELEPORT_CHANNEL_BLUESPACE, forced = TRUE)

/datum/action/cooldown/mob_cooldown/slippery_ice_floors
	name = "Iced Floors"
	desc = "Summon slippery ice floors all around!"
	button_icon = 'icons/turf/floors/ice_turf.dmi'
	button_icon_state = "ice_turf-6"
	cooldown_time = 2 SECONDS
	click_to_activate = FALSE
	melee_cooldown_time = 0 SECONDS
	///perimeter we will spawn the iced floors on
	var/radius = 1
	///intervals we will spawn the ice floors in
	var/spread_duration = 0.2 SECONDS

/datum/action/cooldown/mob_cooldown/slippery_ice_floors/Activate(atom/target_atom)
	for(var/i in 0 to radius)
		var/list/list_of_turfs = border_diamond_range_turfs(owner, i)
		addtimer(CALLBACK(src, PROC_REF(spawn_icy_floors), list_of_turfs), i * spread_duration)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/slippery_ice_floors/proc/spawn_icy_floors(list/list_of_turfs)
	if(!length(list_of_turfs))
		return
	for(var/turf/location in list_of_turfs)
		if(isnull(location))
			continue
		if(isclosedturf(location) || isspaceturf(location))
			continue
		new /obj/effect/temp_visual/slippery_ice(location)

/obj/effect/temp_visual/slippery_ice
	name = "slippery acid"
	icon = 'icons/turf/floors/ice_turf.dmi'
	icon_state = "ice_turf-6"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	duration = 3 SECONDS
	alpha = 100
	/// how long does it take for the effect to phase in
	var/phase_in_period = 2 SECONDS

/obj/effect/temp_visual/slippery_ice/Initialize(mapload)
	. = ..()
	animate(src, alpha = 160, time = phase_in_period)
	animate(alpha = 0, time = duration - phase_in_period) /// slowly fade out of existence
	addtimer(CALLBACK(src, PROC_REF(add_slippery_component), phase_in_period)) //only become slippery after we phased in

/obj/effect/temp_visual/slippery_ice/proc/add_slippery_component()
	AddComponent(/datum/component/slippery, 2 SECONDS)

/datum/action/cooldown/spell/conjure/create_afterimages
	name = "Create After Images"
	button_icon = 'icons/mob/simple/icemoon/icemoon_monsters.dmi'
	button_icon_state = "ice_demon"
	spell_requirements = NONE
	cooldown_time = 1 MINUTES
	summon_type = list(/mob/living/basic/mining/demon_afterimage)
	summon_radius = 1
	summon_amount = 2
	///max number of after images
	var/max_afterimages = 2
	///How many clones do we have summoned
	var/number_of_afterimages = 0

/datum/action/cooldown/spell/conjure/create_afterimages/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	if(number_of_afterimages >= max_afterimages)
		return FALSE
	return TRUE

/datum/action/cooldown/spell/conjure/create_afterimages/post_summon(atom/summoned_object, atom/cast_on)
	var/mob/living/basic/created_copy = summoned_object
	created_copy.AddComponent(/datum/component/joint_damage, overlord_mob = owner)
	RegisterSignals(created_copy, list(COMSIG_QDELETING, COMSIG_LIVING_DEATH), PROC_REF(delete_copy))
	number_of_afterimages++

/datum/action/cooldown/spell/conjure/create_afterimages/proc/delete_copy(mob/source)
	SIGNAL_HANDLER

	UnregisterSignal(source, list(COMSIG_QDELETING, COMSIG_LIVING_DEATH))
	number_of_afterimages--
