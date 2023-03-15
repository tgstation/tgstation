//Decreases the Psi regeneration delay by 3 ticks and increases Psi regeneration threshold to 25.
/datum/darkspawn_upgrade/psi_regen
	name = "\'Recovery\' Sigil"
	id = "psi_regen"
	desc = "The Mqeygjao sigil, representing swiftness, is etched onto the forehead. Unlocking this sigil causes your Psi to regenerate 3 ticks sooner, and you will regenerate up to 25 Psi instead of 20."
	lucidity_price = 1

/datum/darkspawn_upgrade/psi_regen/apply_effects()
	darkspawn.psi_regen = 25
	darkspawn.psi_regen_delay -= 3
