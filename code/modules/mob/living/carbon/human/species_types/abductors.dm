/datum/species/abductor
	name = "Abductor"
	id = "abductor"
	say_mod = "gibbers"
	fitted_slots = list(ITEM_SLOT_EYES, ITEM_SLOT_HEAD) //their heads are shaped differently from the baseline human sprites'
	species_traits = list(NOEYESPRITES, NO_UNDERWEAR)
	exotic_bloodtype = "AY" //AYYYYYYY
	inherent_traits = list(TRAIT_VIRUSIMMUNE,TRAIT_CHUNKYFINGERS,TRAIT_NOHUNGER,TRAIT_NOBREATH, TRAIT_PSYCHIC, TRAIT_TELEPATH) //maybe instead of no_hunger give them nutriment pump implants?
	mutanttongue = /obj/item/organ/tongue/abductor
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

/datum/species/abductor/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	var/datum/atom_hud/abductor_hud = GLOB.huds[DATA_HUD_ABDUCTOR]
	abductor_hud.add_hud_to(C)

/datum/species/abductor/on_species_loss(mob/living/carbon/C)
	. = ..()
	var/datum/atom_hud/abductor_hud = GLOB.huds[DATA_HUD_ABDUCTOR]
	abductor_hud.remove_hud_from(C)

//datum/species/abductor/grey //the playable ones
	//name = "Grey"
	//id = "grey"
	//inherent_traits = list(TRAIT_PSYCHIC, TRAIT_TELEPATH)
