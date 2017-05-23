//Tool for recharging APCs, Borgs, Mechs, Space Heaters, Ninja Suits. SMES, energy guns, stun batons, etc. 
//Basically anything with a power-cell.

/obj/item/weapon/inducer
	name = "inducer"
	desc = "A tool for inductively charging internal power cells."
	cell_type = /obj/item/weapon/stock_parts/cell/high
	var/obj/item/weapon/stock_parts/cell/cell
	icon = null
	force = 7
	var/powertransfer = 1000
	var/emagged = FALSE
	var/opened = FALSE

/obj/item/weapon/inducer/Initialize()
	src.cell = new cell_type

/obj/item/weapon/inducer/proc/induce(/obj/item/weapon/stock_parts/cell/target)
	var/totransfer = max(cell.charge,powertransfer)
	var/transferred = target.give(totransfer)
	cell.use(transferred)

/obj/item/weapon/inducer/proc/induce(/obj/machinery/power/SMES/target)
	var/totransfer = max(cell.charge,powertransfer)
	target.charge = min(target.charge + totransfer, target.capacity)
	cell.use(totransfer)
	

/obj/item/weapon/inducer/Attack(/obj/target, /mob/user)
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
	
	if(istype(target,/obj/machinery/power/apc) | istype(target,/obj/machinery/space_heater) | istype(target,/obj/mecha) | istype(target, /obj/item/weapon/inducer))
		if (target == src)
			to_chat(user,"<span class='warning'> The [src] can't charge itself!)
			return
		visible_message("[user] starts charging the [target] with the [src]."
		if(do_after(user, 20, targets = target)
			if(target.cell.charge == target.cell.maxcharge)
				to_chat(user, "<span class='warning'> The [target] is fully charged!</span>"
				return
			induce(target.cell)
			visible_message("[user] recharges the [target]!")
			return

	if(istype(target,/obj/machinery/power/SMES)
		visible_message("[user] starts charging the [target] with the [src]."
		if(do_after(user, 20, targets = target)
		if(target.charge == target.capacity)
				to_chat(user, "<span class='warning'> The [target] is fully charged!</span>"
				return
			induce(target)
			visible_message("[user] recharges the [target]!")
			return

	if(istype(target,/obj/item/weapon/gun/energy)
		visible_message("[user] starts charging the [target] with the [src].
	 	if(do_after(user, 40, targets = target) //Recharging energy guns should be slower, probably.
			if(target.power_supply.charge == target.power_supply.maxcharge)
				to_chat(user, "<span class='warning'> The [target] is fully charged!</span>"
				return
			induce(target.power_supply)
			visible_message("[user] recharges the [target]!")
			return
	
	if(istype(target,/obj/item/clothing/suit/space/space_ninja)		
		visible_message("[user] starts charging the [target] with the [src].
		if(do_after(user, 40, targets = target) //Same with ninja suits.
			if(target.cell.charge == target.cell.maxcharge)
				to_chat(user, "<span class='warning'> The [target] is fully charged!</span>"
				return
			induce(target.cell)
			visible_message("[user] recharges the [target]!")
			return

	if(istype(target,/obj/item/weapon/melee/baton)
		visible_message("[user] starts charging the [target] with the [src].
		if(do_after(user, 40, targets = target)
			if(target.bcell.charge == target.bcell.maxcharge)
				to_chat(user, "<span class='warning'> The [target] is fully charged!</span>"
				return
			induce(target.bcell)
			visible_message("[user] recharges the [target]!")
			return
	
	
	if(istype(target, /obj/item/machinery/chem_dispenser)
		if(target.energy = target.max_energy)
			to_chat(user, "<span class='warning'> The [target] is fully charged!"
			return
		visible_message("[user] starts charging the [target] with the [src].")
		if(do_after(user, 20, targets = target)
			if(target.energy = target.max_energy)
				to_chat(user, "<span class='warning'> The [target] is fully charged!</span>"
				return
			target.energy += 10;
			cell.use(powertransfer)
			visible_message("[user] recharges the [target]!")
			return
	..()

	/obj/item/weapon/inducer/Attack(/mob/living/target, /mob/user)
	
	if(user.A_INTENT == INTENT_HARM)
		return ..()

	if(!user.isadvancedtooluser())
		to_chat(user, "<span class='warning'>you don't have the dexterity to use \the [src]!</span>")
		return


	if(!cell)
		to_chat(user, "<span class='warning'> The [src] doesn't have a power cell installed!</span>")
		return

	if(!cell.charge)
		to_chat(user, "<span class='warning'> The [src]'s battery is dead!</span>")
		return

	if(istype(target, /mob/living/silicon/robot)
		if(target.cell.charge == target.cell.maxcharge)
		visible_message("[user] starts charging [target]'s power cell with the [src]."
		if(do_after(user, 20, targets = target)
			if(target.cell.charge == target.cell.maxcharge)
				to_chat(user, "<span class='notice'>[target]'s power cell is fully charged!</span>"
				return
			induce(target.cell)
			visible_message("[user] recharges [target]'s power cell!")
			return
	..()

/obj/item/weapon/inducer/examine(/mob/user)
	..()
	to_chat(user, "The [src]'s display shows: [src.cell.charge]W")

