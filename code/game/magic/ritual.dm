var/list/cultists = list()


/obj/rune
	anchored = 1
	icon = 'magic.dmi'
	icon_state = "1"


	var
		word1
		word2
		word3

// ire - travel
// ego - self
// nahlizet - see
// certum - Hell
// veri - blood
// jatkaa - join <- eh, I just used good-soounding combos. Could change that later


// ire ego [word] - Teleport to [rune with word destination matching] (works in pairs)
// nahlizet veri certum - Create a new tome
// jatkaa veri ego - Incorporate person over the rune into the group
// certum jatkaa ego - Summon TERROR
// nahlizet ire certum - EMP rune

	examine()
		set src in usr
		if(!cultists.Find(usr))
			src.desc = text("A strange collection of symbols drawn in blood.")
		else
			src.desc = "A spell circle drawn in blood. It reads: <i>[word1] [word2] [word3]</i>."
		..()
		return

	attackby(I as obj, user as mob)
		if(istype(I, /obj/item/weapon/tome) && cultists.Find(user))
			user << "You retrace your steps, carefully undoing the lines of the rune."
			del(src)
			return
		else if(istype(I, /obj/item/weapon/storage/bible) && usr.mind && (usr.mind.assigned_role == "Chaplain"))
			user << "\blue You banish the vile magic with the blessing of God!"
			del(src)
			return
		return

	attack_hand(mob/user as mob)
		if(!cultists.Find(user))
			user << "You can't mouth the arcane scratchings without fumbling over them."
			return
		if(!word1 || !word2 || !word3 || prob(usr.brainloss))
			return fizzle()

		if(word1 == "ire" && word2 == "ego")
			usr.say("Sas'so c'arta forbici!")
			for(var/obj/rune/R in world)
				if(R == src)
					continue
				if(R.word3 == src.word3 && R.word1 == src.word1 && R.word2 == src.word2)
					for (var/mob/V in viewers(src))
						V.show_message("\red [user] disappears in a flash of red light!", 3, "\red You hear a sickening crunch and sloshing of viscera.", 2)
					user.loc = R.loc
					return
			return	fizzle()
		if(word1 == "nahlizet" && word2 == "veri" && word3 == "certum")
			usr.say("N'ath reth sh'yro eth d'raggathnor!")
			for (var/mob/V in viewers(src))
				V.show_message("\red There's a flash of red light. The rune disappears, and in its place a book lies", 3, "\red You hear a pop and smell ozone.", 2)
			new /obj/item/weapon/tome(src.loc)
			del(src)

/*
		if(word1 == "ire" && word2 == "certum" && word3 == "jatkaa")
			var/list/temprunes = list()
			var/list/runes = list()
			for(var/obj/rune/R in world)
				if(istype(R, /obj/rune))
					if(R.word1 == "ire" && R.word2 == "certum" && R.word3 == "jatkaa")
						runes.Add(R)
						var/atom/a = get_turf_loc(R)
						temprunes.Add(a.loc)
			var/chosen = input("Scry which rune?", "Scrying") in temprunes
			if(!chosen)
				return fizzle()
			var/selection_position = temprunes.Find(chosen)
			var/obj/rune/chosenrune = runes[selection_position]
			user.client.eye = chosenrune
			user:current = chosenrune
			user.reset_view(chosenrune)
*/
			return
		if(word1 == "jatkaa" && word2 == "veri" && word3 == "ego")
			usr.say("Mah'weyh pleggh at e'ntrath!")
			for(var/mob/living/carbon/human/M in src.loc)
				if(cultists.Find(M))
					return fizzle()
				else
					cultists.Add(M)
					for (var/mob/V in viewers(src))
						V.show_message("\red [M] writhes in pain as the markings below him glow a bloody red.", 3, "\red You hear an anguished scream.", 2)
					M << "<font color=\"purple\"><b><i>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</b></i></font>"
					M<< "<font color=\"purple\"><b><i>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</b></i></font>"
					return
		if(word1 == "certum" && word2 == "jatkaa" && word3 == "ego")
			usr.say("Tok-lyr rqa'nap g'lt-ulotf!")
			var/cultist_count = 0
			for(var/mob/M in orange(1,src))
				if(cultists.Find(M))
					cultist_count += 1
			if(cultist_count >= 6)
				var/obj/machinery/the_singularity/S = new /obj/machinery/the_singularity/(src.loc)
				S.icon = 'magic_terror.dmi'
				S.name = "Tear in the Fabric of Reality"
				S.desc = "Your mind begins to bubble and ooze as it tries to comprehend what it sees."
				S.pixel_x = -89
				S.pixel_y = -85
				message_admins("<h1><font color=\"purple\"><b><u>[key_name_admin(usr)] has summoned a Tear in the Fabric of Reality!", 1)
				return
			else
				return fizzle()
		if(word1 == "nahlizet" && word2 == "ire" && word3 == "certum")
			usr.say("ta'gh fara'qha fel d'amar det!")
			playsound(src.loc, 'Welder2.ogg', 25, 1)
			var/turf/T = get_turf(src)
			if(T)
				T.hotspot_expose(700,125)

			var/rune = src // detaching the proc - in theory
			src = null

			var/obj/overlay/pulse = new/obj/overlay ( T )
			pulse.icon = 'effects.dmi'
			pulse.icon_state = "emppulse"
			pulse.name = "emp pulse"
			pulse.anchored = 1
			spawn(20)
				del(pulse)

			for(var/obj/item/weapon/W in range(world.view-1, T))

				if (istype(W, /obj/item/assembly/m_i_ptank) || istype(W, /obj/item/assembly/r_i_ptank) || istype(W, /obj/item/assembly/t_i_ptank))

					var/fuckthis
					if(istype(W:part1,/obj/item/weapon/tank/plasma))
						fuckthis = W:part1
						fuckthis:ignite()
					if(istype(W:part2,/obj/item/weapon/tank/plasma))
						fuckthis = W:part2
						fuckthis:ignite()
					if(istype(W:part3,/obj/item/weapon/tank/plasma))
						fuckthis = W:part3
						fuckthis:ignite()


			for(var/mob/living/M in viewers(world.view-1, T))

				if(!istype(M, /mob/living)) continue

				if (istype(M, /mob/living/silicon))
					M.fireloss += 25
					flick("noise", M:flash)
					M << "\red <B>*BZZZT*</B>"
					M << "\red Warning: Electromagnetic pulse detected."
					if(istype(M, /mob/living/silicon/ai))
						if (prob(30))
							switch(pick(1,2,3)) //Add Random laws.
								if(1)
									M:cancel_camera()
								if(2)
									M:lockdown()
								if(3)
									M:ai_call_shuttle()
					continue


				M << "\red <B>Your equipment malfunctions.</B>" //Yeah, i realise that this WILL
																//show if theyre not carrying anything
																//that is affected. lazy.
				if (locate(/obj/item/weapon/cloaking_device, M))
					for(var/obj/item/weapon/cloaking_device/S in M)
						S.active = 0
						S.icon_state = "shield0"

				if (locate(/obj/item/weapon/gun/energy, M))
					for(var/obj/item/weapon/gun/energy/G in M)
						G.charges = 0
						G.update_icon()

				if ((istype(M, /mob/living/carbon/human)) && (istype(M:glasses, /obj/item/clothing/glasses/thermal)))
					M << "\red <B>Your thermals malfunction.</B>"
					M.eye_blind = 3
					M.eye_blurry = 5
					M.disabilities |= 1
					spawn(100)
						M.disabilities &= ~1

				if (locate(/obj/item/device/radio, M))
					for(var/obj/item/device/radio/R in M) //Add something for the intercoms.
						R.broadcasting = 0
						R.listening = 0

				if (locate(/obj/item/device/flash, M))
					for(var/obj/item/device/flash/F in M) //Add something for the intercoms.
						F.attack_self()

				if (locate(/obj/item/weapon/baton, M))
					for(var/obj/item/weapon/baton/B in M) //Add something for the intercoms.
						B.charges = 0

				if(locate(/obj/item/clothing/under/chameleon, M))
					for(var/obj/item/clothing/under/chameleon/C in M) //Add something for the intercoms.
						M << "\red <B>Your jumpsuit malfunctions</B>"
						C.name = "psychedelic"
						C.desc = "Groovy!"
						C.icon_state = "psyche"
						C.color = "psyche"
						spawn(200)
							C.name = "Black Jumpsuit"
							C.icon_state = "bl_suit"
							C.color = "black"
							C.desc = null

				M << "\red <B>BZZZT</B>"


			for(var/obj/machinery/A in range(world.view-1, T))
				A.use_power(7500)

				var/obj/overlay/pulse2 = new/obj/overlay ( A.loc )
				pulse2.icon = 'effects.dmi'
				pulse2.icon_state = "empdisable"
				pulse2.name = "emp sparks"
				pulse2.anchored = 1
				pulse2.dir = pick(cardinal)

				spawn(10)
					del(pulse2)

				if(istype(A, /obj/machinery/turret))
					A:enabled = 0
					A:lasers = 0
					A:power_change()

				if(istype(A, /obj/machinery/computer) && prob(20))
					A:set_broken()

				if(istype(A, /obj/machinery/firealarm) && prob(50))
					A:alarm()

				if(istype(A, /obj/machinery/power/smes))
					A:online = 0
					A:charging = 0
					A:output = 0
					A:charge -= 1e6
					if (A:charge < 0)
						A:charge = 0
					spawn(100)
						A:output = initial(A:output)
						A:charging = initial(A:charging)
						A:online = initial(A:online)

				if(istype(A, /obj/machinery/door))
					if(prob(20) && (istype(A,/obj/machinery/door/airlock) || istype(A,/obj/machinery/door/window)) )
						A:open()
					if(prob(40))
						if(A:secondsElectrified != 0) continue
						A:secondsElectrified = -1
						spawn(300)
							A:secondsElectrified = 0

				if(istype(A, /obj/machinery/power/apc))
					if(A:cell)
						A:cell:charge -= 1000
						if (A:cell:charge < 0)
							A:cell:charge = 0
					A:lighting = 0
					A:equipment = 0
					A:environ = 0
					spawn(600)
						A:equipment = 3
						A:environ = 3

				if(istype(A, /obj/machinery/camera))
					A.icon_state = "cameraemp"
					A:network = null                   //Not the best way but it will do. I think.
					spawn(900)
						A:network = initial(A:network)
						A:icon_state = initial(A:icon_state)
					for(var/mob/living/silicon/ai/O in world)
						if (O.current == A)
							O.cancel_camera()
							O << "Your connection to the camera has been lost."
					for(var/mob/O in world)
						if (istype(O.machine, /obj/machinery/computer/security))
							var/obj/machinery/computer/security/S = O.machine
							if (S.current == A)
								O.machine = null
								S.current = null
								O.reset_view(null)
								O << "The screen bursts into static."

				if(istype(A, /obj/machinery/clonepod))
					A:malfunction()
			del(rune)
			return
		else
			return fizzle()


	proc
		fizzle()
			usr.say(pick("B'ADMINES SP'WNIN SH'T","IC'IN O'OC","RO'SHA'M I'SA GRI'FF'N ME'AI","TOX'IN'S O'NM FI'RAH","IA BL'AME TOX'IN'S","FIR'A NON'AN RE'SONA","A'OI I'RS ROUA'GE","LE'OAN JU'STA SP'A'C Z'EE SH'EF","IA PT'WOBEA'RD, IA A'DMI'NEH'LP"))
			for (var/mob/V in viewers(src))
				V.show_message("\red The markings pulse with a small burst of light, then fall dark.", 3, "\red You hear a faint fizzle.", 2)
			return

		check_icon()
			if(word1 == "ire" && word2 == "ego")
				icon_state = "2"
				return
			if(word1 == "jatkaa" && word2 == "veri" && word3 == "ego")
				icon_state = "3"
				return
			if(word1 == "certum" && word2 == "jatkaa" && word3 == "ego")
				icon_state = "3"
				src.icon += rgb(100, 0 , 150)
				return
			if(word1 == "nahlizet" && word2 == "ire" && word3 == "certum")
				icon_state = "2"
				src.icon += rgb(0, 50 , 0)
				return
			icon_state = "1"


/obj/item/weapon/tome
	name = "arcane tome"
	icon_state ="tome"
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	flags = FPRINT | TABLEPASS

	attack_self(mob/user as mob)
		if(cultists.Find(user))
			var/C = 0
			for(var/obj/rune/N in world)
				C++
			if (C>=25)
				switch(alert("The cloth of reality can't take that much of a strain. By creating another rune, you risk locally tearing reality apart, which would prove fatal to you. Do you still wish to scribe the rune?",,"Yes","No"))
					if("Yes")
						if(prob(C*5-100))
							usr.emote("scream")
							user << "\red A tear momentarily appears in reality. Before it closes, you catch a glimpse of that which lies beyond. That proves to be too much for your mind."
							usr.gib(1)
							return
					if("No")
						return
			else
				if(alert("Scribe a rune?",,"Yes","No")=="No")
					return
			var/list/words = list("ire", "ego", "nahlizet", "certum", "veri", "jatkaa")
			var/w1
			var/w2
			var/w3
			if(usr)
				w1 = input("Write your first rune:", "Rune Scribing") in words
			if(usr)
				w2 = input("Write your second rune:", "Rune Scribing") in words
			if(usr)
				w3 = input("Write your third rune:", "Rune Scribing") in words
			for (var/mob/V in viewers(src))
				V.show_message("\red [user] slices open a finger and begins to chant and paint symbols on the floor.", 3, "\red You hear chanting.", 2)
			user << "\red You slice open one of your fingers and begin drawing a rune on the floor whilst chanting the ritual that binds your life essence with the dark arcane energies flowing through the surrounding world."
			user.bruteloss += 1
			if(do_after(user, 50))
				var/obj/rune/R = new /obj/rune(user.loc)
				user << "\red You finish drawing the arcane markings of the Geometer."
				R.word1 = w1
				R.word2 = w2
				R.word3 = w3
				R.check_icon()
			return
		else
			user << "The book seems full of illegible scribbles. Is this a joke?"
			return

	examine()
		set src in usr
		if(!cultists.Find(usr))
			usr << "An old, dusty tome with frayed edges and a sinister looking cover."
		else
			usr << "The scriptures of Nar-Sie, The One Who Sees, The Geometer of Blood. Contains the details of every ritual his followers could think of. Most of these are useless, though."


/obj/item/weapon/paperscrap
	name = "scrap of paper"
	icon_state = "scrap"
	throw_speed = 1
	throw_range = 2
	w_class = 1.0
	flags = FPRINT | TABLEPASS

	var
		data

	attack_self(mob/user as mob)
		view_scrap(user)

	examine()
		set src in usr
		view_scrap(usr)

	proc/view_scrap(var/viewer)
		viewer << browse(data)