/////////////////////////// DNA DATUM
/datum/dna
	var/unique_enzymes = null
	var/struc_enzymes = null
	var/uni_identity = null
	var/b_type = "A+"
	var/mutantrace = null  //The type of mutant race the player is if applicable (i.e. potato-man)
	var/real_name //Stores the real name of the person who originally got this dna datum. Used primarely for changelings,

/datum/dna/proc/check_integrity(var/mob/living/carbon/human/character)
	if(character)
		if(length(uni_identity) != 39)
			//Lazy.
			var/temp

			//Hair
			var/hair	= 0
			if(!character.h_style)
				character.h_style = "Skinhead"

			var/hrange = round(4095 / hair_styles_list.len)
			var/index = hair_styles_list.Find(character.h_style)
			if(index)
				hair = index * hrange - rand(1,hrange-1)

			//Facial Hair
			var/beard	= 0
			if(!character.f_style)
				character.f_style = "Shaved"

			var/f_hrange = round(4095 / facial_hair_styles_list.len)
			index = facial_hair_styles_list.Find(character.f_style)
			if(index)
				beard = index * f_hrange - rand(1,f_hrange-1)

			temp = add_zero2(num2hex((character.r_hair),1), 3)
			temp += add_zero2(num2hex((character.b_hair),1), 3)
			temp += add_zero2(num2hex((character.g_hair),1), 3)
			temp += add_zero2(num2hex((character.r_facial),1), 3)
			temp += add_zero2(num2hex((character.b_facial),1), 3)
			temp += add_zero2(num2hex((character.g_facial),1), 3)
			temp += add_zero2(num2hex(((character.s_tone + 220) * 16),1), 3)
			temp += add_zero2(num2hex((character.r_eyes),1), 3)
			temp += add_zero2(num2hex((character.g_eyes),1), 3)
			temp += add_zero2(num2hex((character.b_eyes),1), 3)

			var/gender

			if (character.gender == MALE)
				gender = add_zero2(num2hex((rand(1,(2050+BLOCKADD))),1), 3)
			else
				gender = add_zero2(num2hex((rand((2051+BLOCKADD),4094)),1), 3)

			temp += gender
			temp += add_zero2(num2hex((beard),1), 3)
			temp += add_zero2(num2hex((hair),1), 3)

			uni_identity = temp
		if(length(struc_enzymes)!= 3*STRUCDNASIZE)
			var/mutstring = ""
			for(var/i = 1, i <= STRUCDNASIZE, i++)
				mutstring += add_zero2(num2hex(rand(1,1024)),3)

			struc_enzymes = mutstring
		if(length(unique_enzymes) != 32)
			unique_enzymes = md5(character.real_name)
	else
		if(length(uni_identity) != 39) uni_identity = "00600200A00E0110148FC01300B0095BD7FD3F4"
		if(length(struc_enzymes)!= 3*STRUCDNASIZE) struc_enzymes = "43359156756131E13763334D1C369012032164D4FE4CD61544B6C03F251B6C60A42821D26BA3B0FD6"

/datum/dna/proc/ready_dna(mob/living/carbon/human/character)
	var/temp

	//Hair
	var/hair	= 0
	if(!character.h_style)
		character.h_style = "Bald"

	var/hrange = round(4095 / hair_styles_list.len)
	var/index = hair_styles_list.Find(character.h_style)
	if(index)
		hair = index * hrange - rand(1,hrange-1)

	//Facial Hair
	var/beard	= 0
	if(!character.f_style)
		character.f_style = "Shaved"

	var/f_hrange = round(4095 / facial_hair_styles_list.len)
	index = facial_hair_styles_list.Find(character.f_style)
	if(index)
		beard = index * f_hrange - rand(1,f_hrange-1)

	temp = add_zero2(num2hex((character.r_hair),1), 3)
	temp += add_zero2(num2hex((character.b_hair),1), 3)
	temp += add_zero2(num2hex((character.g_hair),1), 3)
	temp += add_zero2(num2hex((character.r_facial),1), 3)
	temp += add_zero2(num2hex((character.b_facial),1), 3)
	temp += add_zero2(num2hex((character.g_facial),1), 3)
	temp += add_zero2(num2hex(((character.s_tone + 220) * 16),1), 3)
	temp += add_zero2(num2hex((character.r_eyes),1), 3)
	temp += add_zero2(num2hex((character.g_eyes),1), 3)
	temp += add_zero2(num2hex((character.b_eyes),1), 3)

	var/gender

	if (character.gender == MALE)
		gender = add_zero2(num2hex((rand(1,(2050+BLOCKADD))),1), 3)
	else
		gender = add_zero2(num2hex((rand((2051+BLOCKADD),4094)),1), 3)

	temp += gender
	temp += add_zero2(num2hex((beard),1), 3)
	temp += add_zero2(num2hex((hair),1), 3)

	uni_identity = temp

	var/mutstring = ""
	for(var/i = 1, i <= STRUCDNASIZE, i++)
		mutstring += add_zero2(num2hex(rand(1,1024)),3)


	struc_enzymes = mutstring

	unique_enzymes = md5(character.real_name)
	reg_dna[unique_enzymes] = character.real_name

/////////////////////////// DNA DATUM

/////////////////////////// DNA HELPER-PROCS
/proc/getleftblocks(input,blocknumber,blocksize)
	var/string

	if (blocknumber > 1)
		string = copytext(input,1,((blocksize*blocknumber)-(blocksize-1)))
		return string
	else
		return null

/proc/getrightblocks(input,blocknumber,blocksize)
	var/string
	if (blocknumber < (length(input)/blocksize))
		string = copytext(input,blocksize*blocknumber+1,length(input)+1)
		return string
	else
		return null

/proc/getblockstring(input,block,subblock,blocksize,src,ui) // src is probably used here just for urls; ui is 1 when requesting for the unique identifier screen, 0 for structural enzymes screen
	var/string
	var/subpos = 1 // keeps track of the current sub block
	var/blockpos = 1 // keeps track of the current block


	for(var/i = 1, i <= length(input), i++) // loop through each letter

		var/pushstring

		if(subpos == subblock && blockpos == block) // if the current block/subblock is selected, mark it
			pushstring = "</font color><b>[copytext(input, i, i+1)]</b><font color='blue'>"
		else
			if(ui) //This is for allowing block clicks to be differentiated
				pushstring = "<a href='?src=\ref[src];uimenuset=[num2text(blockpos)];uimenusubset=[num2text(subpos)]'>[copytext(input, i, i+1)]</a>"
			else
				pushstring = "<a href='?src=\ref[src];semenuset=[num2text(blockpos)];semenusubset=[num2text(subpos)]'>[copytext(input, i, i+1)]</a>"

		string += pushstring // push the string to the return string

		if(subpos >= blocksize) // add a line break for every block
			string += " </font color><font color='#285B5B'>|</font color><font color='blue'> "
			subpos = 0
			blockpos++

		subpos++

	return string


/proc/getblock(input,blocknumber,blocksize)
	var/result
	result = copytext(input ,(blocksize*blocknumber)-(blocksize-1),(blocksize*blocknumber)+1)
	return result

/proc/getblockbuffer(input,blocknumber,blocksize)
	var/result[3]
	var/block = copytext(input ,(blocksize*blocknumber)-(blocksize-1),(blocksize*blocknumber)+1)
	for(var/i = 1, i <= 3, i++)
		result[i] = copytext(block, i, i+1)
	return result

/proc/setblock(istring, blocknumber, replacement, blocksize)
	if(!blocknumber)
		return istring
	if(!istring || !replacement || !blocksize)	return 0
	var/result = getleftblocks(istring, blocknumber, blocksize) + replacement + getrightblocks(istring, blocknumber, blocksize)
	return result

/proc/add_zero2(t, u)
	var/temp1
	while (length(t) < u)
		t = "0[t]"
	temp1 = t
	if (length(t) > u)
		temp1 = copytext(t,2,u+1)
	return temp1

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

//Instead of picking a value far from the input, this will pick values closer to it.
//Sorry for the block of code, but it's more efficient then calling text2hex -> loop -> hex2text
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

/proc/isblockon(hnumber, bnumber , var/UI = 0)

	var/temp2
	temp2 = hex2num(hnumber)

	if(UI)
		if(temp2 >= 2050)
			return 1
		else
			return 0

	if (bnumber == HULKBLOCK || bnumber == TELEBLOCK || bnumber == NOBREATHBLOCK || bnumber == NOPRINTSBLOCK || bnumber == SMALLSIZEBLOCK || bnumber == SHOCKIMMUNITYBLOCK)
		if (temp2 >= 3500 + BLOCKADD)
			return 1
		else
			return 0
	if (bnumber == XRAYBLOCK || bnumber == FIREBLOCK || bnumber == REMOTEVIEWBLOCK || bnumber == REGENERATEBLOCK || bnumber == INCREASERUNBLOCK || bnumber == REMOTETALKBLOCK || bnumber == MORPHBLOCK)
		if (temp2 >= 3050 + BLOCKADD)
			return 1
		else
			return 0


	if (temp2 >= 2050 + BLOCKADD)
		return 1
	else
		return 0

/proc/ismuton(var/block,var/mob/M)
	return isblockon(getblock(M.dna.struc_enzymes, block,3),block)

/proc/togglemut(mob/M as mob, var/block)
	if(!M)	return
	var/newdna
	M.dna.check_integrity()
	newdna = setblock(M.dna.struc_enzymes,block,toggledblock(getblock(M.dna.struc_enzymes,block,3)),3)
	M.dna.struc_enzymes = newdna
	return

/proc/randmutb(mob/M as mob)
	if(!M)	return
	var/num
	var/newdna
	num = pick(GLASSESBLOCK,COUGHBLOCK,FAKEBLOCK,NERVOUSBLOCK,CLUMSYBLOCK,TWITCHBLOCK,HEADACHEBLOCK,BLINDBLOCK,DEAFBLOCK,HALLUCINATIONBLOCK)
	M.dna.check_integrity()
	newdna = setblock(M.dna.struc_enzymes,num,toggledblock(getblock(M.dna.struc_enzymes,num,3)),3)
	M.dna.struc_enzymes = newdna
	return

/proc/randmutg(mob/M as mob)
	if(!M)	return
	var/num
	var/newdna
	num = pick(HULKBLOCK,XRAYBLOCK,FIREBLOCK,TELEBLOCK,NOBREATHBLOCK,REMOTEVIEWBLOCK,REGENERATEBLOCK,INCREASERUNBLOCK,REMOTETALKBLOCK,MORPHBLOCK,COLDBLOCK,NOPRINTSBLOCK,SHOCKIMMUNITYBLOCK,SMALLSIZEBLOCK)
	M.dna.check_integrity()
	newdna = setblock(M.dna.struc_enzymes,num,toggledblock(getblock(M.dna.struc_enzymes,num,3)),3)
	M.dna.struc_enzymes = newdna
	return

/proc/scramble(var/type, mob/M as mob, var/p)
	if(!M)	return
	M.dna.check_integrity()
	if(type)
		for(var/i = 1, i <= STRUCDNASIZE-1, i++)
			if(prob(p))
				M.dna.uni_identity = setblock(M.dna.uni_identity, i, add_zero2(num2hex(rand(1,4095), 1), 3), 3)
		updateappearance(M, M.dna.uni_identity)

	else
		for(var/i = 1, i <= STRUCDNASIZE-1, i++)
			if(prob(p))
				M.dna.struc_enzymes = setblock(M.dna.struc_enzymes, i, add_zero2(num2hex(rand(1,4095), 1), 3), 3)
		domutcheck(M, null)
	return

/proc/randmuti(mob/M as mob)
	if(!M)	return
	var/num
	var/newdna
	num = rand(1,UNIDNASIZE)
	M.dna.check_integrity()
	newdna = setblock(M.dna.uni_identity,num,add_zero2(num2hex(rand(1,4095),1),3),3)
	M.dna.uni_identity = newdna
	return

/proc/toggledblock(hnumber) //unused
	var/temp3
	var/chtemp
	temp3 = hex2num(hnumber)
	if (temp3 < 2050)
		chtemp = rand(2050,4095)
		return add_zero2(num2hex(chtemp,1),3)
	else
		chtemp = rand(1,2049)
		return add_zero2(num2hex(chtemp,1),3)
/////////////////////////// DNA HELPER-PROCS

/////////////////////////// DNA MISC-PROCS
/proc/updateappearance(mob/M as mob , structure)
	if(istype(M, /mob/living/carbon/human))
		M.dna.check_integrity()
		var/mob/living/carbon/human/H = M
		H.r_hair = hex2num(getblock(structure,1,3))
		H.b_hair = hex2num(getblock(structure,2,3))
		H.g_hair = hex2num(getblock(structure,3,3))
		H.r_facial = hex2num(getblock(structure,4,3))
		H.b_facial = hex2num(getblock(structure,5,3))
		H.g_facial = hex2num(getblock(structure,6,3))
		H.s_tone = round(((hex2num(getblock(structure,7,3)) / 16) - 220))
		H.r_eyes = hex2num(getblock(structure,8,3))
		H.g_eyes = hex2num(getblock(structure,9,3))
		H.b_eyes = hex2num(getblock(structure,10,3))

		if (isblockon(getblock(structure, 11,3),11 , 1))
			H.gender = FEMALE
		else
			H.gender = MALE

		//Hair
		var/hairnum = hex2num(getblock(structure,13,3))
		var/index = round(1 +(hairnum / 4096)*hair_styles_list.len)
		if((0 < index) && (index <= hair_styles_list.len))
			H.h_style = hair_styles_list[index]

		//Facial Hair
		var/beardnum = hex2num(getblock(structure,12,3))
		index = round(1 +(beardnum / 4096)*facial_hair_styles_list.len)
		if((0 < index) && (index <= facial_hair_styles_list.len))
			H.f_style = facial_hair_styles_list[index]

		H.update_body(0)
		H.update_hair()

		return 1
	else
		return 0

/proc/probinj(var/pr, var/inj)
	return prob(pr+inj*pr)

/proc/domutcheck(mob/living/M as mob, connected, inj)
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

	if(ismuton(NOBREATHBLOCK,M))
		if(probinj(45,inj) || (mNobreath in old_mutations))
			M << "\blue You feel no need to breathe."
			M.mutations.Add(mNobreath)
	if(ismuton(REMOTEVIEWBLOCK,M))
		if(probinj(45,inj) || (mRemote in old_mutations))
			M << "\blue Your mind expands"
			M.mutations.Add(mRemote)
			M.verbs += /mob/living/carbon/human/proc/remoteobserve
	if(ismuton(REGENERATEBLOCK,M))
		if(probinj(45,inj) || (mRegen in old_mutations))
			M << "\blue You feel better"
			M.mutations.Add(mRegen)
	if(ismuton(INCREASERUNBLOCK,M))
		if(probinj(45,inj) || (mRun in old_mutations))
			M << "\blue Your leg muscles pulsate."
			M.mutations.Add(mRun)
	if(ismuton(REMOTETALKBLOCK,M))
		if(probinj(45,inj) || (mRemotetalk in old_mutations))
			M << "\blue You expand your mind outwards"
			M.mutations.Add(mRemotetalk)
			M.verbs += /mob/living/carbon/human/proc/remotesay
	if(ismuton(MORPHBLOCK,M))
		if(probinj(45,inj) || (mMorph in old_mutations))
			M.mutations.Add(mMorph)
			M << "\blue Your skin feels strange"
			M.verbs += /mob/living/carbon/human/proc/morph
	if(ismuton(COLDBLOCK,M))
		if(!(COLD_RESISTANCE in old_mutations))
			if(probinj(15,inj) || (mHeatres in old_mutations))
				M.mutations.Add(mHeatres)
				M << "\blue Your skin is icy to the touch"
		else
			if(probinj(5,inj) || (mHeatres in old_mutations))
				M.mutations.Add(mHeatres)
				M << "\blue Your skin is icy to the touch"
	if(ismuton(HALLUCINATIONBLOCK,M))
		if(probinj(45,inj) || (mHallucination in old_mutations))
			M.mutations.Add(mHallucination)
			M << "\red Your mind says 'Hello'"
	if(ismuton(NOPRINTSBLOCK,M))
		if(probinj(45,inj) || (mFingerprints in old_mutations))
			M.mutations.Add(mFingerprints)
			M << "\blue Your fingers feel numb"
	if(ismuton(SHOCKIMMUNITYBLOCK,M))
		if(probinj(45,inj) || (mShock in old_mutations))
			M.mutations.Add(mShock)
			M << "\blue Your skin feels strange"
	if(ismuton(SMALLSIZEBLOCK,M))
		if(probinj(45,inj) || (mSmallsize in old_mutations))
			M << "\blue Your skin feels rubbery"
			M.mutations.Add(mSmallsize)
			M.pass_flags |= 1



	if (isblockon(getblock(M.dna.struc_enzymes, HULKBLOCK,3),HULKBLOCK))
		if(probinj(5,inj) || (HULK in old_mutations))
			M << "\blue Your muscles hurt."
			M.mutations.Add(HULK)
	if (isblockon(getblock(M.dna.struc_enzymes, HEADACHEBLOCK,3),HEADACHEBLOCK))
		M.disabilities |= EPILEPSY
		M << "\red You get a headache."
	if (isblockon(getblock(M.dna.struc_enzymes, FAKEBLOCK,3),FAKEBLOCK))
		M << "\red You feel strange."
		if (prob(95))
			if(prob(50))
				randmutb(M)
			else
				randmuti(M)
		else
			randmutg(M)
	if (isblockon(getblock(M.dna.struc_enzymes, COUGHBLOCK,3),COUGHBLOCK))
		M.disabilities |= COUGHING
		M << "\red You start coughing."
	if (isblockon(getblock(M.dna.struc_enzymes, CLUMSYBLOCK,3),CLUMSYBLOCK))
		M << "\red You feel lightheaded."
		M.mutations.Add(CLUMSY)
	if (isblockon(getblock(M.dna.struc_enzymes, TWITCHBLOCK,3),TWITCHBLOCK))
		M.disabilities |= TOURETTES
		M << "\red You twitch."
	if (isblockon(getblock(M.dna.struc_enzymes, XRAYBLOCK,3),XRAYBLOCK))
		if(probinj(30,inj) || (XRAY in old_mutations))
			M << "\blue The walls suddenly disappear."
//			M.sight |= (SEE_MOBS|SEE_OBJS|SEE_TURFS)
//			M.see_in_dark = 8
//			M.see_invisible = 2
			M.mutations.Add(XRAY)
	if (isblockon(getblock(M.dna.struc_enzymes, NERVOUSBLOCK,3),NERVOUSBLOCK))
		M.disabilities |= NERVOUS
		M << "\red You feel nervous."
	if (isblockon(getblock(M.dna.struc_enzymes, FIREBLOCK,3),FIREBLOCK))
		if(!(mHeatres in old_mutations))
			if(probinj(30,inj) || (COLD_RESISTANCE in old_mutations))
				M << "\blue Your body feels warm."
				M.mutations.Add(COLD_RESISTANCE)
		else
			if(probinj(5,inj) || (COLD_RESISTANCE in old_mutations))
				M << "\blue Your body feels warm."
				M.mutations.Add(COLD_RESISTANCE)
	if (isblockon(getblock(M.dna.struc_enzymes, BLINDBLOCK,3),BLINDBLOCK))
		M.sdisabilities |= BLIND
		M << "\red You can't seem to see anything."
	if (isblockon(getblock(M.dna.struc_enzymes, TELEBLOCK,3),TELEBLOCK))
		if(probinj(15,inj) || (TK in old_mutations))
			M << "\blue You feel smarter."
			M.mutations.Add(TK)
	if (isblockon(getblock(M.dna.struc_enzymes, DEAFBLOCK,3),DEAFBLOCK))
		M.sdisabilities |= DEAF
		M.ear_deaf = 1
		M << "\red Its kinda quiet.."
	if (isblockon(getblock(M.dna.struc_enzymes, GLASSESBLOCK,3),GLASSESBLOCK))
		M.disabilities |= NEARSIGHTED
		M << "Your eyes feel weird..."

	/* If you want the new mutations to work, UNCOMMENT THIS.
	if(istype(M, /mob/living/carbon))
		for (var/datum/mutations/mut in global_mutations)
			mut.check_mutation(M)
	*/

//////////////////////////////////////////////////////////// Monkey Block
	if (isblockon(getblock(M.dna.struc_enzymes, MONKEYBLOCK,3),MONKEYBLOCK) && istype(M, /mob/living/carbon/human))
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

	if (!isblockon(getblock(M.dna.struc_enzymes, MONKEYBLOCK,3),MONKEYBLOCK) && !istype(M, /mob/living/carbon/human))
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

		if (isblockon(getblock(M.dna.uni_identity, 11,3),11))
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
		updateappearance(O,O.dna.uni_identity)
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