/datum/outfit/hermit
	name = "Wasteland Inhabitant Default Outfit"

/datum/outfit/hermit/survivor
	name = "Wasteland Survivor"
	uniform = /obj/item/clothing/under/color/random
	back = /obj/item/storage/backpack
	shoes = /obj/item/clothing/shoes/workboots/mining
	suit = /obj/item/clothing/suit/hooded/explorer/survivor
	r_pocket = /obj/item/tank/internals/emergency_oxygen/engi
	gloves = /obj/item/clothing/gloves/color/black

/datum/outfit/hermit/survivor/hunter
	name = "Wasteland Hunter"
	l_pocket = /obj/item/food/meat/steak/goliath

/datum/outfit/hermit/survivor/gunslinger
	name = "Wasteland Gunslinger"

/obj/effect/mob_spawn/corpse/human/hermit/survivor
	name = "Wasteland Survivor Corpse"
	outfit = /datum/outfit/hermit/survivor
	hairstyle = "Bald"
	skin_tone = "caucasian1"
	facial_hairstyle = "Shaved"

/obj/effect/mob_spawn/corpse/human/hermit/survivor/hunter
	name = "Wasteland Hunter Corpse"
	outfit = /datum/outfit/hermit/survivor/hunter

/obj/effect/mob_spawn/corpse/human/hermit/survivor/gunslinger
	name = "Wasteland Gunslinger Corpse"
	outfit = /datum/outfit/hermit/survivor/gunslinger
