/obj/projectile/energy/electrode
	name = "electrode"
	icon_state = "spark"
	color = "#FFFF00"
	nodamage = FALSE
	paralyze = 100
	stutter = 10 SECONDS
	jitter = 40 SECONDS
	hitsound = 'sound/weapons/taserhit.ogg'
	range = 7
	tracer_type = /obj/effect/projectile/tracer/stun
	muzzle_type = /obj/effect/projectile/muzzle/stun
	impact_type = /obj/effect/projectile/impact/stun

/obj/projectile/energy/electrode/proc/tase_checks()
	return TRUE

/obj/projectile/energy/electrode/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(!ismob(target) || blocked >= 100) //Fully blocked by mob or collided with dense object - burst into sparks!
		do_sparks(1, TRUE, src)
	else if(iscarbon(target))
		var/mob/living/carbon/C = target
		SEND_SIGNAL(C, COMSIG_ADD_MOOD_EVENT, "tased", /datum/mood_event/tased)
		SEND_SIGNAL(C, COMSIG_LIVING_MINOR_SHOCK)
		if(C.dna && C.dna.check_mutation(/datum/mutation/human/hulk))
			C.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ), forced = "hulk")
		else if((C.status_flags & CANKNOCKDOWN) && !HAS_TRAIT(C, TRAIT_STUNIMMUNE))
			addtimer(CALLBACK(C, /mob/living/carbon.proc/do_jitter_animation, 20), 5)

/obj/projectile/energy/electrode/tider
	paralyze = 0
	stutter = 0
	jitter = 0


/obj/projectile/energy/electrode/on_range() //to ensure the bolt sparks when it reaches the end of its range if it didn't hit a target yet
	do_sparks(1, TRUE, src)
	..()

/obj/projectile/energy/electrode/tider/on_hit(atom/target)
	if(!tase_checks(target))
		return
	. = ..()
	var/mob/living/carbon/victim = target
	var/area/Location = get_area(victim)
	var/list/gibbable_areas = list(/area/station/command/bridge, /area/station/command/heads_quarters/captain)
	for(var/area/area_to_check as anything in gibbable_areas)
		if (istype(Location, area_to_check))
			victim.gib()
			return
	victim.Paralyze(10 SECONDS)
	victim.set_timed_status_effect(10 SECONDS, /datum/status_effect/speech/stutter)


/obj/projectile/energy/electrode/tider
	name = "tider taser"

// We only want to activate on Assistants.
/obj/projectile/energy/electrode/tider/tase_checks(mob/target)
	if(!ishuman(target))
		return FALSE
	var/mob/living/carbon/human/human_target = target
	if (!human_target.mind)
		return FALSE
	if(istype(human_target.mind.assigned_role, /datum/job/assistant))
		return TRUE
	human_target.balloon_alert_to_viewers("not an assistant, can't tase!")
	return FALSE
