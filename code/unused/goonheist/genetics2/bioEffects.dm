//////////////////
// DISABILITIES //
//////////////////

// Totally Crippling

/datum/bioEffect/blind
	name = "Blindness"
	desc = "Disconnects the optic nerves from the brain, rendering the subject unable to see."
	id = "blind"
	effectType = effectTypeDisability
	isBad = 1
	probability = 20
	msgGain = "You can't seem to see anything!"
	msgLose = "Your vision returns!"
	reclaim_fail = 15
	lockedGaps = 1
	lockedDiff = 4
	lockedChars = list("G","C","A","T")
	lockedTries = 10

	OnLife()
		if(hasvar(owner, "blinded") && hasvar(owner, "glasses"))
			if(!istype(owner:glasses, /obj/item/clothing/glasses/visor))
				owner:blinded = 1
		return

/datum/bioEffect/mute
	name = "Frontal Gyrus Suspension"
	desc = "Completley shuts down the speech center of the subject's brain."
	id = "mute"
	effectType = effectTypeDisability
	isBad = 1
	probability = 75
	msgGain = "You feel unable to express yourself at all."
	msgLose = "You feel able to speak freely again."
	reclaim_fail = 15
	lockedGaps = 1
	lockedDiff = 4
	lockedChars = list("G","C","A","T")
	lockedTries = 10

/datum/bioEffect/deaf
	name = "Deafness"
	desc = "Diminishes the subject's tympanic membrane, rendering them unable to hear."
	id = "deaf"
	effectType = effectTypeDisability
	isBad = 1
	probability = 50
	blockCount = 4
	msgGain = "It's quiet. Too quiet."
	msgLose = "You can hear again!"
	reclaim_fail = 15
	lockedGaps = 1
	lockedDiff = 4
	lockedChars = list("G","C","A","T")
	lockedTries = 10

// Harmful to others as well as self

/datum/bioEffect/radioactive
	name = "Radioactive"
	desc = "The subject suffers from constant radiation sickness and causes the same on nearby organics."
	id = "radioactive"
	effectType = effectTypeDisability
	probability = 50
	blockCount = 3
	blockGaps = 3
	isBad = 1
	msgGain = "You feel a strange sickness permeate your whole body."
	msgLose = "You no longer feel awful and sick all over."
	reclaim_fail = 15

	OnLife()
		owner.radiation = max(owner.radiation, 20)
		for(var/mob/living/L in range(1, owner))
			if(L == owner) continue
			L << "\red You are enveloped by a soft green glow emanating from [owner]."
			L.radiation += 5
		return

	OnMobDraw()
		if (hasvar(owner, "lying"))
			owner.overlays += image("icon" = 'genetics.dmi', "icon_state" = "rads[!owner.lying ? "_s" : "_l"]")
		return

// Other disabilities

/datum/bioEffect/clumsy
	name = "Dyspraxia"
	desc = "Hinders transmissions in the subject's nervous system, causing poor motor skills."
	id = "clumsy"
	effectType = effectTypeDisability
	isBad = 1
	msgGain = "You feel kind of off-balance and disoriented."
	msgLose = "You feel well co-ordinated again."
	reclaim_fail = 15

/datum/bioEffect/fat
	name = "Obesity"
	desc = "Greatly slows the subject's metabolism, enabling greater buildup of lipid tissue."
	id = "fat"
	effectType = effectTypeDisability
	isBad = 1
	msgGain = "You feel blubbery and lethargic!"
	msgLose = "You feel fit!"
	reclaim_fail = 15

/datum/bioEffect/dwarf
	name = "Dwarfism"
	desc = "Greatly reduces the overall size of the subject, resulting in markedly dimished height."
	id = "dwarf"
	effectType = effectTypeDisability
	isBad = 1
	msgGain = "Did everything just get bigger?"
	msgLose = "You feel tall!"
	reclaim_fail = 15
	mob_exclusive = /mob/living/carbon/human/

	OnAdd()
		if (ishuman(owner))
			if (owner:mutantrace)
				holder.RemoveEffect(id)
				return
			owner:mutantrace = new /datum/mutantrace/dwarf(owner)
		return

	OnRemove()
		if (ishuman(owner))
			if (istype(owner:mutantrace, /datum/mutantrace/dwarf))
				owner:mutantrace = null
		return

	OnLife()
		if (ishuman(owner))
			if(!istype(owner:mutantrace, /datum/mutantrace/dwarf))
				holder.RemoveEffect(id)
		return


/datum/bioEffect/shortsighted
	name = "Diminished Optic Nerves"
	desc = "Reduces the subject's ability to see clearly without glasses or other visual aids."
	id = "bad_eyesight"
	effectType = effectTypeDisability
	isBad = 1
	msgGain = "Your vision blurs."
	msgLose = "Your vision is no longer blurry."
	reclaim_fail = 15

	OnLife()
		if(owner.client && hasvar(owner, "blind") && hasvar(owner, "stat") && hasvar(owner, "blinded") && hasvar(owner, "glasses") && hasvar(owner, "hud_used"))
			if(!owner:blinded)
				if(!istype(owner:glasses, /obj/item/clothing/glasses/regular))
					for(var/obj/screen/O in owner:hud_used.vimpaired)
						O.add_to_client(owner:client)
		return

/datum/bioEffect/epilepsy
	name = "Epilepsy"
	desc = "Causes damage to the subject's brain structure, resulting in occasional siezures from brain misfires."
	id = "epilepsy"
	effectType = effectTypeDisability
	isBad = 1
	probability = 75
	blockCount = 3
	msgGain = "Your thoughts become disorderly and hard to control."
	msgLose = "Your mind regains its former clarity."
	reclaim_fail = 15

	OnLife()
		if (prob(1) && owner:paralysis < 1)
			owner:visible_message("\red <B>[owner] starts having a seizure!", "\red You have a seizure!")
			owner:paralysis = max(2, owner:paralysis)
			owner:make_jittery(100)
		return

/datum/bioEffect/tourettes
	name = "Tourettes"
	desc = "Alters the subject's brain structure, causing periodic involuntary movements and outbursts."
	id = "tourettes"
	effectType = effectTypeDisability
	isBad = 1
	probability = 50
	msgGain = "You feel like you can't control your actions fully."
	msgLose = "You feel in full control of yourself once again."
	reclaim_fail = 15

	OnLife()
		if ((prob(10) && owner:paralysis <= 1 && owner:r_Tourette < 1))
			owner:stunned = max(10, owner:stunned)
			spawn( 0 )
				switch(rand(1, 3))
					if(1 to 2)
						owner:emote("twitch")
					if(3)
						if (owner:client)
							var/enteredtext = winget(owner, "mainwindow.input", "text")
							if ((copytext(enteredtext,1,6) == "say \"") && length(enteredtext) > 5)
								winset(owner, "mainwindow.input", "text=\"\"")
								if(prob(50))
									owner:say(uppertext(copytext(enteredtext,6,0)))
								else
									owner:say(copytext(enteredtext,6,0))
		return

/datum/bioEffect/cough
	name = "Chronic Cough"
	desc = "Enhances the sensetivity of nerves in the subject's throat, causing periodic coughing fits."
	id = "cough"
	effectType = effectTypeDisability
	isBad = 1
	msgGain = "You feel an irritating itch in your throat."
	msgLose = "Your throat clears up."
	reclaim_fail = 15

	OnLife()
		if ((prob(5) && owner:paralysis <= 1 && owner:r_ch_cou < 1))
			owner:drop_item()
			spawn (0)
				owner:emote("cough")
				return
		return

/////////////////////////
// SPEECH MANIPULATORS //
/////////////////////////

/datum/bioEffect/stutter
	name = "Frontal Gyrus Alteration"
	desc = "Hinders nerve transmission to and from the speech center of the brain, resulting in faltering speech."
	id = "stutter"
	effectType = effectTypeDisability
	isBad = 1
	msgGain = "Y-you f.. feel a.. a bit n-n-nervous."
	msgLose = "You don't feel nervous anymore."
	reclaim_fail = 10
	lockedGaps = 1

	OnLife()
		if (prob(10))
			owner:stuttering = max(10, owner:stuttering)

/datum/bioEffect/smile
	name = "Frontal Gyrus Alteration"
	desc = "Causes the speech center of the subject's brain to produce large amounts of seratonin when engaged."
	id = "accent_smiling"
	effectType = effectTypeDisability
	isBad = 1
	probability = 15
	msgGain = "You feel like you want to smile and smile and smile forever :)"
	msgLose = "You don't feel like smiling anymore. :("
	reclaim_fail = 10
	lockedGaps = 1

/datum/bioEffect/elvis
	name = "Frontal Gyrus Alteration"
	desc = "Forces the language center of the subject's brain to drawl out sentences in a funky manner."
	id = "accent_elvis"
	effectType = effectTypeDisability
	isBad = 1
	msgGain = "You feel funky."
	msgLose = "You feel a little less conversation would be great."
	reclaim_fail = 10
	lockedGaps = 1

/datum/bioEffect/chav
	name = "Frontal Gyrus Alteration"
	desc = "Forces the language center of the subject's brain to construct sentences in a more rudimentary manner."
	id = "accent_chav"
	effectType = effectTypeDisability
	isBad = 1
	msgGain = "Ye feel like a reet prat like, innit?"
	msgLose = "You no longer feel like being rude and sassy."
	reclaim_fail = 10
	lockedGaps = 1

/datum/bioEffect/swedish
	name = "Frontal Gyrus Alteration"
	desc = "Forces the language center of the subject's brain to construct sentences in a vaguely norse manner."
	id = "accent_swedish"
	effectType = effectTypeDisability
	isBad = 1
	msgGain = "You feel Swedish, however that works."
	msgLose = "The feeling of Swedishness passes."
	reclaim_fail = 10
	lockedGaps = 1

/datum/bioEffect/loud_voice
	name = "High-Pressure Larynx"
	desc = "Vastly increases airflow speed and capacity through the subject's larynx."
	id = "loud_voice"
	effectType = effectTypePower
	probability = 40
	msgGain = "YOU SUDDENLY FEEL LIKE SHOUTING A WHOLE LOT!!!"
	msgLose = "You no longer feel the need to raise your voice."
	reclaim_fail = 10
	lockedGaps = 1

/datum/bioEffect/quiet_voice
	name = "Constricted Larynx"
	desc = "Decreases airflow speed and capacity through the subject's larynx."
	id = "quiet_voice"
	effectType = effectTypePower
	probability = 40
	msgGain = "...you feel like being quiet..."
	msgLose = "You no longer feel the need to keep your voice down."
	reclaim_fail = 10
	lockedGaps = 1

/datum/bioEffect/unintelligable
	name = "Frontal Gyrus Alteration"
	desc = "Heavily corrupts the part of the brain responsible for forming spoken sentences."
	id = "unintelligable"
	isBad = 1
	effectType = effectTypeDisability
	probability = 8
	blockCount = 4
	blockGaps = 4
	msgGain = "You can't seem to form any coherent thoughts!"
	msgLose = "Your mind feels more clear."
	reclaim_fail = 10
	lockedGaps = 1
	lockedDiff = 4

////////////
// POWERS //
////////////

// Resistances

/datum/bioEffect/fireres
	name = "Fire Resistance"
	desc = "Shields the subject's cellular structure against high temperatures and flames."
	id = "fire_resist"
	effectType = effectTypePower
	probability = 75
	blockCount = 3
	msgLose = "You feel cold."

	OnAdd()
		if (owner.bioHolder.HasEffect("cold_resist"))
			owner.bioHolder.AddEffect("thermal_resist",2)
			owner.bioHolder.RemoveEffect("fire_resist")
			owner.bioHolder.RemoveEffect("cold_resist")
			owner << "\blue Your thermal resistances merge into one!"
		else
			owner << "\blue You feel cold."
		return

	OnMobDraw()
		if (hasvar(owner, "lying"))
			owner.overlays += image("icon" = 'auras.dmi', "icon_state" = "fire[!owner.lying ? "_s" : "_l"]")
		return

/datum/bioEffect/coldres
	name = "Cold Resistance"
	desc = "Shields the subject's cellular structure against freezing temperatures and crystallization."
	id = "cold_resist"
	effectType = effectTypePower
	probability = 75
	blockCount = 3
	msgLose = "You feel warm."
	// you feel warm because you're resisting the cold, stop changing these around! =(

	OnAdd()
		if (owner.bioHolder.HasEffect("fire_resist"))
			owner.bioHolder.AddEffect("thermal_resist",1)
			owner.bioHolder.RemoveEffect("fire_resist")
			owner.bioHolder.RemoveEffect("cold_resist")
			owner << "\blue Your thermal resistances merge into one!"
		else
			owner << "\blue You feel warm."
		return

	OnMobDraw()
		if (hasvar(owner, "lying"))
			owner.overlays += image("icon" = 'auras.dmi', "icon_state" = "cold[!owner.lying ? "_s" : "_l"]")
		return

/datum/bioEffect/thermalres
	name = "Thermal Resistance"
	desc = "Shields the subject's cellular structure against any harmful temperature exposure."
	id = "thermal_resist"
	effectType = effectTypePower
	probability = 75
	blockCount = 3
	isHidden = -1

	OnRemove()
		if (src.variant == 1)
			owner.bioHolder.AddEffect("cold_resist")
			owner << "\red You feel warm."
		else if (src.variant == 2)
			owner.bioHolder.AddEffect("fire_resist")
			owner << "\red You feel cold."
		return

	OnMobDraw()
		if (hasvar(owner, "lying"))
			owner.overlays += image("icon" = 'auras.dmi', "icon_state" = "thermal[!owner.lying ? "_s" : "_l"]")
		return

/datum/bioEffect/elecres
	name = "SMES Human"
	desc = "Protects the subject's cellular structure from electrical energy."
	id = "resist_electric"
	effectType = effectTypePower
	probability = 50
	blockCount = 3
	blockGaps = 3
	msgGain = "Your hair stands on end."
	msgLose = "The tingling in your skin fades."

	OnMobDraw()
		owner.overlays += image("icon" = 'genetics.dmi', "icon_state" = "elec[owner:bioHolder.HasEffect("fat") ? "fat" :""][!owner:lying ? "_s" : "_l"]")
		return

/datum/bioEffect/alcres
	name = "Alcohol Resistance"
	desc = "Strongly reinforces the subject's nervous system against alcoholic intoxication."
	id = "resist_alcohol"
	effectType = effectTypePower
	msgGain = "You feel unusually sober."
	msgLose = "You feel like you could use a stiff drink."

/datum/bioEffect/psychic_resist
	name = "Meta-Neural Enhancement"
	desc = "Boosts efficiency in sectors of the brain commonly associated with meta-mental energies."
	id = "psy_resist"
	effectType = effectTypePower
	msgGain = "Your mind feels closed."
	msgLose = "You feel oddly exposed."

// Stealth Enhancers

/datum/bioEffect/darkcloak
	name = "Cloak of Darkness"
	desc = "Enables the subject to bend low levels of light around themselves, creating a cloaking effect."
	id = "cloak_of_darkness"
	effectType = effectTypePower
	isBad = 0
	probability = 15
	blockGaps = 3
	blockCount = 3
	msgGain = "You begin to fade into the shadows."
	msgLose = "You become fully visible."

/datum/bioEffect/chameleon
	name = "Chameleon"
	desc = "The subject becomes able to subtly alter light patterns to become invisible, as long as they remain still."
	id = "chameleon"
	effectType = effectTypePower
	probability = 25
	blockCount = 3
	blockGaps = 3
	msgGain = "You feel one with your surroundings."
	msgLose = "You feel oddly exposed."
	var/image/over = null

	OnAdd()
		over = image('genetics.dmi', owner, "cloak", FLY_LAYER)
		return

	OnLife()
		if((world.timeofday - owner.l_move_time) >= 30 && can_act(owner))
			owner.invisibility = 1
			owner.overlays -= over
			owner.overlays += over
		else
			owner.overlays -= over
		return

// Others

/datum/bioEffect/glowy
	name = "Glowy"
	desc = "Endows the subject with bioluminescent skin. Color and intensity may vary by subject."
	id = "glowy"
	effectType = effectTypePower
	probability = 100
	blockCount = 3
	blockGaps = 1
	msgGain = "Your skin begins to glow softly."
	msgLose = "Your glow fades away."
	var/glow_red = 0
	var/glow_green = 0
	var/glow_blue = 0

	New()
		..()
		glow_red = rand(1,10) / 10
		glow_green = rand(1,10) / 10
		glow_blue = rand(1,10) / 10

	OnAdd()
		owner.sd_SetLuminosity(owner.luminosity + 5)
		owner.sd_SetColor(glow_red,glow_green,glow_blue)
		return

	OnRemove()
		owner.sd_SetLuminosity(owner.luminosity - 5)
		owner.sd_SetColor(0.5,0.5,0.5)
		return

/datum/bioEffect/hulk
	name = "Gamma Ray Exposure"
	desc = "Vastly enhances the subject's musculature. May cause severe melanocyte corruption."
	id = "hulk"
	effectType = effectTypePower
	probability = 5
	blockCount = 4
	blockGaps = 5
	reclaim_mats = 20
	msgGain = "You feel your muscles swell to an immense size."
	msgLose = "Your muscles shrink back down."

	OnAdd()
		owner.unlock_medal("It's not easy being green", 1)
		return

	OnMobDraw()
		if (hasvar(owner, "lying"))
			owner.overlays += image("icon" = 'genetics.dmi', "icon_state" = "hulk[owner:bioHolder.HasEffect("fat") ? "fat" :""][!owner:lying ? "_s" : "_l"]")
		return

	OnLife()
		if (owner:health <= 25)
			timeLeft = 1
			owner << "\red You suddenly feel very weak."
			owner:weakened = 3
			owner:emote("collapse")


/datum/bioEffect/telekinesis
	name = "Telekinesis"
	desc = "Enables the subject to project kinetic energy using certain thought patterns."
	id = "telekinesis"
	effectType = effectTypePower
	probability = 5
	blockCount = 5
	blockGaps = 5
	reclaim_mats = 20
	msgGain = "You feel your consciousness expand outwards."
	msgLose = "Your conciousness closes inwards."

	OnMobDraw()
		if (hasvar(owner, "lying"))
			owner.overlays += image("icon" = 'genetics.dmi', "icon_state" = "telekinesishead[owner:bioHolder.HasEffect("fat") ? "fat" :""][!owner.lying ? "_s" : "_l"]")
		return

/datum/bioEffect/xray
	name = "X-Ray Vision"
	desc = "Enhances the subject's optic nerves, allowing them to see on x-ray wavelengths."
	id = "xray"
	effectType = effectTypePower
	probability = 10
	blockCount = 3
	blockGaps = 5
	reclaim_mats = 20
	msgGain = "You suddenly seem to be able to see through everything."
	msgLose = "Your vision fades back to normal."

/datum/bioEffect/toxic_farts
	name = "High Decay Digestion"
	desc = "Causes the subject's digestion to create a significant amount of noxious gas."
	id = "toxic_farts"
	probability = 35
	blockCount = 2
	blockGaps = 4
	msgGain = "Your stomach grumbles unpleasantly."
	msgLose = "Your stomach stops acting up. Phew!"

/datum/bioEffect/cooldown_reducer
	name = "Booster Gene X-1"
	desc = "This function of this gene is not well-researched."
	id = "cooldown_reducer"
	probability = 80
	blockCount = 2
	blockGaps = 4
	var/divider = 0.5

	New()
		..()
		name = "Booster Gene [pick("A","B","C")]-[rand(1,3)]"

//////////////////
// USELESS SHIT //
//////////////////

/datum/bioEffect/strong
	// pretty sure this doesn't do jack shit, putting it here until it does
	name = "Musculature Enhancement"
	desc = "Enhances the subject's ability to build and retain heavy muscles."
	id = "strong"
	effectType = effectTypePower
	probability = 50
	msgGain = "You feel buff!"
	msgLose = "You feel wimpy and weak."

/datum/bioEffect/horns
	name = "Cranial Keratin Formation"
	desc = "Enables the growth of a compacted keratin formation on the subject's head."
	id = "horns"
	effectType = effectTypePower
	probability = 60
	msgGain = "A pair of horns erupt from your head."
	msgLose = "Your horns crumble away into nothing."

	OnMobDraw()
		if (hasvar(owner, "lying"))
			owner.overlays += image("icon" = 'genetics.dmi', "icon_state" = "horns_[!owner.lying ? "s" : "l"]")
		return

/datum/bioEffect/stinky
	name = "Apocrine Enhancement"
	desc = "Increases the amount of natural body substances produced from the subject's apocrine glands."
	id = "stinky"
	effectType = effectTypeDisability
	isBad = 1
	msgGain = "You feel sweaty."
	msgLose = "You feel much more hygenic."
	var/personalized_stink = "Wow, it stinks in here!"

	New()
		..()
		src.personalized_stink = stinkString()
		if (prob(5))
			src.variant = 2

	OnLife()
		if (prob(10))
			for(var/mob/living/carbon/C in view(6,get_turf(owner)))
				if (C == owner)
					continue
				if (src.variant == 2)
					C << "\red [src.personalized_stink]"
				else
					C << "\red [stinkString()]"

/datum/bioEffect/consumed
	name = "Consumed"
	desc = "Most of their flesh has been chewed off."
	id = "consumed"
	effectType = effectTypeDisability
	isBad = 1
	isHidden = 1
	can_copy = 0