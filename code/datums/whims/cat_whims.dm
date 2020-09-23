/// Broadly, the whims in these files are written with cats in mind

/// The old code for cats hunting nearby mice, now modularized!
/datum/whim/hunt_mice
	name = "Hunt mice"
	priority = 2
	scan_radius = 3
	scan_every = 3

/datum/whim/hunt_mice/inner_can_start()
	//MICE!
	var/atom/possible_target
	for(var/i in oview(owner, scan_radius))
		if(istype(i, /mob/living/simple_animal/mouse))
			possible_target = i
			break
		else if(istype(i, /obj/item/toy/cattoy))
			possible_target = i
			break

	return possible_target

/datum/whim/hunt_mice/tick()
	. = ..()
	if(state == WHIM_INACTIVE)
		return

	if(!concerned_target || !isturf(concerned_target.loc) || get_dist(owner, concerned_target.loc) > scan_radius)
		abandon()
		return

	walk_to(owner, get_turf(concerned_target), 0, rand(20,35) * 0.1)

	if(!concerned_target)		//Not redundant due to sleeps, Item can be gone in 6 decisecomds
		abandon()
		return

	owner.face_atom(concerned_target)
	if(!owner.Adjacent(concerned_target) || !isturf(concerned_target.loc)) //can't reach food through windows.
		return

	if(isliving(concerned_target))
		var/mob/living/living_target = concerned_target
		if(istype(concerned_target, /mob/living/simple_animal/mouse/brown/tom) && (name == "Jerry") && !living_target.stat) //Turns out there's no jerry subtype.
			owner.visible_message("<span class='warning'>[owner] chases [living_target] around, to no avail!</span>")
			step(living_target, pick(GLOB.cardinals))
			abandon()
		else if(istype(concerned_target, /mob/living/simple_animal/mouse))
			var/mob/living/simple_animal/mouse/mouse_target = concerned_target
			owner.manual_emote("splats \the [mouse_target]!")
			mouse_target.splat()
			return
	else if(istype(concerned_target, /obj/item/toy/cattoy))
		var/obj/item/toy/cattoy/toy_target = concerned_target
		if (toy_target.cooldown < (world.time - 400))
			owner.manual_emote("bats \the [toy_target] around with its paw!")
			toy_target.cooldown = world.time
			abandon()


/// If a cat is near a dead mouse and sees that there's a carbon nearby, they will pick up the dead mouse and bring it to the person. Th-thanks, Runtime
/datum/whim/deliver_gift
	name = "Deliver gift"
	priority = 1
	scan_radius = 6
	scan_every = 5
	/// Dead mice we've recently tried gifting
	var/list/recent_gifts

/// We need both the dead mouse and a nearby person to greenlight this, though we save picking out the recepient for later
/datum/whim/deliver_gift/inner_can_start()
	var/obj/item/possible_gift
	var/possible_recepient

	if(prob(1)) // suitably lazy way to make sure we don't keep immediately regifting the same mouse again and again
		LAZYCLEARLIST(recent_gifts)

	for(var/i in oview(owner, scan_radius))
		if(istype(i, /obj/item/reagent_containers/food/snacks/deadmouse) && !(i in recent_gifts))
			var/obj/item/reagent_containers/food/snacks/deadmouse/for_tile_check = i
			if(!locate(/mob/living/carbon) in get_turf(for_tile_check)) // don't gift a mouse that's already at someone's feet
				possible_gift = i
		else if(iscarbon(i))
			possible_recepient = TRUE

		if(possible_gift && possible_recepient)
			return possible_gift

/datum/whim/deliver_gift/abandon()
	if(carried_cargo && owner && carried_cargo.loc == owner) //bleh
		owner.visible_message("<b>[owner] drops [carried_cargo] from [owner.p_their()] mouth.")
	return ..()

/datum/whim/deliver_gift/tick()
	. = ..()
	if(state == WHIM_INACTIVE)
		return

	if(!concerned_target || !isturf(concerned_target.loc) || get_dist(owner, concerned_target.loc) > scan_radius)
		abandon()
		return

	walk_to(owner, get_turf(concerned_target), 0, rand(20,35) * 0.1)

	if(!concerned_target)		//Not redundant due to sleeps, Item can be gone in 6 decisecomds
		abandon()
		return

	owner.face_atom(concerned_target)
	if(!owner.Adjacent(concerned_target) || !isturf(concerned_target.loc)) //can't reach food through windows.
		return

	if(!carried_cargo && istype(concerned_target, /obj/item/reagent_containers/food/snacks/deadmouse))
		// make this its own proc to pick up the mouse and select a recepient
		owner.visible_message("<b>[owner]</b> picks up [concerned_target] in [owner.p_their()] mouth.")
		carried_cargo = concerned_target
		carried_cargo.forceMove(owner)
		for(var/mob/living/carbon/C in oview(owner, scan_radius))
			concerned_target = C
			return

	else if(carried_cargo && iscarbon(concerned_target))
		var/mob/living/carbon/gift_recepient = concerned_target
		owner.visible_message("<span class='notice'>[owner] presents a gift to [gift_recepient], dropping it at [gift_recepient.p_their()] feet! Oh... it's \a [carried_cargo]...")
		carried_cargo.forceMove(get_turf(gift_recepient))
		carried_cargo = null // manually set the carried_cargo to null before abandoning so we don't do another message about dropping the mouse
		abandon()

/datum/whim/deliver_gift/owner_examined(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(state == WHIM_INACTIVE)
		return

	if(carried_cargo)
		examine_list += "<span class='notice'>[owner.p_they(TRUE)] [owner.p_are()] carrying \a [carried_cargo] in [owner.p_their()] mouth.</span>"



/// How am I supposed to believe these are real cats if they're not constantly knocking over open beverages?
/datum/whim/spill_container
	name = "Spill container"
	priority = 2
	scan_radius = 3
	scan_every = 6

/// See if there's any spillable containers we like
/datum/whim/spill_container/inner_can_start()
	for(var/obj/item/reagent_containers/container in oview(owner,scan_radius))
		if(prob(60) || !container.spillable || !container.reagents.total_volume)
			continue
		return container

/// Just walk straight up and knock it over, hell yeah
/datum/whim/spill_container/tick()
	. = ..()
	if(state == WHIM_INACTIVE)
		return

	var/obj/item/reagent_containers/container = concerned_target
	if(!container || !isturf(container.loc) || get_dist(owner, container.loc) > scan_radius)
		abandon()
		return

	walk_to(owner, get_turf(concerned_target), 0, rand(20,35) * 0.1)

	owner.face_atom(concerned_target)
	if(!owner.Adjacent(concerned_target)) //can't reach through windows.
		return

	owner.visible_message("<span class='notice'>[owner] knocks over [container], spilling it!</span>")
	var/atom/spill_target = pick(get_turf(container))
	container.SplashReagents(spill_target, TRUE)
	abandon()
