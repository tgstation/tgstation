//Meant for simple animals to drop lootable human bodies.

//If someone can do this in a neater way, be my guest-Kor

//This has to be seperate from the Away Mission corpses, because New() doesn't work for those, and initialize() doesn't work for these.

//To do: Allow corpses to appear mangled, bloody, etc. Allow customizing the bodies appearance (they're all bald and white right now).

//List of different corpse types

/obj/effect/mob_spawn/human/corpse/syndicatesoldier
	name = "Syndicate Operative"
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	radio = /obj/item/device/radio/headset
	mask = /obj/item/clothing/mask/gas
	helmet = /obj/item/clothing/head/helmet/swat
	back = /obj/item/weapon/storage/backpack
	has_id = 1
	id_job = "Operative"
	id_access_list = list(GLOB.access_syndicate)

/obj/effect/mob_spawn/human/corpse/syndicatecommando
	name = "Syndicate Commando"
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/space/hardsuit/syndi
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	radio = /obj/item/device/radio/headset
	mask = /obj/item/clothing/mask/gas/syndicate
	back = /obj/item/weapon/tank/jetpack/oxygen
	pocket1 = /obj/item/weapon/tank/internals/emergency_oxygen
	has_id = 1
	id_job = "Operative"
	id_access_list = list(GLOB.access_syndicate)

/obj/effect/mob_spawn/human/corpse/syndicatestormtrooper
	name = "Syndicate Stormtrooper"
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/space/hardsuit/syndi/elite
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	radio = /obj/item/device/radio/headset
	mask = /obj/item/clothing/mask/gas/syndicate
	back = /obj/item/weapon/tank/jetpack/oxygen/harness
	has_id = 1
	id_job = "Operative"
	id_access_list = list(GLOB.access_syndicate)



/obj/effect/mob_spawn/human/clown/corpse
	roundstart = FALSE
	instant = TRUE


/obj/effect/mob_spawn/human/corpse/pirate
	name = "Pirate"
	uniform = /obj/item/clothing/under/pirate
	shoes = /obj/item/clothing/shoes/jackboots
	glasses = /obj/item/clothing/glasses/eyepatch
	helmet = /obj/item/clothing/head/bandana



/obj/effect/mob_spawn/human/corpse/pirate/ranged
	name = "Pirate Gunner"
	suit = /obj/item/clothing/suit/pirate
	helmet = /obj/item/clothing/head/pirate

/obj/effect/mob_spawn/human/corpse/russian
	name = "Russian"
	uniform = /obj/item/clothing/under/soviet
	shoes = /obj/item/clothing/shoes/jackboots
	helmet = /obj/item/clothing/head/bearpelt

/obj/effect/mob_spawn/human/corpse/russian/ranged
	helmet = /obj/item/clothing/head/ushanka

/obj/effect/mob_spawn/human/corpse/russian/ranged/trooper
	uniform = /obj/item/clothing/under/syndicate/camo
	suit = /obj/item/clothing/suit/armor/bulletproof
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	radio = /obj/item/device/radio/headset
	mask = /obj/item/clothing/mask/balaclava
	helmet = /obj/item/clothing/head/helmet/alt

/obj/effect/mob_spawn/human/corpse/russian/ranged/officer
	name = "Russian Officer"
	uniform = /obj/item/clothing/under/rank/security/navyblue/russian
	suit = /obj/item/clothing/suit/security/officer/russian
	shoes = /obj/item/clothing/shoes/laceup
	radio = /obj/item/device/radio/headset
	helmet = /obj/item/clothing/head/ushanka

/obj/effect/mob_spawn/human/corpse/wizard
	name = "Space Wizard"
	uniform = /obj/item/clothing/under/color/lightpurple
	suit = /obj/item/clothing/suit/wizrobe
	shoes = /obj/item/clothing/shoes/sandal/magic
	helmet = /obj/item/clothing/head/wizard


/obj/effect/mob_spawn/human/corpse/nanotrasensoldier
	name = "Nanotrasen Private Security Officer"
	uniform = /obj/item/clothing/under/rank/security
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	radio = /obj/item/device/radio/headset
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	helmet = /obj/item/clothing/head/helmet/swat/nanotrasen
	back = /obj/item/weapon/storage/backpack/security
	has_id = 1
	id_job = "Private Security Force"
	id_access = "Security Officer"