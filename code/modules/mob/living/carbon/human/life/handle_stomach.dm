//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_stomach()
	spawn(0)
		for(var/mob/living/M in stomach_contents)
			if(M.loc != src)
				stomach_contents.Remove(M)
				continue
			if(istype(M, /mob/living/carbon) && stat != DEAD)
				if(M.stat == DEAD) //We just checked if the mob ISN'T dead, but what the fuck ever oldcoders
					M.death(1)
					stomach_contents.Remove(M)
					del(M)
					continue
				if(air_master.current_cycle % 3 == 1)
					if(!(M.status_flags & GODMODE))
						M.adjustBruteLoss(5)
					nutrition += 10
