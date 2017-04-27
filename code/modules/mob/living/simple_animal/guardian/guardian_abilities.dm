//SABAKU NO WA ORE guardian DA

/datum/guardian_abilities
	var/name = "Ability Name"
	var/id = "ability_id" //should be same as their current path

	var/toggle = FALSE
	var/mob/living/simple_animal/hostile/guardian/guardian = null
	var/mob/living/user = null
	var/cooldown = 0
	var/value = 0 //VALUE SYSTEM:
	var/battlecry = "ORA"
	var/list/initial_coeff

	var/only_on_return_true = TRUE //whether hits should connect for an ability to fire.
	var/list/blacklisted_abilities
	//basically, the total value of abilities a guardian can have is 10, and more powerful abilities have more value, this means that
	//randomized-ability guardians can only have a set number of abilities both in quantity and quality, maintaining some form of balance.
	//CRUCIAL: only randomized guardians are to use the value system.

/datum/guardian_abilities/proc/handle_stats()
	LAZYINITLIST(initial_coeff)
	LAZYINITLIST(blacklisted_abilities)
	initial_coeff = guardian.damage_coeff

/datum/guardian_abilities/proc/life_act()


/datum/guardian_abilities/proc/ability_act()


/datum/guardian_abilities/proc/alt_ability_act() //ability to do on alt_click


/datum/guardian_abilities/proc/handle_mode()


/datum/guardian_abilities/proc/bump_reaction()


/datum/guardian_abilities/proc/ranged_attack()


/datum/guardian_abilities/proc/impact_act()


/datum/guardian_abilities/proc/recall_act(forced)
	if(!user || guardian.loc == user || (cooldown > world.time && !forced) && guardian.dextrous)
		return FALSE
	guardian.drop_all_held_items()
	return TRUE //lose items, then return

/datum/guardian_abilities/proc/adjusthealth_act()


/datum/guardian_abilities/proc/light_switch()


/datum/guardian_abilities/proc/manifest_act()


/datum/guardian_abilities/proc/openfire_act()


/datum/guardian_abilities/proc/move_act()


/datum/guardian_abilities/proc/snapback_act()
	if(user && !(get_dist(get_turf(user),get_turf(guardian)) <= guardian.range) && guardian.dextrous)
		guardian.drop_all_held_items()
		return TRUE //lose items, then return

/datum/guardian_abilities/proc/boom_act()

