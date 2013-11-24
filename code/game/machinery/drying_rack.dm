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
	var/list/accepted = list()

/obj/machinery/drying_rack/New()
	..()
	accepted = list(/obj/item/weapon/reagent_containers/food/snacks/grown/coffee_arabica,
	/obj/item/weapon/reagent_containers/food/snacks/grown/coffee_robusta,
	/obj/item/weapon/reagent_containers/food/snacks/grown/tobacco,
	/obj/item/weapon/reagent_containers/food/snacks/grown/tobacco_space,
	/obj/item/weapon/reagent_containers/food/snacks/grown/tea_aspera,
	/obj/item/weapon/reagent_containers/food/snacks/grown/tea_astra,
	/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
	/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiadeus)


/obj/machinery/drying_rack/attackby(var/obj/item/W as obj, var/mob/user as mob)
	if(is_type_in_list(W,accepted))
		if(W:dry == 0)
			var/J = W.type
			user << "You add the [W] to the drying rack."
			user.u_equip(W)
			del(W)
			user << "\red Please wait for the item to finish drying..."
			use_power = 2
			icon_state = "drying_rack_on"
			sleep(60)
			icon_state = "drying_rack"
			var/obj/item/weapon/reagent_containers/food/snacks/grown/D = new J(src.loc)
			user << "\blue You finish drying the [D]"
			D.icon_state = "[D.icon_state]_dry"
			D.dry = 1
			use_power = 1
			return
		else
			user << "\red That has already been dried!"
	else
		user << "\red You cannot add that to the drying rack."


