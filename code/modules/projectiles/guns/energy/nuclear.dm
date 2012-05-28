/obj/item/weapon/gun/energy/gun
	icon_state = "energystun100"
	item_state = "energystun100"
	name = "energy gun"
	desc = "A basic energy-based gun with two settings: Stun and kill."
	fire_sound = 'Taser.ogg'

	charge_cost = 100 //How much energy is needed to fire.
	projectile_type = "/obj/item/projectile/energy/electrode"
	origin_tech = "combat=3;magnets=2"
	modifystate = "energystun"

	var/mode = 0 //0 = stun, 1 = kill


	attack_self(mob/living/user as mob)
		if(..())
			switch(mode)
				if(0)
					mode = 1
					charge_cost = 100
					fire_sound = 'Laser.ogg'
					user << "\red [src.name] is now set to kill."
					projectile_type = "/obj/item/projectile/beam"
					modifystate = "energykill"
				if(1)
					mode = 0
					charge_cost = 100
					fire_sound = 'Taser.ogg'
					user << "\red [src.name] is now set to stun."
					projectile_type = "/obj/item/projectile/energy/electrode"
					modifystate = "energystun"
			update_icon()
		return



/obj/item/weapon/gun/energy/gun/nuclear
	name = "\improper Advanced Energy Gun"
	desc = "An energy gun with an experimental miniaturized reactor."
	origin_tech = "combat=3;materials=5;powerstorage=3"
	var/lightfail = 0
	icon_state = "nucgun"
	item_state = "nucgun100"
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
		if((power_supply.charge / power_supply.maxcharge) != 1)
			if(!failcheck())	return 0
			power_supply.give(100)
			update_icon()
		return 1


	proc
		failcheck()
			lightfail = 0
			if (prob(src.reliability)) return 1 //No failure
			if (prob(src.reliability))
				for (var/mob/living/M in range(0,src)) //Only a minor failure, enjoy your radiation if you're in the same tile or carrying it
					if (src in M.contents)
						M << "\red Your gun feels pleasantly warm for a moment."
					else
						M << "\red You feel a warm sensation."
					M.apply_effect(rand(1,40), IRRADIATE)
				lightfail = 1
			else
				for (var/mob/living/M in range(rand(1,4),src)) //Big failure, TIME FOR RADIATION BITCHES
					if (src in M.contents)
						M << "\red Your gun's reactor overloads!"
					M << "\red You feel a wave of heat wash over you."
					M.apply_effect(100, IRRADIATE)
				crit_fail = 1 //break the gun so it stops recharging
				processing_objects.Remove(src)
				update_icon()
			return 0


		update_charge()
			if (crit_fail)
				overlays += "nucgun-whee"
				return
			var/ratio = power_supply.charge / power_supply.maxcharge
			ratio = round(ratio, 0.25) * 100
			overlays += text("nucgun-[]", ratio)


		update_reactor()
			if(crit_fail)
				overlays += "nucgun-crit"
				return
			if(lightfail)
				overlays += "nucgun-medium"
			else if ((power_supply.charge/power_supply.maxcharge) <= 0.5)
				overlays += "nucgun-light"
			else
				overlays += "nucgun-clean"


		update_mode()
			if (mode == 0)
				overlays += "nucgun-stun"
			else if (mode == 1)
				overlays += "nucgun-kill"


	emp_act(severity)
		..()
		reliability -= round(15/severity)


	update_icon()
		overlays = null
		update_charge()
		update_reactor()
		update_mode()
