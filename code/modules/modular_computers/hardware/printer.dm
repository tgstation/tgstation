/obj/item/computer_hardware/printer
	name = "printer"
	desc = "Computer-integrated printer with paper recycling module."
	power_usage = 100
	icon_state = "printer"
	w_class = WEIGHT_CLASS_NORMAL
	device_type = MC_PRINT
	expansion_hw = TRUE
	var/stored_paper = 20
	var/max_paper = 30

/obj/item/computer_hardware/printer/diagnostics(mob/living/user)
	..()
	to_chat(user, span_notice("Paper level: [stored_paper]/[max_paper]."))

/obj/item/computer_hardware/printer/examine(mob/user)
	. = ..()
	. += span_notice("Paper level: [stored_paper]/[max_paper].")


/obj/item/computer_hardware/printer/proc/print_text(text_to_print, paper_title = "")
	if(!stored_paper)
		return FALSE
	if(!check_functionality())
		return FALSE

	var/obj/item/paper/P = new/obj/item/paper(holder.drop_location())

	// Damaged printer causes the resulting paper to be somewhat harder to read.
	if(damage > damage_malfunction)
		P.info = stars(text_to_print, 100-malfunction_probability)
	else
		P.info = text_to_print
	if(paper_title)
		P.name = paper_title
	P.update_appearance()
	stored_paper--
	P = null
	return TRUE

/obj/item/computer_hardware/printer/try_insert(obj/item/I, mob/living/user = null)
	if(istype(I, /obj/item/paper_bin))
		var/obj/item/paper_bin/bin = I
		var/bin_paper = bin.papers.len
		var/to_insert = min(max_paper, stored_paper + bin_paper)
		var/left_over = bin_paper - max_paper
		if(left_over > 0)
			visible_message(
				span_notice("Paper spills out of the bin as the feed mechanism overloads"),
				span_warning("UWU, the paper jams up your slot and spills out over the ground"), //nobody will ever see this :devilish:
				span_notice("You hear crazy whirring and paper fluttering sounds")
			)
			bin.dump_papers(user.drop_location(), left_over)

		bin.clear_paper()
		stored_paper += to_insert

	if(istype(I, /obj/item/paper))
		if(stored_paper >= max_paper)
			to_chat(user, span_warning("You try to add \the [I] into [src], but its paper bin is full!"))
			return FALSE

		if(user && !user.temporarilyRemoveItemFromInventory(I))
			return FALSE
		to_chat(user, span_notice("You insert \the [I] into [src]'s paper recycler."))
		qdel(I)
		stored_paper++
		return TRUE
	return FALSE

/obj/item/computer_hardware/printer/mini
	name = "miniprinter"
	desc = "A small printer with paper recycling module."
	power_usage = 50
	icon_state = "printer_mini"
	w_class = WEIGHT_CLASS_TINY
	stored_paper = 5
	max_paper = 15
