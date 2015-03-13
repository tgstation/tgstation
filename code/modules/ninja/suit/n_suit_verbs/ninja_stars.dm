

//Shoots ninja stars at a random target
/obj/item/clothing/suit/space/space_ninja/proc/ninjastar()
	set name = "Energy Star (5E)"
	set desc = "Launches an energy star at a random living target."
	set category = "Ninja Ability"
	set popup_menu = 0

	if(!ninjacost(50))
		var/mob/living/carbon/human/H = affecting
		var/list/targets = list()
		for(var/mob/living/M in oview(loc))
			if(M.stat)	continue//Doesn't target corpses or paralyzed persons.
			targets.Add(M)
		if(targets.len)
			var/mob/living/target=pick(targets)//The point here is to pick a random, living mob in oview to shoot stuff at.

			var/turf/curloc = get_turf(H)
			var/turf/targloc = get_turf(target)
			if (!targloc || !curloc)
				return
			if (targloc == curloc)
				return
			var/obj/item/projectile/energy/dart/A = new /obj/item/projectile/energy/dart(curloc)
			A.current = curloc
			A.yo = targloc.y - curloc.y
			A.xo = targloc.x - curloc.x

			A.fire()
		else
			H << "<span class='danger'>There are no targets in view.</span>"
	return
