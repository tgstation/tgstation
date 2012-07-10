/obj/item/weapon/grenade/mustardbomb
	desc = "It is set to detonate in 4 seconds."
	name = "mustard gas bomb"
	icon = 'grenade.dmi'
	icon_state = "flashbang"
	det_time = 40.0
	item_state = "flashbang"
	var/datum/effect/effect/system/mustard_gas_spread/mustard_gas

	New()
		..()
		src.mustard_gas = new /datum/effect/effect/system/mustard_gas_spread
		src.mustard_gas.attach(src)
		src.mustard_gas.set_up(5, 0, usr.loc)

	prime()
		playsound(src.loc, 'smoke.ogg', 50, 1, -3)
		spawn(0)
			src.mustard_gas.start()
			sleep(10)
			src.mustard_gas.start()
			sleep(10)
			src.mustard_gas.start()
			sleep(10)
			src.mustard_gas.start()
		for(var/obj/effect/blob/B in view(8,src))
			var/damage = round(30/(get_dist(B,src)+1))
			B.health -= damage
			B.update_icon()
		sleep(100)
		del(src)
		return
