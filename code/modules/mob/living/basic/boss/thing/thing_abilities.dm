/obj/structure/thing_boss_spike
	name = "blades"
	desc = "A sharp flurry of blades erupting from the ground"
	icon = 'icons/mob/simple/meteor_heart.dmi'
	icon_state = "spikes_idle"
	density = TRUE
	max_integrity = 1 // 1 hit
	var/expiry_time = 10 SECONDS

/obj/structure/thing_boss_spike/Initialize(mapload)
	. = ..()
	QDEL_IN(src, expiry_time)
	addtimer(CALLBACK(src, PROC_REF(impale)), 0.1 SECONDS)

/obj/structure/thing_boss_spike/proc/impale()
	var/turf/our_turf = get_turf(src)
	var/hit_someone = FALSE
	for(var/mob/living/victim in our_turf)
		if (ismegafauna(victim))
			continue
		hit_someone = TRUE
		victim.apply_damage(25, damagetype = BRUTE, sharpness = SHARP_POINTY)
	if (hit_someone)
		playsound(src, 'sound/items/weapons/slice.ogg', vol = 50, vary = TRUE, pressure_affected = FALSE)
	else
		playsound(src, 'sound/misc/splort.ogg', vol = 25, vary = TRUE, pressure_affected = FALSE)

/obj/structure/thing_boss_spike/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(damage_amount)
		playsound(src, 'sound/effects/blob/blobattack.ogg', 50, TRUE)
	else
		playsound(src, 'sound/items/weapons/tap.ogg', 50, TRUE)

/obj/structure/thing_boss_spike/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(istype(mover, /mob/living/basic/boss/thing)) //Make sure looking at appropriate border
		return TRUE

/obj/structure/thing_boss_spike/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	if(istype(pass_info.caller_ref?.resolve(), /mob/living/basic/boss/thing))
		return TRUE
	return ..()

/obj/effect/temp_visual/telegraphing/exclamation
	icon = 'icons/mob/telegraphing/telegraph.dmi'
	icon_state = "exclamation"
	duration = 1 SECONDS

/obj/effect/temp_visual/telegraphing/exclamation/animated
	alpha = 0

/obj/effect/temp_visual/telegraphing/exclamation/animated/Initialize(mapload)
	. = ..()
	transform = matrix()*2
	animate(src, alpha = 255, transform = matrix(), time = duration/3)

/obj/effect/temp_visual/telegraphing/big
	icon = 'icons/mob/telegraphing/telegraph_96x96.dmi'
	icon_state = "target_largebox"
	pixel_x = -32
	pixel_y = -32
	color = COLOR_RED
	duration = 2 SECONDS

/datum/action/cooldown/mob_cooldown/the_thing
	var/list/available_in_phases = list(1,2,3)

/datum/action/cooldown/mob_cooldown/the_thing/IsAvailable(feedback)
	var/mob/living/basic/boss/thing/the_thing = owner
	if(!istype(the_thing) || !the_thing.ruin_spawned)
		return ..()
	return ..() && !!(the_thing.phase in available_in_phases)

/datum/action/cooldown/mob_cooldown/the_thing/decimate
	name = "Decimate"
	desc = "Create spikes in a radius."
	button_icon = 'icons/obj/weapons/stabby.dmi'
	button_icon_state = "huntingknife"
	click_to_activate = FALSE
	cooldown_time = 10 SECONDS
	shared_cooldown = NONE

/datum/action/cooldown/mob_cooldown/the_thing/decimate/Activate(atom/caster)
	if(!COOLDOWN_FINISHED(src, cooldown_time) || HAS_TRAIT_FROM(caster, TRAIT_IMMOBILIZED, ACTION_TRAIT))
		return FALSE
	ADD_TRAIT(caster, TRAIT_IMMOBILIZED, ACTION_TRAIT)
	caster.Shake(1.4, 0.8, 0.3 SECONDS)
	caster.visible_message(span_danger("[caster] shakes violently!"))
	for(var/turf/open/target in RANGE_TURFS(2, caster) - caster.loc)
		new /obj/effect/temp_visual/telegraphing/exclamation(target)
	addtimer(CALLBACK(src, PROC_REF(make_spikes), caster), 1 SECONDS)
	StartCooldown(cooldown_time)

/datum/action/cooldown/mob_cooldown/the_thing/decimate/proc/make_spikes(atom/caster)
	REMOVE_TRAIT(caster, TRAIT_IMMOBILIZED, ACTION_TRAIT)
	for(var/turf/open/target in RANGE_TURFS(2, caster))
		if(target == caster.loc)
			continue
		new /obj/effect/temp_visual/mook_dust(target)
		new /obj/structure/thing_boss_spike(target)

/datum/action/cooldown/mob_cooldown/charge/the_thing
	shared_cooldown = NONE
	charge_damage = 30

/datum/action/cooldown/mob_cooldown/charge/the_thing/do_charge_indicator(atom/charger, atom/charge_target)
	var/turf/target_turf = get_turf(charge_target)
	if(!target_turf)
		return
	new /obj/effect/temp_visual/telegraphing/exclamation(target_turf)
	var/obj/effect/temp_visual/decoy/decoy = new /obj/effect/temp_visual/decoy(charger.loc, charger)
	animate(decoy, alpha = 0, color = COLOR_RED, transform = matrix()*2, time = 3)

/datum/action/cooldown/mob_cooldown/charge/the_thing/hit_target(atom/movable/source, mob/living/target, damage_dealt)
	target.visible_message(span_danger("[source] lunges into [target]!"), span_userdanger("[source] knocks you into the ground, slashing you in the process!"))
	target.apply_damage(damage_dealt, BRUTE)
	playsound(get_turf(target), 'sound/items/weapons/rapierhit.ogg', 100, TRUE)
	shake_camera(target, 4, 3)

/datum/action/cooldown/mob_cooldown/the_thing/big_tendrils
	name = "Decimate"
	desc = "Create spikes in a square around the target."
	button_icon = 'icons/obj/weapons/stabby.dmi'
	button_icon_state = "huntingknife"
	cooldown_time = 5 SECONDS
	shared_cooldown = NONE
	available_in_phases = list(2,3)

/datum/action/cooldown/mob_cooldown/the_thing/big_tendrils/Activate(atom/target)
	if(!COOLDOWN_FINISHED(src, cooldown_time))
		return FALSE
	target = get_turf(target)
	var/mob/living/living_owner = owner
	var/delay = 1 SECONDS
	if(living_owner.health <= living_owner.maxHealth/3 ? 2 : 1)
		new /obj/effect/temp_visual/telegraphing/big(target)
		delay += 1 SECONDS
	else
		new /obj/effect/temp_visual/telegraphing/exclamation(target)
	addtimer(CALLBACK(src, PROC_REF(make_spikes), target), delay)
	StartCooldown(cooldown_time)

/datum/action/cooldown/mob_cooldown/the_thing/big_tendrils/proc/make_spikes(atom/epicenter)
	var/mob/living/living_owner = owner
	var/radius = living_owner.health <= living_owner.maxHealth/3 ? 2 : 1
	for(var/turf/open/target in RANGE_TURFS(radius, epicenter))
		new /obj/effect/temp_visual/mook_dust(target)
		new /obj/structure/thing_boss_spike(target)
