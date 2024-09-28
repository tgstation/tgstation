/datum/corpse_damage/cause_of_death/plasmafire
	cause_of_death = "when I got caught out in a plasmafire!"
	var/tox_damage_max = 40
	var/burn_damage_base = 100
	var/burn_damage_max = 100

/datum/corpse_damage/cause_of_death/plasmafire/apply_to_body(mob/living/carbon/human/body, severity, list/storage)
	body.apply_damage(burn_damage_base + burn_damage_max * severity, BURN, wound_bonus = 100 * severity)
	body.apply_damage(tox_damage_max * severity, TOX)

/datum/corpse_damage/cause_of_death/explosion
	cause_of_death = "when I noticed a bomb!"

	var/severity = EXPLODE_HEAVY
	var/explosion_count_max = 4

/datum/corpse_damage/cause_of_death/explosion/apply_to_body(mob/living/carbon/human/body, severity, list/storage)
	for(var/i in 1 to max(round(explosion_count_max * severity), 1))
		EX_ACT(body, severity)

/datum/corpse_damage/cause_of_death/spaced
	cause_of_death = "when I got spaced!"
	var/base_damage = 80
	var/damage_max = 50

/datum/corpse_damage/cause_of_death/spaced/apply_to_body(mob/living/carbon/human/body, severity, list/storage)
	body.apply_damage(base_damage + damage_max * severity, BURN)
	body.apply_damage(base_damage + damage_max * severity, BRUTE)
	body.set_coretemperature(TCMB)
