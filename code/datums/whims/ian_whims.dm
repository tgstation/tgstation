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


/// Awkwardly named, if our friend is on a tile whose lumcount is below this, we'll see about getting them to a better lit place
#define WHIM_MOURN_MAX_LIGHT_DRAG	0.4
/// This is how much our lighting_standards var decreases per tick, so we accept darker and darker tiles the longer we go on
#define WHIM_MOURN_LIGHT_STD_DECAY	0.08
/// This is how much our lighting_standards var decreases per tick, so we accept darker and darker tiles the longer we go on
#define WHIM_MOURN_SEARCH_LIGHT_CD	10 SECONDS

/// If Ian sees his beloved owner's corpse, he'll get all sad and try waking them up... What a good boy, not like cats. Cats will just start eating your face, evil things.
/datum/whim/mourn
	name = "Mourn owner"
	priority = 2
	scan_radius = 6
	scan_every = 15
	//abandon_rescan_length = 2 MINUTES
	abandon_rescan_length = 5 SECONDS
	ticks_to_frustrate = 30 // longer frustrate time since this is a very passive whim
	blocks_auto_speech = TRUE // so we don't ruin the moment by YAP'ing

	/// What assigned_roles we mourn
	var/list/mournable_roles = list("Head of Personnel")
	/// If we're dragging our dead friend to a better lit turf, this is that turf
	var/turf/dragging_friend_to
	/// Instance variable that represents how much light we want our friend to be on to be successful. Lowers by WHIM_MOURN_LIGHT_STD_DECAY each tick, starts at 1 when we start dragging
	var/lighting_standards
	/// Looking for a lighter turf is pretty intensive, so it gets its own inner cooldown
	COOLDOWN_DECLARE(search_lighter_turf_cooldown)

/datum/whim/mourn/abandon()
	if(owner.pulling == concerned_target)
		owner.stop_pulling()
	dragging_friend_to = null
	return ..()

/datum/whim/mourn/inner_can_start()
	// anything can be a potential dead friend with the right mindset
	for(var/mob/living/carbon/human/potential_dead_friend in oview(owner,scan_radius))
		var/role = potential_dead_friend.mind?.assigned_role
		if(potential_dead_friend.looks_dead() && role && (role in mournable_roles))
			return potential_dead_friend

/datum/whim/mourn/tick()
	. = ..()
	if(state == WHIM_INACTIVE)
		return

	if(!concerned_target || isnull(concerned_target.loc) || get_dist(owner, concerned_target.loc) > scan_radius)
		abandon()
		return

	var/mob/living/carbon/human/my_dead_friend = concerned_target // :(

	if(!my_dead_friend.looks_dead()) // my_not_so_dead_friend
		owner.manual_emote("yaps excitedly at [my_dead_friend]!")
		owner.SpinAnimation(3, 2)
		abandon()
		return

	// if someone's pulling your friend, follow and bark at them warily, but don't snatch the friend away
	var/mob/puller = my_dead_friend.pulledby
	if(puller && puller != owner)
		if(get_dist(owner, puller) > 2)
			step_towards(owner, my_dead_friend)
		else if(prob(20))
			owner.manual_emote("barks at [puller].")
		return

	// if we're in the process of dragging towards the light, keep on with it
	if(dragging_friend_to)
		drag_to_light()
		return

	if(owner.Adjacent(my_dead_friend))
		if(try_start_drag_to_light()) // see if it's too dark for comfort here and if we can move them somewhere brighter
			return
		else if(prob(30))
			switch(rand(1,3))
				if(1)
					owner.visible_message("<b>[owner]</b> nuzzles [my_dead_friend]'s corpse, trying to wake [my_dead_friend.p_them()] up...")
				if(2)
					owner.visible_message("<b>[owner]</b> licks at [my_dead_friend]'s face.")
			playsound(owner.loc, "sound/effects/dog_whine1.ogg", 80)
			return

	if(prob(40 + (15 * get_dist(owner, my_dead_friend))))
		step_towards(owner, my_dead_friend)
		return

	switch(rand(1,6))
		if(1)
			owner.manual_emote("stares uncomprehendingly at [my_dead_friend]'s lifeless body.")
		if(2)
			owner.manual_emote("cocks their head, confused by [my_dead_friend]'s stillness.")
		if(3)
			owner.manual_emote("gently prods at [my_dead_friend] with a paw.")

/**
  * This proc is used to run a series of checks for whether we can move our dead friend to a more well lit area, so they'll be easier to find
  *
  * To qualify for dragging, our friend must not be buckled or pulled by anyone else, be on a tile with < WHIM_MOURN_MAX_LIGHT_DRAG lumcount, and have a lighter tile visible within 6 tiles
  * If all that goes well and we find a target tile, we start the dragging and will continue it in [/datum/whim/mourn/proc/drag_to_light]
  */
/datum/whim/mourn/proc/try_start_drag_to_light()
	if(!COOLDOWN_FINISHED(src, search_lighter_turf_cooldown))
		return FALSE

	var/mob/living/carbon/human/my_dead_friend = concerned_target
	if(owner.pulling || my_dead_friend.buckled || my_dead_friend.pulledby)
		return FALSE

	var/turf/dead_friend_turf = get_turf(my_dead_friend)
	var/dead_friend_light = dead_friend_turf.get_lumcount()

	if(dead_friend_light > WHIM_MOURN_MAX_LIGHT_DRAG)
		return FALSE

	dragging_friend_to = null
	var/list/turf/nearby_turfs = RANGE_TURFS(6, owner)
	var/turf/targ_turf

	for(var/turf/T in nearby_turfs)
		if(T.density || isspaceturf(T) || !can_see(owner, T))
			nearby_turfs -= T

	COOLDOWN_START(src, search_lighter_turf_cooldown, WHIM_MOURN_SEARCH_LIGHT_CD)
	var/best_lum = dead_friend_light
	for(var/i in 1 to max(length(nearby_turfs), 10))
		var/turf/random_turf = pick_n_take(nearby_turfs)
		var/turf_light = random_turf.get_lumcount()
		if(turf_light <= best_lum)
			continue
		best_lum = turf_light
		targ_turf = random_turf

	if(targ_turf)
		owner.start_pulling(my_dead_friend)
		owner.visible_message("<span class='notice'>[owner] begins feebly dragging [my_dead_friend] towards light!</span>")
		lighting_standards = 1
		dragging_friend_to = targ_turf
		return TRUE

/// We're engaged in dragging, keep on it until we get to a sufficiently bright tile (or we get frustrated and give up)
/datum/whim/mourn/proc/drag_to_light()
	var/mob/living/carbon/human/my_dead_friend = concerned_target
	if(!owner.Adjacent(my_dead_friend) || owner.pulling != my_dead_friend)
		dragging_friend_to = null
		return

	step_towards(owner, dragging_friend_to)
	var/turf/dead_friend_turf = get_turf(my_dead_friend)
	var/dead_friend_light = dead_friend_turf.get_lumcount()
	if(dead_friend_light < lighting_standards) // we start at 1 when we start dragging and gradually accept darker tiles each tick
		lighting_standards -= WHIM_MOURN_LIGHT_STD_DECAY
	else
		owner.visible_message("<span class='notice'>[owner] stops dragging [my_dead_friend], nuzzling [my_dead_friend.p_them()] worriedly.</span>")
		playsound(owner.loc, "sound/effects/dog_whine1.ogg", 80)
		dragging_friend_to = null
	return

#undef WHIM_MOURN_MAX_LIGHT_DRAG
#undef WHIM_MOURN_LIGHT_STD_DECAY
#undef WHIM_MOURN_SEARCH_LIGHT_CD
