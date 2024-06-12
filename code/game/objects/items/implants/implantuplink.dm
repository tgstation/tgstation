/obj/item/implant/uplink
	name = "uplink implant"
	desc = "Sneeki breeki."
	icon = 'icons/obj/devices/voice.dmi'
	icon_state = "radio"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	var/starting_tc = 0
	/// The uplink flags of the implant uplink inside, only checked during initialisation so modifying it after initialisation will do nothing
	var/uplink_flag = UPLINK_TRAITORS
	///Reference to the uplink handler, deciding which type of uplink this implant has.
	var/uplink_handler

/obj/item/implant/uplink/Initialize(mapload, uplink_handler)
	. = ..()
	if(!uplink_flag)
		uplink_flag = src.uplink_flag
	src.uplink_handler = uplink_handler
	RegisterSignal(src, COMSIG_COMPONENT_REMOVING, PROC_REF(on_component_removing))

/obj/item/implant/uplink/implant(mob/living/carbon/target, mob/user, silent, force)
	. = ..()
	var/datum/component/uplink/new_uplink = AddComponent(/datum/component/uplink, owner = target?.key, lockable = TRUE, enabled = FALSE, uplink_handler_override = uplink_handler, starting_tc = starting_tc)
	new_uplink.unlock_text = "Your Syndicate Uplink has been cunningly implanted in you, for a small TC fee. Simply trigger the uplink to access it."
	if(!uplink_handler)
		new_uplink.uplink_handler.owner = target.mind
		new_uplink.uplink_handler.assigned_role = target.mind.assigned_role.title
		new_uplink.uplink_handler.assigned_species = target.dna.species.id

/**
 * Proc called when component is removed; ie. uplink component
 *
 * Callback catching if the underlying uplink component has been removed,
 * generally by admin verbs or var editing. Implant does nothing without
 * the component, so delete itself.
 */
/obj/item/implant/uplink/proc/on_component_removing(datum/source, datum/component/component)
	SIGNAL_HANDLER

	if (QDELING(src))
		return

	if(istype(component, /datum/component/uplink))
		qdel(src)

/obj/item/implanter/uplink
	name = "implanter (uplink)"
	imp_type = /obj/item/implant/uplink

/obj/item/implanter/uplink/Initialize(mapload, uplink_handler)
	imp = new imp_type(src, uplink_handler)
	return ..()

/obj/item/implanter/uplink/precharged
	name = "implanter (precharged uplink)"
	imp_type = /obj/item/implant/uplink/precharged

/obj/item/implant/uplink/precharged
	starting_tc = TELECRYSTALS_PRELOADED_IMPLANT

/obj/item/implant/uplink/starting
	starting_tc = TELECRYSTALS_DEFAULT - UPLINK_IMPLANT_TELECRYSTAL_COST
