/datum/disease/dnaspread
	name = "Space Retrovirus"
	max_stages = 4
	spread = "On contact"
	spread_type = CONTACT_GENERAL
	cure = "Ryetalyn"
	cure_id = "ryetalyn"
	curable = 1
	agent = "S4E1 retrovirus"
	affected_species = list("Human")
	var/list/original_dna = list()
	var/transformed = 0
	desc = "This disease transplants the genetic code of the intial vector into new hosts."
	severity = "Medium"


/datum/disease/dnaspread/stage_act()
	..()
	switch(stage)
		if(2 || 3) //Pretend to be a cold and give time to spread.
			if(prob(8))
				affected_mob.emote("sneeze")
			if(prob(8))
				affected_mob.emote("cough")
			if(prob(1))
				affected_mob << "\red Your muscles ache."
				if(prob(20))
					affected_mob.take_organ_damage(1)
			if(prob(1))
				affected_mob << "\red Your stomach hurts."
				if(prob(20))
					affected_mob.adjustToxLoss(2)
					affected_mob.updatehealth()
		if(4)
			if(!src.transformed)
				if ((!strain_data["name"]) || (!strain_data["UI"]) || (!strain_data["SE"]))
					del(affected_mob.virus)
					return

				//Save original dna for when the disease is cured.
				src.original_dna["name"] = affected_mob.real_name
				src.original_dna["UI"] = affected_mob.dna.uni_identity
				src.original_dna["SE"] = affected_mob.dna.struc_enzymes

				affected_mob << "\red You don't feel like yourself.."
				affected_mob.dna.uni_identity = strain_data["UI"]
				updateappearance(affected_mob, affected_mob.dna.uni_identity)
				affected_mob.dna.struc_enzymes = strain_data["SE"]
				affected_mob.real_name = strain_data["name"]
				domutcheck(affected_mob)

				src.transformed = 1
				src.carrier = 1 //Just chill out at stage 4

	return

/datum/disease/dnaspread/Del()
	if ((original_dna["name"]) && (original_dna["UI"]) && (original_dna["SE"]))
		affected_mob.dna.uni_identity = original_dna["UI"]
		updateappearance(affected_mob, affected_mob.dna.uni_identity)
		affected_mob.dna.struc_enzymes = original_dna["SE"]
		affected_mob.real_name = original_dna["name"]

		affected_mob << "\blue You feel more like yourself."
	..()