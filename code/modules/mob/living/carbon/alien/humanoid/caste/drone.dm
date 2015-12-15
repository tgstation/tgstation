/mob/living/carbon/alien/humanoid/drone
	name = "alien drone"
	caste = "d"
	maxHealth = 100
	health = 100
	icon_state = "aliend_s"


/mob/living/carbon/alien/humanoid/drone/New()
	internal_organs += new /obj/item/organ/internal/alien/plasmavessel/large
	internal_organs += new /obj/item/organ/internal/alien/resinspinner
	internal_organs += new /obj/item/organ/internal/alien/acid

	AddAbility(new/obj/effect/proc_holder/alien/evolve(null))
	..()

/mob/living/carbon/alien/humanoid/drone/movement_delay()
	. = ..()
	. += 1

/obj/effect/proc_holder/alien/evolve
	name = "Evolve to Praetorian"
	desc = "Praetorian"
	plasma_cost = 500

	action_icon_state = "alien_evolve_drone"

/obj/effect/proc_holder/alien/evolve/fire(mob/living/carbon/alien/user)
	if(!alien_type_present(/mob/living/carbon/alien/humanoid/royal/))
		user << "<span class='noticealien'>You begin to evolve!</span>"
		user.visible_message("<span class='alertalien'>[user] begins to twist and contort!</span>")
		var/mob/living/carbon/alien/humanoid/royal/praetorian/new_xeno = new (user.loc)
		user.mind.transfer_to(new_xeno)
		qdel(user)
		return 1
	else
		user << "<span class='notice'>We already have a living royal!</span>"
		return 0