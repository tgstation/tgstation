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
	phobia_types = list("spiders", "space", "security", "clowns", "greytide", "lizards",
						"skeletons", "snakes", "robots", "doctors", "authority", "the supernatural",
						"aliens", "strangers")

	phobia_words = list("spiders"   = strings(PHOBIA_FILE, "spiders"),
						"space"     = strings(PHOBIA_FILE, "space"),
						"security"  = strings(PHOBIA_FILE, "security"),
						"clowns"    = strings(PHOBIA_FILE, "clowns"),
						"greytide"  = strings(PHOBIA_FILE, "greytide"),
						"lizards"   = strings(PHOBIA_FILE, "lizards"),
						"skeletons" = strings(PHOBIA_FILE, "skeletons"),
						"snakes"	= strings(PHOBIA_FILE, "snakes"),
						"robots"	= strings(PHOBIA_FILE, "robots"),
						"doctors"	= strings(PHOBIA_FILE, "doctors"),
						"authority"	= strings(PHOBIA_FILE, "authority"),
						"the supernatural"	= strings(PHOBIA_FILE, "the supernatural"),
						"aliens"	= strings(PHOBIA_FILE, "aliens"),
						"strangers"	= strings(PHOBIA_FILE, "strangers"),
						"conspiracies" = strings(PHOBIA_FILE, "conspiracies")
					   )

	phobia_mobs = list("spiders"  = typecacheof(list(/mob/living/simple_animal/hostile/poison/giant_spider)),
					   "security" = typecacheof(list(/mob/living/simple_animal/bot/secbot, /mob/living/simple_animal/bot/ed209)),
					   "lizards"  = typecacheof(list(/mob/living/simple_animal/hostile/lizard)),
					   "skeletons" = typecacheof(list(/mob/living/simple_animal/hostile/skeleton)),
					   "snakes"   = typecacheof(list(/mob/living/simple_animal/hostile/retaliate/poison/snake)),
					   "robots"   = typecacheof(list(/mob/living/silicon/robot, /mob/living/silicon/ai,
					   /mob/living/simple_animal/drone, /mob/living/simple_animal/bot, /mob/living/simple_animal/hostile/swarmer)),
					   "doctors"   = typecacheof(list(/mob/living/simple_animal/bot/medbot)),
					   "the supernatural"   = typecacheof(list(/mob/living/simple_animal/hostile/construct,
					   /mob/living/simple_animal/hostile/clockwork, /mob/living/simple_animal/drone/cogscarab,
					   /mob/living/simple_animal/revenant, /mob/living/simple_animal/shade)),
					   "aliens"   = typecacheof(list(/mob/living/carbon/alien, /mob/living/simple_animal/slime)),
					   "conspiracies" = typecacheof(list(/mob/living/simple_animal/bot/secbot, /mob/living/simple_animal/bot/ed209, /mob/living/simple_animal/drone))
					   )

	phobia_objs = list("snakes" = typecacheof(list(/obj/item/rod_of_asclepius)),

						"spiders"   = typecacheof(list(/obj/structure/spider)),

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
												 /obj/machinery/door/airlock/centcom)),
						"robots"   = typecacheof(list(/obj/machinery/computer/upload, /obj/item/aiModule/, /obj/machinery/recharge_station,
						/obj/item/device/aicard, /obj/item/device/deactivated_swarmer, /obj/effect/mob_spawn/swarmer)),

						"doctors"   = typecacheof(list(/obj/item/clothing/under/rank/medical, /obj/item/clothing/under/rank/chemist,
						/obj/item/clothing/under/rank/nursesuit, /obj/item/clothing/under/rank/chief_medical_officer,
						/obj/item/reagent_containers/syringe, /obj/item/reagent_containers/pill/, /obj/item/reagent_containers/hypospray,
						/obj/item/storage/firstaid, /obj/item/storage/pill_bottle, /obj/item/device/healthanalyzer,
						/obj/structure/sign/departments/medbay, /obj/machinery/door/airlock/medical, /obj/machinery/sleeper,
						/obj/machinery/dna_scannernew, /obj/machinery/atmospherics/components/unary/cryo_cell, /obj/item/surgical_drapes,
						/obj/item/retractor, /obj/item/hemostat, /obj/item/cautery, /obj/item/surgicaldrill, /obj/item/scalpel, /obj/item/circular_saw)),

						"authority"   = typecacheof(list(/obj/item/clothing/under/rank/captain,  /obj/item/clothing/under/rank/head_of_personnel,
						/obj/item/clothing/under/rank/head_of_security, /obj/item/clothing/under/rank/research_director,
						/obj/item/clothing/under/rank/chief_medical_officer, /obj/item/clothing/under/rank/chief_engineer,
						/obj/item/clothing/under/rank/centcom_officer, /obj/item/clothing/under/rank/centcom_commander,
						/obj/item/melee/classic_baton/telescopic, /obj/item/card/id/silver, /obj/item/card/id/gold,
						/obj/item/card/id/captains_spare, /obj/item/card/id/centcom, /obj/machinery/door/airlock/command)),

						"the supernatural"  = typecacheof(list(/obj/structure/destructible/cult, /obj/item/tome,
						/obj/item/melee/cultblade, /obj/item/twohanded/required/cult_bastard, /obj/item/restraints/legcuffs/bola/cult,
						/obj/item/clothing/suit/cultrobes, /obj/item/clothing/suit/space/hardsuit/cult,
						/obj/item/clothing/suit/hooded/cultrobes, /obj/item/clothing/head/hooded/cult_hoodie, /obj/effect/rune,
						/obj/item/stack/sheet/runed_metal, /obj/machinery/door/airlock/cult, /obj/singularity/narsie,
						/obj/item/device/soulstone,
						/obj/structure/destructible/clockwork, /obj/item/clockwork, /obj/item/clothing/suit/armor/clockwork,
						/obj/item/clothing/glasses/judicial_visor, /obj/effect/clockwork/sigil/, /obj/item/stack/tile/brass,
						/obj/machinery/door/airlock/clockwork,
						/obj/item/clothing/suit/wizrobe, /obj/item/clothing/head/wizard, /obj/item/spellbook, /obj/item/staff,
						/obj/item/clothing/suit/space/hardsuit/shielded/wizard, /obj/item/clothing/suit/space/hardsuit/wizard,
						/obj/item/gun/magic/staff, /obj/item/gun/magic/wand,
						/obj/item/nullrod, /obj/item/clothing/under/rank/chaplain)),

						"aliens"   = typecacheof(list(/obj/item/clothing/mask/facehugger, /obj/item/organ/body_egg/alien_embryo,
						/obj/structure/alien, /obj/item/toy/toy_xeno,
						/obj/item/clothing/suit/armor/abductor, /obj/item/device/abductor, /obj/item/gun/energy/alien,
						/obj/item/abductor_baton, /obj/item/device/radio/headset/abductor, /obj/item/scalpel/alien, /obj/item/hemostat/alien,
						/obj/item/retractor/alien, /obj/item/circular_saw/alien, /obj/item/surgicaldrill/alien, /obj/item/cautery/alien,
						/obj/item/clothing/head/helmet/abductor, /obj/structure/bed/abductor, /obj/structure/table_frame/abductor,
						/obj/structure/table/abductor, /obj/structure/table/optable/abductor, /obj/structure/closet/abductor, /obj/item/organ/heart/gland,
						/obj/machinery/abductor, /obj/item/crowbar/abductor, /obj/item/screwdriver/abductor, /obj/item/weldingtool/abductor,
						/obj/item/wirecutters/abductor, /obj/item/wrench/abductor, /obj/item/stack/sheet/mineral/abductor))
					   )

	phobia_turfs = list("space" = typecacheof(list(/turf/open/space, /turf/open/floor/holofloor/space, /turf/open/floor/fakespace)),
						"the supernatural" = typecacheof(list(/turf/open/floor/clockwork, /turf/closed/wall/clockwork,
						/turf/open/floor/plasteel/cult, /turf/closed/wall/mineral/cult)),
						"aliens" = typecacheof(list(/turf/open/floor/plating/abductor, /turf/open/floor/plating/abductor2,
						/turf/open/floor/mineral/abductor, /turf/closed/wall/mineral/abductor))
						)

	phobia_species = list("lizards"   = typecacheof(list(/datum/species/lizard)),
						  "skeletons" = typecacheof(list(/datum/species/skeleton, /datum/species/plasmaman)),
						  "conspiracies" = typecacheof(list(/datum/species/abductor, /datum/species/lizard, /datum/species/synth)),
						  "robots"   = typecacheof(list(/datum/species/android)),
						  "the supernatural" = typecacheof(list(/datum/species/golem/clockwork, /datum/species/golem/runic)),
						  "aliens" = typecacheof(list(/datum/species/abductor, /datum/species/jelly, /datum/species/pod,
						  /datum/species/shadow))
						 )

	return ..()

#undef PHOBIA_FILE
