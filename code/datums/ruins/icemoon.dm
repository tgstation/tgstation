// Hey! Listen! Update \config\iceruinblacklist.txt with your new ruins!

/datum/map_template/ruin/icemoon
	prefix = "_maps/RandomRuins/IceRuins/"

/datum/map_template/ruin/icemoon/seed_vault
	name = "Seed Vault"
	id = "seed-vault"
	description = "The creators of these vaults were a highly advanced and benevolent race, and launched many into the stars, hoping to aid fledgling civilizations. \
	However, all the inhabitants seem to do is grow drugs and guns."
	suffix = "icemoon_surface_seed_vault.dmm"
	cost = 10
	allow_duplicates = FALSE

/datum/map_template/ruin/icemoon/ufo_crash
	name = "UFO Crash"
	id = "ufo-crash"
	description = "Turns out that keeping your abductees unconscious is really important. Who knew?"
	suffix = "icemoon_surface_ufo_crash.dmm"
	cost = 5

/datum/map_template/ruin/icemoon/underground
	name = "underground ruin"

/datum/map_template/ruin/icemoon/underground/survivalcapsule
	name = "Survival Capsule Ruins"
	id = "survivalcapsule"
	description = "What was once sanctuary to the common miner, is now their tomb."
	suffix = "icemoon_surface_survivalpod.dmm"
	cost = 5