//has to be on living instead of carbon because of drones
/mob/living/proc/update_inv_slot_image(imageslot, suffix, imagelayer)
	var/obj/item/I = imageslot
	var/image/image_overlay

	var/target_icon = I.icon
	var/target_icon_state = I.icon_state + suffix

	if(I.item_state_icon)
		target_icon = I.item_state_icon
		target_icon_state = I.item_state + suffix

	if(imagelayer)
		image_overlay = image("icon"=target_icon, "icon_state"="[target_icon_state]", "layer"=-imagelayer)
	else
		image_overlay = image("icon"=target_icon, "icon_state"="[target_icon_state]")

	return image_overlay

//debug
/*
var/list/icon_states_cache = list()

/proc/build_updateicon_txt()
	var/textone
	var/texttwo
	var/textthree
	var/textfour
	for(var/A in typesof(/obj/item))
		var/obj/item/I = new A( locate(1,1,1) )
		if(!I) continue
		if(!icon_states_cache[I.icon])
			icon_states_cache[I.icon] = icon_states(I.icon, 2)

		var/found = 0
		if(!found && I.icon_state)
			for(var/suffix in list("belt", "back", "r", "l", "head", "ears", "eyes", "shoes", "mask", "e", "s_e", "gloves", "tie"))
				if((I.icon_state + "_" + suffix) in icon_states_cache[I.icon])
					if(I.item_state_icon)
						textone+="[I.type]\n"
					found = 1
					break

		if(!found && I.item_state)
			for(var/suffix in list("belt", "back", "r", "l", "head", "ears", "eyes", "shoes", "mask", "e", "s_e", "gloves", "tie"))
				if((I.item_state + "_" + suffix) in icon_states_cache[I.icon])
					if(!I.item_state_icon)
						texttwo+="[I.type] [I.icon]\n"
					found = 1
					break
		if(!found)
			if(I.item_state_icon)
				var/icon/K = new(I.item_state_icon)
				for(var/suffix in list("belt", "back", "r", "l", "head", "ears", "eyes", "shoes", "mask", "e", "s_e", "gloves"))
					if((I.item_state + "_" + suffix) in icon_states(K))
						found = 1
						break
				if(!found)
					textthree+="[I.type] [I.item_state_icon]\n"
		if(!found)
			if(I.item_state)
				textfour+="[I.type]"
		qdel(I)
	var/F1 = file("item_state_icon_to_null.txt")
	var/F2 = file("item_state_icon_to_add.txt")
	var/F3 = file("useless_item_state_icon.txt")
	var/F4 = file("useless_item_state.txt")
	fdel(F1)
	fdel(F2)
	fdel(F3)
	fdel(F4)
	F1 << textone
	F2 << texttwo
	F3 << textthree
	F4 << textfour
	world << "Completely successfully and written"
*/