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
	var/total_paper = 30
	var/list/papers = list()
	var/obj/item/pen/bin_pen
	/// Paper visible on top.
	var/obj/item/paper/top_paper
	/// This goes over the top of the top paper to give it the appearance of being inside the object.
	var/paper_bin_overlay = "paper_bin_overlay"

/obj/item/paper_bin/Initialize(mapload)
	. = ..()
	interaction_flags_item &= ~INTERACT_ITEM_ATTACK_HAND_PICKUP
	if(mapload)
		var/obj/item/pen/P = locate(/obj/item/pen) in src.loc
		if(P && !bin_pen)
			P.forceMove(src)
			bin_pen = P
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

/obj/item/paper_bin/fire_act(exposed_temperature, exposed_volume)
	if(total_paper)
		total_paper = 0
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
	else if(total_paper)
		total_paper--
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
		total_paper++
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
	if(total_paper)
		. += "It contains [total_paper > 1 ? "[total_paper] papers" : "one paper"]."
	else
		. += "It doesn't contain anything."

/obj/item/paper_bin/update_overlays()
	. = ..()
	if(LAZYLEN(papers))
		top_paper = papers[papers.len] //last in first out
	else if(total_paper)
		papers.Add(generate_paper())
		top_paper = papers[papers.len]
	else
		top_paper = null

	if(top_paper)
		. += mutable_appearance(top_paper.icon, top_paper.icon_state)
		. += top_paper.overlays
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
	icon_state = "paper_bundle"
	papertype = /obj/item/paper/natural
	resistance_flags = FLAMMABLE
	paper_bin_overlay = "paper_bundle_overlay"

/obj/item/paper_bin/bundlenatural/attack_hand(mob/user, list/modifiers)
	..()
	if(total_paper < 1)
		qdel(src)

/obj/item/paper_bin/bundlenatural/fire_act(exposed_temperature, exposed_volume)
	qdel(src)

/obj/item/paper_bin/bundlenatural/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/paper/carbon) && (W.icon_state == "paper_stack" || W.icon_state == "paper_stack_words"))
		to_chat(user, "<span class='warning'>[W] won't fit into [src].</span>")
		return
	if(W.get_sharpness())
		to_chat(user, "<span class='notice'>You snip \the [src], spilling paper everywhere.</span>")
		var/turf/T = get_turf(src.loc)
		while(total_paper > 0)
			total_paper--
			var/obj/item/paper/P
			if(papers.len > 0)
				P = papers[papers.len]
				papers -= P
			else
				P = new papertype()
				P.forceMove(T)
			CHECK_TICK
		qdel(src)
	else
		..()

/obj/item/paper_bin/carbon
	name = "carbon paper bin"
	desc = "Contains all the paper you'll ever need, in duplicate!"
	icon_state = "paper_bin_carbon_empty"
	papertype = /obj/item/paper/carbon
	paper_bin_overlay = "paper_bin_carbon_overlay"
