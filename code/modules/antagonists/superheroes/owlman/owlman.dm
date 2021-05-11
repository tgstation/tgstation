//The best(actually the worst and the weakest) superhero, Owlman!
//He is(theoretically) the leader of superhero team, while the BuzzOn actually does all the job for him

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
	id = /obj/item/card/id/advanced/gold/captains_spare

/datum/outfit/superhero/owlman/space
	name = "Owlman (Operation Starbird)"
	suit = /obj/item/clothing/suit/space/hardsuit/syndi/owl
	suit_store = /obj/item/tank/internals/oxygen
	internals_slot = ITEM_SLOT_SUITSTORE

/datum/outfit/superhero/owlman/post_equip(mob/living/carbon/human/H, visualsOnly=FALSE)
	. = ..()
	if(!H.mind)
		return

	var/obj/effect/proc_holder/spell/spell = new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash/long/owlman()
	H.mind.AddSpell(spell)

	var/obj/effect/proc_holder/spell/spell2 = new /obj/effect/proc_holder/spell/targeted/owl_rush()
	H.mind.AddSpell(spell2)

/datum/outfit/superhero/owlman_nude
	name = "Owlman (Nude)"
	uniform = /obj/item/clothing/under/costume/owl
	shoes = /obj/item/clothing/shoes/sneakers/brown
	ears = /obj/item/radio/headset
	gloves = /obj/item/clothing/gloves/color/yellow
	back = /obj/item/storage/backpack
	id = /obj/item/card/id/advanced/gold/captains_spare

/datum/outfit/superhero/owlman_nude/post_equip(mob/living/carbon/human/H, visualsOnly=FALSE)
	. = ..()
	if(!H.mind)
		return

	var/obj/effect/proc_holder/spell/spell = new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash/long/owlman()
	H.mind.AddSpell(spell)

	var/obj/effect/proc_holder/spell/spell2 = new /obj/effect/proc_holder/spell/targeted/owl_rush()
	H.mind.AddSpell(spell2)

/datum/outfit/superhero/owlman/winter
	name = "Owlman (Operation Cryostung)"
	suit = /obj/item/clothing/suit/hooded/wintercoat/owlman
	shoes = /obj/item/clothing/shoes/winterboots
	suit_store = /obj/item/tank/internals/oxygen
	internals_slot = ITEM_SLOT_SUITSTORE
