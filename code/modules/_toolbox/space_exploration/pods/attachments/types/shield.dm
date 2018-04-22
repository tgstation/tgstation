/obj/item/pod_attachment

	shield/
		icon_state = "attachment_shields"
		var/max_absorbtion_amount = 25
		var/power_usage_multiplier = 20
		power_usage = 10
		power_usage_condition = P_ATTACHMENT_USAGE_ONTICK
		var/absorb_sound = 'sound/toolbox/shield_absorb.ogg'
		active = P_ATTACHMENT_INACTIVE

		GetAdditionalMenuData()
			var/dat = "Absorbing a maximum of [max_absorbtion_amount] damage.<br>"
			dat += "Uses [power_usage * power_usage_multiplier] for each absorb."
			return dat

		GetAvailableKeybinds()
			return list()

		proc/Absorb(var/damage = 0)
			if(active & P_ATTACHMENT_INACTIVE)
				return 0

			if(!damage)
				return 0

			if(damage <= max_absorbtion_amount)
				var/power = power_usage * power_usage_multiplier
				if(attached_to.HasPower(power))
					attached_to.UsePower(power)

					spawn(-1)
						playsound(get_turf(src), absorb_sound, 200, 0, 0)

					attached_to.PrintSystemNotice("Shield absorbed hit.")

					return 1

			return 0

		plasma/
			name = "plasma shield"
			max_absorbtion_amount = 10
			power_usage = 2
			construction_cost = list("metal" = 4000, "plasma" = 4000)
			//origin_tech = "magnets=2;powerstorage=2;materials=2"

		neutron/
			name = "neutron shield"
			max_absorbtion_amount = 20
			power_usage = 4
			construction_cost = list("metal" = 4000, "silver" = 4000, "gold" = 2000)
			//origin_tech = "magnets=3;powerstorage=3;materials=3"

		higgs_boson/
			name = "higgs-boson shield"
			max_absorbtion_amount = 30
			power_usage = 16
			construction_cost = list("metal" = 4000, "uranium" = 4000, "diamond" = 2500)
			//origin_tech = "magnets=4;powerstorage=4;materials=5"

		antimatter/
			name = "antimatter shield"
			max_absorbtion_amount = 40
			power_usage = 64
			construction_cost = list("metal" = 4000, "uranium" = 6000, "diamond" = 4500, "gold" = 4500)
			//origin_tech = "magnets=5;powerstorage=5;materials=6"
