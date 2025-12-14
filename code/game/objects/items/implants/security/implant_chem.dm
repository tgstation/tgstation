/obj/item/implant/chem
	name = "chem implant"
	desc = "Injects things."
	icon_state = "reagents"
	actions_types = null
	implant_flags = IMPLANT_TYPE_SECURITY
	hud_icon_state = "hud_imp_chem"
	/// All possible injection sizes for the implant shown in the prisoner management console.
	var/list/implant_sizes = list(1, 5, 10)

	implant_info = "Requires filling via syringe while in an implant case. Automatically activates upon implantation. \
		Allows for remote release of reagents directly into implantee's bloodstream."

	implant_lore = "The Robust Corp MJ-420 Remote Chemical Release Implant is a remotely-controlled \
		microcapsule network designed to be filled via syringe while still within an implant case. After implantation, \
		the MJ-420 can be accessed via prisoner management console to release controlled amounts of reagents directly \
		into the implantee's bloodstream, which is useful for controlled release of sedatives, antipsychotics, or, for \
		particularly dangerous prisoners, lethal injections. Upon implantee's death, breaks down and releases all reagents \
		into their bloodstream."

/obj/item/implant/chem/is_shown_on_console(obj/machinery/computer/prisoner/management/console)
	return is_valid_z_level(get_turf(console), get_turf(imp_in))

/obj/item/implant/chem/get_management_console_data()
	var/list/info_shown = ..()
	info_shown["Volume"] = "[reagents.total_volume]u"
	return info_shown

/obj/item/implant/chem/get_management_console_buttons()
	var/list/buttons = ..()
	for(var/i in implant_sizes)
		UNTYPED_LIST_ADD(buttons, list(
			"name" = "Inject [i]u",
			"color" = "good",
			"action_key" = "inject",
			"action_params" = list("amount" = i),
		))
	return buttons

/obj/item/implant/chem/handle_management_console_action(mob/user, list/params, obj/machinery/computer/prisoner/management/console)
	. = ..()
	if(.)
		return

	if(params["implant_action"] == "inject")
		var/amount = text2num(params["amount"])
		if(!(amount in implant_sizes))
			return TRUE

		var/reagents_inside = reagents.get_reagent_log_string()
		activate(amount)
		log_combat(user, imp_in, "injected [amount] units of [reagents_inside]", src)
		return TRUE

/obj/item/implant/chem/Initialize(mapload)
	. = ..()
	create_reagents(50, OPENCONTAINER)

/obj/item/implant/chem/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(.)
		RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/obj/item/implant/chem/removed(mob/target, silent = FALSE, special = FALSE)
	. = ..()
	if(.)
		UnregisterSignal(target, COMSIG_LIVING_DEATH)

/obj/item/implant/chem/proc/on_death(mob/living/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, TYPE_PROC_REF(/obj/item/implant/chem, activate), reagents.total_volume)

/obj/item/implant/chem/activate(cause)
	. = ..()
	if(!cause || !imp_in)
		return
	var/mob/living/carbon/R = imp_in
	var/injectamount = null
	if (cause == "action_button")
		injectamount = reagents.total_volume
	else
		injectamount = cause
	reagents.trans_to(R, injectamount)
	to_chat(R, span_hear("You hear a faint beep."))
	if(!reagents.total_volume)
		to_chat(R, span_hear("You hear a faint click from your chest."))
		qdel(src)


/obj/item/implantcase/chem
	name = "implant case - 'Remote Chemical'"
	desc = "A glass case containing a remote chemical implant."
	imp_type = /obj/item/implant/chem

/obj/item/implantcase/chem/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/reagent_containers/syringe) && imp)
		return NONE
	return tool.interact_with_atom(imp, user, modifiers)
