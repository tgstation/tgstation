/**
 * Forensics datum
 *
 * Placed onto atoms, and contains:
 * * List of fingerprints on the atom
 * * List of hidden prints (used for admins)
 * * List of blood on the atom
 * * List of clothing fibers on the atom
 */
/datum/forensics
	/// Ref to the parent owning this datum
	var/atom/parent
	/**
	 * List of fingerprints on this atom
	 *
	 * Formatting:
	 * * print = print
	 */
	var/list/fingerprints
	/**
	 * List of hiddenprints on this atom
	 *
	 * Formatting:
	 * * ckey = realname/gloves/ckey
	 */
	var/list/hiddenprints
	/**
	 * List of blood dna on this atom
	 *
	 * Formatting:
	 * * dna = bloodtype
	 */
	var/list/blood_DNA
	/**
	 * List of clothing fibers on this atom
	 *
	 * Formatting:
	 * * fiber = fiber
	 */
	var/list/fibers

/datum/forensics/New(atom/parent, list/fingerprints, list/hiddenprints, list/blood_DNA, list/fibers)
	if(!isatom(parent))
		stack_trace("We tried adding a forensics datum to something that isnt an atom. What the hell are you doing?")
		qdel(src)
		return

	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(clean_act))

	src.parent = parent
	src.fingerprints = fingerprints
	src.hiddenprints = hiddenprints
	src.blood_DNA = blood_DNA
	src.fibers = fibers
	check_blood()

/// Merges the given lists into the preexisting values
/datum/forensics/proc/inherit_new(list/fingerprints, list/hiddenprints, list/blood_DNA, list/fibers) //Use of | and |= being different here is INTENTIONAL.
	if (fingerprints)
		src.fingerprints = LAZY_LISTS_OR(src.fingerprints, fingerprints)
	if (hiddenprints)
		src.hiddenprints = LAZY_LISTS_OR(src.hiddenprints, hiddenprints)
	if (blood_DNA)
		src.blood_DNA = LAZY_LISTS_OR(src.blood_DNA, blood_DNA)
	if (fibers)
		src.fibers = LAZY_LISTS_OR(src.fibers, fibers)
	check_blood()

/datum/forensics/Destroy(force)
	UnregisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT)
	parent = null
	return ..()

/// Empties the fingerprints list
/datum/forensics/proc/wipe_fingerprints()
	fingerprints = null
	return TRUE

/// Empties the blood_DNA list
/datum/forensics/proc/wipe_blood_DNA()
	blood_DNA = null
	return TRUE

/// Empties the fibers list
/datum/forensics/proc/wipe_fibers()
	fibers = null
	return TRUE

/// Handles cleaning up the various forensic types
/datum/forensics/proc/clean_act(datum/source, clean_types)
	SIGNAL_HANDLER

	if(clean_types & CLEAN_TYPE_FINGERPRINTS)
		wipe_fingerprints()
	if(clean_types & CLEAN_TYPE_BLOOD)
		wipe_blood_DNA()
	if(clean_types & CLEAN_TYPE_FIBERS)
		wipe_fibers()

/// Adds the given list into fingerprints
/datum/forensics/proc/add_fingerprint_list(list/fingerprints)
	if(!length(fingerprints))
		return
	LAZYINITLIST(src.fingerprints)
	for(var/fingerprint in fingerprints) //We use an associative list, make sure we don't just merge a non-associative list into ours.
		src.fingerprints[fingerprint] = fingerprint
	return TRUE

/// Adds a single fingerprint
/datum/forensics/proc/add_fingerprint(mob/living/suspect, ignoregloves = FALSE)
	if(!isliving(suspect))
		if(!iseyemob(suspect))
			return
		if(isaicamera(suspect))
			var/mob/eye/camera/ai/ai_camera = suspect
			if(!ai_camera.ai)
				return
			suspect = ai_camera.ai
	add_hiddenprint(suspect)
	if(ishuman(suspect))
		var/mob/living/carbon/human/human_suspect = suspect
		add_fibers(human_suspect)
		var/obj/item/gloves = human_suspect.gloves
		if(gloves) //Check if the gloves (if any) hide fingerprints
			if(!(gloves.body_parts_covered & HANDS) || HAS_TRAIT(gloves, TRAIT_FINGERPRINT_PASSTHROUGH) || HAS_TRAIT(human_suspect, TRAIT_FINGERPRINT_PASSTHROUGH))
				ignoregloves = TRUE
			if(!ignoregloves)
				human_suspect.gloves.add_fingerprint(human_suspect, ignoregloves = TRUE) //ignoregloves = TRUE to avoid infinite loop.
				return
		var/full_print = md5(human_suspect.dna.unique_identity)
		LAZYSET(fingerprints, full_print, full_print)
	return TRUE

/// Adds the given list into fibers
/datum/forensics/proc/add_fiber_list(list/fibers)
	if(!length(fibers))
		return
	LAZYINITLIST(src.fibers)
	for(var/fiber in fibers) //We use an associative list, make sure we don't just merge a non-associative list into ours.
		src.fibers[fiber] = fiber
	return TRUE

#define ITEM_FIBER_MULTIPLIER 1.2
#define NON_ITEM_FIBER_MULTIPLIER 1

/// Adds a single fiber
/datum/forensics/proc/add_fibers(mob/living/carbon/human/suspect)
	var/fibertext
	var/item_multiplier = isitem(parent) ? ITEM_FIBER_MULTIPLIER : NON_ITEM_FIBER_MULTIPLIER
	if(suspect.wear_suit)
		fibertext = "Material from \a [suspect.wear_suit]."
		if(prob(10 * item_multiplier) && !LAZYACCESS(fibers, fibertext))
			LAZYSET(fibers, fibertext, fibertext)
		if(!(suspect.wear_suit.body_parts_covered & CHEST))
			if(suspect.w_uniform)
				fibertext = "Fibers from \a [suspect.w_uniform]."
				if(prob(12 * item_multiplier) && !LAZYACCESS(fibers, fibertext)) //Wearing a suit means less of the uniform exposed.
					LAZYSET(fibers, fibertext, fibertext)
		if(!(suspect.wear_suit.body_parts_covered & HANDS))
			if(suspect.gloves)
				fibertext = "Material from a pair of [suspect.gloves.name]."
				if(prob(20 * item_multiplier) && !LAZYACCESS(fibers, fibertext))
					LAZYSET(fibers, fibertext, fibertext)
	else if(suspect.w_uniform)
		fibertext = "Fibers from \a [suspect.w_uniform]."
		if(prob(15 * item_multiplier) && !LAZYACCESS(fibers, fibertext))
			LAZYSET(fibers, fibertext, fibertext)
		if(suspect.gloves)
			fibertext = "Material from a pair of [suspect.gloves.name]."
			if(prob(20 * item_multiplier) && !LAZYACCESS(fibers, fibertext))
				LAZYSET(fibers, fibertext, fibertext)
	else if(suspect.gloves)
		fibertext = "Material from a pair of [suspect.gloves.name]."
		if(prob(20 * item_multiplier) && !LAZYACCESS(fibers, fibertext))
			LAZYSET(fibers, fibertext, fibertext)
	return TRUE

#undef ITEM_FIBER_MULTIPLIER
#undef NON_ITEM_FIBER_MULTIPLIER

/// Adds the given list into hiddenprints
/datum/forensics/proc/add_hiddenprint_list(list/hiddenprints) //list(ckey = text)
	if(!length(hiddenprints))
		return
	LAZYINITLIST(src.hiddenprints)
	for(var/hidden_print in hiddenprints) //We use an associative list, make sure we don't just merge a non-associative list into ours.
		src.hiddenprints[hidden_print] = hiddenprints[hidden_print]
	return TRUE

/// Adds a single hiddenprint
/datum/forensics/proc/add_hiddenprint(mob/suspect)
	if(!isliving(suspect))
		if(!iseyemob(suspect))
			return
		if(isaicamera(suspect))
			var/mob/eye/camera/ai/ai_camera = suspect
			if(!ai_camera.ai)
				return
			suspect = ai_camera.ai
	if(!suspect.key)
		return
	var/has_gloves = ""
	if(ishuman(suspect))
		var/mob/living/carbon/human/human_suspect = suspect
		if(human_suspect.gloves)
			has_gloves = "(gloves)"
	var/current_time = time_stamp()
	if(!LAZYACCESS(hiddenprints, suspect.key))
		LAZYSET(hiddenprints, suspect.key, "First: \[[current_time]\] \"[suspect.real_name]\"[has_gloves]. Ckey: [suspect.ckey]")
	else
		var/last_stamp_pos = findtext(LAZYACCESS(hiddenprints, suspect.key), "\nLast: ")
		if(last_stamp_pos)
			LAZYSET(hiddenprints, suspect.key, copytext(hiddenprints[suspect.key], 1, last_stamp_pos))
		hiddenprints[suspect.key] += "\nLast: \[[current_time]\] \"[suspect.real_name]\"[has_gloves]. Ckey: [suspect.ckey]" //made sure to be existing by if(!LAZYACCESS);else
	parent.fingerprintslast = suspect.ckey
	return TRUE

/// Adds the given list into blood_DNA
/datum/forensics/proc/add_blood_DNA(list/blood_DNA)
	if(!length(blood_DNA))
		return
	LAZYINITLIST(src.blood_DNA)
	for(var/gene in blood_DNA)
		src.blood_DNA[gene] = blood_DNA[gene]
	check_blood()
	return TRUE

/// Updates the blood displayed on parent
/datum/forensics/proc/check_blood()
	if(!isitem(parent) || isorgan(parent)) // organs don't spawn with blood decals by default
		return
	if(!length(blood_DNA))
		return
	parent.AddElement(/datum/element/decal/blood, _color = get_blood_dna_color(blood_DNA))
