var/list/sacrificed = list()

/obj/effect/rune
/////////////////////////////////////////FIRST RUNE
	proc
		teleport(var/key)
			var/mob/living/user = usr
			var/allrunesloc[]
			allrunesloc = new/list()
			var/index = 0
		//	var/tempnum = 0
			for(var/obj/effect/rune/R in world)
				if(R == src)
					continue
				if(R.word1 == wordtravel && R.word2 == wordself && R.word3 == key && R.z != 2)
					index++
					allrunesloc.len = index
					allrunesloc[index] = R.loc
			if(index >= 5)
				user << "\red You feel pain, as rune disappears in reality shift caused by too much wear of space-time fabric"
				if (istype(user, /mob/living))
					user.take_overall_damage(5, 0)
				del(src)
			if(allrunesloc && index != 0)
				if(istype(src,/obj/effect/rune))
					user.say("Sas'so c'arta forbici!")
				else
					user.whisper("Sas'so c'arta forbici!")
				user.visible_message("\red [user] disappears in a flash of red light!", \
				"\red You feel as your body gets dragged through the dimension of Nar-Sie!", \
				"\red You hear a sickening crunch and sloshing of viscera.")
				user.loc = allrunesloc[rand(1,index)]
				return
			if(istype(src,/obj/effect/rune))
				return	fizzle() //Use friggin manuals, Dorf, your list was of zero length.
			else
				call(/obj/effect/rune/proc/fizzle)()
				return


		itemport(var/key)
//			var/allrunesloc[]
//			allrunesloc = new/list()
//			var/index = 0
		//	var/tempnum = 0
			var/culcount = 0
			var/runecount = 0
			var/obj/effect/rune/IP = null
			var/mob/living/user = usr
			for(var/obj/effect/rune/R in world)
				if(R == src)
					continue
				if(R.word1 == wordtravel && R.word2 == wordother && R.word3 == key)
					IP = R
					runecount++
			if(runecount >= 2)
				user << "\red You feel pain, as rune disappears in reality shift caused by too much wear of space-time fabric"
				if (istype(user, /mob/living))
					user.take_overall_damage(5, 0)
				del(src)
			for(var/mob/living/carbon/C in orange(1,src))
				if(iscultist(C))
					culcount++
			if(culcount>=3)
				user.say("Sas'so c'arta forbici tarem!")
				user.visible_message("\red You feel air moving from the rune - like as it was swapped with somewhere else.", \
				"\red You feel air moving from the rune - like as it was swapped with somewhere else.", \
				"\red You smell ozone.")
				for(var/obj/O in src.loc)
					if(!O.anchored)
						O.loc = IP.loc
				for(var/mob/M in src.loc)
					M.loc = IP.loc
				return

			return fizzle()


/////////////////////////////////////////SECOND RUNE

		tomesummon()
			if(istype(src,/obj/effect/rune))
				usr.say("N'ath reth sh'yro eth d'raggathnor!")
			else
				usr.whisper("N'ath reth sh'yro eth d'raggathnor!")
			usr.visible_message("\red Rune disappears with a flash of red light, and in its place now a book lies.", \
			"\red You are blinded by the flash of red light! After you're able to see again, you see that now instead of the rune there's a book.", \
			"\red You hear a pop and smell ozone.")
			if(istype(src,/obj/effect/rune))
				new /obj/item/weapon/tome(src.loc)
			else
				new /obj/item/weapon/tome(usr.loc)
			del(src)
			return



/////////////////////////////////////////THIRD RUNE

		convert()
			for(var/mob/living/carbon/M in src.loc)
				if(iscultist(M))
					continue
				if(M.stat==2)
					continue
				usr.say("Mah'weyh pleggh at e'ntrath!")
				M.visible_message("\red [M] writhes in pain as the markings below him glow a bloody red.", \
				"\red AAAAAAHHHH!.", \
				"\red You hear an anguished scream.")
				if(is_convertable_to_cult(M.mind))
					ticker.mode.add_cultist(M.mind)
					M << "<font color=\"purple\"><b><i>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</b></i></font>"
					M << "<font color=\"purple\"><b><i>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</b></i></font>"
					return 1
				else
					M << "<font color=\"purple\"><b><i>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</b></i></font>"
					M << "<font color=\"red\"><b>And not a single fuck was given, exterminate the cult at all costs.</b></font>"
					return 0

			return fizzle()



/////////////////////////////////////////FOURTH RUNE

		tearreality()
			var/cultist_count = 0
			for(var/mob/M in range(1,src))
				if(iscultist(M))
					M.say("Tok-lyr rqa'nap g'lt-ulotf!")
					cultist_count += 1
			if(cultist_count >= 9)
				new /obj/machinery/singularity/narsie(src.loc)
				if(ticker.mode.name == "cult")
					ticker.mode:eldergod = 0
				return
			else
				return fizzle()

/////////////////////////////////////////FIFTH RUNE

		emp(var/U,var/range_red) //range_red - var which determines by which number to reduce the default emp range, U is the source loc, needed because of talisman emps which are held in hand at the moment of using and that apparently messes things up -- Urist
			if(istype(src,/obj/effect/rune))
				usr.say("Ta'gh fara'qha fel d'amar det!")
			else
				usr.whisper("Ta'gh fara'qha fel d'amar det!")
			playsound(U, 'Welder2.ogg', 25, 1)
			var/turf/T = get_turf(U)
			if(T)
				T.hotspot_expose(700,125)
			var/rune = src // detaching the proc - in theory
			empulse(U, (range_red - 2), range_red)
			del(rune)
			return

/////////////////////////////////////////SIXTH RUNE

		drain()
			var/drain = 0
			for(var/obj/effect/rune/R in world)
				if(R.word1==wordtravel && R.word2==wordblood && R.word3==wordself)
					for(var/mob/living/carbon/D in R.loc)
						if(D.stat!=2)
							var/bdrain = rand(1,25)
							D << "\red You feel weakened."
							D.take_overall_damage(bdrain, 0)
							drain += bdrain
			if(!drain)
				return fizzle()
			usr.say ("Yu'gular faras desdae. Havas mithum javara. Umathar uf'kal thenar!")
			usr.visible_message("\red Blood flows from the rune into [usr]!", \
			"\red The blood starts flowing from the rune and into your frail mortal body. You feel... empowered.", \
			"\red You hear a liquid flowing.")
			var/mob/living/user = usr
			if(user.bhunger)
				user.bhunger = max(user.bhunger-2*drain,0)
			if(drain>=50)
				user.visible_message("\red [user]'s eyes give off eerie red glow!", \
				"\red ...but it wasn't nearly enough. You crave, crave for more. The hunger consumes you from within.", \
				"\red You hear a heartbeat.")
				user.bhunger += drain
				src = user
				spawn()
					for (,user.bhunger>0,user.bhunger--)
						sleep(50)
						user.take_overall_damage(3, 0)
				return
			user.heal_organ_damage(drain%5, 0)
			drain-=drain%5
			for (,drain>0,drain-=5)
				sleep(2)
				user.heal_organ_damage(5, 0)
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
				usr.seer = 1
				return
			return fizzle()

/////////////////////////////////////////EIGHTH RUNE

		raise()
			var/mob/living/carbon/human/corpse_to_raise
			var/mob/living/carbon/human/body_to_sacrifice
			var/mob/living/carbon/human/ghost
			var/unsuitable_corpse_found = 0
			var/corpse_is_target = 0
			for(var/mob/living/carbon/human/M in src.loc)
				if (M.stat>=2)
					if (M.key)
						unsuitable_corpse_found = 1
					else if (ticker.mode.name == "cult" && M.mind == ticker.mode:sacrifice_target)
						corpse_is_target = 1
					else
						corpse_to_raise = M
						break
			if (!corpse_to_raise)
				if (unsuitable_corpse_found)
					usr << "\red The body still has some earthly ties. It must sever them, if only for them to grow again later."
				if (corpse_is_target)
					usr << "\red The Geometer of blood wants this mortal for himself."
				return fizzle()


			var/sacrifice_is_target = 0
			find_sacrifice:
				for(var/obj/effect/rune/R in world)
					if(R.word1==wordblood && R.word2==wordjoin && R.word3==wordhell)
						for(var/mob/living/carbon/human/N in R.loc)
							if (ticker.mode.name == "cult" && N.mind && N.mind == ticker.mode:sacrifice_target)
								sacrifice_is_target = 1
							else
								if(N.stat<2)
									body_to_sacrifice = N
									break find_sacrifice

			if (!body_to_sacrifice)
				if (sacrifice_is_target)
					usr << "\red The Geometer of blood wants that corpse for himself."
				else
					usr << "\red You need a dead corpse as source of energy to put soul in new body."
				return fizzle()

			for(var/mob/dead/observer/O in src.loc)
				if(!O.client)
					continue
				ghost = O

			if (!ghost)
				usr << "\red You do not feel an ethernal immaterial soul here."
				return fizzle()

//										rejuvenatedheal(M)
			corpse_to_raise.mind = new//Mind initialize stuff.
			corpse_to_raise.mind.current = corpse_to_raise
			corpse_to_raise.mind.original = corpse_to_raise
			corpse_to_raise.mind.key = ghost.key
			corpse_to_raise.key = ghost.key
			del(ghost)
			for(var/datum/organ/external/affecting in corpse_to_raise.organs)
				affecting.heal_damage(1000, 1000)
			corpse_to_raise.setToxLoss(0)
			corpse_to_raise.setOxyLoss(0)
			corpse_to_raise.SetParalysis(0)
			corpse_to_raise.SetStunned(0)
			corpse_to_raise.SetWeakened(0)
			corpse_to_raise.radiation = 0
			corpse_to_raise.buckled = null
			if (corpse_to_raise.handcuffed)
				del(corpse_to_raise.handcuffed)
			corpse_to_raise.stat=0
			corpse_to_raise.updatehealth()
			corpse_to_raise.UpdateDamageIcon()


			usr.say("Pasnar val'keriam usinar. Savrae ines amutan. Yam'toth remium il'tarat!")
			corpse_to_raise.visible_message("\red [corpse_to_raise]'s eyes glow with a faint red as he stands up, slowly starting to breathe again.", \
			"\red Life... I'm alive again...", \
			"\red You hear a faint, slightly familiar whisper.")
			body_to_sacrifice.visible_message("\red [body_to_sacrifice] is torn apart, a black smoke swiftly dissipating from his remains!", \
			"\red You feel as your blood boils, tearing you apart.", \
			"\red You hear a thousand voices, all crying in pain.")
			body_to_sacrifice.gib()
			if (ticker.mode.name == "cult")
				ticker.mode:add_cultist(body_to_sacrifice.mind)
			else
				ticker.mode.cult+=body_to_sacrifice.mind
			corpse_to_raise << "<font color=\"purple\"><b><i>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</b></i></font>"
			corpse_to_raise << "<font color=\"purple\"><b><i>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</b></i></font>"
			return





/////////////////////////////////////////NINETH RUNE

		obscure(var/rad)
			var/S=0
			for(var/obj/effect/rune/R in orange(rad,src))
				if(R!=src)
					R:visibility=0
				S=1
			if(S)
				if(istype(src,/obj/effect/rune))
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
			if(istype(src,/obj/effect/rune))
				return	fizzle()
			else
				call(/obj/effect/rune/proc/fizzle)()
				return

/////////////////////////////////////////TENTH RUNE

		ajourney() //some bits copypastaed from admin tools - Urist
			if(usr.loc==src.loc)
				var/mob/living/carbon/human/L = usr
				usr.say("Fwe'sh mah erl nyag r'ya!")
				usr.visible_message("\red [usr]'s eyes glow blue as \he freezes in place, absolutely motionless.", \
				"\red The shadow that is your spirit separates itself from your body. You are now in the realm beyond. While this is a great sight, being here strains your mind and body. Hurry...", \
				"\red You hear only complete silence for a moment.")
				usr.ghostize()
				for(L.ajourn=1,L.ajourn)
					sleep(10)
					if(L.key)
						L.ajourn=0
						return
					else
						L.take_organ_damage(1, 0)
			return fizzle()




/////////////////////////////////////////ELEVENTH RUNE

		manifest()
			var/obj/effect/rune/this_rune = src
			src = null
			if(usr.loc!=this_rune.loc)
				return this_rune.fizzle()
			var/mob/dead/observer/ghost
			for(var/mob/dead/observer/O in this_rune.loc)
				if (!O.client)
					continue
				ghost = O
				break
			if(!ghost)
				return this_rune.fizzle()

			usr.say("Gal'h'rfikk harfrandid mud'gib!")
			var/mob/living/carbon/human/dummy/D = new(this_rune.loc)
			usr.visible_message("\red A shape forms in the center of the rune. A shape of... a man.", \
			"\red A shape forms in the center of the rune. A shape of... a man.", \
			"\red You hear liquid flowing.")
			D.real_name = "Unknown"
			for(var/obj/item/weapon/paper/P in this_rune.loc)
/*
				if(length(P.info)<=24)
					D.real_name = P.info
					break
*/
				if(length(P.name)<=24)
					D.real_name = P.name
					break
			D.universal_speak = 1
			D.nodamage = 0
			D.mind = new//Mind initialize stuff.
			D.mind.current = D
			D.mind.original = D
			D.mind.key = ghost.key
			D.key = ghost.key
			ghost.invisibility = 101
			if (ticker.mode.name == "cult")
				ticker.mode:add_cultist(D.mind)
			else
				ticker.mode.cult+=D.mind
			D << "<font color=\"purple\"><b><i>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</b></i></font>"
			D << "<font color=\"purple\"><b><i>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</b></i></font>"
			var/mob/living/user = usr
			while(this_rune && user && user.stat==0 && user.client && user.loc==this_rune.loc)
				user.take_organ_damage(1, 0)
				sleep(30)
			if(D)
				D.visible_message("\red [D] slowly dissipates into dust and bones.", \
				"\red You feel pain, as bonds formed between your soul and this homunculus break.", \
				"\red You hear faint rustle.")
				ghost.invisibility = 10
				ghost.key = D.key
				D.dust()
			return





/////////////////////////////////////////TWELFTH RUNE

		talisman()//only hide, emp, teleport, deafen, blind and tome runes can be imbued atm
			var/obj/item/weapon/paper/newtalisman
			var/unsuitable_newtalisman = 0
			for(var/obj/item/weapon/paper/P in src.loc)
				if(!P.info)
					newtalisman = P
					break
				else
					unsuitable_newtalisman = 1
			if (!newtalisman)
				if (unsuitable_newtalisman)
					usr << "\red The blank is tainted. It is unsuitable."
				return fizzle()

			var/obj/effect/rune/imbued_from
			var/obj/item/weapon/paper/talisman/T
			for(var/obj/effect/rune/R in orange(1,src))
				if(R==src)
					continue
				if(R.word1==wordtravel && R.word2==wordself)  //teleport
					T = new(src.loc)
					T.imbue = "[R.word3]"
					T.info = "[R.word3]"
					imbued_from = R
					break
				if(R.word1==wordsee && R.word2==wordblood && R.word3==wordhell) //tome
					T = new(src.loc)
					T.imbue = "newtome"
					imbued_from = R
					break
				if(R.word1==worddestr && R.word2==wordsee && R.word3==wordtech) //emp
					T = new(src.loc)
					T.imbue = "emp"
					imbued_from = R
					break
				if(R.word1==wordblood && R.word2==wordsee && R.word3==worddestr) //conceal
					T = new(src.loc)
					T.imbue = "conceal"
					imbued_from = R
					break
				if(R.word1==wordhell && R.word2==worddestr && R.word3==wordother) //armor
					T = new(src.loc)
					T.imbue = "armor"
					imbued_from = R
					break
				if(R.word1==wordblood && R.word2==wordsee && R.word3==wordhide) //reveal
					T = new(src.loc)
					T.imbue = "revealrunes"
					imbued_from = R
					break
				if(R.word1==wordhide && R.word2==wordother && R.word3==wordsee) //deafen
					T = new(src.loc)
					T.imbue = "deafen"
					imbued_from = R
					break
				/*if(R.word1==worddestr && R.word2==wordsee && R.word3==wordother) //blind
					T = new(src.loc)
					T.imbue = "blind"
					imbued_from = R
					break*/
				if(R.word1==wordself && R.word2==wordother && R.word3==wordtech) //communicat
					T = new(src.loc)
					T.imbue = "communicate"
					imbued_from = R
					break
				if(R.word1==wordjoin && R.word2==wordhide && R.word3==wordtech) //communicat
					T = new(src.loc)
					T.imbue = "runestun"
					imbued_from = R
					break
			if (imbued_from)
				for (var/mob/V in viewers(src))
					V.show_message("\red The runes turn into dust, which then forms into an arcane image on the paper.", 3)
				usr.say("H'drak v'loso, mir'kanas verbot!")
				del(imbued_from)
				del(newtalisman)
			else
				return fizzle()

/////////////////////////////////////////THIRTEENTH RUNE

		mend()
			var/mob/living/user = usr
			src = null
			user.say("Uhrast ka'hfa heldsagen ver'lot!")
			user.take_overall_damage(200, 0)
			runedec+=10
			user.visible_message("\red [user] keels over dead, his blood glowing blue as it escapes his body and dissipates into thin air.", \
			"\red In the last moment of your humble life, you feel an immense pain as fabric of reality mends... with your blood.", \
			"\red You hear faint rustle.")
			for(,user.stat==2)
				sleep(600)
				if (!user)
					return
			runedec-=10
			return


/////////////////////////////////////////FOURTEETH RUNE

		communicate()
			var/input = copytext(sanitize(input(usr, "Please choose a message to tell to the other acolytes.", "Voice of Blood", "") as text|null),1,MAX_MESSAGE_LEN)
			if(!input)
				if (istype(src))
					return fizzle()
				else
					return
			if(istype(src,/obj/effect/rune))
				usr.say("O bidai nabora se'sma!")
			else
				usr.whisper("O bidai nabora se'sma!")
			var/input_s = sanitize(input)
			if(istype(src,/obj/effect/rune))
				usr.say("[input]")
			else
				usr.whisper("[input]")
			for(var/datum/mind/H in ticker.mode.cult)
				if (H.current)
					H.current << "\red \b [input_s]"
			del(src)
			return

/////////////////////////////////////////FIFTEENTH RUNE

		sacrifice()
			var/list/mob/living/carbon/human/cultsinrange = list()
			var/list/mob/living/carbon/human/victims = list()
			for(var/mob/living/carbon/human/V in src.loc)
				if(!(iscultist(V)))
					victims += V
			for(var/mob/living/carbon/C in orange(1,src))
				if(iscultist(C))
					cultsinrange += C
					C.say("Barhah hra zar'garis!")
			for(var/mob/H in victims)
				if (ticker.mode.name == "cult")
					if(H.mind == ticker.mode:sacrifice_target)
						if(cultsinrange.len >= 3)
							sacrificed += H.mind
							H.gib()
							usr << "\red The Geometer of Blood accepts this sacrifice, your objective is now complete."
						else
							usr << "\red Your target's earthly bonds are too strong. You need more cultists to succeed in this ritual."
					else
						if(cultsinrange.len >= 3)
							if(H.stat !=2)
								if(prob(80))
									usr << "\red The Geometer of Blood accepts this sacrifice."
									ticker.mode:grant_runeword(usr)
								else
									usr << "\red The Geometer of blood accepts this sacrifice."
									usr << "\red However, this soul was not enough to gain His favor."
								H.gib()
							else
								if(prob(40))
									usr << "\red The Geometer of blood accepts this sacrifice."
									ticker.mode:grant_runeword(usr)
								else
									usr << "\red The Geometer of blood accepts this sacrifice."
									usr << "\red However, a mere dead body is not enough to satisfy Him."
								H.gib()
						else
							if(H.stat !=2)
								usr << "\red The victim is still alive, you will need more cultists chanting for the sacrifice to succeed."
							else
								if(prob(40))
									usr << "\red The Geometer of blood accepts this sacrifice."
									ticker.mode:grant_runeword(usr)
								else
									usr << "\red The Geometer of blood accepts this sacrifice."
									usr << "\red However, a mere dead body is not enough to satisfy Him."
								H.gib()
				else
					if(cultsinrange.len >= 3)
						if(H.stat !=2)
							if(prob(80))
								usr << "\red The Geometer of Blood accepts this sacrifice."
								ticker.mode:grant_runeword(usr)
							else
								usr << "\red The Geometer of blood accepts this sacrifice."
								usr << "\red However, this soul was not enough to gain His favor."
							H.gib()
						else
							if(prob(40))
								usr << "\red The Geometer of blood accepts this sacrifice."
								ticker.mode:grant_runeword(usr)
							else
								usr << "\red The Geometer of blood accepts this sacrifice."
								usr << "\red However, a mere dead body is not enough to satisfy Him."
							H.gib()
					else
						if(H.stat !=2)
							usr << "\red The victim is still alive, you will need more cultists chanting for the sacrifice to succeed."
						else
							if(prob(40))
								usr << "\red The Geometer of blood accepts this sacrifice."
								ticker.mode:grant_runeword(usr)
							else
								usr << "\red The Geometer of blood accepts this sacrifice."
								usr << "\red However, a mere dead body is not enough to satisfy Him."
							H.gib()
			for(var/mob/living/carbon/monkey/M in src.loc)
				if (ticker.mode.name == "cult")
					if(M.mind == ticker.mode:sacrifice_target)
						if(cultsinrange.len >= 3)
							sacrificed += M.mind
							usr << "\red The Geometer of Blood accepts this sacrifice, your objective is now complete."
						else
							usr << "\red Your target's earthly bonds are too strong. You need more cultists to succeed in this ritual."
							continue
					else
						if(prob(20))
							usr << "\red The Geometer of Blood accepts your meager sacrifice."
							ticker.mode:grant_runeword(usr)
						else
							usr << "\red The Geometer of blood accepts this sacrifice."
							usr << "\red However, a mere monkey is not enough to satisfy Him."
				else
					usr << "\red The Geometer of Blood accepts your meager sacrifice."
					if(prob(20))
						ticker.mode.grant_runeword(usr)
				M.gib()
/*			for(var/mob/living/carbon/alien/A)
				for(var/mob/K in cultsinrange)
					K.say("Barhah hra zar'garis!")
				A.dust()      /// A.gib() doesnt work for some reason, and dust() leaves that skull and bones thingy which we dont really need.
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
			return fizzle() */

/////////////////////////////////////////SIXTEENTH RUNE

		revealrunes(var/obj/W as obj)
			var/go=0
			var/rad
			var/S=0
			if(istype(W,/obj/effect/rune))
				rad = 6
				go = 1
			if (istype(W,/obj/item/weapon/paper/talisman))
				rad = 4
				go = 1
			if (istype(W,/obj/item/weapon/nullrod))
				rad = 1
				go = 1
			if(go)
				for(var/obj/effect/rune/R in orange(rad,src))
					if(R!=src)
						R:visibility=15
					S=1
			if(S)
				if(istype(W,/obj/item/weapon/nullrod))
					usr << "\red Arcane markings suddenly glow from underneath a thin layer of dust!"
					return
				if(istype(W,/obj/effect/rune))
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
			if(istype(W,/obj/effect/rune))
				return	fizzle()
			if(istype(W,/obj/item/weapon/paper/talisman))
				call(/obj/effect/rune/proc/fizzle)()
				return

/////////////////////////////////////////SEVENTEENTH RUNE

		wall()
			usr.say("Khari'd! Eske'te tannin!")
			src.density = !src.density
			var/mob/living/user = usr
			user.take_organ_damage(2, 0)
			if(src.density)
				usr << "\red Your blood flows into the rune, and you feel that the very space over the rune thickens."
			else
				usr << "\red Your blood flows into the rune, and you feel as the rune releases its grasp on space."
			return

/////////////////////////////////////////EIGHTTEENTH RUNE

		freedom()
			var/mob/living/user = usr
			var/list/mob/living/carbon/cultists = new
			for(var/datum/mind/H in ticker.mode.cult)
				if (istype(H.current,/mob/living/carbon))
					cultists+=H.current
			var/list/mob/living/carbon/users = new
			for(var/mob/living/carbon/C in orange(1,src))
				if(iscultist(C))
					users+=C
			if(users.len>=3)
				var/mob/cultist = input("Choose the one who you want to free", "Followers of Geometer") as null|anything in (cultists - users)
				if(!cultist)
					return fizzle()
				if (cultist == user) //just to be sure.
					return
				if(!(cultist.buckled || \
					cultist.handcuffed || \
					istype(cultist.wear_mask, /obj/item/clothing/mask/muzzle) || \
					(istype(cultist.loc, /obj/structure/closet)&&cultist.loc:welded) || \
					(istype(cultist.loc, /obj/structure/closet/secure_closet)&&cultist.loc:locked) || \
					(istype(cultist.loc, /obj/machinery/dna_scannernew)&&cultist.loc:locked) \
				))
					user << "\red The [cultist] is already free."
					return
				cultist.buckled = null
				if (cultist.handcuffed)
					cultist.handcuffed.loc = cultist.loc
					cultist.handcuffed = null
				if (istype(cultist.wear_mask, /obj/item/clothing/mask/muzzle))
					cultist.u_equip(cultist.wear_mask)
				if(istype(cultist.loc, /obj/structure/closet)&&cultist.loc:welded)
					cultist.loc:welded = 0
				if(istype(cultist.loc, /obj/structure/closet/secure_closet)&&cultist.loc:locked)
					cultist.loc:locked = 0
				if(istype(cultist.loc, /obj/machinery/dna_scannernew)&&cultist.loc:locked)
					cultist.loc:locked = 0
				for(var/mob/living/carbon/C in users)
					user.take_overall_damage(15, 0)
					C.say("Khari'd! Gual'te nikka!")
				del(src)
			return fizzle()

/////////////////////////////////////////NINETEENTH RUNE

		cultsummon()
			var/mob/living/user = usr
			var/list/mob/living/carbon/cultists = new
			for(var/datum/mind/H in ticker.mode.cult)
				if (istype(H.current,/mob/living/carbon))
					cultists+=H.current
			var/list/mob/living/carbon/users = new
			for(var/mob/living/carbon/C in orange(1,src))
				if(iscultist(C))
					users+=C
			if(users.len>=3)
				var/mob/cultist = input("Choose the one who you want to summon", "Followers of Geometer") as null|anything in (cultists - user)
				if(!cultist)
					return fizzle()
				if (cultist == user) //just to be sure.
					return
				if(cultist.buckled || cultist.handcuffed || (!isturf(cultist.loc) && !istype(cultist.loc, /obj/structure/closet)))
					user << "\red You cannot summon the [cultist], for his shackles of blood are strong"
					return fizzle()
				cultist.loc = src.loc
				cultist.lying = 1
				cultist.regenerate_icons()
				for(var/mob/living/carbon/human/C in orange(1,src))
					if(iscultist(C))
						C.say("N'ath reth sh'yro eth d'rekkathnor!")
						C.take_overall_damage(25, 0)
				user.visible_message("\red Rune disappears with a flash of red light, and in its place now a body lies.", \
				"\red You are blinded by the flash of red light! After you're able to see again, you see that now instead of the rune there's a body.", \
				"\red You hear a pop and smell ozone.")
				del(src)
			return fizzle()

/////////////////////////////////////////TWENTIETH RUNES

		deafen()
			if(istype(src,/obj/effect/rune))
				var/affected = 0
				for(var/mob/living/carbon/C in range(7,src))
					if (iscultist(C))
						continue
					var/obj/item/weapon/nullrod/N = locate() in C
					if(N)
						continue
					C.ear_deaf += 50
					C.show_message("\red The world around you suddenly becomes quiet.", 3)
					affected++
					if(prob(1))
						C.disabilities |= 4
				if(affected)
					usr.say("Sti' kaliedir!")
					usr << "\red The world becomes quiet as the deafening rune dissipates into fine dust."
					del(src)
				else
					return fizzle()
			else
				var/affected = 0
				for(var/mob/living/carbon/C in range(7,usr))
					if (iscultist(C))
						continue
					var/obj/item/weapon/nullrod/N = locate() in C
					if(N)
						continue
					C.ear_deaf += 30
					//talismans is weaker.
					C.show_message("\red The world around you suddenly becomes quiet.", 3)
					affected++
				if(affected)
					usr.whisper("Sti' kaliedir!")
					usr << "\red Your talisman turns into gray dust, deafening everyone around."
					for (var/mob/V in orange(1,src))
						if(!(iscultist(V)))
							V.show_message("\red Dust flows from [usr]'s hands for a moment, and the world suddenly becomes quiet..", 3)
			return

		blind()
			if(istype(src,/obj/effect/rune))
				var/affected = 0
				for(var/mob/living/carbon/C in viewers(src))
					if (iscultist(C))
						continue
					var/obj/item/weapon/nullrod/N = locate() in C
					if(N)
						continue
					C.eye_blurry += 50
					C.eye_blind += 20
					if(prob(5))
						C.disabilities |= 1
						if(prob(10))
							C.sdisabilities |= 1
					C.show_message("\red Suddenly you see red flash that blinds you.", 3)
					affected++
				if(affected)
					usr.say("Sti' kaliesin!")
					usr << "\red The rune flashes, blinding those who not follow the Nar-Sie, and dissipates into fine dust."
					del(src)
				else
					return fizzle()
			else
				var/affected = 0
				for(var/mob/living/carbon/C in viewers(usr))
					if (iscultist(C))
						continue
					var/obj/item/weapon/nullrod/N = locate() in C
					if(N)
						continue
					C.eye_blurry += 30
					C.eye_blind += 10
					//talismans is weaker.
					affected++
					C.show_message("\red You feel a sharp pain in your eyes, and the world disappears into darkness..", 3)
				if(affected)
					usr.whisper("Sti' kaliesin!")
					usr << "\red Your talisman turns into gray dust, blinding those who not follow the Nar-Sie."
			return


		bloodboil() //cultists need at least one DANGEROUS rune. Even if they're all stealthy.
/*
			var/list/mob/living/carbon/cultists = new
			for(var/datum/mind/H in ticker.mode.cult)
				if (istype(H.current,/mob/living/carbon))
					cultists+=H.current
*/
			var/culcount = 0 //also, wording for it is old wording for obscure rune, which is now hide-see-blood.
//			var/list/cultboil = list(cultists-usr) //and for this words are destroy-see-blood.
			for(var/mob/living/carbon/C in orange(1,src))
				if(iscultist(C))
					culcount++
			if(culcount>=3)
				for(var/mob/living/carbon/M in viewers(usr))
					if(iscultist(M))
						continue
					var/obj/item/weapon/nullrod/N = locate() in M
					if(N)
						continue
					M.take_overall_damage(51,51)
					M << "\red Your blood boils!"
					if(prob(5))
						spawn(5)
							M.gib()
				for(var/obj/effect/rune/R in view(src))
					if(prob(10))
						explosion(R.loc, -1, 0, 1, 5)
				for(var/mob/living/carbon/human/C in orange(1,src))
					if(iscultist(C))
						C.say("Dedo ol'btoh!")
						C.take_overall_damage(15, 0)
				del(src)
			else
				return fizzle()
			return

// WIP rune, I'll wait for Rastaf0 to add limited blood.

		burningblood()
			var/culcount = 0
			for(var/mob/living/carbon/C in orange(1,src))
				if(iscultist(C))
					culcount++
			if(culcount >= 5)
				for(var/obj/effect/rune/R in world)
					if(R.blood_DNA == src.blood_DNA)
						for(var/mob/living/M in orange(2,R))
							M.take_overall_damage(0,15)
							if (R.invisibility>M.see_invisible)
								M << "\red Aargh it burns!"
							else
								M << "\red Rune suddenly ignites, burning you!"
							var/turf/T = get_turf(R)
							T.hotspot_expose(700,125)
				for(var/obj/effect/decal/cleanable/blood/B in world)
					if(B.blood_DNA == src.blood_DNA)
						for(var/mob/living/M in orange(1,B))
							M.take_overall_damage(0,5)
							M << "\red Blood suddenly ignites, burning you!"
							var/turf/T = get_turf(B)
							T.hotspot_expose(700,125)
							del(B)
				del(src)

//////////             Rune 24 (counting burningblood, which kinda doesnt work yet.)

		runestun(var/mob/living/carbon/T as mob)
			if(istype(src,/obj/effect/rune))   ///When invoked as rune, flash and stun everyone around.
				usr.say("Fuu ma'jin!")
				for(var/mob/living/carbon/C in viewers(src))
					flick("e_flash", C.flash)
					if (C.stuttering < 1 && (!(HULK in C.mutations)))
						C.stuttering = 1
					C.Weaken(1)
					C.Stun(1)
					C.show_message("\red The rune explodes in a bright flash.", 3)
				del(src)
			else                        ///When invoked as talisman, stun and mute the target mob.
				usr.say("Dream sign ''Evil sealing talisman''!")
				var/obj/item/weapon/nullrod/N = locate() in T
				if(N)
					for(var/mob/O in viewers(T, null))
						O.show_message(text("\red <B>[] invokes a talisman at [], but they are unaffected!</B>", usr, T), 1)
				else
					for(var/mob/O in viewers(T, null))
						O.show_message(text("\red <B>[] invokes a talisman at []</B>", usr, T), 1)
					flick("e_flash", T.flash)
					if (!(HULK in T.mutations))
						T.silent += 15
					T.Weaken(25)
					T.Stun(25)
				return

/////////////////////////////////////////TWENTY-FIFTH RUNE

		armor()
			var/mob/living/carbon/human/user = usr
			if(istype(src,/obj/effect/rune))
				usr.say("N'ath reth sh'yro eth d'raggathnor!")
			else
				usr.whisper("N'ath reth sh'yro eth d'raggathnor!")
			usr.visible_message("\red Rune disappears with a flash of red light, and a set of armor appears on you..", \
			"\red You are blinded by the flash of red light! After you're able to see again, you see that you are now wearing a set of armor.")
			//user.equip_if_possible(new /obj/item/clothing/shoes/jackboots(user), user.slot_shoes)
			//user.equip_if_possible(new /obj/item/clothing/suit/cultrobes(user), user.slot_wear_suit)
			//user.equip_if_possible(new /obj/item/clothing/head/culthood(user), user.slot_head)
			//user.equip_if_possible(new /obj/item/clothing/gloves/black(user), user.slot_gloves)
			user.equip_if_possible(new /obj/item/clothing/suit/magusred(user), user.slot_wear_suit)
			user.equip_if_possible(new /obj/item/clothing/head/magus(user), user.slot_head)
			user.equip_if_possible(new /obj/item/weapon/melee/cultblade(user), user.slot_r_hand)
			user.equip_if_possible(new /obj/item/weapon/storage/backpack/cultpack(user), user.slot_back)
			del(src)
			return
