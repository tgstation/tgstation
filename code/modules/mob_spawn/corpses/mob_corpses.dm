
///all the corpses meant as mob drops yes, these definitely could be sorted properly. i invite (you) to do it!!

/obj/effect/mob_spawn/corpse/human/syndicatesoldier
	name = "Syndicate Operative"
	hairstyle = "Bald"
	facial_hairstyle = "Shaved"
	outfit = /datum/outfit/syndicatesoldiercorpse

/datum/outfit/syndicatesoldiercorpse
	name = "Syndicate Operative Corpse"
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	ears = /obj/item/radio/headset
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/helmet/swat
	back = /obj/item/storage/backpack
	id = /obj/item/card/id/advanced/chameleon
	id_trim = /datum/id_trim/chameleon/operative

/obj/effect/mob_spawn/corpse/human/syndicatecommando
	name = "Syndicate Commando"
	hairstyle = "Bald"
	facial_hairstyle = "Shaved"
	outfit = /datum/outfit/syndicatecommandocorpse

/datum/outfit/syndicatecommandocorpse
	name = "Syndicate Commando Corpse"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	ears = /obj/item/radio/headset
	mask = /obj/item/clothing/mask/gas/syndicate
	back = /obj/item/mod/control/pre_equipped/nuclear
	r_pocket = /obj/item/tank/internals/emergency_oxygen
	id = /obj/item/card/id/advanced/chameleon
	id_trim = /datum/id_trim/chameleon/operative

/obj/effect/mob_spawn/corpse/human/syndicatecommando/lessenedgear
	outfit = /datum/outfit/syndicatecommandocorpse/lessenedgear

/datum/outfit/syndicatecommandocorpse/lessenedgear
	name = "Syndicate Commando Corpse (Less Antag Gear)"
	gloves = /obj/item/clothing/gloves/tackler
	back = null
	id = null
	id_trim = null

/obj/effect/mob_spawn/corpse/human/syndicatecommando/soft_suit
	outfit = /datum/outfit/syndicatecommandocorpse/soft_suit

/datum/outfit/syndicatecommandocorpse/soft_suit
	name = "Syndicate Commando Corpse (Softsuit)"
	suit = /obj/item/clothing/suit/space/syndicate/black
	head = /obj/item/clothing/head/helmet/space/syndicate/black
	gloves = /obj/item/clothing/gloves/color/black
	back = null
	id = null
	id_trim = null

/obj/effect/mob_spawn/corpse/human/syndicatestormtrooper
	name = "Syndicate Stormtrooper"
	hairstyle = "Bald"
	facial_hairstyle = "Shaved"
	outfit = /datum/outfit/syndicatestormtroopercorpse

/datum/outfit/syndicatestormtroopercorpse
	name = "Syndicate Stormtrooper Corpse"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/tackler/combat
	ears = /obj/item/radio/headset
	mask = /obj/item/clothing/mask/gas/syndicate
	back = /obj/item/mod/control/pre_equipped/elite
	id = /obj/item/card/id/advanced/chameleon
	id_trim = /datum/id_trim/chameleon/operative

/obj/effect/mob_spawn/corpse/human/syndicatepilot
	name = "Syndicate Pilot"
	hairstyle = "Bald"
	facial_hairstyle = "Shaved"
	outfit = /datum/outfit/syndicatepilotcorpse

/datum/outfit/syndicatepilotcorpse
	name = "Syndicate Pilot Corpse"
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/armor/vest/alt
	shoes = /obj/item/clothing/shoes/combat
	neck = /obj/item/clothing/neck/large_scarf/syndie
	glasses = /obj/item/clothing/glasses/cold
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/helmet/swat
	back = /obj/item/storage/backpack
	id = /obj/item/card/id/advanced/chameleon
	id_trim = /datum/id_trim/chameleon/operative

/obj/effect/mob_spawn/corpse/human/tigercultist
	name = "Tiger Cooperative Cultist"
	outfit = /datum/outfit/tigercultcorpse

/datum/outfit/tigercultcorpse
	name = "Tiger Cooperative Corpse"
	uniform = /obj/item/clothing/under/rank/civilian/chaplain
	suit = /obj/item/clothing/suit/hooded/chaplain_hoodie
	shoes = /obj/item/clothing/shoes/laceup
	neck = /obj/item/clothing/neck/fake_heretic_amulet
	head = /obj/item/clothing/head/hooded/chaplain_hood
	back = /obj/item/storage/backpack/cultpack

/obj/effect/mob_spawn/corpse/human/pirate
	name = "Pirate"
	skin_tone = "caucasian1" //all pirates are white because it's easier that way
	outfit = /datum/outfit/piratecorpse
	hairstyle = "Bald"
	facial_hairstyle = "Shaved"

/datum/outfit/piratecorpse
	name = "Pirate Corpse"
	uniform = /obj/item/clothing/under/costume/pirate
	shoes = /obj/item/clothing/shoes/jackboots

/obj/effect/mob_spawn/corpse/human/pirate/melee
	name = "Pirate Swashbuckler"
	outfit = /datum/outfit/piratecorpse/melee

/datum/outfit/piratecorpse/melee
	name = "Pirate Swashbuckler Corpse"
	glasses = /obj/item/clothing/glasses/eyepatch
	head = /obj/item/clothing/head/costume/pirate/bandana/armored

/obj/effect/mob_spawn/corpse/human/pirate/melee/space
	name = "Pirate Swashbuckler - Space"
	outfit = /datum/outfit/piratecorpse/melee/space

/datum/outfit/piratecorpse/melee/space
	name = "Pirate Swashbuckler Corpse - Space"
	suit = /obj/item/clothing/suit/space/pirate
	head = /obj/item/clothing/head/helmet/space/pirate/bandana
	back = /obj/item/tank/jetpack/carbondioxide

/obj/effect/mob_spawn/corpse/human/pirate/ranged
	name = "Pirate Gunner"
	outfit = /datum/outfit/piratecorpse/ranged

/datum/outfit/piratecorpse/ranged
	name = "Pirate Gunner Corpse"
	glasses = /obj/item/clothing/glasses/eyepatch
	suit = /obj/item/clothing/suit/costume/pirate/armored
	head = /obj/item/clothing/head/costume/pirate/armored

/obj/effect/mob_spawn/corpse/human/pirate/ranged/space
	name = "Pirate Gunner - Space"
	outfit = /datum/outfit/piratecorpse/ranged/space

/datum/outfit/piratecorpse/ranged/space
	name = "Pirate Gunner Corpse - Space"
	suit = /obj/item/clothing/suit/space/pirate
	head = /obj/item/clothing/head/helmet/space/pirate
	back = /obj/item/tank/jetpack/carbondioxide

/obj/effect/mob_spawn/corpse/human/old_pirate_captain
	name = "Pirate Captain Skeleton"
	outfit = /datum/outfit/piratecorpse/captain
	mob_species = /datum/species/skeleton

/datum/outfit/piratecorpse/captain
	glasses = /obj/item/clothing/glasses/eyepatch
	head = /obj/item/clothing/head/costume/pirate
	suit = /obj/item/clothing/suit/costume/pirate

/obj/effect/mob_spawn/corpse/human/russian
	name = "Russian"
	outfit = /datum/outfit/russiancorpse
	hairstyle = "Bald"
	facial_hairstyle = "Shaved"

/datum/outfit/russiancorpse
	name = "Russian Corpse"
	uniform = /obj/item/clothing/under/costume/soviet
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/costume/bearpelt
	gloves = /obj/item/clothing/gloves/color/black
	mask = /obj/item/clothing/mask/gas



/obj/effect/mob_spawn/corpse/human/russian/ranged
	outfit = /datum/outfit/russiancorpse/ranged

/datum/outfit/russiancorpse/ranged
	name = "Ranged Russian Corpse"
	head = /obj/item/clothing/head/costume/ushanka


/obj/effect/mob_spawn/corpse/human/russian/ranged/trooper
	outfit = /datum/outfit/russiancorpse/ranged/trooper

/datum/outfit/russiancorpse/ranged/trooper
	name = "Ranged Russian Trooper Corpse"
	uniform = /obj/item/clothing/under/syndicate/camo
	suit = /obj/item/clothing/suit/armor/bulletproof
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/tackler/combat
	ears = /obj/item/radio/headset
	head = /obj/item/clothing/head/helmet/alt
	mask = /obj/item/clothing/mask/balaclava


/obj/effect/mob_spawn/corpse/human/russian/ranged/officer
	name = "Russian Officer"
	outfit = /datum/outfit/russiancorpse/officer

/datum/outfit/russiancorpse/officer
	name = "Russian Officer Corpse"
	uniform = /obj/item/clothing/under/costume/russian_officer
	suit = /obj/item/clothing/suit/jacket/officer/tan
	shoes = /obj/item/clothing/shoes/combat
	ears = /obj/item/radio/headset
	head = /obj/item/clothing/head/costume/ushanka


/obj/effect/mob_spawn/corpse/human/wizard
	name = "Space Wizard Corpse"
	outfit = /datum/outfit/wizardcorpse
	hairstyle = "Bald"
	facial_hairstyle = "Beard (Very Long)"
	facial_haircolor = COLOR_WHITE
	skin_tone = "caucasian1"

/obj/effect/mob_spawn/corpse/human/wizard/red
	outfit = /datum/outfit/wizardcorpse/red

/obj/effect/mob_spawn/corpse/human/wizard/yellow
	outfit = /datum/outfit/wizardcorpse/yellow

/obj/effect/mob_spawn/corpse/human/wizard/black
	outfit = /datum/outfit/wizardcorpse/black

/obj/effect/mob_spawn/corpse/human/wizard/marisa
	outfit = /datum/outfit/wizardcorpse/marisa

/obj/effect/mob_spawn/corpse/human/wizard/tape
	outfit = /datum/outfit/wizardcorpse/tape

/datum/outfit/wizardcorpse
	name = "Space Wizard Corpse"
	uniform = /obj/item/clothing/under/color/lightpurple
	suit = /obj/item/clothing/suit/wizrobe
	shoes = /obj/item/clothing/shoes/sandal/magic
	head = /obj/item/clothing/head/wizard

/datum/outfit/wizardcorpse/red
	suit = /obj/item/clothing/suit/wizrobe/red
	head = /obj/item/clothing/head/wizard/red

/datum/outfit/wizardcorpse/yellow
	suit = /obj/item/clothing/suit/wizrobe/yellow
	head = /obj/item/clothing/head/wizard/yellow

/datum/outfit/wizardcorpse/black
	suit = /obj/item/clothing/suit/wizrobe/black
	head = /obj/item/clothing/head/wizard/black

/datum/outfit/wizardcorpse/marisa
	suit = /obj/item/clothing/suit/wizrobe/marisa
	head = /obj/item/clothing/head/wizard/marisa
	shoes = /obj/item/clothing/shoes/sneakers/marisa

/datum/outfit/wizardcorpse/tape
	suit = /obj/item/clothing/suit/wizrobe/tape
	head = /obj/item/clothing/head/wizard/tape

/obj/effect/mob_spawn/corpse/human/wizard/dark
	name = "Dark Wizard Corpse"
	outfit = /datum/outfit/wizardcorpse/dark

/datum/outfit/wizardcorpse/dark
	head = /obj/item/clothing/head/wizard/hood

/obj/effect/mob_spawn/corpse/human/wizard/paper
	name = "Paper Wizard Corpse"
	outfit = /datum/outfit/paper_wizard

/datum/outfit/paper_wizard
	name = "Paper Wizard"
	uniform = /obj/item/clothing/under/color/white
	suit = /obj/item/clothing/suit/wizrobe/paper
	shoes = /obj/item/clothing/shoes/sandal/magic
	head = /obj/item/clothing/head/collectable/paper

/obj/effect/mob_spawn/corpse/human/nanotrasensoldier
	name = "\improper Nanotrasen Private Security Officer"
	outfit = /datum/outfit/nanotrasensoldiercorpse
	hairstyle = "Bald"
	facial_hairstyle = "Shaved"

/datum/outfit/nanotrasensoldiercorpse
	name = "\improper NT Private Security Officer Corpse"
	uniform = /obj/item/clothing/under/rank/security/officer
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/tackler/combat
	ears = /obj/item/radio/headset
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	head = /obj/item/clothing/head/helmet/swat/nanotrasen
	back = /obj/item/storage/backpack/security
	id = /obj/item/card/id/advanced/centcom
	id_trim = /datum/id_trim/centcom/corpse/private_security/tradepost_officer

/obj/effect/mob_spawn/corpse/human/nanotrasenassaultsoldier
	name = "\improper Nanotrasen Assault Officer Corpse"
	outfit = /datum/outfit/nanotrasenassaultsoldiercorpse
	hairstyle = "Bald"
	facial_hairstyle = "Shaved"

/datum/outfit/nanotrasenassaultsoldiercorpse
	name = "\improper NT Assault Officer Corpse"
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	head = /obj/item/clothing/head/helmet/swat/nanotrasen
	back = /obj/item/storage/backpack/security
	id = /obj/item/card/id/advanced/centcom
	id_trim = /datum/id_trim/centcom/corpse/assault

/obj/effect/mob_spawn/corpse/human/nanotrasenelitesoldier
	name = "\improper Nanotrasen Elite Assault Officer Corpse"
	outfit = /datum/outfit/nanotrasenelitesoldiercorpse
	hairstyle = "Bald"
	facial_hairstyle = "Shaved"

/datum/outfit/nanotrasenelitesoldiercorpse
	name = "\improper NT Elite Assault Officer Corpse"
	uniform = /obj/item/clothing/under/rank/centcom/military
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	back = /obj/item/mod/control/pre_equipped/responsory/security
	id = /obj/item/card/id/advanced/centcom
	id_trim = /datum/id_trim/centcom/ert/security

/obj/effect/mob_spawn/corpse/human/cat_butcher
	name = "The Cat Surgeon"
	hairstyle = "Cut Hair"
	facial_hairstyle = "Watson Mustache"
	skin_tone = "caucasian1"
	outfit = /datum/outfit/cat_butcher

/datum/outfit/cat_butcher
	name = "Cat Butcher Uniform"
	uniform = /obj/item/clothing/under/rank/medical/scrubs/green
	suit = /obj/item/clothing/suit/apron/surgical
	shoes = /obj/item/clothing/shoes/sneakers/white
	gloves = /obj/item/clothing/gloves/latex/nitrile
	ears = /obj/item/radio/headset
	back = /obj/item/storage/backpack/satchel/med
	id = /obj/item/card/id/advanced
	glasses = /obj/item/clothing/glasses/hud/health
	id_trim = /datum/id_trim/away/cat_surgeon

/obj/effect/mob_spawn/corpse/human/bee_terrorist
	name = "BLF Operative"
	outfit = /datum/outfit/bee_terrorist

/datum/outfit/bee_terrorist
	name = "BLF Operative"
	uniform = /obj/item/clothing/under/color/yellow
	suit = /obj/item/clothing/suit/hooded/bee_costume
	shoes = /obj/item/clothing/shoes/sneakers/yellow
	gloves = /obj/item/clothing/gloves/color/yellow
	ears = /obj/item/radio/headset
	belt = /obj/item/storage/belt/fannypack/yellow/bee_terrorist
	id = /obj/item/card/id/advanced
	l_pocket = /obj/item/paper/fluff/bee_objectives
	mask = /obj/item/clothing/mask/animal/small/bee

/obj/effect/mob_spawn/corpse/human/generic_assistant
	name = "Generic Assistant"
	hairstyle = "Short Hair"
	haircolor = COLOR_BLACK
	facial_hairstyle = "Shaved"
	skin_tone = "caucasian1"
	outfit = /datum/outfit/job/assistant/consistent

/obj/effect/mob_spawn/corpse/human/prey_pod
	husk = TRUE
	outfit = /datum/outfit/prey_pod_victim

/datum/outfit/prey_pod_victim
	name = "Prey Pod Victim"
	uniform = /obj/item/clothing/under/rank/rnd/roboticist

/obj/effect/mob_spawn/corpse/human/cyber_police
	name = "Dead Cyber Police"
	outfit = /datum/outfit/cyber_police
