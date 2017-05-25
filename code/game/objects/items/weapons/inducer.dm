
/obj/item/weapon/inducer
	name = "inducer"
	desc = "A tool for inductively charging internal power cells."
	icon = 'icons/obj/tools.dmi'
	icon_state = "inducer-engi"
	origin_tech = "engineering=4;magnets=4;powerstorage=4"
	force = 7
	var/powertransfer = 1000
	var/opened = FALSE
	var/cell_type = /obj/item/weapon/stock_parts/cell/high
	var/obj/item/weapon/stock_parts/cell/cell

/obj/item/weapon/inducer/Initialize()
	. = ..()
	src.cell = new cell_type

/obj/item/weapon/inducer/proc/induce(obj/item/weapon/stock_parts/cell/target)
	var/totransfer = max(cell.charge,powertransfer)
	var/transferred = target.give(totransfer)
	cell.use(transferred)

/obj/item/weapon/inducer/proc/get_cell(atom/target)
	if(istype(target, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/A = target
		return A.cell
	if(istype(target, /obj/item/weapon/gun/energy))
		var/obj/item/weapon/gun/energy/A = target
		return A.cell
	if(istype(target, /obj/item/weapon/melee/baton))
		var/obj/item/weapon/melee/baton/A = target
		return A.cell
	if(istype(target, /obj/item/clothing/suit/space/space_ninja))
		var/obj/item/clothing/suit/space/space_ninja/A = target
		return A.cell
	if(istype(target, /obj/machinery/space_heater))
		var/obj/machinery/space_heater/A = target
		return A.cell
	if(istype(target, /obj/mecha))
		var/obj/mecha/A = target
		return A.cell
	if(istype(target, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/A = target
		return A.cell

	return null

/obj/item/weapon/inducer/attack_obj(obj/target, mob/living/carbon/user)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to use \the [src]!</span>")
		return

	if(!cell)
		to_chat(user, "<span class='warning'> The [src] doesn't have a power cell installed!</span>")
		return

	if(!cell.charge)
		to_chat(user, "<span class='warning'> The [src]'s battery is dead!</span>")
		return

	var/obj/item/weapon/stock_parts/cell/C = get_cell(target)
	if(C)
		user.visible_message("[user] starts recharging the [target] with \the [src]",\
							"<span class='notice'> You start recharging the [target] with \the [src]</span>")
		if(do_after(user, 20, target = C))
			induce(C)
			user.visible_message("[user] recharged the [target]!",\
								 "<span class='notice'> You recharged the [target]!</span>")
			return
	..()

/obj/item/weapon/inducer/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/weapon/screwdriver))
		if(!opened)
			to_chat(user, "<span class='notice'>You unscrew the battery compartment.</span>")
			opened = TRUE
			update_icon()
		else
			to_chat(user, "<span class='notice'>You close the battery comparment.</span>")
			opened = FALSE
			update_icon()
	if(istype(W,/obj/item/weapon/stock_parts/cell))
		if(opened)
			if(!cell)
				if(!user.transferItemToLoc(W, src))
					return
				to_chat(user, "<span class='notice'>You insert the [W] into \the [src].</span>")
				cell = W
				update_icon()
			else
				to_chat(user, "<span class='notice'>The [src] already has \the [cell] installed!</span>")
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


/obj/item/weapon/inducer/sci
	icon_state = "inducer-sci"

/obj/item/weapon/inducer/sci/Initialize()
	. = ..()
	desc += " This one has a science color scheme."

