/obj/item/grenade/hypnotic
	name = "flashbang"
	desc = "A modified flashbang which uses hypnotic flashes and mind-altering soundwaves to induce an instant trance upon detonation."
	icon_state = "flashbang"
	inhand_icon_state = "flashbang"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	var/flashbang_range = 7

/obj/item/grenade/hypnotic/detonate(mob/living/lanced_by)
	. = ..()
	if(!.)
		return

	update_mob()
	var/flashbang_turf = get_turf(src)
	if(!flashbang_turf)
		return
	do_sparks(rand(5, 9), FALSE, src)
	playsound(flashbang_turf, 'sound/effects/screech.ogg', 100, TRUE, 8, 0.9)
	new /obj/effect/dummy/lighting_obj (flashbang_turf, flashbang_range + 2, 4, LIGHT_COLOR_PURPLE, 2)
	for(var/mob/living/living_mob in get_hearers_in_view(flashbang_range, flashbang_turf))
		bang(get_turf(living_mob), living_mob)
	qdel(src)

/obj/item/grenade/hypnotic/proc/bang(turf/turf, mob/living/living_mob)
	if(living_mob.stat == DEAD) //They're dead!
		return
	var/distance = max(0, get_dist(get_turf(src), turf))

	//Bang
	var/hypno_sound = FALSE

	//Hearing protection check
	if(iscarbon(living_mob))
		var/mob/living/carbon/target = living_mob
		var/list/reflist = list(1)
		SEND_SIGNAL(target, COMSIG_CARBON_SOUNDBANG, reflist)
		var/intensity = reflist[1]
		var/ear_safety = target.get_ear_protection()
		var/effect_amount = intensity - ear_safety
		if(effect_amount > 0)
			hypno_sound = TRUE

	if(!distance || loc == living_mob || loc == living_mob.loc)
		living_mob.Paralyze(10)
		living_mob.Knockdown(100)
		to_chat(living_mob, span_hypnophrase("The sound echoes in your brain..."))
		living_mob.hallucination += 50
	else
		if(distance <= 1)
			living_mob.Paralyze(5)
			living_mob.Knockdown(30)
		if(hypno_sound)
			to_chat(living_mob, span_hypnophrase("The sound echoes in your brain..."))
			living_mob.hallucination += 50

	//Flash
	if(living_mob.flash_act(affect_silicon = 1))
		living_mob.Paralyze(max(10/max(1, distance), 5))
		living_mob.Knockdown(max(100/max(1, distance), 40))
		if(iscarbon(living_mob))
			var/mob/living/carbon/target = living_mob
			if(target.hypnosis_vulnerable()) //The sound causes the necessary conditions unless the target has mindshield or hearing protection
				target.apply_status_effect(/datum/status_effect/trance, 100, TRUE)
			else
				to_chat(target, span_hypnophrase("The light is so pretty..."))
				target.adjust_drowsyness(min(target.drowsyness + 10, 20))
				target.adjust_timed_status_effect(10 SECONDS, /datum/status_effect/confusion, max_duration = 20 SECONDS)
				target.adjust_timed_status_effect(20 SECONDS, /datum/status_effect/dizziness, max_duration = 40 SECONDS)
