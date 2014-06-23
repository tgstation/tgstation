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
	var/block = pick(bad_blocks)
	M.dna.SetSEState(block, 1)

// Give Random Good Mutation to M
/proc/randmutg(var/mob/living/M)
	if(!M) return
	M.dna.check_integrity()
	var/block = pick(good_blocks)
	M.dna.SetSEState(block, 1)

// Random Appearance Mutation
/proc/randmuti(var/mob/living/M)
	if(!M) return
	M.dna.check_integrity()
	M.dna.SetUIValue(rand(1,DNA_UI_LENGTH),rand(1,4095))

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
		for(var/i = 1, i <= DNA_SE_LENGTH-1, i++)
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


/proc/query_genes(var/notflags = 0, var/flags = 0, var/genetype = -1)
	. = list()
	for(var/datum/dna/gene/gene in dna_genes)
		if(!gene.block) continue
		if(genetype>-1 && gene.genetype!=genetype) continue
		if(flags!=0 && !(gene.flags & flags)) continue
		if(notflags!=0 && (gene.flags & notflags)) continue
		. += gene.block