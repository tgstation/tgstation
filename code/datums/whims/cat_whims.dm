/datum/whim/hunt_mice
	name = "Hunt mice"
	priority = 2
	scan_radius = 3


/// See if there's any snacks in the vicinity, if so, set to work after them
/datum/whim/hunt_mice/inner_can_start()
	//MICE!
	var/atom/possible_target
	for(var/i in oview(owner, scan_radius))
		//testing("[owner] searching whim [name], atom [i]")
		if(istype(i, /mob/living/simple_animal/mouse))
			possible_target = i
			break
		else if(istype(i, /obj/item/toy/cattoy))
			possible_target = i
			break

	return possible_target

/// A bunch of crappy old code neatened up a bit, this handles the actual moving and eating of snacks
/datum/whim/hunt_mice/tick()
	. = ..()
	if(state == WHIM_INACTIVE)
		return

	if(!concerned_target || !isturf(concerned_target.loc) || get_dist(owner, concerned_target.loc) > scan_radius)
		abandon()
		return

	// The below sleeps are how dog snack code already was, i'm just preserving it for my own simplicity, feel free to change it later -ryll, 2020
	//Feeding, chasing food, FOOOOODDDD
	step_to(owner,concerned_target,1)
	sleep(3)
	step_to(owner,concerned_target,1)
	sleep(3)
	step_to(owner,concerned_target,1)

	if(!concerned_target)		//Not redundant due to sleeps, Item can be gone in 6 decisecomds
		abandon()
		return

	owner.face_atom(concerned_target)
	if(!owner.Adjacent(concerned_target) || !isturf(concerned_target.loc)) //can't reach food through windows.
		return

	if(isliving(concerned_target))
		var/mob/living/living_target = concerned_target
		if(istype(concerned_target, /mob/living/simple_animal/mouse/brown/tom) && (name == "Jerry") && !living_target.stat) //Turns out there's no jerry subtype.
			/*
			if(owner.emote_cooldown < (world.time - 600))
				owner.visible_message("<span class='warning'>[owner] chases [living_target] around, to no avail!</span>")
				owner.step(living_target, pick(GLOB.cardinals))
				owner.emote_cooldown = world.time
				abandon()
			*/
			owner.visible_message("<span class='warning'>[owner] chases [living_target] around, to no avail!</span>")
			step(living_target, pick(GLOB.cardinals))
			abandon()
		else if(istype(concerned_target, /mob/living/simple_animal/mouse))
			var/mob/living/simple_animal/mouse/mouse_target = concerned_target
			//if(mouse_target.sp)
			owner.manual_emote("splats \the [mouse_target]!")
			mouse_target.splat()
			return
	else if(istype(concerned_target, /obj/item/toy/cattoy))
		var/obj/item/toy/cattoy/toy_target = concerned_target
		if (toy_target.cooldown < (world.time - 400))
			owner.manual_emote("bats \the [toy_target] around with its paw!")
			toy_target.cooldown = world.time
			abandon()





/datum/whim/deliver_gift
	name = "Deliver gift"
	priority = 1
	scan_radius = 6
	var/obj/item/gift

/// See if there's any snacks in the vicinity, if so, set to work after them
/datum/whim/deliver_gift/inner_can_start()
	var/obj/item/possible_gift
	var/possible_recepient

	for(var/i in oview(owner, scan_radius))
		//testing("[owner] searching whim [name], atom [i]")
		if(istype(i, /obj/item/reagent_containers/food/snacks/deadmouse))
			var/obj/item/reagent_containers/food/snacks/deadmouse/for_tile_check = i
			if(!locate(/mob/living/carbon) in get_turf(for_tile_check)) // don't gift a mouse that's already at someone's feet
				possible_gift = i
		else if(iscarbon(i))
			possible_recepient = TRUE

	if(possible_gift && possible_recepient)
		return possible_gift

/// A bunch of crappy old code neatened up a bit, this handles the actual moving and eating of snacks
/datum/whim/deliver_gift/abandon()
	if(gift && owner && gift.loc == owner)
		owner.visible_message("<b>[owner] drops [gift] from [owner.p_their()] mouth.")
		gift.forceMove(owner.drop_location())
	gift = null
	return ..()

/// A bunch of crappy old code neatened up a bit, this handles the actual moving and eating of snacks
/datum/whim/deliver_gift/tick()
	. = ..()
	if(state == WHIM_INACTIVE)
		return

	if(!concerned_target || !isturf(concerned_target.loc) || get_dist(owner, concerned_target.loc) > scan_radius)
		abandon()
		return

	// The below sleeps are how dog snack code already was, i'm just preserving it for my own simplicity, feel free to change it later -ryll, 2020
	//Feeding, chasing food, FOOOOODDDD
	step_to(owner,concerned_target,1)
	sleep(3)
	step_to(owner,concerned_target,1)
	sleep(3)
	step_to(owner,concerned_target,1)

	if(!concerned_target)		//Not redundant due to sleeps, Item can be gone in 6 decisecomds
		abandon()
		return

	owner.face_atom(concerned_target)
	if(!owner.Adjacent(concerned_target) || !isturf(concerned_target.loc)) //can't reach food through windows.
		return

	if(!gift && istype(concerned_target, /obj/item/reagent_containers/food/snacks/deadmouse))
		// make this its own proc to pick up the mouse and select a recepient
		owner.visible_message("<b>[owner]</b> picks up [concerned_target] in [owner.p_their()] mouth.")
		gift = concerned_target
		gift.forceMove(owner)
		for(var/mob/living/carbon/C in oview(owner, scan_radius))
			concerned_target = C
			return
	else if(gift && iscarbon(concerned_target))
		var/mob/living/carbon/gift_recepient = concerned_target
		owner.visible_message("<span class='notice'>[owner] presents a gift to [gift_recepient], dropping it at [gift_recepient.p_their()] feet! Oh... it's \a [gift]...")
		gift.forceMove(get_turf(gift_recepient))
		gift = null
		abandon()
