/datum/quirk/evil
	name = "Fundamentally Evil"
	desc = "Where you would have a soul is but an ink-black void. While you are committed to maintaining your social standing, \
		anyone who stares too long into your cold, uncaring eyes will know the truth. You are truly evil. There is nothing \
		wrong with you. You chose to be evil, committed to it. Your ambitions come first above all."
	icon = FA_ICON_HAND_MIDDLE_FINGER
	value = 0
	mob_trait = TRAIT_EVIL
	gain_text = span_notice("You shed what little remains of your humanity. You have work to do.")
	lose_text = span_notice("You suddenly care more about others and their needs.")
	medical_record_text = "Patient has passed all our social fitness tests with flying colours, but had trouble on the empathy tests."
	mail_goodies = list(/obj/item/food/grown/citrus/lemon)

/datum/quirk/evil/post_add()
	var/evil_policy = get_policy("[type]") || "Please note that while you may be [LOWER_TEXT(name)], this does NOT give you any additional right to attack people or cause chaos."
	// We shouldn't need this, but it prevents people using it as a dumb excuse in ahelps.
	to_chat(quirk_holder, span_big(span_info(evil_policy)))
	RegisterSignal(quirk_holder, COMSIG_SPECIES_GAIN, PROC_REF(make_blood_evil))

/datum/quirk/evil/add(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	if(!istype(human_holder))
		return
	make_blood_evil(new_species = human_holder.dna.species)

/datum/quirk/evil/remove()
	UnregisterSignal(quirk_holder, list(COMSIG_SPECIES_GAIN))

/// Get a dynamically generated blood type based off the mob's old blood type and make it 'evil'. Needs to happen whenever the species changes.
/datum/quirk/evil/proc/make_blood_evil(datum/source, datum/species/new_species, datum/species/old_species, pref_load, regenerate_icons)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/human_holder = quirk_holder
	if(!istype(human_holder))
		return

	// Try to find a corresponding evil blood type for this
	var/datum/blood_type/new_blood_type = get_blood_type("[human_holder.dna.blood_type.id]_but_evil")
	if(isnull(new_blood_type)) // this blood type doesn't exist yet in the global list, so make a new one
		new_blood_type = new /datum/blood_type/evil(human_holder.dna.blood_type, human_holder.dna.blood_type.compatible_types)
		GLOB.blood_types[new_blood_type.id] = new_blood_type
	human_holder.set_blood_type(new_blood_type)

	if(new_species.exotic_bloodtype)
		new_species.exotic_bloodtype = new_blood_type
