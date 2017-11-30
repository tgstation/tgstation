SUBSYSTEM_DEF(traumas)
	name = "Traumas"
	flags = SS_NO_FIRE
	var/list/phobia_types
	var/list/phobia_words
	var/list/phobia_mobs
	var/list/phobia_objs
	var/list/phobia_turfs
	var/list/phobia_species

/datum/controller/subsystem/traumas/Initialize()
	phobia_types = list("spiders", "space", "security", "clowns", "greytide", "lizards", "skeletons")

	phobia_words = list("spiders"   = list("spider","web","arachnid"),
						"space"     = list("space", "star", "universe", "void"),
						"security"  = list(" sec ", "security", "shitcurity", "stunbaton", "taser", "beepsky"),
						"clowns"    = list("clown", "honk", "banana", "slip"),
						"greytide"  = list("assistant", "grey", "gasmask", "gas mask", "stunprod", "spear", "revolution", "viva"),
						"lizards"   = list("lizard", "ligger", "hiss", " wag "),
						"skeletons" = list("skeleton", "milk", "xylophone", "bone", "calcium", "the ride never ends")
					   )

	phobia_mobs = list("spiders"  = typecacheof(/mob/living/simple_animal/hostile/poison/giant_spider),
					   "security" = typecacheof(/mob/living/simple_animal/bot/secbot),
					   "lizards"  = typecacheof(/mob/living/simple_animal/hostile/lizard)
					   )

	phobia_objs = list("spiders"   = typecacheof(/obj/structure/spider),
					   "security"  = typecacheof(/obj/item/clothing/under/rank/security, /obj/item/clothing/under/rank/warden,
											 	 /obj/item/clothing/under/rank/head_of_security, /obj/item/clothing/under/rank/det,
												 /obj/item/melee/baton, /obj/item/gun/energy/taser, /obj/item/restraints/handcuffs,
												 /obj/machinery/door/airlock/security),
					   "clowns"    = typecacheof(/obj/item/clothing/under/rank/clown, /obj/item/clothing/shoes/clown_shoes,
												 /obj/item/clothing/mask/gas/clown_hat, /obj/item/device/instrument/bikehorn,
												 /obj/item/device/pda/clown, /obj/item/grown/bananapeel),
					   "greytide"  = typecacheof(/obj/item/clothing/under/color/grey, /obj/item/melee/baton/cattleprod,
												 /obj/item/twohanded/spear, /obj/item/clothing/mask/gas),
					   "lizards"   = typecacheof(/obj/item/toy/plush/lizardplushie, /obj/item/reagent_containers/food/snacks/kebab/tail,
												 /obj/item/organ/tail/lizard, /obj/item/reagent_containers/food/drinks/bottle/lizardwine),
					   "skeletons" = typecacheof(/obj/item/organ/tongue/bone, /obj/item/clothing/suit/armor/bone, /obj/item/stack/sheet/bone,
												 /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/skeleton,
												 /obj/effect/decal/remains/human)
					   )
	phobia_turfs = list("space" = typecacheof(/turf/open/space, /turf/open/floor/holofloor/space, /turf/open/floor/fakespace))

	phobia_species = list("lizards"   = typecacheof(/datum/species/lizard),
						  "skeletons" = typecacheof(/datum/species/skeleton, /datum/species/plasmaman)
						 )
