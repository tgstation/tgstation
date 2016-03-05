// A very special plant, deserving it's own file.

/obj/item/seeds/replicapod
	name = "pack of replica pod seeds"
	desc = "These seeds grow into replica pods. They say these are used to harvest humans."
	icon_state = "seed-replicapod"
	species = "replicapod"
	plantname = "Replica Pod"
	product = /mob/living/carbon/human //verrry special -- Urist
	lifespan = 50
	endurance = 8
	maturation = 10
	production = 1
	yield = 1 //seeds if there isn't a dna inside
	oneharvest = 1
	potency = 30
	var/ckey = null
	var/realName = null
	var/datum/mind/mind = null
	var/blood_gender = null
	var/blood_type = null
	var/list/features = null
	var/factions = null
	var/contains_sample = 0

/obj/item/seeds/replicapod/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W,/obj/item/weapon/reagent_containers/syringe))
		if(!contains_sample)
			for(var/datum/reagent/blood/bloodSample in W.reagents.reagent_list)
				if(bloodSample.data["mind"] && bloodSample.data["cloneable"] == 1)
					mind = bloodSample.data["mind"]
					ckey = bloodSample.data["ckey"]
					realName = bloodSample.data["real_name"]
					blood_gender = bloodSample.data["gender"]
					blood_type = bloodSample.data["blood_type"]
					features = bloodSample.data["features"]
					factions = bloodSample.data["factions"]
					W.reagents.clear_reagents()
					user << "<span class='notice'>You inject the contents of the syringe into the seeds.</span>"
					contains_sample = 1
				else
					user << "<span class='warning'>The seeds reject the sample!</span>"
		else
			user << "<span class='warning'>The seeds already contain a genetic sample!</span>"
	..()