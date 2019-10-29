
/obj/item/borg/upgrade/circuit_app/proc/upgrade_engiborg_manipulator(mob/living/silicon/robot/R, mob/user)

	var/obj/item/borg/apparatus/circuit/basic/C = locate() in R.module.modules
	if(C) //Delete the basic manipulator if we have it
		qdel(C)

	var/obj/item/borg/apparatus/circuit/advanced/A
	A = new(R.module) //Add advanced manipulator
	R.module.basic_modules += A
	R.module.add_module(A, FALSE, TRUE)


/obj/item/borg/upgrade/circuit_app/proc/remove_engiborg_manipulator_upgrade(mob/living/silicon/robot/R, mob/user)

	var/obj/item/borg/apparatus/circuit/advanced/C = locate() in R.module.modules
	if(C)
		R.module.remove_module(C, TRUE)

		var/obj/item/borg/apparatus/circuit/basic/B //Re-add the basic manipulator
		B = new(R.module)
		R.module.basic_modules += B
		R.module.add_module(B, FALSE, TRUE)