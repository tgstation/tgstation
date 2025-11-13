/obj/item/grenade/hypnotic
	name = "flashbang"
	desc = "A modified flashbang which uses hypnotic flashes and mind-altering soundwaves to induce an instant trance upon detonation."
	icon_state = "flashbang"
	inhand_icon_state = "flashbang"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	var/flashbang_range = 7

/obj/item/grenade/hypnotic/apply_grenade_fantasy_bonuses(quality)
	flashbang_range = modify_fantasy_variable("flashbang_range", flashbang_range, quality)

/obj/item/grenade/hypnotic/remove_grenade_fantasy_bonuses(quality)
	flashbang_range = reset_fantasy_variable("flashbang_range", flashbang_range)

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
	var/distance = get_dist(get_turf(src), turf)

	//Bang
	var/hypno_sound = FALSE

	//Hearing protection check
	if(living_mob.get_ear_protection() < 0)
		hypno_sound = TRUE

	if(!distance)
		living_mob.Paralyze(1 SECONDS)
		living_mob.Knockdown(10 SECONDS)
		to_chat(living_mob, span_hypnophrase("The sound echoes in your brain..."))
		living_mob.adjust_hallucinations(150 SECONDS)

	else
		if(distance <= 1)
			living_mob.Paralyze(0.5 SECONDS)
			living_mob.Knockdown(3 SECONDS)
		if(hypno_sound)
			to_chat(living_mob, span_hypnophrase("The sound echoes in your brain..."))
			living_mob.adjust_hallucinations(150 SECONDS)

	//Flash
	if(!living_mob.flash_act(affect_silicon = TRUE))
		return
	living_mob.Paralyze(max(1 SECONDS / (distance || 1), 0.5 SECONDS))
	living_mob.Knockdown(max(10 SECONDS / (distance || 1), 4 SECONDS))
	if(living_mob.hypnosis_vulnerable()) //The sound causes the necessary conditions unless the target has mindshield or hearing protection
		living_mob.apply_status_effect(/datum/status_effect/trance, 10 SECONDS, TRUE)
		return
	to_chat(living_mob, span_hypnophrase("The light is so pretty..."))
	living_mob.adjust_drowsiness_up_to(20 SECONDS, 40 SECONDS)
	living_mob.adjust_confusion_up_to(10 SECONDS, 20 SECONDS)
	living_mob.adjust_dizzy_up_to(20 SECONDS, 40 SECONDS)
