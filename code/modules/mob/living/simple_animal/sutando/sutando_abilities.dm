//SABAKU NO WA ORE stand DA

/datum/sutando_abilities
	var/name = "Ability Name"
	var/id = "ability_id" //should be same as their current path

	var/toggle = FALSE
	var/mob/living/simple_animal/hostile/sutando/stand = null
	var/mob/living/user = null
	var/cooldown = 0
	var/value = 0 //VALUE SYSTEM:
	var/battlecry = "ORA"
	var/list/initial_coeff

	var/list/blacklisted_abilities
	//basically, the total value of abilities a stand can have is 10, and more powerful abilities have more value, this means that
	//randomized-ability stands can only have a set number of abilities both in quantity and quality, maintaining some form of balance.
	//CRUCIAL: only randomized stands are to use the value system.

/datum/sutando_abilities/proc/handle_stats()
	LAZYINITLIST(initial_coeff)
	LAZYINITLIST(blacklisted_abilities)
	initial_coeff = stand.damage_coeff

/datum/sutando_abilities/proc/life_act()


/datum/sutando_abilities/proc/ability_act()


/datum/sutando_abilities/proc/alt_ability_act() //ability to do on alt_click


/datum/sutando_abilities/proc/handle_mode()


/datum/sutando_abilities/proc/bump_reaction()


/datum/sutando_abilities/proc/ranged_attack()


/datum/sutando_abilities/proc/impact_act()


/datum/sutando_abilities/proc/recall_act()


/datum/sutando_abilities/proc/adjusthealth_act()


/datum/sutando_abilities/proc/light_switch()


/datum/sutando_abilities/proc/manifest_act()


/datum/sutando_abilities/proc/openfire_act()


/datum/sutando_abilities/proc/move_act()


/datum/sutando_abilities/proc/snapback_act()


/datum/sutando_abilities/proc/boom_act()

