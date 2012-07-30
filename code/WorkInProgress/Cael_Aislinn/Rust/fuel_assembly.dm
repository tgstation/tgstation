
/obj/item/weapon/fuel_assembly
	icon = 'fuel_assembly.dmi'
	icon_state = "fuel_assembly"
	name = "Fuel Rod Assembly"
	var/list/rod_quantities
	var/percent_depleted = 0
	//
	New()
		rod_quantities = new/list

//these can be abstracted away for now
/*
/obj/item/weapon/fuel_rod
/obj/item/weapon/control_rod
*/
