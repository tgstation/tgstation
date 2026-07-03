GLOBAL_VAR_INIT(legs_trip_threshold, 0.85)
GLOBAL_VAR_INIT(legs_break_threshold, 0.3)
#define TRIP_CHANCE 50

/mob/living/carbon/human/Move(NewLoc, direct)
	. = ..()
	if(!.)
		return

	if(shoes && body_position == STANDING_UP && has_gravity(loc))
		if((. && !moving_diagonally) || (!. && moving_diagonally == SECOND_DIAG_STEP))
			SEND_SIGNAL(shoes, COMSIG_SHOES_STEP_ACTION)

	check_movespeed()

/mob/living/carbon/human/proc/check_movespeed() // чем ближе коэффицент замедления к legs_break_threshold -> тем выше шанс повредить ноги
	if(has_movespeed_modifier(/datum/movespeed_modifier/status_speed_boost))
		return

	if(cached_multiplicative_slowdown >= GLOB.legs_trip_threshold)
		return

	if(!prob(TRIP_CHANCE))
		return

	var/broke_legs = FALSE
	if(cached_multiplicative_slowdown < GLOB.legs_break_threshold)
		var/excess = GLOB.legs_break_threshold - cached_multiplicative_slowdown
		var/chance = excess / GLOB.legs_break_threshold
		if(prob(chance * 100))
			broke_legs = TRUE
			apply_damage(40, BRUTE, BODY_ZONE_L_LEG)
			apply_damage(40, BRUTE, BODY_ZONE_R_LEG)

	Knockdown(2 SECONDS, 0, TRUE)
	if(broke_legs)
		to_chat(src, span_bolddanger("Вы повредили ноги, споткнувшись от слишком быстрого бега!"))
	else
		to_chat(src, span_bolddanger("Вы оступились и упали от слишком быстрого бега!"))

#undef TRIP_CHANCE
