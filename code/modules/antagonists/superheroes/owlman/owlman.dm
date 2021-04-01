//The best(actually the worst and the weakest) superhero, Owlman!

/datum/outfit/superhero/owlman
	name = "Owlman"
	uniform = /obj/item/clothing/under/costume/owl
	suit = /obj/item/clothing/suit/toggle/owlwings/owlman
	shoes = /obj/item/clothing/shoes/sneakers/brown
	ears = /obj/item/radio/headset
	gloves = /obj/item/clothing/gloves/color/yellow
	back = /obj/item/storage/backpack
	glasses = /obj/item/clothing/glasses/night
	mask = /obj/item/clothing/mask/gas/owl_mask
	belt = /obj/item/storage/belt/champion/owlman
	l_pocket = /obj/item/reagent_containers/hypospray/medipen/pumpup
	r_pocket = /obj/item/restraints/handcuffs/cable

/datum/outfit/superhero/owlman/space
	name = "Owlman (Operation Starshine)"
	suit = /obj/item/clothing/suit/space/hardsuit/syndi/owl
	suit_store = /obj/item/tank/internals/oxygen
	internals_slot = ITEM_SLOT_SUITSTORE

/datum/outfit/superhero/owlman/post_equip(mob/living/carbon/human/H, visualsOnly=FALSE)
	. = ..()
	if(!H.mind)
		return
	H.mind.AddSpell(/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash/long/owlman)
	H.mind.AddSpell(/obj/effect/proc_holder/spell/targeted/owl_rush)
