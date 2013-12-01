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
	var/running = 0
	var/volume = 100

/obj/machinery/drying_rack/New()
        ..()
        flags |= NOREACT
        create_reagents(volume)
        accepted = list(/obj/item/weapon/reagent_containers/food/snacks/grown/coffee_arabica,
        /obj/item/weapon/reagent_containers/food/snacks/grown/coffee_robusta,
        /obj/item/weapon/reagent_containers/food/snacks/grown/tobacco,
        /obj/item/weapon/reagent_containers/food/snacks/grown/tobacco_space,
        /obj/item/weapon/reagent_containers/food/snacks/grown/tea_aspera,
        /obj/item/weapon/reagent_containers/food/snacks/grown/tea_astra,
        /obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris,
        /obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiadeus,
        /obj/item/weapon/reagent_containers/food/snacks/meat,
        /obj/item/weapon/reagent_containers/food/snacks/grown/grapes,
        /obj/item/weapon/reagent_containers/food/snacks/grown/greengrapes,
        /obj/item/weapon/reagent_containers/food/snacks/grown/corn,
        /obj/item/weapon/reagent_containers/food/snacks/grown/cherries,
        /obj/item/weapon/reagent_containers/food/snacks/grown/poppy,
        /obj/item/weapon/reagent_containers/food/snacks/grown/harebell,
        /obj/item/weapon/reagent_containers/food/snacks/grown/potato,
        /obj/item/weapon/reagent_containers/food/snacks/grown/cabbage,
        /obj/item/weapon/reagent_containers/food/snacks/grown/berries,
        /obj/item/weapon/reagent_containers/food/snacks/grown/glowberries,
        /obj/item/weapon/reagent_containers/food/snacks/grown/cocoapod,
        /obj/item/weapon/reagent_containers/food/snacks/grown/sugarcane,
        /obj/item/weapon/reagent_containers/food/snacks/grown/poisonberries,
        /obj/item/weapon/reagent_containers/food/snacks/grown/deathberries,
        /obj/item/weapon/reagent_containers/food/snacks/grown/apple,
        /obj/item/weapon/reagent_containers/food/snacks/grown/apple/poisoned,
        /obj/item/weapon/reagent_containers/food/snacks/grown/goldapple,
        /obj/item/weapon/reagent_containers/food/snacks/grown/watermelon,
        /obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin,
        /obj/item/weapon/reagent_containers/food/snacks/grown/lime,
        /obj/item/weapon/reagent_containers/food/snacks/grown/lemon,
        /obj/item/weapon/reagent_containers/food/snacks/grown/orange,
        /obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet,
        /obj/item/weapon/reagent_containers/food/snacks/grown/banana,
        /obj/item/weapon/reagent_containers/food/snacks/grown/chili,
        /obj/item/weapon/reagent_containers/food/snacks/grown/ghost_chilli,
        /obj/item/weapon/reagent_containers/food/snacks/grown/eggplant,
        /obj/item/weapon/reagent_containers/food/snacks/grown/soybeans,
        /obj/item/weapon/reagent_containers/food/snacks/grown/koibeans,
        /obj/item/weapon/reagent_containers/food/snacks/grown/tomato,
        /obj/item/weapon/reagent_containers/food/snacks/grown/bloodtomato,
        /obj/item/weapon/reagent_containers/food/snacks/grown/bluetomato,
        /obj/item/weapon/reagent_containers/food/snacks/grown/wheat,
        /obj/item/weapon/reagent_containers/food/snacks/grown/icepepper,
        /obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
        /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/reishi,
        /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita,
        /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/angel,
        /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap,
        /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet,
        /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle,
        /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom,
        /obj/item/weapon/reagent_containers/food/snacks/grown/bluespacetomato
        )



/obj/machinery/drying_rack/attackby(var/obj/item/W as obj, var/mob/user as mob)
	if(is_type_in_list(W,accepted))
		if(!running)
			if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/meat))
				user.u_equip(W)
				del(W)
				user << "You add the meat to the drying rack."
				src.running = 1
				use_power = 2
				icon_state = "drying_rack_on"
				sleep(60)
				icon_state = "drying_rack"
				new /obj/item/weapon/reagent_containers/food/snacks/sosjerky(src.loc)
				use_power = 1
				src.running = 0
				return
			if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/grown/grapes))
				user.u_equip(W)
				del(W)
				user << "You add the grapes to the drying rack."
				src.running = 1
				use_power = 2
				icon_state = "drying_rack_on"
				sleep(60)
				icon_state = "drying_rack"
				new /obj/item/weapon/reagent_containers/food/snacks/no_raisin(src.loc)
				use_power = 1
				src.running = 0
				return
			if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/grown/greengrapes))
				user.u_equip(W)
				del(W)
				user << "You add the green grapes to the drying rack."
				src.running = 1
				use_power = 2
				icon_state = "drying_rack_on"
				sleep(60)
				icon_state = "drying_rack"
				new /obj/item/weapon/reagent_containers/food/snacks/no_raisin(src.loc)
				use_power = 1
				src.running = 0
				return
			else
				if(W:dry == 0)
					var/J = W.type
					var/obj/item/weapon/reagent_containers/food/snacks/grown/B = W
					B.reagents.trans_to(src, B.reagents.total_volume)
					user << "You add the [W] to the drying rack."
					user.u_equip(W)
					del(W)
					src.running = 1
					use_power = 2
					icon_state = "drying_rack_on"
					sleep(60)
					icon_state = "drying_rack"
					var/obj/item/weapon/reagent_containers/food/snacks/grown/D = new J(src.loc)
					user << "\blue You finish drying the [D]"
					D.icon_state = "[D.icon_state]_dry"
					D.dry = 1
					D.reagents.remove_any(50)
					src.reagents.trans_to(D, src.reagents.total_volume)
					use_power = 1
					src.running = 0
					return
				else
					user << "\red That has already been dried!"
		else
			user << "\red Please wait until the last item has dried."
	else
		user << "\red You cannot add that to the drying rack."
