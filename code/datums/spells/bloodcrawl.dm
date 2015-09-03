/obj/effect/proc_holder/spell/bloodcrawl
	name = "Blood crawl"
	desc = "Use blood to travel."
	charge_max = 10
	clothes_req = 0
	selection_type = "range"
	range = 1
	cooldown_min = 0
	overlay = null
	action_icon_state = "bloodcrawl"
	var/phased = 0

/obj/effect/proc_holder/spell/bloodcrawl/choose_targets(mob/user = usr)
	for(var/obj/effect/decal/cleanable/target in range(range, get_turf(user)))
		if(istype(target, /obj/effect/decal/cleanable/blood) || istype(target, /obj/effect/decal/cleanable/trail_holder))
			perform(target)
			return
	revert_cast()
	user << "<span class='warning'>You need blood to blood crawl.</span>"

/obj/effect/proc_holder/spell/bloodcrawl/perform(obj/effect/decal/cleanable/target, recharge = 1, mob/living/user = usr)
	if(istype(user))
		if(phased)
			if(user.phasein(target))
				phased = 0
		else
			user.phaseout(target)
			phased = 1
		start_recharge()
		return
	revert_cast()
	user << "<span class='warning'>You cannot blood crawl.</span>"