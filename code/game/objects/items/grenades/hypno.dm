/obj/item/grenade/hypnotic
	name = "flashbang"
	desc = "A modified flashbang which uses hypnotic flashes and mind-altering soundwaves to induce an instant trance upon detonation."
	icon_state = "flashbang"
	item_state = "flashbang"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	var/flashbang_range = 7

/obj/item/grenade/hypnotic/prime()
	update_mob()
	var/flashbang_turf = get_turf(src)
	if(!flashbang_turf)
		return
	do_sparks(rand(5, 9), FALSE, src)
	playsound(flashbang_turf, 'sound/effects/screech.ogg', 100, TRUE, 8, 0.9)
	new /obj/effect/dummy/lighting_obj (flashbang_turf, LIGHT_COLOR_PURPLE, (flashbang_range + 2), 4, 2)
	for(var/mob/living/M in get_hearers_in_view(flashbang_range, flashbang_turf))
		bang(get_turf(M), M)
	qdel(src)

/obj/item/grenade/hypnotic/proc/bang(turf/T, mob/living/M)
	if(M.stat == DEAD)	//They're dead!
		return
	var/distance = max(0,get_dist(get_turf(src),T))

	//Bang
	var/hypno_sound = FALSE

	//Hearing protection check
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		var/list/reflist = list(1)
		SEND_SIGNAL(C, COMSIG_CARBON_SOUNDBANG, reflist)
		var/intensity = reflist[1]
		var/ear_safety = C.get_ear_protection()
		var/effect_amount = intensity - ear_safety
		if(effect_amount > 0)
			hypno_sound = TRUE

	if(!distance || loc == M || loc == M.loc)
		M.Paralyze(10)
		M.Knockdown(100)
		to_chat(M, "<span class='hypnophrase'>The sound echoes in your brain...</span>")
		M.hallucination += 50
	else
		if(distance <= 1)
			M.Paralyze(5)
			M.Knockdown(30)
		if(hypno_sound)
			to_chat(M, "<span class='hypnophrase'>The sound echoes in your brain...</span>")
			M.hallucination += 50

	//Flash
	if(M.flash_act(affect_silicon = 1))
		M.Paralyze(max(10/max(1,distance), 5))
		M.Knockdown(max(100/max(1,distance), 40))
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(C.hypnosis_vulnerable()) //The sound causes the necessary conditions unless the target has mindshield or hearing protection
				C.apply_status_effect(/datum/status_effect/trance, 100, TRUE)
			else
				to_chat(C, "<span class='hypnophrase'>The light is so pretty...</span>")
				C.confused += min(C.confused + 10, 20)
				C.dizziness += min(C.dizziness + 10, 20)
				C.drowsyness += min(C.drowsyness + 10, 20)
