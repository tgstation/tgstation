#define SUPPLYPOD_X_OFFSET -16

//The "pod_landingzone" temp visual is created by anything that "launches" a supplypod. This is what animates the pod and makes the pod forcemove to the station.
//------------------------------------SUPPLY POD-------------------------------------//
/obj/structure/closet/supplypod
	name = "supply pod" //Names and descriptions are normally created with the setStyle() proc during initialization, but we have these default values here as a failsafe
	desc = "A Nanotrasen supply drop pod."
	icon = 'icons/obj/supplypods.dmi'
	icon_state = "pod" //This is a common base sprite shared by a number of pods
	pixel_x = SUPPLYPOD_X_OFFSET //2x2 sprite
	layer = BELOW_OBJ_LAYER //So that the crate inside doesn't appear underneath
	allow_objects = TRUE
	allow_dense = TRUE
	delivery_icon = null
	can_weld_shut = FALSE
	armor = list("melee" = 30, "bullet" = 50, "laser" = 50, "energy" = 100, "bomb" = 100, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 80)
	anchored = TRUE //So it cant slide around after landing
	anchorable = FALSE
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	appearance_flags = KEEP_TOGETHER | PIXEL_SCALE 
	density = FALSE

	//*****NOTE*****: Many of these comments are similarly described in centcom_podlauncher.dm. If you change them here, please consider doing so in the centcom podlauncher code as well!
	var/adminNamed = FALSE //Determines whether or not the pod has been named by an admin. If true, the pod's name will not get overridden when the style of the pod changes (changing the style of the pod normally also changes the name+desc)
	var/bluespace = FALSE //If true, the pod deletes (in a shower of sparks) after landing
	var/landingDelay = 30 //How long the pod takes to land after launching
	var/openingDelay = 30 //How long the pod takes to open after landing
	var/departureDelay = 30 //How long the pod takes to leave after opening. If bluespace = TRUE, it deletes. If reversing = TRUE, it flies back to centcom.
	var/damage = 0 //Damage that occurs to any mob under the pod when it lands.
	var/effectStun = FALSE //If true, stuns anyone under the pod when it launches until it lands, forcing them to get hit by the pod. Devilish!
	var/effectLimb = FALSE //If true, pops off a limb (if applicable) from anyone caught under the pod when it lands
	var/effectOrgans = FALSE //If true, yeets out every limb and organ from anyone caught under the pod when it lands
	var/effectGib = FALSE //If true, anyone under the pod will be gibbed when it lands
	var/effectStealth = FALSE //If true, a target icon isn't displayed on the turf where the pod will land
	var/effectQuiet = FALSE //The female sniper. If true, the pod makes no noise (including related explosions, opening sounds, etc)
	var/effectMissile = FALSE //If true, the pod deletes the second it lands. If you give it an explosion, it will act like a missile exploding as it hits the ground
	var/effectCircle = FALSE //If true, allows the pod to come in at any angle. Bit of a weird feature but whatever its here
	var/style = STYLE_STANDARD //Style is a variable that keeps track of what the pod is supposed to look like. It acts as an index to the POD_STYLES list in cargo.dm defines to get the proper icon/name/desc for the pod.
	var/reversing = FALSE //If true, the pod will not send any items. Instead, after opening, it will close again (picking up items/mobs) and fly back to centcom
	var/turf/reverse_dropoff_turf //Turf that the reverse pod will drop off it's newly-acquired cargo to
	var/fallDuration = 4
	var/fallingSoundLength = 11
	var/fallingSound = 'sound/weapons/mortar_long_whistle.ogg'//Admin sound to play before the pod lands
	var/landingSound //Admin sound to play when the pod lands
	var/openingSound //Admin sound to play when the pod opens
	var/leavingSound //Admin sound to play when the pod leaves
	var/soundVolume = 80 //Volume to play sounds at. Ignores the cap
	var/list/explosionSize = list(0,0,2,3)
	var/stay_after_drop = FALSE
	var/specialised = FALSE // It's not a general use pod for cargo/admin use
	var/rubble_type //Rubble effect associated with this supplypod
	var/decal = "default" //What kind of extra decals we add to the pod to make it look nice
	var/door = "pod_door"
	var/fin_mask  = "topfin"
	var/obj/effect/supplypod_rubble/rubble
	var/obj/effect/engineglow/glow_effect
	var/effectShrapnel = FALSE
	var/shrapnel_type = /obj/projectile/bullet/shrapnel
	var/shrapnel_magnitude = 3

/obj/structure/closet/supplypod/bluespacepod
	style = STYLE_BLUESPACE
	bluespace = TRUE
	explosionSize = list(0,0,1,2)
	landingDelay = 15 //Slightly quicker than the supplypod

/obj/structure/closet/supplypod/extractionpod
	name = "Syndicate Extraction Pod"
	desc = "A specalised, blood-red styled pod for extracting high-value targets out of active mission areas. <b>Targets must be manually stuffed inside the pod for proper delivery.</b>"
	specialised = TRUE
	style = STYLE_SYNDICATE
	bluespace = TRUE
	explosionSize = list(0,0,1,2)
	landingDelay = 25 //Longer than others

/obj/structure/closet/supplypod/centcompod
	style = STYLE_CENTCOM
	bluespace = TRUE
	explosionSize = list(0,0,0,0)
	landingDelay = 20 //Very speedy!
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/structure/closet/supplypod/Initialize()
	. = ..()
	setStyle(style, TRUE) //Upon initialization, give the supplypod an iconstate, name, and description based on the "style" variable. This system is important for the centcom_podlauncher to function correctly

/obj/structure/closet/supplypod/extractionpod/Initialize()
	. = ..()
	reverse_dropoff_turf = pick(GLOB.holdingfacility)

/obj/structure/closet/supplypod/proc/setStyle(chosenStyle, duringInit = FALSE) //Used to give the sprite an icon state, name, and description. Should only be called once
	if (!duringInit && style == chosenStyle) //Check if the input style is already the same as the pod's style. This happens in centcom_podlauncher, and as such we set the style to STYLE_CENTCOM.
		setStyle(STYLE_CENTCOM) //We make sure to not check this during initialize() so the standard supplypod works correctly.
		return
	style = chosenStyle
	var/base = POD_STYLES[chosenStyle][POD_BASE] //POD_STYLES is a 2D array we treat as a dictionary. The style represents the verticle index, with the icon state, name, and desc being stored in the horizontal indexes of the 2D array.
	icon_state = base
	decal = POD_STYLES[chosenStyle][POD_DECAL]
	rubble_type = POD_STYLES[chosenStyle][POD_RUBBLE_TYPE]
	if (!adminNamed && !specialised) //We dont want to name it ourselves if it has been specifically named by an admin using the centcom_podlauncher datum
		name = POD_STYLES[chosenStyle][POD_NAME]
		desc = POD_STYLES[chosenStyle][POD_DESC]
	door = "[base]_door"
	update_icon()

/obj/structure/closet/supplypod/proc/SetReverseIcon()
	fin_mask = "bottomfin"
	if (POD_STYLES[style][POD_SHAPE] == POD_SHAPE_NORML)
		icon_state = POD_STYLES[style][POD_BASE] + "_reverse"
	pixel_x = initial(pixel_x) 
	transform = matrix()
	update_icon()

/obj/structure/closet/supplypod/proc/backToNonReverseIcon()
	fin_mask = initial(fin_mask)
	if (POD_STYLES[style][POD_SHAPE] == POD_SHAPE_NORML)
		icon_state = POD_STYLES[style][POD_BASE]
	pixel_x = initial(pixel_x) 
	transform = matrix()
	update_icon()

/obj/structure/closet/supplypod/closet_update_overlays(list/new_overlays)
	return

/obj/structure/closet/supplypod/update_overlays()
	. = ..()
	if (style == STYLE_INVISIBLE)
		return
	if (rubble)
		. += rubble.getForeground(src)
	if (style == STYLE_SEETHROUGH)
		for (var/atom/A in contents)
			var/mutable_appearance/itemIcon = new(A)
			itemIcon.transform = matrix().Translate(-1 * SUPPLYPOD_X_OFFSET, 0)
			. += itemIcon
		return

	if (opened) //We're opened means all we have to worry about is masking a decal if we have one
		if (!decal) //We don't have a decal to mask
			return
		var/icon/masked_decal = new(icon, decal) //The decal we want to apply
		var/icon/door_masker = new(icon, door) //The door shape we want to 'cut out' of the decal
		door_masker.MapColors(0,0,0,1, 0,0,0,1, 0,0,0,1, 1,1,1,0, 0,0,0,1)
		door_masker.SwapColor("#ffffffff", null)
		door_masker.Blend("#000000", ICON_SUBTRACT)
		masked_decal.Blend(door_masker, ICON_ADD)
		. += masked_decal
	else //If we're closed
		if (POD_STYLES[style][POD_SHAPE] != POD_SHAPE_NORML) //If we're not a normal pod shape (aka, if we don't have fins), just add the door without masking
			. += door
		else
			var/icon/masked_door = new(icon, door) //The door we want to apply
			var/icon/fin_masker = new(icon, "mask_[fin_mask]") //The fin shape we want to 'cut out' of the door
			fin_masker.MapColors(0,0,0,1, 0,0,0,1, 0,0,0,1, 1,1,1,0, 0,0,0,1) 
			fin_masker.SwapColor("#ffffffff", null)
			fin_masker.Blend("#000000", ICON_SUBTRACT)
			masked_door.Blend(fin_masker, ICON_ADD)
			. += masked_door
		if (decal)
			. += decal

/obj/structure/closet/supplypod/tool_interact(obj/item/W, mob/user)
	if(bluespace) //We dont want to worry about interacting with bluespace pods, as they are due to delete themselves soon anyways.
		return FALSE
	else
		..()

/obj/structure/closet/supplypod/ex_act() //Explosions dont do SHIT TO US! This is because supplypods create explosions when they land.
	return

/obj/structure/closet/supplypod/contents_explosion() //Supplypods also protect their contents from the harmful effects of fucking exploding.
	return

/obj/structure/closet/supplypod/toggle(mob/living/user)
	return

/obj/structure/closet/supplypod/open(mob/living/user, force = TRUE)
	return

/obj/structure/closet/supplypod/proc/handleReturnAfterDeparting(atom/movable/holder = src)
	reversing = FALSE //Now that we're done reversing, we set this to false (otherwise we would get stuck in an infinite loop of calling the close proc at the bottom of open_pod() )
	bluespace = TRUE //Make it so that the pod doesn't stay in centcom forever
	audible_message("<span class='notice'>The pod hisses, closing and launching itself away from the station.</span>", "<span class='notice'>The ground vibrates, and you hear the sound of engines firing.</span>")
	stay_after_drop = FALSE
	holder.pixel_z = initial(holder.pixel_z)
	holder.alpha = initial(holder.alpha)
	var/shippingLane = GLOB.areas_by_type[/area/centcom/supplypod/fly_me_to_the_moon]
	forceMove(shippingLane) //Move to the centcom-z-level until the pod_landingzone says we can drop back down again
	if (!reverse_dropoff_turf) //If we're centcom-launched, the reverse dropoff turf will be a centcom loading bay. If we're an extraction pod, it should be the ninja jail.
		reverse_dropoff_turf = locate(/area/centcom/supplypod/loading/one) in GLOB.sortedAreas
	landingDelay = initial(landingDelay) //Reset the landing timers so we land on whatever turf we're aiming at normally. Will be changed to be editable later (tm)
	fallDuration = initial(fallDuration) //This is so if someone adds a really long dramatic landing time they don't have to sit through it twice on the pod's return trip
	openingDelay = initial(openingDelay)
	backToNonReverseIcon()
	new /obj/effect/pod_landingzone(reverse_dropoff_turf, src)

/obj/structure/closet/supplypod/proc/preOpen() //Called before the open_pod() proc. Handles anything that occurs right as the pod lands.
	var/turf/T = get_turf(src)
	var/list/B = explosionSize //Mostly because B is more readable than explosionSize :p
	density = TRUE //Density is originally false so the pod doesn't block anything while it's still falling through the air
	if (landingSound)
		playsound(get_turf(src), landingSound, soundVolume, FALSE, FALSE)
	AddComponent(/datum/component/pellet_cloud, projectile_type=shrapnel_type, magnitude=shrapnel_magnitude)
	if(effectShrapnel)	
		SEND_SIGNAL(src, COMSIG_SUPPLYPOD_LANDED)
	for (var/mob/living/M in T)
		if (effectLimb && iscarbon(M)) //If effectLimb is true (which means we pop limbs off when we hit people):
			var/mob/living/carbon/CM = M
			for (var/obj/item/bodypart/bodypart in CM.bodyparts) //Look at the bodyparts in our poor mob beneath our pod as it lands
				if(bodypart.body_part != HEAD && bodypart.body_part != CHEST)//we dont want to kill him, just teach em a lesson!
					if (bodypart.dismemberable)
						bodypart.dismember() //Using the power of flextape i've sawed this man's limb in half!
						break
		if (effectOrgans && iscarbon(M)) //effectOrgans means remove every organ in our mob
			var/mob/living/carbon/CM = M
			for(var/X in CM.internal_organs)
				var/destination = get_edge_target_turf(T, pick(GLOB.alldirs)) //Pick a random direction to toss them in
				var/obj/item/organ/O = X
				O.Remove(CM) //Note that this isn't the same proc as for lists
				O.forceMove(T) //Move the organ outta the body
				O.throw_at(destination, 2, 3) //Thow the organ at a random tile 3 spots away
				sleep(1)
			for (var/obj/item/bodypart/bodypart in CM.bodyparts) //Look at the bodyparts in our poor mob beneath our pod as it lands
				var/destination = get_edge_target_turf(T, pick(GLOB.alldirs))
				if (bodypart.dismemberable)
					bodypart.dismember() //Using the power of flextape i've sawed this man's bodypart in half!
					bodypart.throw_at(destination, 2, 3)
					sleep(1)

		if (effectGib) //effectGib is on, that means whatever's underneath us better be fucking oof'd on
			M.adjustBruteLoss(5000) //THATS A LOT OF DAMAGE (called just in case gib() doesnt work on em)
			M.gib() //After adjusting the fuck outta that brute loss we finish the job with some satisfying gibs
		M.adjustBruteLoss(damage)
	var/explosion_sum = B[1] + B[2] + B[3] + B[4]
	if (explosion_sum != 0) //If the explosion list isn't all zeroes, call an explosion
		explosion(get_turf(src), B[1], B[2], B[3], flame_range = B[4], silent = effectQuiet, ignorecap = istype(src, /obj/structure/closet/supplypod/centcompod)) //less advanced equipment than bluespace pod, so larger explosion when landing
	else if (!effectQuiet) //If our explosion list IS all zeroes, we still make a nice explosion sound (unless the effectQuiet var is true)
		playsound(src, "explosion", landingSound ? 15 : 80, TRUE)
	if (effectMissile) //If we are acting like a missile, then right after we land and finish fucking shit up w explosions, we should delete
		opened = TRUE //We set opened to TRUE to avoid spending time trying to open (due to being deleted) during the Destroy() proc
		qdel(src)
		return
	if (style == STYLE_GONDOLA) //Checks if we are supposed to be a gondola pod. If so, create a gondolapod mob, and move this pod to nullspace. I'd like to give a shout out, to my man oranges
		var/mob/living/simple_animal/pet/gondola/gondolapod/benis = new(get_turf(src), src)
		benis.contents |= contents //Move the contents of this supplypod into the gondolapod mob.
		moveToNullspace()
		addtimer(CALLBACK(src, .proc/open_pod, benis), openingDelay) //After the openingDelay passes, we use the open proc from this supplyprod while referencing the contents of the "holder", in this case the gondolapod mob
	else if (style == STYLE_SEETHROUGH)
		open_pod(src)
	else
		addtimer(CALLBACK(src, .proc/open_pod, src), openingDelay) //After the openingDelay passes, we use the open proc from this supplypod, while referencing this supplypod's contents

/obj/structure/closet/supplypod/proc/open_pod(atom/movable/holder, broken = FALSE, forced = FALSE) //The holder var represents an atom whose contents we will be working with
	if (!holder)
		return
	if (opened) //This is to ensure we don't open something that has already been opened
		return
	holder.setOpened()
	var/turf/T = get_turf(holder) //Get the turf of whoever's contents we're talking about
	var/mob/M
	if (istype(holder, /mob)) //Allows mobs to assume the role of the holder, meaning we look at the mob's contents rather than the supplypod's contents. Typically by this point the supplypod's contents have already been moved over to the mob's contents
		M = holder
		if (M.key && !forced && !broken) //If we are player controlled, then we shouldn't open unless the opening is manual, or if it is due to being destroyed (represented by the "broken" parameter)
			return
	if (openingSound)
		playsound(get_turf(holder), openingSound, soundVolume, FALSE, FALSE) //Special admin sound to play
	for (var/atom/movable/O in holder.contents) //Go through the contents of the holder
		O.forceMove(T) //move everything from the contents of the holder to the turf of the holder
	if (!effectQuiet && !openingSound && style != STYLE_SEETHROUGH) //If we aren't being quiet, play the default pod open sound
		playsound(get_turf(holder), open_sound, 15, TRUE, -3)
	if (broken) //If the pod is opening because it's been destroyed, we end here
		return
	if (style == STYLE_SEETHROUGH)
		startExitSequence(src)
	else
		if (reversing)
			addtimer(CALLBACK(src, .proc/SetReverseIcon), departureDelay/2) //Finish up the pod's duties after a certain amount of time
		if(!stay_after_drop) // Departing should be handled manually
			addtimer(CALLBACK(src, .proc/startExitSequence, holder), departureDelay) //Finish up the pod's duties after a certain amount of time

/obj/structure/closet/supplypod/proc/startExitSequence(atom/movable/holder)
	if (reversing) //If we're reversing, we call the close proc. This sends the pod back up to centcom
		close(holder)
	else if (bluespace) //If we're a bluespace pod, then delete ourselves (along with our holder, if a seperate holder exists)
		deleteRubble()
		if (!effectQuiet && style != STYLE_INVISIBLE && style != STYLE_SEETHROUGH)
			do_sparks(5, TRUE, holder) //Create some sparks right before closing
		qdel(src) //Delete ourselves and the holder
		if (holder != src)
			qdel(holder)

/obj/structure/closet/supplypod/close(atom/movable/holder) //Closes the supplypod and sends it back to centcom. Should only ever be called if the "reversing" variable is true
	if (!holder)
		return
	take_contents(holder)
	playsound(holder, close_sound, close_sound_volume, TRUE, -3)
	holder.setClosed()
	addtimer(CALLBACK(src, .proc/preReturn, holder), 10) //Start to leave a second after closing for cinematic effect

/obj/structure/closet/supplypod/take_contents(atom/movable/holder)
	var/atom/L = holder.drop_location()
	for(var/atom/movable/AM in L)
		if(AM != src && !insert(AM, holder)) // Can't insert that
			continue

/obj/structure/closet/supplypod/insert(atom/movable/AM, atom/movable/holder)
	if(insertion_allowed(AM))
		AM.forceMove(holder)
		return TRUE
	else
		return FALSE

/obj/structure/closet/supplypod/insertion_allowed(atom/movable/AM)
	if(ismob(AM))
		if(!isliving(AM)) //let's not put ghosts or camera mobs inside closets...
			return FALSE
		var/mob/living/L = AM
		if(L.anchored || L.incorporeal_move)
			return FALSE
		L.stop_pulling()

	else if(isobj(AM))
		if((!allow_dense && AM.density) || AM.anchored || AM.has_buckled_mobs())
			return FALSE
		else if(isitem(AM) && !HAS_TRAIT(AM, TRAIT_NODROP))
			return TRUE
		else if(!allow_objects && !istype(AM, /obj/effect/dummy/chameleon))
			return FALSE
	else
		return FALSE

	return TRUE

/obj/structure/closet/supplypod/proc/preReturn(atom/movable/holder)
	if (leavingSound)
		playsound(get_turf(holder), leavingSound, soundVolume, FALSE, FALSE)
	deleteRubble()
	animate(holder, alpha = 0, time = 8, easing = QUAD_EASING|EASE_IN, flags = ANIMATION_PARALLEL) 
	animate(holder, pixel_z = 400, time = 10, easing = QUAD_EASING|EASE_IN, flags = ANIMATION_PARALLEL) //Animate our rising pod
	
	addtimer(CALLBACK(src, .proc/handleReturnAfterDeparting, holder), 15) //Finish up the pod's duties after a certain amount of time

/obj/structure/closet/supplypod/setOpened() //Proc exists here, as well as in any atom that can assume the role of a "holder" of a supplypod. Check the open_pod() proc for more details
	opened = TRUE
	density = FALSE
	update_icon()

/obj/structure/closet/supplypod/extractionpod/setOpened()
	opened = TRUE
	density = TRUE
	update_icon()

/obj/structure/closet/supplypod/setClosed() //Ditto
	opened = FALSE
	density = TRUE
	update_icon()

/obj/structure/closet/supplypod/proc/tryMakeRubble(turf/T) //Ditto
	if (rubble_type == RUBBLE_NONE)
		return
	if (rubble)
		return
	if (effectMissile)
		return
	if (isspaceturf(T) || isclosedturf(T))
		return
	rubble = new /obj/effect/supplypod_rubble(T)
	rubble.setStyle(rubble_type, src)
	update_icon()

/obj/structure/closet/supplypod/Moved()
	deleteRubble()
	return ..()

/obj/structure/closet/supplypod/proc/deleteRubble()
	rubble?.fadeAway()
	rubble = null
	update_icon()

/obj/structure/closet/supplypod/proc/addGlow()
	if (POD_STYLES[style][POD_SHAPE] != POD_SHAPE_NORML)
		return
	glow_effect = new(src)
	glow_effect.icon_state = "pod_glow_" + POD_STYLES[style][POD_GLOW]
	vis_contents += glow_effect
	glow_effect.layer = GASFIRE_LAYER

/obj/structure/closet/supplypod/proc/endGlow()
	if(!glow_effect)
		return
	glow_effect.layer = LOW_ITEM_LAYER
	glow_effect.fadeAway(openingDelay)

/obj/structure/closet/supplypod/Destroy()
	deleteRubble()
	open_pod(src, broken = TRUE) //Lets dump our contents by opening up
	return ..()

//------------------------------------TEMPORARY_VISUAL-------------------------------------//
/obj/effect/supplypod_smoke //Falling pod smoke
	name = ""
	icon = 'icons/obj/supplypods_32x32.dmi'
	icon_state = "smoke"
	desc = ""
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 0

/obj/effect/engineglow //Falling pod smoke
	name = ""
	icon = 'icons/obj/supplypods.dmi'
	icon_state = "pod_engineglow"
	desc = ""
	layer = GASFIRE_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 255

/obj/effect/engineglow/proc/fadeAway(leaveTime)
	var/duration = min(leaveTime, 25)
	animate(src, alpha=0, time = duration)
	QDEL_IN(src, duration + 5)

/obj/effect/supplypod_smoke/proc/drawSelf(amount)
	alpha = max(0, 255-(amount*20))

/obj/effect/supplypod_rubble //This is the object that forceMoves the supplypod to it's location
	name = "Debris"
	desc = "A small crater of rubble. Closer inspection reveals the debris to be made primarily of space-grade metal fragments. You're pretty sure that this will disperse before too long."
	icon = 'icons/obj/supplypods.dmi'
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER // We want this to go right below the layer of supplypods and supplypod_rubble's forground.
	icon_state = "rubble_bg"
	anchored = TRUE
	pixel_x = SUPPLYPOD_X_OFFSET
	var/foreground = "rubble_fg"
	var/verticle_offset = 0

/obj/effect/supplypod_rubble/proc/getForeground(obj/structure/closet/supplypod/pod)
	var/mutable_appearance/rubble_overlay = mutable_appearance('icons/obj/supplypods.dmi', foreground)
	rubble_overlay.appearance_flags = KEEP_APART|RESET_TRANSFORM
	rubble_overlay.transform = matrix().Translate(SUPPLYPOD_X_OFFSET - pod.pixel_x, verticle_offset)  
	return rubble_overlay

/obj/effect/supplypod_rubble/proc/fadeAway()
	animate(src, alpha=0, time = 30)
	QDEL_IN(src, 35)

/obj/effect/supplypod_rubble/proc/setStyle(type, obj/structure/closet/supplypod/pod)
	if (type == RUBBLE_WIDE)
		icon_state += "_wide"
		foreground += "_wide"
	if (type == RUBBLE_THIN)
		icon_state += "_thin"
		foreground += "_thin"
	if (pod.style == STYLE_BOX)
		verticle_offset = -2
	else
		verticle_offset = initial(verticle_offset)

	pixel_y = verticle_offset

/obj/effect/pod_landingzone_effect
	name = ""
	desc = ""
	icon = 'icons/obj/supplypods_32x32.dmi'
	icon_state = "LZ_Slider"
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER

/obj/effect/pod_landingzone_effect/Initialize(mapload, obj/structure/closet/supplypod/pod)
	transform = matrix() * 1.5
	animate(src, transform = matrix()*0.01, time = pod.landingDelay+pod.fallDuration)
	..()

/obj/effect/pod_landingzone //This is the object that forceMoves the supplypod to it's location
	name = "Landing Zone Indicator"
	desc = "A holographic projection designating the landing zone of something. It's probably best to stand back."
	icon = 'icons/obj/supplypods_32x32.dmi'
	icon_state = "LZ"
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	light_range = 2
	anchored = TRUE
	alpha = 0
	var/obj/structure/closet/supplypod/pod //The supplyPod that will be landing ontop of this pod_landingzone
	var/obj/effect/pod_landingzone_effect/helper
	var/list/smoke_effects = new /list(13)

/obj/effect/ex_act()
	return

/obj/effect/pod_landingzone/Initialize(mapload, podParam, single_order = null, clientman)
	. = ..()
	if (ispath(podParam)) //We can pass either a path for a pod (as expressconsoles do), or a reference to an instantiated pod (as the centcom_podlauncher does)
		podParam = new podParam() //If its just a path, instantiate it
	pod = podParam
	if (!pod.effectStealth)
		helper = new (drop_location(), pod)
		alpha = 255
	animate(src, transform = matrix().Turn(90), time = pod.landingDelay+pod.fallDuration)
	if (single_order)
		if (istype(single_order, /datum/supply_order))
			var/datum/supply_order/SO = single_order
			SO.generate(pod)
		else if (istype(single_order, /atom/movable))
			var/atom/movable/O = single_order
			O.forceMove(pod)
	for (var/mob/living/M in pod) //If there are any mobs in the supplypod, we want to set their view to the pod_landingzone. This is so that they can see where they are about to land
		M.reset_perspective(src)
	if(pod.effectStun) //If effectStun is true, stun any mobs caught on this pod_landingzone until the pod gets a chance to hit them
		for (var/mob/living/M in get_turf(src))
			M.Stun(pod.landingDelay+10, ignore_canstun = TRUE)//you ain't goin nowhere, kid.
	if (pod.fallDuration == initial(pod.fallDuration) && pod.landingDelay + pod.fallDuration < pod.fallingSoundLength)
		pod.fallingSoundLength = 3 //The default falling sound is a little long, so if the landing time is shorter than the default falling sound, use a special, shorter default falling sound
		pod.fallingSound =  'sound/weapons/mortar_whistle.ogg'
	var/soundStartTime = pod.landingDelay - pod.fallingSoundLength + pod.fallDuration
	if (soundStartTime < 0)
		soundStartTime = 1
	if (!pod.effectQuiet)
		addtimer(CALLBACK(src, .proc/playFallingSound), soundStartTime)
	addtimer(CALLBACK(src, .proc/beginLaunch, pod.effectCircle), pod.landingDelay)

/obj/effect/pod_landingzone/proc/playFallingSound()
	playsound(src, pod.fallingSound, pod.soundVolume, TRUE, 6)

/obj/effect/pod_landingzone/proc/beginLaunch(effectCircle) //Begin the animation for the pod falling. The effectCircle param determines whether the pod gets to come in from any descent angle
	pod.addGlow()
	pod.update_icon()
	if (pod.style != STYLE_INVISIBLE)
		pod.add_filter("motionblur",1,list("type"="motion_blur", "x"=0, "y"=3))
	pod.forceMove(drop_location())
	for (var/mob/living/M in pod) //Remember earlier (initialization) when we moved mobs into the pod_landingzone so they wouldnt get lost in nullspace? Time to get them out
		M.reset_perspective(null)
	var/angle = effectCircle ? rand(0,360) : rand(70,110) //The angle that we can come in from
	pod.pixel_x = cos(angle)*32*length(smoke_effects) //Use some ADVANCED MATHEMATICS to set the animated pod's position to somewhere on the edge of a circle with the center being the pod_landingzone
	pod.pixel_z = sin(angle)*32*length(smoke_effects)
	var/rotation = Get_Pixel_Angle(pod.pixel_z, pod.pixel_x) //CUSTOM HOMEBREWED proc that is just arctan with extra steps
	setupSmoke(rotation)
	pod.transform = matrix().Turn(rotation)
	pod.layer = FLY_LAYER
	if (pod.style != STYLE_INVISIBLE)
		animate(pod.get_filter("motionblur"), y = 0, time = pod.fallDuration, flags = ANIMATION_PARALLEL)
		animate(pod, pixel_z = -1 * abs(sin(rotation))*4, pixel_x = SUPPLYPOD_X_OFFSET + (sin(rotation) * 20), time = pod.fallDuration, easing = LINEAR_EASING, flags = ANIMATION_PARALLEL) //Make the pod fall! At an angle!
	addtimer(CALLBACK(src, .proc/endLaunch), pod.fallDuration, TIMER_CLIENT_TIME) //Go onto the last step after a very short falling animation

/obj/effect/pod_landingzone/proc/setupSmoke(rotation)
	if (pod.style == STYLE_INVISIBLE || pod.style == STYLE_SEETHROUGH)
		return
	for ( var/i in 1 to length(smoke_effects))
		var/obj/effect/supplypod_smoke/S = new (drop_location())
		if (i == 1)
			S.layer = FLY_LAYER
			S.icon_state = "smoke_start"
		S.transform = matrix().Turn(rotation)
		smoke_effects[i] = S
		S.pixel_x = sin(rotation)*32 * i
		S.pixel_y = abs(cos(rotation))*32 * i
		S.filters += filter(type = "blur", size = 4)
		var/time = (pod.fallDuration / length(smoke_effects))*(length(smoke_effects)-i)
		addtimer(CALLBACK(S, /obj/effect/supplypod_smoke/.proc/drawSelf, i), time, TIMER_CLIENT_TIME) //Go onto the last step after a very short falling animation
		QDEL_IN(S, pod.fallDuration + 35)

/obj/effect/pod_landingzone/proc/drawSmoke()
	if (pod.style == STYLE_INVISIBLE || pod.style == STYLE_SEETHROUGH)
		return
	for (var/obj/effect/supplypod_smoke/S in smoke_effects)
		animate(S, alpha = 0, time = 20, flags = ANIMATION_PARALLEL)
		animate(S.filters[1], size = 6, time = 15, easing = CUBIC_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)

/obj/effect/pod_landingzone/proc/endLaunch()
	pod.tryMakeRubble(drop_location())
	pod.layer = initial(pod.layer)
	pod.endGlow()
	QDEL_NULL(helper)
	pod.preOpen() //Begin supplypod open procedures. Here effects like explosions, damage, and other dangerous (and potentially admin-caused, if the centcom_podlauncher datum was used) memes will take place
	drawSmoke()
	qdel(src) //The pod_landingzone's purpose is complete. It can rest easy now

//------------------------------------UPGRADES-------------------------------------//
/obj/item/disk/cargo/bluespace_pod //Disk that can be inserted into the Express Console to allow for Advanced Bluespace Pods
	name = "Bluespace Drop Pod Upgrade"
	desc = "This disk provides a firmware update to the Express Supply Console, granting the use of Nanotrasen's Bluespace Drop Pods to the supply department."
	icon = 'icons/obj/module.dmi'
	icon_state = "cargodisk"
	inhand_icon_state = "card-id"
	w_class = WEIGHT_CLASS_SMALL

#undef SUPPLYPOD_X_OFFSET
