//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_mutations_and_radiation()
	if(flags & INVULNERABLE)
		return
	if(getFireLoss())
		if((M_RESIST_HEAT in mutations))
			heal_organ_damage(0,1)

	for(var/gene_type in active_genes)
		var/datum/dna/gene/gene = dna_genes[gene_type]
		if(!gene.block)
			continue
		gene.OnMobLife(src)

	if(radiation)

		//Whoever wrote those next two blocks of code obviously never heard of mathematical helpers
		if(radiation > 100)
			radiation = 100
			Weaken(10)
			to_chat(src, "<span class='warning'>You feel weak.</span>")
			emote("collapse")

		if(radiation < 0)
			radiation = 0

		else
			if(species.flags & RAD_ABSORB)
				var/rads = radiation/25
				radiation -= rads
				nutrition += rads
				adjustBruteLoss(-(rads))
				adjustOxyLoss(-(rads))
				adjustToxLoss(-(rads))
				updatehealth()
				return

			var/damage = 0
			switch(radiation)
				if(1 to 49)
					radiation--
					if(!(radiation % 5)) //Damage every 5 ticks. Previously prob(25)
						adjustToxLoss(1)
						damage = 1
						updatehealth()

				if(50 to 74)
					radiation -= 2
					damage = 1
					adjustToxLoss(1)
					if(prob(5))
						radiation -= 5
						Weaken(3)
						to_chat(src, "<span class='warning'>You feel weak.</span>")
						emote("collapse")
					updatehealth()

				if(75 to 100)
					radiation -= 3
					adjustToxLoss(3)
					damage = 1
					/*
					if(prob(1))
						to_chat(src, "<span class='warning'>You mutate!</span>")
						randmutb(src)
						domutcheck(src,null)
						emote("gasp")
					*/
					updatehealth()

			if(damage && organs.len)
				var/datum/organ/external/O = pick(organs)
				if(istype(O)) O.add_autopsy_data("Radiation Poisoning", damage)
