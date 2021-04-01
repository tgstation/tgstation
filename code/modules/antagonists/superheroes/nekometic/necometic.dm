//Not really a lot of unique gear or anything, but he gets a really neat CQC-Carp martial art... and ability to turn others into felinids with his blood!

/datum/outfit/superhero/nekometic
	name = "Nekometic"
	uniform = /obj/item/clothing/under/costume/schoolgirl
	shoes = /obj/item/clothing/shoes/jackboots
	ears = /obj/item/radio/headset
	gloves = /obj/item/clothing/gloves/combat/nekometic

/datum/outfit/superhero/nekometic/post_equip(mob/living/carbon/human/H, visualsOnly=FALSE)
	. = ..()
	H.set_species(/datum/species/human/felinid)
	H.species.exotic_blood = /datum/reagent/mutationtoxin/felinid
