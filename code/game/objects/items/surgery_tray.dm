/**
 * surgery trays
 *
 * a storage object that displays tools in its contents, and can be folded up and carried. click it to draw a random tool
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
	var/tray_mode = TRUE
	item_flags = SLOWS_WHILE_IN_HAND

/obj/item/surgery_tray/deployed
	tray_mode = FALSE

/obj/item/surgery_tray/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/medicart)
	PopulateContents()
	AddComponent(/datum/component/surgical_tool_overlay)
	set_tray_mode(tray_mode)
	update_appearance(UPDATE_OVERLAYS | UPDATE_ICON_STATE | UPDATE_DESC)
	AddElement(/datum/element/noisy_movement)
	AddElement(/datum/element/drag_pickup)
	register_context()

/obj/item/surgery_tray/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_LMB] = "Fumble with tools"
	context[SCREENTIP_CONTEXT_RMB] = "Remove a specific tool"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/surgery_tray/update_icon_state()
	. = ..()
	icon_state = tray_mode ? "tray" : "medicart"

/obj/item/surgery_tray/update_desc()
	. = ..()
	desc = tray_mode ? "The wheels and bottom storage of this medical cart have been stowed away, leaving a cumbersome tray in it's place." : "A Deforest brand medical cart. It is a folding model, meaning the wheels on the bottom can be retracted and the body used as a tray."


/obj/item/surgery_tray/proc/PopulateContents()
	var/static/list/items_inside = list(
		/obj/item/blood_filter = 1,
		/obj/item/bonesetter = 1,
		/obj/item/cautery = 1,
		/obj/item/circular_saw = 1,
		/obj/item/clothing/mask/surgical = 1,
		/obj/item/hemostat = 1,
		/obj/item/razor/surgery = 1,
		/obj/item/retractor = 1,
		/obj/item/scalpel = 1,
		/obj/item/stack/medical/bone_gel = 1,
		/obj/item/stack/sticky_tape/surgical = 1,
		/obj/item/surgical_drapes = 1,
		/obj/item/surgicaldrill = 1,
	)
	generate_items_inside(items_inside, src)

///Sets the surgery tray's deployment state. Silent if user is null.
/obj/item/surgery_tray/proc/set_tray_mode(new_mode, mob/user)
	tray_mode = new_mode
	density = !tray_mode

	if(user)
		user.visible_message(span_notice("[user] [tray_mode ? "retracts" : "extends"] [src]'s wheels."), span_notice("You [tray_mode ? "retract" : "extend"] [src]'s wheels."))

	if(tray_mode)
		interaction_flags_item |= INTERACT_ITEM_ATTACK_HAND_PICKUP
		pass_flags |= PASSTABLE
	else
		interaction_flags_item &= ~INTERACT_ITEM_ATTACK_HAND_PICKUP
		pass_flags &= ~PASSTABLE
	SEND_SIGNAL(src, COMSIG_SURGERY_TRAY_TOGGLE, tray_mode)
	update_appearance(UPDATE_OVERLAYS | UPDATE_ICON_STATE | UPDATE_DESC)

/obj/item/surgery_tray/equipped(mob/user, slot, initial)
	. = ..()
	if(!tray_mode)
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
	desc = "A Deforest brand surgery tray, made for use in morgues. It is a folding model, meaning the wheels on the bottom can be extended outwards, making it a cart."

/obj/item/surgery_tray/morgue/PopulateContents()
	var/static/list/items_inside = list(
		/obj/item/blood_filter = 1,
		/obj/item/bonesetter = 1,
		/obj/item/cautery/cruel = 1,
		/obj/item/circular_saw = 1,
		/obj/item/clothing/mask/surgical = 1,
		/obj/item/hemostat/cruel = 1,
		/obj/item/razor/surgery = 1,
		/obj/item/retractor/cruel = 1,
		/obj/item/scalpel/cruel = 1,
		/obj/item/surgical_drapes = 1,
		/obj/item/surgicaldrill = 1,
	)
	generate_items_inside(items_inside, src)
