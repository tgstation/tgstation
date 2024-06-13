/obj/item/organ/internal/cyberimp/arm/item_set
	///A ref for the arm we're taking up. Mostly for the unregister signal upon removal
	var/obj/hand
	//A list of typepaths to create and insert into ourself on init
	var/list/items_to_create = list()
	/// Used to store a list of all items inside, for multi-item implants.
	var/list/items_list = list()// I would use contents, but they shuffle on every activation/deactivation leading to interface inconsistencies.
	/// You can use this var for item path, it would be converted into an item on New().
	var/obj/item/active_item
	/// Sound played when extending
	var/extend_sound = 'sound/mecha/mechmove03.ogg'
	/// Sound played when retracting
	var/retract_sound = 'sound/mecha/mechmove03.ogg'

/obj/item/organ/internal/cyberimp/arm/item_set/Initialize()
	. = ..()
	if(ispath(active_item))
		active_item = new active_item(src)

	for(var/typepath in items_to_create)
		var/atom/new_item = new typepath(src)
		items_list += WEAKREF(new_item)

/obj/item/organ/internal/cyberimp/arm/item_set/Destroy()
	hand = null
	active_item = null
	for(var/datum/weakref/ref in items_list)
		var/obj/item/to_del = ref.resolve()
		if(!to_del)
			continue
		qdel(to_del)
	items_list.Cut()
	return ..()

/obj/item/organ/internal/cyberimp/arm/item_set/update_implants()
	if(QDELETED(active_item))
		return

	if(!check_compatibility())
		Retract()

	owner.visible_message("<span class='notice'>[owner] retracts [active_item] back into [owner.p_their()] [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm.</span>",
		"<span class='notice'>[active_item] snaps back into your [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm.</span>",
		"<span class='hear'>You hear a short mechanical noise.</span>")

	owner.transferItemToLoc(active_item, src, TRUE)
	active_item = null
	playsound(get_turf(owner), 'sound/mecha/mechmove03.ogg', 50, TRUE)

/obj/item/organ/internal/cyberimp/arm/item_set/ui_action_click()
	if((organ_flags & ORGAN_FAILING) || (!active_item && !contents.len))
		to_chat(owner, span_warning("The implant doesn't respond. It seems to be broken..."))
		return

	if(!active_item || (active_item in src))
		active_item = null
		if(contents.len == 1)
			if(!check_compatibility())
				to_chat(owner, span_warning("Your [src] beeps loudly, it seems its not compatible with your current cyberlink!"))
				return
			Extend(contents[1])
		else
			if(!check_compatibility())
				to_chat(owner, span_warning("Your [src] beeps loudly, it seems its not compatible with your current cyberlink!"))
				return
			var/list/choice_list = list()
			for(var/datum/weakref/augment_ref in items_list)
				var/obj/item/augment_item = augment_ref.resolve()
				if(!augment_item)
					items_list -= augment_ref
					continue
				choice_list[augment_item] = image(augment_item)
			var/obj/item/choice = show_radial_menu(owner, owner, choice_list)
			if(owner && owner == usr && owner.stat != DEAD && (src in owner.organs) && !active_item && (choice in contents))
				// This monster sanity check is a nice example of how bad input is.
				Extend(choice)
	else
		Retract()

/obj/item/organ/internal/cyberimp/arm/item_set/on_insert(mob/living/carbon/arm_owner)
	. = ..()
	RegisterSignal(arm_owner, COMSIG_CARBON_POST_ATTACH_LIMB, PROC_REF(on_limb_attached))
	RegisterSignal(arm_owner, COMSIG_KB_MOB_DROPITEM_DOWN, PROC_REF(dropkey)) //We're nodrop, but we'll watch for the drop hotkey anyway and then stow if possible.
	on_limb_attached(arm_owner, arm_owner.hand_bodyparts[zone == BODY_ZONE_R_ARM ? RIGHT_HANDS : LEFT_HANDS])

/obj/item/organ/internal/cyberimp/arm/item_set/on_remove(mob/living/carbon/arm_owner)
	. = ..()
	Retract(arm_owner)
	UnregisterSignal(arm_owner, list(COMSIG_CARBON_POST_ATTACH_LIMB, COMSIG_KB_MOB_DROPITEM_DOWN))
	on_limb_detached(hand)

/obj/item/organ/internal/cyberimp/arm/item_set/proc/on_limb_attached(mob/living/carbon/source, obj/item/bodypart/limb)
	SIGNAL_HANDLER
	if(!limb || QDELETED(limb) || limb.body_zone != zone)
		return
	if(hand)
		on_limb_detached(hand)
	RegisterSignal(limb, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_item_attack_self))
	RegisterSignal(limb, COMSIG_BODYPART_REMOVED, PROC_REF(on_limb_detached))
	hand = limb

/obj/item/organ/internal/cyberimp/arm/item_set/proc/on_limb_detached(obj/item/bodypart/source)
	SIGNAL_HANDLER
	if(source != hand || QDELETED(hand))
		return
	UnregisterSignal(hand, list(COMSIG_ITEM_ATTACK_SELF, COMSIG_BODYPART_REMOVED))
	hand = null

/obj/item/organ/internal/cyberimp/arm/item_set/proc/on_item_attack_self()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(ui_action_click))

/obj/item/organ/internal/cyberimp/arm/item_set/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF || status == ORGAN_ROBOTIC)
		return
	if(prob(15/severity) && owner)
		to_chat(owner, span_warning("The electromagnetic pulse causes [src] to malfunction!"))
		// give the owner an idea about why his implant is glitching
		Retract()

/**
 * Called when the mob uses the "drop item" hotkey
 *
 * Items inside toolset implants have TRAIT_NODROP, but we can still use the drop item hotkey as a
 * quick way to store implant items. In this case, we check to make sure the user has the correct arm
 * selected, and that the item is actually owned by us, and then we'll hand off the rest to Retract()
**/
/obj/item/organ/internal/cyberimp/arm/item_set/proc/dropkey(mob/living/carbon/host)
	SIGNAL_HANDLER
	if(!host)
		return //How did we even get here
	if(hand != host.hand_bodyparts[host.active_hand_index])
		return //wrong hand
	if(Retract())
		return COMSIG_KB_ACTIVATED

/obj/item/organ/internal/cyberimp/arm/item_set/proc/Retract(mob/living/carbon/passover)
	var/mob/living/carbon/user = owner
	if(passover)
		user = passover
	if(!active_item || (active_item in src))
		return FALSE

	user?.visible_message(span_notice("[user] retracts [active_item] back into [user.p_their()] [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm."),
		span_notice("[active_item] snaps back into your [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm."),
		span_hear("You hear a short mechanical noise."))

	user.transferItemToLoc(active_item, src, TRUE)
	UnregisterSignal(active_item, COMSIG_ITEM_ATTACK_SELF)
	active_item = null
	playsound(get_turf(user), retract_sound, 50, TRUE)
	return TRUE

/obj/item/organ/internal/cyberimp/arm/item_set/proc/Extend(obj/item/augment)
	if(!(augment in src))
		return

	active_item = augment

	active_item.resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	ADD_TRAIT(active_item, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	active_item.slot_flags = null
	active_item.set_custom_materials(null)

	var/side = zone == BODY_ZONE_R_ARM? RIGHT_HANDS : LEFT_HANDS
	var/hand = owner.get_empty_held_index_for_side(side)
	if(hand)
		owner.put_in_hand(active_item, hand)
	else
		var/list/hand_items = owner.get_held_items_for_side(side, all = TRUE)
		var/success = FALSE
		var/list/failure_message = list()
		for(var/i in 1 to hand_items.len) //Can't just use *in* here.
			var/hand_item = hand_items[i]
			if(!owner.dropItemToGround(hand_item))
				failure_message += span_warning("Your [hand_item] interferes with [src]!")
				continue
			to_chat(owner, span_notice("You drop [hand_item] to activate [src]!"))
			success = owner.put_in_hand(active_item, owner.get_empty_held_index_for_side(side))
			break
		if(!success)
			for(var/i in failure_message)
				to_chat(owner, i)
			return
	owner.visible_message(span_notice("[owner] extends [active_item] from [owner.p_their()] [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm."),
		span_notice("You extend [active_item] from your [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm."),
		span_hear("You hear a short mechanical noise."))
	playsound(get_turf(owner), extend_sound, 50, TRUE)

	if(length(items_list) > 1)
		RegisterSignals(active_item, list(COMSIG_ITEM_ATTACK_SELF, COMSIG_ITEM_ATTACK_SELF_SECONDARY), PROC_REF(swap_tools)) // secondary for welders

/obj/item/organ/internal/cyberimp/arm/item_set/proc/swap_tools(active_item)
	SIGNAL_HANDLER
	Retract(owner)
	INVOKE_ASYNC(src, PROC_REF(ui_action_click))
