
/obj/item/device/dominator_spawner
	name = "Dominator Warp Beacon"
	desc = "Warps a dominator to your location and automatically binds it to your gang"
	icon_state = "gangtool-white"
	item_state = "walkietalkie"

/obj/item/device/dominator_spawner/attack_self(mob/user)
	if(!is_gangboss(user))
		to_chat(user, "<span class='warning'>You don't seem to have any idea how this works. Maybe if you were a gang leader you would...</span>")
		return
	var/datum/gang/master = user.mind.gang_datum
	if(!istype(master))
		return
	if(master.current_dominator && !(master.current_dominator.stat & BROKEN))
		var/area/A = get_area(master.current_dominator)
		to_chat(user, "<span class='warning'>Your gang already has an active dominator at [A.map_name]!</span>")
		return FALSE
	var/turf/T = get_turf(user)
	var/returned = check_valid_location_for_dominator(T)
	if(returned != TRUE)
		to_chat(user, returned)
		return
	to_chat(user, "<span class='boldnotice'>You start charging the dominator teleportation beacon..</span>")
	if(do_after(user, 150, TRUE, src))
		var/area/A = get_area(user)
		master.gang_broadcast("A new dominator has been placed at [A.map_name]! This is your primary base and where you acquire equipment with your influence!")
		new /obj/machinery/dominator(get_turf(user),master)
