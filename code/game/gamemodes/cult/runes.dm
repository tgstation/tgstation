var/list/sacrificed = list()

/obj/effect/rune


///Teleport: Teleports the user to a random teleport rune with the same rune. Can be imbued into a talisman.


/obj/effect/rune/proc/teleport(var/key)
	var/mob/living/user = usr
	var/allrunesloc[]
	allrunesloc = new/list()
	var/index = 0
	//	var/tempnum = 0
	for(var/obj/effect/rune/R in world)
		if(R == src)
			continue
		if(R.word1 == wordtravel && R.word2 == wordself && R.word3 == key && R.z != ZLEVEL_CENTCOM)
			index++
			allrunesloc.len = index
			allrunesloc[index] = R.loc
	if(index >= 5)
		user << "<span class='danger'>You feel pain, as rune disappears in reality shift caused by too much wear of space-time fabric</span>"
		if (istype(user, /mob/living))
			user.take_overall_damage(5, 0)
		qdel(src)
	if(allrunesloc && index != 0)
		if(istype(src,/obj/effect/rune))
			user.say("Sas[pick("'","`")]so c'arta forbici!")//Only you can stop auto-muting
		else
			user.whisper("Sas[pick("'","`")]so c'arta forbici!")
		user.visible_message("<span class='danger'>[user] disappears in a flash of red light!</span>", \
		"<span class='userdanger'>You feel as your body gets dragged through the dimension of Nar-Sie!</span>", \
		"<span class='italics'>You hear a sickening crunch and sloshing of viscera.</span>")
		user.loc = allrunesloc[rand(1,index)]
		return
	if(istype(src,/obj/effect/rune))
		return fizzle(user) //Use friggin manuals, Dorf, your list was of zero length.
	else
		call(/obj/effect/rune/proc/fizzle)()
		return


//Subtype of teleport, teleports any items and mobs on top of the rune rather than the user themselves
/obj/effect/rune/proc/itemport(var/key)
//	var/allrunesloc[]
//	allrunesloc = new/list()
//	var/index = 0
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
		user << "<span class='userdanger'>You feel pain, as the rune disappears in reality shift caused by too much wear of space-time fabric</span>"
		if (istype(user, /mob/living))
			user.take_overall_damage(5, 0)
		qdel(src)
	for(var/mob/living/C in orange(1,src))
		if(iscultist(C) && !C.stat)
			culcount++
	if(user.loc==src.loc)
		return fizzle(user)
	if(culcount>=1)
		user.say("Sas[pick("'","`")]so c'arta forbici tarem!")
		user.visible_message("<span class='danger'>You feel air moving from the rune - like as it was swapped with somewhere else.</span>", \
		"<span class='danger'>You feel air moving from the rune - like as it was swapped with somewhere else.</span>", \
		"<span class='danger'>You smell ozone.</span>")
		for(var/obj/O in src.loc)
			if(!O.anchored)
				O.loc = IP.loc
		for(var/mob/M in src.loc)
			M.loc = IP.loc
		return

	return fizzle(user)


///Summon Tome: Summons a completely untranslated tome.


/obj/effect/rune/proc/tomesummon()
	if(istype(src,/obj/effect/rune))
		usr.say("N[pick("'","`")]ath reth sh'yro eth d'raggathnor!")
	else
		usr.whisper("N[pick("'","`")]ath reth sh'yro eth d'raggathnor!")
	usr.visible_message("<span class='danger'>Rune disappears with a flash of red light, and in its place now a book lies.</span>", \
	"<span class='danger'>You are blinded by the flash of red light! After you're able to see again, you see that now instead of the rune there's a book.</span>", \
	"<span class='italics'>You hear a pop and smell ozone.</span>")
	if(istype(src,/obj/effect/rune))
		new /obj/item/weapon/tome(src.loc)
	else
		new /obj/item/weapon/tome(usr.loc)
	qdel(src)
	return


///Convert: The primary method of gaining new followers. Requires three cultists, doesn't work on loyalty implanted people, captains, or chaplains.


/obj/effect/rune/proc/convert()
	var/list/mob/living/cultsinrange = list()
	for(var/mob/living/carbon/M in src.loc)
		if(iscultist(M))
			continue
		if(M.stat==2)
			continue
		for(var/mob/living/C in orange(1,src))
			if(iscultist(C) && !C.stat)		//converting requires three cultists
				cultsinrange += C
				C.say("Mah[pick("'","`")]weyh pleggh at e'ntrath!")
		if(cultsinrange.len >= 3)
			M.visible_message("<span class='danger'>[M] writhes in pain as the markings below him glow a bloody red.</span>", \
			"<span class='userdanger'>AAAAAAHHHH!</span>", \
			"<span class='italics'>You hear an anguished scream.</span>")
			if(is_convertable_to_cult(M.mind))
				ticker.mode.add_cultist(M.mind)
				M.mind.special_role = "Cultist"
				M << "<font color=\"purple\"><b><i>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</b></i></font>"
				M << "<font color=\"purple\"><b><i>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</b></i></font>"
			else
				M << "<font color=\"purple\"><b><i>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</b></i></font>"
				M << "<span class='boldannounce'>And not a single fuck was given, exterminate the cult at all costs.</span>"
				if(ticker.mode.name == "cult")
					if(M.mind == ticker.mode.sacrifice_target)
						for(var/mob/living/carbon/human/cultist in cultsinrange)
							cultist << "<span class='h2.boldannounce'>The Chosen One!! <BR>KILL THE CHOSEN ONE!!! </span>"
				return 0
		else
			for(var/mob/living/carbon/human/cultist in cultsinrange)
				cultist << "<span class='warning'>You need more brothers to overcome their lies and make them see Truth. </span>"
	return fizzle()


///Summon Nar-Sie: Summons the avatar of Nar-Sie to wreak havoc on the station. Will turn walls and floors to cult version and make anyone it touches into a harvester.


/obj/effect/rune/proc/tearreality()
	var/list/mob/living/cultist_count = list()
	var/mob/living/user = usr
	user.say("Tok-lyr rqa'nap g[pick("'","`")]lt-ulotf!")
	for(var/mob/M in range(1,src))
		if(iscultist(M) && !M.stat)
			cultist_count += M
	if(cultist_count.len >= 9)
		if(ticker.mode.name == "cult")
			var/datum/game_mode/cult/cultmode = ticker.mode
			if(!("eldergod" in cultmode.cult_objectives))
				message_admins("[usr.real_name]([usr.ckey]) tried to summon a god when she didn't want to come out to play.")	// Admin alert because you *KNOW* dickbutts are going to abuse this.
				for(var/mob/M in cultist_count)
					M.reagents.add_reagent("hell_water", 10)
					M << "<span class='h2.userdanger'>YOUR SOUL BURNS WITH YOUR ARROGANCE!!!</span>"
				return
			else
				for(var/obj_count=1, obj_count <= cultmode.cult_objectives.len, obj_count++)
					if(cultmode.cult_objectives[obj_count] == "sacrifice")
						if(cultmode.sacrifice_target)
							if(!(cultmode.sacrifice_target in sacrificed))
								for(var/mob/M in cultist_count)
									M << "<span class='h2.userdanger'>Nar-sie refuses to be summoned while the sacrifice isn't complete.</span>"
								return
				cultmode.eldergod = 0
		var/narsie_type = /obj/singularity/narsie/large
		// Moves narsie if she was already summoned.
		var/obj/her = locate(narsie_type, SSobj.processing)
		if(her)
			her.loc = get_turf(src)
			return
		// Otherwise...
		new narsie_type(src.loc) // Summon her!
		qdel(src) 	// Stops cultists from spamming the rune to summon narsie more than once.
					// Might actually be wise to straight up del() this
		return
	else
		return fizzle()


///EMP: Lets out a large EMP blast


/obj/effect/rune/proc/emp(var/U,var/range_red) //range_red - var which determines by which number to reduce the default emp range, U is the source loc, needed because of talisman emps which are held in hand at the moment of using and that apparently messes things up -- Urist
	if(istype(src,/obj/effect/rune))
		usr.say("Ta'gh fara[pick("'","`")]qha fel d'amar det!")
	else
		usr.whisper("Ta'gh fara[pick("'","`")]qha fel d'amar det!")
	playsound(U, 'sound/items/Welder2.ogg', 25, 1)
	var/turf/T = get_turf(U)
	if(T)
		T.hotspot_expose(700,125)
	var/rune = src // detaching the proc - in theory
	empulse(U, (range_red - 2), range_red)
	qdel(rune)

///Blood Drain: Deals 1-25 damage to someone on top of it and heals an equivalent amount of brute damage to the user. Can be stacked. Too much blood drain = blood hunger that must be sated.

/obj/effect/rune/proc/drain()
	var/drain = 0
	for(var/obj/effect/rune/R in world)
		if(R.word1==wordtravel && R.word2==wordblood && R.word3==wordself)
			for(var/mob/living/carbon/D in R.loc)
				if(D.stat!=2)
					var/bdrain = rand(1,25)
					D << "<span class='danger'>You feel weakened.</span>"
					D.take_overall_damage(bdrain, 0)
					drain += bdrain
	if(!drain)
		return fizzle()
	usr.say ("Yu[pick("'","`")]gular faras desdae. Havas mithum javara. Umathar uf'kal thenar!")
	usr.visible_message("<span class='danger'>Blood flows from the rune into [usr]!</span>", \
	"<span class='danger'>The blood starts flowing from the rune and into your frail mortal body. You feel... empowered.</span>", \
	"<span class='italics'>You hear a liquid flowing.</span>")
	var/mob/living/user = usr
	if(user.bhunger)
		user.bhunger = max(user.bhunger-2*drain,0)
	if(drain>=50)
		user.visible_message("<span class='danger'>[user]'s eyes give off eerie red glow!</span>", \
		"<span class='danger'>...but it wasn't nearly enough. You crave, crave for more. The hunger consumes you from within.</span>", \
		"<span class='italics'>You hear a heartbeat.</span>")
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


///Raise Dead: Requires two corpses. Brings one to life and gibs the other.


/obj/effect/rune/proc/raise()
	var/mob/living/carbon/human/corpse_to_raise
	var/mob/living/carbon/human/body_to_sacrifice

	var/is_sacrifice_target = 0
	for(var/mob/living/carbon/human/M in src.loc)
		if(M.stat == DEAD)
			if(ticker.mode.name == "cult" && M.mind == ticker.mode:sacrifice_target)
				is_sacrifice_target = 1
			else
				corpse_to_raise = M
				if(M.key)
					M.ghostize(1)	//kick them out of their body
				break
	if(!corpse_to_raise)
		if(is_sacrifice_target)
			usr << "<span class='danger'>The Geometer of blood wants this mortal for himself.</span>"
		return fizzle()


	is_sacrifice_target = 0
	find_sacrifice:
		for(var/obj/effect/rune/R in world)
			if(R.word1==wordblood && R.word2==wordjoin && R.word3==wordhell)
				for(var/mob/living/carbon/human/N in R.loc)
					if(ticker.mode.name == "cult" && N.mind && N.mind == ticker.mode:sacrifice_target)
						is_sacrifice_target = 1
					else
						if(N.stat!= DEAD)
							body_to_sacrifice = N
							break find_sacrifice

	if(!body_to_sacrifice)
		if (is_sacrifice_target)
			usr << "<span class='danger'>The Geometer of blood wants that corpse for himself.</span>"
		else
			usr << "<span class='danger'>The sacrifical corpse is not dead. You must free it from this world of illusions before it may be used.</span>"
		return fizzle()

	var/mob/dead/observer/ghost
	for(var/mob/dead/observer/O in loc)
		if(!O.client)	continue
		if(O.mind && O.mind.current && O.mind.current.stat != DEAD)	continue
		ghost = O
		break

	if(!ghost)
		usr << "<span class='danger'>You require a restless spirit which clings to this world. Beckon their prescence with the sacred chants of Nar-Sie.</span>"
		return fizzle()

	for(var/obj/item/organ/limb/affecting in corpse_to_raise.organs)
		affecting.heal_damage(1000, 1000, 0)
	corpse_to_raise.setToxLoss(0)
	corpse_to_raise.setOxyLoss(0)
	corpse_to_raise.SetParalysis(0)
	corpse_to_raise.SetStunned(0)
	corpse_to_raise.SetWeakened(0)
	corpse_to_raise.radiation = 0
	corpse_to_raise.stat = CONSCIOUS
	corpse_to_raise.updatehealth()
	corpse_to_raise.update_damage_overlays(0)

	corpse_to_raise.key = ghost.key	//the corpse will keep its old mind! but a new player takes ownership of it (they are essentially possessed)
									//This means, should that player leave the body, the original may re-enter
	if(usr.real_name == "Herbert West")
		usr.say("To life, to life, I bring them!")
	else
		usr.say("Pasnar val'keriam usinar. Savrae ines amutan. Yam'toth remium il'tarat!")
	corpse_to_raise.visible_message("<span class='danger'>[corpse_to_raise]'s eyes glow with a faint red as he stands up, slowly starting to breathe again.</span>", \
	"<span class='danger'>Life... I'm alive again...</span>", \
	"<span class='italics'>You hear a faint, slightly familiar whisper.</span>")
	body_to_sacrifice.visible_message("<span class='danger'>[body_to_sacrifice] is torn apart, a black smoke swiftly dissipating from his remains!</span>", \
	"<span class='userdanger'>You feel a horrible sensation of being torn apart, and--</span>", \
	"<span class='italics'>You hear a thousand voices, all crying in pain.</span>")
	body_to_sacrifice.gib()
	corpse_to_raise << "<font color=\"purple\"><b><i>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</b></i></font>"
	corpse_to_raise << "<font color=\"purple\"><b><i>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</b></i></font>"
	return


///Veil: Makes all surrounding runes invisible. They cannot be used directly but still used indirectly (i.e. teleport...)


/obj/effect/rune/proc/obscure(var/rad)
	var/S=0
	for(var/obj/effect/rune/R in orange(rad,src))
		if(R!=src)
			R.invisibility=INVISIBILITY_OBSERVER
		S=1
	if(S)
		if(istype(src,/obj/effect/rune))
			usr.say("Kla[pick("'","`")]atu barada nikt'o!")
			for (var/mob/V in viewers(src))
				V.show_message("<span class='danger'>The rune turns into gray dust, veiling the surrounding runes.</span>", 3)
			qdel(src)
		else
			usr.whisper("Kla[pick("'","`")]atu barada nikt'o!")
			usr << "<span class='danger'>Your talisman turns into gray dust, veiling the surrounding runes.</span>"
			for (var/mob/V in orange(1,src))
				if(V!=usr)
					V.show_message("<span class='danger'>Dust emanates from [usr]'s hands for a moment.</span>", 3)

		return
	if(istype(src,/obj/effect/rune))
		return fizzle()
	else
		call(/obj/effect/rune/proc/fizzle)()
		return


///Astral Journey: Lets a player explore around as a ghost but does 10 brute damage for every tick they are like that. If they are moved from the rune they cannot return.


/obj/effect/rune/proc/ajourney() //some bits copypastaed from admin tools - Urist
	if(usr.loc==src.loc)
		var/mob/living/carbon/human/L = usr
		usr.say("Fwe[pick("'","`")]sh mah erl nyag r'ya!")
		usr.visible_message("<span class='danger'>[usr]'s eyes glow blue as \he freezes in place, absolutely motionless.</span>", \
		"<span class='danger'>The shadow that is your spirit separates itself from your body. You are now in the realm beyond. While this is a great sight, being here strains your mind and body. Hurry...</span>", \
		"<span class='italics'>You hear only complete silence for a moment.</span>")
		usr.ghostize(1)
		L.ajourn = 1
		while(L)
			if(L.key)
				L.ajourn=0
				return
			else
				L.take_organ_damage(10, 0)
			sleep(100)
	return fizzle()


///Manifest: User must be standing on rune. When invoked, makes a culted human spawn. The user takes damage depending on how many humans there are. If the user moves, all manifested humans are killed.


/obj/effect/rune/proc/manifest()
	var/obj/effect/rune/this_rune = src
	src = null
	if(usr.loc!=this_rune.loc)
		return this_rune.fizzle()
	var/mob/dead/observer/ghost
	for(var/mob/dead/observer/O in this_rune.loc)
		if(!O.client)	continue
		if(O.mind && O.mind.current && O.mind.current.stat != DEAD)	continue
		ghost = O
		break
	if(!ghost)
		return this_rune.fizzle()

	usr.say("Gal'h'rfikk harfrandid mud[pick("'","`")]gib!")
	var/mob/living/carbon/human/dummy/D = new(this_rune.loc)
	usr.visible_message("<span class='danger'>A shape forms in the center of the rune. A shape of... a man.</span>", \
	"<span class='danger'>A shape forms in the center of the rune. A shape of... a man.</span>", \
	"<span class='italics'>You hear liquid flowing.</span>")
	D.real_name = "[pick(first_names_male)] [pick(last_names)]"
	D.status_flags = CANSTUN|CANWEAKEN|CANPARALYSE|CANPUSH

	D.key = ghost.key

	if(ticker.mode.name == "cult")
		ticker.mode:add_cultist(D.mind)
	else
		ticker.mode.cult+=D.mind

	D.mind.special_role = "Cultist"
	D << "<font color=\"purple\"><b><i>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</b></i></font>"
	D << "<font color=\"purple\"><b><i>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</b></i></font>"

	var/mob/living/user = usr
	while(this_rune && user && user.stat==CONSCIOUS && user.client && user.loc==this_rune.loc)
		user.take_organ_damage(1, 0)
		sleep(30)
	if(D)
		D.visible_message("<span class='danger'>[D] slowly dissipates into dust and bones.</span>", \
		"<span class='danger'>You feel pain, as bonds formed between your soul and this homunculus break.</span>", \
		"<span class='italics'>You hear faint rustle.</span>")
		D.dust()
	return


///Imbue Talisman: Put a compatible rune near this one and a paper on top of the imbue rune. Activate, and the compatible rune will be imbued into the paper.


/obj/effect/rune/proc/talisman()//only hide, emp, teleport, deafen, blind and tome runes can be imbued atm
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
			usr << "<span class='danger'>The blank is tainted. It is unsuitable.</span>"
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
		if(R.word1==worddestr && R.word2==wordsee && R.word3==wordother) //blind
			T = new(src.loc)
			T.imbue = "blind"
			imbued_from = R
			break
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
			V.show_message("<span class='danger'>The runes turn into dust, which then forms into an arcane image on the paper.</span>", 3)
		usr.say("H'drak v[pick("'","`")]loso, mir'kanas verbot!")
		qdel(imbued_from)
		qdel(newtalisman)
	else
		return fizzle()


///Communicate: Static communication rune. Somewhat pointless with free communications with tomes.


/obj/effect/rune/proc/communicate()
	var/input = stripped_input(usr, "Please enter a message to tell to the other acolytes.", "Voice of Blood", "")
	if(!input)
		if(istype(src))
			fizzle()
			return 0
		else
			return 0
	cultist_commune(usr , 1, 1, input)
	return 1


///Sacrifice: Gibs a target as an offering. Gives tome words as a reward and if the target has a mind, spawns a soul shard with their shade contained within.


/obj/effect/rune/proc/sacrifice()
	var/list/mob/living/carbon/human/cultsinrange = list()
	var/list/mob/living/carbon/human/victims = list()
	for(var/mob/living/carbon/human/V in src.loc)//Checks for non-cultist humans to sacrifice
		if(ishuman(V))
			if(!(iscultist(V)))
				victims += V//Checks for cult status and mob type
	for(var/obj/item/I in src.loc)//Checks for MMIs/brains/Intellicards
		if(istype(I,/obj/item/organ/brain))
			var/obj/item/organ/brain/B = I
			victims += B.brainmob
		else if(istype(I,/obj/item/device/mmi))
			var/obj/item/device/mmi/B = I
			victims += B.brainmob
		else if(istype(I,/obj/item/device/aicard))
			for(var/mob/living/silicon/ai/A in I)
				victims += A
	for(var/mob/living/carbon/C in orange(1,src))
		if(iscultist(C) && !C.stat)
			cultsinrange += C
			C.say("Barhah hra zar[pick("'","`")]garis!")
			if(cultsinrange.len >= 3) break		//we only need to check for three alive cultists, loop breaks so their aren't extra cultists getting word rewards
	for(var/mob/H in victims)
		if (ticker.mode.name == "cult")
			if(H.mind == ticker.mode:sacrifice_target)
				if(cultsinrange.len >= 3)
					sacrificed += H.mind
					stone_or_gib(H)
					for(var/mob/living/carbon/C in cultsinrange)
						C << "<span class='danger'>The Geometer of Blood accepts this sacrifice, your objective is now complete.</span>"
						C << "<span class='danger'>He is pleased!</span>"
						sac_grant_word(C)
						sac_grant_word(C)
						sac_grant_word(C)	//Little reward for completing the objective
				else
					usr << "<span class='danger'>Your target's earthly bonds are too strong. You need more cultists to succeed in this ritual.</span>"
			else
				if(cultsinrange.len >= 3)
					if(H.stat !=2)
						for(var/mob/living/carbon/C in cultsinrange)
							C << "<span class='danger'>The Geometer of Blood accepts this sacrifice.</span>"
							sac_grant_word(C)
							stone_or_gib(H)
					else
						if(prob(60))
							usr << "<span class='danger'>The Geometer of blood accepts this sacrifice.</span>"
							sac_grant_word(usr)
						else
							usr << "<span class='danger'>The Geometer of blood accepts this sacrifice.</span>"
							usr << "<span class='danger'>However, a mere dead body is not enough to satisfy Him.</span>"
						stone_or_gib(H)
				else
					if(H.stat !=2)
						usr << "<span class='danger'>The victim is still alive, you will need more cultists chanting for the sacrifice to succeed.</span>"
					else
						if(prob(60))
							usr << "<span class='danger'>The Geometer of blood accepts this sacrifice.</span>"
							sac_grant_word(usr)
						else
							usr << "<span class='danger'>The Geometer of blood accepts this sacrifice.</span>"
							usr << "<span class='danger'>However, a mere dead body is not enough to satisfy Him.</span>"
						stone_or_gib(H)
		else
			if(cultsinrange.len >= 3)
				if(H.stat !=2)
					for(var/mob/living/carbon/C in cultsinrange)
						C << "<span class='danger'>The Geometer of Blood accepts this sacrifice.</span>"
						sac_grant_word(C)
						stone_or_gib(H)
				else
					if(prob(60))
						usr << "<span class='danger'>The Geometer of blood accepts this sacrifice.</span>"
						sac_grant_word(usr)
					else
						usr << "<span class='danger'>The Geometer of blood accepts this sacrifice.</span>"
						usr << "<span class='danger'>However, a mere dead body is not enough to satisfy Him.</span>"
					stone_or_gib(H)
			else
				if(H.stat !=2)
					usr << "<span class='danger'>The victim is still alive, you will need more cultists chanting for the sacrifice to succeed.</span>"
				else
					if(prob(60))
						usr << "<span class='danger'>The Geometer of blood accepts this sacrifice.</span>"
						sac_grant_word(usr)
					else
						usr << "<span class='danger'>The Geometer of blood accepts this sacrifice.</span>"
						usr << "<span class='danger'>However, a mere dead body is not enough to satisfy Him.</span>"
					stone_or_gib(H)
	for(var/mob/living/carbon/monkey/M in src.loc)
		if (ticker.mode.name == "cult")
			if(M.mind == ticker.mode:sacrifice_target)
				if(cultsinrange.len >= 3)
					sacrificed += M.mind
					for(var/mob/living/carbon/C in cultsinrange)
						C << "<span class='danger'>The Geometer of Blood accepts this sacrifice, your objective is now complete.</span>"
						C << "<span class='danger'>He is pleased!</span>"
						sac_grant_word(C)
						sac_grant_word(C)
						sac_grant_word(C)	//Little reward for completing the objective
				else
					usr << "<span class='danger'>Your target's earthly bonds are too strong. You need more cultists to succeed in this ritual.</span>"
					continue
			else
				if(prob(30))
					usr << "<span class='danger'>The Geometer of Blood accepts your meager sacrifice.</span>"
					sac_grant_word(usr)
				else
					usr << "<span class='danger'>The Geometer of blood accepts this sacrifice.</span>"
					usr << "<span class='danger'>However, a mere monkey is not enough to satisfy Him.</span>"
		else
			usr << "<span class='danger'>The Geometer of Blood accepts your meager sacrifice.</span>"
			if(prob(30))
				ticker.mode.grant_runeword(usr)
		stone_or_gib(M)
	for(var/mob/victim in src.loc)			//TO-DO: Move the shite above into the mob's own sac_act - see /mob/living/simple_animal/pet/corgi/sac_act for an example
		victim.sac_act(src, victim)			//Sacrifice procs are now seperate per mob, this allows us to allow sacrifice on as many mob types as we want without making an already clunky system worse

/obj/effect/rune/proc/sac_grant_word(var/mob/living/C)	//The proc that which chooses a word rewarded for a successful sacrifice, sacrifices always give a currently unknown word if the normal checks pass
	if(C.mind.cult_words.len != ticker.mode.allwords.len) // No point running if they already know everything
		var/convert_word
		var/pick_list = ticker.mode.allwords - C.mind.cult_words
		convert_word = pick(pick_list)
		ticker.mode.grant_runeword(C, convert_word)

/obj/effect/rune/proc/stone_or_gib(var/mob/T)
	var/obj/item/device/soulstone/stone = new /obj/item/device/soulstone(get_turf(src))
	if(!stone.transfer_soul("FORCE", T, usr))	//if it fails to add soul
		qdel(stone)
	if(T)
		if(isrobot(T))
			T.dust()//To prevent the MMI from remaining
		else
			T.gib()


///Reveal: Reverses the Veil rune's effect, revealing all hidden runes.


/obj/effect/rune/proc/revealrunes(var/obj/W as obj)
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
				R.invisibility=0
			S=1
	if(S)
		if(istype(W,/obj/item/weapon/nullrod))
			usr << "<span class='danger'>Arcane markings suddenly glow from underneath a thin layer of dust!</span>"
			return
		if(istype(W,/obj/effect/rune))
			usr.say("Nikt[pick("'","`")]o barada kla'atu!")
			for (var/mob/V in viewers(src))
				V.show_message("<span class='danger'>The rune turns into red dust, reveaing the surrounding runes.</span>", 3)
			qdel(src)
			return
		if(istype(W,/obj/item/weapon/paper/talisman))
			usr.whisper("Nikt[pick("'","`")]o barada kla'atu!")
			usr << "<span class='danger'>Your talisman turns into red dust, revealing the surrounding runes.</span>"
			for (var/mob/V in orange(1,usr.loc))
				if(V!=usr)
					V.show_message("<span class='danger'>Red dust emanates from [usr]'s hands for a moment.</span>", 3)
			return
		return
	if(istype(W,/obj/effect/rune))
		return fizzle()
	if(istype(W,/obj/item/weapon/paper/talisman))
		call(/obj/effect/rune/proc/fizzle)()
		return


///Wall: Makes the rune dense and uncrossable. You can invoke it again to make it normal again. Deals 2 brute damage when used.


/obj/effect/rune/proc/wall()
	usr.say("Khari[pick("'","`")]d! Eske'te tannin!")
	src.density = !src.density
	var/mob/living/user = usr
	user.take_organ_damage(2, 0)
	if(src.density)
		usr << "<span class='danger'>Your blood flows into the rune, and you feel that the very space over the rune thickens.</span>"
	else
		usr << "<span class='danger'>Your blood flows into the rune, and you feel as the rune releases its grasp on space.</span>"
	return


///Free Cultist: If the cultist is not walking free, makes it so.


/obj/effect/rune/proc/freedom() //MURICA ;_;7
	var/mob/living/user = usr
	var/list/mob/living/cultists = new
	for(var/datum/mind/H in ticker.mode.cult)
		if (istype(H.current,/mob/living/carbon))
			cultists+=H.current
	var/list/mob/living/users = new
	for(var/mob/living/C in orange(1,src))
		if(iscultist(C) && !C.stat)
			users+=C
	if(users.len>=1)
		var/mob/living/carbon/cultist = input("Choose the one who you want to free", "Followers of Geometer") as null|anything in (cultists - users)
		if(!cultist)
			return fizzle(user)
		if (cultist == user) //just to be sure.
			return
		if(!(cultist.buckled || \
			cultist.handcuffed || \
			istype(cultist.wear_mask, /obj/item/clothing/mask/muzzle) || \
			(istype(cultist.loc, /obj/structure/closet)&&cultist.loc:welded) || \
			(istype(cultist.loc, /obj/structure/closet/secure_closet)&&cultist.loc:locked) || \
			(istype(cultist.loc, /obj/machinery/dna_scannernew)&&cultist.loc:locked) \
		))
			user << "<span class='danger'>The [cultist] is already free.</span>"
			return
		if(cultist.buckled)
			cultist.buckled.unbuckle_mob()
		if (cultist.handcuffed)
			cultist.handcuffed.loc = cultist.loc
			cultist.handcuffed = null
			cultist.update_inv_handcuffed(0)
		if (cultist.legcuffed)
			cultist.legcuffed.loc = cultist.loc
			cultist.legcuffed = null
			cultist.update_inv_legcuffed(0)
		if (istype(cultist.wear_mask, /obj/item/clothing/mask/muzzle))
			cultist.unEquip(cultist.wear_mask)
		if(istype(cultist.loc, /obj/structure/closet)&&cultist.loc:welded)
			cultist.loc:welded = 0
		if(istype(cultist.loc, /obj/structure/closet/secure_closet)&&cultist.loc:locked)
			cultist.loc:locked = 0
		if(istype(cultist.loc, /obj/machinery/dna_scannernew)&&cultist.loc:locked)
			cultist.loc:locked = 0
		for(var/mob/living/C in users)
			user.take_overall_damage(15, 0)
			C.say("Khari[pick("'","`")]d! Gual'te nikka!")
		qdel(src)
	return fizzle(user)


///Summon Cultist: Requires 3 cultists, summons a cultist to the rune's location and does 25 brute to all users.


/obj/effect/rune/proc/cultsummon()
	var/mob/living/user = usr
	var/list/mob/living/carbon/cultists = new
	for(var/datum/mind/H in ticker.mode.cult)
		if (istype(H.current,/mob/living/carbon))
			cultists+=H.current
	var/list/mob/living/users = new
	for(var/mob/living/C in orange(1,src))
		if(iscultist(C) && !C.stat)
			users+=C
	if(users.len>=3)
		var/mob/living/carbon/cultist = input("Choose the one who you want to summon", "Followers of Geometer") as null|anything in (cultists - user)
		if(!cultist)
			return fizzle(user)
		if(cultist == user) //just to be sure.
			return
		if(cultist.buckled || cultist.handcuffed || (!isturf(cultist.loc) && !istype(cultist.loc, /obj/structure/closet)))
			user << "<span class='danger'>You cannot summon the [cultist], for his shackles of blood are strong</span>"
			return fizzle(user)
		cultist.loc = src.loc
		cultist.Weaken(5)
		cultist.regenerate_icons()
		for(var/mob/living/C in orange(1,src))
			if(iscultist(C) && !C.stat)
				C.say("N'ath reth sh'yro eth d[pick("'","`")]rekkathnor!")
				C.take_overall_damage(25, 0)
		user.visible_message("<span class='danger'>Rune disappears with a flash of red light, and in its place now a body lies.</span>", \
		"<span class='danger'>You are blinded by the flash of red light! After you're able to see again, you see that now instead of the rune there's a body.</span>", \
		"<span class='italics'>You hear a pop and smell ozone.</span>")
		qdel(src)
	return fizzle(user)


///Deafen: Makes all nearby non-cultists deaf.


/obj/effect/rune/proc/deafen()
	if(istype(src,/obj/effect/rune))
		var/affected = 0
		for(var/mob/living/carbon/C in range(7,src))
			if (iscultist(C))
				continue
			var/obj/item/weapon/nullrod/N = locate() in C
			if(N)
				continue
			C.adjustEarDamage(0, 50)
			C.show_message("<span class='danger'>The world around you suddenly becomes quiet.</span>", 3)
			affected++
			if(prob(1) && ishuman(C))
				C.dna.add_mutation(DEAFMUT)
		if(affected)
			usr.say("Sti[pick("'","`")] kaliedir!")
			usr << "<span class='danger'>The world becomes quiet as the deafening rune dissipates into fine dust.</span>"
			qdel(src)
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
			C.adjustEarDamage(0, 30)
			//talismans is weaker.
			C.show_message("<span class='danger'>The world around you suddenly becomes quiet.</span>", 3)
			affected++
		if(affected)
			usr.whisper("Sti[pick("'","`")] kaliedir!")
			usr << "<span class='danger'>Your talisman turns into gray dust, deafening everyone around.</span>"
			for (var/mob/V in orange(1,src))
				if(!(iscultist(V)))
					V.show_message("<span class='danger'>Dust flows from [usr]'s hands for a moment, and the world suddenly becomes quiet..</span>", 3)
	return


///Blind: Makes all non-cultists nearby blind. Combine with Deafen to make the entire shuttle go into a panic and laugh as they bumble around.


/obj/effect/rune/proc/blind()
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
				C.disabilities |= NEARSIGHT
				if(prob(10))
					C.disabilities |= BLIND
			C.show_message("<span class='danger'>Suddenly you see red flash that blinds you.</span>", 3)
			affected++
		if(affected)
			usr.say("Sti[pick("'","`")] kaliesin!")
			usr << "<span class='danger'>The rune flashes, blinding those who not follow the Nar-Sie, and dissipates into fine dust.</span>"
			qdel(src)
		else
			return fizzle()
	else
		var/affected = 0
		for(var/mob/living/carbon/C in view(2,usr))
			if (iscultist(C))
				continue
			var/obj/item/weapon/nullrod/N = locate() in C
			if(N)
				continue
			C.eye_blurry += 30
			C.eye_blind += 10
			//talismans is weaker.
			affected++
			C.show_message("<span class='danger'>You feel a sharp pain in your eyes, and the world disappears into darkness..</span>", 3)
		if(affected)
			usr.whisper("Sti[pick("'","`")] kaliesin!")
			usr << "<span class='danger'>Your talisman turns into gray dust, blinding those who not follow the Nar-Sie.</span>"
	return


///Blood Boil: Every non-cultist nearby will take 51 burn and 51 brute damage. 5% chance for them to gib as well. Users will take 15 brute. 10% chance for the rune to blow up.


/obj/effect/rune/proc/bloodboil() //cultists need at least one DANGEROUS rune. Even if they're all stealthy.
	var/culcount = 0
	for(var/mob/living/carbon/C in orange(1,src))
		if(iscultist(C) && !C.stat)
			culcount++
	if(culcount>=3)
		for(var/mob/living/carbon/M in viewers(usr))
			if(iscultist(M))
				continue
			var/obj/item/weapon/nullrod/N = locate() in M
			if(N)
				continue
			M.take_overall_damage(51,51)
			M << "<span class='danger'>Your blood boils!</span>"
		for(var/obj/effect/rune/R in view(src))
			if(prob(10))
				explosion(R.loc, -1, 0, 1, 5)
		for(var/mob/living/carbon/human/C in orange(1,src))
			if(iscultist(C) && !C.stat)
				C.say("Dedo ol[pick("'","`")]btoh!")
				C.take_overall_damage(15, 0)
		qdel(src)
	else
		return fizzle()
	return


///Stun: Everyone nearby would be stunned for a -very- short time. If used in a talisman, it stuns and mutes a single target.


/obj/effect/rune/proc/runestun(var/mob/living/T as mob)
	if(istype(src,/obj/effect/rune))   ///When invoked as rune, flash and stun everyone around.
		usr.say("Fuu ma[pick("'","`")]jin!")
		for(var/mob/living/L in viewers(src))

			if(iscarbon(L))
				var/mob/living/carbon/C = L
				flick("e_flash", C.flash)
				C.stuttering = 1
				C.Weaken(1)
				C.Stun(1)
				C.show_message("<span class='danger'>The rune explodes in a bright flash.</span>", 3)

			else if(issilicon(L))
				var/mob/living/silicon/S = L
				S.Weaken(5)
				S.show_message("<span class='danger'>!@(%* BZZZZZT !@(%!)$</span>", 3)
		qdel(src)
	else                        ///When invoked as talisman, stun and mute the target mob.
		usr.say("Dream sign ''Evil sealing talisman'[pick("'","`")]!")
		var/obj/item/weapon/nullrod/N = locate() in T
		if(N)
			for(var/mob/O in viewers(T, null))
				O.show_message(text("<span class='danger'>[] invokes a talisman at [], but they are unaffected!</span>", usr, T), 1)
		else
			for(var/mob/O in viewers(T, null))
				O.show_message(text("<span class='danger'>[] invokes a talisman at []</span>", usr, T), 1)

			if(issilicon(T))
				T.Weaken(10)

			else if(iscarbon(T))
				var/mob/living/carbon/C = T
				flick("e_flash", C.flash)
				C.silent += 15
				C.Weaken(10)
				C.Stun(10)
		return


///Armor: The user will be armed with cultist garb, a trophy rack, and a high-damage sword. If items are in these slots, they will not be equipped and simply deleted.


/obj/effect/rune/proc/armor()
	var/list/armors = list("zealot")
	var/armorworn
	var/mob/living/carbon/human/user = usr
	if(istype(user.wear_suit, /obj/item/clothing/suit/wizrobe) && istype(user.head, /obj/item/clothing/head/wizard))
		armors += "summoner"
	if(istype(user.wear_suit, /obj/item/clothing/suit/space) && istype(user.head, /obj/item/clothing/head/helmet/space))
		armors += "traveler"
	if(istype(user.wear_suit, /obj/item/clothing/suit/space/captain) && istype(user.head, /obj/item/clothing/head/helmet/space/captain))
		armors += "marauder"
	if(istype(user.wear_suit, /obj/item/clothing/suit/armor/reactive))
		armors += "trickster"
	if(istype(user.wear_suit, /obj/item/clothing/suit/toggle/labcoat/cmo))
		armors += "physician"
	if(istype(src,/obj/effect/rune))
		armorworn = input ("Choose your attire.") in armors
	else
		armorworn = "zealot"
	if (armorworn == "zealot")
		usr.say("N'ath reth sh'yro eth d[pick("'","`")]raggathnor!")
		user.equip_to_slot_or_del(new /obj/item/clothing/head/culthood/alt(user), slot_head)
		user.equip_to_slot_or_del(new /obj/item/clothing/suit/cultrobes/alt(user), slot_wear_suit)
		user.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult(user), slot_shoes)
		user.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/cultpack(user), slot_back)
		user.put_in_hands(new /obj/item/weapon/melee/cultblade(user))
		usr.visible_message("\red The rune disappears with a flash of red light, and a set of armor appears on [usr]...", \
		"\red You are blinded by the flash of red light! After you're able to see again, you see that you are now wearing a set of armor.")
	if (armorworn == "summoner" || armorworn == "trickster" || armorworn == "physician")
		usr.say("Uln Shogg Hafh[pick("'","`")]drn!")
		user << "\red You quietly prick your finger and make a pact with the geometer of blood to acquire more power."
		user.take_overall_damage(rand(5,20))
		del(user.head)
		del(user.wear_suit)
		user.equip_to_slot_or_del(new /obj/item/clothing/head/magus(user), slot_head)
		user.equip_to_slot_or_del(new /obj/item/clothing/suit/magusred(user), slot_wear_suit)
		user.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult(user), slot_shoes)
		user.spellremove(user)
		usr.visible_message("\red The rune disappears with a flash of red light, and a set of robes appears on [usr]...", \
		"\red You are blinded by the flash of red light! After you're able to see again, you see that you are now wearing a set of robes.")
	if (armorworn == "summoner")
		user.mind.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/conjure/soulstone/cult(user)
		user.mind.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/conjure/construct/lesser/cult(user)
	if (armorworn == "trickster")
		user.put_in_hands(new /obj/item/weapon/gun/magic/wand/door(user))
		user.mind.spell_list += new /obj/effect/proc_holder/spell/targeted/turf_teleport/blink/cult(user)
	if (armorworn == "physician")
		user.put_in_hands(new /obj/item/weapon/gun/magic/wand/death(user))
		user.put_in_hands(new /obj/item/weapon/gun/magic/wand/resurrection(user))
	if (armorworn == "traveler" || armorworn == "marauder")
		usr.say("Tharanak n[pick("'","`")]ghft!")
		del(user.head)
		del(user.wear_suit)
		user.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/cult(user), slot_head)
		user.equip_to_slot_or_del(new /obj/item/clothing/suit/space/cult(user), slot_wear_suit)
		user.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult(user), slot_shoes)
		user.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/cultpack(user), slot_back)
		user.put_in_hands(new /obj/item/weapon/melee/cultblade(user))
		user.spellremove(user)
		usr.visible_message("\red The rune disappears with a flash of red light, and an armored space suit appears on [usr]...", \
		"\red You are blinded by the flash of red light! After you're able to see again, you see that you are now wearing an armored space suit.")
	if (armorworn == "marauder")
		user.spellremove(user)
		user.mind.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/conjure/creature/cult(user)
	del(src)
	return

///Summon Shell: Summons a construct shell if there's four plasteel sheets on top of the rune


/obj/effect/rune/proc/summon_shell()		// Summons a construct shell
	for(var/obj/item/stack/sheet/plasteel/PS in src.loc)		//I could probably combine the amounts but I'm too lazy to compensate for others' lazyness
		if(PS.amount >= 4)		// may need increasing?
			usr.say("Eth ra p'ni[pick("'","`")]dedo ol!")		//I have no idea if these are written in a proper made up language or just Urist smacking his face on the keyboard
			new /obj/structure/constructshell(src.loc)
//?			PS.remove_amount(4)			//TO-DO: Write a proc for removing sheets from a stack and deleting when stack is empty... why doesnt this exist yet??
			PS.amount -= 4
		if(PS.amount <= 0)
			qdel(PS)
			qdel(src)
			return 1
		return fizzle()
