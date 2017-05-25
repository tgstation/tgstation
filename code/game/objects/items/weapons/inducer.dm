
/obj/item/weapon/inducer
	name = "inducer"
	desc = "A tool for inductively charging internal power cells."
	icon = 'icons/obj/tools.dmi'
	icon_state = "inducer-engi"
	item_state = "inducer-engi"
	origin_tech = "engineering=4;magnets=4;powerstorage=4"
	force = 7
	var/powertransfer = 1000
	var/opened = FALSE
	var/cell_type = /obj/item/weapon/stock_parts/cell/high
	var/obj/item/weapon/stock_parts/cell/cell

/obj/item/weapon/inducer/Initialize()
	. = ..()
	cell = new cell_type

/obj/item/weapon/inducer/proc/induce(obj/item/weapon/stock_parts/cell/target)
	var/totransfer = min(cell.charge,powertransfer)
	var/transferred = target.give(totransfer)
	cell.use(transferred)
	cell.updateicon()
	target.updateicon()

/obj/item/weapon/inducer/get_cell()
	return cell

/obj/item/weapon/inducer/attack_obj(obj/O, mob/living/carbon/user)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to use \the [src]!</span>")
		return

	if(!cell)
		to_chat(user, "<span class='warning'>The [src] doesn't have a power cell installed!</span>")
		return

	if(!cell.charge)
		to_chat(user, "<span class='warning'>The [src]'s battery is dead!</span>")
		return

	var/obj/item/weapon/stock_parts/cell/C = O.get_cell()
	if(C)
		if(C.charge == C.maxcharge)
			to_chat(user, "<span class='notice'>The [O] is fully charged!</span>")
			return
		user.visible_message("[user] starts recharging the [O] with \the [src]",\
							"<span class='notice'>You start recharging the [O] with \the [src]</span>")
		if(do_after(user, 20, target = O, progress = 1))
			induce(C)
			user.visible_message("[user] recharged the [O]!",\
								 "<span class='notice'> You recharged the [O]!</span>")
			return
	..()

/obj/item/weapon/inducer/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/weapon/screwdriver))
		if(!opened)
			to_chat(user, "<span class='notice'>You unscrew the battery compartment.</span>")
			opened = TRUE
			update_icon()
			return
		else
			to_chat(user, "<span class='notice'>You close the battery comparment.</span>")
			opened = FALSE
			update_icon()
			return
	if(istype(W,/obj/item/weapon/stock_parts/cell))
		if(opened)
			if(!cell)
				if(!user.transferItemToLoc(W, src))
					return
				to_chat(user, "<span class='notice'>You insert the [W] into \the [src].</span>")
				cell = W
				update_icon()
				return
			else
				to_chat(user, "<span class='notice'>The [src] already has \the [cell] installed!</span>")
				return

	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to use \the [src]!</span>")
		return

	if(!cell)
		to_chat(user, "<span class='warning'>The [src] doesn't have a power cell installed!</span>")
		return

	if(!cell.charge)
		to_chat(user, "<span class='warning'>The [src]'s battery is dead!</span>")
		return

	var/obj/item/weapon/stock_parts/cell/C = W.get_cell()
	if(C)
		if(C.charge == C.maxcharge)
			to_chat(user, "<span class='notice'>The [W] is fully charged!</span>")
			return
		user.visible_message("[user] starts recharging the [W] with \the [src]",\
							"<span class='notice'>You start recharging the [W] with \the [src]</span>")
		if(do_after(user, 60, target = W, progress = 1)) //Charging items like this is slower because I know someone will bite my head off otherwise.
			induce(C)
			user.visible_message("[user] recharged the [W]!",\
								 "<span class='notice'>You recharged the [W]!</span>")
			return

	..()

/obj/item/weapon/inducer/attack(mob/M, mob/user)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to use \the [src]!</span>")
		return

	if(!cell)
		to_chat(user, "<span class='warning'>The [src] doesn't have a power cell installed!</span>")
		return

	if(!cell.charge)
		to_chat(user, "<span class='warning'>The [src]'s battery is dead!</span>")
		return

	var/obj/item/weapon/stock_parts/cell/C = M.get_cell()
	if(C)
		if(C.charge == C.maxcharge)
			to_chat(user, "<span class='notice'>[M] is fully charged!</span>")
			return

		user.visible_message("[user] starts recharging [M] with \the [src]",\
							"<span class='notice'>You start recharging [M] with \the [src]</span>")
		if(do_after(user, 10, target = M, progress = 1)) //Charging borgs is fast, since they can have high capacity cells inside.
			induce(C)
			user.visible_message("[user] recharged [M]!",\
								 "<span class='notice'>You recharged [M]!</span>")
		return
	..()


/obj/item/weapon/inducer/attack_hand(mob/user)
	if(usr == user && opened && (!issilicon(user)) && user.is_holding(src))
		if(cell)
			user.put_in_hands(cell)
			cell.add_fingerprint(user)
			cell.updateicon()
			src.cell = null
			update_icon()
			user.visible_message("[user] removes the power cell from [src]!",\
								  "<span class='notice'>You remove the power cell.</span>")
	else
		..()


/obj/item/weapon/inducer/examine(mob/living/M)
	..()
	if(cell)
		to_chat(M, "<span class='notice'>The [src]'s display shows: [src.cell.charge]W</span>")
	else
		to_chat(M,"<span class='notice'>The [src]'s display is dark.</span>")
	if(opened)
		to_chat(M,"<span class='notice'>The [src]'s battery compartment is open.</span>")

/obj/item/weapon/inducer/update_icon()
	cut_overlays()
	update_overlays()

/obj/item/weapon/inducer/proc/update_overlays()
	if(!opened)
		return
	else if(!cell)
		add_overlay("inducer-nobat")
	else
		add_overlay("inducer-bat")
	if(blood_DNA)
		add_blood(blood_DNA)


/obj/item/weapon/inducer/sci
	icon_state = "inducer-sci"
	item_state = "inducer-sci"

/obj/item/weapon/inducer/sci/Initialize()
	. = ..()
	desc += " This one has a science color scheme."
	qdel(cell)
	cell = null
	opened = TRUE
	update_icon()


