
/obj/item/weapon/inducer
	name = "inducer"
	desc = "A tool for inductively charging internal power cells."
	icon = "icons/obj/tools.dmi"
	icon_state = "inducer"
	origin_tech = "engineering=4;magnets=4;powerstorage=4"
	force = 7
	var/powertransfer = 1000
	var/opened = FALSE
	var/cell_type = /obj/item/weapon/stock_parts/cell/high
	var/obj/item/weapon/stock_parts/cell/cell

/obj/item/weapon/inducer/Initialize()
	src.cell = new cell_type

/obj/item/weapon/inducer/proc/induce(obj/item/weapon/stock_parts/cell/target)
	var/totransfer = max(cell.charge,powertransfer)
	var/transferred = target.give(totransfer)
	cell.use(transferred)


/obj/item/weapon/inducer/Attack(atom/target, mob/living/user)
	if(user.A_INTENT == INTENT_HARM)
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

	if(istype(target,/obj/item/weapon/stock_parts/cell))
		visible_message("[user] starts charging the [target] with the [src].")
		if(do_after(user, 10)) // Taking a bare cell is faster
			if(target.charge == target.maxcharge)
				to_chat(user, "<span class='warning'> The [target] is fully charged!</span>")
				return
			induce(target)
			visible_message("[user] recharges the [target]!")
			return

	if(istype(target,/obj/machinery/power/apc) || istype(target,/obj/machinery/space_heater) || istype(target,/obj/mecha) || istype(target, /obj/item/weapon/inducer))
		if (target == src)
			to_chat(user,"<span class='warning'> The [src] can't charge itself!")
			return
		visible_message("[user] starts charging the [target] with the [src].")
		if(do_after(user, 20) )
			if(target.cell.charge == target.cell.maxcharge)
				to_chat(user, "<span class='warning'> The [target] is fully charged!</span>")
				return
			induce(target.cell)
			visible_message("[user] recharges the [target]!")
			return

	if(istype(target,/obj/item/weapon/gun/energy))
		visible_message("[user] starts charging the [target] with the [src].")
		if(do_after(user, 40)) //Recharging energy guns should be slower, probably.
			if(target.power_supply.charge == target.power_supply.maxcharge)
				to_chat(user, "<span class='warning'> The [target] is fully charged!</span>")
				return
			induce(target.power_supply)
			visible_message("[user] recharges the [target]!")
			return

	if(istype(target,/obj/item/clothing/suit/space/space_ninja))
		visible_message("[user] starts charging the [target] with the [src].")
		if(do_after(user, 40) ) //Same with ninja suits.
			if(target.cell.charge == target.cell.maxcharge)
				to_chat(user, "<span class='warning'> The [target] is fully charged!</span>")
				return
			induce(target.cell)
			visible_message("[user] recharges the [target]!")
			return

	if(istype(target,/obj/item/weapon/melee/baton) || istype(target,/obj/item/weapon/defibrillator))
		visible_message("[user] starts charging the [target] with the [src].")
		if(do_after(user, 40) )
			if(target.bcell.charge == target.bcell.maxcharge)
				to_chat(user, "<span class='warning'> The [target] is fully charged!</span>")
				return
			induce(target.bcell)
			visible_message("[user] recharges the [target]!")
			return


	if(istype(target, /obj/item/machinery/chem_dispenser))
		if(target.energy = target.max_energy)
			to_chat(user, "<span class='warning'> The [target] is fully charged!")
			return
		visible_message("[user] starts charging the [target] with the [src].")
		if(do_after(user, 20) )
			if(target.energy = target.max_energy)
				to_chat(user, "<span class='warning'> The [target] is fully charged!</span>")
				return
			target.energy += 10;
			cell.use(powertransfer)
			visible_message("[user] recharges the [target]!")
			return

	if(istype(target, /mob/living/silicon/robot))
		if(target.cell.charge == target.cell.maxcharge)
		visible_message("[user] starts charging [target]'s power cell with the [src].")
		if(do_after(user, 20, target) )
			if(target.cell.charge == target.cell.maxcharge)
				to_chat(user, "<span class='notice'>[target]'s power cell is fully charged!</span>")
				return
			induce(target.cell)
			visible_message("[user] recharges [target]'s power cell!")
			return
	..()

/obj/item/weapon/inducer/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/weapon/screwdriver))
	if(!opened)
		to_chat(user, "You unscrew the battery compartment.")
		opened = TRUE
		update_icon()
	else
		to_chat(user, "You close the battery comparment.")
		update_icon()

/obj/item/weapon/inducer/attack_hand(mob/user)
	if(usr == user && opened && (!issilicon(user)))
		if(cell)
			user.put_in_hands(cell)
			cell.add_fingerprint(user)
			cell.updateicon()
			src.cell = null
			update_icon()
			user.visible_message("[user.name] removes the power cell from [src.name]!",\
								  "<span class='notice'>You remove the power cell.</span>")

/obj/item/weapon/inducer/examine(mob/living/M)
	..()
	if(cell)
		to_chat(M, "<span class='notice'>The [src]'s display shows: [src.cell.charge]W</span>")
	else
		to_chat(M,"<span class='notice'>The [src]'s display is dark.</span>")
	if(opened)
		to_chat(M,"<span class='notice'>The [src]'s battery compartment is open.</span>")

/obj/item/weapon/inducer/update_icon()
	if(!opened)
		icon_state = "inducer"
	else
		if(!cell)
			icon_state = "inducer-nobat"
		else
			icon_state = "inducer-bat"


