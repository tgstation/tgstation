/obj/item/mcobject/messaging/storage
	name = "storage component"
	desc = "acts as a one way storage device, only other components can deposit into it"

	icon = 'monkestation/icons/obj/mechcomp.dmi'
	icon_state = "comp_storage"
	base_icon_state = "comp_storage"

	var/total_weight = 0
	var/total_items = 0

	///does this send the amount of items or total weight as its signal?
	var/outputs_items = FALSE

/obj/item/mcobject/messaging/storage/Initialize(mapload)
	. = ..()

	MC_ADD_INPUT("fire", send_signal)
	MC_ADD_CONFIG("Swap Output Signal", swap_signal)

	create_storage(1000, WEIGHT_CLASS_BULKY, 1000, TRUE, storage_type = /datum/storage/component_storage)

/obj/item/mcobject/messaging/storage/multitool_act_secondary(mob/living/user, obj/item/tool)
	var/obj/item/multitool/multitool = tool
	multitool.component_buffer = src
	to_chat(user, span_notice("You save the data in the [multitool.name]'s buffer."))
	return TRUE

/obj/item/mcobject/messaging/storage/proc/swap_signal(mob/user, obj/item/tool)
	outputs_items = !outputs_items
	say("SUCCESS: Will now output [outputs_items ? "Item Count" : "Total Weight"]")
	return TRUE

/obj/item/mcobject/messaging/storage/proc/send_signal(datum/mcmessage/input)
	var/output = total_weight
	if(outputs_items)
		output = total_items
	fire(output)

/obj/item/mcobject/messaging/storage/proc/attempt_insert(obj/item/inserter, obj/item/mcobject/component)
	if(atom_storage.attempt_insert_nonmob(inserter))
		total_weight += inserter.w_class
		total_items++
		say("[inserter.name] recieved from [component.name]")
		return TRUE
	return

//we want to overright this so we can't attempt insertion by normal means
/datum/storage/component_storage/on_attackby(datum/source, obj/item/thing, mob/user, params)
	return COMPONENT_NO_AFTERATTACK


