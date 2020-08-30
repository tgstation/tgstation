/obj/machinery/plumbing/medipen_refiller
	name = "Medipen Refiller"
	desc = "A machine that refills used medipens with chemicals."
	icon = 'icons/obj/machines/medipen_refiller.dmi'
	icon_state = "medipen_refiller"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/medipen_refiller
	idle_power_usage = 100
	/// list of medipen subtypes it can refill
	var/list/allowed = list(/obj/item/reagent_containers/hypospray/medipen = /datum/reagent/medicine/epinephrine,
							/obj/item/reagent_containers/hypospray/medipen/regulated = /datum/reagent/medicine/epinephrine,
							/obj/item/reagent_containers/hypospray/medipen/unregulated = /datum/reagent/medicine/epinephrine,
							/obj/item/reagent_containers/hypospray/medipen/atropine = /datum/reagent/medicine/atropine,
							/obj/item/reagent_containers/hypospray/medipen/salbutamol = /datum/reagent/medicine/salbutamol,
							/obj/item/reagent_containers/hypospray/medipen/oxandrolone = /datum/reagent/medicine/oxandrolone,
							/obj/item/reagent_containers/hypospray/medipen/salacid = /datum/reagent/medicine/sal_acid,
							/obj/item/reagent_containers/hypospray/medipen/penacid = /datum/reagent/medicine/pen_acid)
	/// var to prevent glitches in the animation
	var/busy = FALSE
	/// access flags
	req_access = list(ACCESS_CMO) // medipens are especially dangerous and a medipen filler should require CMO approval.

/obj/machinery/plumbing/medipen_refiller/Initialize()
	. = ..()
	RefreshParts()
	AddComponent(/datum/component/plumbing/specific_demand)


/obj/machinery/plumbing/medipen_refiller/RefreshParts()
	var/new_volume = 100
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		new_volume += 100 * B.rating
	if(!reagents)
		create_reagents(new_volume, TRANSPARENT)
	reagents.maximum_volume = new_volume
	return TRUE

/obj/machinery/plumbing/medipen_refiller/proc/togglelock(mob/living/user)
	if(obj_flags & EMAGGED)
		to_chat(user, "<span class='warning'>The interface is broken!</span>")
	else if(allowed(user))
		locked = !locked
		to_chat(user, "<span class='notice'>You [ locked ? "lock" : "unlock"] the medipen refiller's interface.</span>")
		update_icon()
		updateUsrDialog()
		return TRUE
	else
		to_chat(user, "<span class='warning'>Access denied.</span>")
	return FALSE

/obj/machinery/plumbing/medipen_refiller/AltClick(mob/user)
	..()
	if(!user.canUseTopic(src, !issilicon(user)) || !isturf(loc))
		return
	togglelock(user)

///  handles the messages and animation, calls refill to end the animation
/obj/machinery/plumbing/medipen_refiller/attackby(obj/item/I, mob/user, params)
	// handle id swipes
	if(I.GetID())
		togglelock(user)
		return
	// handle generic containers
	if(istype(I, /obj/item/reagent_containers) && I.is_open_container())
		if(busy)
			to_chat(user, "<span class='danger'>The machine is busy.</span>")
			return
		var/obj/item/reagent_containers/RC = I
		var/units = RC.reagents.trans_to(src, RC.amount_per_transfer_from_this, transfered_by = user)
		if(units)
			to_chat(user, "<span class='notice'>You transfer [units] units of the solution to the [name].</span>")
			return
		else
			to_chat(user, "<span class='danger'>The [name] is full.</span>")
			return
	// handle medipens
	if(istype(I, /obj/item/reagent_containers/hypospray/medipen))
		if(busy)
			to_chat(user, "<span class='danger'>The machine is busy.</span>")
			return
		var/obj/item/reagent_containers/hypospray/medipen/P = I
		if(P.reagents?.reagent_list.len)
			to_chat(user, "<span class='notice'>The medipen is already filled.</span>")
			return
		if(!(LAZYFIND(allowed, P.type)))
			to_chat(user, "<span class='danger'>Error! Unknown schematics.</span>")
			return
		if(locked || (obj_flags & EMAGGED))
			if(reagents.total_volume >= 15)
				add_fingerprint(usr)
				busy = TRUE
				if (obj_flags & EMAGGED)
					add_overlay("active_but_evil")
					addtimer(CALLBACK(src, .proc/refill_unregulated, P, user), 5)
				else
					add_overlay("active")
					addtimer(CALLBACK(src, .proc/refill_regulated, P, user), 5)
				qdel(P)
				return
			to_chat(user, "<span class='danger'>There aren't enough reagents to finish this operation.</span>")
		else
			if(reagents.has_reagent(allowed[P.type], 15))
				add_fingerprint(usr)
				busy = TRUE
				add_overlay("active")
				addtimer(CALLBACK(src, .proc/refill_standard, P, user), 5)
				qdel(P)
				return
			to_chat(user, "<span class='danger'>There aren't enough reagents to finish this operation. This medipen refiller can only dispense reagents the receiving medipen's firmware allows.</span>")
		return
	..()

/obj/machinery/plumbing/medipen_refiller/plunger_act(obj/item/plunger/P, mob/living/user, reinforced)
	to_chat(user, "<span class='notice'>You start furiously plunging [name].</span>")
	if(do_after(user, 30, target = src))
		to_chat(user, "<span class='notice'>You finish plunging the [name].</span>")
		reagents.expose(get_turf(src), TOUCH)
		reagents.clear_reagents()

/obj/machinery/plumbing/medipen_refiller/power_change()
	. = ..()
	if(panel_open)
		icon_state = initial(icon_state) + "_open"
	else if(use_power != NO_POWER_USE)
		icon_state = initial(icon_state) + "_on"
	else
		icon_state = initial(icon_state)

/obj/machinery/plumbing/medipen_refiller/wrench_act(mob/living/user, obj/item/I)
	..()
	default_unfasten_wrench(user, I)
	return TRUE

/obj/machinery/plumbing/medipen_refiller/crowbar_act(mob/user, obj/item/I)
	..()
	default_deconstruction_crowbar(I)
	return TRUE

/obj/machinery/plumbing/medipen_refiller/screwdriver_act(mob/living/user, obj/item/I)
    . = ..()
    if(!.)
        return default_deconstruction_screwdriver(user, "medipen_refiller_open", "medipen_refiller", I)

/obj/machinery/plumbing/medipen_refiller/emag_act(mob/living/user)
	if(obj_flags & EMAGGED)
		return
	add_fingerprint(usr)
	to_chat(user, "<span class='notice'>You program the medipen refiller to use arbitrary reagents!</span>")
	obj_flags |= EMAGGED
	locked = FALSE

/// refill procs
/// refills medipen based on standard reagent lists
/obj/machinery/plumbing/medipen_refiller/proc/refill_standard(obj/item/reagent_containers/hypospray/medipen/P, mob/user)
	new P.type(loc)
	reagents.remove_reagent(allowed[P.type], 15)
	refill_finish(user)

/// refills the medipen based on a CMO-authorized list
/obj/machinery/plumbing/medipen_refiller/proc/refill_regulated(obj/item/reagent_containers/hypospray/medipen/P, mob/user)
	P = new /obj/item/reagent_containers/hypospray/medipen/regulated(loc)
	reagents.trans_to(P, 15)
	refill_finish(user)

/// fills the medipen from an emagged refiller
/obj/machinery/plumbing/medipen_refiller/proc/refill_unregulated(obj/item/reagent_containers/hypospray/medipen/P, mob/user)
	P = new /obj/item/reagent_containers/hypospray/medipen/unregulated(loc)
	reagents.trans_to(P, 15)
	playsound(src, "sparks", 50, TRUE)
	refill_finish(user)

/// terminates refilling for all other procs
/obj/machinery/plumbing/medipen_refiller/proc/refill_finish(mob/user)
	cut_overlays()
	busy = FALSE
	to_chat(user, "<span class='notice'>Medipen refilled.</span>")

/// borrowed reaction chamber code to create reagent list
/obj/machinery/plumbing/medipen_refiller/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemReactionChamber", name)
		ui.open()

/obj/machinery/plumbing/medipen_refiller/ui_data(mob/user)
	var/list/data = list()
	var/list/text_reagents = list()
	for(var/A in required_reagents) //make a list where the key is text, because that looks alot better in the ui than a typepath
		var/datum/reagent/R = A
		text_reagents[initial(R.name)] = required_reagents[R]

	data["reagents"] = text_reagents
	data["emptying"] = FALSE
	data["locked"] = locked
	data["siliconUser"] = user.has_unlimited_silicon_privilege
	return data

/obj/machinery/plumbing/medipen_refiller/ui_act(action, params)
	if(..())
		return
	. = TRUE
	switch(action)
		if("lock")
			if(usr.has_unlimited_silicon_privilege)
				if(obj_flags & EMAGGED)
					to_chat(usr, "<span class='warning'>The medipen refiller does not respond to the command!</span>")
				else
					locked = !locked
					update_icon()
					. = TRUE
		if("remove")
			if(locked)
				to_chat(usr, "<span class='warning'>Access denied.</span>")
				return FALSE
			var/reagent = get_chem_id(params["chem"])
			if(reagent)
				required_reagents.Remove(reagent)
		if("add")
			if(locked)
				to_chat(usr, "<span class='warning'>Access denied.</span>")
				return FALSE
			var/input_reagent = get_chem_id(params["chem"])
			if(input_reagent && !required_reagents.Find(input_reagent))
				var/input_amount = text2num(params["amount"])
				if(input_amount)
					required_reagents[input_reagent] = input_amount
