
/datum/whim/catnip
	name = "Chase catnip"
	priority = 2
	allow_resting = TRUE
	scan_radius = 10
	var/atom/referring_source

/// See if there's any snacks in the vicinity, if so, set to work after them
/datum/whim/catnip/inner_can_start()
	if(!referring_source)
		abandon()

	if(get_dist(owner, referring_source) < scan_radius)
		return referring_source

/// A bunch of crappy old code neatened up a bit, this handles the actual moving and eating of snacks
/datum/whim/catnip/tick()
	. = ..()
	if(state == WHIM_INACTIVE)
		return

	var/atom/catnip_holder = concerned_target?.loc
	if(!concerned_target || isnull(catnip_holder) || get_dist(owner, catnip_holder) > 10)
		abandon()
		return

	// The below sleeps are how dog snack code already was, i'm just preserving it for my own simplicity, feel free to change it later -ryll, 2020
	//Feeding, chasing food, FOOOOODDDD
	walk_to(owner, get_turf(catnip_holder), 0, rand(15,25) * 0.1)

	catnip_holder = concerned_target?.loc // just in case walk_to sleeps and might break things
	if(!concerned_target || !catnip_holder)		//Does walk_to sleep??
		abandon()
		return

	owner.face_atom(catnip_holder)

	if(!owner.Adjacent(concerned_target)) //can't reach food through windows.
		owner.visible_message("<b>[owner]</b> meows at [catnip_holder]!", vision_distance=COMBAT_MESSAGE_RANGE)
		addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, get_turf(owner), pick('sound/effects/meow1.ogg', 'sound/effects/meow2.ogg'), 50, TRUE), rand(0, 10)) // 0-1 seconds, so there's some variation
		return

	if(isturf(catnip_holder))
		var/obj/item/reagent_containers/food/snacks/actual_food = concerned_target
		owner.set_resting(TRUE)
		// if it's on the ground and is food, eat!!!
		if(istype(actual_food) && actual_food.reagents?.total_volume)
			playsound(get_turf(owner), pick('sound/effects/cat_feed1.ogg','sound/effects/cat_feed2.ogg','sound/effects/cat_feed3.ogg'), 80, TRUE, -2)
			if(prob(50))
				owner.visible_message("<b>[owner]</b> quietly nibbles away at [actual_food].", vision_distance=COMBAT_MESSAGE_RANGE)
			// fake eating the food
			actual_food.reagents.remove_any(1)
			actual_food.bitecount++
			actual_food.On_Consume(owner)

		else // else just meow at it
			owner.visible_message("<b>[owner]</b> meows [pick("directly", "defiantly", "suspiciously", "tiredly")] at [catnip_holder]!", vision_distance=COMBAT_MESSAGE_RANGE)
			addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, get_turf(owner), pick('sound/effects/meow1.ogg', 'sound/effects/meow2.ogg'), 50, TRUE), rand(0, 10))

	else
		harass_catnip_holder()


///Somehow, whether by our frustration, the can ceasing to exist (including being finished off), or whatever, we have decided we don't want that food anymore, so we scrub references on both sides (as needed)
/datum/whim/catnip/proc/harass_catnip_holder()
	var/atom/catnip_holder = concerned_target.loc
	switch(rand(1,3))
		if(1)
			owner.visible_message("<b>[owner]</b> meows [pick("directly", "defiantly", "hungrily", "tiredly")] at [catnip_holder]!", vision_distance=COMBAT_MESSAGE_RANGE)
			addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, get_turf(owner), pick('sound/effects/meow1.ogg', 'sound/effects/meow2.ogg'), 50, TRUE), rand(0, 10))
		if(2)
			owner.visible_message("<b>[owner]</b> rubs up against [catnip_holder]!", vision_distance=COMBAT_MESSAGE_RANGE)
			new /obj/effect/temp_visual/heart(owner.loc)
		if(3)
			owner.visible_message("<b>[owner]</b> stares expectantly at [catnip_holder]!", vision_distance=COMBAT_MESSAGE_RANGE)
			owner.face_atom(catnip_holder)

