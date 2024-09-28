/datum/corpse_damage/cause_of_death/melee_weapon
	var/obj/item/weapon
	var/min_hits = 5
	var/max_hits = 15

/datum/corpse_damage/cause_of_death/melee_weapon/apply_to_body(mob/living/carbon/human/body, severity, list/storage)
	weapon = get_weapon(body)

	var/hits = ((max_hits - min_hits) * severity + min_hits)
	for(var/i in 1 to hits)
		weapon.attack(body, body) //needs an attacker, no reason it cant be the body as well

/datum/corpse_damage/cause_of_death/melee_weapon/proc/get_weapon(mob/living/carbon/human/body)
	return new weapon(null)

/datum/corpse_damage/cause_of_death/melee_weapon/esword
	weapon = /obj/item/melee/energy/sword
	cause_of_death = "when I was attacked by a filthy traitor!"

/datum/corpse_damage/cause_of_death/melee_weapon/esword/get_weapon(mob/living/carbon/human/body)
	. = ..()

	var/obj/item/melee/energy/sword/esword = .

	esword.attack_self()

/datum/corpse_damage/cause_of_death/melee_weapon/changeling
	weapon = /obj/item/melee/arm_blade
	cause_of_death = "when I was attacked by a terrifying changeling!"

/datum/corpse_damage/cause_of_death/melee_weapon/toolbox
	cause_of_death = "when some worthless assistant toolboxed me!"

/datum/corpse_damage/cause_of_death/melee_weapon/heretic
	cause_of_death = "when a flipping heretic attacked me!"

/datum/corpse_damage/cause_of_death/melee_weapon/heretic/get_weapon(mob/living/carbon/human/body)
	var/obj/item/melee/sickly_blade/blade = pick(subtypesof(/obj/item/melee/sickly_blade))
	return new blade (null)
