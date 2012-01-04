/datum/event/spacecarp

	Announce()

		for(var/obj/effect/landmark/C in world)
			if(C.name == "carpspawn")
				if(prob(99))
					new /obj/effect/critter/spesscarp(C.loc)
				else
					new /obj/effect/critter/spesscarp/elite(C.loc)
		//sleep(100)
		spawn(rand(3000, 6000)) //Delayed announcements to keep the crew on their toes.
			command_alert("Unknown biological entities have been detected near [station_name()], please stand-by.", "Lifesign Alert")
			world << sound('commandreport.ogg')