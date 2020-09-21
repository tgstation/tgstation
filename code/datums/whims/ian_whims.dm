

/datum/whim/defend_office
	name = "Defend Office"
	priority = 2
	scan_radius = 4
	scan_every = 5
	var/list/defendable_areas = list(/area/crew_quarters/heads/hop)

/// See if there's any snacks in the vicinity, if so, set to work after them
/datum/whim/defend_office/inner_can_start()
	//if(!is_type_in_list(get_area(owner), defendable_areas))
	//	return FALSE

	for(var/i in oview(owner,scan_radius))
	//	if(!is_type_in_list(get_area(i), defendable_areas))
	//		continue
		if(ishuman(i))
			var/mob/living/carbon/human/potential_threat = i
			if(!(potential_threat.mind?.assigned_role in list("Head of Personnel", "Captain")))
				return potential_threat
		else if(iscarbon(i))
			var/mob/living/carbon/potential_threat = i
			return potential_threat

/// A bunch of crappy old code neatened up a bit, this handles the actual moving and eating of snacks
/datum/whim/defend_office/tick()
	. = ..()
	if(state == WHIM_INACTIVE)
		return

	if(!concerned_target || isnull(concerned_target.loc) || get_dist(owner, concerned_target.loc) > scan_radius)
		abandon()
		return

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

/datum/whim/defend_office/proc/bin_threat(obj/machinery/disposal/bin/convenient_bin)
	var/mob/living/carbon/carbon_target = concerned_target
	if(!istype(carbon_target) || !owner.Adjacent(carbon_target) || !concerned_target.Adjacent(carbon_target))
		return

	carbon_target.Knockdown(SHOVE_KNOCKDOWN_SOLID)
	carbon_target.forceMove(convenient_bin)
	carbon_target.visible_message("<span class='danger'>[owner] shoves [carbon_target] into \the [convenient_bin]!</span>",
				"<span class='userdanger'>You're shoved into \the [convenient_bin] by [owner]!</span>", "<span class='hear'>You hear aggressive shuffling followed by a loud thud!</span>", COMBAT_MESSAGE_RANGE)
	convenient_bin.flush = TRUE

	owner.SpinAnimation(10, 1)
	abandon()
