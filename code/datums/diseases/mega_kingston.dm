/datum/disease/kingston
	name = "Yildun Infectious Fusobacter Syndrome" // lolbackronym
	max_stages = 4
	cure = "The Manly Dorf"
	cure_id = "manlydorf"
	cure_chance = 100
	agent = "Baccilli Yiffus"
	affected_species = list("Human")
	curable = 1
	permeability_mod = 0.75
	desc = "No god please no."
	severity = "Major"

	spread = "Bites"


/*
Stage 1 - Random coughing
Stage 2 - Vomiting
Stage 3 - u r now catbeest
*/

/datum/disease/kingston/stage_act()
	..()

	switch(stage)
		if(2)
			if(prob(1))
				affected_mob.emote("sneeze")


		if(3)
			if(ishuman(affected_mob)&&prob(1))
				var/mob/living/carbon/human/H=affected_mob
				H.vomit()

		if(4)

			if(prob(1))
				affected_mob.say(pick(";I FEEL FRISKY","*me scritches behind his ears.", "*me licks [affected_mob.gender==MALE?"his":"her"] arm.",";YIFF",";MEOW"))
				return

			if(prob(1) && prob(50))
				var/mob/living/carbon/human/H=affected_mob
				H << "<span class=\"warning\">You feel a wave of extreme pain and uncleanliness as your body morphs.</span>"
				H.set_species("Tajaran")
				for(var/obj/item/W in H)
					H.drop_from_inventory(W)
				// TODO:
				// ghostize()
				// StartAI(hostile=1,ranged=0)