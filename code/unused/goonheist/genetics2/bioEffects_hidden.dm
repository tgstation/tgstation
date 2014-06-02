// This file is for bio effects that don't show up in the genetics pool

/datum/bioEffect/trainingminer
	name = "Miner Training"
	desc = "Subject is trained in geological and metallurgical matters."
	id = "training_miner"
	effectType = effectTypePower
	isBad = 0
	isHidden = 1
	can_reclaim = 0

/datum/bioEffect/trainingchaplain
	name = "Chaplain Training"
	desc = "Subject is trained in cultural and psychological matters."
	id = "training_chaplain"
	effectType = effectTypePower
	isBad = 0
	isHidden = 1
	can_reclaim = 0

/datum/bioEffect/arcaneshame
	name = "Wizard's Shame"
	desc = "Subject is suffering from Post Traumatic Shaving Disorder."
	id = "arcane_shame"
	effectType = effectTypeDisability
	isBad = 0
	isHidden = 1
	can_reclaim = 0
	can_copy = 0
	// temporary debuff for when the wizard gets shaved
	msgGain = "You feel shameful.  Also bald."
	msgLose = "Your shame changes into righteous anger!"

/datum/bioEffect/arcanepower
	name = "Arcane Power"
	desc = "Subject is imbued with an unknown power."
	id = "arcane_power"
	effectType = effectTypePower
	isBad = 0
	isHidden = 1
	can_reclaim = 0
	// Variant 1 = Half Spell Cooldown, Variant 2 = No Spell Cooldown
	// Only use variant 2 for debugging/horrible admin gimmicks ok
	msgGain = "Your hair stands on end."
	msgLose = "The tingling in your skin fades."

/datum/bioEffect/husk
	name = "Husk"
	desc = "Subject appears to have been drained of all fluids."
	id = "husk"
	effectType = effectTypeDisability
	isBad = 1
	isHidden = 1
	can_reclaim = 0
	can_copy = 0

	OnMobDraw()
		owner:stand_icon.overlays += image('human.dmi', "husk_s")
		owner:lying_icon.overlays += image('human.dmi', "husk_l")
		return

/datum/bioEffect/eaten
	name = "Eaten"
	desc = "Subject appears to have been partially consumed."
	id = "eaten"
	effectType = effectTypeDisability
	isBad = 1
	isHidden = 1
	can_reclaim = 0
	can_copy = 0

	OnMobDraw()
		owner:stand_icon.overlays += image('human.dmi', "decomp1_s")
		owner:lying_icon.overlays += image('human.dmi', "decomp1_l")
		return

/datum/bioEffect/zombie //This wont be added if mutant race is created by something else. Change that.
	name = "Necrotic Degeneration"
	desc = "Subject's cellular structure is degenerating due to sub-lethal necrosis."
	id = "zombie"
	effectType = effectTypeMutantRace
	isBad = 1
	probability = 5
	isHidden = 1
	can_reclaim = 0
	can_copy = 0
	msgGain = "You begin to rot."
	msgLose = "You are no longer rotting."

	OnAdd()
		owner:mutantrace = new /datum/mutantrace/zombie(owner)
		return

	OnRemove()
		if (istype(owner:mutantrace, /datum/mutantrace/zombie))
			owner:mutantrace = null
		return

	OnLife()
		if(!istype(owner:mutantrace, /datum/mutantrace/zombie))
			holder.RemoveEffect(id)
		return

/datum/bioEffect/monkey
	name = "Primal Genetics"
	desc = "Subject is a lab monkey.."
	id = "monkey"
	effectType = effectTypeMutantRace
	isBad = 0
	probability = 5
	isHidden = 1
	can_reclaim = 0
	can_copy = 1
	msgGain = "You go bananas!"
	msgLose = "You do the evolution."

	OnAdd()
		owner:mutantrace = new /datum/mutantrace/monkey(owner)
		return

	OnRemove()
		if (istype(owner:mutantrace, /datum/mutantrace/monkey))
			owner:mutantrace = null
		return

	OnLife()
		if(!istype(owner:mutantrace, /datum/mutantrace/monkey))
			holder.RemoveEffect(id)
		return

/datum/bioEffect/premature_clone
	name = "Stunted Genetics"
	desc = "Genetic abnormalities possibly resulting from incomplete development in a cloning pod."
	id = "premature_clone"
	effectType = effectTypeMutantRace
	isBad = 1
	isHidden = 1
	can_reclaim = 0
	can_copy = 0
	msgGain = "You don't feel quite right."
	msgLose = "You feel normal again."
	var/outOfPod = 0 //Out of the cloning pod.

	OnAdd()
		owner:mutantrace = new /datum/mutantrace/premature_clone(owner)
		if (!istype(owner.loc, /obj/machinery/clonepod))
			owner << "\red Your genes feel...disorderly."
		return

	OnRemove()
		if (istype(owner:mutantrace, /datum/mutantrace/premature_clone))
			owner:mutantrace = null
		return

	OnLife()
		if(!istype(owner:mutantrace, /datum/mutantrace/premature_clone))
			holder.RemoveEffect(id)

		if (outOfPod)
			if (prob(6))
				owner.visible_message("\red [owner.name] suddenly and violently vomits!")
				playsound(owner.loc, 'splat.ogg', 50, 1)
				new /obj/decal/cleanable/vomit(owner.loc)

			else if (prob(2))
				owner.visible_message("\red [owner.name] vomits blood!")
				playsound(owner.loc, 'splat.ogg', 50, 1)
				new /obj/decal/cleanable/blood(owner.loc)
				random_brute_damage(owner, rand(5,8))



		else if (!istype(owner.loc, /obj/machinery/clonepod))
			outOfPod = 1

		return