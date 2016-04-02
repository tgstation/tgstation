/****************************************************
				INTERNAL ORGANS
****************************************************/

/mob/living/carbon/human/var/list/internal_organs = list()

/datum/organ/internal
	var/damage = 0 // amount of damage to the organ
	var/min_bruised_damage = 10
	var/min_broken_damage = 30
	var/parent_organ = "chest"
	var/robotic = 0 //For being a robot
	var/removed_type //When removed, forms this object.
	var/list/transplant_data // Blood DNA and colour of donor
	var/rejecting            // Is this organ already being rejected?
	var/obj/item/organ/organ_holder
	var/datum/dna/owner_dna


/datum/organ/internal/Copy()
	var/datum/organ/internal/I = ..()
	I.damage = damage
	I.min_bruised_damage = min_bruised_damage
	I.min_broken_damage = min_broken_damage
	I.parent_organ = parent_organ
	I.robotic = robotic
	I.removed_type = removed_type
	I.transplant_data = transplant_data
	I.rejecting = rejecting
	I.organ_holder = null
	I.owner_dna = owner_dna
	return I

/datum/organ/internal/proc/rejuvenate()
	damage = 0
	germ_level = 0
	cancer_stage = 0

/datum/organ/internal/proc/is_bruised()
	return damage >= min_bruised_damage

/datum/organ/internal/proc/is_broken()
	return damage >= min_broken_damage

/datum/organ/internal/New(mob/living/carbon/human/H)
	..()
	if(H)
		var/datum/organ/external/E = H.organs_by_name[src.parent_organ]
		if(E.internal_organs == null)
			E.internal_organs = list()
		E.internal_organs |= src
		H.internal_organs |= src
		src.owner = H

/datum/organ/internal/proc/Life()
	// Now organs support Life() processes.
	return

/datum/organ/internal/process()

	//Process infections
	if (robotic >= 2 || (owner.species && owner.species.flags & IS_PLANT))	//TODO make robotic internal and external organs separate types of organ instead of a flag
		germ_level = 0
		return

	if(owner.bodytemperature >= 170)	//cryo stops germs and cancer from moving and doing their bad stuffs
		//** Handle antibiotics and curing infections
		handle_antibiotics()

		//** Handle the effects of infections
		var/antibiotics = owner.reagents.get_reagent_amount("spaceacillin")

		if (germ_level > 0 && germ_level < INFECTION_LEVEL_ONE/2 && prob(30))
			germ_level--

		if (germ_level >= INFECTION_LEVEL_ONE/2)
			//aiming for germ level to go from ambient to INFECTION_LEVEL_TWO in an average of 15 minutes
			if(antibiotics < 5 && prob(round(germ_level/6)))
				germ_level++

		if (germ_level >= INFECTION_LEVEL_TWO)
			var/datum/organ/external/parent = owner.get_organ(parent_organ)
			//spread germs
			if (antibiotics < 5 && parent.germ_level < germ_level && ( parent.germ_level < INFECTION_LEVEL_ONE*2 || prob(30) ))
				parent.germ_level++

			if (prob(3))	//about once every 30 seconds
				take_damage(1,silent=prob(30))

		// Process unsuitable transplants. TODO: consider some kind of
		// immunosuppressant that changes transplant data to make it match.
		if(transplant_data)
			if(!rejecting) //Should this transplant reject?
				if(owner.species.name != transplant_data["species"]) //Nope.
					rejecting = 1
				else if(prob(20) && owner.dna && blood_incompatible(transplant_data["blood_type"],owner.dna.b_type))
					rejecting = 1
			else
				rejecting++ //Rejection severity increases over time.
				if(rejecting % 10 == 0) //Only fire every ten rejection ticks.
					switch(rejecting)
						if(1 to 50)
							take_damage(rand(1,2))
						if(51 to 200)
							take_damage(rand(2,3))
						if(201 to 500)
							take_damage(rand(3,4))
							owner.reagents.add_reagent("toxin", 1)
						if(501 to INFINITY)
							take_damage(5)
							owner.reagents.add_reagent("toxin", rand(3,5))

		if(cancer_stage)
			handle_cancer()

/datum/organ/internal/handle_cancer()

	if(robotic == 2) //This is a fully robotic limb, no cells for cancer to grow from
		return 0

	var/datum/organ/external/parent = owner.get_organ(parent_organ)

	switch(cancer_stage)
		if(CANCER_STAGE_SMALL_TUMOR to CANCER_STAGE_LARGE_TUMOR) //Small tumors will not damage your organ, but might flash pain
			if(prob(1))
				owner.custom_pain("Something inside your [parent.display_name] hurts a lot.", 1)
		if(CANCER_STAGE_LARGE_TUMOR to CANCER_STAGE_METASTASIS) //Large tumors will start damaging your organ and give the owner DNA damage (bodywide, can't go per limb)
			if(prob(20))
				take_damage(0.25)
			if(prob(1))
				owner.apply_damage(0.5, CLONE, parent)
		if(CANCER_STAGE_METASTASIS to INFINITY) //Metastasis achieved, limb will start breaking down very rapidly, and cancer will spread to all other limbs in short order through bloodstream
			if(prob(33))
				take_damage(0.25)
			if(prob(10))
				owner.apply_damage(0.5, CLONE, parent)
			if(prob(1))
				owner.add_cancer() //Add a new cancerous growth

/datum/organ/internal/proc/take_damage(amount, var/silent=0)
	if(!owner) return
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

//All the internal organs without specific code to them are below
//Hopefully this will be filled in soon ?

/datum/organ/internal/heart //This is not set to vital because death immediately occurs in blood.dm if it is removed.
	name = "heart"
	parent_organ = "chest"
	removed_type = /obj/item/organ/heart

/datum/organ/internal/kidney
	name = "kidneys"
	parent_organ = "groin"
	removed_type = /obj/item/organ/kidneys

/datum/organ/internal/brain
	name = "brain"
	parent_organ = "head"
	removed_type = /obj/item/organ/brain
	vital = 1


/datum/organ/internal/appendix
	name = "appendix"
	parent_organ = "groin"
	removed_type = /obj/item/organ/appendix

/datum/organ/internal/proc/remove(var/mob/user, var/quiet=0)


	if(!removed_type) return 0

	var/obj/item/organ/removed_organ = new removed_type(get_turf(user))

	if(istype(removed_organ))
		removed_organ.organ_data = src
		removed_organ.update()
		organ_holder = removed_organ

	return removed_organ
