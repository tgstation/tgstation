/// Data we store to clone someone
/datum/experimental_cloning_record
	/// The name of the cloned subject
	var/name
	/// The DNA of the cloned subject
	var/datum/dna/dna
	/// The types of the quirks of the cloned subject
	var/list/quirks
	/// The types of the brain traumas of the cloned subject at time of scanning
	var/list/brain_traumas
	/// The age of the cloned subject
	var/age
	/// The bodytype of the cloned subject
	var/physique
	/// The athletics level of the cloned subject
	var/athletics_level
	/// The TTS voice of the cloned subject
	var/voice
	/// The TTS voice filter of the cloned subject
	var/voice_filter
	/// The height of the cloned subject
	var/height

/// Record data from a human subject
/datum/experimental_cloning_record/proc/create_profile(mob/living/carbon/human/subject)
	name = subject.real_name
	dna = new subject.dna.type()
	subject.dna.copy_dna(dna)
	age = subject.age
	physique = subject.physique
	athletics_level = subject.mind?.get_skill_level(/datum/skill/athletics) || SKILL_LEVEL_NONE
	height = subject.mob_height

	quirks = list()
	for(var/datum/quirk/quirk as anything in subject.quirks)
		LAZYADD(quirks, quirk.type)

	brain_traumas = list()
	for(var/datum/brain_trauma/trauma as anything in subject.get_traumas())
		LAZYADD(brain_traumas, trauma.type)

	voice = subject.voice
	voice_filter = subject.voice_filter

/// Duplicates our data
/datum/experimental_cloning_record/proc/create_copy()
	var/datum/experimental_cloning_record/new_record = new()
	new_record.name = name
	new_record.dna = new dna.type()
	dna.copy_dna(new_record.dna)
	new_record.age = age
	new_record.physique = physique
	new_record.athletics_level = athletics_level
	new_record.quirks = quirks.Copy()
	new_record.brain_traumas = brain_traumas.Copy()
	new_record.voice = voice
	new_record.voice_filter = voice_filter
	return new_record

/// Apply record data to a clone
/datum/experimental_cloning_record/proc/apply_profile(mob/living/carbon/human/subject)
	subject.name = name
	subject.real_name = name
	subject.age = age
	subject.physique = physique
	subject.mind?.set_level(/datum/skill/athletics, athletics_level, silent = TRUE)
	subject.voice = voice
	subject.voice_filter = voice_filter

	dna.copy_dna(subject.dna, COPY_DNA_SE|COPY_DNA_SPECIES)

	for (var/quirk_type as anything in quirks)
		subject.add_quirk(quirk_type, add_unique = FALSE, announce = FALSE)

	for (var/trauma_type as anything in brain_traumas)
		subject.gain_trauma(trauma_type)

	for (var/obj/item/bodypart/limb as anything in subject.bodyparts)
		limb.update_limb(is_creating = TRUE)

	subject.updateappearance(mutcolor_update = TRUE)
	subject.domutcheck()
	subject.regenerate_icons()
