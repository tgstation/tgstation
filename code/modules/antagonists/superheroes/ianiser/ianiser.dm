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

	var/obj/effect/proc_holder/spell/spell = new /obj/effect/proc_holder/spell/aimed/lightningbolt/lesser()
	H.mind.AddSpell(spell)

	var/obj/effect/proc_holder/spell/spell2 = new /obj/effect/proc_holder/spell/pointed/lightning_jaunt()
	H.mind.AddSpell(spell2)

/datum/outfit/superhero/ianiser/space //Okay so this is the complicated one. Ianiser DOES NOT have a propper space gear. Instead, he has a spell which transforms him into a speedy ball of fur and energy that allows him to travel in space for a brief period of time.
	name = "Ianiser (Operation Starbird)"

/datum/outfit/superhero/ianiser/space/post_equip(mob/living/carbon/human/H, visualsOnly=FALSE)
	. = ..()
	var/obj/effect/proc_holder/spell/spell3 = new /obj/effect/proc_holder/spell/self/lightning_form()
	H.mind.AddSpell(spell3)

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

/datum/outfit/superhero/ianiser/winter
	name = "Ianiser (Operation Cryosting)"
	suit = /obj/item/clothing/suit/hooded/ian_costume/ianiser/winter
	shoes = /obj/item/clothing/shoes/wheelys/skishoes/ianiser

/datum/outfit/superhero/ianiser_nude/full
	name = "Ianiser (Nude, Full Spells)"

/datum/outfit/superhero/ianiser_nude/full/post_equip(mob/living/carbon/human/H, visualsOnly=FALSE)
	. = ..()

	var/obj/effect/proc_holder/spell/spell3 = new /obj/effect/proc_holder/spell/self/lightning_form()
	H.mind.AddSpell(spell3)

/datum/outfit/superhero/ianiser_spawner
	name = "Ianiser (Spawner)"
	uniform = /obj/item/clothing/under/color/white
	shoes = /obj/item/clothing/shoes/sneakers/brown
	ears = /obj/item/radio/headset
	gloves = /obj/item/clothing/gloves/color/white
	back = /obj/item/storage/backpack
