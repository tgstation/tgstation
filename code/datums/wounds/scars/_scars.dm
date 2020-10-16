/**
  * scars are cosmetic datums that are assigned to bodyparts once they recover from wounds. Each wound type and severity have their own descriptions for what the scars
  * look like, and then each body part has a list of "specific locations" like your elbow or wrist or wherever the scar can appear, to make it more interesting than "right arm"
  *
  *
  * Arguments:
  * *
  */
/datum/scar
	var/obj/item/bodypart/limb
	var/mob/living/carbon/victim
	/// The severity of the scar, derived from the worst severity a wound was at before it was healed (see: slashes), determines how visible/bold the scar description is
	var/severity
	/// The description of the scar for examining
	var/description
	/// A string detailing the specific part of the bodypart the scar is on, for fluff purposes. See [/datum/scar/proc/generate]
	var/precise_location

	/// These scars are assumed to come from changeling disguises, rather than from persistence or wounds. As such, they are deleted by dropping changeling disguises, and are ignored by persistence
	var/fake=FALSE
	/// How many tiles away someone can see this scar, goes up with severity. Clothes covering this limb will decrease visibility by 1 each, except for the head/face which is a binary "is mask obscuring face" check
	var/visibility = 2
	/// Whether this scar can actually be covered up by clothing
	var/coverable = TRUE
	/// Obviously, scars that describe damaged flesh wouldn't apply to a skeleton (in some cases like bone wounds, there can be different descriptions for skeletons and fleshy humanoids)
	var/biology = BIO_FLESH_BONE
	/// If we're a persistent scar or may become one, we go in this character slot
	var/persistent_character_slot = 0

/datum/scar/Destroy(force, ...)
	if(limb)
		LAZYREMOVE(limb.scars, src)
	if(victim)
		LAZYREMOVE(victim.all_scars, src)
	. = ..()

/**
  * generate() is used to actually fill out the info for a scar, according to the limb and wound it is provided.
  *
  * After creating a scar, call this on it while targeting the scarred bodypart with a given wound to apply the scar.
  *
  * Arguments:
  * * BP- The bodypart being targeted
  * * W- The wound being used to generate the severity and description info
  * * add_to_scars- Should always be TRUE unless you're just storing a scar for later usage, like how cuts want to store a scar for the highest severity of cut, rather than the severity when the wound is fully healed (probably demoted to moderate)
  */
/datum/scar/proc/generate(obj/item/bodypart/BP, datum/wound/W, add_to_scars=TRUE)
	limb = BP
	severity = W.severity
	if(limb.owner)
		victim = limb.owner
		persistent_character_slot = victim.mind?.original_character_slot_index
	if(add_to_scars)
		LAZYADD(limb.scars, src)
		if(victim)
			LAZYADD(victim.all_scars, src)

	biology = victim?.get_biological_state() || BIO_FLESH_BONE

	if(biology == BIO_JUST_BONE)
		description = pick_list(BONE_SCAR_FILE, W.scar_keyword) || "general disfigurement"
	else // no specific support for flesh w/o bone scars since it's not really useful
		description = pick_list(FLESH_SCAR_FILE, W.scar_keyword) || "general disfigurement"

	precise_location = pick_list_replacements(SCAR_LOC_FILE, limb.body_zone)
	switch(W.severity)
		if(WOUND_SEVERITY_MODERATE)
			visibility = 2
		if(WOUND_SEVERITY_SEVERE)
			visibility = 3
		if(WOUND_SEVERITY_CRITICAL)
			visibility = 5
		if(WOUND_SEVERITY_LOSS)
			visibility = 7
			precise_location = "amputation"

/// Used when we finalize a scar from a healing cut
/datum/scar/proc/lazy_attach(obj/item/bodypart/BP, datum/wound/W)
	LAZYADD(BP.scars, src)
	if(BP.owner)
		victim = BP.owner
		LAZYADD(victim.all_scars, src)

/// Used to "load" a persistent scar
/datum/scar/proc/load(obj/item/bodypart/BP, version, description, specific_location, severity=WOUND_SEVERITY_SEVERE, biology=BIO_FLESH_BONE, char_slot)
	if(!BP.is_organic_limb())
		qdel(src)
		return

	limb = BP
	if(limb.owner)
		victim = limb.owner
		if(victim.get_biological_state() != biology)
			qdel(src)
			return
		LAZYADD(victim.all_scars, src)

	src.severity = severity
	src.biology = biology
	persistent_character_slot = char_slot
	LAZYADD(limb.scars, src)

	src.description = description
	precise_location = specific_location
	switch(severity)
		if(WOUND_SEVERITY_MODERATE)
			visibility = 2
		if(WOUND_SEVERITY_SEVERE)
			visibility = 3
		if(WOUND_SEVERITY_CRITICAL)
			visibility = 5
		if(WOUND_SEVERITY_LOSS)
			visibility = 7
	return src

/// What will show up in examine_more() if this scar is visible
/datum/scar/proc/get_examine_description(mob/viewer)
	if(!victim || !is_visible(viewer))
		return

	var/msg = "[victim.p_they(TRUE)] [victim.p_have()] [description] on [victim.p_their()] [precise_location]."
	switch(severity)
		if(WOUND_SEVERITY_MODERATE)
			msg = "<span class='tinynoticeital'>[msg]</span>"
		if(WOUND_SEVERITY_SEVERE)
			msg = "<span class='smallnoticeital'>[msg]</span>"
		if(WOUND_SEVERITY_CRITICAL)
			msg = "<span class='smallnoticeital'><b>[msg]</b></span>"
		if(WOUND_SEVERITY_LOSS)
			msg = "[victim.p_their(TRUE)] [limb.name] [description]." // different format
			msg = "<span class='notice'><i><b>[msg]</b></i></span>"
	return "\t[msg]"

/// Whether a scar can currently be seen by the viewer
/datum/scar/proc/is_visible(mob/viewer)
	if(!victim || !viewer)
		return
	if(get_dist(viewer, victim) > visibility)
		return

	if(!ishuman(victim) || isobserver(viewer) || victim == viewer)
		return TRUE

	var/mob/living/carbon/human/human_victim = victim
	if(istype(limb, /obj/item/bodypart/head))
		if((human_victim.wear_mask && (human_victim.wear_mask.flags_inv & HIDEFACE)) || (human_victim.head && (human_victim.head.flags_inv & HIDEFACE)))
			return FALSE
	else if(limb.scars_covered_by_clothes)
		var/num_covers = LAZYLEN(human_victim.clothingonpart(limb))
		if(num_covers + get_dist(viewer, victim) >= visibility)
			return FALSE

	return TRUE

/// Used to format a scar to save for either persistent scars, or for changeling disguises
/datum/scar/proc/format()
	return "[SCAR_CURRENT_VERSION]|[limb.body_zone]|[description]|[precise_location]|[severity]|[biology]|[persistent_character_slot]"

/// Used to format a scar to save in preferences for persistent scars
/datum/scar/proc/format_amputated(body_zone)
	description = pick_list(FLESH_SCAR_FILE, "dismemberment")
	return "[SCAR_CURRENT_VERSION]|[body_zone]|[description]|amputated|[WOUND_SEVERITY_LOSS]|[BIO_FLESH_BONE]|[persistent_character_slot]"
