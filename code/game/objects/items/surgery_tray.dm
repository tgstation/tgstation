
/**
 * Surgery Trays
 * A storage object that displays tools in its contents based on tier, better tools are more visible.
 * Can be folded up and carried. Click it to draw a random tool.
 */
/obj/item/surgery_tray
	name = "surgery tray"
	desc = "A Deforest brand medical cart. It is a folding model, meaning the wheels on the bottom can be retracted and the body used as a tray."
	icon = 'icons/obj/medical/medicart.dmi'
	icon_state = "tray"
	w_class = WEIGHT_CLASS_BULKY
	slowdown = 1
	item_flags = SLOWS_WHILE_IN_HAND
	pass_flags = NONE

	/// If true we're currently portable
	var/is_portable = TRUE

	/// List of contents to populate with in populatecontents()
	var/list/starting_items = list()

/// Fills the tray with items it should contain on creation
/obj/item/surgery_tray/proc/populate_contents()
	for(var/obj in starting_items)
		new obj(src)
	update_appearance(UPDATE_ICON)
	return

/obj/item/surgery_tray/Initialize(mapload, effect_spawner = FALSE)
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
			leaving a cumbersome tray in its place."
	else
		desc = initial(desc)

/obj/item/surgery_tray/examine(mob/living/carbon/human/user)
	. = ..()
	. += is_portable \
		? span_notice("You can click and drag it to yourself to pick it up, then use it in your hand to make it a cart!") \
		: span_notice("You can click and drag it to yourself to turn it into a tray!")
	. += span_notice("The top is <b>screwed</b> on.")

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

///Sets the surgery tray's deployment state. Silent if user is null.
/obj/item/surgery_tray/proc/set_tray_mode(new_mode, mob/user)
	is_portable = new_mode
	density = !is_portable
	if(user)
		user.visible_message(span_notice("[user] [is_portable ? "retracts" : "extends"] [src]'s wheels."), span_notice("You [is_portable ? "retract" : "extend"] [src]'s wheels."))

	if(is_portable)
		interaction_flags_item |= INTERACT_ITEM_ATTACK_HAND_PICKUP
		passtable_on(src, type)
		RemoveElement(/datum/element/noisy_movement)
	else
		interaction_flags_item &= ~INTERACT_ITEM_ATTACK_HAND_PICKUP
		passtable_off(src, type)
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
	if(!length(contents))
		balloon_alert(user, "empty!")
	else
		var/obj/item/grabbies = pick(contents)
		if(atom_storage.remove_single(user, grabbies, drop_location()))
			user.put_in_hands(grabbies)
	return TRUE

/obj/item/surgery_tray/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	tool.play_tool_sound(src)
	to_chat(user, span_notice("You begin taking apart [src]."))
	if(!tool.use_tool(src, user, 1 SECONDS))
		return
	deconstruct(TRUE)
	to_chat(user, span_notice("[src] has been taken apart."))

/obj/item/surgery_tray/dump_contents()
	var/atom/drop_point = drop_location()
	for(var/atom/movable/tool as anything in contents)
		tool.forceMove(drop_point)

/obj/item/surgery_tray/atom_deconstruct(disassembled = TRUE)
	dump_contents()
	new /obj/item/stack/rods(drop_location(), 2)
	new /obj/item/stack/sheet/mineral/silver(drop_location())

/obj/item/surgery_tray/deployed
	is_portable = FALSE

/obj/item/surgery_tray/full
	starting_items = list(
		/obj/item/blood_filter,
		/obj/item/bonesetter,
		/obj/item/cautery,
		/obj/item/circular_saw,
		/obj/item/clothing/mask/surgical,
		/obj/item/hemostat,
		/obj/item/razor/surgery,
		/obj/item/retractor,
		/obj/item/scalpel,
		/obj/item/stack/medical/bone_gel,
		/obj/item/stack/sticky_tape/surgical,
		/obj/item/surgical_drapes,
		/obj/item/surgicaldrill,
	)

/obj/item/surgery_tray/full/deployed
	is_portable = FALSE

/obj/item/surgery_tray/full/morgue
	name = "autopsy tray"
	desc = "A Deforest brand surgery tray, made for use in morgues. It is a folding model, \
		meaning the wheels on the bottom can be extended outwards, making it a cart."
	starting_items = list(
		/obj/item/blood_filter/cruel,
		/obj/item/bonesetter/cruel,
		/obj/item/cautery/cruel,
		/obj/item/circular_saw/cruel,
		/obj/item/clothing/mask/surgical,
		/obj/item/hemostat/cruel,
		/obj/item/razor/surgery,
		/obj/item/retractor/cruel,
		/obj/item/scalpel/cruel,
		/obj/item/stack/medical/bone_gel,
		/obj/item/stack/sticky_tape/surgical,
		/obj/item/surgical_drapes,
		/obj/item/surgicaldrill/cruel,
	)

/obj/item/surgery_tray/full/morgue/deployed
	is_portable = FALSE

/// Surgery tray with advanced tools for debug
/obj/item/surgery_tray/full/advanced
	starting_items = list(
		/obj/item/scalpel/advanced,
		/obj/item/retractor/advanced,
		/obj/item/cautery/advanced,
		/obj/item/surgical_drapes,
		/obj/item/reagent_containers/medigel/sterilizine,
		/obj/item/bonesetter,
		/obj/item/blood_filter,
		/obj/item/stack/medical/bone_gel,
		/obj/item/stack/sticky_tape/surgical,
		/obj/item/clothing/mask/surgical,
	)

/obj/effect/spawner/surgery_tray
	name = "surgery tray spawner"
	icon = 'icons/obj/medical/medicart.dmi'
	icon_state = "tray"
	/// Tray to usually spawn in.
	var/tray_to_spawn = /obj/item/surgery_tray
	/// Toolbox to sometimes replace the above tray with.
	var/rare_toolbox_replacement = /obj/item/storage/toolbox/medical
	/// Chance for replacement
	var/toolbox_chance = 1

/obj/effect/spawner/surgery_tray/Initialize(mapload)
	. = ..()
	if(prob(toolbox_chance))
		new rare_toolbox_replacement(loc)
		return
	new tray_to_spawn(loc, TRUE)

/obj/effect/spawner/surgery_tray/full
	name = "full surgery tray spawner"
	icon_state = "tray"
	tray_to_spawn = /obj/item/surgery_tray/full
	rare_toolbox_replacement = /obj/item/storage/toolbox/medical/full

/obj/effect/spawner/surgery_tray/full/deployed
	name = "full deployed tray spawner"
	icon_state = "medicart"
	tray_to_spawn = /obj/item/surgery_tray/full

/obj/effect/spawner/surgery_tray/full/morgue
	name = "full autopsy tray spawner"
	icon_state = "tray"
	tray_to_spawn = /obj/item/surgery_tray/full/morgue
	rare_toolbox_replacement = /obj/item/storage/toolbox/medical/coroner
	toolbox_chance = 3 // tray is rarer, so toolbox is more common

/obj/effect/spawner/surgery_tray/full/morgue/deployed
	name = "full deployed autopsy tray spawner"
	icon_state = "medicart"
	tray_to_spawn = /obj/item/surgery_tray/full/morgue/deployed
