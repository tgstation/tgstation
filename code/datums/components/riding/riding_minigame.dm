#define STARTING_ARROW_POSITION -50
#define ENDING_ARROW_POSITION 20
#define VERTICAL_ARROW_HEIGHT 13
#define HORIZONTAL_ARROW_HEIGHT 9
#define FADE_AWAY_TIME 0.1 SECONDS
#define PING_GRACE 0.25 SECONDS

//a simple minigame players must win to mount and tame a mob
/datum/riding_minigame
	///our host mob
	var/datum/weakref/host
	///our current rider
	var/datum/weakref/mounter
	///the total amount of tries the rider gets
	var/maximum_attempts = 25
	///maximum number of failures before we fail
	var/current_attempts = 0
	///required number of successes
	var/required_successes = 11
	///what failures are we on
	var/current_failures = 0
	///we win these
	var/current_succeeded = 0
	///holder of our heart counter
	var/image/heart_counter
	///list of our hearts
	var/list/hearts_list = list()
	///holder of our minigame!
	var/image/minigame_holder
	///cached directional icons of our host
	var/list/cached_arrows = list()
	///speed of our arrow
	var/arrow_speed = 45
	///time to linger
	var/linger_time = 0.3 SECONDS
	///multiplier for easy settings
	var/easy_difficulty_multiplier = 1.1
	///multiplier for hard settings
	var/hard_difficulty_multiplier = 0.9
	///cooldown when we fail
	COOLDOWN_DECLARE(failure_cooldown)

/datum/riding_minigame/New(mob/living/ridden, mob/living/rider)
	. = ..()
	host = WEAKREF(ridden)
	mounter = WEAKREF(rider)
	set_difficulty(ridden, rider)
	RegisterSignal(rider, COMSIG_MOB_UNBUCKLED, PROC_REF(lose_minigame))
	RegisterSignal(ridden, COMSIG_MOVABLE_ATTEMPTED_MOVE, PROC_REF(on_ridden_moved))
	minigame_holder = image(icon='icons/effects/effects.dmi', loc=rider,icon_state="nothing", layer = 0)
	minigame_holder.pixel_w = 32
	heart_counter = image(icon='icons/effects/effects.dmi', loc=rider,icon_state="nothing", layer = 0)
	heart_counter.pixel_z = -32
	SET_PLANE_EXPLICIT(minigame_holder, ABOVE_HUD_PLANE, rider)
	SET_PLANE_EXPLICIT(heart_counter, ABOVE_HUD_PLANE, rider)
	generate_heart_counter()
	generate_visuals()
	rider.client.images |= list(minigame_holder, heart_counter)
	START_PROCESSING(SSprocessing, src)

/datum/riding_minigame/proc/set_difficulty(mob/living/ridden, mob/living/rider)
	if(HAS_TRAIT(rider, TRAIT_BEAST_EMPATHY) || HAS_TRAIT(ridden, TRAIT_MOB_EASY_TO_MOUNT))
		linger_time *= easy_difficulty_multiplier
	if(HAS_TRAIT(ridden, TRAIT_MOB_DIFFICULT_TO_MOUNT))
		linger_time *= hard_difficulty_multiplier

/datum/riding_minigame/proc/generate_visuals()
	var/static/list/void_arrow_order = list(
		"north",
		"west",
		"south",
		"east",
	)
	var/x_offset = 0
	for(var/direction in void_arrow_order)
		var/obj/effect/overlay/vis/ride_minigame/new_arrow = new
		new_arrow.icon = 'icons/effects/riding_minigame.dmi'
		new_arrow.icon_state = "blank_arrow"
		new_arrow.setDir(text2dir(direction))
		new_arrow.pixel_x = x_offset
		new_arrow.pixel_y = ENDING_ARROW_POSITION
		new_arrow.layer = ABOVE_ALL_MOB_LAYER
		minigame_holder.vis_contents += new_arrow
		cached_arrows[direction] = list("visual_object" = new_arrow, "is_active" = null)
		x_offset += 16

/datum/riding_minigame/proc/generate_heart_counter()
	var/x_offset = -32
	for(var/i in 1 to required_successes)
		var/obj/effect/overlay/vis/ride_minigame/heart = new
		heart.icon = 'icons/effects/effects.dmi'
		heart.icon_state = "empty_heart"
		heart.pixel_x = x_offset
		x_offset += 8
		hearts_list += heart
		heart_counter.vis_contents += heart

/datum/riding_minigame/process()
	if(current_attempts >= maximum_attempts)
		lose_minigame()
		return
	if(prob(30)) //we shake and move uncontrollably!
		var/mob/living/living_host = host.resolve()
		living_host.Shake(pixelshiftx = 1, pixelshifty = 0, duration = 0.75 SECONDS)
		living_host.spin(spintime = 0.75 SECONDS, speed = 1)

	generate_arrow()

/datum/riding_minigame/proc/generate_arrow()
	if(current_attempts >= maximum_attempts)
		return
	var/static/list/possible_arrows = list(
		"north" = 0,
		"west" = 16,
		"south" = 32,
		"east" = 48,
	)

	current_attempts++
	var/picked_arrow = pick(possible_arrows)
	var/obj/effect/overlay/vis/ride_minigame/new_arrow = new
	new_arrow.icon = 'icons/effects/riding_minigame.dmi'
	new_arrow.icon_state = "[picked_arrow]_arrow"
	new_arrow.alpha = 0
	new_arrow.layer = ABOVE_ALL_MOB_LAYER + 0.1
	new_arrow.pixel_x = possible_arrows[picked_arrow]
	new_arrow.pixel_y = STARTING_ARROW_POSITION
	minigame_holder.vis_contents += new_arrow

	animate(new_arrow, alpha = 255, time = 0.15 SECONDS)
	animate(new_arrow, pixel_y = ENDING_ARROW_POSITION, time = ((ENDING_ARROW_POSITION - STARTING_ARROW_POSITION) / arrow_speed) SECONDS)

	addtimer(CALLBACK(src, PROC_REF(add_active_arrow), new_arrow, picked_arrow), ((ENDING_ARROW_POSITION - (STARTING_ARROW_POSITION + get_arrow_height(picked_arrow))) / arrow_speed) SECONDS)

/datum/riding_minigame/proc/get_arrow_height(text_direction)
	var/direction = text2dir(text_direction)
	return NSCOMPONENT(direction) ? VERTICAL_ARROW_HEIGHT : HORIZONTAL_ARROW_HEIGHT

/datum/riding_minigame/proc/add_active_arrow(atom/arrow, direction)
	if(QDELETED(arrow))
		return

	if(!COOLDOWN_FINISHED(src, failure_cooldown))
		remove_active_arrow(arrow, direction)
		return

	var/mob/living/rider = mounter?.resolve()
	if(isnull(rider))
		return
	var/client/rider_client = rider.client
	if(isnull(rider_client))
		return
	cached_arrows[direction]["is_active"] = arrow
	RegisterSignal(arrow, COMSIG_QDELETING, PROC_REF(on_arrow_delete))
	var/distance_to_travel = get_arrow_height(direction) * 2
	var/time_of_grace = (distance_to_travel / arrow_speed) SECONDS + linger_time + PING_GRACE - FADE_AWAY_TIME
	addtimer(CALLBACK(src, PROC_REF(remove_active_arrow), arrow, direction), time_of_grace)

/datum/riding_minigame/proc/remove_active_arrow(atom/arrow, direction)
	if(QDELETED(arrow))
		return
	animate(arrow, alpha = 0, time = FADE_AWAY_TIME)
	QDEL_IN(arrow, FADE_AWAY_TIME)

/datum/riding_minigame/proc/on_arrow_delete(datum/source)
	SIGNAL_HANDLER
	for(var/arrow in cached_arrows)
		var/list/arrow_details = cached_arrows[arrow]
		if(arrow_details["is_active"] != source)
			continue
		arrow_details["is_active"] = null

/datum/riding_minigame/proc/on_ridden_moved(atom/movable/source, atom/new_loc, direction)
	SIGNAL_HANDLER
	. = NONE
	if(new_loc.z != source.z || !COOLDOWN_FINISHED(src, failure_cooldown))
		return
	var/list/arrow_data = cached_arrows[dir2text(direction)]
	var/atom/existing_arrow = arrow_data["is_active"]

	if(!QDELETED(existing_arrow))
		qdel(existing_arrow)
		var/atom/arrow_object = arrow_data["visual_object"]
		flick("blank_arrow_win", arrow_object)
		increment_counter()
		return

	for(var/arrow_direction in cached_arrows)
		var/obj/my_arrow = cached_arrows[arrow_direction]["visual_object"]
		if(isnull(my_arrow))
			continue
		var/atom/clickable_arrow = cached_arrows[arrow_direction]["is_active"]
		if(!QDELETED(clickable_arrow))
			qdel(clickable_arrow)
		my_arrow.layer = ABOVE_ALL_MOB_LAYER + 0.2
		flick("blank_arrow_lose", my_arrow)
		my_arrow.Shake(duration = 2 SECONDS)
		addtimer(VARSET_CALLBACK(my_arrow, layer, ABOVE_ALL_MOB_LAYER), 2 SECONDS)

	increment_failure()

/datum/riding_minigame/proc/increment_counter()
	current_succeeded++
	var/obj/new_heart = hearts_list[current_succeeded]
	new_heart.icon_state = "full_heart"
	new_heart.transform = new_heart.transform.Scale(2 ,2)
	animate(new_heart, transform = matrix(), time = 0.3 SECONDS)
	if(current_succeeded >= required_successes)
		win_minigame()

/datum/riding_minigame/proc/increment_failure()
	current_failures++
	COOLDOWN_START(src, failure_cooldown, 2 SECONDS)
	if(current_failures > (maximum_attempts - required_successes))
		lose_minigame()

/datum/riding_minigame/proc/lose_minigame()
	SIGNAL_HANDLER
	var/mob/living/living_host = host?.resolve()
	var/mob/living/living_rider = mounter?.resolve()
	if(isnull(living_host) || isnull(living_rider))
		qdel(src)
		return
	if(LAZYFIND(living_host.buckled_mobs, living_rider))
		UnregisterSignal(living_rider, COMSIG_MOB_UNBUCKLED) //we're about to knock them down!
		living_host.spin(spintime = 2 SECONDS, speed = 1)
		living_rider.Knockdown(4 SECONDS)
		living_host.unbuckle_mob(living_rider)
		living_host.balloon_alert(living_rider, "knocks you down!")
	qdel(src)

/datum/riding_minigame/proc/win_minigame()
	var/mob/living/living_host = host?.resolve()
	var/mob/living/living_rider = mounter?.resolve()
	if(isnull(living_host) || isnull(living_rider))
		qdel(src)
		return
	living_host.befriend(living_rider)
	living_host.balloon_alert(living_rider, "calms down...")
	qdel(src)

/datum/riding_minigame/Destroy()
	STOP_PROCESSING(SSprocessing, src)

	var/mob/living/living_mounter = mounter?.resolve()
	if(living_mounter)
		living_mounter.client.images -= minigame_holder
		living_mounter.client.images -= heart_counter

	mounter = null
	host = null
	hearts_list = null
	cached_arrows = null
	minigame_holder = null
	heart_counter = null
	return ..()

/obj/effect/overlay/vis/ride_minigame
	vis_flags = VIS_INHERIT_PLANE

#undef STARTING_ARROW_POSITION
#undef ENDING_ARROW_POSITION
#undef VERTICAL_ARROW_HEIGHT
#undef HORIZONTAL_ARROW_HEIGHT
#undef FADE_AWAY_TIME
#undef PING_GRACE
