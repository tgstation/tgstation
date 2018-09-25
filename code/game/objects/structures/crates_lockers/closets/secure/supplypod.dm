//The "BDPtarget" temp visual is created by the expressconsole, which in turn makes two things: a falling droppod animation, and the droppod itself.
#define POD_STANDARD 0
#define POD_BLUESPACE 1
#define POD_CENTCOM 2

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
	var/atom/other_delivery

/obj/structure/closet/supplypod/bluespacepod
	name = "Bluespace Drop Pod"
	desc = "A Nanotrasen Bluespace drop pod. Teleports back to CentCom after delivery."
	icon_state = "bluespacepod"

/obj/structure/closet/supplypod/bluespacepod/centcompod
	name = "CentCom Drop Pod"
	desc = "A Nanotrasen Bluespace drop pod, this one has been marked with Central Command's designations. Teleports back to Centcom after delivery."
	icon_state = "centcompod"

/obj/structure/closet/supplypod/Initialize(mapload, SO)
	. = ..()
	if(istype(SO, /datum/supply_order))
		SupplyOrder = SO//uses Supply Order passed from expressconsole into BDPtarget
	else
		other_delivery = SO//if the object is not a supply order, we force the object in the pod
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
	if(SupplyOrder)
		SupplyOrder.generate(T)//not called during populateContents as supplyorder generation requires a turf
	if(other_delivery)
		new other_delivery(T)
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
	icon_state = "supplypod_falling"

/obj/effect/temp_visual/DPfall/Initialize(dropLocation, podID)
	if (podID == POD_STANDARD)
		icon_state = "supplypod_falling"
		name = "Supply Drop Pod"
	else if (podID == POD_BLUESPACE)
		icon_state = "bluespacepod_falling"
		name = "Bluespace Drop Pod"
	else
		icon_state = "centcompod_falling"
		name = "CentCom Drop Pod"
	. = ..()

//------------------------------------TEMPORARY_VISUAL-------------------------------------//
/obj/effect/DPtarget
	icon = 'icons/mob/actions/actions_items.dmi'
	icon_state = "sniper_zoom"
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	light_range = 2
	var/obj/effect/temp_visual/fallingPod

/obj/effect/DPtarget/Initialize(mapload, SO, podID)
	. = ..()
	var/delayTime = 17			//We're forcefully adminspawned, make it faster
	switch(podID)
		if(POD_STANDARD)
			delayTime = 30
		if(POD_BLUESPACE)
			delayTime = 15
		if(POD_CENTCOM)			//Admin smite, even faster.
			delayTime = 5//speedy delivery

	addtimer(CALLBACK(src, .proc/beginLaunch, SO, podID), delayTime)//standard pods take 3 seconds to come in, bluespace pods take 1.5

/obj/effect/DPtarget/proc/beginLaunch(SO, podID)
	fallingPod = new /obj/effect/temp_visual/DPfall(drop_location(), podID)
	animate(fallingPod, pixel_z = 0, time = 3, easing = LINEAR_EASING)//make and animate a falling pod
	addtimer(CALLBACK(src, .proc/endLaunch, SO, podID), 3, TIMER_CLIENT_TIME)//fall 0.3seconds

/obj/effect/DPtarget/proc/endLaunch(SO, podID)
	if(podID == POD_STANDARD)
		new /obj/structure/closet/supplypod(drop_location(), SO)//pod is created
		explosion(src,0,0,2, flame_range = 3) //less advanced equipment than bluespace pod, so larger explosion when landing
	else if(podID == POD_BLUESPACE)
		new /obj/structure/closet/supplypod/bluespacepod(drop_location(), SO)//pod is created
		explosion(src,0,0,2, flame_range = 1) //explosion and camshake (shoutout to @cyberboss)
	else if(podID == POD_CENTCOM)
		new /obj/structure/closet/supplypod/bluespacepod/centcompod(drop_location(), SO)//CentCom supplypods dont create explosions; instead they directly deal 40 fire damage to people on the turf
		var/turf/T = get_turf(src)
		playsound(src, "explosion", 80, 1)
		new /obj/effect/hotspot(T)
		T.hotspot_expose(700, 50, 1)//same as fireball
		for(var/mob/living/M in T.contents)
			M.adjustFireLoss(40)
	else			//We're buildmoded or directly spawned, blow them up damnit.
		new /obj/structure/closet/supplypod/bluespacepod/centcompod(drop_location(), SO)
		explosion(src, 0, 0, 2, flame_range = 3)
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
