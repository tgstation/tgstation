/**
 * # Alien Praetorian
 *
 * A larget, tankier alien who wields an impressive amount of health at the cost of speed and ventcrawling.
 *
 * A subtype of alien which acts as a tanky bruiser.  Like the queen, it can use tail whip to stun enemies,
 * and has access to neurotoxin and acid, along with being able to create structures via resin spinner.
 * It is also the only caste which can evolve into alien, albeit only if one currently does not exist and
 * the limit for queens in a round hasn't already been met.
 */
/mob/living/carbon/alien/humanoid/royal/praetorian
	name = "alien praetorian"
	caste = "p"
	maxHealth = 250
	health = 250
	icon_state = "alienp"
	speed = 1

/mob/living/carbon/alien/humanoid/royal/praetorian/Initialize()
	real_name = name
	AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/repulse/xeno(src))
	AddAbility(new /obj/effect/proc_holder/alien/royal/praetorian/evolve())
	. = ..()

/mob/living/carbon/alien/humanoid/royal/praetorian/create_internal_organs()
	internal_organs += new /obj/item/organ/alien/plasmavessel/large
	internal_organs += new /obj/item/organ/alien/resinspinner
	internal_organs += new /obj/item/organ/alien/acid
	internal_organs += new /obj/item/organ/alien/neurotoxin
	..()

/obj/effect/proc_holder/alien/royal/praetorian/evolve
	name = "Evolve"
	desc = "Produce an internal egg sac capable of spawning children. Only one queen can exist at a time."
	plasma_cost = 500

	action_icon_state = "alien_evolve_praetorian"

#define MAX_QUEEN_DEATHS 2

/obj/effect/proc_holder/alien/royal/praetorian/evolve/fire(mob/living/carbon/alien/humanoid/user)
	var/obj/item/organ/alien/hivenode/node = user.getorgan(/obj/item/organ/alien/hivenode)
	if(!node) //Just in case this particular Praetorian gets violated and kept by the RD as a replacement for Lamarr.
		to_chat(user, "<span class='warning'>Without the hivemind, you would be unfit to rule as queen!</span>")
		return FALSE
	var/datum/antagonist/xeno/xeno_datum = user.mind.has_antag_datum(/datum/antagonist/xeno)
	if(xeno_datum?.xeno_team?.queen_deaths >= MAX_QUEEN_DEATHS)
		to_chat(user, "<span class='warning'>Too many queens have died today already!  The hivemind can't take any more pain!</span>")
		return FALSE	
	if(node.recent_queen_death)
		to_chat(user, "<span class='warning'>You are still too burdened with guilt to evolve into a queen.</span>")
		return FALSE
	if(!get_alien_type(/mob/living/carbon/alien/humanoid/royal/queen))
		var/mob/living/carbon/alien/humanoid/royal/queen/new_xeno = new (user.loc)
		user.alien_evolve(new_xeno)
		return TRUE
	else
		to_chat(user, "<span class='warning'>We already have an alive queen!</span>")
		return FALSE

#undef MAX_QUEEN_DEATHS
