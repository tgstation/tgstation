//Not really a lot of unique gear or anything, but he gets a really neat CQC-Carp martial art and a katana

/datum/outfit/superhero/villain/nekometic
	name = "Nekometic"
	uniform = /obj/item/clothing/under/costume/schoolgirl/nekometic
	shoes = /obj/item/clothing/shoes/jackboots
	ears = /obj/item/radio/headset
	gloves = /obj/item/clothing/gloves/combat/nekometic
	head = /obj/item/clothing/head/kitty
	belt = /obj/item/katana

/datum/outfit/superhero/villain/nekometic/post_equip(mob/living/carbon/human/H)
	. = ..()
	H.hair_color = "#000000"
	H.facial_hair_color = "#000000"
	H.hairstyle = "Bald"
	H.facial_hairstyle = "Moustache (Fu Manchu)"
	H.update_hair()

	var/datum/species/species = H.dna.species
	species.punchstunthreshold = 13 //Yes, his punches almost always knock people down. Don't mess with him.
	species.punchdamagelow = 11
	species.punchdamagehigh = 21 //KNOCKOUT!!

/datum/outfit/superhero/villain/nekometic_nude
	name = "Nekometic (Nude)"
	uniform = /obj/item/clothing/under/costume/schoolgirl/nekometic
	shoes = /obj/item/clothing/shoes/sneakers/black
	ears = /obj/item/radio/headset
	head = /obj/item/clothing/head/kitty

/datum/outfit/superhero/villain/nekometic/space
	name = "Nekometic (Operation Starbird)"
	uniform = /obj/item/clothing/under/costume/schoolgirl
	suit = /obj/item/clothing/suit/space/hardsuit/syndi/nekometic
	head = null
	suit_store = /obj/item/tank/internals/oxygen
	mask = /obj/item/clothing/mask/gas
	internals_slot = ITEM_SLOT_SUITSTORE

/datum/outfit/superhero/villain/nekometic/winter
	name = "Nekometic (Operation Cryosting)"
	uniform = /obj/item/clothing/under/costume/schoolgirl
	suit = /obj/item/clothing/suit/hooded/wintercoat/nekometic
	head = null

/datum/outfit/superhero/villain/nekometic/winter/post_equip(mob/living/carbon/human/H, visualsOnly=FALSE)
	. = ..()

	var/obj/item/clothing/suit/hooded/wintercoat/nekometic/suit = H.get_item_by_slot(ITEM_SLOT_OCLOTHING)
	suit.ToggleHood()
