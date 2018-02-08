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
	phobia_types = list("spiders", "space", "security", "clowns", "greytide", "lizards", "skeletons", "snakes", "robots", "doctors", "authority", "the supernatural")

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
						"the supernatural"	= strings(PHOBIA_FILE, "the supernatural")
					   )

	phobia_mobs = list("spiders"  = typecacheof(list(/mob/living/simple_animal/hostile/poison/giant_spider)),
					   "security" = typecacheof(list(/mob/living/simple_animal/bot/secbot)),
					   "lizards"  = typecacheof(list(/mob/living/simple_animal/hostile/lizard)),
					   "snakes"   = typecacheof(list(/mob/living/simple_animal/hostile/retaliate/poison/snake))
					   "robots"   = typecacheof(list(/mob/living/silicon/robot, /mob/living/silicon/AI, 
					   /mob/living/simple_animal/drone, /mob/living/simple_animal/bot/)),
					   "the supernatural"   = typecacheof(list(/mob/living/simple_animal/hostile/construct, 
					   /mob/living/simple_animal/hostile/clockwork/, /mob/living/simple_animal/drone/cogscarab))
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
						"robots"   = typecacheof(list(/obj/machinery/computer/upload, /obj/item/aiModule/, /obj/item/device/aicard)),
						"doctors"   = typecacheof(list(/obj/item/clothing/under/rank/medical, /obj/item/clothing/under/rank/chemist, 
						/obj/item/clothing/under/rank/nursesuit, /obj/item/clothing/under/rank/chief_medical_officer, 
						/obj/item/reagent_containers/syringe, /obj/item/reagent_containers/pill/, /obj/item/reagent_containers/hypospray/, 
						/obj/item/storage/firstaid, /obj/item/storage/pill_bottle, /obj/item/device/healthanalyzer/, 
						/obj/structure/sign/departments/medbay, /obj/machinery/door/airlock/medical, /obj/machinery/sleeper, 
						/obj/machinery/dna_scannernew, /obj/machinery/atmospherics/components/unary/cryo_cell)),
						"authority"   = typecacheof(list(/obj/item/clothing/under/rank/captain,  /obj/item/clothing/under/rank/head_of_personnel, 
						/obj/item/clothing/under/rank/head_of_security, /obj/item/clothing/under/rank/research_director, 
						/obj/item/clothing/under/rank/chief_medical_officer, /obj/item/clothing/under/rank/chief_engineer, 
						/obj/item/clothing/under/rank/centcom_officer, /obj/item/clothing/under/rank/centcom_commander, 
						/obj/item/melee/classic_baton/telescopic, /obj/item/card/id/silver, /obj/item/card/id/gold, 
						/obj/item/card/id/captains_spare, /obj/item/card/id/centcom, /obj/machinery/door/airlock/command)),
						"the supernatural"  = typecacheof(list(/obj/structure/destructible/cult, /obj/item/tome, 
						/obj/item/melee/cultblade/, /obj/item/twohanded/required/cult_bastard, /obj/item/restraints/legcuffs/bola/cult, 
						/obj/item/clothing/suit/cultrobes/, /obj/item/clothing/suit/space/hardsuit/cult, 
						/obj/item/clothing/suit/hooded/cultrobes/, /obj/item/clothing/head/hooded/cult_hoodie, /obj/effect/rune, 
						/turf/open/floor/plasteel/cult, /turf/closed/wall/mineral/cult, /obj/item/stack/sheet/runed_metal, 
						/obj/machinery/door/airlock/cult/, /obj/singularity/narsie, /obj/item/device/soulstone
						/obj/structure/destructible/clockwork/, /obj/item/clockwork/, /obj/item/clothing/suit/armor/clockwork, 
						/obj/item/clothing/glasses/judicial_visor, /obj/effect/clockwork/sigil, /obj/item/stack/tile/brass, 
						/turf/open/floor/clockwork, /turf/closed/wall/clockwork, /obj/machinery/door/airlock/clockwork/,
						/obj/item/clothing/suit/wizrobe, /obj/item/clothing/head/wizard, /obj/item/spellbook, /obj/item/staff, 
						/obj/item/clothing/suit/space/hardsuit/shielded/wizard, /obj/item/clothing/suit/space/hardsuit/wizard,
						/obj/item/gun/magic/staff/, /obj/item/gun/magic/wand/,
						/obj/item/nullrod, /obj/item/clothing/under/rank/chaplain))
					   )
	phobia_turfs = list("space" = typecacheof(list(/turf/open/space, /turf/open/floor/holofloor/space, /turf/open/floor/fakespace)))

	phobia_species = list("lizards"   = typecacheof(list(/datum/species/lizard)),
						  "skeletons" = typecacheof(list(/datum/species/skeleton, /datum/species/plasmaman)),
						  "robots"   = typecacheof(list(/datum/species/android)),
						  "the supernatural" = typecacheof(list(/datum/species/golem/clockwork, /datum/species/golem/runic))
						 )

#undef PHOBIA_FILE
