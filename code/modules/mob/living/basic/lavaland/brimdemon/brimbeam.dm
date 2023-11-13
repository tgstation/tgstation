/// Fires a bloody beam. Brimdemon Blast!
/datum/action/cooldown/mob_cooldown/brimbeam
	name = "brimstone blast"
	desc = "Unleash a barrage of infernal energies in the targeted direction."
	button_icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	button_icon_state = "brimdemon_firing"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"
	click_to_activate = TRUE
	cooldown_time = 5 SECONDS
	melee_cooldown_time = 0
	/// How far does our beam go?
	var/beam_range = 10
	/// How long does our beam last?
	var/beam_duration = 2 SECONDS
	/// How long do we wind up before firing?
	var/charge_duration = 1 SECONDS
	/// Overlay we show when we're about to fire
	var/static/image/direction_overlay = image('icons/mob/simple/lavaland/lavaland_monsters.dmi', "brimdemon_telegraph_dir")
	/// A list of all the beam parts.
	var/list/beam_parts = list()

/datum/action/cooldown/mob_cooldown/brimbeam/Destroy()
	extinguish_laser()
	return ..()

/datum/action/cooldown/mob_cooldown/brimbeam/Activate(atom/target)
	StartCooldown(360 SECONDS)

	owner.face_atom(target)
	owner.move_resist = MOVE_FORCE_VERY_STRONG
	owner.add_overlay(direction_overlay)
	owner.balloon_alert_to_viewers("charging...")

	var/fully_charged = do_after(owner, delay = charge_duration, target = owner)
	owner.cut_overlay(direction_overlay)
	if (!fully_charged)
		StartCooldown()
		return TRUE

	if (!fire_laser())
		var/static/list/fail_emotes = list("coughs.", "wheezes.", "belches out a puff of black smoke.")
		owner.manual_emote(pick(fail_emotes))
		StartCooldown()
		return TRUE

	do_after(owner, delay = beam_duration, target = owner)
	extinguish_laser()
	StartCooldown()
	return TRUE

/// Create a laser in the direction we are facing
/datum/action/cooldown/mob_cooldown/brimbeam/proc/fire_laser()
	owner.visible_message(span_danger("[owner] fires a brimbeam!"))
	playsound(owner, 'sound/creatures/brimdemon.ogg', 150, FALSE, 0, 3)
	var/turf/target_turf = get_ranged_target_turf(owner, owner.dir, beam_range)
	var/turf/origin_turf = get_turf(owner)
	var/list/affected_turfs = get_line(origin_turf, target_turf) - origin_turf
	for(var/turf/affected_turf in affected_turfs)
		if(affected_turf.opacity)
			break
		var/blocked = FALSE
		for(var/obj/potential_block in affected_turf.contents)
			if(potential_block.opacity)
				blocked = TRUE
				break
		if(blocked)
			break
		var/atom/new_brimbeam = new /obj/effect/brimbeam(affected_turf)
		new_brimbeam.dir = owner.dir
		beam_parts += new_brimbeam
		for(var/mob/living/hit_mob in affected_turf.contents)
			hit_mob.apply_damage(damage = 25, damagetype = BURN)
			to_chat(hit_mob, span_userdanger("You're blasted by [owner]'s brimbeam!"))
		RegisterSignal(new_brimbeam, COMSIG_QDELETING, PROC_REF(extinguish_laser)) // In case idk a singularity eats it or something
	if(!length(beam_parts))
		return FALSE
	var/atom/last_brimbeam = beam_parts[length(beam_parts)]
	last_brimbeam.icon_state = "brimbeam_end"
	var/atom/first_brimbeam = beam_parts[1]
	first_brimbeam.icon_state = "brimbeam_start"
	return TRUE

/// Get rid of our laser when we are done with it
/datum/action/cooldown/mob_cooldown/brimbeam/proc/extinguish_laser()
	if(!length(beam_parts))
		return FALSE
	owner.move_resist = initial(owner.move_resist)
	for(var/obj/effect/brimbeam/beam in beam_parts)
		beam.disperse()
	beam_parts = list()

/// Segments of the actual beam, these hurt if you stand in them
/obj/effect/brimbeam
	name = "brimbeam"
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "brimbeam_mid"
	layer = ABOVE_MOB_LAYER
	plane = ABOVE_GAME_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	light_power = 3
	light_range = 2

/obj/effect/brimbeam/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/effect/brimbeam/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/effect/brimbeam/process()
	for(var/mob/living/hit_mob in get_turf(src))
		damage(hit_mob)

/// Hurt the passed mob
/obj/effect/brimbeam/proc/damage(mob/living/hit_mob)
	hit_mob.apply_damage(damage = 5, damagetype = BURN)
	to_chat(hit_mob, span_danger("You're damaged by [src]!"))

/// Disappear
/obj/effect/brimbeam/proc/disperse()
	animate(src, time = 0.5 SECONDS, alpha = 0)
	QDEL_IN(src, 0.5 SECONDS)
