/****************************************************
				INTERNAL ORGANS
****************************************************/

/mob/living/carbon/human/var/list/internal_organs = list()

/datum/organ/internal
	// amount of damage to the organ
	var/damage = 0
	var/min_bruised_damage = 10
	var/min_broken_damage = 30
	var/parent_organ = "chest"
	var/robotic = 0 //For being a robot

/datum/organ/internal/proc/rejuvenate()
	damage=0

/datum/organ/internal/proc/is_bruised()
	return damage >= min_bruised_damage

/datum/organ/internal/proc/is_broken()
	return damage >= min_broken_damage


/datum/organ/internal/New(mob/living/carbon/human/H)
	..()
	var/datum/organ/external/E = H.organs_by_name[src.parent_organ]
	if(E.internal_organs == null)
		E.internal_organs = list()
	E.internal_organs += src
	H.internal_organs[src.name] = src
	src.owner = H

/datum/organ/internal/proc/take_damage(amount, var/silent=0)
	if(src.robotic == 2)
		src.damage += (amount * 0.8)
	else
		src.damage += amount

	var/datum/organ/external/parent = owner.get_organ(parent_organ)
	if (!silent)
		owner.custom_pain("Something inside your [parent.display_name] hurts a lot.", 1)


/datum/organ/internal/proc/emp_act(severity)
	switch(robotic)
		if(0)
			return
		if(1)
			switch (severity)
				if (1.0)
					take_damage(20,0)
					return
				if (2.0)
					take_damage(7,0)
					return
				if(3.0)
					take_damage(3,0)
					return
		if(2)
			switch (severity)
				if (1.0)
					take_damage(40,0)
					return
				if (2.0)
					take_damage(15,0)
					return
				if(3.0)
					take_damage(10,0)
					return

/datum/organ/internal/proc/mechanize() //Being used to make robutt hearts, etc
	robotic = 2

/datum/organ/internal/proc/mechassist() //Used to add things like pacemakers, etc
	robotic = 1
	min_bruised_damage = 15
	min_broken_damage = 35

/****************************************************
				INTERNAL ORGANS DEFINES
****************************************************/

/datum/organ/internal/heart
	name = "heart"
	parent_organ = "chest"


/datum/organ/internal/lungs
	name = "lungs"
	parent_organ = "chest"

	process()
		if(is_bruised())
			if(prob(2))
				spawn owner.emote("me", 1, "coughs up blood!")
				owner.drip(10)
			if(prob(4))
				spawn owner.emote("me", 1, "gasps for air!")
				owner.losebreath += 5

/datum/organ/internal/liver
	name = "liver"
	parent_organ = "chest"
	var/process_accuracy = 10

	process()
		if(owner.life_tick % process_accuracy == 0)
			if(src.damage < 0)
				src.damage = 0

			//High toxins levels are dangerous
			if(owner.getToxLoss() >= 60 && !owner.reagents.has_reagent("anti_toxin"))
				//Healthy liver suffers on its own
				if (src.damage < min_broken_damage)
					src.damage += 0.2 * process_accuracy
				//Damaged one shares the fun
				else
					var/victim = pick(owner.internal_organs)
					var/datum/organ/internal/O = owner.internal_organs[victim]
					O.damage += 0.2  * process_accuracy

			//Detox can heal small amounts of damage
			if (src.damage && src.damage < src.min_bruised_damage && owner.reagents.has_reagent("anti_toxin"))
				src.damage -= 0.2 * process_accuracy

			// Damaged liver means some chemicals are very dangerous
			if(src.damage >= src.min_bruised_damage)
				for(var/datum/reagent/R in owner.reagents.reagent_list)
					// Ethanol and all drinks are bad
					if(istype(R, /datum/reagent/ethanol))
						owner.adjustToxLoss(0.1 * process_accuracy)

				// Can't cope with toxins at all
				for(var/toxin in list("toxin", "plasma", "sacid", "pacid", "cyanide", "lexorin", "amatoxin", "chloralhydrate", "carpotoxin", "zombiepowder", "mindbreaker"))
					if(owner.reagents.has_reagent(toxin))
						owner.adjustToxLoss(0.3 * process_accuracy)

/datum/organ/internal/kidney
	name = "kidney"
	parent_organ = "chest"

/datum/organ/internal/brain
	name = "brain"
	parent_organ = "head"

/datum/organ/internal/eyes
	name = "eyes"
	parent_organ = "head"

	process() //Eye damage replaces the old eye_stat var.
		if(is_bruised())
			owner.eye_blurry = 20
		if(is_broken())
			owner.eye_blind = 20
