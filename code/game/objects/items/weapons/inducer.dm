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
	var/recharging = FALSE

/obj/item/weapon/inducer/Initialize()
	. = ..()
	if(!cell && cell_type)
		cell = new cell_type

/obj/item/weapon/inducer/proc/induce(obj/item/weapon/stock_parts/cell/target, coefficient)
	var/totransfer = min(cell.charge,(powertransfer * coefficient))
	var/transferred = target.give(totransfer)
	cell.use(transferred)
	cell.update_icon()
	target.update_icon()

/obj/item/weapon/inducer/get_cell()
	return cell

/obj/item/weapon/inducer/emp_act(severity)
	..()
	if(cell)
		cell.emp_act(severity)

/obj/item/weapon/inducer/attack_obj(obj/O, mob/living/carbon/user)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(cantbeused(user))
		return

	if(recharge(O, user))
		return

	return ..()

/obj/item/weapon/inducer/proc/cantbeused(mob/user)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to use \the [src]!</span>")
		return TRUE

	if(!cell)
		to_chat(user, "<span class='warning'>\The [src] doesn't have a power cell installed!</span>")
		return TRUE

	if(!cell.charge)
		to_chat(user, "<span class='warning'>\The [src]'s battery is dead!</span>")
		return TRUE
	return FALSE


/obj/item/weapon/inducer/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/screwdriver))
		playsound(src, W.usesound, 50, 1)
		if(!opened)
			to_chat(user, "<span class='notice'>You unscrew the battery compartment.</span>")
			opened = TRUE
			update_icon()
			return
		else
			to_chat(user, "<span class='notice'>You close the battery compartment.</span>")
			opened = FALSE
			update_icon()
			return
	if(istype(W, /obj/item/weapon/stock_parts/cell))
		if(opened)
			if(!cell)
				if(!user.transferItemToLoc(W, src))
					return
				to_chat(user, "<span class='notice'>You insert \the [W] into \the [src].</span>")
				cell = W
				update_icon()
				return
			else
				to_chat(user, "<span class='notice'>\The [src] already has \a [cell] installed!</span>")
				return

	if(cantbeused(user))
		return

	if(recharge(W, user))
		return

	return ..()

/obj/item/weapon/inducer/proc/recharge(atom/movable/A, mob/user)
	if(recharging)
		return TRUE
	else
		recharging = TRUE
	var/obj/item/weapon/stock_parts/cell/C = A.get_cell()
	var/obj/item/weapon/gun/energy/E
	var/obj/O
	var/coefficient = 1
	if(istype(A, /obj/item/weapon/gun/energy))
		coefficient = 0.075 // 14 loops to recharge an egun from 0-1000
		E = A
	if(istype(A, /obj))
		O = A
	if(C)
		if(C.charge >= C.maxcharge)
			to_chat(user, "<span class='notice'>\The [A] is fully charged!</span>")
			recharging = FALSE
			return TRUE
		user.visible_message("[user] starts recharging \the [A] with \the [src]","<span class='notice'>You start recharging [A] with \the [src]</span>")
		while(C.charge < C.maxcharge)
			if(E)
				E.chambered = null  // Prevents someone from firing continuously while recharging the gun.
			if(do_after(user, 10, target = user) && cell.charge)
				induce(C, coefficient)
				do_sparks(1, FALSE, A)
				if(O)
					O.update_icon()
			else
				break
		if(E)
			E.recharge_newshot() //We're done charging, so we'll let someone fire it now.
		user.visible_message("[user] recharged \the [A]!","<span class='notice'>You recharged \the [A]!</span>")
		recharging = FALSE
		return TRUE
	recharging = FALSE


/obj/item/weapon/inducer/attack(mob/M, mob/user)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(cantbeused(user))
		return

	if(recharge(M, user))
		return
	return ..()


/obj/item/weapon/inducer/attack_self(mob/user)
	if(opened && cell)
		user.visible_message("[user] removes \the [cell] from \the [src]!","<span class='notice'>You remove \the [cell].</span>")
		cell.update_icon()
		user.put_in_hands(cell)
		cell = null
		update_icon()


/obj/item/weapon/inducer/examine(mob/living/M)
	..()
	if(cell)
		to_chat(M, "<span class='notice'>It's display shows: [cell.charge]W</span>")
	else
		to_chat(M,"<span class='notice'>It's display is dark.</span>")
	if(opened)
		to_chat(M,"<span class='notice'>It's battery compartment is open.</span>")

/obj/item/weapon/inducer/update_icon()
	cut_overlays()
	if(opened)
		if(!cell)
			add_overlay("inducer-nobat")
		else
			add_overlay("inducer-bat")

/obj/item/weapon/inducer/sci
	icon_state = "inducer-sci"
	item_state = "inducer-sci"
	desc = "A tool for inductively charging internal power cells. This one has a science color scheme, and is less potent than it's engineering counterpart."
	cell_type = null
	powertransfer = 500
	opened = TRUE

/obj/item/weapon/inducer/sci/Initialize()
	. = ..()
	update_icon()


