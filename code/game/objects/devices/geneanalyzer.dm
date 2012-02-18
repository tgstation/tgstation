/obj/item/device/geneticsanalyzer
	name = "Genetics Analyser"
	icon = 'device.dmi'
	icon_state = "genetics"
	w_class = 2

/obj/item/device/geneticsanalyzer/attack(mob/M as mob, mob/user as mob)
	for(var/mob/O in viewers(M, null))
		O.show_message(text("\red [] has analyzed []'s genetic code!", user, M), 1)
		//Foreach goto(67)
	user.show_message(text("\blue Analyzing Results for [M]: [M.dna.struc_enzymes]\n\t"), 1)
	user.show_message(text("\blue \t Epilepsy: [isblockon(getblock(M.dna.struc_enzymes, HEADACHEBLOCK,3),HEADACHEBLOCK) ? "Yes" : "No"]"), 1)
	user.show_message(text("\blue \t Cough: [isblockon(getblock(M.dna.struc_enzymes, COUGHBLOCK,3),COUGHBLOCK) ? "Yes" : "No"]"), 1)
	user.show_message(text("\blue \t Clumsy: [isblockon(getblock(M.dna.struc_enzymes, CLUMSYBLOCK,3),CLUMSYBLOCK) ? "Yes" : "No"]"), 1)
	user.show_message(text("\blue \t Twitch: [isblockon(getblock(M.dna.struc_enzymes, TWITCHBLOCK,3),TWITCHBLOCK) ? "Yes" : "No"]"), 1)
	user.show_message(text("\blue \t Nervous: [isblockon(getblock(M.dna.struc_enzymes, NERVOUSBLOCK,3),NERVOUSBLOCK) ? "Yes" : "No"]"), 1)
	user.show_message(text("\blue \t Blind: [isblockon(getblock(M.dna.struc_enzymes, BLINDBLOCK,3),BLINDBLOCK) ? "Yes" : "No"]"), 1)
	user.show_message(text("\blue \t Deaf: [isblockon(getblock(M.dna.struc_enzymes, DEAFBLOCK,3),DEAFBLOCK) ? "Yes" : "No"]"), 1)
	user.show_message(text("\blue \t Requires Glasses: [isblockon(getblock(M.dna.struc_enzymes, GLASSESBLOCK,3),GLASSESBLOCK) ? "Yes" : "No"]"), 1)

	var/unknow = 0
	var/list/unknowns = list(HULKBLOCK,TELEBLOCK,FIREBLOCK,XRAYBLOCK,NOBREATHBLOCK,REMOTEVIEWBLOCK,REGENERATEBLOCK,INCREASERUNBLOCK,REMOTETALKBLOCK,MORPHBLOCK,BLENDBLOCK,HALLUCINATIONBLOCK,NOPRINTSBLOCK,SHOCKIMMUNITYBLOCK,SMALLSIZEBLOCK)
	for(var/unknown in unknowns)
		if(isblockon(getblock(M.dna.struc_enzymes, unknown,3),unknown))
			unknow += 1
	user.show_message(text("\blue \t Unknown Anomalies: [unknow]"))