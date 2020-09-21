/// These whims are written specifically with Ian in mind, in his role as the HoP's beloved pet. I used assigned_role to identify the HoP because i'm lazy, I need to account for changeling disguises as well

/// If someone who isn't the HoP or Captain is in the HoP's office, Ian will get all territorial, fun!
/datum/whim/defend_office
	name = "Defend Office"
	priority = 2
	scan_radius = 4
	scan_every = 8
	/// Which areas this whim is valid for
	var/list/defendable_areas = list(/area/crew_quarters/heads/hop)
	/// Which assigned_roles this whim won't assault
	var/list/exempted_roles = list("Head of Personnel", "Captain")

/datum/whim/defend_office/inner_can_start()
	//if(!is_type_in_list(get_area(owner), defendable_areas))
	//	return FALSE

	for(var/i in oview(owner,scan_radius))
	//	if(!is_type_in_list(get_area(i), defendable_areas))
	//		continue
		if(isliving(i))
			var/mob/living/living_target = i
			if(living_target.stat == DEAD)
				continue
		if(ishuman(i))
			var/mob/living/carbon/human/potential_threat = i
			var/role = potential_threat.mind?.assigned_role
			if(role && !(role in exempted_roles))
				return potential_threat
		else if(iscarbon(i))
			var/mob/living/carbon/potential_threat = i
			return potential_threat

/datum/whim/defend_office/tick()
	. = ..()
	if(state == WHIM_INACTIVE)
		return

	if(!concerned_target || isnull(concerned_target.loc) || get_dist(owner, concerned_target.loc) > scan_radius)
		abandon()
		return

	// the only defensive behavior I actually have right now is jumpkicking people standing next to a disposal bin into it and flushing it, expect more noisy growling and barking later
	var/obj/machinery/disposal/bin/convenient_bin = (locate(/obj/machinery/disposal/bin) in range(concerned_target, 1))
	if(convenient_bin)
		var/datum/callback/tackle = CALLBACK(src, .proc/bin_threat, convenient_bin)
		owner.throw_at(concerned_target, 10, 4, owner, FALSE, FALSE, tackle)
		return

	walk_to(owner, get_step_towards(concerned_target, owner), 0, rand(15,25) * 0.1)

	if(!concerned_target)		//Not redundant due to sleeps, Item can be gone in 6 decisecomds
		abandon()
		return

	owner.face_atom(concerned_target)
	if(!owner.Adjacent(concerned_target)) //can't reach food through windows.
		return

	if(isturf(concerned_target.loc))
		concerned_target.attack_animal(owner)
	else if(ishuman(concerned_target.loc))
		if(prob(20))
			owner.manual_emote("stares at [concerned_target.loc]'s [concerned_target] with a sad puppy-face")

/// For the callback from Ian throwing himself at an intruder, to tackle them into a disposal bin and flush it
/datum/whim/defend_office/proc/bin_threat(obj/machinery/disposal/bin/convenient_bin)
	var/mob/living/carbon/carbon_target = concerned_target
	if(!istype(carbon_target) || !owner.Adjacent(carbon_target) || !concerned_target.Adjacent(carbon_target))
		return

	carbon_target.Knockdown(SHOVE_KNOCKDOWN_SOLID)
	carbon_target.forceMove(convenient_bin)
	carbon_target.visible_message("<span class='danger'>[owner] shoves [carbon_target] into \the [convenient_bin]!</span>",
				"<span class='userdanger'>You're shoved into \the [convenient_bin] by [owner]!</span>", "<span class='hear'>You hear aggressive shuffling followed by a loud thud!</span>", COMBAT_MESSAGE_RANGE)
	convenient_bin.flush = TRUE

	owner.SpinAnimation(10, 1) // flair on 'em
	abandon()


/// If Ian sees his beloved owner's corpse, he'll get all sad and try waking them up... What a good boy, not like cats. Cats will just start eating your face, evil things.
/datum/whim/mourn
	name = "Mourn owner"
	priority = 2
	scan_radius = 5
	scan_every = 10
	abandon_rescan_length = 2 MINUTES
	ticks_to_frustrate = 30 // longer frustrate time since this is a very passive whim
	/// What assigned_roles we mourn
	var/list/mournable_roles = list("Head of Personnel")

/datum/whim/mourn/inner_can_start()
	for(var/i in oview(owner,scan_radius))
	//	if(!is_type_in_list(get_area(i), defendable_areas))
	//		continue
		if(ishuman(i))
			var/mob/living/carbon/human/potential_target = i
			var/role = potential_target.mind?.assigned_role
			if(potential_target.stat == DEAD && role && (role in mournable_roles))
				return potential_target

/datum/whim/mourn/tick()
	. = ..()
	if(state == WHIM_INACTIVE)
		return

	if(!concerned_target || isnull(concerned_target.loc) || get_dist(owner, concerned_target.loc) > scan_radius)
		abandon()
		return

	var/mob/living/carbon/human/my_dead_friend = concerned_target // :(

	if(prob(30 - (5 * get_dist(owner, my_dead_friend))))
		step_towards(owner, my_dead_friend)

	if(!concerned_target)
		abandon()
		return

	owner.face_atom(concerned_target)

	// lots more work to do fleshing this out obv
	if(owner.Adjacent(my_dead_friend))
		if(prob(10))
			owner.visible_message("<b>[owner]</b> nuzzles [my_dead_friend]'s corpse, trying to wake [my_dead_friend.p_them()] up...")
			playsound(owner.loc, "sound/effects/dog_whine1.ogg", 80)
		return

	switch(rand(1,5))
		if(1)
			owner.visible_message("<b>[owner]</b> stares uncomprehendingly at [my_dead_friend]'s lifeless body.")

