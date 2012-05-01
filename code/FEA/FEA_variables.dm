//Please note that mose of these variables are holdovers form ZAS, but I really do not want to expend the effort to prune it down quite yet.

pl_control/var
	PLASMA_DMG = 3
	PLASMA_DMG_NAME = "Plasma Damage Multiplier"
	PLASMA_DMG_DESC = "Multiplier on how much damage inhaling plasma can do."

	OXY_TO_PLASMA = 1
	OXY_TO_PLASMA_NAME = "O2/Plasma Ratio"
	OXY_TO_PLASMA_DESC = "Multiplier for the ratio of oxygen to plasma required in fires."

	CLOTH_CONTAMINATION = 1 //If this is on, plasma does damage by getting into cloth.
	CLOTH_CONTAMINATION_NAME = "Plasma - Cloth Contamination"
	CLOTH_CONTAMINATION_RANDOM = 60
	CLOTH_CONTAMINATION_METHOD = "Toggle"
	CLOTH_CONTAMINATION_DESC = "If set to nonzero, plasma will contaminate cloth items (uniforms, backpacks, etc.)\
	and cause a small amount of damage over time to anyone carrying or wearing them. Contamination can be detected\
	with a Health Analyzer, and washed off in the washer."

	ALL_ITEM_CONTAMINATION = 0 //If this is on, any item can be contaminated, so suits and tools must be discarded or
										  //decontaminated.
	ALL_ITEM_CONTAMINATION_NAME = "Plasma - Full Contamination"
	ALL_ITEM_CONTAMINATION_RANDOM = 10
	ALL_ITEM_CONTAMINATION_METHOD = "Toggle"
	ALL_ITEM_CONTAMINATION_DESC = "Like Cloth Contamination, but all item types are susceptible."

	PLASMAGUARD_ONLY = 0
	PLASMAGUARD_ONLY_NAME = "Plasma - Biosuits/Spacesuits Only"
	PLASMAGUARD_ONLY_RANDOM = 20
	PLASMAGUARD_ONLY_METHOD = "Toggle"
	PLASMAGUARD_ONLY_DESC = "If on, any suits that are not biosuits or space suits will not protect against contamination."

	//CANISTER_CORROSION = 0         //If this is on, plasma must be stored in orange tanks and canisters,
	//CANISTER_CORROSION_RANDOM = 20 //or it will corrode the tank.
	//CANISTER_CORROSION_METHOD = "Toggle"

	GENETIC_CORRUPTION = 0 //Chance of genetic corruption as well as toxic damage, X in 10,000.
	GENETIC_CORRUPTION_NAME = "Plasma - Genetic Corruption"
	GENETIC_CORRUPTION_RANDOM = "PROB10/3d6"
	GENETIC_CORRUPTION_METHOD = "Numeric"
	GENETIC_CORRUPTION_DESC = "When set to a probability in 1000, any humans in plasma will have this chance to develop a random mutation."

	SKIN_BURNS = 1       //Plasma has an effect similar to mustard gas on the un-suited.
	SKIN_BURNS_NAME = "Plasma - Skin Burns"
	SKIN_BURNS_RANDOM = 10
	SKIN_BURNS_METHOD = "Toggle"
	SKIN_BURNS_DESC = "When toggled, humans with exposed skin will suffer burns (similar to mustard gas) in plasma."

	//PLASMA_INJECTS_TOXINS = 0         //Plasma damage injects the toxins chemical to do damage over time.
	//PLASMA_INJECTS_TOXINS_RANDOM = 30
	//PLASMA_INJECTS_TOXINS_METHOD = "Toggle"

	EYE_BURNS = 0 //Plasma burns the eyes of anyone not wearing eye protection.
	EYE_BURNS_NAME = "Plasma - Eye Burns"
	EYE_BURNS_RANDOM = 30
	EYE_BURNS_METHOD = "Toggle"
	EYE_BURNS_DESC = "When toggled, humans without masks that cover the eyes will suffer temporary blurriness and sight loss,\
	and may need glasses to see again if exposed for long durations."

	//N2O_REACTION = 0 //Plasma can react with N2O, making sparks and starting a fire if levels are high.
	//N2O_REACTION_RANDOM = 5

	//PLASMA_COLOR = "onturf" //Plasma can change colors yaaaay!
	//PLASMA_COLOR_RANDOM = "PICKonturf,onturf"

	//PLASMA_DMG_OFFSET = 1
	//PLASMA_DMG_OFFSET_RANDOM = "1d5"
	//PLASMA_DMG_QUOTIENT = 10
	//PLASMA_DMG_QUOTIENT_RANDOM = "1d10+4"

	CONTAMINATION_LOSS = 0.1
	_NAME = "Plasma - Contamination Damage"
	CONTAMINATION_LOSS_DESC = "A number representing the damage done per life cycle by contaminated items."

	PLASMA_HALLUCINATION = 1
	PLASMA_HALLUCINATION_NAME = "Plasma - Hallucination"
	PLASMA_HALLUCINATION_METHOD = "Toggle"
	PLASMA_HALLUCINATION_DESC = "If toggled, uses the remnants of the hallucination code to induce visions in those\
	who breathe plasma."
	N2O_HALLUCINATION = 1
	N2O_HALLUCINATION_NAME = "Nitrous Oxide - Hallucination"
	N2O_HALLUCINATION_METHOD = "Toggle"
	N2O_HALLUCINATION_DESC = "If toggled, uses the remnants of the hallucination code to induce visions in those\
	who breathe N2O."
	//CONTAMINATION_LOSS_RANDOM = "5d5"
//Plasma has a chance to be a different color.

var/tick_multiplier = 2
/datum/controller/air_system/var
	//Used in /mob/carbon/human/life
	OXYGEN_LOSS = 2
	OXYGEN_LOSS_NAME = "Damage - Oxygen Loss"
	OXYGEN_LOSS_DESC = "A multiplier for damage due to lack of air, CO2 poisoning, and vacuum. Does not affect oxyloss\
	from being incapacitated or dying."
	TEMP_DMG = 2
	TEMP_DMG_NAME = "Damage - Temperature"
	TEMP_DMG_DESC = "A multiplier for damage due to body temperature irregularities."
	BURN_DMG = 6
	BURN_DMG_NAME = "Damage - Fire"
	BURN_DMG_DESC = "A multiplier for damage due to direct fire exposure."

	AF_TINY_MOVEMENT_THRESHOLD = 50 //% difference to move tiny items.
	AF_TINY_MOVEMENT_THRESHOLD_NAME = "Airflow - Tiny Movement Threshold %"
	AF_TINY_MOVEMENT_THRESHOLD_DESC = "Percent of 1 Atm. at which items with the tiny weight class will move."
	AF_SMALL_MOVEMENT_THRESHOLD = 70 //% difference to move small items.
	AF_SMALL_MOVEMENT_THRESHOLD_NAME = "Airflow - Small Movement Threshold %"
	AF_SMALL_MOVEMENT_THRESHOLD_DESC = "Percent of 1 Atm. at which items with the small weight class will move."
	AF_NORMAL_MOVEMENT_THRESHOLD = 90 //% difference to move normal items.
	AF_NORMAL_MOVEMENT_THRESHOLD_NAME = "Airflow - Normal Movement Threshold %"
	AF_NORMAL_MOVEMENT_THRESHOLD_DESC = "Percent of 1 Atm. at which items with the normal weight class will move."
	AF_LARGE_MOVEMENT_THRESHOLD = 100 //% difference to move large and huge items.
	AF_LARGE_MOVEMENT_THRESHOLD_NAME = "Airflow - Large Movement Threshold %"
	AF_LARGE_MOVEMENT_THRESHOLD_DESC = "Percent of 1 Atm. at which items with the large or huge weight class will move."
	AF_DENSE_MOVEMENT_THRESHOLD = 120 //% difference to move dense crap and mobs.
	AF_DENSE_MOVEMENT_THRESHOLD_NAME = "Airflow - Dense Movement Threshold %"
	AF_DENSE_MOVEMENT_THRESHOLD_DESC = "Percent of 1 Atm. at which dense objects (canisters, etc.) will be shifted by airflow."
	AF_MOB_MOVEMENT_THRESHOLD = 175
	AF_MOB_MOVEMENT_THRESHOLD_NAME = "Airflow - Human Movement Threshold %"
	AF_MOB_MOVEMENT_THRESHOLD_DESC = "Percent of 1 Atm. at which mobs will be shifted by airflow."

	AF_HUMAN_STUN_THRESHOLD = 130
	AF_HUMAN_STUN_THRESHOLD_NAME = "Airflow - Human Stun Threshold %"
	AF_HUMAN_STUN_THRESHOLD_DESC = "Percent of 1 Atm. at which living things are stunned or knocked over."

	AF_PERCENT_OF = ONE_ATMOSPHERE
	AF_PERCENT_OF_NAME = "Airflow - 100% Pressure"
	AF_PERCENT_OF_DESC = "Normally set to 1 Atm. in kPa, this indicates what pressure is considered 100% by the system."

	AF_SPEED_MULTIPLIER = 4 //airspeed per movement threshold value crossed.
	AF_SPEED_MULTIPLIER_NAME = "Airflow - Speed Increase per 10%"
	AF_SPEED_MULTIPLIER_DESC = "Velocity increase of shifted items per 10% of airflow."
	AF_DAMAGE_MULTIPLIER = 5 //Amount of damage applied per airflow_speed.
	AF_DAMAGE_MULTIPLIER_NAME = "Airflow - Damage Per Velocity"
	AF_DAMAGE_MULTIPLIER_DESC = "Amount of damage applied per unit of speed (1-15 units) at which mobs are thrown."
	AF_STUN_MULTIPLIER = 1.5 //Seconds of stun applied per airflow_speed.
	AF_STUN_MULTIPLIER_NAME = "Airflow - Stun Per Velocity"
	AF_STUN_MULTIPLIER_DESC = "Amount of stun effect applied per unit of speed (1-15 units) at which mobs are thrown."
	AF_SPEED_DECAY = 0.5 //Amount that flow speed will decay with time.
	AF_SPEED_DECAY_NAME = "Airflow - Velocity Lost per Tick"
	AF_SPEED_DECAY_DESC = "Amount of airflow speed lost per tick on a moving object."
	AF_SPACE_MULTIPLIER = 2 //Increasing this will make space connections more DRAMATIC!
	AF_SPACE_MULTIPLIER_NAME = "Airflow - Space Airflow Multiplier"
	AF_SPACE_MULTIPLIER_DESC = "Increasing this multiplier will cause more powerful airflow to space."
	AF_CANISTER_MULTIPLIER = 0.25
	AF_CANISTER_MULTIPLIER_NAME = "Airflow - Canister Airflow Multiplier"
	AF_CANISTER_MULTIPLIER_DESC = "Increasing this multiplier will cause more powerful airflow from single-tile sources like canisters."

/datum/controller/air_system
	var
		list/settings = list()
		list/bitflags = list("1","2","4","8","16","32","64","128","256","512","1024")
		pl_control/plc = new()
	New()
		. = ..()
		settings = vars.Copy()

		var/datum/D = new() //Ensure only unique vars are put through by making a datum and removing all common vars.
		for(var/V in D.vars)
			settings -= V

		for(var/V in settings)
			if(findtextEx(V,"_RANDOM") || findtextEx(V,"_DESC") || findtextEx(V,"_METHOD"))
				settings -= V

		settings -= "settings"
		settings -= "bitflags"
		settings -= "plc"

	proc/ChangeSettingsDialog(mob/user,list/L)
		//var/which = input(user,"Choose a setting:") in L
		var/dat = ""
		for(var/ch in L)
			if(findtextEx(ch,"_RANDOM") || findtextEx(ch,"_DESC") || findtextEx(ch,"_METHOD") || findtextEx(ch,"_NAME")) continue
			var/vw
			var/vw_desc = "No Description."
			var/vw_name = ch
			if(ch in plc.settings)
				vw = plc.vars[ch]
				if("[ch]_DESC" in plc.vars) vw_desc = plc.vars["[ch]_DESC"]
				if("[ch]_NAME" in plc.vars) vw_name = plc.vars["[ch]_NAME"]
			else
				vw = vars[ch]
				if("[ch]_DESC" in vars) vw_desc = vars["[ch]_DESC"]
				if("[ch]_NAME" in plc.vars) vw_name = vars["[ch]_NAME"]
			dat += "<b>[vw_name] = [vw]</b> <A href='?src=\ref[src];changevar=[ch]'>\[Change\]</A><br>"
			dat += "<i>[vw_desc]</i><br><br>"
		user << browse(dat,"window=settings")
	Topic(href,href_list)
		if("changevar" in href_list)
			ChangeSetting(usr,href_list["changevar"])
	proc/ChangeSetting(mob/user,ch)
		var/vw
		var/how = "Text"
		if(ch in plc.settings)
			vw = plc.vars[ch]
			if("[ch]_METHOD" in vars)
				how = plc.vars["[ch]_METHOD"]
			else
				if(isnum(vw))
					how = "Numeric"
				else
					how = "Text"
		else
			vw = vars[ch]
			if("[ch]_METHOD" in vars)
				how = vars["[ch]_METHOD"]
			else
				if(isnum(vw))
					how = "Numeric"
				else
					how = "Text"
		var/newvar = vw
		switch(how)
			if("Numeric")
				newvar = input(user,"Enter a number:","Settings",newvar) as num
			if("Bit Flag")
				var/flag = input(user,"Toggle which bit?","Settings") in bitflags
				flag = text2num(flag)
				if(newvar & flag)
					newvar &= ~flag
				else
					newvar |= flag
			if("Toggle")
				newvar = !newvar
			if("Text")
				newvar = input(user,"Enter a string:","Settings",newvar) as text
			if("Long Text")
				newvar = input(user,"Enter text:","Settings",newvar) as message
		vw = newvar
		if(ch in plc.settings)
			plc.vars[ch] = vw
		else
			vars[ch] = vw
		if(how == "Toggle")
			newvar = (newvar?"ON":"OFF")
		world << "\blue <b>[key_name(user)] changed the setting [ch] to [newvar].</b>"
		//user << "[which] has been changed to [newvar]."
		if(ch in plc.settings)
			ChangeSettingsDialog(user,plc.settings)
		else
			ChangeSettingsDialog(user,settings)
	proc/RandomizeWithProbability()
		for(var/V in settings)
			var/newvalue
			if("[V]_RANDOM" in vars)
				if(isnum(vars["[V]_RANDOM"]))
					newvalue = prob(vars["[V]_RANDOM"])
				else if(istext(vars["[V]_RANDOM"]))
					newvalue = roll(vars["[V]_RANDOM"])
				else
					newvalue = vars[V]
			V = newvalue

	proc/ChangePlasma()
		for(var/V in plc.settings)
			plc.Randomize(V)
		////world << "Plasma randomized."

	proc/SetDefault(def)
		switch(def)
			if("Original")
				plc.CLOTH_CONTAMINATION = 0 //If this is on, plasma does damage by getting into cloth.

				plc.ALL_ITEM_CONTAMINATION = 0 //If this is on, any item can be contaminated, so suits and tools must be discarded or

				plc.PLASMAGUARD_ONLY = 0

				//plc.CANISTER_CORROSION = 0         //If this is on, plasma must be stored in orange tanks and canisters,

				plc.GENETIC_CORRUPTION = 0 //Chance of genetic corruption as well as toxic damage, X in 1000.

				plc.SKIN_BURNS = 0       //Plasma has an effect similar to mustard gas on the un-suited.

				//plc.PLASMA_INJECTS_TOXINS = 0         //Plasma damage injects the toxins chemical to do damage over time.

				plc.EYE_BURNS = 0 //Plasma burns the eyes of anyone not wearing eye protection.

				//plc.N2O_REACTION = 0 //Plasma can react with N2O, making sparks and starting a fire if levels are high.

				//plc.PLASMA_COLOR = "onturf" //Plasma can change colors yaaaay!

				//plc.PLASMA_DMG_OFFSET = 1
				//plc.PLASMA_DMG_QUOTIENT = 10

				plc.CONTAMINATION_LOSS = 0
			if("Hazard-Low")
				plc.CLOTH_CONTAMINATION = 1 //If this is on, plasma does damage by getting into cloth.

				plc.ALL_ITEM_CONTAMINATION = 0 //If this is on, any item can be contaminated, so suits and tools must be discarded or

				plc.PLASMAGUARD_ONLY = 0

			//	plc.CANISTER_CORROSION = 0         //If this is on, plasma must be stored in orange tanks and canisters,

				plc.GENETIC_CORRUPTION = 0 //Chance of genetic corruption as well as toxic damage, X in 1000.

				plc.SKIN_BURNS = 0       //Plasma has an effect similar to mustard gas on the un-suited.

			//	plc.PLASMA_INJECTS_TOXINS = 0         //Plasma damage injects the toxins chemical to do damage over time.

				plc.EYE_BURNS = 0 //Plasma burns the eyes of anyone not wearing eye protection.

			//	plc.N2O_REACTION = 0 //Plasma can react with N2O, making sparks and starting a fire if levels are high.

			//	plc.PLASMA_COLOR = "onturf" //RBPYB

				//if(prob(20))
				//	plc.PLASMA_COLOR = pick("red","yellow","blue","purple")

				//plc.PLASMA_DMG_OFFSET = 1.5
				//plc.PLASMA_DMG_QUOTIENT = 8

				plc.CONTAMINATION_LOSS = 0.01

				var/s = pick(plc.settings)
				plc.Randomize(s)

			if("Hazard-High")
				plc.CLOTH_CONTAMINATION = 1 //If this is on, plasma does damage by getting into cloth.

				plc.ALL_ITEM_CONTAMINATION = 0 //If this is on, any item can be contaminated, so suits and tools must be discarded or

				plc.PLASMAGUARD_ONLY = 0

			//	plc.CANISTER_CORROSION = 1         //If this is on, plasma must be stored in orange tanks and canisters,

				plc.GENETIC_CORRUPTION = 0 //Chance of genetic corruption as well as toxic damage, X in 1000.

				plc.SKIN_BURNS = 0       //Plasma has an effect similar to mustard gas on the un-suited.

			//	plc.PLASMA_INJECTS_TOXINS = 0         //Plasma damage injects the toxins chemical to do damage over time.

				plc.EYE_BURNS = 0 //Plasma burns the eyes of anyone not wearing eye protection.

			//	plc.N2O_REACTION = 0 //Plasma can react with N2O, making sparks and starting a fire if levels are high.

			//	plc.PLASMA_COLOR = "onturf"//pick("red","yellow","blue","purple") //RBPYB

				//plc.PLASMA_DMG_OFFSET = 3
				//plc.PLASMA_DMG_QUOTIENT = 5

				plc.CONTAMINATION_LOSS = 0.05

				for(var/i = rand(3,5),i>0,i--)
					var/s = pick(plc.settings)
					plc.Randomize(s)

			if("Everything")
				plc.CLOTH_CONTAMINATION = 1 //If this is on, plasma does damage by getting into cloth.

				plc.ALL_ITEM_CONTAMINATION = 1 //If this is on, any item can be contaminated, so suits and tools must be discarded or ELSE

				plc.PLASMAGUARD_ONLY = 1

			//	plc.CANISTER_CORROSION = 1         //If this is on, plasma must be stored in orange tanks and canisters,

				plc.GENETIC_CORRUPTION = 5 //Chance of genetic corruption as well as toxic damage, X in 1000.

				plc.SKIN_BURNS = 1       //Plasma has an effect similar to mustard gas on the un-suited.

			//	plc.PLASMA_INJECTS_TOXINS = 1         //Plasma damage injects the toxins chemical to do damage over time.

				plc.EYE_BURNS = 1 //Plasma burns the eyes of anyone not wearing eye protection.

			//	plc.N2O_REACTION = 1 //Plasma can react with N2O, making sparks and starting a fire if levels are high.

			//	plc.PLASMA_COLOR = "onturf" //RBPYB

				//plc.PLASMA_DMG_OFFSET = 3
				//plc.PLASMA_DMG_QUOTIENT = 5

				plc.CONTAMINATION_LOSS = 0.02
		/////world << "Plasma color updated."

pl_control
	var/list/settings = list()
	New()
		. = ..()
		settings = vars.Copy()

		var/datum/D = new() //Ensure only unique vars are put through by making a datum and removing all common vars.
		for(var/V in D.vars)
			settings -= V

		for(var/V in settings)
			if(findtextEx(V,"_RANDOM") || findtextEx(V,"_DESC"))
				settings -= V

		settings -= "settings"
	proc/Randomize(V)
		//world << "Randomizing [V]"
		var/newvalue
		if("[V]_RANDOM" in vars)
			if(isnum(vars["[V]_RANDOM"]))
				newvalue = prob(vars["[V]_RANDOM"])
				if(newvalue)
					//world << "Probability [vars["[V]_RANDOM"]]%: Success."
				else
					//world << "Probability [vars["[V]_RANDOM"]]%: Failure."
			else if(istext(vars["[V]_RANDOM"]))
				var/txt = vars["[V]_RANDOM"]
				if(findtextEx(txt,"PROB"))
					//world << "Probability/Roll Combo \..."
					txt = dd_text2list(txt,"/")
					txt[1] = dd_replacetext(txt[1],"PROB","")
					var/p = text2num(txt[1])
					var/r = txt[2]
					//world << "Prob:[p]% Roll:[r]"
					if(prob(p))
						newvalue = roll(r)
						//world << "Success. New value: [newvalue]"
					else
						newvalue = vars[V]
						//world << "Probability check failed."
				else if(findtextEx(txt,"PICK"))
					txt = dd_replacetext(txt,"PICK","")
					//world << "Pick: [txt]"
					txt = dd_text2list(txt,",")
					newvalue = pick(txt)
					//world << "Picked: [newvalue]"
				else
					newvalue = roll(txt)
					//world << "Roll: [txt] - [newvalue]"
			else
				newvalue = vars[V]
			vars[V] = newvalue
				////world << "Plasma color updated."

mob/proc/Change_Airflow_Constants()
	set category = "Debug"

	var/choice = input("Which constant will you modify?","Change Airflow Constants")\
	as null|anything in list("Movement Threshold","Speed Multiplier","Damage Multiplier","Stun Multiplier","Speed Decay")

	var/n

	switch(choice)
		if("Movement Threshold")
			n = input("What will you change it to","Change Airflow Constants",air_master.AF_DENSE_MOVEMENT_THRESHOLD) as num
			n = max(1,n)
			air_master.AF_DENSE_MOVEMENT_THRESHOLD = n
			world.log << "air_master.AF_DENSE_MOVEMENT_THRESHOLD set to [n]."
		if("Speed Multiplier")
			n = input("What will you change it to","Change Airflow Constants",air_master.AF_SPEED_MULTIPLIER) as num
			n = max(1,n)
			air_master.AF_SPEED_MULTIPLIER = n
			world.log << "air_master.AF_SPEED_MULTIPLIER set to [n]."
		if("Damage Multiplier")
			n = input("What will you change it to","Change Airflow Constants",air_master.AF_DAMAGE_MULTIPLIER) as num
			air_master.AF_DAMAGE_MULTIPLIER = n
			world.log << "AF_DAMAGE_MULTIPLIER set to [n]."
		if("Stun Multiplier")
			n = input("What will you change it to","Change Airflow Constants",air_master.AF_STUN_MULTIPLIER) as num
			air_master.AF_STUN_MULTIPLIER = n
			world.log << "AF_STUN_MULTIPLIER set to [n]."
		if("Speed Decay")
			n = input("What will you change it to","Change Airflow Constants",air_master.AF_SPEED_DECAY) as num
			air_master.AF_SPEED_DECAY = n
			world.log << "AF_SPEED_DECAY set to [n]."
		if("Space Flow Multiplier")
			n = input("What will you change it to","Change Airflow Constants",air_master.AF_SPEED_DECAY) as num
			air_master.AF_SPEED_DECAY = n
			world.log << "AF_SPEED_DECAY set to [n]."

obj/var/contaminated = 0

obj/item/proc
	can_contaminate()
		if(flags & PLASMAGUARD) return 0
		if((flags & SUITSPACE) && !air_master.plc.PLASMAGUARD_ONLY) return 1
		if(air_master.plc.ALL_ITEM_CONTAMINATION) return 1
		else if(istype(src,/obj/item/clothing)) return 1
		else if(istype(src,/obj/item/weapon/storage/backpack)) return 1

/mob/living/carbon/human/proc/contaminate()
	if(!pl_suit_protected())
		suit_contamination()
	else if(air_master.plc.PLASMAGUARD_ONLY)
		if(!wear_suit.flags & PLASMAGUARD) wear_suit.contaminated = 1



	if(!pl_head_protected())
		if(wear_mask) wear_mask.contaminated = 1
		if(prob(1)) suit_contamination() //Plasma can sometimes get through such an open suit.
	else if(air_master.plc.PLASMAGUARD_ONLY)
		if(!head.flags & PLASMAGUARD) head.contaminated = 1

	if(istype(back,/obj/item/weapon/storage/backpack) || air_master.plc.ALL_ITEM_CONTAMINATION)
		back.contaminated = 1

	if(l_hand)
		if(l_hand.can_contaminate()) l_hand.contaminated = 1
	if(r_hand)
		if(r_hand.can_contaminate()) r_hand.contaminated = 1
	if(belt)
		if(belt.can_contaminate()) belt.contaminated = 1
	if(wear_id && !pl_suit_protected())
		if(wear_id.can_contaminate()) wear_id.contaminated = 1
	if(l_ear && !pl_head_protected())
		if(l_ear.can_contaminate()) l_ear.contaminated = 1
	if(r_ear && !pl_head_protected())
		if(r_ear.can_contaminate()) r_ear.contaminated = 1

/mob/living/carbon/human/proc/pl_effects()
	if(stat >= 2)
		return
	if(air_master.plc.SKIN_BURNS)
		if(!pl_head_protected() || !pl_suit_protected())
			burn_skin(0.75)
			if (coughedtime != 1)
				coughedtime = 1
				emote("gasp")
				spawn (20)
					coughedtime = 0
			updatehealth()
	if(air_master.plc.EYE_BURNS && !pl_head_protected())
		if(!wear_mask)
			if(prob(20)) usr << "\red Your eyes burn!"
			eye_stat += 2.5
			eye_blurry += 1.5
			if (eye_stat >= 20 && !(disabilities & 1))
				src << "\red Your eyes start to burn badly!"
				disabilities |= 1
			if (prob(max(0,eye_stat - 20) + 1))
				src << "\red You are blinded!"
				eye_blind += 20
				eye_stat = max(eye_stat-25,0)
		else
			if(!(wear_mask.flags & MASKCOVERSEYES))
				if(prob(20)) usr << "\red Your eyes burn!"
				eye_stat += 2.5
				eye_blurry = min(eye_blurry+1.5,50)
				if (eye_stat >= 20 && !(disabilities & 1))
					src << "\red Your eyes start to burn badly!"
					disabilities |= 1
				if (prob(max(0,eye_stat - 20) + 1) &&!eye_blind)
					src << "\red You are blinded!"
					eye_blind += 20
					eye_stat = 0
	if(air_master.plc.GENETIC_CORRUPTION)
		if(rand(1,1000) < air_master.plc.GENETIC_CORRUPTION)
			randmutb(src)
			src << "\red High levels of toxins cause you to spontaneously mutate."
			domutcheck(src,null)

/mob/living/carbon/human/proc/FireBurn(mx as num)
	//NO! NOT INTO THE PIT! IT BURRRRRNS!
	mx *= air_master.BURN_DMG

	var
		head_exposure = 1
		chest_exposure = 1
		groin_exposure = 1
		legs_exposure = 1
		feet_exposure = 1
		arms_exposure = 1
		hands_exposure = 1
	for(var/obj/item/clothing/C in src)
		if(l_hand == C || r_hand == C) continue
		if(C.body_parts_covered & HEAD)
			head_exposure *= C.heat_transfer_coefficient
		if(C.body_parts_covered & UPPER_TORSO)
			chest_exposure *= C.heat_transfer_coefficient
		if(C.body_parts_covered & LOWER_TORSO)
			groin_exposure *= C.heat_transfer_coefficient
		if(C.body_parts_covered & LEGS)
			legs_exposure *= C.heat_transfer_coefficient
		if(C.body_parts_covered & FEET)
			feet_exposure *= C.heat_transfer_coefficient
		if(C.body_parts_covered & ARMS)
			arms_exposure *= C.heat_transfer_coefficient
		if(C.body_parts_covered & HANDS)
			arms_exposure *= C.heat_transfer_coefficient

	mx *= 10

	apply_damage("head", 0, 2.5*mx*head_exposure)
	apply_damage("chest", 0, 2.5*mx*chest_exposure)
	apply_damage("groin", 0, 2.0*mx*groin_exposure)
	apply_damage("l_leg", 0, 0.6*mx*legs_exposure)
	apply_damage("r_leg", 0, 0.6*mx*legs_exposure)
	apply_damage("l_arm", 0, 0.4*mx*arms_exposure)
	apply_damage("r_arm", 0, 0.4*mx*arms_exposure)
	apply_damage("l_foot", 0, 0.25*mx*feet_exposure)
	apply_damage("r_foot", 0, 0.25*mx*feet_exposure)
	apply_damage("l_hand", 0, 0.25*mx*hands_exposure)
	apply_damage("r_hand", 0, 0.25*mx*hands_exposure)

/mob/living/carbon/human/proc/suit_interior()
	. = list()
	if(!pl_suit_protected())
		for(var/obj/item/I in src)
			. += I
		return .
	. += wear_mask
	. += w_uniform
	. += shoes
	. += gloves
	if(!pl_head_protected())
		. += head

/mob/living/carbon/human/proc/pl_head_protected()
	if(head)
		if(head.flags & PLASMAGUARD || head.flags & HEADSPACE) return 1
	return 0

/mob/living/carbon/human/proc/pl_suit_protected()
	if(wear_suit)
		if(wear_suit.flags & PLASMAGUARD || wear_suit.flags & SUITSPACE) return 1
	return 0

/mob/living/carbon/human/proc/suit_contamination()
	if(air_master.plc.ALL_ITEM_CONTAMINATION)
		for(var/obj/item/I in src)
			I.contaminated = 1
	else
		if(wear_suit) wear_suit.contaminated = 1
		if(w_uniform) w_uniform.contaminated = 1
		if(shoes) shoes.contaminated = 1
		if(gloves) gloves.contaminated = 1
		if(wear_mask) wear_mask.contaminated = 1


turf/Entered(obj/item/I)
	. = ..()
	if(istype(I))
		var/datum/gas_mixture/env = return_air(1)
		if(env.toxins > 0.35)
			if(I.can_contaminate())
				I.contaminated = 1