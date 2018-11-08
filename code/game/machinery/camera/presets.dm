// PRESETS

// EMP
/obj/machinery/camera/emp_proof
	start_active = TRUE

/obj/machinery/camera/emp_proof/Initialize()
	. = ..()
	upgradeEmpProof()

// X-ray

/obj/machinery/camera/xray
	start_active = TRUE
	icon_state = "xraycamera" //mapping icon - Thanks to Krutchen for the icons.

/obj/machinery/camera/xray/Initialize()
	. = ..()
	upgradeXRay()

// MOTION
/obj/machinery/camera/motion
	start_active = TRUE
	name = "motion-sensitive security camera"

/obj/machinery/camera/motion/Initialize()
	. = ..()
	upgradeMotion()

// ALL UPGRADES
/obj/machinery/camera/all
	start_active = TRUE
	icon_state = "xraycamera" //mapping icon.

/obj/machinery/camera/all/Initialize()
	. = ..()
	upgradeEmpProof()
	upgradeXRay()
	upgradeMotion()

// AUTONAME

/obj/machinery/camera/autoname
	var/number = 0 //camera number in area

//This camera type automatically sets it's name to whatever the area that it's in is called.
/obj/machinery/camera/autoname/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/camera/autoname/LateInitialize()
	. = ..()
	number = 1
	var/area/A = get_area(src)
	if(A)
		for(var/obj/machinery/camera/autoname/C in GLOB.machines)
			if(C == src)
				continue
			var/area/CA = get_area(C)
			if(CA.type == A.type)
				if(C.number)
					number = max(number, C.number+1)
		c_tag = "[A.name] #[number]"


// UPGRADE PROCS

/obj/machinery/camera/proc/isEmpProof()
	return upgrades & CAMERA_UPGRADE_EMP_PROOF

/obj/machinery/camera/proc/upgradeEmpProof()
	if(isEmpProof())
		return
	emp_component = AddComponent(/datum/component/empprotection, EMP_PROTECT_SELF | EMP_PROTECT_WIRES | EMP_PROTECT_CONTENTS)
	if(!assembly.emp_module)
		assembly.emp_module = new(assembly)
	upgrades |= CAMERA_UPGRADE_EMP_PROOF

/obj/machinery/camera/proc/removeEmpProof()
	emp_component.RemoveComponent()
	upgrades &= ~CAMERA_UPGRADE_EMP_PROOF



/obj/machinery/camera/proc/isXRay()
	return upgrades & CAMERA_UPGRADE_XRAY

/obj/machinery/camera/proc/upgradeXRay()
	if(isXRay())
		return
	if(!assembly.xray_module)
		assembly.xray_module = new(assembly)
	upgrades |= CAMERA_UPGRADE_XRAY
	update_icon()

/obj/machinery/camera/proc/removeXRay()
	upgrades &= ~CAMERA_UPGRADE_XRAY
	update_icon()



/obj/machinery/camera/proc/isMotion()
	return upgrades & CAMERA_UPGRADE_MOTION

/obj/machinery/camera/proc/upgradeMotion()
	if(isMotion())
		return
	if(name == initial(name))
		name = "motion-sensitive security camera"
	if(!assembly.proxy_module)
		assembly.proxy_module = new(assembly)
	upgrades |= CAMERA_UPGRADE_MOTION

/obj/machinery/camera/proc/removeMotion()
	if(name == "motion-sensitive security camera")
		name = "security camera"
	upgrades &= ~CAMERA_UPGRADE_MOTION
