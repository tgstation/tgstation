

/mob/living/carbon/alien/adult/nova/warrior
	name = "alien warrior"
	desc = "If there are aliens to call walking tanks, this would be one of them, with both the heavy armor and strong arms to back that claim up."
	caste = "warrior"
	maxHealth = 400
	health = 400
	icon_state = "alienwarrior"
	melee_damage_lower = 30
	melee_damage_upper = 35

/mob/living/carbon/alien/adult/nova/warrior/Initialize(mapload)
	. = ..()
	var/static/list/innate_actions = list(
		/datum/action/cooldown/spell/aoe/repulse/xeno/nova_tailsweep,
		/datum/action/cooldown/mob_cooldown/charge/basic_charge/defender,
		/datum/action/cooldown/alien/nova/warrior_agility,
	)
	grant_actions_by_list(innate_actions)

	REMOVE_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

	add_movespeed_modifier(/datum/movespeed_modifier/alien_big)

/mob/living/carbon/alien/adult/nova/warrior/create_internal_organs()
	organs += new /obj/item/organ/internal/alien/plasmavessel
	..()

/datum/action/cooldown/alien/nova/warrior_agility
	name = "Agility Mode"
	desc = "Drop onto all fours, increasing your speed at the cost of damage and being unable to use most abilities."
	button_icon_state = "the_speed_is_alot"
	cooldown_time = 1 SECONDS
	can_be_used_always = TRUE
	/// Is the warrior currently running around on all fours?
	var/being_agile = FALSE

/datum/action/cooldown/alien/nova/warrior_agility/Activate()
	. = ..()
	if(!being_agile)
		begin_agility()
		return TRUE
	if(being_agile)
		end_agility()
		return TRUE

/// Handles the visual indication and code activation of the warrior agility ability (say that five times fast)
/datum/action/cooldown/alien/nova/warrior_agility/proc/begin_agility()
	var/mob/living/carbon/alien/adult/nova/agility_target = owner
	agility_target.balloon_alert(agility_target, "agility active")
	to_chat(agility_target, span_danger("We drop onto all fours, allowing us to move at much greater speed at expense of being able to use most abilities."))
	playsound(agility_target, 'monkestation/code/modules/blueshift/sounds/alien_hiss.ogg', 100, TRUE, 8, 0.9)
	agility_target.icon_state = "alien[agility_target.caste]_mobility"

	being_agile = TRUE
	agility_target.add_movespeed_modifier(/datum/movespeed_modifier/warrior_agility)
	agility_target.unable_to_use_abilities = TRUE

	agility_target.melee_damage_lower = 15
	agility_target.melee_damage_upper = 20

/// Handles the visual indicators and code side of deactivating the agility ability
/datum/action/cooldown/alien/nova/warrior_agility/proc/end_agility()
	var/mob/living/carbon/alien/adult/nova/agility_target = owner
	agility_target.balloon_alert(agility_target, "agility ended")
	playsound(agility_target, 'monkestation/code/modules/blueshift/sounds/alien_roar2.ogg', 100, TRUE, 8, 0.9) //Warrior runs up on all fours, stands upright, screams at you
	agility_target.icon_state = "alien[agility_target.caste]"

	being_agile = FALSE
	agility_target.remove_movespeed_modifier(/datum/movespeed_modifier/warrior_agility)
	agility_target.unable_to_use_abilities = FALSE

	agility_target.melee_damage_lower = initial(agility_target.melee_damage_lower)
	agility_target.melee_damage_upper = initial(agility_target.melee_damage_upper)

/datum/movespeed_modifier/warrior_agility
	multiplicative_slowdown = -2
