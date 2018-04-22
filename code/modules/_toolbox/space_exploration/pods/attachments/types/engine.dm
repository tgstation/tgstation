/obj/item/pod_attachment

	engine/
		name = "pod engine"
		hardpoint_slot = P_HARDPOINT_ENGINE
		var/power_per_fuel = 1000
		var/fuel_type = /obj/item/stack/sheet/mineral/plasma
		var/burn_time = 250
		var/last_burn_time = 0
		var/pod_move_reduction = 0
		//origin_tech = "powerstorage=1"

		GetAvailableKeybinds()
			return list()

		GetAdditionalMenuData()
			var/dat = "Generating [power_per_fuel]W every [burn_time / 10] seconds."
			if(active & P_ATTACHMENT_ACTIVE)
				dat += "<br>"
				dat += "Next generation in [CLAMP(round(((last_burn_time + burn_time) - world.time) / 10), 0, INFINITY)] seconds."
			return dat

		PodProcess(var/obj/pod/pod)
			..()

			if((last_burn_time + burn_time) > world.time)
				return 0

			if(!pod.power_source)
				return 0

			var/obj/item/pod_attachment/cargo/cargo_hold = pod.GetAttachmentOnHardpoint(P_HARDPOINT_CARGO_HOLD)
			if(!cargo_hold)
				return 0

			var/list/fuel_list = cargo_hold.GetListFromType(fuel_type, 1)
			if(!fuel_list || !length(fuel_list))
				return 0

			var/combined_amount = 0
			for(var/obj/item/stack/sheet/fuel in fuel_list)
				combined_amount += fuel.amount
				qdel(fuel)

			if(combined_amount <= 0)
				return 0

			var/obj/item/stack/sheet/fuel = new fuel_type(get_turf(src))
			fuel.amount = combined_amount

			if(pod.AddPower(power_per_fuel))
				fuel.use(1)
				last_burn_time = world.time

			if(fuel.amount > 0)
				cargo_hold.PlaceInto(fuel, 1)

		New()
			..()
			var/obj/item/stack/sheet/mineral/fuel = new fuel_type()
			desc = "Uses [fuel.name] sheets."

			qdel(fuel)

		plasma/
			name = "plasma engine"
			construction_cost = list("metal" = 4000)

			advanced/
				name = "advanced plasma engine"
				burn_time = 200
				pod_move_reduction = -0.2
				construction_cost = list("metal" = 4000, "silver" = 2500, "gold" = 2500)
				//origin_tech = "powerstorage=4;materials=4"

		uranium/
			name = "uranium engine"
			fuel_type = /obj/item/stack/sheet/mineral/uranium
			power_per_fuel = 2500
			burn_time = 600
			construction_cost = list("metal" = 4000)

			advanced/
				name = "advanced uranium engine"
				burn_time = 400
				pod_move_reduction = -0.2
				construction_cost = list("metal" = 4000, "silver" = 2500, "gold" = 2500)
				//origin_tech = "powerstorage=4;materials=4"

		wood/
			name = "wooden engine"
			fuel_type = /obj/item/stack/sheet/mineral/wood
			power_per_fuel = 200
			burn_time = 50
			construction_cost = list("metal" = 4000)

			advanced/
				name = "advanced wooden engine"
				burn_time = 30
				pod_move_reduction = -0.2
				construction_cost = list("metal" = 4000, "silver" = 2500, "gold" = 2500)
				//origin_tech = "powerstorage=4;materials=4"
