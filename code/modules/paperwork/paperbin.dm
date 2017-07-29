/obj/item/weapon/paper_bin
	name = "paper bin"
	desc = "Contains all the paper you'll never need."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_bin1"
	item_state = "sheet-metal"
	lefthand_file = 'icons/mob/inhands/misc/sheets_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/sheets_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 3
	throw_range = 7
	pressure_resistance = 8
	var/papertype = /obj/item/weapon/paper
	var/total_paper = 30
	var/list/papers = list()
	var/obj/item/weapon/pen/bin_pen

/obj/item/weapon/paper_bin/Initialize(mapload)
	. = ..()
	if(!mapload)
		return
	var/obj/item/weapon/pen/P = locate(/obj/item/weapon/pen) in src.loc
	if(P && !bin_pen)
		P.loc = src
		bin_pen = P
		update_icon()
		var/static/warned = FALSE
		if(P.type == /obj/item/weapon/pen && !warned)
			warning("one or more paperbins ate a pen duing initialize()")
			warned = TRUE

/obj/item/weapon/paper_bin/fire_act(exposed_temperature, exposed_volume)
	if(!total_paper)
		return
	..()

/obj/item/weapon/paper_bin/Destroy()
	if(papers)
		for(var/i in papers)
			qdel(i)
		papers = null
	. = ..()

/obj/item/weapon/paper_bin/fire_act(exposed_temperature, exposed_volume)
	if(total_paper)
		total_paper = 0
		update_icon()
	..()

/obj/item/weapon/paper_bin/MouseDrop(atom/over_object)
	var/mob/living/M = usr
	if(!istype(M) || M.incapacitated() || !Adjacent(M))
		return

	if(over_object == M)
		M.put_in_hands(src)

	else if(istype(over_object, /obj/screen/inventory/hand))
		var/obj/screen/inventory/hand/H = over_object
		M.putItemFromInventoryInHandIfPossible(src, H.held_index)

	add_fingerprint(M)


/obj/item/weapon/paper_bin/attack_paw(mob/user)
	return attack_hand(user)


/obj/item/weapon/paper_bin/attack_hand(mob/user)
	if(user.lying)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	if(bin_pen)
		var/obj/item/weapon/pen/P = bin_pen
		P.loc = user.loc
		user.put_in_hands(P)
		to_chat(user, "<span class='notice'>You take [P] out of \the [src].</span>")
		bin_pen = null
		update_icon()
	else if(total_paper >= 1)
		total_paper--
		update_icon()
		// If there's any custom paper on the stack, use that instead of creating a new paper.
		var/obj/item/weapon/paper/P
		if(papers.len > 0)
			P = papers[papers.len]
			papers.Remove(P)
		else
			P = new papertype(src)
			if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
				if(prob(30))
					P.info = "<font face=\"[CRAYON_FONT]\" color=\"red\"><b>HONK HONK HONK HONK HONK HONK HONK<br>HOOOOOOOOOOOOOOOOOOOOOONK<br>APRIL FOOLS</b></font>"
					P.rigged = 1
					P.updateinfolinks()

		P.loc = user.loc
		user.put_in_hands(P)
		to_chat(user, "<span class='notice'>You take [P] out of \the [src].</span>")
	else
		to_chat(user, "<span class='warning'>[src] is empty!</span>")

	add_fingerprint(user)


/obj/item/weapon/paper_bin/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/paper))
		var/obj/item/weapon/paper/P = I
		if(!user.transferItemToLoc(P, src))
			return
		to_chat(user, "<span class='notice'>You put [P] in [src].</span>")
		papers.Add(P)
		total_paper++
		update_icon()
	else if(istype(I, /obj/item/weapon/pen) && !bin_pen)
		var/obj/item/weapon/pen/P = I
		if(!user.transferItemToLoc(P, src))
			return
		to_chat(user, "<span class='notice'>You put [P] in [src].</span>")
		bin_pen = P
		update_icon()
	else
		return ..()

/obj/item/weapon/paper_bin/examine(mob/user)
	..()
	if(total_paper)
		to_chat(user, "It contains " + (total_paper > 1 ? "[total_paper] papers" : " one paper")+".")
	else
		to_chat(user, "It doesn't contain anything.")


/obj/item/weapon/paper_bin/update_icon()
	if(total_paper < 1)
		icon_state = "paper_bin0"
	else
		icon_state = "[initial(icon_state)]"
	cut_overlays()
	if(bin_pen)
		add_overlay(mutable_appearance(bin_pen.icon, bin_pen.icon_state))

/obj/item/weapon/paper_bin/construction
	name = "construction paper bin"
	desc = "Contains all the paper you'll never need, IN COLOR!"
	icon_state = "paper_binc"
	papertype = /obj/item/weapon/paper/construction

/obj/item/weapon/paper_bin/bundlenatural
	name = "natural paper bundle"
	desc = "A bundle of paper created using traditional methods."
	icon_state = "paper_bundle"
	papertype = /obj/item/weapon/paper/natural
	resistance_flags = FLAMMABLE
/obj/item/weapon/paper_bin/bundlenatural/attack_hand(mob/user)
	..()
	if(total_paper < 1)
		qdel(src)
/obj/item/weapon/paper_bin/bundlenatural/fire_act(exposed_temperature, exposed_volume)
	qdel(src)
/obj/item/weapon/paper_bin/bundlenatural/attackby(obj/item/weapon/W, mob/user)
	if(W.is_sharp())
		to_chat(user, "<span class='notice'>You snip \the [src], spilling paper everywhere.</span>")
		var/turf/T = get_turf(src.loc)
		while(total_paper > 0)
			total_paper--
			var/obj/item/weapon/paper/P
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