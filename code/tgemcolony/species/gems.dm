/datum/species/gem
	name = "Ruby"
	id = "ruby"
	limbs_id = "human"
	sexes = TRUE
	var/height = "small"
	fixed_mut_color = "C22"
	hair_color = "911"
	var/hairstyle = "Afro (Square)"
	species_traits = list(HAIR,LIPS,MUTCOLORS,NOBLOOD,NO_UNDERWEAR) //no mutcolors, and can burn
	inherent_traits = list(TRAIT_ALWAYS_CLEAN,TRAIT_NOHUNGER,TRAIT_RESISTHEAT,TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOFIRE,TRAIT_RADIMMUNE,TRAIT_NODISMEMBER)
	inherent_biotypes = list(MOB_GEM, MOB_HUMANOID)
	default_features = list("mcolor" = "F22", "wings" = "None")
	var/datum/action/weapon = new/datum/action/innate/gem/weapon
	var/datum/action/fusion = new/datum/action/innate/gem/fusion
	var/datum/action/unfuse = new/datum/action/innate/gem/unfuse
	var/datum/action/bubble = new/datum/action/innate/gem/bubble
	var/datum/action/ability1 = null
	var/datum/action/ability2 = null
	var/datum/quirk/quirk = null

/datum/species/gem/spec_life(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return
	if(H.health <= 0)
		H.setCloneLoss(9001) //POOF THEM WHEN CRITTED!

/datum/species/gem/peridot
	name = "Peridot"
	id = "peridot"
	height = "normal"
	fixed_mut_color = "2C2"
	hair_color = "AFA"
	hairstyle = "Afro (Triangle)"
	weapon = new/datum/action/innate/gem/weapon/peridottoolbox
	ability1 = new/datum/action/innate/gem/miningscan

//datum/species/gem/jade
//	name = "Jade"
//	id = "jade"
//	height = "normal"
//	fixed_mut_color = "2C2"
//	hair_color = "AFA"
//	hairstyle = "Ponytail 4"
//	weapon = new/datum/action/innate/gem/weapon/jadedagger

/datum/species/gem/amethyst
	name = "Amethyst"
	id = "amethyst"
	height = "big" //They're Quartz Soldiers.
	fixed_mut_color = "C6C"
	hair_color = "FAF"
	armor = 50
	hairstyle = "Long Hair 3"
	weapon = new/datum/action/innate/gem/weapon/amethystwhip
	quirk = /datum/quirk/voracious

/datum/species/gem/agate
	name = "Agate"
	id = "agate"
	height = "big" //They're Quartz Soldiers.
	fixed_mut_color = "C66"
	hair_color = "FCC"
	armor = 50
	hairstyle = "Updo"
	weapon = new/datum/action/innate/gem/weapon/agatewhip

/datum/species/gem/sapphire
	name = "Sapphire"
	id = "sapphire"
	height = "small"
	fixed_mut_color = "66C"
	hair_color = "CCF"
	hairstyle = "Sapphire Hair"
	weapon = null
	ability1 = new/datum/action/innate/gem/findmob

/datum/species/gem/agate/homeworld
	fixed_mut_color = "66C"
	hair_color = "CCF"

/datum/species/gem/pearl
	name = "Pearl"
	id = "pearl"
	height = "normal"
	fixed_mut_color = "FCF"
	hair_color = "F6C"
	hairstyle = "Spiky 3"
	weapon = new/datum/action/innate/gem/weapon/pearlspear
	ability1 = new/datum/action/innate/gem/store
	ability2 = new/datum/action/innate/gem/withdraw
	quirk = /datum/quirk/musician
	//EATING FOOD IS SO DISGUSTING!
	disliked_food = GROSS | RAW | JUNKFOOD | FRIED | FRUIT | MEAT | VEGETABLES | GRAIN | TOXIC | PINEAPPLE | SUGAR | DAIRY | ALCOHOL

/datum/species/gem/pearl/homeworld
	fixed_mut_color = "6C6"
	hair_color = "CFC"
	hairstyle = "Sapphire Hair"

/datum/species/gem/rosequartz
	name = "Rose Quartz"
	id = "rosequartz" //They're Quartz Soldiers.
	height = "big"
	fixed_mut_color = "FC9"
	hair_color = "F9C"
	hairstyle = "Drill Hair (Extended)"
	weapon = new/datum/action/innate/gem/weapon/roseshield
	ability1 = new/datum/action/innate/gem/healingtears

/datum/species/gem/bismuth
	name = "Bismuth"
	id = "bismuth" //They're Quartz Soldiers.
	height = "big"
	fixed_mut_color = "C6C"
	hair_color = "FFF"
	hairstyle = "Bismuth Hair"
	weapon = new/datum/action/innate/gem/weapon/bismuthpick
	ability1 = new/datum/action/innate/gem/smelt

/mob/living/carbon/human/species/gem
	race = /datum/species/gem

/datum/species/gem/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	C.update_gravity(1,1)
	if(weapon != null)
		weapon.Grant(C)
	fusion.Grant(C)
	unfuse.Grant(C)
	bubble.Grant(C)
	if(ability1 != null)
		ability1.Grant(C)
	if(ability2 != null)
		ability2.Grant(C)
	if(quirk != null)
		new quirk(C)
	C.add_trait(SPECIES_TRAIT)
	C.gender = "female"
	if(ishuman(C))
		var/mob/living/carbon/human/N = C
		N.hair_style = hairstyle
		N.hair_color = hair_color
	sleep(1)
	C.revive(full_heal = TRUE, admin_revive = TRUE)

/datum/species/gem/on_species_loss(mob/living/carbon/C)
	C.remove_trait(SPECIES_TRAIT)
	weapon.Remove(C)
	fusion.Remove(C)
	unfuse.Remove(C)
	if(ability1 != null)
		ability1.Remove(C)
	if(ability2 != null)
		ability2.Remove(C)
	C.resize = 1
	..()