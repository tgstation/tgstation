//Simple door switch system for away missions

/obj/structure/button
	name = "button"

	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"

	var/activate_id = "1" //icon_state of the /obj/effect/hidden_door that you want to be activate
	var/global_search = 1 //If 1, search for all hidden doors in the world. Otherwise, only search for those in current area
	var/reset_name = 1

	var/state = 0 //When the button is pressed, this variable switches from 0 to 1 and vice versa

	var/one_time = 0 //If this button can only be used once
	var/used = 0

/obj/structure/button/New()
	..()

	//So that you can label your buttons in the map editor
	if(reset_name)
		name = initial(name)

/obj/structure/button/attack_hand(mob/user)
	if(one_time && used)
		to_chat(user, "<span class='info'>It won't budge!</span>")
		return

	visible_message("<span class='info'>[user] presses \the [src].</span>")
	activate()

/obj/structure/button/attack_tk(mob/user)
	return attack_hand(user)

/obj/structure/button/proc/activate()
	if(global_search)
		for(var/obj/effect/hidden_door/hidden_door in hidden_doors)
			if(is_valid_door(hidden_door))
				hidden_door.toggle()
				used = 1
	else
		for(var/obj/effect/hidden_door/hidden_door in get_area(src))
			if(is_valid_door(hidden_door))
				hidden_door.toggle()
				used = 1

	state = !state

/obj/structure/button/proc/is_valid_door(obj/effect/hidden_door/D)
	return (D.icon_state == activate_id && (D.z == z))

var/list/hidden_doors = list()

/obj/effect/hidden_door
	name = "hidden door"
	icon = 'icons/effects/triggers.dmi'

	var/inverted = 0 //If 1, the door starts opened and closes on switch
	var/list/door_appearance = list()

	var/door_typepath = /turf/unsimulated/wall

	var/floor_typepath = /turf/simulated/floor

	var/opened = 0

	var/fade_animation = 0

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

		for(var/V in door_appearance)
			T.vars[V] = door_appearance[V]

		opened = 0
	else
		steal_appearance()
		T.ChangeTurf(floor_typepath)

		if(fade_animation)
			T.turf_animation('icons/effects/96x96.dmi',"beamin",-32,0,MOB_LAYER+1)

		opened = 1
