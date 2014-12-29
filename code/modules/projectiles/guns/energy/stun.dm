
/obj/item/weapon/gun/energy/taser
	name = "taser gun"
	desc = "A low-capacity, energy-based stun gun used by security teams to subdue targets at range."
	icon_state = "taser"
	item_state = null	//so the human update icon uses the icon_state instead.
	ammo_type = list(/obj/item/ammo_casing/energy/electrode)
	cell_type = "/obj/item/weapon/stock_parts/cell/crap"

/obj/item/weapon/gun/energy/stunrevolver
	name = "stun revolver"
	desc = "A high-tech revolver that fires internal, reusable stun cartidges in a revolving cylinder."
	icon_state = "stunrevolver"
	origin_tech = "combat=3;materials=3;powerstorage=2"
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/gun)
	cell_type = "/obj/item/weapon/stock_parts/cell"

/obj/item/weapon/gun/energy/gun/advtaser
	name = "advanced taser"
	desc = "A hybrid taser designed to fire both short-range high-power electrodes and long-range disabler beams."
	icon_state = "advtaser"
	ammo_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/disabler)
	cell_type = "/obj/item/weapon/stock_parts/cell/crap"
	origin_tech = null

/obj/item/weapon/gun/energy/gun/advtaser/cyborg
	name = "advanced taser"
	desc = "An integrated advanced taser that draws directly from a cyborg's power cell. The weapon contains a limiter to prevent the cyborg's power cell from overheating."
	cell_type = "/obj/item/weapon/stock_parts/cell/secborg"
	var/charge_tick = 0
	var/recharge_time = 10

/obj/item/weapon/gun/energy/gun/advtaser/cyborg/New()
	..()
	processing_objects.Add(src)


/obj/item/weapon/gun/energy/gun/advtaser/cyborg/Destroy()
	processing_objects.Remove(src)
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


/obj/item/weapon/gun/energy/crossbow
	name = "mini energy crossbow"
	desc = "A weapon favored by syndicate stealth specialists."
	icon_state = "crossbow"
	item_state = "crossbow"
	w_class = 2.0
	m_amt = 2000
	origin_tech = "combat=2;magnets=2;syndicate=5"
	suppressed = 1
	ammo_type = list(/obj/item/ammo_casing/energy/bolt)
	cell_type = "/obj/item/weapon/stock_parts/cell/crap"
	var/charge_tick = 0


/obj/item/weapon/gun/energy/crossbow/New()
	..()
	processing_objects.Add(src)


/obj/item/weapon/gun/energy/crossbow/Destroy()
	processing_objects.Remove(src)
	..()


/obj/item/weapon/gun/energy/crossbow/process()
	charge_tick++
	if(charge_tick < 4) return 0
	charge_tick = 0
	if(!power_supply) return 0
	power_supply.give(100)
	return 1


/obj/item/weapon/gun/energy/crossbow/update_icon()
	return

/obj/item/weapon/gun/energy/crossbow/cyborg/newshot()
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select] //Necessary to find cost of shot
			if(R.cell.use(shot.e_cost))
				chambered = shot
				chambered.newshot()
	return

/obj/item/weapon/gun/energy/crossbow/largecrossbow
	name = "energy crossbow"
	desc = "A weapon favored by syndicate carp hunters."
	icon_state = "crossbowlarge"
	w_class = 3.0
	force = 10
	m_amt = 4000
	suppressed = 0