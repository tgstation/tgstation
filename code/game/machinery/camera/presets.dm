/**
 * Deconstructed Camera
 * Used by wallmounted cameras, starts off deconstructed and requires building by a player.
 */
/obj/machinery/camera/autoname/deconstructed
	icon_state = "camera_off"
	camera_construction_state = CAMERA_STATE_WRENCHED
	camera_enabled = FALSE

/**
 * EMP Proof
 * Starts off with the EMP protection upgrade, and can't start unactivated.
 */
/obj/machinery/camera/emp_proof
	start_active = TRUE

/obj/machinery/camera/emp_proof/Initialize(mapload)
	. = ..()
	upgradeEmpProof()

/**
 * Motion EMP proof
 * Same as EMP but also starts with motion upgrade.
 */
/obj/machinery/camera/emp_proof/motion/Initialize(mapload)
	. = ..()
	upgradeMotion()

/**
 * X-Ray Cameras
 * Starts off with x-ray, and can't start deactivated.
 */
/obj/machinery/camera/xray
	start_active = TRUE
	icon_state = "xraycamera" //mapping icon only

/obj/machinery/camera/xray/Initialize(mapload)
	. = ..()
	upgradeXRay()

/**
 * Motion camera
 * Starts off with the motion detector and can't be disablede on roundstart.
 */
/obj/machinery/camera/motion
	start_active = TRUE
	name = "motion-sensitive security camera"

/obj/machinery/camera/motion/Initialize(mapload)
	. = ..()
	upgradeMotion()

/**
 * All camera
 * Has all upgrades by default, can't be disabled roundstart.
 */
/obj/machinery/camera/all
	start_active = TRUE
	icon_state = "xraycamera" //mapping icon.

/obj/machinery/camera/all/Initialize(mapload)
	. = ..()
	upgradeEmpProof()
	upgradeXRay()
	upgradeMotion()

/**
 * Autonaming camera
 * Automatically names itself after the area it's in during post_machine_initialize,
 * good for mappers who don't want to manually name them all.
 */
/obj/machinery/camera/autoname
	var/number = 0 //camera number in area

/obj/machinery/camera/autoname/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/camera/autoname/post_machine_initialize()
	. = ..()
	var/static/list/autonames_in_areas = list()
	var/area/camera_area = get_area(src)
	number = autonames_in_areas[camera_area] + 1
	autonames_in_areas[camera_area] = number
	c_tag = "[format_text(camera_area.name)] #[number]"

/obj/machinery/camera/autoname/motion
	start_active = TRUE
	name = "motion-sensitive security camera"

/obj/machinery/camera/autoname/motion/Initialize(mapload)
	. = ..()
	upgradeMotion()

/**
 * Bomb preset
 * Can't be disabled, sees further, doesn't cost power, can be seen by ordnance
 * cameras, and is indestructible (so bomb-proof).
 */
/obj/machinery/camera/preset/ordnance
	name = "Hardened Bomb-Test Camera"
	desc = "A specially-reinforced camera with a long lasting battery, used to monitor the bomb testing site. An external light is attached to the top."
	c_tag = "Bomb Testing Site"
	network = list(CAMERANET_NETWORK_RD, CAMERANET_NETWORK_ORDNANCE)
	use_power = NO_POWER_USE //Test site is an unpowered area
	resistance_flags = parent_type::resistance_flags | INDESTRUCTIBLE
	light_range = 10
	start_active = TRUE

///The internal camera object for exosuits, applied by the camera upgrade
/obj/machinery/camera/exosuit
	c_tag = "Exosuit: unspecified"
	desc = "This camera belongs in a mecha. If you see this, tell a coder!"
	network = list(CAMERANET_NETWORK_SS13, CAMERANET_NETWORK_RD)
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
	return (camera_upgrade_bitflags & CAMERA_UPGRADE_EMP_PROOF) && (!(ignore_malf_upgrades && malf_emp_firmware_active))

/obj/machinery/camera/proc/upgradeEmpProof(malf_upgrade, ignore_malf_upgrades)
	if(isEmpProof(ignore_malf_upgrades)) //pass a malf upgrade to ignore_malf_upgrades so we can replace the malf module with the normal one
		return //that way if someone tries to upgrade an already malf-upgraded camera, it'll just upgrade it to a normal version.
	if(malf_upgrade)
		malf_emp_firmware_active = TRUE //don't add parts to drop, update icon, ect. reconstructing it will also retain the upgrade.
		malf_emp_firmware_present = TRUE //so the upgrade is retained after incompatible parts are removed.
		AddElement(/datum/element/empprotection, EMP_PROTECT_ALL|EMP_NO_EXAMINE)

	else if(!emp_module) //only happens via upgrading in camera/attackby()
		emp_module = new(src)
		malf_emp_firmware_active = FALSE //make it appear like it's just normally upgraded so the icons and examine texts are restored.
		AddElement(/datum/element/empprotection, EMP_PROTECT_ALL)

	camera_upgrade_bitflags |= CAMERA_UPGRADE_EMP_PROOF

/obj/machinery/camera/proc/removeEmpProof(ignore_malf_upgrades)
	if(ignore_malf_upgrades) //don't downgrade it if malf software is forced onto it.
		return
	RemoveElement(/datum/element/empprotection, EMP_PROTECT_ALL)
	RemoveElement(/datum/element/empprotection, EMP_PROTECT_ALL|EMP_NO_EXAMINE)
	camera_upgrade_bitflags &= ~CAMERA_UPGRADE_EMP_PROOF

/obj/machinery/camera/proc/isXRay(ignore_malf_upgrades)
	return (camera_upgrade_bitflags & CAMERA_UPGRADE_XRAY) && (!(ignore_malf_upgrades && malf_xray_firmware_active))

/obj/machinery/camera/proc/upgradeXRay(malf_upgrade, ignore_malf_upgrades)
	if(isXRay(ignore_malf_upgrades)) //pass a malf upgrade to ignore_malf_upgrades so we can replace the malf upgrade with the normal one
		return //that way if someone tries to upgrade an already malf-upgraded camera, it'll just upgrade it to a normal version.
	if(malf_upgrade)
		malf_xray_firmware_active = TRUE //don't add parts to drop, update icon, ect. reconstructing it will also retain the upgrade.
		malf_xray_firmware_present = TRUE //so the upgrade is retained after incompatible parts are removed.

	else if(!xray_module) //only happens via upgrading in camera/attackby()
		xray_module = new(src)
		if(malf_xray_firmware_active)
			malf_xray_firmware_active = FALSE //make it appear like it's just normally upgraded so the icons and examine texts are restored.

	camera_upgrade_bitflags |= CAMERA_UPGRADE_XRAY
	update_appearance()

/obj/machinery/camera/proc/removeXRay(ignore_malf_upgrades)
	if(!ignore_malf_upgrades) //don't downgrade it if malf software is forced onto it.
		camera_upgrade_bitflags &= ~CAMERA_UPGRADE_XRAY
	update_appearance()

/obj/machinery/camera/proc/isMotion()
	return camera_upgrade_bitflags & CAMERA_UPGRADE_MOTION

/obj/machinery/camera/proc/upgradeMotion()
	if(isMotion())
		return

	if(name == initial(name))
		name = "motion-sensitive security camera"
	if(!proximity_monitor)
		proximity_monitor = new(src)
	camera_upgrade_bitflags |= CAMERA_UPGRADE_MOTION
	create_prox_monitor()

/obj/machinery/camera/proc/removeMotion()
	if(name == "motion-sensitive security camera")
		name = "security camera"
	camera_upgrade_bitflags &= ~CAMERA_UPGRADE_MOTION
	if(!area_motion)
		QDEL_NULL(proximity_monitor)
