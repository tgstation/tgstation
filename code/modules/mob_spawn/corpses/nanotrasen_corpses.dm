
//generally nanotrasen themed corpses

/obj/effect/mob_spawn/corpse/human/bridgeofficer
	name = "Bridge Officer"
	outfit = /datum/outfit/nanotrasenbridgeofficer

/datum/outfit/nanotrasenbridgeofficer
	name = "Bridge Officer"
	ears = /obj/item/radio/headset/heads/hop
	uniform = /obj/item/clothing/under/rank/centcom/officer
	suit = /obj/item/clothing/suit/armor/bulletproof
	shoes = /obj/item/clothing/shoes/sneakers/black
	glasses = /obj/item/clothing/glasses/sunglasses
	id = /obj/item/card/id/advanced/centcom
	id_trim = /datum/id_trim/centcom/corpse/bridge_officer

/obj/effect/mob_spawn/corpse/human/commander
	name = "Commander"
	outfit = /datum/outfit/nanotrasencommander

/datum/outfit/nanotrasencommander
	name = "\improper Nanotrasen Private Security Commander"
	uniform = /obj/item/clothing/under/rank/centcom/commander
	suit = /obj/item/clothing/suit/armor/bulletproof
	ears = /obj/item/radio/headset/heads/captain
	glasses = /obj/item/clothing/glasses/eyepatch
	mask = /obj/item/cigarette/cigar/cohiba
	head = /obj/item/clothing/head/hats/centhat
	gloves = /obj/item/clothing/gloves/tackler/combat
	shoes = /obj/item/clothing/shoes/combat/swat
	r_pocket = /obj/item/lighter
	id = /obj/item/card/id/advanced/centcom
	id_trim = /datum/id_trim/centcom/corpse/commander

/obj/effect/mob_spawn/corpse/human/nanotrasensoldier
	name = "\improper Nanotrasen Private Security Officer"
	outfit = /datum/outfit/nanotrasensoldier

/datum/outfit/nanotrasensoldier
	name = "NT Private Security Officer"
	uniform = /obj/item/clothing/under/rank/security/officer
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/tackler/combat
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	head = /obj/item/clothing/head/helmet/swat/nanotrasen
	back = /obj/item/storage/backpack/security
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/centcom/corpse/private_security

/obj/effect/mob_spawn/corpse/human/intern //this is specifically the comms intern from the event
	name = "CentCom Intern"
	outfit = /datum/outfit/centcom/centcom_intern/unarmed
	mob_name = "Nameless Intern"

/obj/effect/mob_spawn/corpse/human/intern/special(mob/living/carbon/human/spawned_human)
	. = ..()
	spawned_human.gender = MALE //we're making it canon babies
	spawned_human.update_body()
