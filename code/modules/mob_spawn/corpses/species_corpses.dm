
//corpses that only differentiate themselves by representing a species

/obj/effect/mob_spawn/corpse/human/skeleton
	//these are also fished in chasms so it wouldn't hurt giving them an apter name than "mob spawner"
	name = "skeleton"
	mob_species = /datum/species/skeleton

/obj/effect/mob_spawn/corpse/human/skeleton/cerulean
	name = "cerulean skeleton"

/obj/effect/mob_spawn/corpse/human/skeleton/cerulean/special(mob/living/carbon/human/spawned, mob/mob_possessor, apply_prefs)
	. = ..()
	for(var/zone in GLOB.leg_zones)
		spawned.dna.species.bodypart_overrides -= zone
	spawned.dna.features[FEATURE_TAIL_FISH_COLOR] = LIGHT_COLOR_TUNGSTEN
	spawned.dna.features[FEATURE_FRILLS] = /datum/sprite_accessory/frills/aquatic::name
	spawned.dna.species.mutant_organs[/obj/item/organ/tail/fish/cerulean/skeletal] = /datum/sprite_accessory/tails/fish/cerulean/skeleton::name
	spawned.dna.species.mutant_organs[/obj/item/organ/frills] = /datum/sprite_accessory/frills/aquatic::name
	spawned.dna.species.regenerate_organs(spawned, excluded_zones = GLOB.arm_zones)

/obj/effect/mob_spawn/corpse/human/cerulean
	mob_species = /datum/species/human/cerulean

/obj/effect/mob_spawn/corpse/human/cerulean/special(mob/living/carbon/human/spawned, mob/mob_possessor, apply_prefs)
	. = ..()
	spawned.dna.features[FEATURE_FRILLS] = /datum/sprite_accessory/frills/aquatic::name
	spawned.dna.species.mutant_organs[/obj/item/organ/frills] = /datum/sprite_accessory/frills/aquatic::name
	spawned.dna.species.regenerate_organs(spawned, excluded_zones = (GLOB.all_body_zones - BODY_ZONE_HEAD))

/obj/effect/mob_spawn/corpse/human/cerulean/true/special(mob/living/carbon/human/spawned, mob/mob_possessor, apply_prefs)
	. = ..()
	spawned.dna.species.mutantlungs = /obj/item/organ/lungs/fish
	spawned.dna.species.regenerate_organs(spawned, excluded_zones = (GLOB.all_body_zones - BODY_ZONE_CHEST))

/obj/effect/mob_spawn/corpse/human/zombie
	mob_species = /datum/species/zombie

/obj/effect/mob_spawn/corpse/human/monkey
	mob_species = /datum/species/monkey

/obj/effect/mob_spawn/corpse/human/abductor
	name = "abductor"
	mob_name = "alien"
	mob_species = /datum/species/abductor
	outfit = /datum/outfit/abductorcorpse

/datum/outfit/abductorcorpse
	name = "Abductor Corpse"
	uniform = /obj/item/clothing/under/color/grey
	shoes = /obj/item/clothing/shoes/combat
