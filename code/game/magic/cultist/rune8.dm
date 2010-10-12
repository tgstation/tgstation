/obj/rune/proc/raise()
	for(var/mob/living/carbon/human/M in src.loc)
		if(M.health<=-100)
			for(var/obj/rune/R in world)
				if(R.word1==wordblood && R.word2==wordjoin && R.word3==wordhell)
					for(var/mob/living/carbon/human/N in R.loc)
						if(N.health>-100 && N.client)
							for(var/mob/dead/observer/O in src.loc)
								if(M.key)
									usr << "\red The body still has some earthly ties. It must sever them, if only for them to grow again later."
									return
								if(!O.key)
									continue
								M.key=O.key
								del(O)

								if(istype(M, /mob/living/carbon/human))
									var/mob/living/carbon/human/H = M
									for(var/A in H.organs)
										var/datum/organ/external/affecting = null
										if(!H.organs[A])    continue
										affecting = H.organs[A]
										if(!istype(affecting, /datum/organ/external))    continue
										affecting.heal_damage(1000, 1000)    //fixes getting hit after ingestion, killing you when game updates organ health
									H.UpdateDamageIcon()
								M.fireloss = 0
								M.toxloss = 0
								M.bruteloss = 0
								M.oxyloss = 0
								M.paralysis = 0
								M.stunned = 0
								M.weakened = 0
								M.radiation = 0
								M.health = 100
								M.updatehealth()
								M.buckled = initial(M.buckled)
								M.handcuffed = initial(M.handcuffed)
								if (M.stat > 1)
									M.stat=0
								..() //shamelessly stolen from rejuvenate code - Urist

								usr.say("Pasnar val'keriam usinar. Savrae ines amutan. Yam'toth remium il'tarat!")
								for (var/mob/V in viewers(M))
									V.show_message("\red [M]'s eyes glow with a faint red as \he stands up, slowly starting to breathe again.", 3, "\red You hear a faint, slightly familiar whisper.", 2)
								N.gib(1)
								for (var/mob/V in viewers(N))
									V.show_message("\red [N] is torn apart, a black smoke swiftly dissipating from \his remains!", 3, "\red You hear a thousand voices, all crying in pain.", 2)
								return
	return fizzle()
