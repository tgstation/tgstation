SUBSYSTEM_DEF(traumas)
	name = "Traumas"
	flags = SS_NO_FIRE
	var/list/phobia_types
	var/list/phobia_words
	var/list/phobia_mobs
	var/list/phobia_objs
	var/list/phobia_turfs
	var/list/phobia_species

#define PHOBIA_FILE "phobia.json"

/datum/controller/subsystem/traumas/Initialize()
	phobia_types = list("spiders", "space", "security", "clowns", "greytide", "lizards", "skeletons", "snakes")

	phobia_words = list("spiders"   = strings(PHOBIA_FILE, "spiders"),
						"space"     = strings(PHOBIA_FILE, "space"),
						"security"  = strings(PHOBIA_FILE, "security"),
						"clowns"    = strings(PHOBIA_FILE, "clowns"),
						"greytide"  = strings(PHOBIA_FILE, "greytide"),
						"lizards"   = strings(PHOBIA_FILE, "lizards"),
						"skeletons" = strings(PHOBIA_FILE, "skeletons"),
						"snakes" = strings(PHOBIA_FILE, "snakes"),
						"conspiracies" = strings(PHOBIA_FILE, "conspiracies")
					   )

	phobia_mobs = list("spiders"  = typecacheof(list(/mob/living/simple_animal/hostile/poison/giant_spider)),
					   "security" = typecacheof(list(/mob/living/simple_animal/bot/secbot)),
					   "lizards"  = typecacheof(list(/mob/living/simple_animal/hostile/lizard)),
					   "snakes"   = typecacheof(list(/mob/living/simple_animal/hostile/retaliate/poison/snake)),
					   "conspiracies" = typecacheof(list(/mob/living/simple_animal/bot/secbot, /mob/living/simple_animal/bot/ed209, /mob/living/simple_animal/drone))
					   )

	phobia_objs = list("spiders"   = typecacheof(list(/obj/structure/spider)),
					   "security"  = typecacheof(list(/obj/item/clothing/under/rank/security, /obj/item/clothing/under/rank/warden,
											 	 /obj/item/clothing/under/rank/head_of_security, /obj/item/clothing/under/rank/det,
												 /obj/item/melee/baton, /obj/item/gun/energy/taser, /obj/item/restraints/handcuffs,
												 /obj/machinery/door/airlock/security)),
					   "clowns"    = typecacheof(list(/obj/item/clothing/under/rank/clown, /obj/item/clothing/shoes/clown_shoes,
												 /obj/item/clothing/mask/gas/clown_hat, /obj/item/device/instrument/bikehorn,
												 /obj/item/device/pda/clown, /obj/item/grown/bananapeel)),
					   "greytide"  = typecacheof(list(/obj/item/clothing/under/color/grey, /obj/item/melee/baton/cattleprod,
												 /obj/item/twohanded/spear, /obj/item/clothing/mask/gas)),
					   "lizards"   = typecacheof(list(/obj/item/toy/plush/lizardplushie, /obj/item/reagent_containers/food/snacks/kebab/tail,
												 /obj/item/organ/tail/lizard, /obj/item/reagent_containers/food/drinks/bottle/lizardwine)),
					   "skeletons" = typecacheof(list(/obj/item/organ/tongue/bone, /obj/item/clothing/suit/armor/bone, /obj/item/stack/sheet/bone,
												 /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/skeleton,
												 /obj/effect/decal/remains/human)),
				   "conspiracies" = typecacheof(list(/obj/item/clothing/under/rank/captain, /obj/item/clothing/under/rank/head_of_security,
												 /obj/item/clothing/under/rank/chief_engineer, /obj/item/clothing/under/rank/chief_medical_officer,
												 /obj/item/clothing/under/rank/head_of_personnel, /obj/item/clothing/under/rank/research_director,
												 /obj/item/clothing/under/rank/head_of_security/grey, /obj/item/clothing/under/rank/head_of_security/alt,
												 /obj/item/clothing/under/rank/research_director/alt, /obj/item/clothing/under/rank/research_director/turtleneck,
												 /obj/item/clothing/under/captainparade, /obj/item/clothing/under/hosparademale, /obj/item/clothing/under/hosparadefem,
												 /obj/item/clothing/head/helmet/abductor, /obj/item/clothing/suit/armor/abductor/vest, /obj/item/abductor_baton,
												 /obj/item/storage/belt/military/abductor, /obj/item/gun/energy/alien, /obj/item/device/abductor/silencer,
												 /obj/item/device/abductor/gizmo, /obj/item/clothing/under/rank/centcom_officer,
												 /obj/item/clothing/suit/space/hardsuit/ert, /obj/item/clothing/suit/space/hardsuit/ert/sec,
												 /obj/item/clothing/suit/space/hardsuit/ert/engi, /obj/item/clothing/suit/space/hardsuit/ert/med,
												 /obj/item/clothing/suit/space/hardsuit/deathsquad, /obj/item/clothing/head/helmet/space/hardsuit/deathsquad,
												 /obj/machinery/door/airlock/centcom))
					   )
	phobia_turfs = list("space" = typecacheof(list(/turf/open/space, /turf/open/floor/holofloor/space, /turf/open/floor/fakespace)))

	phobia_species = list("lizards"   = typecacheof(list(/datum/species/lizard)),
						  "skeletons" = typecacheof(list(/datum/species/skeleton, /datum/species/plasmaman)),
						  "conspiracies" = typecacheof(list(/datum/species/abductor, /datum/species/lizard, /datum/species/synth))
						 )

#undef PHOBIA_FILE
