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
	if(LAZYLEN(papers))
		for(var/paper in papers)
			qdel(paper)
		papers.Cut()
	. = ..()

/obj/item/paper_bin/dump_contents(atom/droppoint)
	if(!droppoint)
		droppoint = drop_location()
	for(var/atom/movable/AM in contents)
		AM.forceMove(droppoint)
		if(!AM.pixel_y)
			AM.pixel_y = rand(-5,5)
		if(!AM.pixel_x)
			AM.pixel_x = rand(-5,5)
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

	if(overlays.len >= MAX_ATOM_OVERLAYS)
		visible_message("<span class='warning'>The stack of paper collapses!</span>")
		dump_contents()
		add_fingerprint(M)
		return

	if(isturf(over_object))
		to_chat(M,"<span class='notice'>Use it in-hand to dump it out.</span>")
		return

/obj/item/paper_bin/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/paper_bin/attack_hand(mob/user, list/modifiers)
	if(isliving(user))
		var/mob/living/L = user
		if(!(L.mobility_flags & MOBILITY_PICKUP))
			return
	user.changeNext_move(CLICK_CD_MELEE)
	if(overlays.len >= MAX_ATOM_OVERLAYS)
		visible_message("<span class='warning'>The stack of paper collapses!</span>")
		dump_contents()
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
	if(overlays.len >= MAX_ATOM_OVERLAYS)
		visible_message("<span class='warning'>The stack of paper collapses!</span>")
		dump_contents()
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

/obj/item/paper_bin/attack_self(mob/user)
	if(LAZYLEN(contents))
		user.visible_message("<span class='warning'>[user] begins dumping out [src]!</span>", "<span class='notice'>You begin dumping out [src]...</span>")
		if(do_after(user, 0.3 SECONDS * LAZYLEN(contents)))
			user.visible_message("<span class='warning'>[user] dumps out [src]!</span>", "<span class='notice'>You dump out [src].</span>")
			dump_contents()

/obj/item/paper_bin/examine(mob/user)
	. = ..()
	if(LAZYLEN(papers))
		. += "<span class='notice'>It contains [LAZYLEN(papers) > 1 ? "[LAZYLEN(papers)] sheets" : "one sheet"]."
	. += "<span class='notice'>Click and drag to your sprite to pick up.</span>[LAZYLEN(papers) ? " <span class='notice'>Use in-hand to dump out.</span>" : ""]"
/obj/item/paper_bin/update_overlays()
	. = ..()

	if(bin_pen)
		pen_overlay = mutable_appearance(bin_pen.icon, bin_pen.icon_state)

	if(LAZYLEN(papers))
		var/paper_number = 1
		for(var/obj/item/paper/current_paper in papers)
			var/mutable_appearance/paper_overlay = mutable_appearance(current_paper.icon, current_paper.icon_state)
			paper_overlay.color = current_paper.color
			paper_overlay.pixel_y = paper_number/8 - 2
			if(istype(src, /obj/item/paper_bin/bundlenatural))
				bin_overlay.pixel_y = paper_overlay.pixel_y //keeps it on top
			if(bin_pen)
				pen_overlay.pixel_y = paper_overlay.pixel_y //keeps it on top
			. += paper_overlay
			. += current_paper.overlays
			paper_number++

		if(!bin_overlay)
			bin_overlay = mutable_appearance(icon, bin_overlay_string)
		. += bin_overlay

	if(bin_pen)
		. += pen_overlay

/obj/item/paper_bin/crafted
	starting_sheets = 0

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
	qdel(src)

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

/obj/item/paper_bin/bundlenatural/wirecutter_act(mob/user, obj/item/tool)
	. = ..()
	if(tool.use_tool(src, user, 1 SECONDS))
		to_chat(user, "<span class='notice'>You snip the cable from [src].</span>")
		deconstruct(TRUE)
		return TRUE

/obj/item/paper_bin/bundlenatural/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The cable looks <b>cuttable</b>.</span>"

/obj/item/paper_bin/bundlenatural/crafted
	name = "handcrafted paper bundle"
	starting_sheets = 0

/obj/item/paper_bin/bundlenatural/CheckParts(list/parts_list, datum/crafting_recipe/R)
	..()
	for(var/obj/item/paper/sick_pape in contents)
		papers.Add(sick_pape)

	for(var/obj/item/stack/cable_coil/found_cable in contents)
		if(found_cable != binding_cable)
			qdel(binding_cable)
			binding_cable = found_cable

	update_appearance()

/obj/item/paper_bin/carbon
	name = "carbon paper bin"
	desc = "Contains all the paper you'll ever need, in duplicate!"
	icon_state = "paper_bin_carbon_empty"
	papertype = /obj/item/paper/carbon
	bin_overlay_string = "paper_bin_carbon_overlay"
