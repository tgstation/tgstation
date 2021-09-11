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
	if(istype(I, /obj/item/paper_bin))
		var/obj/item/paper_bin/bin = I
		if(LAZYLEN(bin.papers))
			if(stored_paper >= max_paper)
				to_chat(user, span_warning("You try to feed \the [bin] into [src]'s paper recycler, but its paper bin is full!"))
				return FALSE
			/// Number of sheets we're adding
			var/num_to_add = 0
			/// Some goober put their manifesto in the paperbin, complain at the user if that's why nothing happened
			var/rejected_sheets = FALSE
			for(var/obj/item/paper/the_paper in bin.papers) // Search for the first blank sheet of paper, then toss it in
				if(the_paper.info != "") // Uh oh, paper has words! 
					rejected_sheets = TRUE
					continue
				if(istype(the_paper, /obj/item/paper/carbon)) // Add both the carbon, and the copy
					var/obj/item/paper/carbon/carbon_paper = the_paper
					if(!carbon_paper.copied && ((max_paper - stored_paper) >= 2)) // See if there's room for both
						num_to_add = 2
				else
					num_to_add = 1
				LAZYREMOVE(bin.papers, the_paper)
				qdel(the_paper)
				stored_paper += num_to_add
				break // All full!
			bin.update_appearance()
			if(!num_to_add)
				if(rejected_sheets)
					to_chat(user, span_warning("The [src]'s paper recycler detects writing on everything in \the [bin], outright refusing to accept anything!"))
				else
					to_chat(user, span_warning("The [src]'s paper recycler refuses \the [bin], flashing some cryptic message about a feed error!"))
			else
				to_chat(user, span_notice("The [src]'s paper recycler pulls in [num_to_add] unit[num_to_add >= 2 ? "s" : ""] of paper from \the [bin]."))
			return TRUE
		else
			to_chat(user, span_warning("\The [bin] is empty."))
			return FALSE
	return FALSE

/obj/item/computer_hardware/printer/mini
	name = "miniprinter"
	desc = "A small printer with paper recycling module."
	power_usage = 50
	icon_state = "printer_mini"
	w_class = WEIGHT_CLASS_TINY
	stored_paper = 5
	max_paper = 15
