/obj/effect/spawner/random/medical
	name = "medical loot spawner"
	desc = "Doc, gimmie something good."

/obj/effect/spawner/random/medical/minor_healing
	name = "minor healing spawner"
	loot = list(
		/obj/item/stack/medical/suture,
		/obj/item/stack/medical/mesh,
		/obj/item/stack/medical/gauze,
	)

/obj/effect/spawner/random/medical/injector
	name = "injector spawner"
	loot = list(
		/obj/item/implanter,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe,
	)

/obj/effect/spawner/random/medical/organ_spawner
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

/obj/effect/spawner/random/medical/memeorgans
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
