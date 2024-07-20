/obj/item/pod_equipment
	// the pod we are attached to
	var/obj/vehicle/sealed/space_pod/pod
	// the slot we go in
	var/slot

/obj/item/pod_equipment/examine(mob/user)
	. = ..()
	. += span_notice("This goes into the [slot].")

/obj/item/pod_equipment/Destroy(force)
	. = ..()
	on_detach()
	pod = null

/// Optional, return an actual overlay or an icon state name to show when attached.
/obj/item/pod_equipment/proc/get_overlay()

/obj/item/pod_equipment/proc/on_attach(mob/user)

/obj/item/pod_equipment/proc/on_detach(mob/user)

/obj/item/pod_equipment/proc/create_occupant_actions(mob/occupant, flag = NONE)

//equipment action
/datum/action/vehicle/sealed/spacepod_equipment
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"
	var/datum/callback/callback_on_click

/datum/action/vehicle/sealed/spacepod_equipment/Trigger(trigger_flags)
	. = ..()
	callback_on_click.Invoke(owner)
