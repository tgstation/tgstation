
//The default outfit for during play

/datum/outfit/mafia
	name = "Mafia Default Outfit"
	uniform = /obj/item/clothing/under/color/grey
	shoes = /obj/item/clothing/shoes/sneakers/black

///Map-specific custom outfits

/datum/outfit/mafia/abductee
	name = "Mafia Abductee"
	uniform = /obj/item/clothing/under/abductor
	shoes = /obj/item/clothing/shoes/combat

/datum/outfit/mafia/syndie
	name = "Mafia Syndicate"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/color/black

/datum/outfit/mafia/lavaland
	name = "Mafia Wastelander"
	mask = /obj/item/clothing/mask/breath
	shoes = /obj/item/clothing/shoes/sneakers/black
	suit = /obj/item/clothing/suit/hooded/cloak/goliath
	uniform = /obj/item/clothing/under/rank/cargo/miner

/datum/outfit/mafia/ninja
	name = "Mafia Ninja"
	glasses = /obj/item/clothing/glasses/sunglasses
	suit = /obj/item/clothing/suit/costume/wellworn_shirt/graphic/ian
	uniform = /obj/item/clothing/under/pants/jeans
	shoes = /obj/item/clothing/shoes/sandal

/datum/outfit/mafia/snowy
	name = "Mafia Outwear"
	gloves = /obj/item/clothing/gloves/color/black
	suit = /obj/item/clothing/suit/hooded/wintercoat
	shoes = /obj/item/clothing/shoes/winterboots
	uniform = /obj/item/clothing/under/rank/civilian/curator/treasure_hunter

/datum/outfit/mafia/gothic
	name = "Mafia Castlegoer"
	glasses = /obj/item/clothing/glasses/monocle
	gloves = /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/laceup
	suit = /obj/item/clothing/suit/costume/gothcoat
	uniform = /obj/item/clothing/under/costume/buttondown/slacks/service

//town

/datum/outfit/mafia/assistant
	name = "Mafia Assistant"

	uniform = /obj/item/clothing/under/color/rainbow

/datum/outfit/mafia/detective
	name = "Mafia Detective"

	uniform = /obj/item/clothing/under/rank/security/detective
	neck = /obj/item/clothing/neck/tie/detective
	shoes = /obj/item/clothing/shoes/sneakers/brown
	suit = /obj/item/clothing/suit/jacket/det_suit
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/fedora/det_hat
	mask = /obj/item/clothing/mask/cigarette

/datum/outfit/mafia/psychologist
	name = "Mafia Psychologist"

	uniform = /obj/item/clothing/under/costume/buttondown/slacks/service
	neck = /obj/item/clothing/neck/tie/black/tied
	shoes = /obj/item/clothing/shoes/laceup

/datum/outfit/mafia/chaplain
	name = "Mafia Chaplain"

	uniform = /obj/item/clothing/under/rank/civilian/chaplain

/datum/outfit/mafia/md
	name = "Mafia Medical Doctor"

	uniform = /obj/item/clothing/under/rank/medical/scrubs/blue
	shoes = /obj/item/clothing/shoes/sneakers/white
	suit = /obj/item/clothing/suit/toggle/labcoat

/datum/outfit/mafia/security
	name = "Mafia Security Officer"

	uniform = /obj/item/clothing/under/rank/security/officer
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/helmet/sec
	suit = /obj/item/clothing/suit/armor/vest/alt
	shoes = /obj/item/clothing/shoes/jackboots

/datum/outfit/mafia/lawyer
	name = "Mafia Lawyer"

	uniform = /obj/item/clothing/under/rank/civilian/lawyer/bluesuit
	suit = /obj/item/clothing/suit/toggle/lawyer
	shoes = /obj/item/clothing/shoes/laceup

/datum/outfit/mafia/hop
	name = "Mafia Head of Personnel"

	uniform = /obj/item/clothing/under/rank/civilian/head_of_personnel
	suit = /obj/item/clothing/suit/armor/vest/alt
	shoes = /obj/item/clothing/shoes/sneakers/brown
	head = /obj/item/clothing/head/hats/hopcap
	glasses = /obj/item/clothing/glasses/sunglasses

/datum/outfit/mafia/hos
	name = "Mafia Head of Security"

	uniform = /obj/item/clothing/under/rank/security/head_of_security
	shoes = /obj/item/clothing/shoes/jackboots
	suit = /obj/item/clothing/suit/armor/hos/trenchcoat
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/hats/hos/beret
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses

/datum/outfit/mafia/warden
	name = "Mafia Warden"

	uniform = /obj/item/clothing/under/rank/security/warden
	shoes = /obj/item/clothing/shoes/jackboots
	suit = /obj/item/clothing/suit/armor/vest/warden/alt
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/hats/warden/red
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses

//mafia

/datum/outfit/mafia/changeling
	name = "Mafia Changeling"

	head = /obj/item/clothing/head/helmet/changeling
	suit = /obj/item/clothing/suit/armor/changeling

//solo

/datum/outfit/mafia/fugitive
	name = "Mafia Fugitive"

	uniform = /obj/item/clothing/under/rank/prisoner
	shoes = /obj/item/clothing/shoes/sneakers/orange

/datum/outfit/mafia/obsessed
	name = "Mafia Obsessed"
	uniform = /obj/item/clothing/under/misc/overalls
	shoes = /obj/item/clothing/shoes/sneakers/white
	gloves = /obj/item/clothing/gloves/latex
	mask = /obj/item/clothing/mask/surgical
	suit = /obj/item/clothing/suit/apron

/datum/outfit/mafia/obsessed/post_equip(mob/living/carbon/human/H)
	for(var/obj/item/carried_item in H.get_equipped_items(INCLUDE_POCKETS | INCLUDE_ACCESSORIES))
		carried_item.add_mob_blood(H)//Oh yes, there will be blood...
	H.regenerate_icons()

/datum/outfit/mafia/clown
	name = "Mafia Clown"

	uniform = /obj/item/clothing/under/rank/civilian/clown
	shoes = /obj/item/clothing/shoes/clown_shoes
	mask = /obj/item/clothing/mask/gas/clown_hat

/datum/outfit/mafia/traitor
	name = "Mafia Traitor"

	mask = /obj/item/clothing/mask/gas/syndicate
	uniform = /obj/item/clothing/under/syndicate/tacticool
	shoes = /obj/item/clothing/shoes/jackboots

/datum/outfit/mafia/nightmare
	name = "Mafia Nightmare"

	uniform = null
	shoes = null
