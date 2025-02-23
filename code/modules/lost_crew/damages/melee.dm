/// Simulates a melee attack with a specified weapon
/datum/corpse_damage/cause_of_death/melee_weapon
	/// The weapon with which we hit
	var/obj/item/weapon
	/// The minimal amount of hits
	var/min_hits = 5
	/// The maximum amount of hits
	var/max_hits = 15

/datum/corpse_damage/cause_of_death/melee_weapon/apply_to_body(mob/living/carbon/human/body, severity, list/storage, list/datum/callback/on_revive_and_player_occupancy)
	weapon = get_weapon(body)

	var/hits = ((max_hits - min_hits) * severity + min_hits)
	for(var/i in 1 to hits)
		weapon.attack(body, body) //needs an attacker, no reason it cant be the body as well
		body.zone_selected = pick(GLOB.all_body_zones)

/datum/corpse_damage/cause_of_death/melee_weapon/proc/get_weapon(mob/living/carbon/human/body)
	return new weapon(null)

/datum/corpse_damage/cause_of_death/melee_weapon/esword
	weapon = /obj/item/melee/energy/sword
	cause_of_death = "when I was attacked by a filthy traitor!"

/datum/corpse_damage/cause_of_death/melee_weapon/esword/get_weapon(mob/living/carbon/human/body)
	. = ..()

	var/obj/item/melee/energy/sword/esword = .

	esword.attack_self() //need to activate it

/datum/corpse_damage/cause_of_death/melee_weapon/changeling
	weapon = /obj/item/melee/arm_blade
	cause_of_death = "when I was attacked by a terrifying changeling!"

/datum/corpse_damage/cause_of_death/melee_weapon/toolbox
	cause_of_death = "when some worthless assistant toolboxed me!"
	weapon = /obj/item/storage/toolbox

/datum/corpse_damage/cause_of_death/melee_weapon/heretic
	cause_of_death = "when a flipping heretic attacked me!"

/datum/corpse_damage/cause_of_death/melee_weapon/heretic/get_weapon(mob/living/carbon/human/body)
	var/obj/item/melee/sickly_blade/blade = pick(subtypesof(/obj/item/melee/sickly_blade)) //pick a random blade, can be a bunch of fun stuff
	return new blade (null)
