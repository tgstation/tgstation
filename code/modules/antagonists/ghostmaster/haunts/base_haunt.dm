/mob/living/simple_animal/hostile/haunt
	name = "generic spook"
	desc = "Boo."
	icon_state = "spook"
	icon_living = "spook"
	mob_biotypes = list(MOB_SPIRIT)
	speak_chance = 0
	turns_per_move = 5
	spacewalk = TRUE
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	faction = list("spook")
	movement_type = FLYING
	pressure_resistance = 200
	var/bound = FALSE
	var/stray_damage = 5
	var/area/haunted_areas = list()
	var/datum/exorcism/exorcism
	var/obj/effect/decal/remains/human/haunted/corpse
	var/death_timeout = 600

/mob/living/simple_animal/hostile/haunt/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if(!message || !can_speak_basic(message))
		return
	haunt_talk(src, message)
	//emote spooky noises here
	return

/mob/living/simple_animal/hostile/haunt/proc/generate_corpse()
	corpse = new (get_turf(src))
	exorcism = new()
	exorcism.generate()
	exorcism.bound_spook = src
	exorcism.RegisterCorpse(corpse)
	return

//death hint
/mob/living/simple_animal/hostile/haunt/death(gibbed)
	if(exorcism)
		var/hint = exorcism.give_hint()
		audible_message("<span class='big haunt'>[hint]</span>")
	if(!exorcism.completed)
		bench_time()
	else
		. = ..()


/mob/living/simple_animal/hostile/haunt/proc/bench_time()
	to_chat(src,"<span class='userdanger'>Our essence disperses from the damage, but we'll be back soon.</span>")
	toggle_ai(AI_OFF)
	death_effect()
	addtimer(CALLBACK(src,.proc/back_to_play),death_timeout)

/mob/living/simple_animal/hostile/haunt/proc/back_to_play()
	toggle_ai(AI_ON)
	revive(fully_heal = TRUE)
	lift_death_effect()

/mob/living/simple_animal/hostile/haunt/proc/death_effect()
	invisibility = INVISIBILITY_OBSERVER
	density = FALSE
	SetParalyzed(death_timeout,ignore_canstun = TRUE)
	update_mobility()

/mob/living/simple_animal/hostile/haunt/proc/lift_death_effect()
	invisibility = initial(invisibility)
	density = initial(density)
	

/mob/living/simple_animal/hostile/haunt/Life()
	. = ..()
	if(handle_spook_zone())
		apply_status_effect(/datum/status_effect/spookdecay)
	else
		remove_status_effect(/datum/status_effect/spookdecay)

//Return true if outside our haunt zone
/mob/living/simple_animal/hostile/haunt/proc/handle_spook_zone()
	if(!bound)
		return FALSE
	if(get_area(src) in haunted_areas)
		return FALSE
	if(corpse && get_dist(get_turf(corpse),get_turf(src)) < 5)
		return FALSE
	return TRUE

/datum/status_effect/spookdecay
	id = "spookdecay"
	duration = -1 //removed under specific conditions
	tick_interval = 20
	alert_type = null
	var/base_damage = 5

/datum/status_effect/spookdecay/tick()
	owner.adjustBruteLoss(base_damage)

/datum/status_effect/spookdecay/on_apply()
	to_chat(owner, "<span class='userdanger'>You feel your ectoplasm withering away so far away from your place of death...</span>")
	return ..()