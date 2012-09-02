/obj/machinery/camera/emp_proof/New()
	..()
	assembly.upgrades.Add(new /obj/item/stack/sheet/plasma(assembly))

/obj/machinery/camera/xray/New()
	..()
	assembly.upgrades.Add(new /obj/item/weapon/reagent_containers/food/snacks/grown/carrot(assembly))

/obj/machinery/camera/proc/isEmpProof()
	var/O = locate(/obj/item/stack/sheet/plasma) in assembly.upgrades
	return O

/obj/machinery/camera/proc/isXRay()
	var/O = locate(/obj/item/weapon/reagent_containers/food/snacks/grown/carrot) in assembly.upgrades
	return O

/obj/machinery/camera/all/New()
	..()
	assembly.upgrades.Add(new /obj/item/stack/sheet/plasma(assembly),
	new /obj/item/weapon/reagent_containers/food/snacks/grown/carrot(assembly),
	new /obj/item/device/assembly/prox_sensor(assembly))