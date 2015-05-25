
/obj/item/weapon/gun/energy/taser
	name = "taser gun"
	desc = "A low-capacity, energy-based stun gun used by security teams to subdue targets at range."
	icon_state = "taser"
	item_state = null	//so the human update icon uses the icon_state instead.
	ammo_type = list(/obj/item/ammo_casing/energy/electrode)

/obj/item/weapon/gun/energy/stunrevolver
	name = "stun revolver"
	desc = "A high-tech revolver that fires internal, reusable taser cartridges in a revolving cylinder. The cartridges can be recharged using conventional rechargers."
	icon_state = "stunrevolver"
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/gun)
	can_flashlight = 0
	pin = null

/obj/item/weapon/gun/energy/gun/advtaser
	name = "hybrid taser"
	desc = "A dual-mode taser designed to fire both short-range high-power electrodes and long-range disabler beams."
	icon_state = "advtaser"
	ammo_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/disabler)
	origin_tech = null

/obj/item/weapon/gun/energy/gun/advtaser/cyborg
	name = "cyborg taser"
	desc = "An integrated hybrid taser that draws directly from a cyborg's power cell. The weapon contains a limiter to prevent the cyborg's power cell from overheating."
	var/charge_tick = 0
	var/recharge_time = 10
	can_flashlight = 0

/obj/item/weapon/gun/energy/gun/advtaser/cyborg/New()
	..()
	SSobj.processing |= src


/obj/item/weapon/gun/energy/gun/advtaser/cyborg/Destroy()
	SSobj.processing.Remove(src)
	..()

/obj/item/weapon/gun/energy/gun/advtaser/cyborg/process() //Every [recharge_time] ticks, recharge a shot for the cyborg
	charge_tick++
	if(charge_tick < recharge_time) return 0
	charge_tick = 0

	if(!power_supply) return 0 //sanity
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select] //Necessary to find cost of shot
			if(R.cell.use(shot.e_cost)) 		//Take power from the borg...
				power_supply.give(shot.e_cost)	//... to recharge the shot

	update_icon()
	return 1
