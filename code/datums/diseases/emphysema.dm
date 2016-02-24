/datum/disease/emphysema	//Smoker's lung
	form = "Condition"
	name = "Emphysema"
	max_stages = 3
	cure_text = "Surgery"
	agent = "Lung transplant"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 1
	desc = "If left untreated the subject will cough often."
	severity = MEDIUM
	longevity = 1000
	disease_flags = CAN_CARRY|CAN_RESIST
	spread_flags = NON_CONTAGIOUS
	visibility_flags = HIDDEN_PANDEMIC
	required_organs = list(/obj/item/organ/internal/lungs)


/datum/disease/emphysema/stage_act()
	..()

	switch(stage)
		if(1)
			if(prob(2))
				affected_mob << "<span class='warning'>You feel short of breath.</span>"
			if(prob(5))
				affected_mob.emote("cough")
		if(2)
			if(prob(10))
				affected_mob.emote("cough")
			var/obj/item/organ/internal/lungs/L = null
			var/datum/organ/internal/lungs/lungs = affected_mob.get_organ("lungs")
			if(lungs && lungs.exists())
				L = lungs.organitem
			if(L)
				L.dysfunctional = 1
				L.update_icon()
		if(3)
			if(prob(10))
				affected_mob.drop_item()
				affected_mob.emote("cough")

