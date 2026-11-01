/// Vibelin's faiths, patrons and cultures (Vanderlin's code/datums/gods and code/datums/culture), the data ported by
/// tools/port_vibelin.py into heritage/ported/. A character on a medieval map believes in a faith, worships one of its
/// patrons and comes from a culture; the patron's traits come with it. Prayers, devotion and miracles live in faith/.
/// The Russian of every name and text is in localization/strings/chargen.txt.

#define ROGUE_PATRON_TRAIT "rogue_patron"

/datum/faith
	var/name
	var/desc
	/// The patron a believer gets when they pick none.
	var/datum/patron/godhead

/datum/patron
	var/name
	/// The name in the preferences, when it differs.
	var/display_name
	var/domain
	var/desc
	var/worshippers
	var/flaws
	var/sins
	var/boons
	var/drawbacks
	var/prayer_fail
	var/datum/faith/associated_faith
	/// Species ids that may worship it; empty is anyone.
	var/list/allowed_races
	/// Traits worshippers have (Vibelin's added_traits this build has).
	var/list/rogue_traits
	/// What its worshippers cry under torture (faith/confession.dm reads it).
	var/list/confess_lines
	/// Exists but is never picked in the preferences (Vibelin's preference_accessible() returning FALSE).
	var/rogue_hidden = FALSE

/datum/culture
	var/name
	var/description
	/// Put before the name in "from [pre_append][name]".
	var/pre_append = ""
	/// Species ids it belongs to; empty is a culture anyone may have.
	var/list/species

/// Instances by type, of the types with a name (the others are Vibelin's abstract parents).
GLOBAL_LIST_INIT(rogue_faiths, rogue_heritage_instances(/datum/faith))
GLOBAL_LIST_INIT(rogue_patrons, rogue_heritage_instances(/datum/patron))
GLOBAL_LIST_INIT(rogue_cultures, rogue_heritage_instances(/datum/culture))

/// Species ids here that stand for one of Vibelin's races in its heritage data (a patron's allowed_races, a culture's
/// species): Ratwood's dark elf and orc for Vibelin's dark elf and half-orc, Vibelin's humen (vib_human) for "human".
GLOBAL_LIST_INIT(rogue_heritage_species_aliases, list(
	"rogue_drow" = "vib_drow",
	"rogue_orc" = "vib_halforc",
	"vib_human" = "human",
))

/// The species id the heritage data knows this species by.
/proc/rogue_heritage_species(species_id)
	return GLOB.rogue_heritage_species_aliases[species_id] || species_id

/proc/rogue_heritage_instances(root)
	. = list()
	for(var/path in subtypesof(root))
		var/datum/instance = new path
		if(instance.vars["name"])
			.[path] = instance
		else
			qdel(instance)

/datum/patron/proc/display_title()
	return display_name || name

/datum/patron/proc/preference_accessible(species_id)
	return !rogue_hidden && (!length(allowed_races) || (rogue_heritage_species(species_id) in allowed_races))

/datum/faith/proc/patrons()
	. = list()
	for(var/path in GLOB.rogue_patrons)
		var/datum/patron/patron = GLOB.rogue_patrons[path]
		if(patron.associated_faith == type)
			. += patron

/datum/faith/proc/preference_accessible(species_id)
	for(var/datum/patron/patron as anything in patrons())
		if(patron.preference_accessible(species_id))
			return TRUE
	return FALSE

/datum/culture/proc/is_selectable(species_id)
	return !length(species) || (rogue_heritage_species(species_id) in species)

/datum/culture/proc/examined_string()
	return "[pre_append][name]"

/datum/patron/proc/on_gain(mob/living/pious)
	for(var/trait in rogue_traits)
		ADD_TRAIT(pious, trait, ROGUE_PATRON_TRAIT)

/datum/patron/proc/on_remove(mob/living/pious)
	REMOVE_TRAITS_IN(pious, ROGUE_PATRON_TRAIT)

/mob/living/carbon/human
	var/datum/faith/rogue_faith
	var/datum/patron/rogue_patron
	var/datum/culture/rogue_culture

/mob/living/carbon/human/proc/rogue_set_patron(datum/patron/patron)
	if(rogue_patron == patron)
		return
	rogue_patron?.on_remove(src)
	rogue_patron = patron
	rogue_patron?.on_gain(src)

#undef ROGUE_PATRON_TRAIT
