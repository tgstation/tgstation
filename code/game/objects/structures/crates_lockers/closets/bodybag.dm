
/obj/structure/closet/body_bag
	name = "body bag"
	desc = "A plastic bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag"
	density = FALSE
	mob_storage_capacity = 2
	open_sound = 'sound/items/zip.ogg'
	close_sound = 'sound/items/zip.ogg'
	open_sound_volume = 15
	close_sound_volume = 15
	integrity_failure = 0
	material_drop = /obj/item/stack/sheet/cloth
	delivery_icon = null //unwrappable
	anchorable = FALSE
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	drag_slowdown = 0
	var/foldedbag_path = /obj/item/bodybag
	var/obj/item/bodybag/foldedbag_instance = null
	var/tagged = FALSE // so closet code knows to put the tag overlay back

/obj/structure/closet/body_bag/Destroy()
	// If we have a stored bag, and it's in nullspace (not in someone's hand), delete it.
	if (foldedbag_instance && !foldedbag_instance.loc)
		QDEL_NULL(foldedbag_instance)
	return ..()

/obj/structure/closet/body_bag/attackby(obj/item/I, mob/user, params)
	if (istype(I, /obj/item/pen) || istype(I, /obj/item/toy/crayon))
		if(!user.is_literate())
			to_chat(user, "<span class='notice'>You scribble illegibly on [src]!</span>")
			return
		var/t = stripped_input(user, "What would you like the label to be?", name, null, 53)
		if(user.get_active_held_item() != I)
			return
		if(!user.canUseTopic(src, BE_CLOSE))
			return
		if(t)
			name = "[initial(name)] - [t]"
			tagged = TRUE
			update_appearance()
		else
			name = initial(name)
		return
	else if(I.tool_behaviour == TOOL_WIRECUTTER)
		to_chat(user, "<span class='notice'>You cut the tag off [src].</span>")
		name = "body bag"
		tagged = FALSE
		update_appearance()

/obj/structure/closet/body_bag/update_overlays()
	. = ..()
	if(tagged)
		. += "bodybag_label"

/obj/structure/closet/body_bag/open(mob/living/user, force = FALSE)
	. = ..()
	if(.)
		mouse_drag_pointer = MOUSE_INACTIVE_POINTER

/obj/structure/closet/body_bag/close()
	. = ..()
	if(.)
		density = FALSE
		mouse_drag_pointer = MOUSE_ACTIVE_POINTER

/obj/structure/closet/body_bag/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(over_object == usr && Adjacent(usr) && (in_range(src, usr) || usr.contents.Find(src)))
		if(!attempt_fold(usr))
			return
		perform_fold(usr)
		qdel(src)

		/**
		  * Checks to see if we can fold. Return TRUE to actually perform the fold and delete.
			*
		  * Arguments:
		  * * the_folder - over_object of MouseDrop aka usr
		  */
/obj/structure/closet/body_bag/proc/attempt_fold(mob/living/carbon/human/the_folder)
	. = FALSE
	if(!istype(the_folder))
		return
	if(opened)
		to_chat(the_folder, "<span class='warning'>You wrestle with [src], but it won't fold while unzipped.</span>")
		return
	if(contents.len)
		to_chat(the_folder, "<span class='warning'>There are too many things inside of [src] to fold it up!</span>")
		return
	// toto we made it!
	return TRUE

	/**
		* Performs the actual folding. Deleting is automatic, please do not include.
		*
		* Arguments:
		* * the_folder - over_object of MouseDrop aka usr
		*/
/obj/structure/closet/body_bag/proc/perform_fold(mob/living/carbon/human/the_folder)
	visible_message("<span class='notice'>[usr] folds up [src].</span>")
	var/obj/item/bodybag/B = foldedbag_instance || new foldedbag_path
	the_folder.put_in_hands(B)

/obj/structure/closet/body_bag/bluespace
	name = "bluespace body bag"
	desc = "A bluespace body bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bluebodybag"
	foldedbag_path = /obj/item/bodybag/bluespace
	mob_storage_capacity = 15
	max_mob_size = MOB_SIZE_LARGE

/obj/structure/closet/body_bag/bluespace/attempt_fold(mob/living/carbon/human/the_folder)
	. = FALSE
	//copypaste zone, we do not want the content check so we don't want inheritance
	if(!istype(the_folder))
		return
	if(opened)
		to_chat(the_folder, "<span class='warning'>You wrestle with [src], but it won't fold while unzipped.</span>")
		return
	//end copypaste zone
	if(contents.len >= mob_storage_capacity / 2)
		to_chat(usr, "<span class='warning'>There are too many things inside of [src] to fold it up!</span>")
		return
	for(var/obj/item/bodybag/bluespace/B in src)
		to_chat(usr, "<span class='warning'>You can't recursively fold bluespace body bags!</span>" )
		return
	return TRUE

/obj/structure/closet/body_bag/bluespace/perform_fold(mob/living/carbon/human/the_folder)
	visible_message("<span class='notice'>[usr] folds up [src].</span>")
	var/obj/item/bodybag/B = foldedbag_instance || new foldedbag_path
	var/max_weight_of_contents = initial(B.w_class)
	for(var/am in contents)
		var/atom/movable/content = am
		content.forceMove(B)
		if(isliving(content))
			to_chat(content, "<span class='userdanger'>You're suddenly forced into a tiny, compressed space!</span>")
		if(!isitem(content))
			max_weight_of_contents = max(WEIGHT_CLASS_BULKY, max_weight_of_contents)
			continue
		var/obj/item/A_is_item = content
		if(A_is_item.w_class < max_weight_of_contents)
			continue
		max_weight_of_contents = A_is_item.w_class
	B.w_class = max_weight_of_contents
	usr.put_in_hands(B)
