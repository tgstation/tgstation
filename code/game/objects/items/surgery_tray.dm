/**
 * Surgery Trays
 * A storage object that displays tools in its contents based on tier, better tools are more visible.
 * Can be folded up and carried. Click it to draw a random tool.
 *
 */
/obj/item/surgery_tray
	name = "surgery tray"
	desc = "A Deforest brand medical cart. It is a folding model, meaning the wheels on the bottom can be retracted and the body used as a tray."
	icon = 'icons/obj/medicart.dmi'
	icon_state = "tray"
	w_class = WEIGHT_CLASS_BULKY
	slowdown = 1
	item_flags = SLOWS_WHILE_IN_HAND

	/// If true we're currently portable
	var/is_portable = TRUE
	/// List of things that we spawn containing
	var/list/initial_contents = list(
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
	)

/obj/item/surgery_tray/deployed
	is_portable = FALSE

/obj/item/surgery_tray/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/drag_pickup)
	create_storage(storage_type = /datum/storage/surgery_tray)
	populate_contents()
	register_context()
	set_tray_mode(is_portable)

/obj/item/surgery_tray/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_LMB] = "Take a random tool"
	context[SCREENTIP_CONTEXT_RMB] = "Take a specific tool"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/surgery_tray/update_icon_state()
	. = ..()
	icon_state = is_portable ? "tray" : "medicart"

/obj/item/surgery_tray/update_desc()
	. = ..()
	if(is_portable)
		desc = "The wheels and bottom storage of this medical cart have been stowed away, \
			leaving a cumbersome tray in it's place."
	else
		desc = initial(desc)

/obj/item/surgery_tray/examine(mob/living/carbon/human/user)
	. = ..()
	. += is_portable \
		? span_notice("You can click and drag it to yourself to pick it up, then use it in your hand to make it a cart!") \
		: span_notice("You can click and drag it to yourself to turn it into a tray!")

/obj/item/surgery_tray/update_overlays()
	. = ..()
	// assoc list of all overlays, key = the item generating the overlay, value = the overlay string
	var/list/surgery_overlays = list()
	// assoc list of tool behaviors to fastest toolspeed of that type we already have
	// easy way for us to check if there are any lower quality tools within
	var/list/recorded_tool_speeds = list()
	// handle drapes separately so they're always on the bottom
	if (locate(/obj/item/surgical_drapes) in contents)
		. += "drapes"
	// compile all the overlays from items inside us
	for(var/obj/item/surgery_tool in src)
		// the overlay we will use if we want to display this one
		var/actual_overlay = surgery_tool.get_surgery_tool_overlay(tray_extended = !is_portable)
		if (isnull(actual_overlay))
			continue // nothing to see here

		// if we don't have tool behaviour then just record the overlay
		if(!length(surgery_tool.get_all_tool_behaviours()))
			surgery_overlays[surgery_tool] = actual_overlay
			continue

		// if we have at least one tool behaviour, check if we already recorded a faster one
		for (var/surgery_tool_type in surgery_tool.get_all_tool_behaviours())
			var/highest_speed = LAZYACCESS(recorded_tool_speeds, surgery_tool_type) || INFINITY // bigger number = slower
			if(surgery_tool.toolspeed > highest_speed)
				continue
			// the existing tool was worse than us, ditch it
			surgery_overlays -= surgery_tool_type
			LAZYSET(recorded_tool_speeds, surgery_tool_type, surgery_tool.toolspeed)
			surgery_overlays[surgery_tool_type] = actual_overlay

	for(var/surgery_tool in surgery_overlays)
		. |= surgery_overlays[surgery_tool]

///Spawn the things we contain on initialisation
/obj/item/surgery_tray/proc/populate_contents()
	for (var/thing_path in initial_contents)
		new thing_path(src)
	update_appearance(UPDATE_OVERLAYS)

///Sets the surgery tray's deployment state. Silent if user is null.
/obj/item/surgery_tray/proc/set_tray_mode(new_mode, mob/user)
	is_portable = new_mode
	density = !is_portable
	if(user)
		user.visible_message(span_notice("[user] [is_portable ? "retracts" : "extends"] [src]'s wheels."), span_notice("You [is_portable ? "retract" : "extend"] [src]'s wheels."))

	if(is_portable)
		interaction_flags_item |= INTERACT_ITEM_ATTACK_HAND_PICKUP
		pass_flags |= PASSTABLE
		RemoveElement(/datum/element/noisy_movement)
	else
		interaction_flags_item &= ~INTERACT_ITEM_ATTACK_HAND_PICKUP
		pass_flags &= ~PASSTABLE
		AddElement(/datum/element/noisy_movement)

	update_appearance()

/obj/item/surgery_tray/equipped(mob/user, slot, initial)
	. = ..()
	if(!is_portable)
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

/obj/item/surgery_tray/dump_contents()
	var/atom/drop_point = drop_location()
	for(var/atom/movable/tool as anything in contents)
		tool.forceMove(drop_point)

/obj/item/surgery_tray/deconstruct(disassembled = TRUE)
	dump_contents()
	return ..()

/obj/item/surgery_tray/morgue
	name = "autopsy tray"
	desc = "A Deforest brand surgery tray, made for use in morgues. It is a folding model, \
		meaning the wheels on the bottom can be extended outwards, making it a cart."
	initial_contents = list(
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
	)

/datum/storage/surgery_tray
	max_total_storage = 30
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_slots = 14

/datum/storage/surgery_tray/New()
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
