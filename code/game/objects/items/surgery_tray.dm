/**
 * surgery trays
 *
 * a storage object that displays tools in its contents based on tier, overriding the lower tiers in favor of higher ones. can be folded up and carried. click it to draw a random tool
 *
 */


/datum/storage/medicart
	max_total_storage = 30
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_slots = 14

/datum/storage/medicart/New()
	. = ..()
	set_holdable(list(
		/obj/item/blood_filter,
		/obj/item/bonesetter,
		/obj/item/cautery,
		/obj/item/circular_saw,
		/obj/item/clothing/mask/surgical,
		/obj/item/hemostat,
		/obj/item/razor,
		/obj/item/retractor,
		/obj/item/scalpel,
		/obj/item/stack/medical/bone_gel,
		/obj/item/stack/sticky_tape/surgical,
		/obj/item/surgical_drapes,
		/obj/item/surgicaldrill,
	))

/obj/item/surgery_tray
	name = "surgery tray"
	desc = "A Deforest brand medical cart. It is a folding model, meaning the wheels on the bottom can be retracted and the body used as a tray."
	icon = 'icons/obj/medicart.dmi'
	icon_state = "tray"
	w_class = WEIGHT_CLASS_BULKY
	slowdown = 1
	item_flags = SLOWS_WHILE_IN_HAND

	var/tray_toggled = TRUE

	var/obj/item/stack/medical/bone_gel/bone_gel
	var/obj/item/stack/sticky_tape/surgical/surgical_tape
	var/obj/item/blood_filter/blood_filter

	var/obj/item/razor/surgery/razor
	var/obj/item/bonesetter/bonesetter
	var/obj/item/surgical_drapes/surgical_drapes

	var/obj/item/surgicaldrill/surgical_drill
	var/obj/item/cautery/cautery
	var/obj/item/circular_saw/circular_saw
	var/obj/item/hemostat/hemostat
	var/obj/item/retractor/retractor
	var/obj/item/scalpel/scalpel

/obj/item/surgery_tray/deployed
	tray_toggled = FALSE

/obj/item/surgery_tray/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/medicart)
	PopulateContents()
	AddElement(/datum/element/noisy_movement)
	AddElement(/datum/element/drag_pickup)
	set_tray_mode(tray_toggled)
	register_context()

/obj/item/surgery_tray/Destroy(force)
	QDEL_NULL(bone_gel)
	QDEL_NULL(surgical_tape)
	QDEL_NULL(razor)
	QDEL_NULL(blood_filter)
	QDEL_NULL(bonesetter)
	QDEL_NULL(surgical_drapes)
	QDEL_NULL(surgical_drill)
	QDEL_NULL(cautery)
	QDEL_NULL(circular_saw)
	QDEL_NULL(hemostat)
	QDEL_NULL(retractor)
	QDEL_NULL(scalpel)
	return ..()

/obj/item/surgery_tray/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_LMB] = "Take a random tool"
	context[SCREENTIP_CONTEXT_RMB] = "Take a specific tool"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/surgery_tray/update_icon_state()
	. = ..()
	icon_state = tray_toggled ? "tray" : "medicart"

/obj/item/surgery_tray/update_desc()
	. = ..()
	if(tray_toggled)
		desc = "The wheels and bottom storage of this medical cart have been stowed away, \
			leaving a cumbersome tray in it's place."
	else
		desc = "A Deforest brand medical cart. It is a folding model, meaning the wheels on the \
			bottom can be retracted and the body used as a tray."

/obj/item/surgery_tray/examine(mob/living/carbon/human/user)
	. = ..()
	. += tray_toggled ? span_notice("You can click and drag it to yourself to pick it up, then use it in your hand to make it a cart!") : span_notice("You can click and drag it to yourself to turn it into a tray!")

/// Extend this to give the item an appearance when placed in a surgical tray
/obj/item/proc/get_surgery_tool_overlay()
	return null

/obj/item/scalpel
	/// How this looks when placed in a surgical tray
	var/surgical_tray_overlay = "scalpel"

/obj/item/scalpel/get_surgery_tool_overlay()
	return surgical_tray_overlay

/obj/item/scalpel/advanced
	var/surgical_tray_overlay = "scalpel_advanced"

/obj/item/scalpel/advanced/get_surgery_tool_overlay()
	return surgical_tray_overlay

/obj/item/scalpel/alien
	var/surgical_tray_overlay = "scalpel_alien"

/obj/item/scalpel/alien/get_surgery_tool_overlay()
	return surgical_tray_overlay

/obj/item/scalpel/cruel
	var/surgical_tray_overlay = "scalpel_cruel"

/obj/item/scalpel/cruel/get_surgery_tool_overlay()
	return surgical_tray_overlay

/obj/item/retractor
	var/surgical_tray_overlay = "retractor"

/obj/item/retractor/get_surgery_tool_overlay()
	return surgical_tray_overlay

/obj/item/retractor/advanced
	var/surgical_tray_overlay = "retractor_advanced"

/obj/item/retractor/advanced/get_surgery_tool_overlay()
	return surgical_tray_overlay

/obj/item/retractor/alien
	var/surgical_tray_overlay = "retractor_alien"

/obj/item/retractor/alien/get_surgery_tool_overlay()
	return surgical_tray_overlay

/obj/item/retractor/cruel
	var/surgical_tray_overlay = "retractor_cruel"

/obj/item/retractor/cruel/get_surgery_tool_overlay()
	return surgical_tray_overlay

    . = ..()
    // assoc list of all overlays, key = the item generating the overlay, value = the overlay string
    var/list/surgery_overlays = list()
    // assoc list of tool behaviors to list of all items in our contents that match that behavior
    // easy way for us to check if there are any lower quality tools within
    var/list/tools_recorded = list()
    // compile all the overlays from items inside us
    for(var/obj/item/surgery_tool in src)
        // if we are a tool, check for better tools to use instead
        // initial is used for transforming tool memes. use their default behavior
        var/surgery_tool_type = initial(surgery_tool.tool_behaviour)
        if(surgery_tool_type)
            for(var/obj/item/existing_overlay as anything in tools_recorded[surgery_tool_type])
                if(surgery_tool.toolspeed <= existing_overlay.toolspeed)
                    continue
                // the existing tool was worse than us, ditch it
                surgery_overlays -= existing_overlay

            LAZYADDASSOCLIST(tools_recorded, surgery_tool_type, surgery_tool)

        // slots the overlay we get in.
        var/actual_overlay = surgery_tool.get_surgery_tool_overlay()
        if(actual_overlay)
            surgery_overlays[surgery_tool] = actual_overlay

    for(var/surgery_tool in surgery_overlays)
        . |= surgery_overlays[surgery_tool]

/obj/item/proc/get_surgery_tool_overlay()
    return // update on a subtype basis

/obj/item/surgery_tray/proc/PopulateContents()
	if(!blood_filter)
		blood_filter = new(src)
	if(!bonesetter)
		bonesetter = new(src)
	if(!razor)
		razor = new(src)
	if(!cautery)
		cautery = new(src)
	if(!hemostat)
		hemostat = new(src)
	if(!retractor)
		retractor = new(src)
	if(!scalpel)
		scalpel = new(src)
	if(!circular_saw)
		circular_saw = new(src)
	if(!bone_gel)
		bone_gel = new(src)
	if(!surgical_tape)
		surgical_tape = new(src)
	if(!surgical_drapes)
		surgical_drapes = new(src)
	if(!surgical_drill)
		surgical_drill = new(src)
	new obj/item/clothing/mask/surgical(src)

///Sets the surgery tray's deployment state. Silent if user is null.
/obj/item/surgery_tray/proc/set_tray_mode(new_mode, mob/user)
	tray_toggled = new_mode
	density = !tray_toggled

	if(user)
		user.visible_message(span_notice("[user] [tray_toggled ? "retracts" : "extends"] [src]'s wheels."), span_notice("You [tray_toggled ? "retract" : "extend"] [src]'s wheels."))

	if(tray_toggled)
		interaction_flags_item |= INTERACT_ITEM_ATTACK_HAND_PICKUP
		pass_flags |= PASSTABLE
	else
		interaction_flags_item &= ~INTERACT_ITEM_ATTACK_HAND_PICKUP
		pass_flags &= ~PASSTABLE

	update_appearance()

/obj/item/surgery_tray/equipped(mob/user, slot, initial)
	. = ..()
	if(!tray_toggled)
		set_tray_mode(TRUE, user)

/obj/item/surgery_tray/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return
	var/turf/open/placement_turf = get_turf(user)
	if(isgroundlessturf(placement_turf) || isclosedturf(placement_turf))
		balloon_alert(user, "can't deploy!")
		return TRUE
	if(!user.transferItemToLoc(src, placement_turf))
		balloon_alert(user, "tray stuck!")
		return TRUE
	set_tray_mode(FALSE, user)
	return

/obj/item/surgery_tray/attack_hand(mob/living/user)
	if(!user.can_perform_action(src, NEED_HANDS))
		return ..()
	var/obj/item/grabbies = pick(contents)
	if(grabbies)
		atom_storage.remove_single(user, grabbies, drop_location())
		user.put_in_hands(grabbies)
	return TRUE

/obj/item/surgery_tray/morgue
	name = "autopsy tray"
	desc = "A Deforest brand surgery tray, made for use in morgues. It is a folding model, \
		meaning the wheels on the bottom can be extended outwards, making it a cart."

/obj/item/surgery_tray/morgue/PopulateContents()
	cautery = new /obj/item/cautery/cruel(src)
	hemostat = new /obj/item/hemostat/cruel(src)
	retractor = new /obj/item/retractor/cruel(src)
	scalpel = new /obj/item/scalpel/cruel(src)
	return ..()
