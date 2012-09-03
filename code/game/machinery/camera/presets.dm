// PRESETS

/obj/machinery/camera/emp_proof/New()
	..()
	upgradeEmpProof()

/obj/machinery/camera/xray/New()
	..()
	upgradeXRay()

/obj/machinery/camera/motion/New()
	..()
	upgradeMotion()

/obj/machinery/camera/all/New()
	..()
	upgradeEmpProof()
	upgradeXRay()
	upgradeMotion()

// CHECKS

/obj/machinery/camera/proc/isEmpProof()
	var/O = locate(/obj/item/stack/sheet/plasma) in assembly.upgrades
	return O

/obj/machinery/camera/proc/isXRay()
	var/O = locate(/obj/item/weapon/reagent_containers/food/snacks/grown/carrot) in assembly.upgrades
	return O

/obj/machinery/camera/proc/isMotion()
	var/O = locate(/obj/item/device/assembly/prox_sensor) in assembly.upgrades
	return O

// UPGRADE PROCS

/obj/machinery/camera/proc/upgradeEmpProof()
	assembly.upgrades.Add(new /obj/item/stack/sheet/plasma(assembly))

/obj/machinery/camera/proc/upgradeXRay()
	assembly.upgrades.Add(new /obj/item/weapon/reagent_containers/food/snacks/grown/carrot(assembly))

// If you are upgrading Motion, and it isn't in the camera's New(), add it to the machines list.
/obj/machinery/camera/proc/upgradeMotion()
	assembly.upgrades.Add(new /obj/item/device/assembly/prox_sensor(assembly))