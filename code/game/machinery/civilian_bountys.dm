//Pad & Pad Terminal
/obj/machinery/piratepad/civilian
	name = "civilian bounty pad"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "lpad-idle-o"
	idle_state = "lpad-idle-o"
	warmup_state = "lpad-idle"
	sending_state = "lpad-beam"

/obj/machinery/computer/piratepad_control/civilian
	name = "civilian bounty control terminal"
	ui_x = 600
	ui_y = 230
	status_report = "Ready for delivery."
	warmup_time = 100
	sending = FALSE

/obj/machinery/computer/piratepad_control/civilian/Initialize()
	. = ..()
	pad = /obj/machinery/piratepad/civilian

/obj/machinery/computer/piratepad_control/civilian/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(istype(I, /obj/item/card/id))
		var/obj/item/card/id/swiped = I
		if(!swiped.registered_account)
			return
		var/datum/bank_account/pot_acc = swiped.registered_account
		if(pot_acc.civilian_bounty && ((world.time) < pot_acc.bounty_timer + 5 MINUTES))
			return FALSE
		var/datum/bounty/crumbs = random_bounty() //It's a good scene from War Dogs (2016).
		crumbs.reward = (crumbs.reward/ (rand(2,4)))
		to_chat(user, "<span class='notice'>You swipe [swiped], and have a new civilian bounty!</span>")
		if(istype(crumbs, /datum/bounty/item))
			var/datum/bounty/item/slice = crumbs
			to_chat(user, "<span class='bounty'>[crumbs.description]. Quantity = [slice.required_count] . Reward: = [crumbs.reward].</span>")
		if(istype(crumbs, /datum/bounty/reagent))
			var/datum/bounty/reagent/tall_glass = crumbs
			to_chat(user, "<span class='bounty'>[crumbs.description]. Quantity = [tall_glass.required_volume] . Reward: = [crumbs.reward].</span>")
		pot_acc.bounty_timer = world.time

/obj/machinery/computer/piratepad_control/multitool_act(mob/living/user, obj/item/multitool/I)
	. = ..()
	if (istype(I) && istype(I.buffer,/obj/machinery/piratepad/civilian))
		to_chat(user, "<span class='notice'>You link [src] with [I.buffer] in [I] buffer.</span>")
		pad = I.buffer
		return TRUE

/obj/machinery/computer/piratepad_control/civilian/LateInitialize()
	. = ..()
	if(cargo_hold_id)
		for(var/obj/machinery/piratepad/civilian/C in GLOB.machines)
			if(C.cargo_hold_id == cargo_hold_id)
				pad = C
				return
	else
		pad = locate() in range(4,src)

/obj/machinery/computer/piratepad_control/civilian/recalc()
	if(sending)
		return

	status_report = "Predicted value: "
	var/value = 0
	var/datum/export_report/ex = new
	for(var/atom/movable/AM in get_turf(pad))
		if(AM == pad)
			continue
		export_item_and_contents(AM, EXPORT_CARGO, apply_elastic = TRUE, dry_run = TRUE, external_report = ex)
	for(var/datum/export/E in ex.total_amount)
		status_report += E.total_printout(ex,notes = FALSE)
		status_report += " "
		value += ex.total_value[E]
	if(!value)
		status_report += "0"

/obj/machinery/computer/piratepad_control/civilian/send()
	if(!sending)
		return

	var/datum/export_report/ex = new

	for(var/atom/movable/AM in get_turf(pad))
		if(AM == pad)
			continue
		export_item_and_contents(AM, EXPORT_CARGO, apply_elastic = TRUE, delete_unsold = FALSE, external_report = ex)

	status_report = "Sold: "
	var/value = 0
	for(var/datum/export/E in ex.total_amount)
		var/export_text = E.total_printout(ex,notes = FALSE) //Don't want nanotrasen messages, makes no sense here.
		if(!export_text)
			continue

		status_report += export_text
		status_report += " "
		value += ex.total_value[E]

	if(!total_report)
		total_report = ex
	else
		total_report.exported_atoms += ex.exported_atoms
		for(var/datum/export/E in ex.total_amount)
			total_report.total_amount[E] += ex.total_amount[E]
			total_report.total_value[E] += ex.total_value[E]
	points += value
	if(!value)
		status_report += "Nothing"

	pad.visible_message("<span class='notice'>[pad] activates!</span>")
	flick(pad.sending_state,pad)
	pad.icon_state = pad.idle_state
	sending = FALSE
