//Increases max Psi by 25.
/datum/darkspawn_upgrade/psi_cap
	name = "\'Atlwjz\' Sigils"
	id = "psi_cap"
	desc = "The Atlwjz sigils, representing omniscience, are etched onto the forehead. Unlocking these sigils increases your maximum Psi by 25"
	lucidity_price = 2

/datum/darkspawn_upgrade/psi_cap/apply_effects()
	darkspawn.psi_cap += 25
