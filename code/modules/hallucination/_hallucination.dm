GLOBAL_LIST_INIT(hallucination_list, list(
	/datum/hallucination/chat = 100,
	/datum/hallucination/message = 60,
	/datum/hallucination/sounds = 50,
	/datum/hallucination/battle = 20,
	/datum/hallucination/dangerflash = 15,
	/datum/hallucination/hudscrew = 12,
	/datum/hallucination/fake_health_doll = 12,
	/datum/hallucination/fake_alert = 12,
	/datum/hallucination/weird_sounds = 8,
	/datum/hallucination/stationmessage = 7,
	/datum/hallucination/fake_flood = 7,
	/datum/hallucination/stray_bullet = 7,
	/datum/hallucination/bolts = 7,
	/datum/hallucination/items_other = 7,
	/datum/hallucination/husks = 7,
	/datum/hallucination/items = 4,
	/datum/hallucination/fire = 3,
	/datum/hallucination/self_delusion = 2,
	/datum/hallucination/delusion = 2,
	/datum/hallucination/shock = 1,
	/datum/hallucination/death = 1,
	/datum/hallucination/oh_yeah = 1
	))


/mob/living/carbon/proc/handle_hallucinations(delta_time, times_fired)
	if(!hallucination)
		return

	hallucination = max(hallucination - (0.5 * delta_time), 0)
	if(world.time < next_hallucination)
		return

	var/halpick = pick_weight(GLOB.hallucination_list)
	new halpick(src, FALSE)

	next_hallucination = world.time + rand(100, 600)

/mob/living/carbon/proc/set_screwyhud(hud_type)
	hal_screwyhud = hud_type
	update_health_hud()

/datum/hallucination
	var/natural = TRUE
	var/mob/living/carbon/target
	var/feedback_details //extra info for investigate

/datum/hallucination/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	target = C
	natural = !forced

	// Cancel early if the target is deleted
	RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/target_deleting)

/datum/hallucination/proc/target_deleting()
	SIGNAL_HANDLER

	qdel(src)

/datum/hallucination/proc/wake_and_restore()
	target.set_screwyhud(SCREWYHUD_NONE)
	target.SetSleeping(0)

/datum/hallucination/Destroy()
	target.investigate_log("was afflicted with a hallucination of type [type] by [natural?"hallucination status":"an external source"]. [feedback_details]", INVESTIGATE_HALLUCINATIONS)

	if (target)
		UnregisterSignal(target, COMSIG_PARENT_QDELETING)

	target = null
	return ..()

//Returns a random turf in a ring around the target mob, useful for sound hallucinations
/datum/hallucination/proc/random_far_turf()
	var/x_based = prob(50)
	var/first_offset = pick(-8,-7,-6,-5,5,6,7,8)
	var/second_offset = rand(-8,8)
	var/x_off
	var/y_off
	if(x_based)
		x_off = first_offset
		y_off = second_offset
	else
		y_off = first_offset
		x_off = second_offset
	var/turf/T = locate(target.x + x_off, target.y + y_off, target.z)
	return T

/obj/effect/hallucination
	invisibility = INVISIBILITY_OBSERVER
	anchored = TRUE
	var/mob/living/carbon/target = null

/obj/effect/hallucination/simple
	var/image_icon = 'icons/mob/alien.dmi'
	var/image_state = "alienh_pounce"
	var/px = 0
	var/py = 0
	var/col_mod = null
	var/image/current_image = null
	var/image_layer = MOB_LAYER
	var/image_plane = GAME_PLANE
	var/active = TRUE //qdelery

/obj/effect/hallucination/singularity_pull()
	return

/obj/effect/hallucination/singularity_act()
	return

/obj/effect/hallucination/simple/Initialize(mapload, mob/living/carbon/T)
	. = ..()
	if(!T)
		stack_trace("A hallucination was created with no target")
		return INITIALIZE_HINT_QDEL
	target = T
	current_image = GetImage()
	if(target.client)
		target.client.images |= current_image

/obj/effect/hallucination/simple/proc/GetImage()
	var/image/I = image(image_icon,src,image_state,image_layer,dir=src.dir)
	I.plane = image_plane
	I.pixel_x = px
	I.pixel_y = py
	if(col_mod)
		I.color = col_mod
	return I

/obj/effect/hallucination/simple/proc/Show(update=1)
	if(active)
		if(target.client)
			target.client.images.Remove(current_image)
		if(update)
			current_image = GetImage()
		if(target.client)
			target.client.images |= current_image

/obj/effect/hallucination/simple/update_icon(updates=ALL, new_state, new_icon, new_px=0, new_py=0)
	image_state = new_state
	if(new_icon)
		image_icon = new_icon
	else
		image_icon = initial(image_icon)
	px = new_px
	py = new_py
	. = ..()
	Show()

/obj/effect/hallucination/simple/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(!loc)
		return
	Show()

/obj/effect/hallucination/simple/Destroy()
	if(target.client)
		target.client.images.Remove(current_image)
	active = FALSE
	return ..()
