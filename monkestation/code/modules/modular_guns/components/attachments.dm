/* This is a helper component to use where we can specify an empty list of slots and when interacted with
by an item that can attach seemlessly attaches, split into tool detach and hand detach tool detach takes
GROUP, TOOL, ITEM for reading whereas hand is just GROUP, ITEM. Prioritizes hand slots first
*/


/datum/component/weapon_attachments
	/// list of all the slots we have that can be tool detached
	var/list/tool_slots = list(

	)
	/// list of all the slots we have that can be hand detached
	var/list/hand_slots = list(

	)
	/// only attachments with this type can be sloted into this
	var/attachment_type = GUN_ATTACH_AK

/datum/component/weapon_attachments/Initialize(attachment_type = GUN_ATTACH_AK, hand_slots = list(), tool_slots = list())
	. = ..()
	src.attachment_type = attachment_type
	src.hand_slots = hand_slots
	src.tool_slots = tool_slots

/datum/component/weapon_attachments/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATTACHMENT_ATTACH_ATTEMPT, PROC_REF(attempt_attach))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_attached_overlays))
	RegisterSignal(parent, COMSIG_GUN_TRY_FIRE, PROC_REF(check_can_fire))
	RegisterSignal(parent, COMSIG_ATTACHMENT_STAT_RESET, PROC_REF(apply_per_reset_uniques))
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(check_removal))

/datum/component/weapon_attachments/proc/check_can_fire(obj/item/gun/ballistic/source, mob/living/user, atom/target, flag, params)
	SIGNAL_HANDLER

	for(var/datum/attachment_handler/listed as anything in (hand_slots + tool_slots))
		if(!listed.required_to_fire)
			continue
		if(!listed.stored)
			user.balloon_alert(user, "Missing Essential Attachments!")
			return COMPONENT_CANCEL_GUN_FIRE

/datum/component/weapon_attachments/proc/attempt_attach(obj/item/gun/source, mob/living/user, atom/target, obj/item/attachment/attacher)
	if(attacher.attachment_rail != attachment_type)
		to_chat(user, span_notice("The [attacher] does not fit on the [target]."))
		return

	var/found = FALSE
	for(var/datum/attachment_handler/listed as anything in (hand_slots + tool_slots))
		if((listed.attachment_slot == attacher.attachment_type)  && !listed.stored)
			found = TRUE
			break

	if(!found)
		to_chat(user, span_notice("You can't seem to fit the [attacher] onto the [target]"))
		return


	for(var/datum/attachment_handler/listed as anything in hand_slots)
		if((listed.attachment_slot != attacher.attachment_type) || listed.stored)
			continue
		attach_to(attacher, listed)

	for(var/datum/attachment_handler/listed as anything in tool_slots)
		if((listed.attachment_slot != attacher.attachment_type) || listed.stored)
			continue
		if(!(listed.tool_required in get_surrounding_tools(user)))
			to_chat(user, span_notice("You need a [listed.tool_required] in order to attach [attacher]"))
			continue
		if(!do_after(user, 1.5 SECONDS, parent))
			continue
		attach_to(attacher, listed)

/datum/component/weapon_attachments/proc/attach_to(obj/item/attachment/attacher, datum/attachment_handler/slot)
	attacher.forceMove(parent)
	slot.stored = attacher
	SEND_SIGNAL(parent, COMSIG_ATTACHMENT_ATTACHED, attacher)

	var/obj/item/item = parent
	item.update_appearance()
	attacher.unique_attachment_effects(parent)

/datum/component/weapon_attachments/proc/update_attached_overlays(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER
	var/obj/item/item = parent
	for(var/datum/attachment_handler/listed as anything in (hand_slots + tool_slots))
		if(!listed.stored)
			continue
		if(listed.stored.attachment_flags & ATTACHMENT_COLORABLE && !listed.stored.attachment_color)
			continue
		var/mutable_appearance/gun_attachment =  mutable_appearance(listed.stored.attachment_icon, listed.stored.attachment_icon_state, item.layer + listed.stored.layer_modifier, offset_spokesman = parent)
		gun_attachment.pixel_x += listed.stored.offset_x
		gun_attachment.pixel_y += listed.stored.offset_y
		gun_attachment.color = listed.stored.attachment_color

		overlays += gun_attachment

/datum/component/weapon_attachments/proc/apply_per_reset_uniques(obj/item/gun/source)
	SIGNAL_HANDLER
	for(var/datum/attachment_handler/listed as anything in (hand_slots + tool_slots))
		if(!listed.stored)
			continue
		listed.stored.unique_attachment_effects_per_reset(parent)


/datum/component/weapon_attachments/proc/check_removal(datum/source, obj/item/I, mob/living/user)
	var/list/removeable_attachments = list()
	if(I.tool_behaviour == TOOL_WRENCH)
		for(var/datum/attachment_handler/listed as anything in hand_slots)
			if(!listed.stored)
				continue
			removeable_attachments += listed.stored

	for(var/datum/attachment_handler/listed as anything in tool_slots)
		if(I.tool_behaviour != listed.tool_required)
			continue
		removeable_attachments += listed.stored

	if(!length(removeable_attachments))
		return
	try_removal(removeable_attachments, I, user)

/datum/component/weapon_attachments/proc/try_removal(list/removable, obj/item/I, mob/living/user)
	var/obj/item/item = parent
	var/obj/item/choice = tgui_input_list(user, "Choose an attachment to remove.", item.name, removable)
	if(!choice)
		return
	if(!do_after(user, 1.5 SECONDS, item))
		return

	for(var/datum/attachment_handler/listed as anything in (hand_slots + tool_slots))
		if(!listed.stored)
			continue
		if(choice != listed.stored)
			continue
		listed.stored = null
	choice.forceMove(get_turf(user))
	user.balloon_alert(user, "Successfully removed [choice.name].")

	SEND_SIGNAL(parent, COMSIG_ATTACHMENT_DETACHED, choice)

///this is literally all to handle tools around us for shit


/datum/component/weapon_attachments/proc/get_environment(atom/a, list/blacklist = null, radius_range = 1)
	. = list()

	if(!isturf(a.loc))
		return

	for(var/atom/movable/AM in range(radius_range, a))
		if((AM.flags_1 & HOLOGRAM_1) || (blacklist && (AM.type in blacklist)))
			continue
		. += AM

/datum/component/weapon_attachments/proc/get_surrounding_tools(atom/a, list/blacklist=null)
	. = list()
	for(var/obj/object in get_environment(a, blacklist))
		if(isitem(object))
			var/obj/item/item = object
			if(item.tool_behaviour)
				. += item.tool_behaviour
