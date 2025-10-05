/datum/action/cooldown/mob_cooldown/blood_warp
	name = "Blood Warp"
	button_icon = 'icons/effects/blood.dmi'
	button_icon_state = "floor1"
	desc = "Allows you to teleport to blood at a clicked position."
	cooldown_time = 0 SECONDS
	/// The range of turfs to try to jaunt to from around the target
	var/pick_range = 5
	/// The range of turfs if a client is using this ability
	var/client_pick_range = 0
	/// Whether or not to remove the inside of our radius from the possible pools to jaunt to
	var/remove_inner_pools = TRUE

/datum/action/cooldown/mob_cooldown/blood_warp/Activate(atom/target_atom)
	disable_cooldown_actions()
	blood_warp(target_atom)
	StartCooldown()
	enable_cooldown_actions()
	return TRUE

/datum/action/cooldown/mob_cooldown/blood_warp/proc/blood_warp(atom/target)
	if(owner.Adjacent(target))
		return FALSE

	var/turf/target_turf = get_turf(target)
	var/turf/owner_turf = get_turf(owner)

	if (target_turf.z != owner_turf.z)
		return FALSE

	var/list/can_jaunt = get_bloodcrawlable_pools(owner_turf, 1)
	if(!can_jaunt.len)
		return FALSE

	var/chosen_pick_range = get_pick_range()
	var/list/pools = get_bloodcrawlable_pools(target_turf, chosen_pick_range)
	if(remove_inner_pools)
		var/list/pools_to_remove = get_bloodcrawlable_pools(target_turf, chosen_pick_range - 1)
		pools -= pools_to_remove
	if(!pools.len)
		return FALSE

	var/obj/effect/temp_visual/decoy/DA = new /obj/effect/temp_visual/decoy(owner.loc, owner)
	DA.color = COLOR_RED
	var/oldtransform = DA.transform
	DA.transform = matrix()*2
	animate(DA, alpha = 255, color = initial(DA.color), transform = oldtransform, time = 3)
	SLEEP_CHECK_DEATH(0.3 SECONDS, owner)
	qdel(DA)

	var/obj/effect/decal/cleanable/blood/found_bloodpool
	pools = get_bloodcrawlable_pools(target_turf, chosen_pick_range)
	if(remove_inner_pools)
		var/list/pools_to_remove = get_bloodcrawlable_pools(target_turf, chosen_pick_range - 1)
		pools -= pools_to_remove
	if(pools.len)
		shuffle_inplace(pools)
		found_bloodpool = pick(pools)
	if(found_bloodpool)
		owner.visible_message(span_danger("[owner] sinks into the blood..."))
		playsound(owner_turf, 'sound/effects/magic/enter_blood.ogg', 100, TRUE, -1)
		owner.forceMove(get_turf(found_bloodpool))
		playsound(get_turf(owner), 'sound/effects/magic/exit_blood.ogg', 100, TRUE, -1)
		owner.visible_message(span_danger("And springs back out!"))
		SEND_SIGNAL(owner, COMSIG_BLOOD_WARP)
		return TRUE
	return FALSE

/datum/action/cooldown/mob_cooldown/blood_warp/proc/get_pick_range()
	if(owner.client)
		return client_pick_range
	return pick_range

/proc/get_bloodcrawlable_pools(turf/T, range)
	if(range < 0)
		return list()
	. = list()
	for(var/obj/effect/decal/cleanable/nearby in view(T, range))
		if(nearby.can_bloodcrawl_in())
			. += nearby
