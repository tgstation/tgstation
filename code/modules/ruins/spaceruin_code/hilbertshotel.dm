GLOBAL_VAR_INIT(hhStorageTurf, null)

/obj/item/hilbertshotel
    name = "Hilbert's Hotel"
    desc = "A sphere of what appears to be an intricate network of bluespace. Observing it in detail seems to give you a headache as you try to comprehend the infinite amount of infinitesimally distinct points on its surface."
    icon_state = "hilbertshotel"
    w_class = WEIGHT_CLASS_SMALL
    resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
    var/ruinSpawned = FALSE
    var/datum/map_template/hilbertshotel/hotelRoomTemp
    var/datum/map_template/hilbertshotel/empty/hotelRoomTempEmpty
    var/datum/map_template/hilbertshotel/lore/hotelRoomTempLore
    var/list/activeRooms = list()
    var/list/storedRooms = list()
    var/storageTurf

/obj/item/hilbertshotel/Initialize()
    . = ..()
    //Load templates
    hotelRoomTemp = new()
    hotelRoomTempEmpty = new()
    hotelRoomTempLore = new()
    var/area/currentArea = get_area(src)
    if(currentArea.type == /area/ruin/space/has_grav/hilbertresearchfacility)
        ruinSpawned = TRUE
    if(!GLOB.hhStorageTurf)
        var/datum/map_template/hilbertshotelstorage/storageTemp = new()
        var/datum/turf_reservation/storageReservation = SSmapping.RequestBlockReservation(3, 3)
        storageTemp.load(locate(storageReservation.bottom_left_coords[1], storageReservation.bottom_left_coords[2], storageReservation.bottom_left_coords[3]))
        GLOB.hhStorageTurf = locate(storageReservation.bottom_left_coords[1]+1, storageReservation.bottom_left_coords[2]+1, storageReservation.bottom_left_coords[3])
    storageTurf = GLOB.hhStorageTurf

/obj/item/hilbertshotel/attack_self(mob/user)
    . = ..()
    var/chosenRoomNumber = input("What number room will you be checking into?", "Room Number") as null|num
    if(!chosenRoomNumber)
        return
    if((chosenRoomNumber < 1) || (chosenRoomNumber != round(chosenRoomNumber)))
        to_chat(user, "<span class='warning'>That is not a valid room number!</span>")
        return
    src.forceMove(get_turf(user))
    if(tryActiveRoom(chosenRoomNumber, user))
        return
    if(tryStoredRoom(chosenRoomNumber, user))
        return
    sendToNewRoom(chosenRoomNumber, user)

/obj/item/hilbertshotel/proc/tryActiveRoom(var/roomNumber, var/mob/user)
    if(activeRooms["[roomNumber]"])
        var/datum/turf_reservation/roomReservation = activeRooms["[roomNumber]"]
        do_sparks(3, FALSE, get_turf(user))
        user.forceMove(locate(roomReservation.bottom_left_coords[1] + hotelRoomTemp.landingZoneRelativeX, roomReservation.bottom_left_coords[2] + hotelRoomTemp.landingZoneRelativeY, roomReservation.bottom_left_coords[3]))
        return TRUE
    else
        return FALSE

/obj/item/hilbertshotel/proc/tryStoredRoom(var/roomNumber, var/mob/user)
    if(storedRooms["[roomNumber]"])
        var/datum/turf_reservation/roomReservation = SSmapping.RequestBlockReservation(hotelRoomTemp.width, hotelRoomTemp.height)
        hotelRoomTempEmpty.load(locate(roomReservation.bottom_left_coords[1], roomReservation.bottom_left_coords[2], roomReservation.bottom_left_coords[3]))
        var/turfNumber = 1
        for(var/i=0, i<hotelRoomTemp.width, i++)
            for(var/j=0, j<hotelRoomTemp.height, j++)
                for(var/atom/movable/A in storedRooms["[roomNumber]"][turfNumber])
                    if(istype(A.loc, /obj/item/abstracthotelstorage))//Don't want to recall something thats been moved
                        if(ismob(A))
                            var/mob/M = A
                            M.notransform = FALSE
                        A.forceMove(locate(roomReservation.bottom_left_coords[1] + i, roomReservation.bottom_left_coords[2] + j, roomReservation.bottom_left_coords[3]))
                turfNumber++
        for(var/obj/item/abstracthotelstorage/S in storageTurf)
            if(S.roomNumber == roomNumber)
                qdel(S)
        storedRooms -= "[roomNumber]"
        activeRooms["[roomNumber]"] = roomReservation
        linkTurfs(roomReservation, roomNumber)
        do_sparks(3, FALSE, get_turf(user))
        user.forceMove(locate(roomReservation.bottom_left_coords[1] + hotelRoomTemp.landingZoneRelativeX, roomReservation.bottom_left_coords[2] + hotelRoomTemp.landingZoneRelativeY, roomReservation.bottom_left_coords[3]))
        return TRUE
    else
        return FALSE

/obj/item/hilbertshotel/proc/sendToNewRoom(var/roomNumber, var/mob/user)
    var/datum/turf_reservation/roomReservation = SSmapping.RequestBlockReservation(hotelRoomTemp.width, hotelRoomTemp.height)
    if(ruinSpawned && (roomNumber == 1337256))
        hotelRoomTempLore.load(locate(roomReservation.bottom_left_coords[1], roomReservation.bottom_left_coords[2], roomReservation.bottom_left_coords[3]))
    else
        hotelRoomTemp.load(locate(roomReservation.bottom_left_coords[1], roomReservation.bottom_left_coords[2], roomReservation.bottom_left_coords[3]))
    activeRooms["[roomNumber]"] = roomReservation
    linkTurfs(roomReservation, roomNumber)
    do_sparks(3, FALSE, get_turf(user))
    user.forceMove(locate(roomReservation.bottom_left_coords[1] + hotelRoomTemp.landingZoneRelativeX, roomReservation.bottom_left_coords[2] + hotelRoomTemp.landingZoneRelativeY, roomReservation.bottom_left_coords[3]))

/obj/item/hilbertshotel/proc/linkTurfs(var/datum/turf_reservation/currentReservation, var/currentRoomnumber)
    var/area/currentArea = get_area(locate(currentReservation.bottom_left_coords[1], currentReservation.bottom_left_coords[2], currentReservation.bottom_left_coords[3]))
    currentArea.name = "Hilbert's Hotel Room [currentRoomnumber]"
    for(var/turf/closed/indestructible/hoteldoor/door in currentArea)
        door.parentSphere = src
        door.storageTurf = storageTurf
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

/datum/map_template/hilbertshotel/lore
    name = "Doctor Hilbert's Deathbed"
    mappath = '_maps/templates/hilbertshotellore.dmm'

/datum/map_template/hilbertshotelstorage
    name = "Hilbert's Hotel Storage"
    mappath = '_maps/templates/hilbertshotelstorage.dmm'


//Turfs and Areas
/turf/closed/indestructible/hotelwall
	name = "hotel wall"
	desc = "A wall designed to protect the security of the hotel's guests."
	icon_state = "hotelwall"
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
    var/turf/storageTurf

/turf/closed/indestructible/hoteldoor/attack_hand(mob/user)
    if(!parentSphere)
        to_chat(user, "<span class='warning'>The door seems to be malfunctioned and refuses to operate!</span>")
        return
    if(alert(user, "Hilbert's Hotel would like to remind you that while we will do everything we can to protect the belongings you leave behind, we make no guarantees of their safety while you're gone, especially that of the health of any living creatures. With that in mind, are you ready to leave?", "Exit", "Leave", "Stay") == "Leave")
        user.forceMove(get_turf(parentSphere))
        do_sparks(3, FALSE, get_turf(user))
        var/area/currentArea = get_area(src)
        var/stillPopulated = FALSE
        var/list/currentLivingMobs = currentArea.GetAllContents(/mob/living) //Got to catch anyone hiding in anything
        for(var/mob/living/L in currentLivingMobs) //Check to see if theres any sentient mobs left.
            if(L.mind && (L != user))
                stillPopulated = TRUE
                break
        if(!stillPopulated)
            storeRoom()

/turf/closed/indestructible/hoteldoor/proc/storeRoom()
    var/storage[(reservation.top_right_coords[1]-reservation.bottom_left_coords[1]+1)*(reservation.top_right_coords[2]-reservation.bottom_left_coords[2]+1)]
    var/turfNumber = 1
    var/obj/item/abstracthotelstorage/storageObj = new(storageTurf)
    storageObj.roomNumber = roomnumber
    storageObj.name = "Room [roomnumber] Storage"
    for(var/i=0, i<parentSphere.hotelRoomTemp.width, i++)
        for(var/j=0, j<parentSphere.hotelRoomTemp.height, j++)
            var/list/turfContents = list()
            for(var/atom/movable/A in locate(reservation.bottom_left_coords[1] + i, reservation.bottom_left_coords[2] + j, reservation.bottom_left_coords[3]))
                turfContents += A
                if(ismob(A))
                    var/mob/M = A
                    M.notransform = TRUE
                A.forceMove(storageObj)
            storage[turfNumber] = turfContents
            turfNumber++
    parentSphere.storedRooms["[roomnumber]"] = storage
    parentSphere.activeRooms -= "[roomnumber]"
    qdel(reservation)

/area/hilbertshotel
    name = "Hilbert's Hotel Room"
    icon_state = "hilbertshotel"
    requires_power = FALSE
    has_gravity = TRUE
    noteleport = TRUE
    hidden = TRUE
    unique = FALSE
    dynamic_lighting = DYNAMIC_LIGHTING_FORCED
    ambientsounds = list('sound/ambience/servicebell.ogg')

/area/hilbertshotelstorage
    name = "Hilbert's Hotel Storage Room"
    icon_state = "hilbertshotel"
    requires_power = FALSE
    has_gravity = TRUE
    noteleport = TRUE
    hidden = TRUE

/obj/item/abstracthotelstorage
    anchored = TRUE
    invisibility = INVISIBILITY_ABSTRACT
    resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
    item_flags = ABSTRACT
    var/roomNumber

//Space Ruin stuff
/area/ruin/space/has_grav/hilbertresearchfacility
    name = "Hilbert Research Facility"

/obj/item/analyzer/hilbertsanalyzer
    name = "custom rigged analyzer"
    desc = "A hand-held environmental scanner which reports current gas levels. This one seems custom rigged to additionally be able to analyze some sort of bluespace device."
    icon_state = "hilbertsanalyzer"

/obj/item/analyzer/hilbertsanalyzer/afterattack(atom/target, mob/user, proximity)
    . = ..()
    if(istype(target, /obj/item/hilbertshotel))
        if(!proximity)
            to_chat(user, "<span class='warning'>It's to far away to scan!</span>")
            return
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

/obj/effect/mob_spawn/human/doctorhilbert
    name = "Doctor Hilbert"
    mob_name = "Doctor Hilbert"
    mob_gender = "male"
    assignedrole = null
    ghost_usable = FALSE
    oxy_damage = 500
    mob_species = /datum/species/skeleton
    id_job = "Head Researcher"
    id_access = ACCESS_RESEARCH
    id_access_list = list(ACCESS_AWAY_GENERIC3, ACCESS_RESEARCH)
    instant = TRUE
    id = /obj/item/card/id/silver
    uniform = /obj/item/clothing/under/rank/research_director
    shoes = /obj/item/clothing/shoes/sneakers/brown
    back = /obj/item/storage/backpack/satchel/leather
    suit = /obj/item/clothing/suit/toggle/labcoat

/obj/item/paper/crumpled/docslogs
    name = "Research Logs"
    info = {"<h4><center>Research Logs</center></h4>
	I might just be onto something here!<br>
	The strange space-warping properties of bluespace have been known about for awhile now, but I might be on the verge of discovering a new way of harnessing it.<br>
	It's too soon to say for sure, but this might be the start of something quite important!<br>
    I'll be sure to log any major future breakthroughs. This might be a lot more than I can manage on my own, perhaps I should hire that secreatary after all...<br>
	<h4>Breakthrough!</h4>
	I can't believe it, but I did it! Just when I was certain it couldn't be done, I made the final necessary breakthrough.<br>
    Exploiting the effects of space dilation caused by specific bluespace structures combined with a precise use of geometric calculus, I've discovered a way to correlate an infinte amount of space within a finite area!<br>
    While the potential applications are endless, I utilized it in quite a nifty way so far by designing a system that recursively constructs subspace rooms and spatially links them to any of the infinite infinitesimally distinct points on the spheres surface.<br>
    I call it: Hilbert's Hotel!<br>
	<h4>Goodbye</h4>
	I can't take this anymore. I know what happens next, and the fear of what is coming leaves me unable to continue working.<br>
    Any fool in my field has heard the stories. It's not that I didn't believe them, it's just... I guess I underestimated the importance of my own research...<br>
    Robert has reported a further increase in frequency of the strange, prying visitors who ask questions they have no buisness asking. I've requested him to keep everything on strict lockdown and have permanetly dismissed all other assistants.<br>
    I've also instructed him to use the encryption method we discussed for any important quantitative data. The poor lad... I don't think he truly understands what he's gotten himself into...<br>
    It's clear what happens now. One day they'll show up uninvited, and claim my research as their own, leaving me as nothing more than a bullet ridden corpse floating in space.<br>
    I can't stick around to the let that happen.<br>
    I'm escaping into the very thing that brought all this trouble to my doorstep in the first place - my hotel.<br>
    I'll be in <u>FGeo</u> (That will make sense to anyone who should know)<br>
    I'm sorry that I must go like this. Maybe one day things will be different and it will be safe to return... maybe...<br>
    Goodbye<br>
	<br>
	<i>Doctor Hilbert</i>"}

/obj/item/paper/crumpled/robertsworkjournal
    name = "Work Journal"
    info = {"<h4>First Week!</h4>
	First week on the new job. It's a secretarial position, but hey, whatever pays the bills. Plus it seems like some intersting stuff goes on here.<br>
	Doc says its best that I don't openly talk about his research with others, I guess he doesn't want it getting out or something. I've caught myself slipping a few times when talking to others, it's hard not to brag about someting this cool!<br>
	I'm not really sure why I'm choosing to journal this. Doc seems to log everything. He says it's incase he discovers anything important.<br>
    I guess thats why I'm doing it too, I've always wanted to be a part of something important.<br>
    Here's to a new job and to becoming a part of something important!<br>
	<h4>Weird times...</h4>
	Things are starting to get a little strange around here. Just weeks after Doc's amazing breakthrough, weird visitors have began showing up unannouced, asking strange things about Doc's work.<br>
    I knew Doc wasn't a big fan of company, but even he seemed strangely unnerved when I told him about the visitors.<br>
    He said it's important that from here on out we keep tight security on everthing, even other staff members.<br>
    He also said something about securing data, something about sixty-four bases. What's that mean? Something to do with baseball? Doc never struct me as the sports type...<br>
    He often uses a lot of big sciencey words that I don't really understand, but I kinda dig it, it makes me feel like I'm witnessing something big.<br>
    I hope things go back to normal soon, but I guess that's the price you pay for being a part of something important.<br>
	<h4>Last day I guess?</h4>
	Thinks are officially starting to get too strange for me.<br>
    The visitors have been coming a lot more often, and they all seem increasingly aggressive and nosey. I'm starting to see why they made Doc so nervous, they're certainly starting to creep me out too.<br>
    Awhile ago Doc started having me keep the place on strict lockdown and requested I refuse entry to anyone else, including previous staff.<br>
    But the weirdest part?<br>
    I haven't seen Doc in days. It's not unusual for him to work continuosly for long periods of time in the lab, but when I took a peak in their yesterday - he was nowhere to be seen! I didn't risk prying much further, Doc had a habit of leaving the defense systems on these last few weeks.<br>
    I'm thinking it might be time to call it quits. Can't work much without a boss, plus things are starting to get kind of shady. I wanted to be a part of something important, but you gotta know when to play it safe.<br>
    As my dad always said, "The smart get famous, but the wise survive..."<br>
	<br>
	<i>Robert P.</i>"}

/obj/item/paper/crumpled/bloody/docsdeathnote
    name = "note"
    info = {"This is it isn't it?<br>
    No ones coming to help, that much has become clear.<br>
    Sure, its lonely, but do I have much choice? Atleast I brought the analyzer with me, they shouldn't be able to find me without it.<br>
    Who knows who's waiting for me out there. It either die out there in their hands, or die a slower, slightly more comfortable death in here.<br>
    Everyday I can feel myself slipping away more and more, both physically and mentally. Who knows what happens now...<br>
    Heh, so it's true then, this must be the inescapable path of all great minds... so be it then.<br>
    <br>
    <br>
    <br>
    <i>Choose a room, and enter the sphere<br>
    Lay your head to rest, it soon becomes clear<br>
    There's always more room around every bend<br>
    Not all that's countable has an end...<i>"}
