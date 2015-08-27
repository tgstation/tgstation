// PRESETS

// EMP

/obj/machinery/camera/emp_proof/New()
	..()
	upgradeEmpProof()

// X-RAY

/obj/machinery/camera/xray/New()
	..()
	upgradeXRay()
	update_icon()

// MOTION

/obj/machinery/camera/motion/New()
	..()
	upgradeMotion()

// HEARING

/obj/machinery/camera/hearing/New()
	..()
	upgradeHearing()

// ALL UPGRADES

/obj/machinery/camera/all/New()
	..()
	upgradeEmpProof()
	upgradeXRay()
	upgradeMotion()
	upgradeHearing()
	update_icon()

// AUTONAME

/obj/machinery/camera/autoname
	var/number = 0 //camera number in area

//This camera type automatically sets it's name to whatever the area that it's in is called.
/obj/machinery/camera/autoname/New()
	..()
	spawn(10)
		number = 1
		var/area/A = get_area(src)
		if(A)
			for(var/obj/machinery/camera/autoname/C in cameranet.cameras)
				if(C == src) continue
				var/area/CA = get_area(C)
				if(CA.type == A.type)
					if(C.number)
						number = max(number, C.number+1)
			c_tag = "[A.name] #[number]"


// CHECKS

/obj/machinery/camera/proc/isEmpProof()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/machinery/camera/proc/isEmpProof() called tick#: [world.time]")
	var/O = locate(/obj/item/stack/sheet/mineral/plasma) in assembly.upgrades
	return O

/obj/machinery/camera/proc/isXRay()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/machinery/camera/proc/isXRay() called tick#: [world.time]")
	var/O = locate(/obj/item/weapon/reagent_containers/food/snacks/grown/carrot) in assembly.upgrades
	return O

/obj/machinery/camera/proc/isMotion()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/machinery/camera/proc/isMotion() called tick#: [world.time]")
	var/O = locate(/obj/item/device/assembly/prox_sensor) in assembly.upgrades
	return O

/obj/machinery/camera/proc/isHearing()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/machinery/camera/proc/isMotion() called tick#: [world.time]")
	var/O = locate(/obj/item/device/assembly/voice) in assembly.upgrades
	return O

// UPGRADE PROCS

/obj/machinery/camera/proc/upgradeEmpProof()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/machinery/camera/proc/upgradeEmpProof() called tick#: [world.time]")
	assembly.upgrades.Add(new /obj/item/stack/sheet/mineral/plasma(assembly))

/obj/machinery/camera/proc/upgradeXRay()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/machinery/camera/proc/upgradeXRay() called tick#: [world.time]")
	assembly.upgrades.Add(new /obj/item/weapon/reagent_containers/food/snacks/grown/carrot(assembly))

// If you are upgrading Motion, and it isn't in the camera's New(), add it to the machines list.
/obj/machinery/camera/proc/upgradeMotion()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/machinery/camera/proc/upgradeMotion() called tick#: [world.time]")
	assembly.upgrades.Add(new /obj/item/device/assembly/prox_sensor(assembly))

/obj/machinery/camera/proc/upgradeHearing()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/machinery/camera/proc/isMotion() called tick#: [world.time]")
	assembly.upgrades.Add(new /obj/item/device/assembly/voice(assembly))
	update_hear()
