/mob/living/carbon/alien/humanoid/drone
	name = "alien drone"
	caste = "d"
	maxHealth = 100
	health = 100
	icon_state = "aliend_s"


/mob/living/carbon/alien/humanoid/drone/New(loc, var/datum/organsystem/alienlarva/oldorgans)
	organsystem = new/datum/organsystem/humanoid/alien/drone(src, oldorgans)

	AddAbility(new/obj/effect/proc_holder/alien/evolve(null))
	..()

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
		var/datum/organ/internal/brain/B = Q.get_organ("brain")
		if(!Q.key || !(B && B.exists()))
			continue
		no_queen = 0
	if(no_queen)
		user << "<span class='noticealien'>You begin to evolve!</span>"
		user.visible_message("<span class='alertalien'>[user] begins to twist and contort!</span>")
		var/mob/living/carbon/alien/humanoid/queen/new_xeno = new (user.loc, user.organsystem)
		user.mind.transfer_to(new_xeno)
		qdel(user)
		return 1
	else
		user << "<span class='notice'>We already have an alive queen.</span>"
		return 0