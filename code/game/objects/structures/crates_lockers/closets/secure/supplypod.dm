//The "BDPtarget" temp visual is created by the expressconsole, which in turn makes two things: a falling droppod animation, and the droppod itself.


//------------------------------------SUPPLY POD-------------------------------------//
/obj/structure/closet/supplypod
	name = "Supply Drop Pod"
	desc = "A Nanotrasen supply drop pod."
	icon = 'icons/obj/2x2.dmi'
	icon_state = "supplypod"
	pixel_x = -16//2x2 sprite
	pixel_y = -5
	layer = TABLE_LAYER//so that the crate inside doesn't appear underneath
	allow_objects = TRUE
	allow_dense = TRUE
	delivery_icon = null
	can_weld_shut = FALSE
	armor = list("melee" = 30, "bullet" = 50, "laser" = 50, "energy" = 100, "bomb" = 90, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80)
	anchored = TRUE
	anchorable = FALSE
	var/datum/supply_order/SupplyOrder

/obj/structure/closet/supplypod/bluespacepod
	name = "Bluespace Drop Pod"
	desc = "A Nanotrasen Bluespace drop pod. Teleports back to Centcom after delivery."
	icon_state = "bluespacepod"

/obj/structure/closet/supplypod/Initialize(mapload, datum/supply_order/so)
	. = ..()
	SupplyOrder = so//uses Supply Order passed from expressconsole into BDPtarget
	addtimer(CALLBACK(src, .proc/open), 30)//open 3seconds after appearing

/obj/structure/closet/supplypod/update_icon()
	cut_overlays()
	if (opened)
		add_overlay("[icon_state]_open")
	else
		add_overlay("[icon_state]_door")

/obj/structure/closet/supplypod/bluespacepod/tool_interact(obj/item/W, mob/user)
	return TRUE

/obj/structure/closet/supplypod/toggle(mob/living/user)
	return

/obj/structure/closet/supplypod/open()
	var/turf/T = get_turf(src)
	opened = TRUE
	SupplyOrder.generate(T)//not called during populateContents as supplyorder generation requires a turf
	update_icon()
	playsound(src, open_sound, 15, 1, -3)
	if(istype(src,/obj/structure/closet/supplypod/bluespacepod))
		addtimer(CALLBACK(src, .proc/sparks), 30)//if bluespace, then 3 seconds after opening, make some sparks and delete		
 		
/obj/structure/closet/supplypod/proc/sparks()//sparks cant be called from addtimer		
 	do_sparks(5, TRUE, src)		
 	qdel(src)//no need for QDEL_IN if we already have a timer 

/obj/structure/closet/supplypod/Destroy()//make some sparks b4 deletion
	QDEL_NULL(SupplyOrder)
	return ..()

//------------------------------------FALLING SUPPLY POD-------------------------------------//
/obj/effect/temp_visual/DPfall
	icon = 'icons/obj/2x2.dmi'
	pixel_x = -16
	pixel_y = -5
	pixel_z = 200
	desc = "Get out of the way!"
	layer = FLY_LAYER//that wasnt flying, that was falling with style!
	randomdir = FALSE

/obj/effect/temp_visual/DPfall/Initialize(var/dropLocation, var/podID)
	if (podID == 1)
		icon_state = "bluespacepod_falling"
		name = "Bluespace Drop Pod"
	else
		icon_state = "supplypod_falling"
		name = "Supply Drop Pod"
	. = ..()

//------------------------------------TEMPORARY_VISUAL-------------------------------------//
/obj/effect/DPtarget
	icon = 'icons/mob/actions/actions_items.dmi'
	icon_state = "sniper_zoom"
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	light_range = 2
	var/obj/effect/temp_visual/fallingPod

/obj/effect/DPtarget/Initialize(mapload, datum/supply_order/SO, var/podID)
	. = ..()
	addtimer(CALLBACK(src, .proc/beginLaunch, SO, podID), 30)//wait 3 seconds

/obj/effect/DPtarget/proc/beginLaunch(datum/supply_order/SO, var/podID)
	fallingPod = new /obj/effect/temp_visual/DPfall(drop_location(), podID)
	animate(fallingPod, pixel_z = 0, time = 3, easing = LINEAR_EASING)//make and animate a falling pod
	addtimer(CALLBACK(src, .proc/endLaunch, SO, podID), 3, TIMER_CLIENT_TIME)//fall 0.3seconds 

/obj/effect/DPtarget/proc/endLaunch(datum/supply_order/SO, var/podID)
	if (podID == 1)//podID 1 = bluespace supplypod, podID 0 = standard supplypod
		new /obj/structure/closet/supplypod/bluespacepod(drop_location(), SO)//pod is created
		explosion(src,0,0,2, flame_range = 1) //explosion and camshake (shoutout to @cyberboss)
	else
		new /obj/structure/closet/supplypod(drop_location(), SO)//pod is created
		explosion(src,0,0,2, flame_range = 3) //less advanced equipment than bluespace pod, so larger explosion when landing
	qdel(src)

/obj/effect/DPtarget/Destroy()
	QDEL_NULL(fallingPod)//delete falling pod after animation's over
	return ..()

//------------------------------------UPGRADES-------------------------------------//
/obj/item/disk/cargo/bluespace_pod
	name = "Bluespace Drop Pod Upgrade"
	desc = "This disk provides a firmware update to the Express Supply Console, granting the use of Nanotrasen's Bluespace Drop Pods to the supply department."
	icon = 'icons/obj/module.dmi'
	icon_state = "cargodisk"
	item_state = "card-id"
	w_class = WEIGHT_CLASS_SMALL