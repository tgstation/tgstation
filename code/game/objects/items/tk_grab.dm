/obj/item/tk_grab
	name = "Telekinetic Grab"
	icon = 'magic.dmi'//Needs sprites
	icon_state = "2"
	flags = USEDELAY
	//item_state = null
	w_class = 10.0
	layer = 20

	var
		last_throw = 0
		obj/focus = null
		mob/living/host = null


	dropped(mob/user as mob)
		del(src)
		return


	equipped(var/mob/user, var/slot)
		del(src)
		return


	afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)//TODO: go over this
		if(!target || !user)	return
		if(last_throw+4 > world.time)	return
		if(!host)
			del(src)
			return
		if(!host.mutations & TK)
			del(src)
			return
		if(!focus)
			focus_object(target)
			return

		if((get_dist(target, user) <= 16) && (get_dist(focus, user) <= 10))
			apply_focus_overlay()
			focus.throw_at(target, 10, 1)
			last_throw = world.time
		return


	proc/focus_object(var/obj/target)
		if(!istype(target,/obj))	return//Cant throw non objects atm might let it do mobs later
		if(target.anchored)	return//No throwing anchored things
		focus = target
		update_icon()
		apply_focus_overlay()
		return


	proc/apply_focus_overlay()
		if(!focus)	return
		var/obj/effect/overlay/O = new /obj/effect/overlay(locate(focus.x,focus.y,focus.z))
		O.name = "sparkles"
		O.anchored = 1
		O.density = 0
		O.layer = FLY_LAYER
		O.dir = pick(cardinal)
		O.icon = 'effects.dmi'
		O.icon_state = "nothing"
		flick("empdisable",O)
		spawn(5)
			del(O)
		return


	update_icon()
		overlays = null
		if(focus)
			overlays += "[focus.icon_state]"
		return

//equip_if_possible(obj/item/W, slot, del_on_fail = 1)
/*
		if(istype(user, /mob/living/carbon))
			if(user:mutations & TK && get_dist(source, user) <= 7)
				if(user:equipped())	return 0
				var/X = source:x
				var/Y = source:y
				var/Z = source:z
				spawn(0)
					//I really shouldnt put this here but i dont have a better idea

*/