/mob/living/carbon/alien/humanoid/royal/praetorian
	name = "alien praetorian"
	caste = "p"
	maxHealth = 250
	health = 250
	icon_state = "alienp"



/mob/living/carbon/alien/humanoid/royal/praetorian/New()

	real_name = name

	internal_organs += new /obj/item/organ/alien/plasmavessel/large
	internal_organs += new /obj/item/organ/alien/resinspinner
	internal_organs += new /obj/item/organ/alien/acid
	internal_organs += new /obj/item/organ/alien/neurotoxin
	AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/repulse/xeno(src))
	AddAbility(new /obj/effect/proc_holder/alien/royal/praetorian/evolve())
	..()

/mob/living/carbon/alien/humanoid/royal/praetorian/movement_delay()
	. = ..()
	. += 1

/obj/effect/proc_holder/alien/royal/praetorian/evolve
	name = "Evolve"
	desc = "Produce an interal egg sac capable of spawning children. Only one queen can exist at a time."
	plasma_cost = 500

	action_icon_state = "alien_evolve_praetorian"

/obj/effect/proc_holder/alien/royal/praetorian/evolve/fire(mob/living/carbon/alien/humanoid/user)
	var/obj/item/organ/alien/hivenode/node = user.getorgan(/obj/item/organ/alien/hivenode)
	if(!node) //Just in case this particular Praetorian gets violated and kept by the RD as a replacement for Lamarr.
		user << "<span class='danger'>Without the hivemind, you would be unfit to rule as queen!</span>"
		return 0
	if(node.recent_queen_death)
		user << "<span class='danger'>You are still too burdened with guilt to evolve into a queen.</span>"
		return 0
	if(!alien_type_present(/mob/living/carbon/alien/humanoid/royal/queen))
		var/mob/living/carbon/alien/humanoid/royal/queen/new_xeno = new (user.loc)
		if(user.client.prefs.unlock_content) //check the player is a donator
			switch(alert("Would you like to use your alternative skin?",,"Yes","No"))
				if("Yes")
					new_xeno.maidify()
				if("No")
					user << "You decide against the xeno fetish outfit"
		user.alien_evolve(new_xeno)
		return 1
	else
		user << "<span class='notice'>We already have an alive queen.</span>"
		return 0

/mob/living/carbon/alien/humanoid/royal/queen/proc/maidify()
    name = "alien queen maid"
    icon_state = "alienqmaid"
    caste = "qmaid"
