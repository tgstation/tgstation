/datum/action/cooldown/mob_cooldown/chicken/lay_egg
	name = "Lay Egg"
	desc = "Lay an egg."
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "eye"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

	click_to_activate = FALSE
	cooldown_time = 15 SECONDS
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	shared_cooldown = NONE
	what_range = /datum/ai_behavior/targeted_mob_ability/min_range/chicken/on_top

/datum/action/cooldown/mob_cooldown/chicken/lay_egg/PreActivate(atom/target)
	var/mob/living/basic/chicken/chicken_owner = owner
	if(!istype(chicken_owner))
		return
	if(chicken_owner.eggs_left <= 0)
		return
	. = ..()

/datum/action/cooldown/mob_cooldown/chicken/lay_egg/Activate(atom/target)
	. = ..()
	var/mob/living/basic/chicken/chicken_owner = owner
	chicken_owner.visible_message("[chicken_owner] [pick(chicken_owner.layMessage)]")

	var/passes_minimum_checks = FALSE
	if(chicken_owner.total_times_eaten > 4 && prob(25 + chicken_owner.instability))
		passes_minimum_checks = TRUE

	SEND_SIGNAL(chicken_owner, COMSIG_MUTATION_TRIGGER, get_turf(chicken_owner), passes_minimum_checks, chicken_owner.instability)
	chicken_owner.eggs_left--
	StartCooldown(cooldown_time / max(1, (chicken_owner.egg_laying_boosting * 0.02)))
	return TRUE

/datum/action/cooldown/mob_cooldown/chicken/feed
	name = "Feast"
	desc = "Eat from some laid feed."
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "eye"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

	cooldown_time = 20 SECONDS
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	shared_cooldown = NONE
	what_range = /datum/ai_behavior/targeted_mob_ability/min_range/chicken/on_top

/datum/action/cooldown/mob_cooldown/chicken/feed/PreActivate(atom/target)
	if(!istype(target, /obj/effect/chicken_feed))
		return
	if(!owner.CanReach(target))
		return
	. = ..()

/datum/action/cooldown/mob_cooldown/chicken/feed/Activate(atom/target)
	. = ..()
	var/mob/living/basic/chicken/chicken_owner = owner
	chicken_owner.eat_feed(target)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/chicken
	melee_cooldown_time =  1 // dumb
	var/datum/ai_behavior/targeted_mob_ability/min_range/chicken/what_range = /datum/ai_behavior/targeted_mob_ability/min_range/chicken/melee

/datum/pet_command/point_targeting/attack/chicken
	attack_behaviour = /datum/ai_behavior/basic_melee_attack/chicken

/datum/pet_command/point_targeting/attack/chicken/ranged
	attack_behaviour = /datum/ai_behavior/basic_ranged_attack/chicken
