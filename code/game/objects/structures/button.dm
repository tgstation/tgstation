//Simple door switch system for away missions

/obj/structure/button
	name = "button"

	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"

	var/activate_id = "1" //icon_state of the /obj/effect/hidden_door that you want to be activate
	var/global_search = 1 //If 1, search for all hidden doors in the world. Otherwise, only search for those in current area
	var/reset_name = 1

/obj/structure/button/New()
	..()

	//So that you can label your buttons in the map editor
	if(reset_name)
		name = initial(name)

/obj/structure/button/attack_hand(mob/user)
	visible_message("<span class='info'>[user] presses \the [src].</span>")
	activate()

/obj/structure/button/proc/activate()
	if(global_search)
		for(var/obj/effect/hidden_door/hidden_door in hidden_doors)
			if(hidden_door.icon_state == activate_id && hidden_door.z == src.z)
				hidden_door.toggle()
	else
		for(var/obj/effect/hidden_door/hidden_door in get_area(src))
			if(hidden_door.icon_state == activate_id && hidden_door.z == src.z)
				hidden_door.toggle()

var/list/hidden_doors = list()

/obj/effect/hidden_door
	name = "hidden door"
	icon = 'icons/effects/triggers.dmi'

	var/inverted = 0 //If 1, the door starts opened and closes on switch
	var/list/door_appearance = list()

	var/door_typepath = /turf/unsimulated/wall

	var/floor_typepath = /turf/simulated/floor

	var/opened = 0

/obj/effect/hidden_door/New()
	..()

	invisibility = 101
	hidden_doors.Add(src)

	if(inverted)
		toggle()

/obj/effect/hidden_door/Destroy()
	hidden_doors.Remove(src)

	..()

/obj/effect/hidden_door/proc/steal_appearance()
	var/turf/T = get_turf(src)

	if(!T) return
	door_appearance["name"] = T.name
	door_appearance["icon_state"] = T.icon_state
	door_typepath = T.type

/obj/effect/hidden_door/proc/toggle()
	var/turf/T = get_turf(src)
	playsound(T, 'sound/effects/stonedoor_openclose.ogg', 100, 1)

	if(opened)
		T.ChangeTurf(door_typepath)

		spawn()
			for(var/V in door_appearance)
				T.vars[V] = door_appearance[V]

		opened = 0
	else
		steal_appearance()
		T.ChangeTurf(floor_typepath)

		opened = 1
