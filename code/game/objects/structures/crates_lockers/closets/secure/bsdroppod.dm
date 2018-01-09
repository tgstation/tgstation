//The "BDPtarget" temp visual is created by the expressconsole, which in turn makes two things: a falling droppod animation, and the droppod itself.


//------------------------------------BLUESPACE DROP POD-------------------------------------//
/obj/structure/closet/bsdroppod
	name = "Bluespace Drop Pod"
	desc = "A Nanotrasen supply drop pod."
	icon = 'icons/obj/2x2.dmi'
	icon_state = "BDP"
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

/obj/structure/closet/bsdroppod/Initialize(mapload, datum/supply_order/so)
	. = ..()
	SupplyOrder = so//uses Supply Order passed from expressconsole into BDPtarget
	addtimer(CALLBACK(src, .proc/open), 30)//open 3seconds after appearing

/obj/structure/closet/bsdroppod/update_icon()
	cut_overlays()
	if (opened)
		add_overlay("BDP_open")
	else
		add_overlay("BDP_door")

/obj/structure/closet/bsdroppod/tool_interact(obj/item/W, mob/user)
	return TRUE

/obj/structure/closet/bsdroppod/toggle(mob/living/user)
	return

/obj/structure/closet/bsdroppod/open()
	var/turf/T = get_turf(src)
	opened = TRUE
	SupplyOrder.generate(T)//not called during populateContents as supplyorder generation requires a turf
	update_icon()
	playsound(src, open_sound, 15, 1, -3)
	addtimer(CALLBACK(src, .proc/sparks), 30)//3 seconds after opening, make some sparks and delete

/obj/structure/closet/bsdroppod/proc/sparks()//sparks cant be called from addtimer
	do_sparks(5, TRUE, src)
	qdel(src)//no need for QDEL_IN if we already have a timer 

/obj/structure/closet/bsdroppod/Destroy()//make some sparks b4 deletion
	QDEL_NULL(SupplyOrder)
	return ..()

//------------------------------------FALLING BLUESPACE DROP POD-------------------------------------//
/obj/effect/temp_visual/BDPfall
	icon = 'icons/obj/2x2.dmi'
	icon_state = "BDP_falling"
	pixel_x = -16
	pixel_y = -5
	pixel_z = 200
	name = "Bluespace Drop Pod"
	desc = "Get out of the way!"
	layer = FLY_LAYER//that wasnt flying, that was falling with style!
	randomdir = FALSE

//------------------------------------TEMPORARY_VISUAL-------------------------------------//
/obj/effect/BDPtarget
	icon = 'icons/mob/actions/actions_items.dmi'
	icon_state = "sniper_zoom"
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	light_range = 2
	var/obj/effect/temp_visual/fallingPod

/obj/effect/BDPtarget/Initialize(mapload, datum/supply_order/SO)
	. = ..()
	addtimer(CALLBACK(src, .proc/beginLaunch, SO), 30)//wait 3 seconds

/obj/effect/BDPtarget/proc/beginLaunch(datum/supply_order/SO)
	fallingPod = new /obj/effect/temp_visual/BDPfall(drop_location())
	animate(fallingPod, pixel_z = 0, time = 3, easing = LINEAR_EASING)//make and animate a falling pod
	addtimer(CALLBACK(src, .proc/endLaunch, SO), 3, TIMER_CLIENT_TIME)//fall 0.3seconds 

/obj/effect/BDPtarget/proc/endLaunch(datum/supply_order/SO)
	new /obj/structure/closet/bsdroppod(drop_location(), SO)//pod is created
	explosion(src,0,0,2, flame_range = 2) //explosion and camshake (shoutout to @cyberboss)
	qdel(src)

/obj/effect/BDPtarget/Destroy()
	QDEL_NULL(fallingPod)//delete falling pod after animation's over
	return ..()