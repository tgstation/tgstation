#define SHARP_DESC_ADD "This one appears to have a bunch of sharp edges peeking out from under its leaves."
#define EMAG_DESC_ADD "This plant appears to have been illegally modified."

/obj/item/twohanded/required/kirbyplants
	var/disable = 0 //for screwdriver
	var/is_sharpened = 0 //to prevent multiple sharpenings
	var/sharp_prefix = "thorny"

/obj/item/twohanded/required/kirbyplants/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/screwdriver)) //If you screwdrive it, it is attachable
		add_fingerprint(user)
		disable = !disable
		if(disable)
			user.visible_message("[user] prepares the foliage for connection.", "<span class='notice'>The screwdriver reveals a panel labelled 'INSERT SHARP ITEM HERE'...</span>")
		if(!disable)
			user.visible_message("[user] impedes the foliage from connection.", "<span class='notice'>You close the panel back up.</span>")
	if(W.is_sharp() && disable)  //If screwdriven and the item is sharp, it creates sharp plant
		if(is_sharpened)
			var/mob/living/carbon/C = user
			var/hit_hand = ((user.active_hand_index % 2 == 0) ? "r_" : "l_") + "arm"
			user.visible_message("Tries to place an object among the plant's branches, but there's already something sharp inside. Be careful!", "<span class='notice'>You cut yourself on the plant! It's already full...</span>")
			C.apply_damage(5, BRUTE, hit_hand)
		else
			var/item_name=W.name
			user.visible_message("[user] places something sharp inside the plant's branches..", "<span class='notice'>You insert the [item_name] into the panel and close it. The plant suddenly seems more dangerous.</span>")
			name = "[sharp_prefix] [name]"
			desc = "[desc] " + SHARP_DESC_ADD
			is_sharpened = 1
			force = W.force
			sharpness = W.sharpness
			hitsound='hippiestation/sound/weapons/sharpBushHit.ogg' //cool sound
			qdel(W)
			disable = !disable
	if(istype(W, /obj/item/reagent_containers) && (obj_flags & EMAGGED))
		if(W.reagents.has_reagent("lean"))
			W.reagents.clear_reagents()
			playsound(src.loc, 'hippiestation/sound/effects/pottedLeanSpawnSound.ogg', 25)
			new /mob/living/simple_animal/hostile/retaliate/pottedlean(get_turf(src))
			qdel(src)
	else
		return ..()

/obj/item/twohanded/required/kirbyplants/emag_act(mob/user)
	do_sparks(8, FALSE, get_turf(src))
	user.visible_message("<span class='warning'>Sparks burst from the plant as a jolt of electricity courses through your arm.</span>")
	var/obj/item/new_plant = new /obj/item/kirbyplants_onehanded(get_turf(src))
	new_plant.icon_state = src.icon_state
	qdel(src)


/obj/item/twohanded/required/kirbyplants/photosynthetic/emag_act(mob/user) //do not emag this one!
	explosion(get_turf(src), 0, 1, 5, flame_range = 5)
	qdel(src)

/obj/item/twohanded/required/kirbyplants/equipped(mob/user, slot)
	if((obj_flags & EMAGGED) && wielded)
		unwield(user) //This is a ghetto way to make it one-handed and it works
	var/image/I = image(icon = 'icons/obj/flora/plants.dmi' , icon_state = src.icon_state, loc = user)
	I.copy_overlays(src)
	I.override = 1
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/everyone, "sneaking_mission", I)
	I.layer = ABOVE_MOB_LAYER
	
	
/obj/item/kirbyplants_onehanded
	name = "potted plant"
	icon = 'icons/obj/flora/_flora.dmi'
	icon_state = "random_plant"
	var/list/static/states
	desc = "An extra little bit of nature contained in a pot."
	layer = ABOVE_MOB_LAYER
	w_class = WEIGHT_CLASS_HUGE
	force = 10
	throwforce = 13
	throw_speed = 2
	throw_range = 4
	var/disable = 0 //for screwdriver
	var/is_sharpened = 0 //to prevent multiple sharpenings
	var/sharp_prefix = "thorny"
	
obj/item/kirbyplants_onehanded/equipped(mob/living/user)
	var/image/I = image(icon = 'icons/obj/flora/plants.dmi' , icon_state = src.icon_state, loc = user)
	I.copy_overlays(src)
	I.override = 1
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/everyone, "sneaking_mission", I)
	I.layer = ABOVE_MOB_LAYER
	..()

/obj/item/kirbyplants_onehanded/dropped(mob/living/user)
	..()
	user.remove_alt_appearance("sneaking_mission")
	
/obj/item/kirbyplants_onehanded/Initialize()
	. = ..()
	icon = 'icons/obj/flora/plants.dmi'
	if(!states)
		generate_states()
	icon_state = pick(states)

/obj/item/kirbyplants_onehanded/proc/generate_states()
	states = list()
	for(var/i in 1 to 25)
		var/number
		if(i < 10)
			number = "0[i]"
		else
			number = "[i]"
		states += "plant-[number]"
	states += "applebush"

/obj/item/kirbyplants_onehanded/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/screwdriver)) //If you screwdrive it, it is attachable
		add_fingerprint(user)
		disable = !disable
		if(disable)
			user.visible_message("[user] prepares the foliage for connection.", "<span class='notice'>The screwdriver reveals a panel labelled 'INSERT SHARP ITEM HERE'...</span>")
		if(!disable)
			user.visible_message("[user] impedes the foliage from connection.", "<span class='notice'>You close the panel back up.</span>")
	if(W.is_sharp() && disable)  //If screwdriven and the item is sharp, it creates sharp plant
		if(is_sharpened)
			var/mob/living/carbon/C = user
			var/hit_hand = ((user.active_hand_index % 2 == 0) ? "r_" : "l_") + "arm"
			user.visible_message("Tries to place an object among the plant's branches, but there's already something sharp inside. Be careful!", "<span class='notice'>You cut yourself on the plant! It's already full...</span>")
			C.apply_damage(5, BRUTE, hit_hand)
		else
			var/item_name=W.name
			user.visible_message("[user] places something sharp inside the plant's branches..", "<span class='notice'>You insert the [item_name] into the panel and close it. The plant suddenly seems more dangerous.</span>")
			name = "[sharp_prefix] [name]"
			desc = "[desc] " + SHARP_DESC_ADD
			is_sharpened = 1
			force = W.force
			sharpness = W.sharpness
			hitsound='hippiestation/sound/weapons/sharpBushHit.ogg' //cool sound
			qdel(W)
			disable = !disable
	if(istype(W, /obj/item/reagent_containers)) //You have to emag a plant to get this item, so it shouldn't need a check for emagging again
		if(W.reagents.has_reagent("lean"))
			W.reagents.clear_reagents()
			playsound(src.loc, 'hippiestation/sound/effects/pottedLeanSpawnSound.ogg', 25)
			new /mob/living/simple_animal/hostile/retaliate/pottedlean(get_turf(src))
			qdel(src)
	else
		return ..()
