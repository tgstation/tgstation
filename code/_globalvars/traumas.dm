#define PHOBIA_FILE "phobia.json"

/// Phobia types that can be pulled randomly for brain traumas.
/// Also determines what phobias you can choose as your preference with the quirk.
GLOBAL_LIST_INIT(phobia_types, sort_list(list(
	"aliens",
	"anime",
	"authority",
	"birds",
	"clowns",
	"doctors",
	"falling",
	"greytide",
	"guns",
	"insects",
	"lizards",
	"robots",
	"security",
	"skeletons",
	"snakes",
	"space",
	"spiders",
	"strangers",
	"the supernatural",
)))

GLOBAL_LIST_INIT(phobia_regexes, list(
	"aliens" = construct_phobia_regex("aliens"),
	"anime" = construct_phobia_regex("anime"),
	"authority" = construct_phobia_regex("authority"),
	"birds" = construct_phobia_regex("birds"),
	"clowns" = construct_phobia_regex("clowns"),
	"conspiracies" = construct_phobia_regex("conspiracies"),
	"doctors" = construct_phobia_regex("doctors"),
	"falling" = construct_phobia_regex("falling"),
	"greytide" = construct_phobia_regex("greytide"),
	"guns" = construct_phobia_regex("guns"),
	"insects" = construct_phobia_regex("insects"),
	"lizards" = construct_phobia_regex("lizards"),
	"ocky icky" = construct_phobia_regex("ocky icky"),
	"robots" = construct_phobia_regex("robots"),
	"security" = construct_phobia_regex("security"),
	"skeletons" = construct_phobia_regex("skeletons"),
	"snakes" = construct_phobia_regex("snakes"),
	"space" = construct_phobia_regex("space"),
	"spiders" = construct_phobia_regex("spiders"),
	"strangers" = construct_phobia_regex("strangers"),
	"the supernatural" = construct_phobia_regex("the supernatural"),
))

GLOBAL_LIST_INIT(phobia_mobs, list(
	"spiders" = typecacheof(list(/mob/living/simple_animal/hostile/giant_spider)),
	"security" = typecacheof(list(/mob/living/simple_animal/bot/secbot)),
	"lizards" = typecacheof(list(/mob/living/simple_animal/hostile/lizard)),
	"skeletons" = typecacheof(list(/mob/living/simple_animal/hostile/skeleton)),
	"snakes" = typecacheof(list(/mob/living/simple_animal/hostile/retaliate/snake)),
	"robots" = typecacheof(list(
		/mob/living/silicon/ai,
		/mob/living/silicon/robot,
		/mob/living/simple_animal/bot,
		/mob/living/simple_animal/drone,
		/mob/living/simple_animal/hostile/swarmer,
	)),
	"doctors" = typecacheof(list(/mob/living/simple_animal/bot/medbot)),
	"the supernatural" = typecacheof(list(
		/mob/living/simple_animal/hostile/construct,
		/mob/living/simple_animal/revenant,
		/mob/living/simple_animal/shade,
		/mob/living/simple_animal/hostile/skeleton,
		/mob/living/simple_animal/hostile/retaliate/ghost,
		/mob/living/simple_animal/hostile/imp,
		/mob/dead/observer,
		/mob/living/simple_animal/bot/mulebot/paranormal,
		/mob/living/simple_animal/hostile/retaliate/bat,
		/mob/living/simple_animal/hostile/dark_wizard,
		/mob/living/simple_animal/hostile/faithless,
		/mob/living/simple_animal/hostile/wizard,
		/mob/living/simple_animal/hostile/zombie,
	)),
	"aliens" = typecacheof(list(
		/mob/living/carbon/alien,
		/mob/living/simple_animal/slime,
	)),
	"conspiracies" = typecacheof(list(
		/mob/living/simple_animal/bot/secbot,
		/mob/living/simple_animal/drone,
		/mob/living/simple_animal/pet/penguin,
	)),
	"birds" = typecacheof(list(
		/mob/living/simple_animal/chick,
		/mob/living/simple_animal/chicken,
		/mob/living/simple_animal/parrot,
		/mob/living/simple_animal/pet/penguin,
	)),
	"anime" = typecacheof(list(/mob/living/simple_animal/hostile/guardian)),
	"insects" = typecacheof(list(
		/mob/living/basic/cockroach,
		/mob/living/simple_animal/hostile/bee,
	)),
))

GLOBAL_LIST_INIT(phobia_objs, list(
	"snakes" = typecacheof(list(/obj/item/rod_of_asclepius, /obj/item/toy/plush/snakeplushie)),
	"spiders" = typecacheof(list(/obj/structure/spider)),
	"security" = typecacheof(list(
		/obj/item/clothing/under/rank/security/officer, /obj/item/clothing/under/rank/security/warden,
		/obj/item/clothing/under/rank/security/head_of_security, /obj/item/clothing/under/rank/security/detective,
		/obj/item/melee/baton, /obj/item/gun/energy/taser, /obj/item/restraints/handcuffs,
		/obj/machinery/door/airlock/security, /obj/effect/hallucination/simple/securitron,
		/obj/item/stamp/hos, /obj/item/megaphone/sec, /obj/item/toy/figure/hos, /obj/item/toy/figure/secofficer,
		/obj/structure/statue/silver/sec, /obj/structure/statue/silver/secborg, /obj/structure/statue/gold/hos
	)),

	"clowns" = typecacheof(list(
		/obj/item/clothing/under/rank/civilian/clown, /obj/item/clothing/shoes/clown_shoes,
		/obj/item/clothing/mask/gas/clown_hat, /obj/item/instrument/bikehorn,
		/obj/item/pda/clown, /obj/item/grown/bananapeel, /obj/item/food/cheesiehonkers,
		/obj/item/trash/cheesie, /obj/item/stack/ore/bananium, /obj/item/stack/tile/mineral/bananium,
		/obj/structure/falsewall/bananium, /obj/item/stack/ore/bananium, /obj/machinery/door/airlock/bananium,
		/obj/structure/statue/bananium, /obj/item/toy/crayon/rainbow, /obj/vehicle/sealed/mecha/combat/honker,
		/obj/item/toy/mecha/honk, /obj/item/toy/mecha/darkhonk,
		/obj/structure/mecha_wreckage/honker, /obj/item/megaphone/clown, /obj/item/stamp/clown,
		/obj/item/storage/backpack/clown, /obj/item/storage/backpack/ert/clown, /obj/item/storage/backpack/duffelbag/clown,
		/obj/item/food/pie/cream, /obj/item/pneumatic_cannon/pie, /obj/item/bedsheet/clown, /obj/vehicle/sealed/car/clowncar,
		/obj/item/gun/magic/staff/honk, /obj/item/clothing/suit/chaplainsuit/clownpriest, /obj/item/clothing/head/clownmitre,
		/obj/item/clothing/under/plasmaman/clown
	)),

	"greytide" = (typecacheof(list(/obj/item/clothing/under/color/grey, /obj/item/melee/baton/security/cattleprod,
		/obj/item/spear, /obj/item/toy/figure/assistant,
		/obj/structure/statue/sandstone/assistant)) + typecacheof(list(/obj/item/clothing/mask/gas), ignore_root_path = FALSE, only_root_path = TRUE
		// to match only specific items in this phobia and not subtypes, use an additional typecacheof w/ ignore_root_path set FALSE and only_root_patch set TRUE
	)),

	"lizards" = typecacheof(list(/obj/item/toy/plush/lizard_plushie, /obj/item/food/kebab/tail, /obj/item/organ/tail/lizard,
		/obj/item/reagent_containers/food/drinks/bottle/lizardwine, /obj/item/clothing/head/lizard, /obj/item/clothing/shoes/cowboy/lizard,
	)),

	"skeletons" = typecacheof(list(/obj/item/organ/tongue/bone, /obj/item/clothing/suit/armor/bone, /obj/item/stack/sheet/bone,
		/obj/item/food/meat/slab/human/mutant/skeleton,
		/obj/effect/decal/remains/human,
	)),

	"conspiracies" = typecacheof(list(/obj/item/clothing/under/rank/captain, /obj/item/clothing/under/rank/security/head_of_security,
		/obj/item/clothing/under/rank/engineering/chief_engineer, /obj/item/clothing/under/rank/medical/chief_medical_officer,
		/obj/item/clothing/under/rank/civilian/head_of_personnel, /obj/item/clothing/under/rank/rnd/research_director,
		/obj/item/clothing/under/rank/security/head_of_security/grey, /obj/item/clothing/under/rank/security/head_of_security/alt,
		/obj/item/clothing/under/rank/rnd/research_director/alt, /obj/item/clothing/under/rank/rnd/research_director/turtleneck,
		/obj/item/clothing/under/rank/captain/parade, /obj/item/clothing/under/rank/security/head_of_security/parade, /obj/item/clothing/under/rank/security/head_of_security/parade/female,
		/obj/item/clothing/head/helmet/abductor, /obj/item/clothing/suit/armor/abductor/vest, /obj/item/melee/baton/abductor,
		/obj/item/storage/belt/military/abductor, /obj/item/gun/energy/alien, /obj/item/abductor/silencer,
		/obj/item/abductor/gizmo, /obj/item/clothing/under/rank/centcom/officer,
		/obj/machinery/door/airlock/centcom, /obj/machinery/atmospherics/miner, /obj/item/toy/figure/captain, /obj/item/toy/figure/ce,
		/obj/item/toy/figure/dsquad, /obj/item/toy/figure/hop, /obj/item/toy/figure/hos, /obj/item/toy/figure/rd,
		/obj/item/toy/figure/cmo, /obj/item/stamp/captain, /obj/item/stamp/hop, /obj/item/stamp/hos, /obj/item/stamp/ce,
		/obj/item/stamp/rd, /obj/item/stamp/cmo, /obj/item/stamp/centcom, /obj/item/megaphone/command
	)),

	"robots" = typecacheof(list(/obj/machinery/computer/upload, /obj/item/ai_module, /obj/machinery/recharge_station,
		/obj/item/aicard, /obj/structure/swarmer_beacon, /obj/item/toy/figure/borg, /obj/item/toy/talking/ai,
		/obj/structure/statue/silver/medborg, /obj/structure/statue/silver/secborg, /obj/structure/statue/diamond/ai1,
		/obj/structure/statue/diamond/ai2,
	)),

	"doctors" = typecacheof(list(/obj/item/clothing/under/rank/medical,
		/obj/item/reagent_containers/syringe, /obj/item/reagent_containers/pill/, /obj/item/reagent_containers/hypospray,
		/obj/item/storage/firstaid, /obj/item/storage/pill_bottle, /obj/item/healthanalyzer,
		/obj/structure/sign/departments/medbay, /obj/machinery/door/airlock/medical, /obj/machinery/sleeper, /obj/machinery/stasis,
		/obj/machinery/dna_scannernew, /obj/machinery/atmospherics/components/unary/cryo_cell, /obj/item/surgical_drapes,
		/obj/item/retractor, /obj/item/hemostat, /obj/item/cautery, /obj/item/surgicaldrill, /obj/item/scalpel, /obj/item/circular_saw,
		/obj/item/clothing/suit/bio_suit/plaguedoctorsuit, /obj/item/clothing/head/plaguedoctorhat, /obj/item/clothing/mask/gas/plaguedoctor,
	)),

	"authority" = typecacheof(list(/obj/item/clothing/under/rank/captain,  /obj/item/clothing/under/rank/civilian/head_of_personnel,
		/obj/item/clothing/under/rank/security/head_of_security, /obj/item/clothing/under/rank/rnd/research_director,
		/obj/item/clothing/under/rank/medical/chief_medical_officer, /obj/item/clothing/under/rank/engineering/chief_engineer,
		/obj/item/clothing/under/rank/centcom/officer, /obj/item/clothing/under/rank/centcom/commander,
		/obj/item/melee/baton/telescopic, /obj/item/card/id/advanced/silver, /obj/item/card/id/advanced/gold,
		/obj/item/card/id/advanced/centcom, /obj/machinery/door/airlock/command,
		/obj/item/toy/figure/captain, /obj/item/toy/figure/ce,
		/obj/item/toy/figure/dsquad, /obj/item/toy/figure/hop, /obj/item/toy/figure/hos, /obj/item/toy/figure/rd,
		/obj/item/toy/figure/cmo, /obj/item/stamp/captain, /obj/item/stamp/hop, /obj/item/stamp/hos, /obj/item/stamp/ce,
		/obj/item/stamp/rd, /obj/item/stamp/cmo, /obj/item/stamp/centcom, /obj/item/megaphone/command,
		/obj/structure/statue/gold/hos, /obj/structure/statue/gold/ce, /obj/structure/statue/gold/cmo, /obj/structure/statue/gold/rd,
		/obj/structure/statue/gold/hop, /obj/structure/statue/diamond/captain
	)),

	"the supernatural" = typecacheof(list(/obj/structure/destructible/cult, /obj/item/tome,
		/obj/item/melee/cultblade, /obj/item/cult_bastard, /obj/item/restraints/legcuffs/bola/cult,
		/obj/item/clothing/suit/hooded/cultrobes, /obj/item/clothing/head/hooded/cult_hoodie, /obj/effect/rune,
		/obj/item/stack/sheet/runed_metal, /obj/machinery/door/airlock/cult, /obj/narsie,
		/obj/item/soulstone,
		/obj/item/clothing/suit/wizrobe, /obj/item/clothing/head/wizard, /obj/item/spellbook, /obj/item/staff,
		/obj/item/gun/magic/staff, /obj/item/gun/magic/wand,
		/obj/item/nullrod, /obj/item/clothing/under/rank/civilian/chaplain,
		/obj/item/gun/magic/staff, /obj/item/gun/magic/wand, /obj/item/scrying, /obj/item/necromantic_stone,
		/obj/item/warpwhistle, /obj/item/nullrod, /obj/item/clothing/under/rank/civilian/chaplain,
		/obj/structure/spirit_board, /obj/item/toy/eightball/haunted, /obj/item/storage/toolbox/haunted,
		/obj/item/stack/sheet/hauntium,
	)),

	"aliens" = typecacheof(list(/obj/item/clothing/mask/facehugger, /obj/item/organ/body_egg/alien_embryo,
		/obj/structure/alien, /obj/item/toy/toy_xeno,
		/obj/item/clothing/suit/armor/abductor, /obj/item/abductor, /obj/item/gun/energy/alien,
		/obj/item/melee/baton/abductor, /obj/item/radio/headset/abductor, /obj/item/scalpel/alien, /obj/item/hemostat/alien,
		/obj/item/retractor/alien, /obj/item/circular_saw/alien, /obj/item/surgicaldrill/alien, /obj/item/cautery/alien,
		/obj/item/clothing/head/helmet/abductor, /obj/structure/bed/abductor, /obj/structure/table_frame/abductor,
		/obj/structure/table/abductor, /obj/structure/table/optable/abductor, /obj/structure/closet/abductor, /obj/item/organ/heart/gland,
		/obj/machinery/abductor, /obj/item/crowbar/abductor, /obj/item/screwdriver/abductor, /obj/item/weldingtool/abductor,
		/obj/item/wirecutters/abductor, /obj/item/wrench/abductor, /obj/item/stack/sheet/mineral/abductor, /obj/item/toy/toy_xeno,
		/obj/structure/statue/plasma/xeno
	)),

	"birds" = typecacheof(list(/obj/item/clothing/mask/gas/plaguedoctor, /obj/item/food/cracker,
		/obj/item/clothing/suit/chickensuit, /obj/item/clothing/head/chicken,
		/obj/item/clothing/suit/toggle/owlwings, /obj/item/clothing/under/costume/owl, /obj/item/clothing/mask/gas/owl_mask,
		/obj/item/clothing/under/costume/griffin, /obj/item/clothing/shoes/griffin, /obj/item/clothing/head/griffin,
		/obj/item/clothing/head/helmet/space/freedom, /obj/item/clothing/suit/space/freedom,
	)),

	"anime" = typecacheof(list(/obj/item/clothing/under/costume/schoolgirl, /obj/item/katana, /obj/item/food/sashimi, /obj/item/food/chawanmushi,
		/obj/item/reagent_containers/food/drinks/bottle/sake, /obj/item/throwing_star, /obj/item/clothing/head/kitty/genuine, /obj/item/clothing/suit/space/space_ninja,
		/obj/item/clothing/mask/gas/space_ninja, /obj/item/clothing/shoes/space_ninja, /obj/item/clothing/gloves/space_ninja, /obj/item/highfrequencyblade,
		/obj/item/nullrod/scythe/vibro, /obj/item/energy_katana, /obj/item/toy/katana, /obj/item/nullrod/claymore/katana, /obj/structure/window/paperframe, /obj/structure/mineral_door/paperframe)),

	"birds" = typecacheof(list(/obj/item/clothing/mask/gas/plaguedoctor, /obj/item/food/cracker,
		/obj/item/clothing/suit/chickensuit, /obj/item/clothing/head/chicken,
		/obj/item/clothing/suit/toggle/owlwings, /obj/item/clothing/under/costume/owl, /obj/item/clothing/mask/gas/owl_mask,
		/obj/item/clothing/under/costume/griffin, /obj/item/clothing/shoes/griffin, /obj/item/clothing/head/griffin,
		/obj/item/clothing/head/helmet/space/freedom, /obj/item/clothing/suit/space/freedom
	)),

	"guns" = typecacheof(list(/obj/item/gun/ballistic, /obj/item/gun/energy, /obj/item/gun/syringe, /obj/item/gun/chem,
		/obj/item/gun/blastcannon, /obj/item/gun/grenadelauncher, /obj/machinery/porta_turret, /obj/machinery/power/emitter,
		/obj/item/ammo_casing, /obj/item/storage/belt/bandolier, /obj/item/storage/belt/holster, /obj/item/ammo_box,
		/obj/item/mecha_ammo, /obj/item/mecha_parts/mecha_equipment/weapon/ballistic, /obj/item/mecha_parts/mecha_equipment/weapon/energy
	)),

	"insects" = typecacheof(list(/obj/item/toy/plush/moth, /obj/item/toy/plush/beeplushie, /obj/item/clothing/mask/animal/rat/bee, /obj/item/clothing/suit/hooded/bee_costume, /obj/structure/beebox)),

	"anime" = typecacheof(list(/obj/item/clothing/under/costume/schoolgirl, /obj/item/katana, /obj/item/food/sashimi, /obj/item/food/chawanmushi,
		/obj/item/reagent_containers/food/drinks/bottle/sake, /obj/item/throwing_star, /obj/item/clothing/head/kitty/genuine, /obj/item/clothing/suit/space/space_ninja,
		/obj/item/clothing/mask/gas/space_ninja, /obj/item/clothing/shoes/space_ninja, /obj/item/clothing/gloves/space_ninja, /obj/item/highfrequencyblade,
		/obj/item/nullrod/scythe/vibro, /obj/item/energy_katana, /obj/item/toy/katana, /obj/item/nullrod/claymore/katana, /obj/structure/window/paperframe, /obj/structure/mineral_door/paperframe
	)),
))

GLOBAL_LIST_INIT(phobia_turfs, list(
	"space" = typecacheof(list(/turf/open/space, /turf/open/floor/holofloor/space, /turf/open/floor/fakespace)),
	"the supernatural" = typecacheof(list(/turf/open/floor/cult, /turf/closed/wall/mineral/cult)),
	"aliens" = typecacheof(list(/turf/open/floor/plating/abductor, /turf/open/floor/plating/abductor2,
		/turf/open/floor/mineral/abductor, /turf/closed/wall/mineral/abductor
	)),
	"falling" = typecacheof(list(/turf/open/chasm, /turf/open/floor/fakepit, /turf/open/openspace)),
))

GLOBAL_LIST_INIT(phobia_species, list(
	"aliens" = typecacheof(list(/datum/species/abductor, /datum/species/jelly, /datum/species/pod,/datum/species/shadow)),
	"anime" = typecacheof(list(/datum/species/human/felinid)),
	"conspiracies" = typecacheof(list(/datum/species/abductor, /datum/species/lizard, /datum/species/synth)),
	"insects" = typecacheof(list(/datum/species/fly, /datum/species/moth)),
	"lizards" = typecacheof(list(/datum/species/lizard)),
	"robots" = typecacheof(list(/datum/species/android)),
	"skeletons" = typecacheof(list(/datum/species/skeleton, /datum/species/plasmaman)),
	"the supernatural" = typecacheof(list(/datum/species/golem/runic)),
))

/// Creates a regular expression to match against the given phobia
/// Capture group 2 = the scary word
/// Capture group 3 = an optional suffix on the scary word
/proc/construct_phobia_regex(list/name)
	var/list/words = strings(PHOBIA_FILE, name)
	if(!length(words))
		CRASH("phobia [name] has no entries")
	var/words_match = ""
	for(var/word in words)
		words_match += "[REGEX_QUOTE(word)]|"
	words_match = copytext(words_match, 1, -1)
	return regex("(\\b|\\A)([words_match])('?s*)(\\b|\\|)", "ig")

#undef PHOBIA_FILE
