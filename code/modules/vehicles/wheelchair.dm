/obj/vehicle/ridden/wheelchair //ported from Hippiestation (by Jujumatic)
	name = "wheelchair"
	desc = "A chair with big wheels. It looks like you can move in this on your own."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "wheelchair"
	layer = OBJ_LAYER
	max_integrity = 100
	armor = list(MELEE = 10, BULLET = 10, LASER = 10, ENERGY = 0, BOMB = 10, BIO = 0, RAD = 0, FIRE = 20, ACID = 30)	//Wheelchairs aren't super tough yo
	density = FALSE		//Thought I couldn't fix this one easily, phew
	/// Run speed delay is multiplied with this for vehicle move delay.
	var/delay_multiplier = 6.7
	/// This variable is used to specify which overlay icon is used for the wheelchair, ensures wheelchair can cover your legs
	var/overlay_icon = "wheelchair_overlay"
	///Determines the typepath of what the object folds into
	var/foldabletype = /obj/item/wheelchair

/obj/vehicle/ridden/wheelchair/Initialize()
	. = ..()
	make_ridable()

/obj/vehicle/ridden/wheelchair/ComponentInitialize()	//Since it's technically a chair I want it to have chair properties
	. = ..()
	AddComponent(/datum/component/simple_rotation,ROTATION_ALTCLICK | ROTATION_CLOCKWISE, CALLBACK(src, .proc/can_user_rotate),CALLBACK(src, .proc/can_be_rotated),null)

/obj/vehicle/ridden/wheelchair/obj_destruction(damage_flag)
	new /obj/item/stack/rods(drop_location(), 1)
	new /obj/item/stack/sheet/iron(drop_location(), 1)
	..()

/obj/vehicle/ridden/wheelchair/Destroy()
	if(has_buckled_mobs())
		var/mob/living/carbon/H = buckled_mobs[1]
		unbuckle_mob(H)
	return ..()

/obj/vehicle/ridden/wheelchair/Moved()
	. = ..()
	cut_overlays()
	playsound(src, 'sound/effects/roll.ogg', 75, TRUE)
	if(has_buckled_mobs())
		handle_rotation_overlayed()


/obj/vehicle/ridden/wheelchair/post_buckle_mob(mob/living/user)
	. = ..()
	handle_rotation_overlayed()

/obj/vehicle/ridden/wheelchair/post_unbuckle_mob()
	. = ..()
	cut_overlays()

/obj/vehicle/ridden/wheelchair/setDir(newdir)
	..()
	handle_rotation(newdir)

/obj/vehicle/ridden/wheelchair/wrench_act(mob/living/user, obj/item/I)	//Attackby should stop it attacking the wheelchair after moving away during decon
	..()
	to_chat(user, "<span class='notice'>You begin to detach the wheels...</span>")
	if(I.use_tool(src, user, 40, volume=50))
		to_chat(user, "<span class='notice'>You detach the wheels and deconstruct the chair.</span>")
		new /obj/item/stack/rods(drop_location(), 6)
		new /obj/item/stack/sheet/iron(drop_location(), 4)
		qdel(src)
	return TRUE

/obj/vehicle/ridden/wheelchair/proc/handle_rotation(direction)
	if(has_buckled_mobs())
		handle_rotation_overlayed()
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.setDir(direction)

/obj/vehicle/ridden/wheelchair/proc/handle_rotation_overlayed()
	cut_overlays()
	var/image/V = image(icon = icon, icon_state = overlay_icon, layer = FLY_LAYER, dir = src.dir)
	add_overlay(V)



/obj/vehicle/ridden/wheelchair/proc/can_be_rotated(mob/living/user)
	return TRUE

/obj/vehicle/ridden/wheelchair/proc/can_user_rotate(mob/living/user)
	var/mob/living/L = user
	if(istype(L))
		if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, !iscyborg(user)))
			return FALSE
	if(isobserver(user) && CONFIG_GET(flag/ghost_interaction))
		return TRUE
	return FALSE

/// I assign the ridable element in this so i don't have to fuss with hand wheelchairs and motor wheelchairs having different subtypes
/obj/vehicle/ridden/wheelchair/proc/make_ridable()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/wheelchair/hand)

/obj/vehicle/ridden/wheelchair/gold
	material_flags = MATERIAL_ADD_PREFIX | MATERIAL_AFFECT_STATISTICS
	desc = "Damn, he's been through a lot."
	icon_state = "gold_wheelchair"
	overlay_icon = "gold_wheelchair_overlay"
	max_integrity = 200
	armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 0, BOMB = 20, BIO = 0, RAD = 0, FIRE = 30, ACID = 40)
	custom_materials = list(/datum/material/gold = 10000)
	foldabletype = /obj/item/wheelchair/gold

/obj/item/wheelchair
	name = "wheelchair"
	desc = "A collapsed wheelchair that can be carried around."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "wheelchair_folded"
	inhand_icon_state = "wheelchair_folded"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	force = 8 //Force is same as a chair
	custom_materials = list(/datum/material/iron = 10000)
	var/unfolded_type = /obj/vehicle/ridden/wheelchair

/obj/item/wheelchair/gold
	name = "gold wheelchair"
	desc = "A collapsed, shiny wheelchair that can be carried around."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "wheelchair_folded_gold"
	inhand_icon_state = "wheelchair_folded_gold"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	force = 10
	unfolded_type = /obj/vehicle/ridden/wheelchair/gold

/obj/vehicle/ridden/wheelchair/MouseDrop(over_object, src_location, over_location)  //Lets you collapse wheelchair
	. = ..()
	if(over_object != usr || !Adjacent(usr) || !foldabletype)
		return FALSE
	if(!ishuman(usr) || !usr.canUseTopic(src, BE_CLOSE))
		return FALSE
	if(has_buckled_mobs())
		return FALSE
	usr.visible_message("<span class='notice'>[usr] collapses [src].</span>", "<span class='notice'>You collapse [src].</span>")
	var/obj/vehicle/ridden/wheelchair/wheelchair_folded = new foldabletype(get_turf(src))
	usr.put_in_hands(wheelchair_folded)
	qdel(src)

/obj/item/wheelchair/attack_self(mob/user)  //Deploys wheelchair on in-hand use
	deploy_wheelchair(user, user.loc)

/obj/item/wheelchair/proc/deploy_wheelchair(mob/user, atom/location)
	var/obj/vehicle/ridden/wheelchair/wheelchair_unfolded = new unfolded_type(location)
	wheelchair_unfolded.add_fingerprint(user)
	qdel(src)
