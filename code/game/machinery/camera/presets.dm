// PRESETS

// EMP
/obj/machinery/camera/emp_proof
	start_active = TRUE

/obj/machinery/camera/emp_proof/Initialize(mapload)
	. = ..()
	upgradeEmpProof()

// EMP + Motion

/obj/machinery/camera/emp_proof/motion/Initialize(mapload)
	. = ..()
	upgradeMotion()

// X-ray

/obj/machinery/camera/xray
	start_active = TRUE
	icon_state = "xraycamera" //mapping icon - Thanks to Krutchen for the icons.

/obj/machinery/camera/xray/Initialize(mapload)
	. = ..()
	upgradeXRay()

// MOTION
/obj/machinery/camera/motion
	start_active = TRUE
	name = "motion-sensitive security camera"

/obj/machinery/camera/motion/Initialize(mapload)
	. = ..()
	upgradeMotion()

// ALL UPGRADES
/obj/machinery/camera/all
	start_active = TRUE
	icon_state = "xraycamera" //mapping icon.

/obj/machinery/camera/all/Initialize(mapload)
	. = ..()
	upgradeEmpProof()
	upgradeXRay()
	upgradeMotion()

// AUTONAME

/obj/machinery/camera/autoname
	var/number = 0 //camera number in area

//This camera type automatically sets it's name to whatever the area that it's in is called.
/obj/machinery/camera/autoname/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/camera/autoname/LateInitialize()
	. = ..()

	var/static/list/autonames_in_areas = list()

	var/area/camera_area = get_area(src)

	number = autonames_in_areas[camera_area] + 1
	autonames_in_areas[camera_area] = number

	c_tag = "[format_text(camera_area.name)] #[number]"

///The internal camera object for exosuits, applied by the camera upgrade
/obj/machinery/camera/exosuit
	c_tag = "Exosuit: unspecified"
	desc = "This camera belongs in a mecha. If you see this, tell a coder!"
	network = list("ss13", "rd")
	short_range = 1 //used when the camera gets EMPd
	///Number of the camera and thus the name of the mech
	var/number = 0
	///Currently used name of the mech
	var/current_name = null
	///Whether the camera was recently affected by an EMP and is thus unfocused, shortening view_range
	var/is_emp_scrambled = FALSE

///Restore the camera's view default view range after an EMP
/obj/machinery/camera/exosuit/proc/emp_refocus(obj/vehicle/sealed/mecha/our_chassis)
	is_emp_scrambled = FALSE
	setViewRange(initial(view_range))
	our_chassis.diag_hud_set_camera()

///Updates the c_tag of the mech camera while preventing duplicate c_tag usage due to having mechs with the same name
/obj/machinery/camera/exosuit/proc/update_c_tag(obj/vehicle/sealed/mecha/mech)
	//List of all used mech names
	var/static/list/existing_mech_names = list()
	//Name of the mech passed with this proc. We use format_text to wipe away stuff like `\initial` to prevent c_tag from erroring out
	var/mech_name = format_text(mech.name)

	if(current_name && current_name != mech_name) //decrease by 1 to preserve correct naming numeration
		existing_mech_names[current_name] -= 1
	number = existing_mech_names[mech_name] + 1
	existing_mech_names[mech_name] = number

	c_tag = "Exosuit: [mech_name] #[number]"
	current_name = mech_name

// UPGRADE PROCS

/obj/machinery/camera/proc/isEmpProof(ignore_malf_upgrades)
	var/obj/structure/camera_assembly/assembly = assembly_ref?.resolve()
	return (upgrades & CAMERA_UPGRADE_EMP_PROOF) && (!(ignore_malf_upgrades && assembly?.malf_emp_firmware_active))

/obj/machinery/camera/proc/upgradeEmpProof(malf_upgrade, ignore_malf_upgrades)
	if(isEmpProof(ignore_malf_upgrades)) //pass a malf upgrade to ignore_malf_upgrades so we can replace the malf module with the normal one
		return //that way if someone tries to upgrade an already malf-upgraded camera, it'll just upgrade it to a normal version.
	AddElement(/datum/element/empprotection, EMP_PROTECT_SELF | EMP_PROTECT_WIRES | EMP_PROTECT_CONTENTS)
	var/obj/structure/camera_assembly/assembly = assembly_ref?.resolve()
	if(malf_upgrade)
		assembly.malf_emp_firmware_active = TRUE //don't add parts to drop, update icon, ect. reconstructing it will also retain the upgrade.
		assembly.malf_emp_firmware_present = TRUE //so the upgrade is retained after incompatible parts are removed.

	else if(!assembly.emp_module) //only happens via upgrading in camera/attackby()
		assembly.emp_module = new(assembly)
		if(assembly.malf_emp_firmware_active)
			assembly.malf_emp_firmware_active = FALSE //make it appear like it's just normally upgraded so the icons and examine texts are restored.

	upgrades |= CAMERA_UPGRADE_EMP_PROOF

/obj/machinery/camera/proc/removeEmpProof(ignore_malf_upgrades)
	if(ignore_malf_upgrades) //don't downgrade it if malf software is forced onto it.
		return
	RemoveElement(/datum/element/empprotection, EMP_PROTECT_SELF | EMP_PROTECT_WIRES | EMP_PROTECT_CONTENTS)
	upgrades &= ~CAMERA_UPGRADE_EMP_PROOF



/obj/machinery/camera/proc/isXRay(ignore_malf_upgrades)
	var/obj/structure/camera_assembly/assembly = assembly_ref?.resolve()
	return (upgrades & CAMERA_UPGRADE_XRAY) && (!(ignore_malf_upgrades && assembly.malf_xray_firmware_active))

/obj/machinery/camera/proc/upgradeXRay(malf_upgrade, ignore_malf_upgrades)
	if(isXRay(ignore_malf_upgrades)) //pass a malf upgrade to ignore_malf_upgrades so we can replace the malf upgrade with the normal one
		return //that way if someone tries to upgrade an already malf-upgraded camera, it'll just upgrade it to a normal version.
	var/obj/structure/camera_assembly/assembly = assembly_ref?.resolve()
	if(malf_upgrade)
		assembly.malf_xray_firmware_active = TRUE //don't add parts to drop, update icon, ect. reconstructing it will also retain the upgrade.
		assembly.malf_xray_firmware_present = TRUE //so the upgrade is retained after incompatible parts are removed.

	else if(!assembly.xray_module) //only happens via upgrading in camera/attackby()
		assembly.xray_module = new(assembly)
		if(assembly.malf_xray_firmware_active)
			assembly.malf_xray_firmware_active = FALSE //make it appear like it's just normally upgraded so the icons and examine texts are restored.

	upgrades |= CAMERA_UPGRADE_XRAY
	update_appearance()

/obj/machinery/camera/proc/removeXRay(ignore_malf_upgrades)
	if(!ignore_malf_upgrades) //don't downgrade it if malf software is forced onto it.
		upgrades &= ~CAMERA_UPGRADE_XRAY
	update_appearance()



/obj/machinery/camera/proc/isMotion()
	return upgrades & CAMERA_UPGRADE_MOTION

/obj/machinery/camera/proc/upgradeMotion()
	if(isMotion())
		return
	var/obj/structure/camera_assembly/assembly = assembly_ref?.resolve()

	if(name == initial(name))
		name = "motion-sensitive security camera"
	if(!assembly.proxy_module)
		assembly.proxy_module = new(assembly)
	upgrades |= CAMERA_UPGRADE_MOTION
	create_prox_monitor()

/obj/machinery/camera/proc/removeMotion()
	if(name == "motion-sensitive security camera")
		name = "security camera"
	upgrades &= ~CAMERA_UPGRADE_MOTION
	if(!area_motion)
		QDEL_NULL(proximity_monitor)
