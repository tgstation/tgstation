/obj/item/bluespace_beacon
	name = "bluespace beacon"
	desc = ""
	icon = 'icons/obj/bluespace_beacon.dmi'
	icon_state = "1"
	item_state = "signaler"

	var/id = 1//1 to 4

/obj/item/weapon/beacon_dispenser
	name = "beacon based area designator"
	desc = "Guide to using: 1. spawn beacons in the shape of the future area, 2. use the 'Create an area' command, 3. ???, 4. ADMINBUS"
	icon = 'icons/obj/bluespace_beacon.dmi'
	icon_state = "dispenser"

	var/list/beacons = list()
	var/list/areas = list()
	var/id = 1//1 to 4

/obj/item/weapon/beacon_dispenser/attack_self(mob/user)
	id++
	if(id>4) id=1
	to_chat(user, "Spawning beacons with ID: [id]")

/obj/item/weapon/beacon_dispenser/afterattack(atom/A, mob/user as mob)
	var/turf/T = get_turf(A)

	if(istype(A,/obj/item/bluespace_beacon))
		beacons -= A
		qdel(A)
		return

	var/area/AR = get_area(T)
	if(!AR) return

	if(AR.name == "Space")
		var/obj/item/bluespace_beacon/B = new(T)
		B.id = src.id
		B.icon_state = "[src.id]"
		beacons |= B
	else
		to_chat(usr, "There is already an area there.")

/obj/item/weapon/beacon_dispenser/verb/commit()
	set name = "Create an area"
	//set category = "Object" //This is admin-only, the default category 'Commands' will do

	var/list/turfs = list()
	var/conflict = 0
	for(var/obj/item/bluespace_beacon/B in beacons)
		if(B.id == src.id)
			var/area/AR = get_area(B)
			if(AR.type != /area)
				if(!conflict)
					to_chat(usr, "One or more beacons are conflicting with another area. The area will not be created, and conflicting beacons will be marked as such.")
					conflict = 1
				B.overlays += image('icons/obj/bluespace_beacon.dmi', icon_state = "bad")
			turfs |= get_turf(B)

	if(conflict) return

	var/area/shuttle/newarea = new
	areas += newarea
	areas[newarea] = src.id

	var/area/oldarea = get_area(usr)
	newarea.name = input(usr, "Select a name for the new area.") as text
	newarea.tag = "[newarea.type]/[md5(newarea.name)]"
	newarea.lighting_use_dynamic = 0
	newarea.contents.Add(turfs)
	for(var/turf/T in turfs)
		T.change_area(oldarea,newarea)
		for(var/atom/allthings in T.contents)
			allthings.change_area(oldarea,newarea)
	newarea.addSorted()