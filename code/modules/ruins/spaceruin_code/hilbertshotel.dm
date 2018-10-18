/obj/item/hilbertshotel
    name = "Hilbert's Hotel"
    desc = "A sphere of what appears to be an intricate network of bluespace. Observing it in detail seems to give you a headache as you try to comprehend the infinite amount of infinitesimally distinct points on its surface."
    icon_state = "hilbertshotel"
    w_class = WEIGHT_CLASS_SMALL
    var/ruinSpawned = FALSE
    var/datum/map_template/hilbertshotel/hotelRoomTemp
    var/datum/map_template/hilbertshotel/hotelRoomTempEmpty
    var/list/activeRooms = list()
    var/list/storedRooms = list()

/obj/item/hilbertshotel/Initialize()
    . = ..()
    //Load templates
    hotelRoomTemp = new()
    hotelRoomTempEmpty = new()

/obj/item/hilbertshotel/attack_self(mob/user)
    . = ..()
    var/chosenRoomNumber = input("What number room will you be checking into?", "Room Number") as null|num
    if(!chosenRoomNumber)
        return
    if((chosenRoomNumber < 1) || (chosenRoomNumber != round(chosenRoomNumber)))
        to_chat(user, "<span class='warning'>That is not a valid room number!</span>")
        return
    var/datum/turf_reservation/roomReservation //Pun not intended
    src.forceMove(get_turf(user))
    if(activeRooms["[chosenRoomNumber]"])
        roomReservation = activeRooms["[chosenRoomNumber]"]
        do_sparks(3, FALSE, get_turf(user))
        user.forceMove(locate(roomReservation.bottom_left_coords[1] + hotelRoomTemp.landingZoneRelativeX, roomReservation.bottom_left_coords[2] + hotelRoomTemp.landingZoneRelativeY, roomReservation.bottom_left_coords[3]))
        return
    roomReservation = SSmapping.RequestBlockReservation(hotelRoomTemp.width, hotelRoomTemp.height)
    if(storedRooms["[chosenRoomNumber]"])
        hotelRoomTempEmpty.load(locate(roomReservation.bottom_left_coords[1], roomReservation.bottom_left_coords[2], roomReservation.bottom_left_coords[3]))
        var/turfNumber = 1
        for(var/i=0, i<hotelRoomTemp.width, i++)
            for(var/j=0, j<hotelRoomTemp.height, j++)
                for(var/atom/movable/A in storedRooms["[chosenRoomNumber]"][turfNumber])
                    A.forceMove(locate(roomReservation.bottom_left_coords[1] + i, roomReservation.bottom_left_coords[2] + j, roomReservation.bottom_left_coords[3]))
                turfNumber++
        storedRooms -= "[chosenRoomNumber]"
    else
        hotelRoomTemp.load(locate(roomReservation.bottom_left_coords[1], roomReservation.bottom_left_coords[2], roomReservation.bottom_left_coords[3]))
    activeRooms["[chosenRoomNumber]"] = roomReservation
    linkTurfs(roomReservation, chosenRoomNumber)
    do_sparks(3, FALSE, get_turf(user))
    user.forceMove(locate(roomReservation.bottom_left_coords[1] + hotelRoomTemp.landingZoneRelativeX, roomReservation.bottom_left_coords[2] + hotelRoomTemp.landingZoneRelativeY, roomReservation.bottom_left_coords[3]))

/obj/item/hilbertshotel/proc/linkTurfs(var/datum/turf_reservation/currentReservation, var/currentRoomnumber)
    var/area/currentArea = get_area(locate(currentReservation.bottom_left_coords[1], currentReservation.bottom_left_coords[2], currentReservation.bottom_left_coords[3]))
    currentArea.name = "Hilbert's Hotel Room [currentRoomnumber]"
    for(var/turf/closed/indestructible/hoteldoor/door in currentArea)
        door.parentSphere = src
        door.roomnumber = currentRoomnumber
        door.reservation = currentReservation
        door.desc = "The door to this hotel room. The placard reads 'Room [currentRoomnumber]'. Strange, this door doesnt even seem openable. The doorknob, however, seems to buzz with unusual energy..."
    for(var/turf/open/space/bluespace/BSturf in currentArea)
        BSturf.parentSphere = src

//Template Stuff
/datum/map_template/hilbertshotel
    name = "Hilbert's Hotel Room"
    mappath = '_maps/templates/hilbertshotel.dmm'
    var/landingZoneRelativeX = 2
    var/landingZoneRelativeY = 8

/datum/map_template/hilbertshotel/empty
    name = "Empty Hilbert's Hotel Room"
    mappath = '_maps/templates/hilbertshotelempty.dmm'

//Turfs and Areas
/turf/closed/indestructible/hotelwall
	name = "hotel wall"
	desc = "A wall designed to protect the security of the hotel's guests."
	icon = 'icons/turf/walls/wood_wall.dmi'
	icon_state = "wood"
	canSmoothWith = list(/turf/closed/indestructible/hotelwall)
	explosion_block = INFINITY

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
    baseturfs = /turf/open/space/bluespace
    flags_1 = NOJAUNT_1
    explosion_block = INFINITY
    var/obj/item/hilbertshotel/parentSphere

/turf/open/space/bluespace/Entered(atom/movable/A)
    . = ..()
    A.forceMove(get_turf(parentSphere))
    do_sparks(3, FALSE, get_turf(A))

/turf/closed/indestructible/hoteldoor
    name = "Hotel Door"
    icon_state = "hoteldoor"
    explosion_block = INFINITY
    var/roomnumber = 0
    var/obj/item/hilbertshotel/parentSphere
    var/datum/turf_reservation/reservation

/turf/closed/indestructible/hoteldoor/attack_hand(mob/user)
    if(!parentSphere)
        to_chat(user, "<span class='warning'>The door seems to be malfunctioned and refuses to operate!</span>")
        return
    if(alert(user, "Would you like to leave the hotel room?", "Exit", "Leave", "Stay") == "Leave")
        var/area/currentArea = get_area(src)
        var/stillPopulated = FALSE
        for(var/mob/living/L in currentArea) //Check to see if theres any sentient mobs left.
            if(L.mind && (L != user))
                stillPopulated = TRUE
                break
        if(!stillPopulated)
            switch(alert(user, "As the last current resident of this room, Hilbert's Hotel would like to remind you that while we will do everything we can to protect the belongings you left behind, we make no guarantee of their safety while you're gone, especially that of the health of any living creatures. With that in mind, are you ready to leave?", "Property Damage Liability Notice", "Ready", "Not Yet"))
                if("Not Yet")
                    return
                if("Ready")
                    user.forceMove(get_turf(parentSphere))
                    do_sparks(3, FALSE, get_turf(user))
                    var/storage[(reservation.top_right_coords[1]-reservation.bottom_left_coords[1]+1)*(reservation.top_right_coords[2]-reservation.bottom_left_coords[2]+1)]
                    var/turfNumber = 1
                    for(var/i=0, i<parentSphere.hotelRoomTemp.width, i++)
                        for(var/j=0, j<parentSphere.hotelRoomTemp.height, j++)
                            var/list/turfContents = list()
                            for(var/atom/movable/A in locate(reservation.bottom_left_coords[1] + i, reservation.bottom_left_coords[2] + j, reservation.bottom_left_coords[3]))
                                turfContents += A
                                A.forceMove(parentSphere)
                            storage[turfNumber] = turfContents
                            turfNumber++
                    parentSphere.storedRooms["[roomnumber]"] = storage
                    parentSphere.activeRooms -= "[roomnumber]"
                    qdel(reservation)
                    qdel(currentArea) //Why this isn't deleted with the reservation is beyond me
        else
            user.forceMove(get_turf(parentSphere))
            do_sparks(3, FALSE, get_turf(user))

/area/hilbertshotel
    name = "Hilbert's Hotel Room"
    icon_state = "hilbertshotel"
    requires_power = FALSE
    has_gravity = TRUE
    noteleport = TRUE
    hidden = TRUE
    unique = FALSE
    dynamic_lighting = DYNAMIC_LIGHTING_FORCED
