/obj/item/paper_bin
	name = "paper bin"
	desc = "Contains all the paper you'll never need."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_bin_empty"
	inhand_icon_state = "sheet-metal"
	lefthand_file = 'icons/mob/inhands/misc/sheets_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/sheets_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 3
	throw_range = 7
	pressure_resistance = 8
	var/papertype = /obj/item/paper
	var/starting_sheets = 30
	var/list/papers = list()
	var/obj/item/pen/bin_pen
	/// This goes over the top to give the paper the appearance of being inside the object.
	var/paper_bin_overlay = "paper_bin_overlay"

/obj/item/paper_bin/Initialize(mapload)
	. = ..()
	interaction_flags_item &= ~INTERACT_ITEM_ATTACK_HAND_PICKUP
	if(mapload)
		var/obj/item/pen/P = locate(/obj/item/pen) in src.loc
		if(P && !bin_pen)
			P.forceMove(src)
			bin_pen = P
	for(var/i in 1 to starting_sheets)
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
		papers.Cut()
	. = ..()

/obj/item/paper_bin/dump_contents()
	var/atom/droppoint = drop_location()
	for(var/atom/movable/AM in contents)
		AM.forceMove(droppoint)
	papers.Cut()
	update_appearance()

/obj/item/paper_bin/fire_act(exposed_temperature, exposed_volume)
	if(LAZYLEN(papers))
		papers.Cut()
		update_appearance()
	..()

/obj/item/paper_bin/MouseDrop(atom/over_object)
	. = ..()
	var/mob/living/M = usr
	if(!istype(M) || M.incapacitated() || !Adjacent(M))
		return

	if(over_object == M)
		M.put_in_hands(src)

	else if(istype(over_object, /atom/movable/screen/inventory/hand))
		var/atom/movable/screen/inventory/hand/H = over_object
		M.putItemFromInventoryInHandIfPossible(src, H.held_index)

	add_fingerprint(M)

/obj/item/paper_bin/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/paper_bin/attack_hand(mob/user, list/modifiers)
	if(isliving(user))
		var/mob/living/L = user
		if(!(L.mobility_flags & MOBILITY_PICKUP))
			return
	user.changeNext_move(CLICK_CD_MELEE)
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

/obj/item/paper_bin/examine(mob/user)
	. = ..()
	if(LAZYLEN(papers))
		. += "It contains [LAZYLEN(papers) > 1 ? "[LAZYLEN(papers)] papers" : "one paper"]."

/obj/item/paper_bin/update_overlays()
	. = ..()
	if(LAZYLEN(papers))
		var/paper_number = 1
		for(var/obj/item/paper/current_paper in papers)
			var/mutable_appearance/paper_overlay = mutable_appearance(current_paper.icon, current_paper.icon_state)
			paper_overlay.color = current_paper.color
			switch(paper_number)
				if(1 to 8)
					paper_overlay.pixel_y -= 2
				if(9 to 16)
					paper_overlay.pixel_y -= 1
				if(17 to 24)
					paper_overlay.pixel_y += 0
				if(25 to 32)
					paper_overlay.pixel_y += 1
				if(33 to INFINITY)
					paper_overlay.pixel_y += 2
			. += paper_overlay
			. += current_paper.overlays
			paper_number++
	if(LAZYLEN(papers))
		. += mutable_appearance(icon, paper_bin_overlay)
	if(bin_pen)
		. += mutable_appearance(bin_pen.icon, bin_pen.icon_state)

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
	paper_bin_overlay = "paper_bundle_overlay"
	///Color of the cable this bundle is held together with.
	var/cable_color = "#a9734f"

/obj/item/paper_bin/bundlenatural/attack_hand(mob/user, list/modifiers)
	..()
	if(!LAZYLEN(papers))
		deconstruct(FALSE)

/obj/item/paper_bin/bundlenatural/deconstruct(disassembled = TRUE)
	var/obj/item/stack/cable_coil/dropped_cable = new /obj/item/stack/cable_coil(drop_location(), 2)
	dropped_cable.color = cable_color
	dropped_cable.cable_color = "brown"
	dropped_cable.desc += " Non-natural."
	dump_contents()
	qdel(src)

/obj/item/paper_bin/bundlenatural/fire_act(exposed_temperature, exposed_volume)
	qdel(src)

/obj/item/paper_bin/bundlenatural/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/paper/carbon) && (W.icon_state == "paper_stack" || W.icon_state == "paper_stack_words"))
		to_chat(user, "<span class='warning'>[W] won't fit into [src].</span>")
		return
	if(W.get_sharpness())
		to_chat(user, "<span class='notice'>You slice the cable from [src].</span>")
		deconstruct(TRUE)
	else
		..()

/obj/item/paper_bin/bundlenatural/wirecutter_act(mob/user, obj/item/tool)
	. = ..()
	if(tool.use_tool(src, user, 1 SECONDS))
		to_chat(user, "<span class='notice'>You snip the cable from [src].</span>")
		deconstruct(TRUE)
		return TRUE

/obj/item/paper_bin/bundlenatural/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[src] is held together with cable. It could be <b>cut</b>.</span>"

/obj/item/paper_bin/bundlenatural/crafted
	name = "handcrafted paper bundle"
	starting_sheets = 1

/obj/item/paper_bin/carbon
	name = "carbon paper bin"
	desc = "Contains all the paper you'll ever need, in duplicate!"
	icon_state = "paper_bin_carbon_empty"
	papertype = /obj/item/paper/carbon
	paper_bin_overlay = "paper_bin_carbon_overlay"
