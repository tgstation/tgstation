/////////////////////////////
// Helpers for DNA2
/////////////////////////////

// Pads 0s to t until length == u
/proc/add_zero2(t, u)
	var/temp1
	while (length(t) < u)
		t = "0[t]"
	temp1 = t
	if (length(t) > u)
		temp1 = copytext(t,2,u+1)
	return temp1

// DNA Gene activation boundaries, see dna2.dm.
// Returns a list object with 4 numbers.
/proc/GetDNABounds(var/block)
	var/list/BOUNDS=dna_activity_bounds[block]
	if(!istype(BOUNDS))
		return DNA_DEFAULT_BOUNDS
	return BOUNDS

// Give Random Bad Mutation to M
/proc/randmutb(var/mob/living/M)
	if(!M) return
	M.dna.check_integrity()
	var/block = pick(GLASSESBLOCK,COUGHBLOCK,FAKEBLOCK,NERVOUSBLOCK,CLUMSYBLOCK,TWITCHBLOCK,HEADACHEBLOCK,BLINDBLOCK,DEAFBLOCK,HALLUCINATIONBLOCK)
	M.dna.SetSEState(block, 1)

// Give Random Good Mutation to M
/proc/randmutg(var/mob/living/M)
	if(!M) return
	M.dna.check_integrity()
	var/block = pick(HULKBLOCK,XRAYBLOCK,FIREBLOCK,TELEBLOCK,NOBREATHBLOCK,REMOTEVIEWBLOCK,REGENERATEBLOCK,INCREASERUNBLOCK,REMOTETALKBLOCK,MORPHBLOCK,COLDBLOCK,NOPRINTSBLOCK,SHOCKIMMUNITYBLOCK,SMALLSIZEBLOCK)
	M.dna.SetSEState(block, 1)

// Random Appearance Mutation
/proc/randmuti(var/mob/living/M)
	if(!M) return
	M.dna.check_integrity()
	M.dna.SetUIValue(rand(1,UNIDNASIZE),rand(1,4095))

// Scramble UI or SE.
/proc/scramble(var/UI, var/mob/M, var/prob)
	if(!M)	return
	M.dna.check_integrity()
	if(UI)
		for(var/i = 1, i <= DNA_UI_LENGTH-1, i++)
			if(prob(prob))
				M.dna.SetUIValue(i,rand(1,4095),1)
		M.dna.UpdateUI()
		M.UpdateAppearance()

	else
		for(var/i = 1, i <= STRUCDNASIZE-1, i++)
			if(prob(prob))
				M.dna.SetSEValue(i,rand(1,4095),1)
		M.dna.UpdateSE()
		domutcheck(M, null)
	return

// I haven't yet figured out what the fuck this is supposed to do.
/proc/miniscramble(input,rs,rd)
	var/output
	output = null
	if (input == "C" || input == "D" || input == "E" || input == "F")
		output = pick(prob((rs*10));"4",prob((rs*10));"5",prob((rs*10));"6",prob((rs*10));"7",prob((rs*5)+(rd));"0",prob((rs*5)+(rd));"1",prob((rs*10)-(rd));"2",prob((rs*10)-(rd));"3")
	if (input == "8" || input == "9" || input == "A" || input == "B")
		output = pick(prob((rs*10));"4",prob((rs*10));"5",prob((rs*10));"A",prob((rs*10));"B",prob((rs*5)+(rd));"C",prob((rs*5)+(rd));"D",prob((rs*5)+(rd));"2",prob((rs*5)+(rd));"3")
	if (input == "4" || input == "5" || input == "6" || input == "7")
		output = pick(prob((rs*10));"4",prob((rs*10));"5",prob((rs*10));"A",prob((rs*10));"B",prob((rs*5)+(rd));"C",prob((rs*5)+(rd));"D",prob((rs*5)+(rd));"2",prob((rs*5)+(rd));"3")
	if (input == "0" || input == "1" || input == "2" || input == "3")
		output = pick(prob((rs*10));"8",prob((rs*10));"9",prob((rs*10));"A",prob((rs*10));"B",prob((rs*10)-(rd));"C",prob((rs*10)-(rd));"D",prob((rs*5)+(rd));"E",prob((rs*5)+(rd));"F")
	if (!output) output = "5"
	return output

// HELLO I MAKE BELL CURVES AROUND YOUR DESIRED TARGET
// So a shitty way of replacing gaussian noise.
// input: YOUR TARGET
// rs: RAD STRENGTH
// rd: DURATION
/proc/miniscrambletarget(input,rs,rd)
	var/output = null
	switch(input)
		if("0")
			output = pick(prob((rs*10)+(rd));"0",prob((rs*10)+(rd));"1",prob((rs*10));"2",prob((rs*10)-(rd));"3")
		if("1")
			output = pick(prob((rs*10)+(rd));"0",prob((rs*10)+(rd));"1",prob((rs*10)+(rd));"2",prob((rs*10));"3",prob((rs*10)-(rd));"4")
		if("2")
			output = pick(prob((rs*10));"0",prob((rs*10)+(rd));"1",prob((rs*10)+(rd));"2",prob((rs*10)+(rd));"3",prob((rs*10));"4",prob((rs*10)-(rd));"5")
		if("3")
			output = pick(prob((rs*10)-(rd));"0",prob((rs*10));"1",prob((rs*10)+(rd));"2",prob((rs*10)+(rd));"3",prob((rs*10)+(rd));"4",prob((rs*10));"5",prob((rs*10)-(rd));"6")
		if("4")
			output = pick(prob((rs*10)-(rd));"1",prob((rs*10));"2",prob((rs*10)+(rd));"3",prob((rs*10)+(rd));"4",prob((rs*10)+(rd));"5",prob((rs*10));"6",prob((rs*10)-(rd));"7")
		if("5")
			output = pick(prob((rs*10)-(rd));"2",prob((rs*10));"3",prob((rs*10)+(rd));"4",prob((rs*10)+(rd));"5",prob((rs*10)+(rd));"6",prob((rs*10));"7",prob((rs*10)-(rd));"8")
		if("6")
			output = pick(prob((rs*10)-(rd));"3",prob((rs*10));"4",prob((rs*10)+(rd));"5",prob((rs*10)+(rd));"6",prob((rs*10)+(rd));"7",prob((rs*10));"8",prob((rs*10)-(rd));"9")
		if("7")
			output = pick(prob((rs*10)-(rd));"4",prob((rs*10));"5",prob((rs*10)+(rd));"6",prob((rs*10)+(rd));"7",prob((rs*10)+(rd));"8",prob((rs*10));"9",prob((rs*10)-(rd));"A")
		if("8")
			output = pick(prob((rs*10)-(rd));"5",prob((rs*10));"6",prob((rs*10)+(rd));"7",prob((rs*10)+(rd));"8",prob((rs*10)+(rd));"9",prob((rs*10));"A",prob((rs*10)-(rd));"B")
		if("9")
			output = pick(prob((rs*10)-(rd));"6",prob((rs*10));"7",prob((rs*10)+(rd));"8",prob((rs*10)+(rd));"9",prob((rs*10)+(rd));"A",prob((rs*10));"B",prob((rs*10)-(rd));"C")
		if("10")//A
			output = pick(prob((rs*10)-(rd));"7",prob((rs*10));"8",prob((rs*10)+(rd));"9",prob((rs*10)+(rd));"A",prob((rs*10)+(rd));"B",prob((rs*10));"C",prob((rs*10)-(rd));"D")
		if("11")//B
			output = pick(prob((rs*10)-(rd));"8",prob((rs*10));"9",prob((rs*10)+(rd));"A",prob((rs*10)+(rd));"B",prob((rs*10)+(rd));"C",prob((rs*10));"D",prob((rs*10)-(rd));"E")
		if("12")//C
			output = pick(prob((rs*10)-(rd));"9",prob((rs*10));"A",prob((rs*10)+(rd));"B",prob((rs*10)+(rd));"C",prob((rs*10)+(rd));"D",prob((rs*10));"E",prob((rs*10)-(rd));"F")
		if("13")//D
			output = pick(prob((rs*10)-(rd));"A",prob((rs*10));"B",prob((rs*10)+(rd));"C",prob((rs*10)+(rd));"D",prob((rs*10)+(rd));"E",prob((rs*10));"F")
		if("14")//E
			output = pick(prob((rs*10)-(rd));"B",prob((rs*10));"C",prob((rs*10)+(rd));"D",prob((rs*10)+(rd));"E",prob((rs*10)+(rd));"F")
		if("15")//F
			output = pick(prob((rs*10)-(rd));"C",prob((rs*10));"D",prob((rs*10)+(rd));"E",prob((rs*10)+(rd));"F")

	if(!input || !output) //How did this happen?
		output = "8"

	return output

// /proc/updateappearance has changed behavior, so it's been removed
// Use mob.UpdateAppearance() instead.

// Simpler. Don't specify UI in order for the mob to use its own.
/mob/proc/UpdateAppearance(var/list/UI=null)
	if(istype(src, /mob/living/carbon/human))
		if(UI!=null)
			src.dna.UI=UI
			src.dna.UpdateUI()
		dna.check_integrity()
		var/mob/living/carbon/human/H = src
		H.r_hair   = dna.GetUIValueRange(DNA_UI_HAIR_R,    255)
		H.g_hair   = dna.GetUIValueRange(DNA_UI_HAIR_G,    255)
		H.b_hair   = dna.GetUIValueRange(DNA_UI_HAIR_B,    255)

		H.r_facial = dna.GetUIValueRange(DNA_UI_BEARD_R,   255)
		H.g_facial = dna.GetUIValueRange(DNA_UI_BEARD_G,   255)
		H.b_facial = dna.GetUIValueRange(DNA_UI_BEARD_B,   255)

		H.r_eyes   = dna.GetUIValueRange(DNA_UI_EYES_R,    255)
		H.g_eyes   = dna.GetUIValueRange(DNA_UI_EYES_G,    255)
		H.b_eyes   = dna.GetUIValueRange(DNA_UI_EYES_B,    255)

		H.s_tone   = 35 - dna.GetUIValueRange(DNA_UI_SKIN_TONE, 220) // Value can be negative.

		if (dna.GetUIState(DNA_UI_GENDER))
			H.gender = FEMALE
		else
			H.gender = MALE

		//Hair
		var/hair = dna.GetUIValueRange(DNA_UI_HAIR_STYLE,hair_styles_list.len)
		if((0 < hair) && (hair <= hair_styles_list.len))
			H.h_style = hair_styles_list[hair]

		//Facial Hair
		var/beard = dna.GetUIValueRange(DNA_UI_BEARD_STYLE,facial_hair_styles_list.len)
		if((0 < beard) && (beard <= facial_hair_styles_list.len))
			H.f_style = facial_hair_styles_list[beard]

		H.update_body(0)
		H.update_hair()

		return 1
	else
		return 0

// Used below, simple injection modifier.
/proc/probinj(var/pr, var/inj)
	return prob(pr+inj*pr)

// (Re-)Apply mutations.
// TODO: Turn into a /mob proc, change inj to a bitflag for various forms of differing behavior.
// M: Mob to mess with
// connected: Machine we're in, type unchecked so I doubt it's used beyond monkeying
// flags: See below, bitfield.
#define MUTCHK_FROM_INJECTOR 1
#define MUTCHK_FORCED        2
/proc/domutcheck(var/mob/living/M, var/connected, var/flags)
	if (!M) return

	M.dna.check_integrity()

	M.disabilities = 0
	M.sdisabilities = 0
	var/old_mutations = M.mutations
	M.mutations = list()
	M.pass_flags = 0
//	M.see_in_dark = 2
//	M.see_invisible = 0

	if(PLANT in old_mutations)
		M.mutations.Add(PLANT)
	if(SKELETON in old_mutations)
		M.mutations.Add(SKELETON)
	if(FAT in old_mutations)
		M.mutations.Add(FAT)
	if(HUSK in old_mutations)
		M.mutations.Add(HUSK)

	var/inj    = (flags & MUTCHK_FROM_INJECTOR) == MUTCHK_FROM_INJECTOR
	var/forced = (flags & MUTCHK_FORCED)        == MUTCHK_FORCED

	if(M.dna.GetSEState(NOBREATHBLOCK))
		if(forced || probinj(45,inj) || (mNobreath in old_mutations))
			M << "\blue You feel no need to breathe."
			M.mutations.Add(mNobreath)
	if(M.dna.GetSEState(REMOTEVIEWBLOCK))
		if(forced || probinj(45,inj) || (mRemote in old_mutations))
			M << "\blue Your mind expands"
			M.mutations.Add(mRemote)
			M.verbs += /mob/living/carbon/human/proc/remoteobserve
	if(M.dna.GetSEState(REGENERATEBLOCK))
		if(forced || probinj(45,inj) || (mRegen in old_mutations))
			M << "\blue You feel better"
			M.mutations.Add(mRegen)
	if(M.dna.GetSEState(INCREASERUNBLOCK))
		if(forced || probinj(45,inj) || (mRun in old_mutations))
			M << "\blue Your leg muscles pulsate."
			M.mutations.Add(mRun)
	if(M.dna.GetSEState(REMOTETALKBLOCK))
		if(forced || probinj(45,inj) || (mRemotetalk in old_mutations))
			M << "\blue You expand your mind outwards"
			M.mutations.Add(mRemotetalk)
			M.verbs += /mob/living/carbon/human/proc/remotesay
	if(M.dna.GetSEState(MORPHBLOCK))
		if(forced || probinj(45,inj) || (mMorph in old_mutations))
			M.mutations.Add(mMorph)
			M << "\blue Your skin feels strange"
			M.verbs += /mob/living/carbon/human/proc/morph
	if(M.dna.GetSEState(COLDBLOCK))
		if(!(COLD_RESISTANCE in old_mutations))
			if(forced || probinj(15,inj) || (mHeatres in old_mutations))
				M.mutations.Add(mHeatres)
				M << "\blue Your skin is icy to the touch"
		else
			if(forced || probinj(5,inj) || (mHeatres in old_mutations))
				M.mutations.Add(mHeatres)
				M << "\blue Your skin is icy to the touch"
	if(M.dna.GetSEState(HALLUCINATIONBLOCK))
		if(forced || probinj(45,inj) || (mHallucination in old_mutations))
			M.mutations.Add(mHallucination)
			M << "\red Your mind says 'Hello'"
	if(M.dna.GetSEState(NOPRINTSBLOCK))
		if(forced || probinj(45,inj) || (mFingerprints in old_mutations))
			M.mutations.Add(mFingerprints)
			M << "\blue Your fingers feel numb"
	if(M.dna.GetSEState(SHOCKIMMUNITYBLOCK))
		if(forced || probinj(45,inj) || (mShock in old_mutations))
			M.mutations.Add(mShock)
			M << "\blue Your skin feels strange"
	if(M.dna.GetSEState(SMALLSIZEBLOCK))
		if(forced || probinj(45,inj) || (mSmallsize in old_mutations))
			M << "\blue Your skin feels rubbery"
			M.mutations.Add(mSmallsize)
			M.pass_flags |= 1



	if (M.dna.GetSEState(HULKBLOCK))
		if(forced || probinj(5,inj) || (HULK in old_mutations))
			M << "\blue Your muscles hurt."
			M.mutations.Add(HULK)
	if (M.dna.GetSEState(HEADACHEBLOCK))
		M.disabilities |= EPILEPSY
		M << "\red You get a headache."
	if (M.dna.GetSEState(FAKEBLOCK))
		M << "\red You feel strange."
		if (prob(95))
			if(prob(50))
				randmutb(M)
			else
				randmuti(M)
		else
			randmutg(M)
	if (M.dna.GetSEState(COUGHBLOCK))
		M.disabilities |= COUGHING
		M << "\red You start coughing."
	if (M.dna.GetSEState(CLUMSYBLOCK))
		M << "\red You feel lightheaded."
		M.mutations.Add(CLUMSY)
	if (M.dna.GetSEState(TWITCHBLOCK))
		M.disabilities |= TOURETTES
		M << "\red You twitch."
	if (M.dna.GetSEState(XRAYBLOCK))
		if(forced || probinj(30,inj) || (XRAY in old_mutations))
			M << "\blue The walls suddenly disappear."
//			M.sight |= (SEE_MOBS|SEE_OBJS|SEE_TURFS)
//			M.see_in_dark = 8
//			M.see_invisible = 2
			M.mutations.Add(XRAY)
	if (M.dna.GetSEState(NERVOUSBLOCK))
		M.disabilities |= NERVOUS
		M << "\red You feel nervous."
	if (M.dna.GetSEState(FIREBLOCK))
		if(!(mHeatres in old_mutations))
			if(forced || probinj(30,inj) || (COLD_RESISTANCE in old_mutations))
				M << "\blue Your body feels warm."
				M.mutations.Add(COLD_RESISTANCE)
		else
			if(forced || probinj(5,inj) || (COLD_RESISTANCE in old_mutations))
				M << "\blue Your body feels warm."
				M.mutations.Add(COLD_RESISTANCE)
	if (M.dna.GetSEState(BLINDBLOCK))
		M.sdisabilities |= BLIND
		M << "\red You can't seem to see anything."
	if (M.dna.GetSEState(TELEBLOCK))
		if(forced || probinj(15,inj) || (TK in old_mutations))
			M << "\blue You feel smarter."
			M.mutations.Add(TK)
	if (M.dna.GetSEState(DEAFBLOCK))
		M.sdisabilities |= DEAF
		M.ear_deaf = 1
		M << "\red Its kinda quiet.."
	if (M.dna.GetSEState(GLASSESBLOCK))
		M.disabilities |= NEARSIGHTED
		M << "Your eyes feel weird..."

	/* If you want the new mutations to work, UNCOMMENT THIS.
	if(istype(M, /mob/living/carbon))
		for (var/datum/mutations/mut in global_mutations)
			mut.check_mutation(M)
	*/

//////////////////////////////////////////////////////////// Monkey Block
	if (M.dna.GetSEState(MONKEYBLOCK) && istype(M, /mob/living/carbon/human))
	// human > monkey
		var/mob/living/carbon/human/H = M
		H.monkeyizing = 1
		var/list/implants = list() //Try to preserve implants.
		for(var/obj/item/weapon/implant/W in H)
			implants += W
			W.loc = null

		if(!connected)
			for(var/obj/item/W in (H.contents-implants))
				if (W==H.w_uniform) // will be teared
					continue
				H.drop_from_inventory(W)
			M.monkeyizing = 1
			M.canmove = 0
			M.icon = null
			M.invisibility = 101
			var/atom/movable/overlay/animation = new( M.loc )
			animation.icon_state = "blank"
			animation.icon = 'icons/mob/mob.dmi'
			animation.master = src
			flick("h2monkey", animation)
			sleep(48)
			del(animation)


		var/mob/living/carbon/monkey/O = null
		if(H.species.primitive)
			O = new H.species.primitive(src)
		else
			H.gib() //Trying to change the species of a creature with no primitive var set is messy.
			return

		if(M)
			if (M.dna)
				O.dna = M.dna
				M.dna = null

			if (M.suiciding)
				O.suiciding = M.suiciding
				M.suiciding = null


		for(var/datum/disease/D in M.viruses)
			O.viruses += D
			D.affected_mob = O
			M.viruses -= D


		for(var/obj/T in (M.contents-implants))
			del(T)

		O.loc = M.loc

		if(M.mind)
			M.mind.transfer_to(O)	//transfer our mind to the cute little monkey

		if (connected) //inside dna thing
			var/obj/machinery/dna_scannernew/C = connected
			O.loc = C
			C.occupant = O
			connected = null
		O.real_name = text("monkey ([])",copytext(md5(M.real_name), 2, 6))
		O.take_overall_damage(M.getBruteLoss() + 40, M.getFireLoss())
		O.adjustToxLoss(M.getToxLoss() + 20)
		O.adjustOxyLoss(M.getOxyLoss())
		O.stat = M.stat
		O.a_intent = "hurt"
		for (var/obj/item/weapon/implant/I in implants)
			I.loc = O
			I.implanted = O
//		O.update_icon = 1	//queue a full icon update at next life() call
		del(M)
		return

	if (!M.dna.GetSEState(MONKEYBLOCK) && !istype(M, /mob/living/carbon/human))
	// monkey > human,
		var/mob/living/carbon/monkey/Mo = M
		Mo.monkeyizing = 1
		var/list/implants = list() //Still preserving implants
		for(var/obj/item/weapon/implant/W in Mo)
			implants += W
			W.loc = null
		if(!connected)
			for(var/obj/item/W in (Mo.contents-implants))
				Mo.drop_from_inventory(W)
			M.monkeyizing = 1
			M.canmove = 0
			M.icon = null
			M.invisibility = 101
			var/atom/movable/overlay/animation = new( M.loc )
			animation.icon_state = "blank"
			animation.icon = 'icons/mob/mob.dmi'
			animation.master = src
			flick("monkey2h", animation)
			sleep(48)
			del(animation)

		var/mob/living/carbon/human/O = new( src )
		if(Mo.greaterform)
			O.set_species(Mo.greaterform)

		if (M.dna.GetUIState(DNA_UI_GENDER))
			O.gender = FEMALE
		else
			O.gender = MALE

		if (M)
			if (M.dna)
				O.dna = M.dna
				M.dna = null

			if (M.suiciding)
				O.suiciding = M.suiciding
				M.suiciding = null

		for(var/datum/disease/D in M.viruses)
			O.viruses += D
			D.affected_mob = O
			M.viruses -= D

		//for(var/obj/T in M)
		//	del(T)

		O.loc = M.loc

		if(M.mind)
			M.mind.transfer_to(O)	//transfer our mind to the human

		if (connected) //inside dna thing
			var/obj/machinery/dna_scannernew/C = connected
			O.loc = C
			C.occupant = O
			connected = null

		var/i
		while (!i)
			var/randomname
			if (O.gender == MALE)
				randomname = capitalize(pick(first_names_male) + " " + capitalize(pick(last_names)))
			else
				randomname = capitalize(pick(first_names_female) + " " + capitalize(pick(last_names)))
			if (findname(randomname))
				continue
			else
				O.real_name = randomname
				i++
		O.UpdateAppearance()
		O.take_overall_damage(M.getBruteLoss(), M.getFireLoss())
		O.adjustToxLoss(M.getToxLoss())
		O.adjustOxyLoss(M.getOxyLoss())
		O.stat = M.stat
		for (var/obj/item/weapon/implant/I in implants)
			I.loc = O
			I.implanted = O
//		O.update_icon = 1	//queue a full icon update at next life() call
		del(M)
		return
//////////////////////////////////////////////////////////// Monkey Block
	if(M)
		M.update_icon = 1	//queue a full icon update at next life() call
	return null
/////////////////////////// DNA MISC-PROCS