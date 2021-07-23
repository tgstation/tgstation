/obj/effect/spawner/lootdrop/medical
	name = "medical loot spawner"
	desc = "Doc, gimmie something good."

/obj/effect/spawner/lootdrop/medical/organ_spawner
	name = "ayylien organ spawner"
	lootcount = 3
	loot = list(
		/obj/item/organ/heart/gland/egg = 7,
		/obj/item/organ/heart/gland/plasma = 7,
		/obj/item/organ/heart/gland/chem = 5,
		/obj/item/organ/heart/gland/mindshock = 5,
		/obj/item/organ/heart/gland/transform = 5,
		/obj/item/organ/heart/gland/spiderman = 5,
		/obj/item/organ/heart/gland/slime = 4,
		/obj/item/organ/heart/gland/trauma = 4,
		/obj/item/organ/heart/gland/electric = 3,
		/obj/item/organ/regenerative_core = 2,
		/obj/item/organ/heart/gland/ventcrawling = 1,
		/obj/item/organ/body_egg/alien_embryo = 1,
	)

/obj/effect/spawner/lootdrop/medical/memeorgans
	name = "meme organ spawner"
	lootcount = 5
	loot = list(
		/obj/item/organ/ears/penguin,
		/obj/item/organ/ears/cat,
		/obj/item/organ/eyes/moth,
		/obj/item/organ/eyes/snail,
		/obj/item/organ/tongue/bone,
		/obj/item/organ/tongue/fly,
		/obj/item/organ/tongue/snail,
		/obj/item/organ/tongue/lizard,
		/obj/item/organ/tongue/alien,
		/obj/item/organ/tongue/ethereal,
		/obj/item/organ/tongue/robot,
		/obj/item/organ/tongue/zombie,
		/obj/item/organ/appendix,
		/obj/item/organ/liver/fly,
		/obj/item/organ/lungs/plasmaman,
		/obj/item/organ/tail/cat,
		/obj/item/organ/tail/lizard,
	)

/obj/effect/spawner/lootdrop/medical/two_percent_xeno_egg_spawner
	name = "2% chance xeno egg spawner"
	loot = list(
		/obj/effect/decal/remains/xeno = 49,
		/obj/effect/spawner/xeno_egg_delivery = 1,
	)
