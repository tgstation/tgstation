/obj/item/assembly/control/polarizer
	name = "window polarization remote controller"
	desc = "A small electronic device able to control the polarization status of linked windows remotely."
	/// Whether the connected windows are meant to be polarized or not.
	var/polarizing = FALSE


/obj/item/assembly/control/polarizer/examine(mob/user)
	. = ..()

	. += span_notice("Use it <b>in your hand</b> or with a <b>multitool</b> to change its channel ID.")


/obj/item/assembly/control/polarizer/multitool_act(mob/living/user)
	attack_self(user)


/obj/item/assembly/control/polarizer/attack_self(mob/living/user)
	var/change_id = tgui_input_number(user, "Set [src]'s ID", "Polarization ID", text2num(id), 1000)
	if(!change_id || QDELETED(user) || QDELETED(src) || !usr.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return

	id = "[change_id]"
	balloon_alert(user, "id changed")
	to_chat(user, span_notice("You change the ID to [id]."))


/obj/item/assembly/control/polarizer/activate()
	if(cooldown)
		return

	cooldown = TRUE

	if(!GLOB.polarization_controllers[id])
		addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 1 SECONDS) // Just so they can't spam the button.
		return

	polarizing = !polarizing

	for(var/datum/component/polarization_controller/controller as anything in GLOB.polarization_controllers[id])
		controller.toggle(polarizing)

	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 1 SECONDS)


/obj/machinery/button/polarizer
	device_type = /obj/item/assembly/control/polarizer


/datum/design/polarizer
	name = "Window Polarization Remote Controller"
	id = "polarizer"
	build_type = PROTOLATHE | AWAY_LATHE | AUTOLATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/assembly/control/polarizer
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_CONSTRUCTION + RND_SUBCATEGORY_CONSTRUCTION_ELECTRONICS,
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING
