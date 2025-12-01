/datum/corpse_damage/cause_of_death/plasmafire
	cause_of_death = "when I got caught in a plasmafire!"
	/// The max tox damage we deal
	var/tox_damage_max = 40
	/// Guaranteed burn damage
	var/burn_damage_base = 100
	/// Burn damage that fluctuates with severity
	var/burn_damage_max = 100

/datum/corpse_damage/cause_of_death/plasmafire/apply_to_body(mob/living/carbon/human/body, severity, list/storage, list/datum/callback/on_revive_and_player_occupancy)
	body.apply_damage(burn_damage_base + burn_damage_max * severity, BURN, wound_bonus = 100 * severity, spread_damage = TRUE)
	body.apply_damage(tox_damage_max * severity, TOX)

/datum/corpse_damage/cause_of_death/explosion
	cause_of_death = "when I noticed a bomb!"

	/// The explosion severity
	var/severity = EXPLODE_HEAVY
	/// The maximum amount of explosions we can proc
	var/explosion_count_max = 4

/datum/corpse_damage/cause_of_death/explosion/apply_to_body(mob/living/carbon/human/body, severity, list/storage, list/datum/callback/on_revive_and_player_occupancy)
	for(var/i in 1 to max(round(explosion_count_max * severity), 1))
		body.ex_act(EXPLODE_HEAVY)

/datum/corpse_damage/cause_of_death/spaced
	cause_of_death = "when I got spaced!"
	/// Guaranteed brute and burn damage
	var/base_damage = 90
	/// Damage influenced by the severity
	var/damage_max = 100

/datum/corpse_damage/cause_of_death/spaced/apply_to_body(mob/living/carbon/human/body, severity, list/storage, list/datum/callback/on_revive_and_player_occupancy)
	body.apply_damage(base_damage + damage_max * (severity * rand(80, 120) * 0.01), BURN, spread_damage = TRUE)
	body.apply_damage(base_damage + damage_max * (severity * rand(80, 120) * 0.01), BRUTE, spread_damage = TRUE)
	body.set_coretemperature(TCMB)
