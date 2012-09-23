/datum/event/alieninfestation

	Announce()

		var/list/vents = list()
		for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in world)
			if(temp_vent.loc.z == 1 && !temp_vent.welded)
				vents.Add(temp_vent)
		var/spawncount = 1
		if(prob(10)) spawncount++ //rarely, have two larvae spawn instead of one
		while(spawncount >= 1)
			var/obj/vent = pick(vents)

			var/list/candidates = list() // Picks a random ghost in the world to shove in the larva -- TLE; If there's no ghost... well, sucks. Wasted event. -- Urist

			for(var/mob/dead/observer/G in world)
				if(G.client)
					if(G.client.be_alien)
						if(((G.client.inactivity/10)/60) <= 5)
							if(G.corpse)
								if(G.corpse.stat==2)
									candidates.Add(G)
							if(!G.corpse)
								candidates.Add(G)

			if(candidates.len)
				var/mob/dead/observer/G = pick(candidates)
				var/mob/living/carbon/alien/larva/new_xeno = new(vent.loc)
				new_xeno.mind_initialize(G,"Larva")
				new_xeno.key = G.key
				del(G)

			vents.Remove(vent)
			spawncount -= 1

		spawn(rand(3000, 6000)) //Delayed announcements to keep the crew on their toes.
			command_alert("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert")
			world << sound('aliens.ogg')