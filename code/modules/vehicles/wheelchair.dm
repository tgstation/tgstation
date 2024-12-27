/obj/vehicle/ridden/wheelchair //ported from Hippiestation (by Jujumatic)
	name = "wheelchair"
	desc = "A chair with big wheels. It looks like you can move in this on your own."
	icon = 'icons/mob/rideables/vehicles.dmi'
	icon_state = "wheelchair"
	layer = OBJ_LAYER
	max_integrity = 100
	armor_type = /datum/armor/ridden_wheelchair
	density = FALSE
	interaction_flags_mouse_drop = ALLOW_RESTING

	/// Run speed delay is multiplied with this for vehicle move delay.
	var/delay_multiplier = 6.7
	/// This variable is used to specify which overlay icon is used for the wheelchair, ensures wheelchair can cover your legs
	var/overlay_icon = "wheelchair_overlay"
	var/image/wheels_overlay
	///Determines the typepath of what the object folds into
	var/foldabletype = /obj/item/wheelchair
	///Bell attached to the wheelchair, if we have one.
	var/obj/structure/desk_bell/bell_attached

/datum/armor/ridden_wheelchair
	melee = 10
	bullet = 10
	laser = 10
	bomb = 10
	fire = 20
	acid = 30

/obj/vehicle/ridden/wheelchair/generate_actions()
	. = ..()
	if(!bell_attached)
		return
	initialize_controller_action_type(/datum/action/vehicle/ridden/wheelchair/bell, VEHICLE_CONTROL_DRIVE)

/obj/vehicle/ridden/wheelchair/Initialize(mapload)
	. = ..()
	make_ridable()
	wheels_overlay = image(icon, overlay_icon, ABOVE_MOB_LAYER)
	ADD_TRAIT(src, TRAIT_NO_IMMOBILIZE, INNATE_TRAIT)
	AddComponent(/datum/component/simple_rotation) //Since it's technically a chair I want it to have chair properties
	AddElement(/datum/element/noisy_movement, volume = 75)

/obj/vehicle/ridden/wheelchair/atom_destruction(damage_flag)
	new /obj/item/stack/rods(drop_location(), 1)
	new /obj/item/stack/sheet/iron(drop_location(), 1)
	return ..()

/obj/vehicle/ridden/wheelchair/post_buckle_mob(mob/living/user)
	. = ..()
	update_appearance()

/obj/vehicle/ridden/wheelchair/post_unbuckle_mob()
	. = ..()
	update_appearance()

/obj/vehicle/ridden/wheelchair/wrench_act(mob/living/user, obj/item/tool) //Attackby should stop it attacking the wheelchair after moving away during decon
	..()
	balloon_alert(user, "disassembling")
	if(!tool.use_tool(src, user, 4 SECONDS, volume=50))
		return ITEM_INTERACT_SUCCESS
	to_chat(user, span_notice("You detach the wheels and deconstruct the chair."))
	new /obj/item/stack/rods(drop_location(), 6)
	new /obj/item/stack/sheet/iron(drop_location(), 4)
	qdel(src)
	return ITEM_INTERACT_SUCCESS


/obj/vehicle/ridden/wheelchair/update_overlays()
	. = ..()
	if(has_buckled_mobs())
		. += wheels_overlay
	if(bell_attached)
		. += "wheelchair_bell"


/// I assign the ridable element in this so i don't have to fuss with hand wheelchairs and motor wheelchairs having different subtypes
/obj/vehicle/ridden/wheelchair/proc/make_ridable()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/wheelchair/hand)

///A reward item for obtaining 5K hardcore random points. Do not use for anything else
/obj/vehicle/ridden/wheelchair/gold
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_AFFECT_STATISTICS
	desc = "Damn, must've been through a lot."
	icon_state = "gold_wheelchair"
	overlay_icon = "gold_wheelchair_overlay"
	max_integrity = 200
	armor_type = /datum/armor/wheelchair_gold
	custom_materials = list(/datum/material/gold = SHEET_MATERIAL_AMOUNT*5)
	foldabletype = /obj/item/wheelchair/gold

/obj/item/wheelchair
	name = "wheelchair"
	desc = "A collapsed wheelchair that can be carried around."
	icon = 'icons/mob/rideables/vehicles.dmi'
	icon_state = "wheelchair_folded"
	inhand_icon_state = "wheelchair_folded"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	force = 8 //Force is same as a chair
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*5)
	///The wheelchair vehicle type we create when we unfold this chair
	var/unfolded_type = /obj/vehicle/ridden/wheelchair

///A reward item for obtaining 5K hardcore random points. Do not use for anything else
/obj/item/wheelchair/gold
	name = "gold wheelchair"
	desc = "A collapsed, shiny wheelchair that can be carried around."
	icon = 'icons/mob/rideables/vehicles.dmi'
	icon_state = "wheelchair_folded_gold"
	inhand_icon_state = "wheelchair_folded_gold"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	force = 10
	custom_materials = list(/datum/material/gold = SHEET_MATERIAL_AMOUNT*5)
	unfolded_type = /obj/vehicle/ridden/wheelchair/gold

/datum/armor/wheelchair_gold
	melee = 20
	bullet = 20
	laser = 20
	bomb = 20
	fire = 30
	acid = 40

/obj/vehicle/ridden/wheelchair/mouse_drop_dragged(atom/over_object, mob/user)  //Lets you collapse wheelchair
	if(over_object != user || !foldabletype || !ishuman(user))
		return FALSE
	if(has_buckled_mobs())
		return FALSE
	user.visible_message(span_notice("[user] collapses [src]."), span_notice("You collapse [src]."))
	var/obj/vehicle/ridden/wheelchair/wheelchair_folded = new foldabletype(get_turf(src))
	user.put_in_hands(wheelchair_folded)
	qdel(src)

/obj/item/wheelchair/attack_self(mob/user)  //Deploys wheelchair on in-hand use
	deploy_wheelchair(user, user.loc)

/obj/item/wheelchair/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(isopenturf(interacting_with))
		deploy_wheelchair(user, interacting_with)
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/item/wheelchair/proc/deploy_wheelchair(mob/user, atom/location)
	var/obj/vehicle/ridden/wheelchair/wheelchair_unfolded = new unfolded_type(location)
	wheelchair_unfolded.add_fingerprint(user)
	qdel(src)


///attaches bell to the wheelchair
/obj/vehicle/ridden/wheelchair/proc/attach_bell(obj/structure/desk_bell/bell)
	bell_attached = bell
	bell.forceMove(src)
	generate_actions()
	update_appearance()

/obj/vehicle/ridden/wheelchair/examine(mob/user)
	. =..()
	if(bell_attached)
		. += span_notice("There is \a [bell_attached] attached to the handle.")

/obj/vehicle/ridden/wheelchair/Destroy()
	if(bell_attached)
		remove_bell()
	return ..()

/obj/vehicle/ridden/wheelchair/proc/remove_bell()
	bell_attached.forceMove(get_turf(src))
	usr.visible_message(span_notice("[bell_attached] falls off!"))
	bell_attached = null
	update_appearance()

