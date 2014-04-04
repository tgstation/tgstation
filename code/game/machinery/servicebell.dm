// A service bell intended to be placed on the front desks of departments. Works by playing a sound to all
// clients within the specified areas in "departments". A map editor can place these wherever they wish and
// edit the "departments" list to have the area pathnames as desired. 
// e.g. (/area/medical/medbay,/area/medical/sleeper)

/obj/machinery/servicebell
	name = "service bell"
	desc = "A service bell for getting a department's front desk attention."
	icon = 'icons/obj/objects.dmi'
	icon_state = "servicebell"
	anchored = 1
	use_power = 1
	idle_power_usage = 10
	var/list/departments = null
	var/delay = 300
	var/cooldown = 0
	
/obj/machinery/servicebell/New()
	var/list/temp_departments = list()
	for(var/A in departments)
		temp_departments += get_areas(A)
	departments = temp_departments
	return
	
/obj/machinery/servicebell/attack_hand(mob/user)
	if(cooldown >= world.time)
		return
	if(issilicon(user) || user.stat)
		return
	if(!anchored || stat & (BROKEN|NOPOWER))
		return
	if(!departments.Find(get_area_master(loc)))	// Only work if in designated areas
		return
		
	add_fingerprint(user)
	
	for(var/area/department in departments)
		var/list/mobs = get_players_in_area(department)
		for(var/M in mobs)
			if(M != usr)
				M << 'sound/machines/dingdong.ogg'
	usr << 'sound/machines/dingdong.ogg'
	cooldown = world.time + delay
	return
	
/obj/machinery/servicebell/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench))
		anchored = !anchored
		user << "<span class='notice'>You [anchored ? "attached" : "detached"] [src] from the surface.</span>"
		playsound(loc, 'sound/items/Ratchet.ogg', 75, 1)
	return