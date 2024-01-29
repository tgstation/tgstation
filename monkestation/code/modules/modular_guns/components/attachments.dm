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

/datum/component/weapon_attachments/proc/attach_to(obj/item/attachment/attacher, datum/attachment_handler/slot, tool_requirement)
	attacher.forceMove(parent)
	slot.stored = attacher
	SEND_SIGNAL(parent, COMSIG_ATTACHMENT_ATTACHED, attacher)
	update_attached_overlays()
	attacher.unique_attachment_effects(parent)

/datum/component/weapon_attachments/proc/update_attached_overlays(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER
	var/obj/item/item = parent
	for(var/datum/attachment_handler/listed as anything in (hand_slots + tool_slots))
		if(!listed.stored)
			continue

		var/mutable_appearance/gun_attachment =  mutable_appearance(listed.stored.attachment_icon, listed.stored.attachment_icon_state, item.layer + listed.stored.layer_modifier, offset_spokesman = parent)
		gun_attachment.pixel_x += listed.stored.offset_x
		gun_attachment.pixel_y += listed.stored.offset_y
		overlays += gun_attachment
