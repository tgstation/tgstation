<<<<<<< HEAD
/mob/living/carbon/alien/humanoid/drone
	name = "alien drone"
	caste = "d"
	maxHealth = 125
	health = 125
	icon_state = "aliend_s"


/mob/living/carbon/alien/humanoid/drone/New()
	internal_organs += new /obj/item/organ/alien/plasmavessel/large
	internal_organs += new /obj/item/organ/alien/resinspinner
	internal_organs += new /obj/item/organ/alien/acid

	AddAbility(new/obj/effect/proc_holder/alien/evolve(null))
	..()

/mob/living/carbon/alien/humanoid/drone/movement_delay()
	. = ..()

/obj/effect/proc_holder/alien/evolve
	name = "Evolve to Praetorian"
	desc = "Praetorian"
	plasma_cost = 500

	action_icon_state = "alien_evolve_drone"

/obj/effect/proc_holder/alien/evolve/fire(mob/living/carbon/alien/humanoid/user)
	var/obj/item/organ/alien/hivenode/node = user.getorgan(/obj/item/organ/alien/hivenode)
	if(!node) //Players are Murphy's Law. We may not expect there to ever be a living xeno with no hivenode, but they _WILL_ make it happen.
		user << "<span class='danger'>Without the hivemind, you can't possibly hold the responsibility of leadership!</span>"
		return 0
	if(node.recent_queen_death)
		user << "<span class='danger'>Your thoughts are still too scattered to take up the position of leadership.</span>"
		return 0

	if(!isturf(user.loc))
		user << "<span class='notice'>You can't evolve here!</span>"
		return 0
	if(!get_alien_type(/mob/living/carbon/alien/humanoid/royal))
		var/mob/living/carbon/alien/humanoid/royal/praetorian/new_xeno = new (user.loc)
		user.alien_evolve(new_xeno)
		return 1
	else
		user << "<span class='notice'>We already have a living royal!</span>"
		return 0
=======
/mob/living/carbon/alien/humanoid/drone
	name = "alien drone" //The alien drone, not Alien Drone
	caste = "d"
	maxHealth = 100
	health = 100
	icon_state = "aliend_s"
	plasma_rate = 15

/mob/living/carbon/alien/humanoid/drone/movement_delay()
	var/tally = 2 + move_delay_add + config.alien_delay //Drones are slow

	var/turf/T = loc
	if(istype(T))
		tally = T.adjust_slowdown(src, tally)

	return tally

/mob/living/carbon/alien/humanoid/drone/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(src.name == "alien drone")
		src.name = text("alien drone ([rand(1, 1000)])")
	src.real_name = src.name
	verbs.Add(/mob/living/carbon/alien/humanoid/proc/resin,/mob/living/carbon/alien/humanoid/proc/corrosive_acid)
	..()
	add_language(LANGUAGE_XENO)
	default_language = all_languages[LANGUAGE_XENO]

//Drones use the same base as generic humanoids.
//Drone verbs

/mob/living/carbon/alien/humanoid/drone/verb/evolve() // -- TLE
	set name = "Evolve (500)"
	set desc = "Produce an interal egg sac capable of spawning children. Only one queen can exist at a time."
	set category = "Alien"

	if(powerc(500))
		// Queen check
		var/no_queen = 1
		for(var/mob/living/carbon/alien/humanoid/queen/Q in living_mob_list)
			if(!Q.key && Q.has_brain())
				continue
			no_queen = 0

		if(no_queen)
			adjustToxLoss(-500)
			visible_message("<span class='alien'>[src] begins to violently twist and contort!</span>", "<span class='alien'>You begin to evolve, stand still for a few moments</span>")
			if(do_after(src, src, 50))
				var/mob/living/carbon/alien/humanoid/queen/new_xeno = new(loc)
				mind.transfer_to(new_xeno)
				transferImplantsTo(new_xeno)
				transferBorers(new_xeno)
				qdel(src)
		else
			to_chat(src, "<span class='notice'>We already have an alive queen.</span>")
	return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
