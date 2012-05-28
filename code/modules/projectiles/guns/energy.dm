/obj/item/weapon/gun/energy
	icon_state = "energy"
	name = "energy gun"
	desc = "A basic energy-based gun."
	fire_sound = 'Taser.ogg'

	var/obj/item/weapon/cell/power_supply //What type of power cell this uses
	var/charge_cost = 100 //How much energy is needed to fire.
	var/cell_type = "/obj/item/weapon/cell"
	var/projectile_type = "/obj/item/projectile/energy"
	var/modifystate

	emp_act(severity)
		power_supply.use(round(power_supply.maxcharge / severity))
		update_icon()
		..()


	New()
		..()
		if(cell_type)
			power_supply = new cell_type(src)
		else
			power_supply = new(src)
		power_supply.give(power_supply.maxcharge)
		return


	load_into_chamber()
		if(in_chamber)
			if(!istype(in_chamber, projectile_type))
				del(in_chamber)
				in_chamber = new projectile_type(src)
			return 1
		if(!power_supply)	return 0
		if(!power_supply.use(charge_cost))	return 0
		if(!projectile_type)	return 0
		in_chamber = new projectile_type(src)
		return 1


	update_icon()
		var/ratio = power_supply.charge / power_supply.maxcharge
		ratio = round(ratio, 0.25) * 100
		if(modifystate)
			icon_state = text("[][]", modifystate, ratio)
		else
			icon_state = text("[][]", initial(icon_state), ratio)



