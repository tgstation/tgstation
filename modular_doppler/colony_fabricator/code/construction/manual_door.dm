/obj/structure/mineral_door/manual_colony_door
	name = "manual airlock"
	icon = 'modular_doppler/colony_fabricator/icons/doors/airlock_manual.dmi'
	material_flags = NONE
	icon_state = "manual"
	openSound = 'modular_doppler/colony_fabricator/sounds/manual_door/manual_door_open.wav'
	closeSound = 'modular_doppler/colony_fabricator/sounds/manual_door/manual_door_close.wav'
	/// What we disassemble into
	var/disassembled_type = /obj/item/flatpacked_machine/airlock_kit_manual
	/// How long it takes to open/close the door
	var/manual_actuation_delay = 1 SECONDS

/obj/structure/mineral_door/manual_colony_door/atom_deconstruct(disassembled = TRUE)
	if(disassembled)
		new disassembled_type(get_turf(src))

// Pickaxes won't dig these apart
/obj/structure/mineral_door/manual_colony_door/pickaxe_door(mob/living/user, obj/item/item_in_question)
	return

// These doors have a short do_after to check if you can open or close them
/obj/structure/mineral_door/manual_colony_door/TryToSwitchState(atom/user)
	if(isSwitchingStates || !anchored)
		return
	if(!do_after(user, manual_actuation_delay, src))
		return
	return ..()

// We don't care about being bumped, just a copy of the base bumped proc
/obj/structure/mineral_door/manual_colony_door/Bumped(atom/movable/bumped_atom)
	set waitfor = FALSE
	SEND_SIGNAL(src, COMSIG_ATOM_BUMPED, bumped_atom)

/obj/structure/mineral_door/manual_colony_door/Open()
	isSwitchingStates = TRUE
	playsound(src, openSound, 100, TRUE)
	set_opacity(FALSE)
	flick("[initial(icon_state)]opening",src)
	icon_state = "[initial(icon_state)]open"
	sleep(1 SECONDS)
	set_density(FALSE)
	door_opened = TRUE
	layer = OPEN_DOOR_LAYER
	air_update_turf(TRUE, FALSE)
	update_appearance()
	isSwitchingStates = FALSE

	if(close_delay != -1)
		addtimer(CALLBACK(src, PROC_REF(Close)), close_delay)

/obj/structure/mineral_door/manual_colony_door/Close()
	if(isSwitchingStates || !door_opened)
		return
	var/turf/T = get_turf(src)
	for(var/mob/living/L in T)
		return
	isSwitchingStates = TRUE
	playsound(src, closeSound, 100, TRUE)
	flick("[initial(icon_state)]closing",src)
	icon_state = initial(icon_state)
	sleep(1 SECONDS)
	set_density(TRUE)
	set_opacity(TRUE)
	door_opened = FALSE
	layer = initial(layer)
	air_update_turf(TRUE, TRUE)
	update_appearance()
	isSwitchingStates = FALSE

// Parts kit for putting the door together
/obj/item/flatpacked_machine/airlock_kit_manual
	name = "prefab manual airlock parts kit"
	icon = 'modular_doppler/colony_fabricator/icons/doors/packed.dmi'
	icon_state = "airlock_parts_manual"
	type_to_deploy = /obj/structure/mineral_door/manual_colony_door
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
	)
	w_class = WEIGHT_CLASS_NORMAL
