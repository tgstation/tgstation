/datum/action/cooldown/mob_cooldown/ed209_charge
	name = "Bot Tackle"
	desc = "Not even God's mightiest Quarterback can withstand this."
	cooldown_time = 10 SECONDS
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	shared_cooldown = NONE
	///duration of telegraph
	var/telegraph_duration = 1.25 SECONDS
	///damage we apply on tackle
	var/tackle_damage = 25

/datum/action/cooldown/mob_cooldown/ed209_charge/Activate(atom/target)
	var/turf/target_turf = get_turf(target)
	if(isclosedturf(target_turf) || isspaceturf(target_turf))
		owner.balloon_alert(owner, "base not suitable!")
		return FALSE
	addtimer(CALLBACK(src, PROC_REF(commence_launch), target), telegraph_duration)
	owner.Shake(duration = telegraph_duration)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/ed209_charge/proc/commence_launch(atom/target)
	var/turf/target_turf = get_turf(target)
	owner.throw_at(target = target_turf, range = 7, speed = 1, spin = FALSE, callback = CALLBACK(src, PROC_REF(on_tackle), target_turf))
	new /obj/effect/temp_visual/mook_dust(owner.loc)

/datum/action/cooldown/mob_cooldown/ed209_charge/proc/on_tackle(turf/target, original_pixel_y)
	playsound(get_turf(owner), 'sound/effects/meteorimpact.ogg', 100, TRUE)
	new /obj/effect/temp_visual/mook_dust(owner.loc)
	for(var/mob/living/victim in oview(1, owner))
		if(victim in owner.buckled_mobs)
			continue
		victim.apply_damage(tackle_damage)
		if(QDELETED(victim))
			continue
		var/throw_dir = victim.loc == owner.loc ? get_dir(owner, victim) : pick(GLOB.alldirs)
		var/throwtarget = get_edge_target_turf(victim, throw_dir)
		victim.throw_at(target = throwtarget, range = 3, speed = 1)
		victim.visible_message(span_warning("[victim] eats steel!"))
