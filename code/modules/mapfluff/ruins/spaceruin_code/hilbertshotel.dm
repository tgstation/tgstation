GLOBAL_VAR_INIT(hhStorageTurf, null)
GLOBAL_VAR_INIT(hhMysteryRoomNumber, rand(1, 999999))

/obj/item/hilbertshotel
	name = "Hilbert's Hotel"
	desc = "A sphere of what appears to be an intricate network of bluespace. Observing it in detail seems to give you a headache as you try to comprehend the infinite amount of infinitesimally distinct points on its surface."
	icon = 'icons/obj/structures.dmi'
	icon_state = "hilbertshotel"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/datum/map_template/hilbertshotel/hotelRoomTemp
	var/datum/map_template/hilbertshotel/empty/hotelRoomTempEmpty
	var/datum/map_template/hilbertshotel/lore/hotelRoomTempLore
	var/list/activeRooms = list()
	var/list/storedRooms = list()
	var/storageTurf
	//Lore Stuff
	var/ruinSpawned = FALSE

/obj/item/hilbertshotel/Initialize(mapload)
	. = ..()
	//Load templates
	INVOKE_ASYNC(src, PROC_REF(prepare_rooms))

/obj/item/hilbertshotel/proc/prepare_rooms()
	hotelRoomTemp = new()
	hotelRoomTempEmpty = new()
	hotelRoomTempLore = new()
	var/area/currentArea = get_area(src)
	if(currentArea.type == /area/ruin/space/has_grav/powered/hilbertresearchfacility/secretroom)
		ruinSpawned = TRUE

/obj/item/hilbertshotel/Destroy()
	ejectRooms()
	return ..()

/obj/item/hilbertshotel/attack(mob/living/M, mob/living/user)
	if(M.mind)
		to_chat(user, span_notice("You invite [M] to the hotel."))
		promptAndCheckIn(user, M)
	else
		to_chat(user, span_warning("[M] is not intelligent enough to understand how to use this device!"))

/obj/item/hilbertshotel/attack_self(mob/user)
	. = ..()
	promptAndCheckIn(user, user)

/obj/item/hilbertshotel/attack_tk(mob/user)
	to_chat(user, span_notice("\The [src] actively rejects your mind as the bluespace energies surrounding it disrupt your telekinesis."))
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/item/hilbertshotel/proc/promptAndCheckIn(mob/user, mob/target)
	var/chosenRoomNumber

	// Input text changes depending on if you're using this in yourself or someone else.
	if(user == target)
		chosenRoomNumber = input(target, "What number room will you be checking into?", "Room Number") as null|num
	else
		chosenRoomNumber = input(target, "[user] is inviting you to enter \the [src]. What number room will you be checking into?", "Room Number") as null|num

	if(!chosenRoomNumber)
		return
	if(chosenRoomNumber > SHORT_REAL_LIMIT)
		to_chat(target, span_warning("You have to check out the first [SHORT_REAL_LIMIT] rooms before you can go to a higher numbered one!"))
		return
	if((chosenRoomNumber < 1) || (chosenRoomNumber != round(chosenRoomNumber)))
		to_chat(target, span_warning("That is not a valid room number!"))
		return

	// Orb is not adjacent to the target. No teleporties.
	if(!src.Adjacent(target))
		to_chat(target, span_warning("You too far away from \the [src] to enter it!"))

	// If the target is incapacitated after selecting a room, they're not allowed to teleport.
	if(target.incapacitated())
		to_chat(target, span_warning("You aren't able to activate \the [src] anymore!"))

	// Has the user thrown it away or otherwise disposed of it such that it's no longer in their hands or in some storage connected to them?
	if(!(get_atom_on_turf(src, /mob) == user))
		if(user == target)
			to_chat(user, span_warning("\The [src] is no longer in your possession!"))
		else
			to_chat(target, span_warning("\The [src] is no longer in the possession of [user]!"))
		return

	// If the player is using it on themselves, we've got some logic to deal with.
	// The user should drop the item before teleporting, but we're not going to force the item to be dropped if it can't be done normally...
	if(user == target)
		// The item should be on the user or in the user's inventory somewhere.
		// However, if they're not holding it, it may be in a pocket? In a backpack? Who knows! Still, they can't just drop it to the floor anymore...
		if(!user.get_held_index_of_item(src))
			to_chat(user, span_warning("You try to drop \the [src], but it's too late! It's no longer in your hands! Prepare for unforeseen consequences..."))
		// Okay, so they HAVE to be holding it here, because it's in their hand from the above check. Try to drop the item and if it fails, oh dear...
		else if(!user.dropItemToGround(src))
			to_chat(user, span_warning("You can't seem to drop \the [src]! It must be stuck to your hand somehow! Prepare for unforeseen consequences..."))

	if(!storageTurf) //Blame subsystems for not allowing this to be in Initialize
		if(!GLOB.hhStorageTurf)
			var/datum/map_template/hilbertshotelstorage/storageTemp = new()
			var/datum/turf_reservation/storageReservation = SSmapping.request_turf_block_reservation(1, 1, 1)
			var/turf/storage_turf = storageReservation.bottom_left_turfs[1]
			storageTemp.load(storage_turf)
			GLOB.hhStorageTurf = storage_turf
		else
			storageTurf = GLOB.hhStorageTurf
	if(tryActiveRoom(chosenRoomNumber, target))
		return
	if(tryStoredRoom(chosenRoomNumber, target))
		return
	sendToNewRoom(chosenRoomNumber, target)

/obj/item/hilbertshotel/proc/tryActiveRoom(roomNumber, mob/user)
	if(activeRooms["[roomNumber]"])
		var/datum/turf_reservation/roomReservation = activeRooms["[roomNumber]"]
		do_sparks(3, FALSE, get_turf(user))
		var/turf/room_bottom_left = roomReservation.bottom_left_turfs[1]
		user.forceMove(locate(
			room_bottom_left.x + hotelRoomTemp.landingZoneRelativeX,
			room_bottom_left.y + hotelRoomTemp.landingZoneRelativeY,
			room_bottom_left.z,
		))
		return TRUE
	return FALSE

/obj/item/hilbertshotel/proc/tryStoredRoom(roomNumber, mob/user)
	if(storedRooms["[roomNumber]"])
		var/datum/turf_reservation/roomReservation = SSmapping.request_turf_block_reservation(hotelRoomTemp.width, hotelRoomTemp.height, 1)
		var/turf/room_turf = roomReservation.bottom_left_turfs[1]
		hotelRoomTempEmpty.load(room_turf)
		var/turfNumber = 1
		for(var/x in 0 to hotelRoomTemp.width-1)
			for(var/y in 0 to hotelRoomTemp.height-1)
				for(var/atom/movable/A in storedRooms["[roomNumber]"][turfNumber])
					if(istype(A.loc, /obj/item/abstracthotelstorage))//Don't want to recall something thats been moved
						A.forceMove(locate(
							room_turf.x + x,
							room_turf.y + y,
							room_turf.z,
						))
				turfNumber++
		for(var/obj/item/abstracthotelstorage/S in storageTurf)
			if((S.roomNumber == roomNumber) && (S.parentSphere == src))
				qdel(S)
		storedRooms -= "[roomNumber]"
		activeRooms["[roomNumber]"] = roomReservation
		linkTurfs(roomReservation, roomNumber)
		do_sparks(3, FALSE, get_turf(user))
		user.forceMove(locate(
			room_turf.x + hotelRoomTemp.landingZoneRelativeX,
			room_turf.y + hotelRoomTemp.landingZoneRelativeY,
			room_turf.z,
		))
		return TRUE
	return FALSE

/obj/item/hilbertshotel/proc/sendToNewRoom(roomNumber, mob/user)
	var/datum/turf_reservation/roomReservation = SSmapping.request_turf_block_reservation(hotelRoomTemp.width, hotelRoomTemp.height, 1)
	var/turf/bottom_left = roomReservation.bottom_left_turfs[1]
	var/datum/map_template/load_from = hotelRoomTemp

	if(ruinSpawned && roomNumber == GLOB.hhMysteryRoomNumber)
		load_from = hotelRoomTempLore

	load_from.load(bottom_left)
	activeRooms["[roomNumber]"] = roomReservation
	linkTurfs(roomReservation, roomNumber)
	do_sparks(3, FALSE, get_turf(user))
	user.forceMove(locate(
		bottom_left.x + hotelRoomTemp.landingZoneRelativeX,
		bottom_left.y + hotelRoomTemp.landingZoneRelativeY,
		bottom_left.z,
	))

/obj/item/hilbertshotel/proc/linkTurfs(datum/turf_reservation/currentReservation, currentRoomnumber)
	var/turf/room_bottom_left = currentReservation.bottom_left_turfs[1]
	var/area/misc/hilbertshotel/currentArea = get_area(room_bottom_left)
	currentArea.name = "Hilbert's Hotel Room [currentRoomnumber]"
	currentArea.parentSphere = src
	currentArea.storageTurf = storageTurf
	currentArea.roomnumber = currentRoomnumber
	currentArea.reservation = currentReservation
	for(var/turf/closed/indestructible/hoteldoor/door in currentArea)
		door.parentSphere = src
		door.desc = "The door to this hotel room. The placard reads 'Room [currentRoomnumber]'. Strangely, this door doesn't even seem openable. The doorknob, however, seems to buzz with unusual energy...<br />[span_info("Alt-Click to look through the peephole.")]"
	for(var/turf/open/space/bluespace/BSturf in currentArea)
		BSturf.parentSphere = src

/obj/item/hilbertshotel/proc/ejectRooms()
	if(activeRooms.len)
		for(var/x in activeRooms)
			var/datum/turf_reservation/room = activeRooms[x]
			var/turf/room_bottom_left = room.bottom_left_turfs[1]
			for(var/i in 0 to hotelRoomTemp.width-1)
				for(var/j in 0 to hotelRoomTemp.height-1)
					for(var/atom/movable/A in locate(room_bottom_left.x + i, room_bottom_left.y + j, room_bottom_left.z))
						if(ismob(A))
							var/mob/M = A
							if(M.mind)
								to_chat(M, span_warning("As the sphere breaks apart, you're suddenly ejected into the depths of space!"))
						var/max = world.maxx-TRANSITIONEDGE
						var/min = 1+TRANSITIONEDGE
						var/list/possible_transtitons = list()
						for(var/AZ in SSmapping.z_list)
							var/datum/space_level/D = AZ
							if (D.linkage == CROSSLINKED)
								possible_transtitons += D.z_value
						var/_z = pick(possible_transtitons)
						var/_x = rand(min,max)
						var/_y = rand(min,max)
						var/turf/T = locate(_x, _y, _z)
						A.forceMove(T)
			qdel(room)

	if(storedRooms.len)
		for(var/x in storedRooms)
			var/list/atomList = storedRooms[x]
			for(var/atom/movable/A in atomList)
				var/max = world.maxx-TRANSITIONEDGE
				var/min = 1+TRANSITIONEDGE
				var/list/possible_transtitons = list()
				for(var/AZ in SSmapping.z_list)
					var/datum/space_level/D = AZ
					if (D.linkage == CROSSLINKED)
						possible_transtitons += D.z_value
				var/_z = pick(possible_transtitons)
				var/_x = rand(min,max)
				var/_y = rand(min,max)
				var/turf/T = locate(_x, _y, _z)
				A.forceMove(T)

//Template Stuff
/datum/map_template/hilbertshotel
	name = "Hilbert's Hotel Room"
	mappath = "_maps/templates/hilbertshotel.dmm"
	var/landingZoneRelativeX = 2
	var/landingZoneRelativeY = 8

/datum/map_template/hilbertshotel/empty
	name = "Empty Hilbert's Hotel Room"
	mappath = "_maps/templates/hilbertshotelempty.dmm"

/datum/map_template/hilbertshotel/lore
	name = "Doctor Hilbert's Deathbed"
	mappath = "_maps/templates/hilbertshotellore.dmm"

/datum/map_template/hilbertshotelstorage
	name = "Hilbert's Hotel Storage"
	mappath = "_maps/templates/hilbertshotelstorage.dmm"


//Turfs and Areas
/turf/closed/indestructible/hotelwall
	name = "hotel wall"
	desc = "A wall designed to protect the security of the hotel's guests."
	icon_state = "hotelwall"
	smoothing_groups = SMOOTH_GROUP_CLOSED_TURFS + SMOOTH_GROUP_HOTEL_WALLS
	canSmoothWith = SMOOTH_GROUP_HOTEL_WALLS
	explosive_resistance = INFINITY

/turf/open/indestructible/hotelwood
	desc = "Stylish dark wood with extra reinforcement. Secured firmly to the floor to prevent tampering."
	icon_state = "wood"
	footstep = FOOTSTEP_WOOD
	tiled_dirt = FALSE

/turf/open/indestructible/hoteltile
	desc = "Smooth tile with extra reinforcement. Secured firmly to the floor to prevent tampering."
	icon_state = "showroomfloor"
	footstep = FOOTSTEP_FLOOR
	tiled_dirt = FALSE

/turf/open/space/bluespace
	name = "\proper bluespace hyperzone"
	icon_state = "bluespace"
	base_icon_state = "bluespace"
	baseturfs = /turf/open/space/bluespace
	turf_flags = NOJAUNT
	explosive_resistance = INFINITY
	var/obj/item/hilbertshotel/parentSphere

/turf/open/space/bluespace/Initialize(mapload)
	. = ..()
	update_icon_state()

/turf/open/space/bluespace/update_icon_state()
	icon_state = base_icon_state
	return ..()

/turf/open/space/bluespace/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(parentSphere && arrived.forceMove(get_turf(parentSphere)))
		do_sparks(3, FALSE, get_turf(arrived))

/turf/closed/indestructible/hoteldoor
	name = "Hotel Door"
	icon_state = "hoteldoor"
	explosive_resistance = INFINITY
	var/obj/item/hilbertshotel/parentSphere

/turf/closed/indestructible/hoteldoor/proc/promptExit(mob/living/user)
	if(!isliving(user))
		return
	if(!user.mind)
		return
	if(!parentSphere)
		to_chat(user, span_warning("The door seems to be malfunctioning and refuses to operate!"))
		return
	if(tgui_alert(user, "Hilbert's Hotel would like to remind you that while we will do everything we can to protect the belongings you leave behind, we make no guarantees of their safety while you're gone, especially that of the health of any living creatures. With that in mind, are you ready to leave?", "Exit", list("Leave", "Stay")) == "Leave")
		if(HAS_TRAIT(user, TRAIT_IMMOBILIZED) || (get_dist(get_turf(src), get_turf(user)) > 1)) //no teleporting around if they're dead or moved away during the prompt.
			return
		user.forceMove(get_turf(parentSphere))
		do_sparks(3, FALSE, get_turf(user))

/turf/closed/indestructible/hoteldoor/attack_ghost(mob/dead/observer/user)
	if(!isobserver(user) || !parentSphere)
		return ..()
	user.forceMove(get_turf(parentSphere))

//If only this could be simplified...
/turf/closed/indestructible/hoteldoor/attack_tk(mob/user)
	return //need to be close.

/turf/closed/indestructible/hoteldoor/attack_hand(mob/user, list/modifiers)
	promptExit(user)

/turf/closed/indestructible/hoteldoor/attack_animal(mob/user, list/modifiers)
	promptExit(user)

/turf/closed/indestructible/hoteldoor/attack_paw(mob/user, list/modifiers)
	promptExit(user)

/turf/closed/indestructible/hoteldoor/attack_hulk(mob/living/carbon/human/user)
	promptExit(user)

/turf/closed/indestructible/hoteldoor/attack_larva(mob/user, list/modifiers)
	promptExit(user)

/turf/closed/indestructible/hoteldoor/attack_slime(mob/user, list/modifiers)
	promptExit(user)

/turf/closed/indestructible/hoteldoor/attack_robot(mob/user)
	if(get_dist(get_turf(src), get_turf(user)) <= 1)
		promptExit(user)

/turf/closed/indestructible/hoteldoor/AltClick(mob/user)
	. = ..()
	if(get_dist(get_turf(src), get_turf(user)) <= 1)
		to_chat(user, span_notice("You peak through the door's bluespace peephole..."))
		user.reset_perspective(parentSphere)
		var/datum/action/peephole_cancel/PHC = new
		user.overlay_fullscreen("remote_view", /atom/movable/screen/fullscreen/impaired, 1)
		PHC.Grant(user)
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/atom/, check_eye), user)

/turf/closed/indestructible/hoteldoor/check_eye(mob/user)
	if(get_dist(get_turf(src), get_turf(user)) >= 2)
		for(var/datum/action/peephole_cancel/PHC in user.actions)
			INVOKE_ASYNC(PHC, TYPE_PROC_REF(/datum/action/peephole_cancel, Trigger))

/datum/action/peephole_cancel
	name = "Cancel View"
	desc = "Stop looking through the bluespace peephole."
	button_icon_state = "cancel_peephole"

/datum/action/peephole_cancel/Trigger(trigger_flags)
	. = ..()
	to_chat(owner, span_warning("You move away from the peephole."))
	owner.reset_perspective()
	owner.clear_fullscreen("remote_view", 0)
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
	qdel(src)

// Despite using the ruins.dmi, hilbertshotel is not a ruin
/area/misc/hilbertshotel
	name = "Hilbert's Hotel Room"
	icon = 'icons/area/areas_ruins.dmi'
	icon_state = "hilbertshotel"
	requires_power = FALSE
	has_gravity = TRUE
	area_flags = NOTELEPORT | HIDDEN_AREA
	static_lighting = TRUE
	ambientsounds = list('sound/ambience/servicebell.ogg')
	var/roomnumber = 0
	var/obj/item/hilbertshotel/parentSphere
	var/datum/turf_reservation/reservation
	var/turf/storageTurf

/area/misc/hilbertshotel/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(istype(arrived, /obj/item/hilbertshotel))
		relocate(arrived)
	var/list/obj/item/hilbertshotel/hotels = arrived.get_all_contents_type(/obj/item/hilbertshotel)
	for(var/obj/item/hilbertshotel/H in hotels)
		if(parentSphere == H)
			relocate(H)

/area/misc/hilbertshotel/proc/relocate(obj/item/hilbertshotel/H)
	if(prob(0.135685)) //Because screw you
		qdel(H)
		return

	// Prepare for...
	var/mob/living/unforeseen_consequences = get_atom_on_turf(H, /mob/living)

	// Turns out giving anyone who grabs a Hilbert's Hotel a free, complementary warp whistle is probably bad.
	// Let's gib the last person to have selected a room number in it.
	if(unforeseen_consequences)
		to_chat(unforeseen_consequences, span_warning("\The [H] starts to resonate. Forcing it to enter itself induces a bluespace paradox, violently tearing your body apart."))
		unforeseen_consequences.investigate_log("has been gibbed by using [H] while inside of it.", INVESTIGATE_DEATHS)
		unforeseen_consequences.gib(DROP_ALL_REMAINS)

	var/turf/targetturf = find_safe_turf()
	if(!targetturf)
		if(GLOB.blobstart.len > 0)
			targetturf = get_turf(pick(GLOB.blobstart))
		else
			CRASH("Unable to find a blobstart landmark")
	var/turf/T = get_turf(H)
	var/area/A = T.loc
	log_game("[H] entered itself. Moving it to [loc_name(targetturf)].")
	message_admins("[H] entered itself. Moving it to [ADMIN_VERBOSEJMP(targetturf)].")
	for(var/mob/M in A)
		to_chat(M, span_danger("[H] almost implodes in upon itself, but quickly rebounds, shooting off into a random point in space!"))
	H.forceMove(targetturf)

/area/misc/hilbertshotel/Exited(atom/movable/gone, direction)
	. = ..()
	if(ismob(gone))
		var/mob/M = gone
		if(M.mind)
			var/stillPopulated = FALSE
			var/list/currentLivingMobs = get_all_contents_type(/mob/living) //Got to catch anyone hiding in anything
			for(var/mob/living/L in currentLivingMobs) //Check to see if theres any sentient mobs left.
				if(L.mind)
					stillPopulated = TRUE
					break
			if(!stillPopulated)
				storeRoom()

/area/misc/hilbertshotel/proc/storeRoom()
	var/turf/room_bottom_left = reservation.bottom_left_turfs[1]
	var/turf/room_top_right = reservation.top_right_turfs[1]
	var/roomSize = \
		((room_top_right.x - room_bottom_left.x) + 1) * \
		((room_top_right.y - room_bottom_left.y) + 1)
	var/storage[roomSize]
	var/turfNumber = 1
	var/obj/item/abstracthotelstorage/storageObj = new(storageTurf)
	storageObj.roomNumber = roomnumber
	storageObj.parentSphere = parentSphere
	storageObj.name = "Room [roomnumber] Storage"
	for(var/x in 0 to parentSphere.hotelRoomTemp.width-1)
		for(var/y in 0 to parentSphere.hotelRoomTemp.height-1)
			var/list/turfContents = list()
			for(var/atom/movable/A in locate(room_bottom_left.x + x, room_bottom_left.y + y, room_bottom_left.z))
				if(ismob(A) && !isliving(A))
					continue //Don't want to store ghosts
				turfContents += A
				A.forceMove(storageObj)
			storage[turfNumber] = turfContents
			turfNumber++
	parentSphere.storedRooms["[roomnumber]"] = storage
	parentSphere.activeRooms -= "[roomnumber]"
	qdel(reservation)

/area/misc/hilbertshotelstorage
	name = "Hilbert's Hotel Storage Room"
	icon = 'icons/area/areas_ruins.dmi'
	icon_state = "hilbertshotel"
	requires_power = FALSE
	area_flags = HIDDEN_AREA | NOTELEPORT | UNIQUE_AREA
	has_gravity = TRUE

/obj/item/abstracthotelstorage
	anchored = TRUE
	invisibility = INVISIBILITY_ABSTRACT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	item_flags = ABSTRACT
	var/roomNumber
	var/obj/item/hilbertshotel/parentSphere

/obj/item/abstracthotelstorage/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(istype(arrived, /obj/machinery/light))
		var/obj/machinery/light/entered_light = arrived
		entered_light.end_processing()
	. = ..()
	if(ismob(arrived))
		var/mob/target = arrived
		ADD_TRAIT(target, TRAIT_NO_TRANSFORM, REF(src))

/obj/item/abstracthotelstorage/Exited(atom/movable/gone, direction)
	. = ..()
	if(ismob(gone))
		var/mob/target = gone
		REMOVE_TRAIT(target, TRAIT_NO_TRANSFORM, REF(src))
	if(istype(gone, /obj/machinery/light))
		var/obj/machinery/light/exited_light = gone
		exited_light.begin_processing()

//Space Ruin stuff
/area/ruin/space/has_grav/powered/hilbertresearchfacility
	name = "Hilbert Research Facility"

/area/ruin/space/has_grav/powered/hilbertresearchfacility/secretroom
	area_flags = UNIQUE_AREA | NOTELEPORT | HIDDEN_AREA

/obj/item/analyzer/hilbertsanalyzer
	name = "custom rigged analyzer"
	desc = "A hand-held environmental scanner which reports current gas levels. This one seems custom rigged to additionally be able to analyze some sort of bluespace device."
	icon_state = "hilbertsanalyzer"
	worn_icon_state = "analyzer"

/obj/item/analyzer/hilbertsanalyzer/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(istype(target, /obj/item/hilbertshotel))
		. |= AFTERATTACK_PROCESSED_ITEM
		if(!proximity)
			to_chat(user, span_warning("It's to far away to scan!"))
			return .
		var/obj/item/hilbertshotel/sphere = target
		if(sphere.activeRooms.len)
			to_chat(user, "Currently Occupied Rooms:")
			for(var/roomnumber in sphere.activeRooms)
				to_chat(user, roomnumber)
		else
			to_chat(user, "No currenty occupied rooms.")
		if(sphere.storedRooms.len)
			to_chat(user, "Vacated Rooms:")
			for(var/roomnumber in sphere.storedRooms)
				to_chat(user, roomnumber)
		else
			to_chat(user, "No vacated rooms.")
		return .

/obj/effect/landmark/transport/transport_id/hilbert
	specific_transport_id = HILBERT_LINE_1

/obj/effect/landmark/transport/nav_beacon/tram/nav/hilbert
	name = HILBERT_LINE_1
	specific_transport_id = TRAM_NAV_BEACONS

/obj/effect/landmark/transport/nav_beacon/tram/platform/hilbert/left
	name = "Port"
	specific_transport_id = HILBERT_LINE_1
	platform_code = HILBERT_PORT
	tgui_icons = list("Reception" = "briefcase", "Botany" = "leaf", "Chemistry" = "flask")

/obj/effect/landmark/transport/nav_beacon/tram/platform/hilbert/middle
	name = "Central"
	specific_transport_id = HILBERT_LINE_1
	platform_code = HILBERT_CENTRAL
	tgui_icons = list("Processing" = "cogs", "Xenobiology" = "paw")

/obj/effect/landmark/transport/nav_beacon/tram/platform/hilbert/right
	name = "Starboard"
	specific_transport_id = HILBERT_LINE_1
	platform_code = HILBERT_STARBOARD
	tgui_icons = list("Ordnance" = "bullseye", "Office" = "user", "Dormitories" = "bed")

/obj/item/keycard/hilbert
	name = "Hilbert's office keycard"
	desc = "A keycard with an engraving on it. The engraving reads: \"Hilbert\"."
	color = "#aa00cc"
	puzzle_id = "hilbert_office"

/obj/machinery/door/puzzle/keycard/hilbert
	name = "secure airlock"
	puzzle_id = "hilbert_office"

/datum/outfit/doctorhilbert
	name = "Doctor Hilbert"
	id = /obj/item/card/id/advanced/silver
	uniform = /obj/item/clothing/under/rank/rnd/research_director/doctor_hilbert
	shoes = /obj/item/clothing/shoes/sneakers/brown
	back = /obj/item/storage/backpack/satchel/leather
	suit = /obj/item/clothing/suit/toggle/labcoat
	id_trim = /datum/id_trim/away/hilbert

/datum/outfit/doctorhilbert/pre_equip(mob/living/carbon/human/hilbert, visualsOnly)
	. = ..()
	if(!visualsOnly)
		hilbert.gender = MALE
		hilbert.update_body()

/obj/item/paper/crumpled/ruins/note_institute
	name = "note to the institute"

/obj/item/paper/crumpled/ruins/note_institute/Initialize(mapload)
	default_raw_text = {"Note to the Institute<br>
	If you're reading this, I hope you're from the Institute. First things first, I should apologise. I won't be coming back to teach in the new semester.<br>
	We've made some powerful enemies. Very powerful. More powerful than any of you can imagine, and so we can't come back.<br>
	So, we've made the decision to vanish. Perhaps more literally than you might think. Do not try to find us- for your own safety.<br>
	I've left some of our effects in the Hotel. Room number <u>[uppertext(num2hex(GLOB.hhMysteryRoomNumber, 0))]</u>. To anyone who should know, that should make sense.<br>
	Best of luck with the research. From all of us in the Hilbert Group, it's been a pleasure working with you.<br>
	- David, Phil, Fiona and Jen"}
	return ..()

/obj/item/paper/crumpled/ruins/postdocs_memo
	name = "memo to the postdocs"
	default_raw_text = {"Memo to the Postdocs
	Remember, if you're going in to retrieve the prototype for any reason (not that you should be without my supervision), that the security systems are always live- they have no shutoff.<br>
	Instead, remember: what you can't see can't hurt you.<br>
	Take care of the lab during my vacation. See you all in June.<br>
	- David"}

/obj/item/paper/crumpled/ruins/hotel_note
	name = "hotel note"
	default_raw_text = {"Hotel Note<br>
	Well, you figured out the puzzle. Looks like someone's done their homework on my research.<br>
	I suppose you deserve to know some more about our situation. Our research has attracted some undue attention and so, for our own safety, we've taken to the Bluespace.<br>
	Yes, you did read that correctly. I'm sure the physics and maths would bore you, but in layman's terms, the manifested link to the Bluespace the crystals provide can be exploited. With the correct technology, one can "surf" the Bluespace, as Jen likes to call it.<br>
	What's more, the space-time continuum is in full effect here. By correctly manipulating the bluespace, one can go <i>anywhere</i>: time or space. I'll confess to not having figured that one out myself. Check the closet- consider it a prize for solving the puzzle. Just be careful with its use- you might find yourself dealing with the same pursuers we've picked up.<br>
	They deal in "time crimes", whatever their definition of those are.<br>
	Anyway, I'm beginning to ramble. We must be going now. Make sure any posthumous Nobel prizes are made out to the department.<br>
	- David"}

/obj/item/paper/fluff/ruins/docslabnotes
	name = "lab notebook page"
	default_raw_text = {"Laboratory Notebook<br>
	PROPERTY OF DOCTOR D. HILBERT<br>
	May 10th, 2555<br>
	Finally, my new facility is complete, and not a moment too soon!<br>
	My disagreements with Greenham have become too much to bear, so some time away from the campus will do me well. It's not like my students understand my work, anyway. Teaching never was my passion.<br>
	Anyway, I'm getting off track. It is quite amazing what a few million in grants will buy you. This station is state of the art, perfect for my studies.<br>
	Since the Zhang Incident of 2459, we have been quite aware of the properties of bluespace crystals. Their space-warping properties are well-documented, but poorly understood. However, I theorise that it may be possible to harness them in new ways.<br>
	To this end, I've procured a small team of postdoctorate students from the institute to assist with my research. Some administrative help wouldn't go amiss, either- perhaps I should hire a secretary...<br>
	*Following this is a long series of pages detailing failures, grievances with the institute, and more scientific equations than anyone can reasonably chew through.*<br>
	<h4>Breakthrough<h4>
	January 8th, 2557<br>
	My theories have held up adequately. Today, we had our first successful test of the "Hilbert Pocket", as we've taken to calling it. By exploiting the ability of bluespace crystals to create a localised dilation in space, with precise application of force according to geometric calculus, we have successfully "folded" space into a pocket. We had Phil throw one of his analysers into it from across the room, and what we saw was incredible.<br>
	A pocket of infinite space, within a finite area. Simply revolutionary!<br>
	I've set the postdocs to paper writing while I work out the specifics. The technology is successful, but we have no way to harness it. Unless...<br>
	*Many more pages dedicated to equations, engineering drawings, and ramblings continue. Hilbert clearly loves the sight of his own handwriting.*<br>
	<h4>A New Device<h4>
	September 21st, 2557<br>
	We've submitted the first draft of the paper on Hilbert Pockets to the journals. Now, I suppose, we wait.<br>
	In the meantime, I've taken to assembling the first prototype of the device. By exploiting the pocket's ability to create an infinite region of space within a finite area, I've made... well, I suppose it could be called a "Pocket Dimension". Within, I've created a nifty system that recursively produces subspace rooms, spatially linking them to any of the infinite points on the pocket's surface. Fiona says it's akin to a hotel, and I'm inclined to agree.<br>
	Hilbert's Hotel. I like the sound of that.<br>"}

/obj/machinery/computer/terminal/hilbert
	upperinfo = "EMAIL READOUT - 14/05/2558"
	content = list(
		"<b>New Job</b><br> \
		<i>Sent to: natalya_petroyenko@kosmokomm.net</i><br> \
		Hello sis! Figured I should update you on what's going on with the career change.<br> \
		First day on the new job. It's a pretty boring position, but hey- it's not like I was finding anything in New Vladimir. I'm just glad to have something to pay the bills.<br> \
		Suppose I should say what's involved: I'm essentially playing housekeeper for some scientist and his cohort of student assistants. Far above my pay grade to understand what they do, but they seem excited enough. Talking about \"pockets\", for whatever reason. Maybe they're designing the next innovation in clothes?<br> \
		Anyway, that's pretty much it. I'm living on their station for pretty much the duration, so I'm not sure if I'll be able to make it to Mama's birthday. Sorry about that- I'll do my best to make it up to her (and you) when I get some leave.<br> \
		Hope to see you soon,<br> \
		Little Brother Roman",
		"<b>Visitors</b><br> \
		<i>Sent to: david_hilbert@physics.mit.edu</i><br> \
		Morning Doctor. Sorry to email you when you're on holiday, but you did tell me to update you on anything suspicious.<br> \
		There's been a ship that's been hanging around the facility for a few days. Figured that was odd enough, given how far from anything important we are, but it got stranger when one of them finally came over to talk.<br> \
		I know I'm not a native speaker, but I couldn't make out his accent. Wasn't like anything I've heard before, anyway.<br> \
		He kept asking where you were, and if he could come in to speak to you. Of course, I turned him away- even if you had been around I'd have been hesitant to let him in.<br> \
		As an aside, the postdocs told me to pass on a message. Apparently they've made a breakthrough, which sounds good and all.<br> \
		Regards,<br> \
		Roman<br>",
		"<b>Weird Times</b><br> \
		<i>Sent to: natalya_petroyenko@kosmokomm.net</i><br> \
		Hi sis! How was Christmas? Are Mama and Papa doing well? I'm really sorry I couldn't be there, but I've been working my fingers to the bone at work.<br> \
		I figure I should tell you a bit about how it's been going here. I know, I know, you keep calling me a workaholic, but it's really... strange, I guess?<br> \
		I keep getting little glimpses into the research that's happening. They're messing around with bluespace- you know, the tech that makes FTL engines work? I'm not sure what exactly they're doing with it, but they're talking more and more about pockets every day now.<br> \
		Not only that, but I'm starting to hear strange noises from the labs I'm not allowed into. Nothing super terrifying, you know, we're not talking xenomorphs, but more like industrial sounds. Crashes, bangs, occasional high-pitched whining, you know the sort. Like a broken vacuum cleaner.<br> \
		I know it's not the instruments or I'd have heard it before, so it must be something new they've been working on. Exciting, I suppose, but I'm starting to wonder if I'm in over my head working here. Maybe I should start looking for a new job, somewhere closer to home.<br> \
		Hope to see you at Papa's birthday. I've requested leave for it, and I'm just waiting on the Doc's response.<br> \
		See you soon,<br> \
		Little Brother Roman<br>",
		"<b>End of Leave</b><br> \
		<i>Sent to: david_hilbert@physics.mit.edu</i><br> \
		Morning Doctor. Where is everyone? I got back from leave and the station was empty. Have you all went on holiday without telling me?<br> \
		And what the hell happened to the ordnance lab? I couldn't even open the door to get in, it was fused shut!<br> \
		Look, I don't feel safe staying on the station with it in this state, so I'm calling an engineer and heading home until I hear back from you.<br> \
		Regards,<br> \
		Roman<br>",
		"<b>Looking for a New Job</b><br> \
		<i>Sent to: natalya_petroyenko@kosmokomm.net</i><br> \
		Hi sis. First things first, sorry for missing your engagement party. There's been a... situation at work.<br> \
		In fact, that's most of why I'm writing this. I have absolutely no idea what happened, but the Doctor and the students are gone. Just up and left. The facility's abandoned.<br> \
		But like, it's clear they left in a hurry. Hell, there's still coffee in the cups. I'd question it further, but they were always kinda... odd, I guess? The whole thing gives me chills and I don't think I want to dig any deeper.<br> \
		I dropped his university an email and called in the authorities. All that's left now, I guess, is to find a new job. Would your boss happen to be hiring?<br> \
		See you soon,<br> \
		Little Brother Roman",
	)

/obj/structure/showcase/machinery/tv/broken
	name = "broken tv"
	desc = "Nothing plays."

/obj/structure/showcase/machinery/tv/broken/Initialize(mapload)
	. = ..()
	add_overlay("television_broken")

/obj/machinery/porta_turret/syndicate/teleport
	name = "displacement turret"
	desc = "A ballistic machine gun auto-turret that fires bluespace bullets."
	lethal_projectile = /obj/projectile/magic/teleport
	stun_projectile = /obj/projectile/magic/teleport
	faction = list(FACTION_TURRET)
