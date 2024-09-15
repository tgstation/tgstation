#define SELF_AID_REMOVE_DELAY 5 SECONDS
#define OTHER_AID_REMOVE_DELAY 2 SECONDS

/obj/item/stack/medical/gauze
	/// The amount of direct hits our limb can take before we fall off.
	var/integrity = 2
	/// If we are splinting a limb, this is the overlay prefix we will use.
	var/splint_prefix = "splint"
	/// If we are bandaging a limb, this is the overlay prefix we will use.
	var/gauze_prefix = "gauze"
	/// If it is at all possible for us to splint a limb.
	var/can_splint = TRUE

/obj/item/bodypart/apply_gauze(obj/item/stack/gauze)
	. = ..()

	owner?.update_bandage_overlays()

/obj/item/stack/medical/gauze/Destroy()
	var/mob/living/carbon/previously_gauzed = gauzed_bodypart?.owner

	. = ..()

	previously_gauzed?.update_bandage_overlays()

/**
 * rip_off() called when someone rips it off
 *
 * It will return the bandage if it's considered pristine
 *
 */
/obj/item/stack/medical/gauze/proc/rip_off()
	if (is_pristine())
		. = new src.type(null, 1)

	qdel(src)

/// Returns either [splint_prefix] or [gauze_prefix] depending on if we are splinting or not. Suffixes it with a digitigrade flag if applicable for the limb.
/obj/item/stack/medical/gauze/proc/get_overlay_prefix()
	var/splinting = is_splinting()

	var/prefix
	if (splinting)
		prefix = splint_prefix
	else
		prefix = gauze_prefix

	var/suffix = gauzed_bodypart.body_zone
	if(gauzed_bodypart.bodyshape & BODYSHAPE_DIGITIGRADE)
		suffix += "_digitigrade"

	return "[prefix]_[suffix]"

/// Returns if we can splint, and if any wound on our bodypart gives a splint overlay.
/obj/item/stack/medical/gauze/proc/is_splinting()
	SHOULD_BE_PURE(TRUE)

	if (!can_splint)
		return FALSE

	for (var/datum/wound/iterated_wound as anything in gauzed_bodypart.wounds)
		if (iterated_wound.wound_flags & SPLINT_OVERLAY)
			return TRUE

	return FALSE

/**
 * is_pristine() called by rip_off()
 *
 * Used to determine whether the bandage can be re-used and won't qdel itself
 *
 */

/obj/item/stack/medical/gauze/proc/is_pristine()
	return (integrity == initial(integrity))

/**
 * get_hit() called when the bandage gets damaged
 *
 * This proc will subtract integrity and delete the bandage with a to_chat message to whoever was bandaged
 *
 */

/obj/item/stack/medical/gauze/proc/get_hit()
	integrity--
	if(integrity <= 0)
		if(gauzed_bodypart.owner)
			to_chat(gauzed_bodypart.owner, span_warning("The [name] on your [gauzed_bodypart.name] tears and falls off!"))
		qdel(src)

/obj/item/stack/medical/gauze/Topic(href, href_list)
	. = ..()
	if(href_list["remove"])
		if(!gauzed_bodypart.owner)
			return
		if(!iscarbon(usr))
			return
		if(!in_range(usr, gauzed_bodypart.owner))
			return
		var/mob/living/carbon/carbon_user = usr
		var/self = (carbon_user == gauzed_bodypart.owner)
		carbon_user.visible_message(span_notice("[carbon_user] begins removing [name] from [self ? "[gauzed_bodypart.owner.p_Their()]" : "[gauzed_bodypart.owner]'s" ] [gauzed_bodypart.name]..."), span_notice("You begin to remove [name] from [self ? "your" : "[gauzed_bodypart.owner]'s"] [gauzed_bodypart.name]..."))
		if(!do_after(carbon_user, (self ? SELF_AID_REMOVE_DELAY : OTHER_AID_REMOVE_DELAY), target = gauzed_bodypart.owner))
			return
		if(QDELETED(src))
			return
		carbon_user.visible_message(span_notice("[carbon_user] removes [name] from [self ? "[gauzed_bodypart.owner.p_Their()]" : "[gauzed_bodypart.owner]'s" ] [gauzed_bodypart.name]."), span_notice("You remove [name] from [self ? "your" : "[gauzed_bodypart.owner]'s" ] [gauzed_bodypart.name]."))
		var/obj/item/gotten = rip_off()
		if(gotten && !carbon_user.put_in_hands(gotten))
			gotten.forceMove(get_turf(carbon_user))

/// Returns the name of ourself when used in a "owner is [usage_prefix] by [name]" examine_more situation/
/obj/item/stack/proc/get_gauze_description()
	return "[name]"

/// Returns the usage prefix of ourself when used in a "owner is [usage_prefix] by [name]" examine_more situation/
/obj/item/stack/proc/get_gauze_usage_prefix()
	return "bandaged"

/obj/item/stack/medical/gauze/get_gauze_usage_prefix()
	if (is_splinting())
		return "fastened"
	else
		return ..()

/// Returns TRUE if we can generate an overlay, false otherwise.
/obj/item/stack/medical/gauze/proc/has_overlay()
	return (!isnull(gauze_prefix) && !isnull(splint_prefix))

/obj/item/stack/medical/gauze/improvised
	splint_prefix = "splint_improv"
