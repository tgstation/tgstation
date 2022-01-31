//males

///uses a whip!
/datum/outfit/pirate/antonio
	name = "Antonio Belpaese"

	id = /obj/item/card/id/advanced/silver
	id_trim = /datum/id_trim/pirate/monster_hunters
	uniform = /obj/item/clothing/under/rank/centcom/intern/monster_hunters
	suit = /obj/item/clothing/suit/hooded/cloak/monster_hunters
	glasses = null
	gloves = /obj/item/clothing/gloves/botanic_leather
	head = null
	shoes = /obj/item/clothing/shoes/cowboy/black/monster_hunters

	l_hand = /obj/item/nullrod/whip/monster_hunters

/datum/outfit/pirate/antonio/post_equip(mob/living/carbon/human/equipped, visualsOnly)
	. = ..()
	if(visualsOnly)
		return
	prequipped.fully_replace_character_name(prequipped.real_name, name)

/datum/outfit/pirate/gennaro
	name = "Gennaro Belpaese"

	id = /obj/item/card/id/advanced/silver
	id_trim = /datum/id_trim/pirate/monster_hunters
	uniform = /obj/item/clothing/under/pants/tan
	suit = /obj/item/clothing/suit/armor/vest/alt
	belt = /obj/item/storage/belt/knives
	glasses = null
	gloves = /obj/item/clothing/gloves/color/black
	head = null
	shoes = /obj/item/clothing/shoes/cowboy/black/monster_hunters

/datum/outfit/pirate/gennaro/pre_equip(mob/living/carbon/human/prequipped, visualsOnly)
	. = ..()
	if(visualsOnly)
		return
	prequipped.fully_replace_character_name(prequipped.real_name, name)
	equipped.hairstyle = "Flair"
	equipped.hair_color = "#e8eb41"
	equipped.update_hair()

/datum/outfit/pirate/arca
	name = "Arca Ladonna"

	id = /obj/item/card/id/advanced/silver
	id_trim = /datum/id_trim/pirate/monster_hunters
	uniform = /obj/item/clothing/under/suit/charcoal
	suit = /obj/item/clothing/suit/armor/vest/alt
	glasses = /obj/item/clothing/glasses/monocle
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/collectable/tophat
	shoes = /obj/item/clothing/shoes/laceup

/datum/outfit/pirate/arca/pre_equip(mob/living/carbon/human/prequipped, visualsOnly)
	. = ..()
	if(visualsOnly)
		return
	prequipped.fully_replace_character_name(prequipped.real_name, name)

//females

/datum/outfit/pirate/imelda
	name = "Imelda Belpaese"

	id = /obj/item/card/id/advanced/silver
	id_trim = /datum/id_trim/pirate/monster_hunters
	uniform = /obj/item/clothing/under/suit/charcoal
	suit = /obj/item/clothing/suit/armor/vest/alt
	glasses = /obj/item/clothing/glasses/monocle
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/collectable/tophat
	shoes = /obj/item/clothing/shoes/laceup

/datum/outfit/pirate/imelda/pre_equip(mob/living/carbon/human/prequipped, visualsOnly)
	. = ..()
	if(visualsOnly)
		return
	prequipped.fully_replace_character_name(prequipped.real_name, name)

/datum/outfit/pirate/pasqualina
	name = "Pasqualina Belpaese"

	id = /obj/item/card/id/advanced/silver
	id_trim = /datum/id_trim/pirate/monster_hunters
	uniform = /obj/item/clothing/under/suit/charcoal
	suit = /obj/item/clothing/suit/armor/vest/alt
	glasses = /obj/item/clothing/glasses/monocle
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/collectable/tophat
	shoes = /obj/item/clothing/shoes/laceup

/datum/outfit/pirate/pasqualina/pre_equip(mob/living/carbon/human/prequipped, visualsOnly)
	. = ..()
	if(visualsOnly)
		return
	prequipped.fully_replace_character_name(prequipped.real_name, name)

/datum/outfit/pirate/porta
	name = "Porta Ladonna"

	id = /obj/item/card/id/advanced/silver
	id_trim = /datum/id_trim/pirate/monster_hunters
	uniform = /obj/item/clothing/under/suit/charcoal
	suit = /obj/item/clothing/suit/armor/vest/alt
	glasses = /obj/item/clothing/glasses/monocle
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/collectable/tophat
	shoes = /obj/item/clothing/shoes/laceup

/datum/outfit/pirate/porta/pre_equip(mob/living/carbon/human/prequipped, visualsOnly)
	. = ..()
	if(visualsOnly)
		return
	prequipped.fully_replace_character_name(prequipped.real_name, name)

///this skeleton can be from anyone!
/datum/outfit/pirate/mortaccio
	name = "Mortaccio"

	id = /obj/item/card/id/advanced/silver
	id_trim = /datum/id_trim/pirate/monster_hunters

	uniform = null
	suit = null
	glasses = null
	head = null
	shoes = null

	l_pocket = /obj/item/food/meat/slab/human/mutant/skeleton/boomerang
	r_pocket = /obj/item/food/meat/slab/human/mutant/skeleton/boomerang

/datum/outfit/pirate/mortaccio/pre_equip(mob/living/carbon/human/prequipped, visualsOnly)
	. = ..()
	if(visualsOnly)
		id = null
		l_pocket = null
		r_pocket = null
		return
	prequipped.set_species(/datum/species/skeleton)
	var/datum/species/skele_species = prequipped.dna.species
	skele_species.nojumpsuit = TRUE //allows Mort to have an ID without a jumpsuit.
	prequipped.fully_replace_character_name(prequipped.real_name, "Mortaccio")
	prequipped.underwear = "Nude"
	prequipped.undershirt = "Nude"
	prequipped.socks = "Nude"
	prequipped.update_body()
	//see, YOU'RE not a monster, lil mortaccio
	equipped.AddElement(/datum/element/halo/holy, initial_delay = 0)
