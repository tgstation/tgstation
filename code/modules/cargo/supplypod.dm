//The "BDPtarget" temp visual is created by anything that "launches" a supplypod.  It makes two things: a falling droppod animation, and the droppod itself.
//------------------------------------SUPPLY POD-------------------------------------//
/obj/structure/closet/supplypod
	name = "supply pod" //Names and descriptions are normally created with the setStyle() proc during initialization, but we have these default values here as a failsafe
	desc = "A Nanotrasen supply drop pod."
	icon = 'icons/obj/supplypods.dmi'
	icon_state = "supplypod"
	pixel_x = -16 //2x2 sprite
	pixel_y = -5
	layer = TABLE_LAYER //So that the crate inside doesn't appear underneath
	allow_objects = TRUE
	allow_dense = TRUE
	delivery_icon = null
	can_weld_shut = FALSE
	armor = list("melee" = 30, "bullet" = 50, "laser" = 50, "energy" = 100, "bomb" = 100, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 80)
	anchored = TRUE //So it cant slide around after landing
	anchorable = FALSE
	//*****NOTE*****: Many of these comments are similarly described in centcom_podlauncher.dm. If you change them here, please consider doing so in the centcom podlauncher code as well!
	var/adminNamed = FALSE //Determines whether or not the pod has been named by an admin. If true, the pod's name will not get overridden when the style of the pod changes (changing the style of the pod normally also changes the name+desc)
	var/bluespace = FALSE //If true, the pod deletes (in a shower of sparks) after landing
	var/landingDelay = 30 //How long the pod takes to land after launching
	var/openingDelay = 30 //How long the pod takes to open after landing
	var/departureDelay = 30 //How long the pod takes to leave after opening (if bluespace=true, it deletes. if reversing=true, it flies back to centcom)
	var/damage = 0 //Damage that occurs to any mob under the pod when it lands.
	var/effectStun = FALSE //If true, stuns anyone under the pod when it launches until it lands, forcing them to get hit by the pod. Devilish!
	var/effectLimb = FALSE //If true, pops off a limb (if applicable) from anyone caught under the pod when it lands
	var/effectGib = FALSE //If true, anyone under the pod will be gibbed when it lands
	var/effectStealth = FALSE //If true, a target icon isnt displayed on the turf where the pod will land
	var/effectQuiet = FALSE //The female sniper. If true, the pod makes no noise (including related explosions, opening sounds, etc)
	var/effectMissile = FALSE //If true, the pod deletes the second it lands. If you give it an explosion, it will act like a missile exploding as it hits the ground
	var/effectCircle = FALSE //If true, allows the pod to come in at any angle. Bit of a weird feature but whatever its here
	var/style = STYLE_STANDARD //Style is a variable that keeps track of what the pod is supposed to look like. It acts as an index to the POD_STYLES list in cargo.dm defines to get the proper icon/name/desc for the pod. 
	var/reversing = FALSE //If true, the pod will not send any items. Instead, after opening, it will close again (picking up items/mobs) and fly back to centcom
	var/landingSound //Admin sound to play when the pod lands
	var/openingSound //Admin sound to play when the pod opens
	var/leavingSound //Admin sound to play when the pod leaves
	var/soundVolume = 50 //Volume to play sounds at. Ignores the cap
	var/bay //Used specifically for the centcom_podlauncher datum. Holds the current bay the user is launching objects from. Bays are specific rooms on the centcom map.
	var/list/explosionSize = list(0,0,2,3)

/obj/structure/closet/supplypod/bluespacepod
	style = STYLE_BLUESPACE
	bluespace = TRUE
	explosionSize = list(0,0,1,2)
	landingDelay = 15 //Slightly quicker than the supplypod

/obj/structure/closet/supplypod/centcompod
	style = STYLE_CENTCOM
	bluespace = TRUE
	explosionSize = list(0,0,0,0)
	landingDelay = 5 //Very speedy!
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/structure/closet/supplypod/Initialize()
	..()
	setStyle(style, TRUE) //Upon initialization, give the supplypod an iconstate, name, and description based on the "style" variable. This system is important for the centcom_podlauncher to function correctly

/obj/structure/closet/supplypod/update_icon()
	cut_overlays()
	if (style != STYLE_INVISIBLE) //If we're invisible, we dont bother adding any overlays
		if (opened)
			add_overlay("[icon_state]_open")
		else
			add_overlay("[icon_state]_door")

/obj/structure/closet/supplypod/proc/setStyle(chosenStyle, var/duringInit = FALSE) //Used to give the sprite an icon state, name, and description
	if (!duringInit && style == chosenStyle) //Check if the input style is already the same as the pod's style. This happens in centcom_podlauncher, and as such we set the style to STYLE_CENTCOM.
		setStyle(STYLE_CENTCOM) //We make sure to not check this during initialize() so the standard supplypod works correctly.
		return
	style = chosenStyle
	icon_state = POD_STYLES[chosenStyle][POD_ICON_STATE] //POD_STYLES is a 2D array we treat as a dictionary. The style represents the verticle index, with the icon state, name, and desc being stored in the horizontal indexes of the 2D array.
	if (!adminNamed) //We dont want to name it ourselves if it has been specifically named by an admin using the centcom_podlauncher datum
		name = POD_STYLES[chosenStyle][POD_NAME]
		desc = POD_STYLES[chosenStyle][POD_DESC]
	update_icon()

/obj/structure/closet/supplypod/tool_interact(obj/item/W, mob/user)
	if (bluespace) //We dont want to worry about interacting with bluespace pods, as they are due to delete themselves soon anyways.
		return FALSE 
	else
		..()

/obj/structure/closet/supplypod/ex_act() //Explosions dont do SHIT TO US! This is because supplypods create explosions when they land.
	return

/obj/structure/closet/supplypod/contents_explosion() //Supplypods also protect their contents from the harmful effects of fucking exploding.
	return

/obj/structure/closet/supplypod/toggle(mob/living/user) //Supplypods shouldn't be able to be manually opened under any circumstances, as the open() proc generates supply order datums
	return

/obj/structure/closet/supplypod/proc/preOpen() //Called before the open() proc. Handles anything that occurs right as the pod lands.
	var/turf/T = get_turf(src)
	var/list/B = explosionSize //Mostly because B is more readable than explosionSize :p
	var/boomTotal = 0 //A counter used to check if the explosion does nothing
	if (landingSound)
		playsound(get_turf(src), landingSound, soundVolume, 0, 0)
	for (var/mob/living/M in T)
		if (effectLimb && iscarbon(M)) //If effectLimb is true (which means we pop limbs off when we hit people):
			var/mob/living/carbon/CM = M
			for (var/obj/item/bodypart/bodypart in CM.bodyparts) //Look at the bodyparts in our poor mob beneath our pod as it lands
				if(bodypart.body_part != HEAD && bodypart.body_zone != CHEST)//we dont want to kill him, just teach em a lesson!
					if (bodypart.dismemberable)
						bodypart.dismember() //Using the power of flextape i've sawed this man's limb in half!
						break
		if (effectGib) //effectGib is on, that means whatever's underneath us better be fucking oof'd on
			M.adjustBruteLoss(5000) //THATS A LOT OF DAMAGE (called just in case gib() doesnt work on em)
			M.gib() //After adjusting the fuck outta that brute loss we finish the job with some satisfying gibs
		M.adjustBruteLoss(damage)

	for (var/i in B)
		boomTotal += i //Count up all the values of the explosion

	if (boomTotal != 0) //If the explosion list isn't all zeroes, call an explosion
		explosion(get_turf(src), B[1], B[2], B[3], flame_range = B[4], silent = effectQuiet, ignorecap = istype(src, /obj/structure/closet/supplypod/centcompod)) //less advanced equipment than bluespace pod, so larger explosion when landing
	else if (!effectQuiet) //If our explosion list IS all zeroes, we still make a nice explosion sound (unless the effectQuiet var is true)
		playsound(src, "explosion", landingSound ? 15 : 80, 1)
	if (effectMissile) //If we are acting like a missile, then right after we land and finish fucking shit up w explosions, we should delete
		opened = TRUE //We set opened to TRUE to avoid spending time trying to open (due to being deleted) during the Destroy() proc
		qdel(src)
	if (style == STYLE_GONDOLA) //Checks if we are supposed to be a gondola pod. If so, create a gondolapod mob, and move this pod to nullspace. I'd like to give a shout out, to my man oranges
		var/mob/living/simple_animal/pet/gondola/gondolapod/benis = new(get_turf(src), src)
		benis.contents |= contents //Move the contents of this supplypod into the gondolapod mob.
		moveToNullspace()
		addtimer(CALLBACK(src, .proc/open, benis), openingDelay) //After the openingDelay passes, we use the open proc from this supplyprod while referencing the contents of the "holder", in this case the gondolapod mob
	else
		addtimer(CALLBACK(src, .proc/open, src), openingDelay) //After the openingDelay passes, we use the open proc from this supplypod, while referencing this supplypod's contents

/obj/structure/closet/supplypod/open(atom/movable/holder, var/broken = FALSE, var/forced = FALSE) //The holder var represents an atom whose contents we will be working with
	var/turf/T = get_turf(holder) //Get the turf of whoever's contents we're talking about
	var/mob/M
	if (istype(holder, /mob)) //Allows mobs to assume the role of the holder, meaning we look at the mob's contents rather than the supplypod's contents. Typically by this point the supplypod's contents have already been moved over to the mob's contents
		M = holder
		if (M.key && !forced && !broken) //If we are player controlled, then we shouldnt open unless the opening is manual, or if it is due to being destroyed (represented by the "broken" parameter)
			return
	opened = TRUE //This is to ensure we don't open something that has already been opened
	if (openingSound)
		playsound(get_turf(holder), openingSound, soundVolume, 0, 0)
	INVOKE_ASYNC(holder, .proc/setOpened) //Use the INVOKE_ASYNC proc to call setOpened() on whatever the holder may be, without giving the atom/movable base class a setOpened() proc definition
	for (var/atom/movable/O in holder.contents) //Go through the contents of the holder
		O.forceMove(T) //move everything from the contents of the holder to the turf of the holder
	if (!effectQuiet) //If we aren't being quiet, play an open sound
		playsound(get_turf(holder), open_sound, 15, 1, -3)
	if (broken) //If the pod is opening because it's been destroyed, we end here
		return
	addtimer(CALLBACK(src, .proc/depart, holder), departureDelay) //Finish up the pod's duties after a certain amount of time

/obj/structure/closet/supplypod/proc/depart(atom/movable/holder)
	if (leavingSound)
		playsound(get_turf(holder), leavingSound, soundVolume, 0, 0)
	if (reversing) //If we're reversing, we call the close proc. This sends the pod back up to centcom
		close(holder)
	else if (bluespace) //If we're a bluespace pod, then delete ourselves (along with our holder, if a seperate holder exists) 
		if (style != STYLE_INVISIBLE) 
			do_sparks(5, TRUE, holder) //Create some sparks right before closing
		qdel(src) //Delete ourselves and the holder 
		if (holder != src)
			qdel(holder)

/obj/structure/closet/supplypod/centcompod/close(atom/movable/holder) //Closes the supplypod and sends it back to centcom. Should only ever be called if the "reversing" variable is true
	opened = FALSE
	INVOKE_ASYNC(holder, .proc/setClosed) //Use the INVOKE_ASYNC proc to call setClosed() on whatever the holder may be, without giving the atom/movable base class a setClosed() proc definition
	for (var/atom/movable/O in get_turf(holder))
		if (ismob(O) && !isliving(O)) //We dont want to take ghosts with us
			continue
		O.forceMove(holder) //Put objects inside before we close
	var/obj/effect/temp_visual/risingPod = new /obj/effect/temp_visual/DPfall(get_turf(holder), src) //Make a nice animation of flying back up
	risingPod.pixel_z = 0 //The initial value of risingPod's pixel_z is 200 because it normally comes down from a high spot
	holder.forceMove(bay) //Move the pod back to centcom, where it belongs
	animate(risingPod, pixel_z = 200, time = 10, easing = LINEAR_EASING) //Animate our rising pod
	reversing = FALSE //Now that we're done reversing, we set this to false (otherwise we would get stuck in an infinite loop of calling the close proc at the bottom of open() )
	open(holder, forced = TRUE)
	return

/obj/structure/closet/supplypod/proc/setOpened() //Proc exists here, as well as in any atom that can assume the role of a "holder" of a supplypod. Check the open() proc for more details
	update_icon()

/obj/structure/closet/supplypod/proc/setClosed() //Ditto
	update_icon()

/obj/structure/closet/supplypod/Destroy()
	if (!opened) //If we havent opened yet, we're opening because we've been destroyed. Lets dump our contents by opening up
		open(src, broken = TRUE)
	return ..()

//------------------------------------FALLING SUPPLY POD-------------------------------------//
/obj/effect/temp_visual/DPfall //Falling pod
	name = ""
	icon = 'icons/obj/supplypods.dmi'
	pixel_x = -16
	pixel_y = -5
	pixel_z = 200
	desc = "Get out of the way!"
	layer = FLY_LAYER//that wasnt flying, that was falling with style!
	randomdir = FALSE
	icon_state = ""

/obj/effect/temp_visual/DPfall/Initialize(dropLocation, obj/structure/closet/supplypod/pod)
	if (pod.style != STYLE_INVISIBLE) //Check to ensure the pod isn't invisible
		icon_state = "[pod.icon_state]_falling"
		name = pod.name
	. = ..()

//------------------------------------TEMPORARY_VISUAL-------------------------------------//
/obj/effect/DPtarget //This is the object that forceMoves the supplypod to it's location
	name = "Landing Zone Indicator"
	desc = "A holographic projection designating the landing zone of something. It's probably best to stand back."
	icon = 'icons/mob/actions/actions_items.dmi'
	icon_state = "sniper_zoom"
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	light_range = 2
	var/obj/effect/temp_visual/fallingPod //Temporary "falling pod" that we animate
	var/obj/structure/closet/supplypod/pod //The supplyPod that will be landing ontop of this target

/obj/effect/ex_act()
	return

/obj/effect/DPtarget/Initialize(mapload, podParam, var/datum/supply_order/SO = null)
	if (ispath(podParam)) //We can pass either a path for a pod (as expressconsoles do), or a reference to an instantiated pod (as the centcom_podlauncher does)
		podParam = new podParam() //If its just a path, instantiate it
	pod = podParam
	if (SO)
		SO.generate(pod)
	for (var/mob/living/M in podParam) //If there are any mobs in the supplypod, we want to forceMove them into the target. This is so that they can see where they are about to land, AND so that they don't get sent to the nullspace error room (as the pod is currently in nullspace)
		M.forceMove(src)
	if(pod.effectStun) //If effectStun is true, stun any mobs caught on this target until the pod gets a chance to hit them
		for (var/mob/living/M in get_turf(src))
			M.Stun(pod.landingDelay+10, ignore_canstun = TRUE)//you aint goin nowhere, kid.
	if (pod.effectStealth) //If effectStealth is true we want to be invisible
		alpha = 255
	addtimer(CALLBACK(src, .proc/beginLaunch, pod.effectCircle), pod.landingDelay)

/obj/effect/DPtarget/proc/beginLaunch(effectCircle) //Begin the animation for the pod falling. The effectCircle param determines whether the pod gets to come in from any descent angle
	fallingPod = new /obj/effect/temp_visual/DPfall(drop_location(), pod)
	var/matrix/M = matrix(fallingPod.transform) //Create a new matrix that we can rotate
	var/angle = effectCircle ? rand(0,360) : rand(70,110) //The angle that we can come in from
	fallingPod.pixel_x = cos(angle)*200 //Use some ADVANCED MATHEMATICS to set the animated pod's position to somewhere on the edge of a circle with the center being the target
	fallingPod.pixel_z = sin(angle)*200
	var/rotation = Get_Pixel_Angle(fallingPod.pixel_z, fallingPod.pixel_x) //CUSTOM HOMEBREWED proc that is just arctan with extra steps
	M.Turn(rotation) //Turn our matrix accordingly
	fallingPod.transform = M //Transform the animated pod according to the matrix
	M = matrix(pod.transform) //Make another matrix based on the pod
	M.Turn(rotation) //Turn the matrix
	pod.transform = M //Turn the actual pod (Won't be visible until endLaunch() proc tho)
	animate(fallingPod, pixel_z = 0, pixel_x = -16, time = 3, , easing = LINEAR_EASING) //Make the pod fall! At an angle!
	addtimer(CALLBACK(src, .proc/endLaunch), 3, TIMER_CLIENT_TIME) //Go onto the last step after a very short falling animation

/obj/effect/DPtarget/proc/endLaunch()
	pod.forceMove(drop_location()) //The fallingPod animation is over, now's a good time to forceMove the actual pod into position
	for (var/mob/living/M in src) //Remember earlier (initialization) when we moved mobs into the DPTarget so they wouldnt get lost in nullspace? Time to get them out
		M.forceMove(pod)
	pod.preOpen() //Begin supplypod open procedures. Here effects like explosions, damage, and other dangerous (and potentially admin-caused, if the centcom_podlauncher datum was used) memes will take place
	QDEL_NULL(fallingPod) //The fallingPod's (the animated effect, not the actual pod) purpose is complete. It can rest easy now
	qdel(src) //ditto

//------------------------------------UPGRADES-------------------------------------//
/obj/item/disk/cargo/bluespace_pod //Disk that can be inserted into the Express Console to allow for Advanced Bluespace Pods
	name = "Bluespace Drop Pod Upgrade"
	desc = "This disk provides a firmware update to the Express Supply Console, granting the use of Nanotrasen's Bluespace Drop Pods to the supply department."
	icon = 'icons/obj/module.dmi'
	icon_state = "cargodisk"
	item_state = "card-id"
	w_class = WEIGHT_CLASS_SMALL
