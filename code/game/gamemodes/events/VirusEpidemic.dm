//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:04

/datum/event/viralinfection
	var/virus_type
	var/virus
	var/virus2 = 0

	Announce()
		if(!virus)
			for(var/mob/living/carbon/human/H in world)
				if((H.virus2.len) || (H.stat == 2) || prob(30))
					continue
				if(prob(100))	// no lethal diseases outside virus mode!
					infect_mob_random_lesser(H)
					if(prob(20))//don't want people to know that the virus alert = greater virus
						command_alert("Probable outbreak of level [rand(1,6)] viral biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Virus Alert")
				else
					infect_mob_random_greater(H)
					if(prob(80))
						command_alert("Probable outbreak of level [rand(2,9)] viral biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Virus Alert")
				break
			//overall virus alert happens 26% of the time, might need to be higher
		else
			if(!virus)
				virus_type = pick(/datum/disease/dnaspread,/datum/disease/flu,/datum/disease/cold,/datum/disease/brainrot,/datum/disease/magnitis,/datum/disease/pierrot_throat)
			else
				switch(virus)
					if("fake gbs")
						virus_type = /datum/disease/fake_gbs
					if("gbs")
						virus_type = /datum/disease/gbs
					if("magnitis")
						virus_type = /datum/disease/magnitis
					if("rhumba beat")
						virus_type = /datum/disease/rhumba_beat
					if("brain rot")
						virus_type = /datum/disease/brainrot
					if("cold")
						virus_type = /datum/disease/cold
					if("retrovirus")
						virus_type = /datum/disease/dnaspread
					if("flu")
						virus_type = /datum/disease/flu
//					if("t-virus")
//						virus_type = /datum/disease/t_virus
					if("pierrot's throat")
						virus_type = /datum/disease/pierrot_throat
			for(var/mob/living/carbon/human/H in world)

				var/foundAlready = 0 // don't infect someone that already has the virus
				for(var/datum/disease/D in H.viruses)
					foundAlready = 1
				if(H.stat == 2 || foundAlready)
					continue

				if(virus_type == /datum/disease/dnaspread) //Dnaspread needs strain_data set to work.
					if((!H.dna) || (H.disabilities & 128)) //A blindness disease would be the worst.
						continue
					var/datum/disease/dnaspread/D = new
					D.strain_data["name"] = H.real_name
					D.strain_data["UI"] = H.dna.uni_identity
					D.strain_data["SE"] = H.dna.struc_enzymes
					D.carrier = 1
					D.holder = H
					D.affected_mob = H
					H.viruses += D
					break
				else
					var/datum/disease/D = new virus_type
					D.carrier = 1
					D.holder = H
					D.affected_mob = H
					H.viruses += D
					break
			spawn(rand(3000, 6000)) //Delayed announcements to keep the crew on their toes.
				command_alert("Confirmed outbreak of level 7 viral biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert")
				world << sound('sound/AI/outbreak7.ogg')
	Tick()
		ActiveFor = Lifetime //killme

