/obj/machinery/drying_rack
	name = "drying rack"
	desc = "A large rack with a heater built into the base. Used for drying things out."
	icon = 'icons/obj/hydroponics.dmi'
	icon_state = "drying_rack"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 50
	var/running = 0
	var/volume = 100

/obj/machinery/drying_rack/New()
	..()
	flags |= NOREACT
	create_reagents(volume)


/obj/machinery/drying_rack/attackby(var/obj/item/I as obj, var/mob/user as mob)
	if(running)
		user << "\red Please wait until the last item has dried."
		return
	if(!istype(I,/obj/item/weapon/reagent_containers/food/snacks))
		user << "\red You cannot add that to the drying rack."
		return
	var/obj/item/weapon/reagent_containers/food/snacks/S = I
	if(!S.dried_type)
		user << "\red You cannot add that to the drying rack."
		return
	if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/grown))
		var/obj/item/weapon/reagent_containers/food/snacks/grown/plant = I
		var/resulttype = plant.dried_type
		if(ispath(resulttype,/obj/item/weapon/reagent_containers/food/snacks/grown))
			if(plant.dry == 0)
				plant.reagents.trans_to(src, plant.reagents.total_volume)
				user.u_equip(I)
				user << "You add the [I] to the drying rack."
				del(I)
				src.running = 1
				use_power = 2
				icon_state = "drying_rack_on"
				sleep(60)
				icon_state = "drying_rack"
				var/obj/item/weapon/reagent_containers/food/snacks/grown/result = new resulttype(src.loc)
				user << "\blue The [result] has finished drying."
				result.icon_state = "[result.icon_state]_dry"
				result.dry = 1
				result.reagents.clear_reagents()
				src.reagents.trans_to(result, src.reagents.total_volume)
				use_power = 1
				src.running = 0
				return
			else
				user << "\red That has already been dried."

	var/snacktype = S.dried_type
	user.u_equip(I)
	user << "You add the [I] to the drying rack."
	del(I)
	src.running = 1
	use_power = 2
	icon_state = "drying_rack_on"
	sleep(60)
	icon_state = "drying_rack"
	new snacktype(src.loc)
	use_power = 1
	src.running = 0
