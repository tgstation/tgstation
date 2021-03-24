/obj/item/paper_bin
	name = "paper bin"
	desc = "Contains all the paper you'll never need."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_bin0"
	inhand_icon_state = "sheet-metal"
	lefthand_file = 'icons/mob/inhands/misc/sheets_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/sheets_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 3
	throw_range = 7
	pressure_resistance = 8
	var/papertype = /obj/item/paper
	var/total_paper = 30
	var/list/papers = list()
	var/obj/item/pen/bin_pen
	///Overlay of the pen on top of the bin.
	var/mutable_appearance/pen_overlay
	///Name of icon that goes over the paper overlays.
	var/bin_overlay_string = "paper_bin_overlay"
	///Overlay that goes over the paper overlays.
	var/mutable_appearance/bin_overlay

/obj/item/paper_bin/Initialize(mapload)
	. = ..()
	interaction_flags_item &= ~INTERACT_ITEM_ATTACK_HAND_PICKUP
	AddElement(/datum/element/drag_pickup)
	if(mapload)
		var/obj/item/pen/P = locate(/obj/item/pen) in src.loc
		if(P && !bin_pen)
			P.forceMove(src)
			bin_pen = P
	for(var/i in 1 to total_paper)
		papers.Add(generate_paper())
	update_appearance()

/obj/item/paper_bin/proc/generate_paper()
	var/obj/item/paper/P = new papertype(src)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		if(prob(30))
			P.info = "<font face=\"[CRAYON_FONT]\" color=\"red\"><b>HONK HONK HONK HONK HONK HONK HONK<br>HOOOOOOOOOOOOOOOOOOOOOONK<br>APRIL FOOLS</b></font>"
			P.AddComponent(/datum/component/honkspam)
	return P

/obj/item/paper_bin/Destroy()
	if(papers)
		for(var/i in papers)
			qdel(i)
		papers = null
	. = ..()

/obj/item/paper_bin/dump_contents(atom/droppoint, collapse = FALSE)
	if(!droppoint)
		droppoint = drop_location()
	if(collapse)
		visible_message("<span class='warning'>The stack of paper collapses!</span>")
	for(var/atom/movable/AM in contents)
		AM.forceMove(droppoint)
		if(!AM.pixel_y)
			AM.pixel_y = rand(-3,3)
		if(!AM.pixel_x)
			AM.pixel_x = rand(-3,3)
	papers.Cut()
	update_appearance()

/obj/item/paper_bin/fire_act(exposed_temperature, exposed_volume)
	if(LAZYLEN(papers))
		papers.Cut()
		update_appearance()
	..()

/obj/item/paper_bin/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/paper_bin/attack_hand(mob/user, list/modifiers)
	if(isliving(user))
		var/mob/living/L = user
		if(!(L.mobility_flags & MOBILITY_PICKUP))
			return
	user.changeNext_move(CLICK_CD_MELEE)
	if(at_overlay_limit())
		dump_contents(drop_location(), TRUE)
		return
	if(bin_pen)
		var/obj/item/pen/P = bin_pen
		P.add_fingerprint(user)
		P.forceMove(user.loc)
		user.put_in_hands(P)
		to_chat(user, "<span class='notice'>You take [P] out of \the [src].</span>")
		bin_pen = null
		update_appearance()
	else if(LAZYLEN(papers))
		var/obj/item/paper/top_paper = papers[LAZYLEN(papers)]
		papers.Remove(top_paper)
		top_paper.add_fingerprint(user)
		top_paper.forceMove(user.loc)
		user.put_in_hands(top_paper)
		to_chat(user, "<span class='notice'>You take [top_paper] out of \the [src].</span>")
		update_appearance()
	else
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
	add_fingerprint(user)
	return ..()

/obj/item/paper_bin/attackby(obj/item/I, mob/user, params)
	if(at_overlay_limit())
		dump_contents(drop_location(), TRUE)
		return
	if(istype(I, /obj/item/paper))
		var/obj/item/paper/P = I
		if(!user.transferItemToLoc(P, src))
			return
		to_chat(user, "<span class='notice'>You put [P] in [src].</span>")
		papers.Add(P)
		update_appearance()
	else if(istype(I, /obj/item/pen) && !bin_pen)
		var/obj/item/pen/P = I
		if(!user.transferItemToLoc(P, src))
			return
		to_chat(user, "<span class='notice'>You put [P] in [src].</span>")
		bin_pen = P
		update_appearance()
	else
		return ..()

/obj/item/paper_bin/proc/at_overlay_limit()
	return overlays.len >= MAX_ATOM_OVERLAYS

/obj/item/paper_bin/examine(mob/user)
	. = ..()
	if(total_paper)
		. += "It contains [total_paper > 1 ? "[total_paper] papers" : "one paper"]."
	else
		. += "It doesn't contain anything."

/obj/item/paper_bin/update_icon_state()
	if(total_paper < 1)
		icon_state = "paper_bin0"
	else
		icon_state = "[initial(icon_state)]"
	return ..()

/obj/item/paper_bin/update_overlays()
	. = ..()

	total_paper = LAZYLEN(papers)

	if(bin_pen)
		pen_overlay = mutable_appearance(bin_pen.icon, bin_pen.icon_state)

	if(!bin_overlay)
		bin_overlay = mutable_appearance(icon, bin_overlay_string)

	if(LAZYLEN(papers))
		for(var/paper_number in 1 to LAZYLEN(papers))
			if(paper_number != LAZYLEN(papers) && paper_number % 8 != 0) //only top paper and every 8th paper get overlays
				continue
			var/obj/item/paper/current_paper = papers[paper_number]
			var/mutable_appearance/paper_overlay = mutable_appearance(current_paper.icon, current_paper.icon_state)
			paper_overlay.color = current_paper.color
			paper_overlay.pixel_y = paper_number/8 - 2 //gives the illusion of stacking
			. += paper_overlay
			if(paper_number == LAZYLEN(papers)) //this is our top paper
				. += current_paper.overlays //add overlays only for top paper
				if(istype(src, /obj/item/paper_bin/bundlenatural))
					bin_overlay.pixel_y = paper_overlay.pixel_y //keeps binding centred on stack
				if(bin_pen)
					pen_overlay.pixel_y = paper_overlay.pixel_y //keeps pen on top of stack
		. += bin_overlay

	if(bin_pen)
		. += pen_overlay

/obj/item/paper_bin/construction
	name = "construction paper bin"
	desc = "Contains all the paper you'll never need, IN COLOR!"
	papertype = /obj/item/paper/construction

/obj/item/paper_bin/bundlenatural
	name = "natural paper bundle"
	desc = "A bundle of paper created using traditional methods."
	icon_state = null
	papertype = /obj/item/paper/natural
	resistance_flags = FLAMMABLE
	bin_overlay_string = "paper_bundle_overlay"
	///Cable this bundle is held together with.
	var/obj/item/stack/cable_coil/binding_cable

/obj/item/paper_bin/bundlenatural/Initialize(mapload)
	binding_cable = new /obj/item/stack/cable_coil(src, 2)
	binding_cable.color = "#a9734f"
	binding_cable.cable_color = "brown"
	binding_cable.desc += " Non-natural."
	return ..()

/obj/item/paper_bin/bundlenatural/dump_contents(atom/droppoint)
	. = ..()
	qdel(src)

/obj/item/paper_bin/bundlenatural/update_overlays()
	bin_overlay = mutable_appearance(icon, bin_overlay_string)
	bin_overlay.color = binding_cable.color
	return ..()

/obj/item/paper_bin/bundlenatural/attack_hand(mob/user, list/modifiers)
	..()
	if(!LAZYLEN(papers))
		deconstruct(FALSE)

/obj/item/paper_bin/bundlenatural/deconstruct(disassembled)
	dump_contents()
	return ..()

/obj/item/paper_bin/bundlenatural/fire_act(exposed_temperature, exposed_volume)
	qdel(src)

/obj/item/paper_bin/bundlenatural/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/paper/carbon) && (W.icon_state == "paper_stack" || W.icon_state == "paper_stack_words"))
		to_chat(user, "<span class='warning'>[W] won't fit into [src].</span>")
		return
	if(W.get_sharpness())
		if(W.use_tool(src, user, 1 SECONDS))
			to_chat(user, "<span class='notice'>You slice the cable from [src].</span>")
			deconstruct(TRUE)
	else
		..()

/obj/item/paper_bin/carbon
	name = "carbon paper bin"
	desc = "Contains all the paper you'll ever need, in duplicate!"
	icon_state = "paper_bin_carbon0"
	papertype = /obj/item/paper/carbon
	bin_overlay_string = "paper_bin_carbon_overlay"
