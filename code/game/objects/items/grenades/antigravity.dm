/obj/item/grenade/antigravity
	name = "antigravity grenade"
	icon_state = "emp"
	item_state = "emp"
	
	var/range = 7
	var/forced_value = 0
	var/duration = 300

/obj/item/grenade/antigravity/prime()
	update_mob()
	
	for(var/turf/T in view(range,src))
		var/datum/component/C = T.AddComponent(/datum/component/forced_gravity,forced_value)
		QDEL_IN(C,duration)
		
	qdel(src)
