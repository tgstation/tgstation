/datum/action/cooldown/blood_warp
	name = "Blood Warp"
	icon_icon = 'icons/effects/blood.dmi'
	button_icon_state = "floor1"
	desc = "Allows you to teleport to blood at a clicked position."
	cooldown_time = 0
	text_cooldown = FALSE
	click_to_activate = TRUE
	shared_cooldown = MOB_SHARED_COOLDOWN

/datum/action/cooldown/blood_warp/Activate(var/atom/target_atom)
	StartCooldown(100)
	blood_warp(target_atom)
	StartCooldown()

/datum/action/cooldown/blood_warp/proc/blood_warp(var/atom/target)
	if(owner.Adjacent(target))
		return FALSE
	var/list/can_jaunt = get_bloodcrawlable_pools(get_turf(owner), 1)
	if(!can_jaunt.len)
		return FALSE

	var/list/pools = get_bloodcrawlable_pools(get_turf(target), 5)
	var/list/pools_to_remove = get_bloodcrawlable_pools(get_turf(target), 4)
	pools -= pools_to_remove
	if(!pools.len)
		return FALSE

	var/obj/effect/temp_visual/decoy/DA = new /obj/effect/temp_visual/decoy(owner.loc, owner)
	DA.color = "#FF0000"
	var/oldtransform = DA.transform
	DA.transform = matrix()*2
	animate(DA, alpha = 255, color = initial(DA.color), transform = oldtransform, time = 3)
	SLEEP_CHECK_DEATH(3, owner)
	qdel(DA)

	var/obj/effect/decal/cleanable/blood/found_bloodpool
	pools = get_bloodcrawlable_pools(get_turf(target), 5)
	pools_to_remove = get_bloodcrawlable_pools(get_turf(target), 4)
	pools -= pools_to_remove
	if(pools.len)
		shuffle_inplace(pools)
		found_bloodpool = pick(pools)
	if(found_bloodpool)
		owner.visible_message("<span class='danger'>[owner] sinks into the blood...</span>")
		playsound(get_turf(owner), 'sound/magic/enter_blood.ogg', 100, TRUE, -1)
		owner.forceMove(get_turf(found_bloodpool))
		playsound(get_turf(owner), 'sound/magic/exit_blood.ogg', 100, TRUE, -1)
		owner.visible_message("<span class='danger'>And springs back out!</span>")
		SEND_SIGNAL(owner, COMSIG_BLOOD_WARP)
		return TRUE
	return FALSE

/proc/get_bloodcrawlable_pools(turf/T, range)
	. = list()
	for(var/obj/effect/decal/cleanable/nearby in view(T, range))
		if(nearby.can_bloodcrawl_in())
			. += nearby
