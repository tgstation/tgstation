/// Everything in the hallucinator's view looks like it's burning, and fake burning copies of someone run around.
/datum/hallucination/everything_on_fire
	/// How long the vision lasts
	var/duration = 15 SECONDS
	/// How many fake burning copies of the heretic run around
	var/fake_count = 6
	/// Burning item images. Passed in so every victim of one flash shares the same ones instead of each building their own.
	var/list/item_images
	/// Fake burning copies of the heretic. Shared between every victim of one flash, they go away once nobody sees them.
	var/list/fakes
	/// Who the fake copies look like. Only held until start(), so it can't cause a hard delete.
	var/mob/living/fake_source
	/// Assoc list of mob -> the fire image we put over them
	var/list/mob_images

/datum/hallucination/everything_on_fire/New(mob/living/hallucinator, duration, list/shared_item_images, list/shared_fakes, mob/living/fake_source)
	if(isnum(duration))
		src.duration = duration
	item_images = shared_item_images
	fakes = shared_fakes
	src.fake_source = fake_source
	return ..()

/datum/hallucination/everything_on_fire/Destroy()
	if(!QDELETED(hallucinator))
		UnregisterSignal(hallucinator, COMSIG_MOB_LOGIN)
		hallucinator.client?.images -= item_images
		hallucinator.client?.images -= assoc_to_values(mob_images)
	for(var/mob/living/burning as anything in mob_images)
		UnregisterSignal(burning, COMSIG_QDELETING)
	for(var/obj/effect/client_image_holder/fake as anything in fakes)
		if(!QDELETED(fake))
			fake.remove_seer(hallucinator)
	item_images = null
	fakes = null
	fake_source = null
	mob_images = null
	return ..()

/datum/hallucination/everything_on_fire/start()
	var/list/seen = view(hallucinator)
	if(!item_images)
		item_images = list()
		for(var/obj/item/burning_item in seen)
			if(!isturf(burning_item.loc))
				continue
			var/image/item_image = image(GLOB.fire_overlay, burning_item)
			SET_PLANE_EXPLICIT(item_image, GAME_PLANE, burning_item)
			item_images += item_image

	for(var/mob/living/burning in seen)
		var/image/mob_fire_image = image(burning.get_fire_overlay(MAX_FIRE_STACKS, TRUE) || burning.make_generic_fire_overlay(), burning)
		SET_PLANE_EXPLICIT(mob_fire_image, GAME_PLANE, burning)
		LAZYSET(mob_images, burning, mob_fire_image)
		if(burning != hallucinator)
			RegisterSignal(burning, COMSIG_QDELETING, PROC_REF(on_mob_delete))

	if(fakes)
		for(var/obj/effect/client_image_holder/fake as anything in fakes)
			if(!QDELETED(fake))
				fake.add_seer(hallucinator)
	else if(fake_source)
		fakes = list()
		var/list/spawn_locs = list()
		for(var/turf/open/floor in view(fake_source))
			if(!floor.is_blocked_turf(exclude_mobs = TRUE))
				spawn_locs += floor
		for(var/i in 1 to min(fake_count, length(spawn_locs)))
			fakes += new /obj/effect/client_image_holder/burning_fake(pick(spawn_locs), hallucinator, fake_source)
	fake_source = null

	hallucinator.client?.images += item_images
	hallucinator.client?.images += assoc_to_values(mob_images)
	RegisterSignal(hallucinator, COMSIG_MOB_LOGIN, PROC_REF(on_login))
	to_chat(hallucinator, span_userdanger("The whole world bursts into flame around you!"))
	QDEL_IN(src, duration)
	return TRUE

/datum/hallucination/everything_on_fire/proc/on_login(mob/living/source)
	SIGNAL_HANDLER

	source.client.images += item_images
	source.client.images += assoc_to_values(mob_images)

/datum/hallucination/everything_on_fire/proc/on_mob_delete(mob/living/source)
	SIGNAL_HANDLER

	hallucinator.client?.images -= mob_images[source]
	LAZYREMOVE(mob_images, source)

/// A copy of someone, burning, that only the people it was made for can see. It runs around at random.
/obj/effect/client_image_holder/burning_fake

/obj/effect/client_image_holder/burning_fake/Initialize(mapload, list/mobs_which_see_us, mob/living/copied)
	var/mutable_appearance/look = copy_appearance_filter_overlays(copied.appearance)
	look.overlays += copied.get_fire_overlay(MAX_FIRE_STACKS, TRUE) || copied.make_generic_fire_overlay()
	image_icon = look
	dir = copied.dir
	. = ..()
	GLOB.move_manager.move_to_rand(src, 0.2 SECONDS)

/obj/effect/client_image_holder/burning_fake/Move(atom/newloc, direction, glide_size_override = 0, update_dir = TRUE)
	if(isturf(newloc))
		var/turf/new_turf = newloc
		if(new_turf.is_blocked_turf(exclude_mobs = TRUE))
			return FALSE
	return ..()
