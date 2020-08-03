
//what people wear unrevealed

/datum/outfit/mafia
	name = "Mafia Game Outfit"
	uniform = /obj/item/clothing/under/color/grey
	shoes = /obj/item/clothing/shoes/sneakers/black

//town

/datum/outfit/mafia/assistant
	name = "Mafia Assistant"

	uniform = /obj/item/clothing/under/color/rainbow

/datum/outfit/mafia/detective
	name = "Mafia Detective"

	uniform = /obj/item/clothing/under/rank/security/detective
	neck = /obj/item/clothing/neck/tie/detective
	shoes = /obj/item/clothing/shoes/sneakers/brown
	suit = /obj/item/clothing/suit/det_suit
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/fedora/det_hat
	mask = /obj/item/clothing/mask/cigarette

/datum/outfit/mafia/psychologist
	name = "Mafia Psychologist"

	uniform = /obj/item/clothing/under/suit/black
	shoes = /obj/item/clothing/shoes/laceup

/datum/outfit/mafia/md
	name = "Mafia Medical Doctor"

	uniform = /obj/item/clothing/under/rank/medical/doctor
	shoes = /obj/item/clothing/shoes/sneakers/white
	suit =  /obj/item/clothing/suit/toggle/labcoat

/datum/outfit/mafia/chaplain
	name = "Mafia Chaplain"

	uniform = /obj/item/clothing/under/rank/civilian/chaplain

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
	head = /obj/item/clothing/head/hopcap
	glasses = /obj/item/clothing/glasses/sunglasses

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
	gloves = /obj/item/clothing/gloves/color/latex
	mask = /obj/item/clothing/mask/surgical
	suit = /obj/item/clothing/suit/apron

/datum/outfit/mafia/obsessed/post_equip(mob/living/carbon/human/H)
	for(var/obj/item/carried_item in H.get_equipped_items(TRUE))
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
