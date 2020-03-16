/obj/machinery/hazmat/emitter
	name = "emitter"
	desc = "An emitter for the hazmat system. This one is labelled #420."
	icon_state = "emitter_1"
	var/emitter_number = 1
	var/obj/item/crystal/my_crystal

/obj/machinery/hazmat/emitter/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	fire_laser(TRUE)
	say("Emitting test laser.")

/obj/machinery/hazmat/emitter/proc/fire_laser(is_testfire = TRUE)
	for(var/obj/machinery/hazmat/anomalous_material/AM in view())
		var/obj/projectile/crystal/P = new projectile_type(src.loc)
		P.firer = src
		P.preparePixelProjectile(AM, src)
		P.icon_state = "crystal_[my_crystal.crystal_shape]"
		P.color = my_crystal.color
		switch(my_crystal.crystal_size)
			if(CRYSTAL_SIZE_SMALL)
				P.transform *= 0.5
			if(CRYSTAL_SIZE_LARGE)
				P.transform *= 2
		P.crystal_size = my_crystal.crystal_size
		P.crystal_shape = my_crystal.crystal_shape
		P.crystal_color = my_crystal.crystal_color
		P.is_test_fire = is_testfire
		P.fire()