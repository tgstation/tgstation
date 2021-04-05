//Ianiser, the great electrofurry!
/datum/outfit/superhero/ianiser
	name = "Ianiser"
	uniform = /obj/item/clothing/under/color/white
	shoes = /obj/item/clothing/shoes/sneakers/brown
	suit = /obj/item/clothing/suit/hooded/ian_costume/ianiser
	ears = /obj/item/radio/headset
	gloves = /obj/item/clothing/gloves/color/white
	back = /obj/item/storage/backpack

/datum/outfit/superhero/ianiser/post_equip(mob/living/carbon/human/H, visualsOnly=FALSE)
	. = ..()
	H.dna.add_mutation(INSULATED)
	H.dna.add_mutation(SHOCKTOUCH)

	var/obj/item/clothing/suit/hooded/ian_costume/ianiser/suit = H.get_item_by_slot(ITEM_SLOT_OCLOTHING)
	suit.ToggleHood()

	if(!H.mind)
		return

	var/obj/effect/proc_holder/spell/spell = new /obj/effect/proc_holder/spell/aimed/lightningbolt/lesser
	H.mind.AddSpell(spell)

	var/obj/effect/proc_holder/spell/spell2 = new /obj/effect/proc_holder/spell/pointed/lightning_jaunt
	H.mind.AddSpell(spell2)

/datum/outfit/superhero/ianiser_nude
	name = "Ianiser (Nude)"
	uniform = /obj/item/clothing/under/color/white
	shoes = /obj/item/clothing/shoes/sneakers/brown
	ears = /obj/item/radio/headset
	gloves = /obj/item/clothing/gloves/color/white
	back = /obj/item/storage/backpack

/datum/outfit/superhero/ianiser_nude/post_equip(mob/living/carbon/human/H, visualsOnly=FALSE)
	. = ..()
	H.dna.add_mutation(INSULATED)
	H.dna.add_mutation(SHOCKTOUCH)

	if(!H.mind)
		return

	var/obj/effect/proc_holder/spell/spell = new /obj/effect/proc_holder/spell/aimed/lightningbolt/lesser
	H.mind.AddSpell(spell)

	var/obj/effect/proc_holder/spell/spell2 = new /obj/effect/proc_holder/spell/pointed/lightning_jaunt
	H.mind.AddSpell(spell2)
