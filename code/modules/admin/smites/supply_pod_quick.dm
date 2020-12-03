#define SUPPLY_POD_QUICK_DAMAGE 40
#define SUPPLY_POD_QUICK_FIRE_RANGE 2

/// Quickly throws a supply pod at the target, optionally with an item
/datum/smite/supply_pod_quick
	name = "Supply Pod (Quick)"

/datum/smite/supply_pod_quick/effect(client/user, mob/living/target)
	. = ..()

	var/target_path = input(
		user,
		"Enter typepath of an atom you'd like to send with the pod (type \"empty\" to send an empty pod):",
		"Typepath",
		"/obj/item/food/grown/harebell",
	) as null|text

	var/obj/structure/closet/supplypod/centcompod/pod = new
	pod.damage = SUPPLY_POD_QUICK_DAMAGE
	pod.explosionSize = list(0, 0, 0, SUPPLY_POD_QUICK_FIRE_RANGE)
	pod.effectStun = TRUE

	if (isnull(target_path)) //The user pressed "Cancel"
		return

	if (target_path != "empty") // if you didn't type empty, we want to load the pod with a delivery
		var/delivery = text2path(target_path)
		if(!ispath(delivery))
			delivery = pick_closest_path(target_path)
			if(!delivery)
				alert(user, "ERROR: Incorrect / improper path given.")
				return
		new delivery(pod)

	new /obj/effect/pod_landingzone(get_turf(target), pod)

#undef SUPPLY_POD_QUICK_DAMAGE
#undef SUPPLY_POD_QUICK_FIRE_RANGE
