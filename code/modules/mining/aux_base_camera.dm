//Aux base construction console
/mob/camera/aiEye/remote/base_construction
	name = "construction holo-drone"
	move_on_shuttle = 1 //Allows any curious crew to watch the base after it leaves. (This is safe as the base cannot be modified once it leaves)
	icon = 'icons/obj/mining.dmi'
	icon_state = "construction_drone"
	var/area/starting_area

/mob/camera/aiEye/remote/base_construction/Initialize()
	. = ..()
	starting_area = get_area(loc)

/mob/camera/aiEye/remote/base_construction/setLoc(var/t)
	var/area/curr_area = get_area(t)
	if(curr_area == starting_area || istype(curr_area, /area/shuttle/auxillary_base))
		return ..()
	//While players are only allowed to build in the base area, but consoles starting outside the base can move into the base area to begin work.

/mob/camera/aiEye/remote/base_construction/relaymove(mob/user, direct)
	dir = direct //This camera eye is visible as a drone, and needs to keep the dir updated
	..()

/obj/item/construction/rcd/internal //Base console's internal RCD. Roundstart consoles are filled, rebuilt cosoles start empty.
	name = "internal RCD"
	max_matter = 600 //Bigger container and faster speeds due to being specialized and stationary.
	no_ammo_message = "<span class='warning'>Internal matter exhausted. Please add additional materials.</span>"
	delay_mod = 0.5

/obj/machinery/computer/camera_advanced/base_construction
	name = "base construction console"
	desc = "An industrial computer integrated with a camera-assisted rapid construction drone."
	networks = list("ss13")
	var/obj/item/construction/rcd/internal/RCD //Internal RCD. The computer passes user commands to this in order to avoid massive copypaste.
	circuit = /obj/item/circuitboard/computer/base_construction
	off_action = new/datum/action/innate/camera_off/base_construction
	jump_action = null
	var/datum/action/innate/aux_base/switch_mode/switch_mode_action = new //Action for switching the RCD's build modes
	var/datum/action/innate/aux_base/build/build_action = new //Action for using the RCD
	var/datum/action/innate/aux_base/airlock_type/airlock_mode_action = new //Action for setting the airlock type
	var/datum/action/innate/aux_base/window_type/window_action = new //Action for setting the window type
	var/datum/action/innate/aux_base/place_fan/fan_action = new //Action for spawning fans
	var/fans_remaining = 0 //Number of fans in stock.
	var/datum/action/innate/aux_base/install_turret/turret_action = new //Action for spawning turrets
	var/turret_stock = 0 //Turrets in stock
	var/obj/machinery/computer/auxillary_base/found_aux_console //Tracker for the Aux base console, so the eye can always find it.

	icon_screen = "mining"
	icon_keyboard = "rd_key"

	light_color = LIGHT_COLOR_PINK

/obj/machinery/computer/camera_advanced/base_construction/Initialize()
	. = ..()
	RCD = new(src)

/obj/machinery/computer/camera_advanced/base_construction/Initialize(mapload)
	. = ..()
	if(mapload) //Map spawned consoles have a filled RCD and stocked special structures
		RCD.matter = RCD.max_matter
		fans_remaining = 4
		turret_stock = 4

/obj/machinery/computer/camera_advanced/base_construction/CreateEye()

	var/spawn_spot
	for(var/obj/machinery/computer/auxillary_base/ABC in GLOB.machines)
		if(istype(get_area(ABC), /area/shuttle/auxillary_base))
			found_aux_console = ABC
			break

	if(found_aux_console)
		spawn_spot = found_aux_console
	else
		spawn_spot = src


	eyeobj = new /mob/camera/aiEye/remote/base_construction(get_turf(spawn_spot))
	eyeobj.origin = src


/obj/machinery/computer/camera_advanced/base_construction/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/rcd_ammo) || istype(W, /obj/item/stack/sheet))
		RCD.attackby(W, user, params) //If trying to feed the console more materials, pass it along to the RCD.
	else
		return ..()

/obj/machinery/computer/camera_advanced/base_construction/Destroy()
	qdel(RCD)
	return ..()

/obj/machinery/computer/camera_advanced/base_construction/GrantActions(mob/living/user)
	..()

	if(switch_mode_action)
		switch_mode_action.target = src
		switch_mode_action.Grant(user)
		actions += switch_mode_action

	if(build_action)
		build_action.target = src
		build_action.Grant(user)
		actions += build_action

	if(airlock_mode_action)
		airlock_mode_action.target = src
		airlock_mode_action.Grant(user)
		actions += airlock_mode_action

	if(window_action)
		window_action.target = src
		window_action.Grant(user)
		actions += window_action

	if(fan_action)
		fan_action.target = src
		fan_action.Grant(user)
		actions += fan_action

	if(turret_action)
		turret_action.target = src
		turret_action.Grant(user)
		actions += turret_action

	eyeobj.invisibility = 0 //When the eye is in use, make it visible to players so they know when someone is building.

/obj/machinery/computer/camera_advanced/base_construction/remove_eye_control(mob/living/user)
	..()
	eyeobj.invisibility = INVISIBILITY_MAXIMUM //Hide the eye when not in use.

/datum/action/innate/aux_base //Parent aux base action
	icon_icon = 'icons/mob/actions/actions_construction.dmi'
	var/mob/living/C //Mob using the action
	var/mob/camera/aiEye/remote/base_construction/remote_eye //Console's eye mob
	var/obj/machinery/computer/camera_advanced/base_construction/B //Console itself

/datum/action/innate/aux_base/Activate()
	if(!target)
		return TRUE
	C = owner
	remote_eye = C.remote_control
	B = target
	if(!B.RCD) //The console must always have an RCD.
		B.RCD = new /obj/item/construction/rcd/internal(src) //If the RCD is lost somehow, make a new (empty) one!

/datum/action/innate/aux_base/proc/check_spot()
//Check a loction to see if it is inside the aux base at the station. Camera visbility checks omitted so as to not hinder construction.
	var/turf/build_target = get_turf(remote_eye)
	var/area/build_area = get_area(build_target)

	if(!istype(build_area, /area/shuttle/auxillary_base))
		to_chat(owner, "<span class='warning'>You can only build within the mining base!</span>")
		return FALSE

	if(!is_station_level(build_target.z))
		to_chat(owner, "<span class='warning'>The mining base has launched and can no longer be modified.</span>")
		return FALSE

	return TRUE

/datum/action/innate/camera_off/base_construction
	name = "Log out"

//*******************FUNCTIONS*******************

/datum/action/innate/aux_base/build
	name = "Build"
	button_icon_state = "build"

/datum/action/innate/aux_base/build/Activate()
	if(..())
		return

	if(!check_spot())
		return


	var/atom/movable/rcd_target
	var/turf/target_turf = get_turf(remote_eye)

	//Find airlocks
	rcd_target = locate(/obj/machinery/door/airlock) in target_turf

	if(!rcd_target)
		rcd_target = locate (/obj/structure) in target_turf

	if(!rcd_target || !rcd_target.anchored)
		rcd_target = target_turf

	owner.changeNext_move(CLICK_CD_RANGE)
	B.RCD.afterattack(rcd_target, owner, TRUE) //Activate the RCD and force it to work remotely!
	playsound(target_turf, 'sound/items/deconstruct.ogg', 60, 1)

/datum/action/innate/aux_base/switch_mode
	name = "Switch Mode"
	button_icon_state = "builder_mode"

/datum/action/innate/aux_base/switch_mode/Activate()
	if(..())
		return

	var/list/buildlist = list("Walls and Floors" = 1,"Airlocks" = 2,"Deconstruction" = 3,"Windows and Grilles" = 4)
	var/buildmode = input("Set construction mode.", "Base Console", null) in buildlist
	B.RCD.mode = buildlist[buildmode]
	to_chat(owner, "Build mode is now [buildmode].")

/datum/action/innate/aux_base/airlock_type
	name = "Select Airlock Type"
	button_icon_state = "airlock_select"

datum/action/innate/aux_base/airlock_type/Activate()
	if(..())
		return

	B.RCD.change_airlock_setting()


datum/action/innate/aux_base/window_type
	name = "Select Window Type"
	button_icon_state = "window_select"

datum/action/innate/aux_base/window_type/Activate()
	if(..())
		return
	B.RCD.toggle_window_type()

datum/action/innate/aux_base/place_fan
	name = "Place Tiny Fan"
	button_icon_state = "build_fan"

datum/action/innate/aux_base/place_fan/Activate()
	if(..())
		return

	var/turf/fan_turf = get_turf(remote_eye)

	if(!B.fans_remaining)
		to_chat(owner, "<span class='warning'>[B] is out of fans!</span>")
		return

	if(!check_spot())
		return

	if(fan_turf.density)
		to_chat(owner, "<span class='warning'>Fans may only be placed on a floor.</span>")
		return

	new /obj/structure/fans/tiny(fan_turf)
	B.fans_remaining--
	to_chat(owner, "<span class='notice'>Tiny fan placed. [B.fans_remaining] remaining.</span>")
	playsound(fan_turf, 'sound/machines/click.ogg', 50, 1)

datum/action/innate/aux_base/install_turret
	name = "Install Plasma Anti-Wildlife Turret"
	button_icon_state = "build_turret"

datum/action/innate/aux_base/install_turret/Activate()
	if(..())
		return

	if(!check_spot())
		return

	if(!B.turret_stock)
		to_chat(owner, "<span class='warning'>Unable to construct additional turrets.</span>")
		return

	var/turf/turret_turf = get_turf(remote_eye)

	if(is_blocked_turf(turret_turf))
		to_chat(owner, "<span class='warning'>Location is obstructed by something. Please clear the location and try again.</span>")
		return

	var/obj/machinery/porta_turret/aux_base/T = new /obj/machinery/porta_turret/aux_base(turret_turf)
	if(B.found_aux_console)
		B.found_aux_console.turrets += T //Add new turret to the console's control

	B.turret_stock--
	to_chat(owner, "<span class='notice'>Turret installation complete!</span>")
	playsound(turret_turf, 'sound/items/drill_use.ogg', 65, 1)





/obj/item/circuitboard/computer/base_construction/arena
	name = "Arena Construction Board"
	desc = "Allows the construction of hazards in a specially designated arena."



/obj/machinery/computer/camera_advanced/arena_construction
	name = "arena construction console"
	desc = "Designed to maximize viewership. Ensure all participants have signed the omni-waiver."
	networks = list("arena")
	circuit = /obj/item/circuitboard/computer/base_construction/arena
	off_action = new/datum/action/innate/camera_off/base_construction
	jump_action = null
	var/list/hazards = list()
	var/datum/action/innate/arena_base/turfchange/lava/V = new
	var/datum/action/innate/arena_base/turfchange/ice/I = new
	var/datum/action/innate/arena_base/turfchange/slow/W = new
	var/datum/action/innate/arena_base/turfchange/fast/A = new
	var/datum/action/innate/arena_base/object/launcher/L = new
	var/datum/action/innate/arena_base/object/slip/S = new
	var/datum/action/innate/arena_base/object/freeze/Z = new
	var/datum/action/innate/arena_base/object/damage/D = new
	var/datum/action/innate/arena_base/object/fire/F = new
	var/datum/action/innate/arena_base/object/snare/N = new
	var/datum/action/innate/arena_base/object/emitter/E = new
	var/datum/action/innate/clear_hazards/H = new


//Aux base construction console
/mob/camera/aiEye/remote/arena_construction
	name = "arena holo-drone"
	icon = 'icons/obj/mining.dmi'
	icon_state = "construction_drone"
	use_static = FALSE
	var/area/starting_area

/mob/camera/aiEye/remote/arena_construction/Initialize()
	. = ..()
	starting_area = get_area(loc)

/mob/camera/aiEye/remote/arena_construction/setLoc(var/t)
	var/area/curr_area = get_area(t)
	if(curr_area == starting_area || istype(curr_area, /area/maintenance/arena))
		return ..()

/mob/camera/aiEye/remote/arena_construction/relaymove(mob/user, direct)
	dir = direct //This camera eye is visible as a drone, and needs to keep the dir updated
	..()

/obj/machinery/computer/camera_advanced/arena_construction/CreateEye()
	eyeobj = new /mob/camera/aiEye/remote/arena_construction(get_turf(src))
	eyeobj.origin = src

/obj/machinery/computer/camera_advanced/arena_construction/GrantActions(mob/living/user)
	..()
	if(V)
		V.target = src
		V.Grant(user)
		actions += V
	if(I)
		I.target = src
		I.Grant(user)
		actions += I
	if(W)
		W.target = src
		W.Grant(user)
		actions += W
	if(A)
		A.target = src
		A.Grant(user)
		actions += A
	if(L)
		L.target = src
		L.Grant(user)
		actions += L
	if(S)
		S.target = src
		S.Grant(user)
		actions += S
	if(Z)
		Z.target = src
		Z.Grant(user)
		actions += Z
	if(D)
		D.target = src
		D.Grant(user)
		actions += D
	if(F)
		F.target = src
		F.Grant(user)
		actions += F
	if(N)
		N.target = src
		N.Grant(user)
		actions += N
	if(E)
		E.target = src
		E.Grant(user)
		actions += E
	if(H)
		H.target = src
		H.Grant(user)
		actions += H
	eyeobj.invisibility = 0

/obj/machinery/computer/camera_advanced/arena_construction/remove_eye_control(mob/living/user)
	..()
	eyeobj.invisibility = INVISIBILITY_MAXIMUM //Hide the eye when not in use.

/datum/action/innate/arena_base//Parent for arena construction actions
	icon_icon = 'icons/mob/actions/actions_construction.dmi'
	var/mob/living/C //Mob using the action
	var/mob/camera/aiEye/remote/base_construction/remote_eye //Console's eye mob
	var/obj/machinery/computer/camera_advanced/arena_construction/comp //Console itself

/datum/action/innate/arena_base/Activate()
	if(!target)
		return FALSE
	C = owner
	remote_eye = C.remote_control
	comp = target
	if(!check_spot())
		return FALSE
	if(hazard_limited())
		return FALSE
	return TRUE

/datum/action/innate/arena_base/proc/check_spot()
	var/turf/build_target = get_turf(remote_eye)
	var/area/build_area = get_area(build_target)
	if(!istype(build_area, /area/maintenance/arena))
		to_chat(owner, "<span class='warning'>You can only build within the arena!</span>")
		return FALSE
	return TRUE

/datum/action/innate/arena_base/proc/hazard_limited()
	for(var/obj/O in comp.hazards)
		if(QDELETED(O))
			comp.hazards -= O
	if(LAZYLEN(comp.hazards) >= 12)
		to_chat(owner, "<span class='warning'>You have reached the arena's hazard limit - clear the previous hazards to create more!</span>")
		return TRUE
	return FALSE


datum/action/innate/arena_base/turfchange
	name = "Place Default Turf"
	button_icon_state = "build"
	var/turf_type = /turf/open/floor/plasteel/showroomfloor

datum/action/innate/arena_base/turfchange/Activate()
	. = ..()
	if(.)
		var/turf/T = get_turf(remote_eye)
		var/turf/open/Newt = T.ChangeTurf(turf_type, null, CHANGETURF_IGNORE_AIR)
		Newt.planetary_atmos = 0
		playsound(Newt, 'sound/machines/click.ogg', 50, 1)
		new /obj/effect/temp_visual/small_smoke(Newt)
		comp.hazards += Newt

datum/action/innate/arena_base/turfchange/lava
	name = "Place Lava"
	icon_icon = 'icons/turf/floors.dmi'
	button_icon_state = "lava"
	turf_type = /turf/open/lava/smooth

datum/action/innate/arena_base/turfchange/ice
	name = "Place Ice"
	icon_icon = 'icons/turf/snow.dmi'
	button_icon_state = "ice"
	turf_type = /turf/open/floor/plating/ice/smooth

datum/action/innate/arena_base/turfchange/slow
	name = "Place Slow Tile"
	icon_icon = 'icons/turf/floors.dmi'
	button_icon_state = "sepia"
	turf_type = /turf/open/floor/sepia/notile

datum/action/innate/arena_base/turfchange/fast
	name = "Place Speed Tile"
	icon_icon = 'icons/turf/floors.dmi'
	button_icon_state = "bluespace"
	turf_type = /turf/open/floor/bluespace/notile

datum/action/innate/arena_base/object
	name = "Place Object"
	button_icon_state = "build"
	var/obj_type = /obj/item

datum/action/innate/arena_base/object/Activate()
	. = ..()
	if(.)
		var/turf/T = get_turf(remote_eye)
		var/obj/O = new obj_type(T)
		O.dir = remote_eye.dir
		playsound(T, 'sound/machines/click.ogg', 50, 1)
		new /obj/effect/temp_visual/small_smoke(T)
		comp.hazards += O

datum/action/innate/arena_base/object/launcher
	name = "Place Atmos Launcher"
	icon_icon = 'icons/obj/atmospherics/pipes/disposal.dmi'
	button_icon_state = "intake"
	obj_type = /obj/machinery/disposal/deliveryChute

datum/action/innate/arena_base/object/slip
	name = "Place Oil Slick"
	icon_icon = 'icons/mob/robots.dmi'
	button_icon_state = "floor2"
	obj_type = /obj/effect/decal/cleanable/oil/slippery


datum/action/innate/arena_base/object/freeze
	name = "Place Freeze Trap"
	icon_icon = 'icons/obj/hand_of_god_structures.dmi'
	button_icon_state = "trap-frost"
	obj_type = /obj/structure/trap/chill

datum/action/innate/arena_base/object/damage
	name = "Place Damage Trap"
	icon_icon  = 'icons/obj/hand_of_god_structures.dmi'
	button_icon_state = "trap-earth"
	obj_type = /obj/structure/trap/damage

datum/action/innate/arena_base/object/fire
	name = "Place Fire Trap"
	icon_icon  = 'icons/obj/hand_of_god_structures.dmi'
	button_icon_state = "trap-fire"
	obj_type = /obj/structure/trap/fire

datum/action/innate/arena_base/object/snare
	name = "Place Energy Snare"
	icon_icon = 'icons/obj/items_and_weapons.dmi'
	button_icon_state  = "e_snare"
	obj_type = /obj/item/restraints/legcuffs/beartrap/energy/arena

/obj/item/restraints/legcuffs/beartrap/energy/arena/dissipate()
	return

datum/action/innate/arena_base/object/emitter
	name = "Place Emitter"
	icon_icon = 'icons/obj/singularity.dmi'
	button_icon_state = "emitter"
	obj_type = /obj/machinery/power/emitter/energycannon/arena

/obj/machinery/power/emitter/energycannon/arena
	projectile_type = /obj/item/projectile/beam/emitter/arena

/obj/item/projectile/beam/emitter/arena
	range = 5

datum/action/innate/clear_hazards
	name = "Clear Hazards"
	icon_icon = 'icons/mob/actions/actions_flightsuit.dmi'
	button_icon_state = "flightpack_airbrake"
	var/obj/machinery/computer/camera_advanced/arena_construction/comp //Console itself

/datum/action/innate/clear_hazards/Activate()
	if(!target)
		return FALSE
	comp = target
	for(var/A in comp.hazards)
		if(isturf(A))
			var/turf/T = A
			T.ChangeTurf(/turf/open/floor/plating)
		else
			qdel(A)
	comp.hazards = list()