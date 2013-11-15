/* Chameleon boxes!
Can hold everything a normal box can, but can be disguised as any item sized normal or smaller!
By Miauw */
/obj/item/weapon/storage/box/chameleon
	name = "box"
	desc = "It's just an ordinary box."
	foldable = null
	var/active = 0
	var/saved_name //These vars contain info about the scanned object. Mostly self-explanatory.
	var/saved_desc
	var/saved_icon
	var/saved_icon_state
	var/saved_item_state
	origin_tech = "syndicate=2;magnets=1"

/obj/item/weapon/storage/box/chameleon/attack_self(mob/user)
	toggle()

/obj/item/weapon/storage/box/chameleon/afterattack(atom/target, mob/user , proximity)
	if(!proximity) return
	if(!active)
		if(target.loc != src) //It can be everything you want it to be~ //Now it can truely be everything you want it to be, thanks to Pete. Have fun with your dildo-filled holographic rwalls.
			playsound(get_turf(src), 'sound/weapons/flash.ogg', 100, 1, -6)
			user << "<span class='notice'>Scanned [target].</span>"
			saved_name = target.name
			saved_desc = target.desc
			saved_icon = target.icon
			saved_icon_state = target.icon_state
			saved_opaque = target.opaque
			if(istype(target, /obj/item))
				var/obj/item/targetitem = target //Neccesary for item_state
				saved_item_state = targetitem.item_state

/obj/item/weapon/storage/box/chameleon/proc/toggle()
	if(active)
		playsound(get_turf(src), 'sound/effects/pop.ogg', 100, 1, -6)
		name = initial(name)
		desc = initial(desc)
		icon_state = initial(icon_state)
		icon = initial(icon)
		item_state = initial(item_state)
		active = 0
		//world << "deactivated"

	else if(!active && saved_name) //Only one saved_ var is checked because they're all set at the same time.
		playsound(get_turf(src), 'sound/effects/pop.ogg', 100, 1, -6)

		name = saved_name //Set the box's appearance
		desc = saved_desc
		icon = saved_icon
		icon_state = saved_icon_state
		item_state = saved_item_state
		opaque = saved_opaque

		saved_name = null //Reset the vars.
		saved_desc = null
		saved_icon = null
		saved_icon_state = null
		saved_item_state = null
		saved_opaque = null

		//world << "activated"
		active = 1
	if(istype(loc, /mob/living/carbon)) //Update inhands (hopefully)
		var/mob/living/carbon/C = loc
		C.update_inv_l_hand()
		C.update_inv_r_hand()

/obj/item/weapon/storage/box/chameleon/handle_item_insertion(obj/item/W, prevent_warning = 0)
	if(active) //Can't push things trough the cloaking field from the outside.
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 0, src)
		s.start()
		toggle()
		return
	..()