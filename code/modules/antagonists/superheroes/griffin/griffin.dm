/datum/outfit/superhero/villain/griffin
	name = "Griffin"
	uniform = /obj/item/clothing/under/costume/griffin
	suit = /obj/item/clothing/suit/toggle/owlwings/griffinwings/griffin
	shoes = /obj/item/clothing/shoes/griffin
	ears = /obj/item/radio/headset
	gloves = /obj/item/clothing/gloves/color/white/griffin
	head = /obj/item/clothing/head/griffin/griffin
	back = /obj/item/storage/backpack
	glasses = /obj/item/clothing/glasses/sunglasses
	mask = /obj/item/clothing/mask/gas
	belt = /obj/item/storage/belt/utility/griffon
	r_pocket = /obj/item/grenade/smokebomb
	l_pocket = /obj/item/restraints/handcuffs/cable
	implants = list(/obj/item/implant/freedom)

/datum/outfit/superhero/villain/griffin/post_equip(mob/living/carbon/human/H, visualsOnly=FALSE)
	. = ..()
	if(!H.mind)
		return

	var/obj/effect/proc_holder/spell/spell = new /obj/effect/proc_holder/spell/pointed/griffin_convert()
	H.mind.AddSpell(spell)

/datum/outfit/superhero/villain/griffin/space
	name = "Griffin (Operation Starbird)"
	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/tank/jetpack/oxygen/harness/griffin
	internals_slot = ITEM_SLOT_SUITSTORE

/datum/outfit/superhero/villain/griffin/space/post_equip(mob/living/carbon/human/H, visualsOnly=FALSE)
	. = ..()
	H.dna.add_mutation(SPACEMUT) //He gets space adapt instead of a hardsuit

/datum/outfit/superhero/villain/griffin_nude
	name = "Griffin (Nude)"
	uniform = /obj/item/clothing/under/costume/griffin
	shoes = /obj/item/clothing/shoes/griffin
	ears = /obj/item/radio/headset
	gloves = /obj/item/clothing/gloves/color/white/griffin
	implants = list(/obj/item/implant/freedom)

/datum/outfit/superhero/villain/griffin_nude/post_equip(mob/living/carbon/human/H, visualsOnly=FALSE)
	. = ..()
	if(!H.mind)
		return

	var/obj/effect/proc_holder/spell/spell = new /obj/effect/proc_holder/spell/pointed/griffin_convert()
	H.mind.AddSpell(spell)

/datum/outfit/superhero/villain/griffin_nude/full
	name = "Griffin (Nude, Full equip)"

/datum/outfit/superhero/villain/griffin_nude/full/post_equip(mob/living/carbon/human/H, visualsOnly=FALSE)
	. = ..()
	H.dna.add_mutation(SPACEMUT)

/datum/outfit/superhero/villain/griffin/winter
	name = "Griffin (Operation Cryosting)"
	suit = /obj/item/clothing/suit/hooded/wintercoat/griffin
	head = null
	suit_store = /obj/item/tank/internals/oxygen
	internals_slot = ITEM_SLOT_SUITSTORE

/datum/outfit/superhero/villain/griffin/winter/post_equip(mob/living/carbon/human/H, visualsOnly=FALSE)
	. = ..()

	var/obj/item/clothing/suit/hooded/wintercoat/griffin/suit = H.get_item_by_slot(ITEM_SLOT_OCLOTHING)
	suit.ToggleHood()

/datum/outfit/superhero/villain/griffin_nude/spawner
	name = "Griffin (Spawner)"
	implants = list()
