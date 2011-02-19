var/list/sacrificed = list()

/obj/rune
/////////////////////////////////////////FIRST RUNE
	proc
		teleport(var/key)
			var/allrunesloc[]
			allrunesloc = new/list()
			var/index = 0
		//	var/tempnum = 0
			for(var/obj/rune/R in world)
				if(R == src)
					continue
				if(R.word1 == wordtravel && R.word2 == wordself && R.word3 == key)
					index++
					allrunesloc.len = index
					allrunesloc[index] = R.loc
			if(index >= 5)
				usr << "\red You feel pain, as rune disappears in reality shift caused by too much wear of space-time fabric"
				usr.bruteloss += 5
				del(src)
			if(allrunesloc && index != 0)
				if(istype(src,/obj/rune))
					usr.say("Sas'so c'arta forbici!")
				else
					usr.whisper("Sas'so c'arta forbici!")
				usr.visible_message("\red [usr] disappears in a flash of red light!", \
				"\red You feel as your body gets dragged through the dimension of Nar-Sie!", \
				"\red You hear a sickening crunch and sloshing of viscera.")
				usr.loc = allrunesloc[rand(1,index)]
				return
			if(istype(src,/obj/rune))
				return	fizzle() //Use friggin manuals, Dorf, your list was of zero length.
			else
				call(/obj/rune/proc/fizzle)()
				return


		itemport(var/key)
//			var/allrunesloc[]
//			allrunesloc = new/list()
//			var/index = 0
		//	var/tempnum = 0
			var/culcount = 0
			var/runecount = 0
			var/obj/rune/IP = null
			for(var/obj/rune/R in world)
				if(R == src)
					continue
				if(R.word1 == wordtravel && R.word2 == wordother && R.word3 == key)
					IP = R
					runecount++
			if(runecount >= 2)
				usr << "\red You feel pain, as rune disappears in reality shift caused by too much wear of space-time fabric"
				usr.bruteloss += 5
				del(src)
			for(var/mob/living/carbon/human/C in orange(1,src))
				if(cultists.Find(C))
					culcount++
			if(culcount>=3)
				usr.say("Sas'so c'arta forbici tarem!")
				usr.visible_message("\red You feel air moving from the rune - like as it was swapped with somewhere else.", \
				"\red You feel air moving from the rune - like as it was swapped with somewhere else.", \
				"\red You smell ozone.")
				for(var/obj/O in src.loc)
					if(!O.anchored)
						O.loc = IP.loc
				for(var/mob/M in src.loc)
					M.loc = IP.loc
				return

			return	fizzle()


/////////////////////////////////////////SECOND RUNE

		tomesummon()
			if(istype(src,/obj/rune))
				usr.say("N'ath reth sh'yro eth d'raggathnor!")
			else
				usr.whisper("N'ath reth sh'yro eth d'raggathnor!")
			usr.visible_message("\red Rune disappears with a flash of red light, and in it's place now a book lies.", \
			"\red You are blinded by the flash of red light! After you're able to see again, you see that now instead of the rune there's a book.", \
			"\red You hear a pop and smell ozone.")
			if(istype(src,/obj/rune))
				new /obj/item/weapon/tome(src.loc)
			else
				new /obj/item/weapon/tome(usr.loc)
			del(src)
			return



/////////////////////////////////////////THIRD RUNE

		convert()
			for(var/mob/living/carbon/human/M in src.loc)
				if(cultists.Find(M))
					return fizzle()
				if(M.stat==2)
					return fizzle()
				if(ticker.mode.name == "cult")
					var/list/uncons = call(/datum/game_mode/cult/proc/get_unconvertables)()
					if(M.mind in uncons)
						return fizzle()
					ticker.mode:add_cultist(M.mind)
				usr.say("Mah'weyh pleggh at e'ntrath!")
				M.visible_message("\red [M] writhes in pain as the markings below him glow a bloody red.", \
				"\red AAAAAAHHHH!.", \
				"\red You hear an anguished scream.")
				M << "<font color=\"purple\"><b><i>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</b></i></font>"
				M << "<font color=\"purple\"><b><i>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</b></i></font>"
				cultists.Add(M)
				return
			return fizzle()



/////////////////////////////////////////FOURTH RUNE

		tearreality()
			var/cultist_count = 0
			for(var/mob/M in range(1,src))
				if(cultists.Find(M))
					M.say("Tok-lyr rqa'nap g'lt-ulotf!")
					cultist_count += 1
			if(cultist_count >= 9)
				var/obj/machinery/singularity/S = new /obj/machinery/singularity/(src.loc)
				S.icon = 'magic_terror.dmi'
				S.name = "Tear in the Fabric of Reality"
				S.desc = "Your mind begins to bubble and ooze as it tries to comprehend what it sees."
				S.pixel_x = -89
				S.pixel_y = -85
				if(ticker.mode.name == "cult")
					ticker.mode:eldergod = 0
				return
			else
				return

/////////////////////////////////////////FIFTH RUNE

		emp(var/U,var/range_red) //range_red - var which determines by which number to reduce the default emp range, U is the source loc, needed because of talisman emps which are held in hand at the moment of using and that apparently messes things up -- Urist
			if(istype(src,/obj/rune))
				usr.say("Ta'gh fara'qha fel d'amar det!")
			else
				usr.whisper("Ta'gh fara'qha fel d'amar det!")
			playsound(U, 'Welder2.ogg', 25, 1)
			var/turf/T = get_turf(U)
			if(T)
				T.hotspot_expose(700,125)

			var/rune = src // detaching the proc - in theory
			empulse(src, (range_red - 2), range_red)
			del(rune)
			return

/////////////////////////////////////////SIXTH RUNE

		drain()
			var/drain = 0
			for(var/obj/rune/R in world)
				if(R.word1==wordtravel && R.word2==wordblood && R.word3==wordself)
					for(var/mob/living/carbon/D in R.loc)
						if(D.health>=-100)
							var/bdrain = rand(1,25)
							D << "\red You feel weakened."
							D.bruteloss += bdrain
							drain += bdrain
			if(!drain)
				return fizzle()
			usr.say ("Yu'gular faras desdae. Havas mithum javara. Umathar uf'kal thenar!")
			usr.visible_message("\red Blood flows from the rune into [usr]!", \
			"\red The blood starts flowing from the rune and into your frail mortal body. You feel... empowered.", \
			"\red You hear a liquid flowing.")
			if(usr.bhunger)
				usr.bhunger -= 2*drain
			if(drain>=50)
				usr.visible_message("\red [usr]'s eyes give off eerie red glow!", \
				"\red ...but it wasn't nearly enough. You crave, crave for more. The hunger consumes you from within.", \
				"\red You hear a heartbeat.")
				usr.bhunger += drain
				for (,usr.bhunger,usr.bhunger--)
					sleep(50)
					usr.bruteloss += 3
			usr.bruteloss -= drain
			return






/////////////////////////////////////////SEVENTH RUNE

		seer()
			if(usr.loc==src.loc)
				usr.say("Rash'tla sektath mal'zua. Zasan therium vivira. Itonis al'ra matum!")
				if(usr.see_invisible!=0 && usr.see_invisible!=15)
					usr << "\red The world beyond flashes your eyes but disappears quickly, as if something is disrupting your vision."
				else
					usr << "\red The world beyond opens to your eyes."
				usr.see_invisible = 15
				return
			return fizzle()

/////////////////////////////////////////EIGHTH RUNE

		raise()
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

//										rejuvenatedheal(M)

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


										usr.say("Pasnar val'keriam usinar. Savrae ines amutan. Yam'toth remium il'tarat!")
										M.visible_message("\red [M]'s eyes glow with a faint red as he stands up, slowly starting to breathe again.", \
										"\red Life... I'm alive again...", \
										"\red You hear a faint, slightly familiar whisper.")
										N.gib(1)
										N.visible_message("\red [N] is torn apart, a black smoke swiftly dissipating from his remains!", \
										"\red You feel as your blood boils, tearing you apart.", \
										"\red You hear a thousand voices, all crying in pain.")
										return
			return fizzle()





/////////////////////////////////////////NINETH RUNE

		obscure(var/rad)
			var/S=0
			for(var/obj/rune/R in orange(rad,src))
				if(R!=src)
					R:visibility=0
				S=1
			if(S)
				if(istype(src,/obj/rune))
					usr.say("Kla'atu barada nikt'o!")
					for (var/mob/V in viewers(src))
						V.show_message("\red The rune turns into gray dust, veiling the surrounding runes.", 3)
					del(src)
				else
					usr.whisper("Kla'atu barada nikt'o!")
					usr << "\red Your talisman turns into gray dust, veiling the surrounding runes."
					for (var/mob/V in orange(1,src))
						if(V!=usr)
							V.show_message("\red Dust emanates from [usr]'s hands for a moment.", 3)

				return
			if(istype(src,/obj/rune))
				return	fizzle()
			else
				call(/obj/rune/proc/fizzle)()
				return

/////////////////////////////////////////TENTH RUNE

		ajourney() //some bits copypastaed from admin tools - Urist
			if(usr.loc==src.loc)
				var/mob/living/carbon/human/L = usr
				usr.say("Fwe'sh mah erl nyag r'ya!")
				usr.ghostize()
				usr.visible_message("\red [usr]'s eyes glow blue as \he freezes in place, absolutely motionless.", \
				"\red The shadow that is your spirit separates itself from your body. You are now in the realm beyond. While this it's a great sight, being here strains your mind and body. Hurry.", \
				"\red You hear only complete silence for a moment.")
				for(L.ajourn=1,L.ajourn)
					sleep(10)
					if(L.key)
						L.ajourn=0
						return
					else
						L.bruteloss++
			return fizzle()




/////////////////////////////////////////ELEVENTH RUNE

		manifest()
			if(usr.loc==src.loc)
				for(var/mob/dead/observer/O in src.loc)
					usr.say("Gal'h'rfikk harfrandid mud'gib!")
					var/mob/living/carbon/human/dummy/D = new /mob/living/carbon/human/dummy(src.loc)
					usr.visible_message("\red A shape forms in the center of the rune. A shape of... a man.", \
					"\red A shape forms in the center of the rune. A shape of... a man.", \
					"\red You hear liquid flowing.")
					D.real_name = "Unknown"
					for(var/obj/item/weapon/paper/P in src.loc)
						if(length(P.info)<=24)
							D.real_name = P.info
					D.universal_speak = 1
					D.nodamage = 0
					D.key = O.key
					del(O)
					for(,usr.loc==src.loc)
						sleep(30)
						if(usr.health>-100)
							usr.bruteloss++
						else
							break
					D.visible_message("\red [D] slowly dissipates into dust and bones.", \
					"\red You feel pain, as bonds formed between your soul and this homunculus break.", \
					"\red You hear faint rustle.")
					D.dust(1)
					return
			return fizzle()





/////////////////////////////////////////TWELFTH RUNE

		talisman()//only hide, emp, teleport and tome runes can be imbued atm
			for(var/obj/rune/R in orange(1,src))
				if(R==src)
					continue
				if(R.word1==wordtravel && R.word2==wordself)
					for(var/obj/item/weapon/paper/P in src.loc)
						if(P.info)
							usr << "\red The blank is tainted. It is unsuitable."
							return
						del(P)
						var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(src.loc)
						T.imbue = "[R.word3]"
						T.info = "[R.word3]"
						for (var/mob/V in viewers(src))
							V.show_message("\red The runes turn into dust, which then forms into an arcane image on the paper.", 3)
						del(R)
						del(src)
						usr.say("H'drak v'loso, mir'kanas verbot!")
						return
				if(R.word1==wordsee && R.word2==wordblood && R.word3==wordhell)
					for(var/obj/item/weapon/paper/P in src.loc)
						if(P.info)
							usr << "\red The blank is tainted. It is unsuitable."
							return
						del(P)
						var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(src.loc)
						T.imbue = "newtome"
						for (var/mob/V in viewers(src))
							V.show_message("\red The runes turn into dust, which then forms into an arcane image on the paper.", 3)
						del(R)
						del(src)
						usr.say("H'drak v'loso, mir'kanas verbot!")
						return
				if(R.word1==worddestr && R.word2==wordsee && R.word3==wordtech)
					for(var/obj/item/weapon/paper/P in src.loc)
						if(P.info)
							usr << "\red The blank is tainted. It is unsuitable."
							return
						del(P)
						var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(src.loc)
						T.imbue = "emp"
						for (var/mob/V in viewers(src))
							V.show_message("\red The runes turn into dust, which then forms into an arcane image on the paper.", 3)
						del(R)
						del(src)
						usr.say("H'drak v'loso, mir'kanas verbot!")
						return
				if(R.word1==wordblood && R.word2==wordsee && R.word3==worddestr)
					for(var/obj/item/weapon/paper/P in src.loc)
						if(P.info)
							usr << "\red The blank is tainted. It is unsuitable."
							return
						del(P)
						var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(src.loc)
						T.imbue = "conceal"
						for (var/mob/V in viewers(src))
							V.show_message("\red The runes turn into dust, which then forms into an arcane image on the paper.", 3)
						del(R)
						del(src)
						usr.say("H'drak v'loso, mir'kanas verbot!")
						return
				if(R.word1==wordblood && R.word2==wordsee && R.word3==wordhide)
					for(var/obj/item/weapon/paper/P in src.loc)
						if(P.info)
							usr << "\red The blank is tainted. It is unsuitable."
							return
						del(P)
						var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(src.loc)
						T.imbue = "revealrunes"
						for (var/mob/V in viewers(src))
							V.show_message("\red The runes turn into dust, which then forms into an arcane image on the paper.", 3)
						del(R)
						del(src)
						usr.say("H'drak v'loso, mir'kanas verbot!")
						return
				if(R.word1==worddestr && R.word2==wordsee && R.word3==wordhear)
					for(var/obj/item/weapon/paper/P in src.loc)
						if(P.info)
							usr << "\red The blank is tainted. It is unsuitable."
							return
						del(P)
						var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(src.loc)
						T.imbue = "deafen"
						for (var/mob/V in viewers(src))
							V.show_message("\red The runes turn into dust, which then forms into an arcane image on the paper.", 3)
						del(R)
						del(src)
						usr.say("H'drak v'loso, mir'kanas verbot!")
						return
				if(R.word1==worddestr && R.word2==wordsee && R.word3==wordother)
					for(var/obj/item/weapon/paper/P in src.loc)
						if(P.info)
							usr << "\red The blank is tainted. It is unsuitable."
							return
						del(P)
						var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(src.loc)
						T.imbue = "blind"
						for (var/mob/V in viewers(src))
							V.show_message("\red The runes turn into dust, which then forms into an arcane image on the paper.", 3)
						del(R)
						del(src)
						usr.say("H'drak v'loso, mir'kanas verbot!")
						return
			return fizzle()

/////////////////////////////////////////THIRTEENTH RUNE

		mend()
			usr.say("Uhrast ka'hfa heldsagen ver'lot!")
			usr.bruteloss+=200
			runedec+=5
			usr.visible_message("\red [usr] keels over dead, his blood glowing blue as it escapes his body and dissipates into thin air.", \
			"\red In the last moment of your humbly life, you feel as fabric of reality mends... with your blood.", \
			"\red You hear faint rustle.")
			for(,usr.health<-100)
				sleep(600)
			runedec=0
			return




/////////////////////////////////////////FOURTEETH RUNE

		communicate()
			if(istype(src,/obj/rune))
				usr.say("O bidai nabora se'sma!")
			else
				usr.whisper("O bidai nabora se'sma!")
			var/input = input(usr, "Please choose a message to tell to the other acolytes.", "Voice of Blood", "")
			if(!input)
				return fizzle()
			if(istype(src,/obj/rune))
				usr.say("[input]")
			else
				usr.whisper("[input]")
			for(var/mob/living/carbon/human/H in cultists)
				H << "\red \b [input]"
			del(src)
			return

/////////////////////////////////////////FIFTEENTH RUNE

		sacrifice()
			var/list/cultsinrange = list()
			var/list/victims = list()
			for(var/mob/living/carbon/human/V in src.loc)
				if(!cultists.Find(V))
					victims.Add(V)
			for(var/mob/living/carbon/human/C in orange(1,src))
				if(cultists.Find(C))
					cultsinrange.Add(C)
			for(var/mob/H in victims)
				for(var/mob/K in cultsinrange)
					K.say("Barhah hra zar'garis!")
				if (ticker.mode.name == "cult")
					if(H == ticker.mode:sacrifice_target.current)
						if(cultsinrange.len >= 3)
							H.gib(1)
							sacrificed += H.mind
							usr << "\red The Geometer of Blood accepts this sacrifice, your objective is now complete."
						else
							usr << "\red Your target's earthly bonds are too strong. You need more cultists to succeed in this ritual."
					else
						if(cultsinrange.len >= 3)
							if(H.stat !=2)
								H.gib(1)
								if(prob(80))
									usr << "\red The Geometer of Blood accepts this sacrifice."
									ticker.mode:grant_runeword(usr)
								else
									usr << "\red The Geometer of blood accepts this sacrifice."
									usr << "\red However, this soul was not enough to gain His favor."
							else
								H.gib(1)
								if(prob(40))
									usr << "\red The Geometer of blood accepts this sacrifice."
									ticker.mode:grant_runeword(usr)
								else
									usr << "\red The Geometer of blood accepts this sacrifice."
									usr << "\red However, a mere dead body is not enough to satisfy Him."
						else
							if(H.stat !=2)
								usr << "\red The victim is still alive, you will need more cultists chanting for the sacrifice to succeed."
							else
								H.gib(1)
								if(prob(40))
									usr << "\red The Geometer of blood accepts this sacrifice."
									ticker.mode:grant_runeword(usr)
								else
									usr << "\red The Geometer of blood accepts this sacrifice."
									usr << "\red However, a mere dead body is not enough to satisfy Him."
				else
					if(cultsinrange.len >= 3)
						H.gib(1)
						usr << "\red The Geometer of Blood accepts this sacrifice."
					else
						if(H.stat !=2)
							usr << "\red The victim is still alive, you will need more cultists chanting for the sacrifice to succeed."
						else
							H.gib(1)
							usr << "\red The Geometer of blood accepts this sacrifice."

				return
			for(var/mob/living/carbon/monkey/M in src.loc)
				for(var/mob/K in cultsinrange)
					K.say("Barhah hra zar'garis!")
				M.gib(1)
				if (ticker.mode.name == "cult")
					if(prob(20))
						usr << "\red The Geometer of Blood accepts your meager sacrifice."
						ticker.mode:grant_runeword(usr)
					else
						usr << "\red The Geometer of blood accepts this sacrifice."
						usr << "\red However, a mere monkey is not enough to satisfy Him."
				else
					usr << "\red The Geometer of Blood accepts your meager sacrifice."
				return
			for(var/mob/living/carbon/alien/A)
				for(var/mob/K in cultsinrange)
					K.say("Barhah hra zar'garis!")
				A.gib(1)
				if (ticker.mode.name == "cult")
					if(prob(75))
						usr << "\red The Geometer of Blood accepts your exotic sacrifice."
						ticker.mode:grant_runeword(usr)
					else
						usr << "\red The Geometer of Blood accepts your exotic sacrifice."
						usr << "\red However, this alien is not enough to gain His favor."
				else
					usr << "\red The Geometer of Blood accepts your exotic sacrifice."
				return
			return fizzle()

/////////////////////////////////////////SIXTEENTH RUNE

		revealrunes(var/obj/W as obj)
			var/go=0
			var/rad
			var/S=0
			if(istype(W,/obj/rune))
				rad = 6
				go = 1
			if (istype(W,/obj/item/weapon/paper/talisman))
				rad = 4
				go = 1
			if (istype(W,/obj/item/weapon/storage/bible))
				rad = 1
				go = 1
			if(go)
				for(var/obj/rune/R in orange(rad,src))
					if(R!=src)
						R:visibility=15
					S=1
			if(S)
				if(istype(W,/obj/item/weapon/storage/bible))
					usr << "\red Arcane markings suddenly glow from underneath a thin layer of dust!"
					return
				if(istype(W,/obj/rune))
					usr.say("Nikt'o barada kla'atu!")
					for (var/mob/V in viewers(src))
						V.show_message("\red The rune turns into red dust, reveaing the surrounding runes.", 3)
					del(src)
					return
				if(istype(W,/obj/item/weapon/paper/talisman))
					usr.whisper("Nikt'o barada kla'atu!")
					usr << "\red Your talisman turns into red dust, revealing the surrounding runes."
					for (var/mob/V in orange(1,usr.loc))
						if(V!=usr)
							V.show_message("\red Red dust emanates from [usr]'s hands for a moment.", 3)
					return
				return
			if(istype(W,/obj/rune))
				return	fizzle()
			if(istype(W,/obj/item/weapon/paper/talisman))
				call(/obj/rune/proc/fizzle)()
				return

/////////////////////////////////////////SEVENTEENTH RUNE

		wall()
			usr.say("Khari'd! Eske'te tannin!")
			src.density = !src.density
			usr.bruteloss += 2
			if(src.density)
				usr << "\red Your blood flows into the rune, and you feel that the very space over the rune thickens."
			else
				usr << "\red Your blood flows into the rune, and you feel as the rune releases its grasp on space."
			return

/////////////////////////////////////////EIGHTTEENTH RUNE

		freedom()
			var/culcount = 0
			for(var/mob/living/carbon/human/C in orange(1,src))
				if(cultists.Find(C))
					culcount++
			if(culcount>=3)
				var/mob/cultist = input("Choose the one who you want to free", "Followers of Geometer") as null|anything in (cultists - usr)
				if(!cultist)
					return fizzle()
				if (cultist == usr) //just to be sure.
					return
				if(!cultist.buckled && !cultist.handcuffed)
					usr << "\red The [cultist] is already free."
					return
				cultist.buckled = initial(cultist.buckled)
				cultist.handcuffed = initial(cultist.handcuffed)
				for(var/mob/living/carbon/human/C in orange(1,src))
					if(cultists.Find(C))
						C.bruteloss += 15
						C.say("Khari'd! Gual'te nikka!")
				del(src)
			return fizzle()

/////////////////////////////////////////NINETEENTH RUNE

		cultsummon()
			var/culcount = 0
			for(var/mob/living/carbon/human/C in orange(1,src))
				if(cultists.Find(C))
					culcount++
			if(culcount>=3)
				var/mob/cultist = input("Choose the one who you want to summon", "Followers of Geometer") as null|anything in (cultists - usr)
				if(!cultist)
					return fizzle()
				if (cultist == usr) //just to be sure.
					return
				if(cultist.buckled || cultist.handcuffed || (!isturf(cultist.loc) && !istype(cultist.loc, /obj/closet)))
					usr << "\red You cannot summon the [cultist], for him shackles of blood are strong"
					return fizzle()
				cultist.loc = src.loc
				for(var/mob/living/carbon/human/C in orange(1,src))
					if(cultists.Find(C))
						C.say("N'ath reth sh'yro eth d'rekkathnor!")
						C.bruteloss += 25
				usr.visible_message("\red Rune disappears with a flash of red light, and in it's place now a body lies.", \
				"\red You are blinded by the flash of red light! After you're able to see again, you see that now instead of the rune there's a body.", \
				"\red You hear a pop and smell ozone.")
				del(src)
			return fizzle()

/////////////////////////////////////////TWENTIETH RUNES

		deafen()
			if(istype(src,/obj/rune))
				var/affected = 0
				for(var/mob/living/carbon/C in range(7,src))
					if (cultists.Find(C))
						continue
					C.ear_deaf += 50
					C.show_message("\red World around you suddenly becomes quiet.", 3)
					affected++
					if(prob(1))
						C.disabilities |= 4
				if(affected)
					usr.say("Sti' kaliedir!")
					usr << "\red World becomes quiet as deafening rune dissipates into fine dust."
					del(src)
				else
					return fizzle()
			else
				usr.whisper("Sti' kaliedir!")
				usr << "\red Your talisman turns into gray dust, deafening everyone around."
				for(var/mob/living/carbon/C in range(7,usr))
					if (cultists.Find(C))
						continue
					C.ear_deaf += 30
					//talismans is weaker.
					C.show_message("\red World around you suddenly becomes quiet.", 3)
					for (var/mob/V in orange(1,src))
						if(!cultists.Find(V))
							V.show_message("\red Dust flows from [usr]'s hands for a moment, and the world suddenly becomes quiet..", 3)
			return

		blind()
			if(istype(src,/obj/rune))
				var/affected = 0
				for(var/mob/living/carbon/C in viewers(src))
					if (cultists.Find(C))
						continue
					C.eye_blurry += 50
					C.eye_blind += 20
					if(prob(5))
						C.disabilities |= 1
						if(prob(1))
							C.sdisabilities |= 1
					C.show_message("\red Suddenly you see red flash, that blinds you.", 3)
					affected++
				if(affected)
					usr.say("Sti' kaliesin!")
					usr << "\red Rune flashes, blinding those who not follow the Nar-Sie, and dissipates into fine dust."
					del(src)
				else
					return fizzle()
			else
				usr.whisper("Sti' kaliesin!")
				usr << "\red Your talisman turns into gray dust, blinding those who not follow the Nar-Sie."
				for(var/mob/living/carbon/C in viewers(usr))
					if (cultists.Find(C))
						continue
					C.eye_blurry += 30
					C.eye_blind += 10
					//talismans is weaker.
					C.show_message("\red You feel sharp pain in your eyes, and the world disappears into darkness..", 3)
			return


		bloodboil() //cultists need at least one DANGEROUS rune. Even if they're all stealthy.
			var/culcount = 0 //also, wording for it is old wording for obscure rune, which is now hide-see-blood.
			var/list/cultboil = list(cultists-usr) //and for this words are destroy-see-blood.
			for(var/mob/living/carbon/human/C in orange(1,src))
				if(cultists.Find(C))
					culcount++
			if(culcount>=2)
				for(var/mob/living/carbon/M in viewers(usr))
					if(cultboil.Find(M))
						continue
					M.bruteloss += 51
					M.fireloss += 51
					M << "\red Your blood boils!"
					if(prob(5))
						spawn(5)
							M.gib(1)
				for(var/obj/rune/R in viewers(src))
					if(prob(10))
						explosion(R.loc, -1, 0, 1, 5)
				del(src)
			else
				return fizzle()
			return

// WIP rune, I'll wait for Rastaf0 to add limited blood.

		burningblood()
			var/culcount = 0
			for(var/mob/living/carbon/human/C in orange(1,src))
				if(cultists.Find(C))
					culcount++
			if(culcount >= 5)
				for(var/obj/rune/R in world)
					if(R.blood_DNA == src.blood_DNA && R.blood_type == src.blood_type)
						for(var/mob/M in orange(2,R))
							M.fireloss += 15
							M << "\red Rune suddenly ignites, burning you!"
				for(var/obj/decal/cleanable/blood/B in world)
					if(B.blood_DNA == src.blood_DNA && B.blood_type == src.blood_type)
						for(var/mob/M in orange(1,B))
							M.fireloss += 5
							M << "\red Blood suddenly ignites, burning you!"
							del(B)
				del(src)