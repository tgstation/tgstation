
/obj/item/weapon/gun/energy/taser
	name = "taser gun"
	desc = "A small, low capacity gun used for non-lethal takedowns."
	icon_state = "taser"
	item_state = null	//so the human update icon uses the icon_state instead.
	ammo_type = list(/obj/item/ammo_casing/energy/electrode)
	cell_type = "/obj/item/weapon/cell/crap"

/obj/item/weapon/gun/energy/taser/cyborg
	name = "taser gun"
	desc = "A small, low capacity gun used for non-lethal takedowns."
	icon_state = "taser"
	fire_sound = 'sound/weapons/Taser.ogg'
	cell_type = "/obj/item/weapon/cell/secborg"
	var/charge_tick = 0
	var/recharge_time = 10 //Time it takes for shots to recharge (in ticks)

	New()
		..()
		processing_objects.Add(src)


	Del()
		processing_objects.Remove(src)
		..()

	process() //Every [recharge_time] ticks, recharge a shot for the cyborg
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


/obj/item/weapon/gun/energy/stunrevolver
	name = "stun revolver"
	desc = "A high-tech revolver that fires stun cartridges. The stun cartridges can be recharged using a conventional energy weapon recharger."
	icon_state = "stunrevolver"
	origin_tech = "combat=3;materials=3;powerstorage=2"
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/gun)
	cell_type = "/obj/item/weapon/cell"



/obj/item/weapon/gun/energy/crossbow
	name = "mini energy-crossbow"
	desc = "A weapon favored by many of the syndicates stealth specialists."
	icon_state = "crossbow"
	w_class = 2.0
	item_state = "crossbow"
	m_amt = 2000
	origin_tech = "combat=2;magnets=2;syndicate=5"
	silenced = 1
	ammo_type = list(/obj/item/ammo_casing/energy/bolt)
	cell_type = "/obj/item/weapon/cell/crap"
	var/charge_tick = 0


	New()
		..()
		processing_objects.Add(src)


	Del()
		processing_objects.Remove(src)
		..()


	process()
		charge_tick++
		if(charge_tick < 4) return 0
		charge_tick = 0
		if(!power_supply) return 0
		power_supply.give(100)
		return 1


	update_icon()
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
	name = "Energy Crossbow"
	desc = "A weapon favored by syndicate infiltration teams."
	w_class = 4.0
	force = 10
	m_amt = 200000
