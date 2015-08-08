/mob/living/carbon/alien/humanoid/drone
	name = "alien drone"
	caste = "d"
	maxHealth = 100
	health = 100
	icon_state = "aliend_s"
	plasma_rate = 15


/mob/living/carbon/alien/humanoid/drone/New()
	create_reagents(100)
	if(src.name == "alien drone")
		src.name = text("alien drone ([rand(1, 1000)])")
	src.real_name = src.name

	AddAbility(new/obj/effect/proc_holder/alien/resin(null))
	AddAbility(new/obj/effect/proc_holder/alien/acid(null))
	AddAbility(new/obj/effect/proc_holder/alien/evolve(null))

	..()
//Drones use the same base as generic humanoids.

/mob/living/carbon/alien/humanoid/drone/movement_delay()
	. = ..()
	. += 1

/obj/effect/proc_holder/alien/evolve
	name = "Evolve"
	desc = "Produce an interal egg sac capable of spawning children. Only one queen can exist at a time."
	plasma_cost = 500

	action_icon_state = "alien_evolve_drone"

/obj/effect/proc_holder/alien/evolve/fire(mob/living/carbon/alien/user)
	var/no_queen = 1
	for(var/mob/living/carbon/alien/humanoid/queen/Q in living_mob_list)
		if(!Q.key || !Q.getorgan(/obj/item/organ/brain))
			continue
		no_queen = 0
	if(no_queen)
		user << "<span class='noticealien'>You begin to evolve!</span>"
		user.visible_message("<span class='alertalien'>[user] begins to twist and contort!</span>")
		var/mob/living/carbon/alien/humanoid/queen/new_xeno = new (user.loc)
		user.mind.transfer_to(new_xeno)
		qdel(user)
		return 1
	else
		user << "<span class='notice'>We already have an alive queen.</span>"
		return 0