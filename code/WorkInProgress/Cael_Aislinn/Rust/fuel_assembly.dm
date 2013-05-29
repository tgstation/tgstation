
/obj/item/weapon/fuel_assembly
	icon = 'code/WorkInProgress/Cael_Aislinn/Rust/rust.dmi'
	icon_state = "fuel_assembly"
	name = "Fuel Rod Assembly"
	var/list/rod_quantities
	var/percent_depleted = 1
	layer = 3.1
	//
	New()
		rod_quantities = new/list

//these can be abstracted away for now
/*
/obj/item/weapon/fuel_rod
/obj/item/weapon/control_rod
*/
