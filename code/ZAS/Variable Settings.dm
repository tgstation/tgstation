var/global/vs_control/vsc = new

// Whoever made this fucking thing:  I hate you so much.
vs_control/var
	// N3X15 - Added back in so we can tweak performance.
	airflow_push = 0
	airflow_push_NAME="Airflow - Push shit around"
	airflow_push_DESC="1=yes please rape my server, 0=no"
	airflow_push_METHOD="Toggle" // See ChangeSettings().  I'd rather not let people break this.

	fire_consuption_rate = 0.75
	fire_consuption_rate_NAME = "Fire - Air Consumption Ratio"
	fire_consuption_rate_DESC = "Ratio of air removed and combusted per tick."

	fire_firelevel_multiplier = 25
	fire_firelevel_multiplier_NAME = "Fire - Firelevel Constant"
	fire_firelevel_multiplier_DESC = "Multiplied by the equation for firelevel, affects mainly the extingiushing of fires."

	fire_fuel_energy_release = 550000
	fire_fuel_energy_release_NAME = "Fire - Fuel energy release"
	fire_fuel_energy_release_DESC = "The energy in joule released when burning one mol of a burnable substance"


	airflow_lightest_pressure = 20
	airflow_lightest_pressure_NAME = "Airflow - Small Movement Threshold %"
	airflow_lightest_pressure_DESC = "Percent of 1 Atm. at which items with the small weight classes will move."

	airflow_light_pressure = 35
	airflow_light_pressure_NAME = "Airflow - Medium Movement Threshold %"
	airflow_light_pressure_DESC = "Percent of 1 Atm. at which items with the medium weight classes will move."

	airflow_medium_pressure = 50
	airflow_medium_pressure_NAME = "Airflow - Heavy Movement Threshold %"
	airflow_medium_pressure_DESC = "Percent of 1 Atm. at which items with the largest weight classes will move."

	airflow_heavy_pressure = 65
	airflow_heavy_pressure_NAME = "Airflow - Mob Movement Threshold %"
	airflow_heavy_pressure_DESC = "Percent of 1 Atm. at which mobs will move."

	airflow_dense_pressure = 85
	airflow_dense_pressure_NAME = "Airflow - Dense Movement Threshold %"
	airflow_dense_pressure_DESC = "Percent of 1 Atm. at which items with canisters and closets will move."

	airflow_stun_pressure = 60
	airflow_stun_pressure_NAME = "Airflow - Mob Stunning Threshold %"
	airflow_stun_pressure_DESC = "Percent of 1 Atm. at which mobs will be stunned by airflow."

	airflow_stun_cooldown = 60
	airflow_stun_cooldown_NAME = "Aiflow Stunning - Cooldown"
	airflow_stun_cooldown_DESC = "How long, in tenths of a second, to wait before stunning them again."

	airflow_stun = 1
	airflow_stun_NAME = "Airflow Impact - Stunning"
	airflow_stun_DESC = "How much a mob is stunned when hit by an object."

	airflow_damage = 2
	airflow_damage_NAME = "Airflow Impact - Damage"
	airflow_damage_DESC = "Damage from airflow impacts."

	airflow_speed_decay = 1.5
	airflow_speed_decay_NAME = "Airflow Speed Decay"
	airflow_speed_decay_DESC = "How rapidly the speed gained from airflow decays."

	airflow_delay = 30
	airflow_delay_NAME = "Airflow Retrigger Delay"
	airflow_delay_DESC = "Time in deciseconds before things can be moved by airflow again."

	airflow_mob_slowdown = 1
	airflow_mob_slowdown_NAME = "Airflow Slowdown"
	airflow_mob_slowdown_DESC = "Time in tenths of a second to add as a delay to each movement by a mob if they are fighting the pull of the airflow."

	var/connection_insulation = 0.4
	var/connection_insulation_NAME = "Connections - Insulation"
	var/connection_insulation_DESC = "How insulative a connection is, in terms of heat transfer.  1 is perfectly insulative, and 0 is perfectly conductive."

	var/connection_temperature_delta = 10
	var/connection_temperature_delta_NAME = "Connections - Temperature Difference"
	var/connection_temperature_delta_DESC = "The smallest temperature difference which will cause heat to travel through doors."

vs_control
	var
		list/settings = list()
		list/bitflags = list("1","2","4","8","16","32","64","128","256","512","1024") // Oh jesus why.  Learn to shift bits, you idiots.
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
				if("[ch]_NAME" in vars) vw_name = vars["[ch]_NAME"]
			dat += "<b>[vw_name] = [vw]</b> <A href='?src=\ref[src];changevar=[ch]'>\[Change\]</A><br>"
			dat += "<i>[vw_desc]</i><br><br>"
		user << browse(dat,"window=settings")
	Topic(href,href_list)
		if("changevar" in href_list)
			ChangeSetting(usr,href_list["changevar"])
	proc/ChangeSetting(mob/user,ch)
		var/vw
		var/how = "Text"
		var/display_description = ch
		if(ch in plc.settings)
			vw = plc.vars[ch]
			if("[ch]_NAME" in plc.vars)
				display_description = plc.vars["[ch]_NAME"]
			if("[ch]_METHOD" in plc.vars)
				how = plc.vars["[ch]_METHOD"]
			else
				if(isnum(vw))
					how = "Numeric"
				else
					how = "Text"
		else
			vw = vars[ch]
			if("[ch]_NAME" in vars)
				display_description = vars["[ch]_NAME"]
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
		world << "\blue <b>[key_name(user)] changed the setting [display_description] to [newvar].</b>"
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

	proc/SetDefault(var/mob/user)
		var/list/setting_choices = list("Plasma - Standard", "Plasma - Low Hazard", "Plasma - High Hazard", "Plasma - Oh Shit!",\
		"ZAS - Normal", "ZAS - Forgiving", "ZAS - Dangerous", "ZAS - Hellish")
		var/def = input(user, "Which of these presets should be used?") as null|anything in setting_choices
		if(!def)
			return
		switch(def)
			if("Plasma - Standard")
				plc.CLOTH_CONTAMINATION = 1 //If this is on, plasma does damage by getting into cloth.
				plc.PLASMAGUARD_ONLY = 0
				plc.GENETIC_CORRUPTION = 0 //Chance of genetic corruption as well as toxic damage, X in 1000.
				plc.SKIN_BURNS = 0       //Plasma has an effect similar to mustard gas on the un-suited.
				plc.EYE_BURNS = 1 //Plasma burns the eyes of anyone not wearing eye protection.
				plc.PLASMA_HALLUCINATION = 0
				plc.CONTAMINATION_LOSS = 0.02

			if("Plasma - Low Hazard")
				plc.CLOTH_CONTAMINATION = 0 //If this is on, plasma does damage by getting into cloth.
				plc.PLASMAGUARD_ONLY = 0
				plc.GENETIC_CORRUPTION = 0 //Chance of genetic corruption as well as toxic damage, X in 1000
				plc.SKIN_BURNS = 0       //Plasma has an effect similar to mustard gas on the un-suited.
				plc.EYE_BURNS = 1 //Plasma burns the eyes of anyone not wearing eye protection.
				plc.PLASMA_HALLUCINATION = 0
				plc.CONTAMINATION_LOSS = 0.01

			if("Plasma - High Hazard")
				plc.CLOTH_CONTAMINATION = 1 //If this is on, plasma does damage by getting into cloth.
				plc.PLASMAGUARD_ONLY = 0
				plc.GENETIC_CORRUPTION = 0 //Chance of genetic corruption as well as toxic damage, X in 1000.
				plc.SKIN_BURNS = 1       //Plasma has an effect similar to mustard gas on the un-suited.
				plc.EYE_BURNS = 1 //Plasma burns the eyes of anyone not wearing eye protection.
				plc.PLASMA_HALLUCINATION = 1
				plc.CONTAMINATION_LOSS = 0.05

			if("Plasma - Oh Shit!")
				plc.CLOTH_CONTAMINATION = 1 //If this is on, plasma does damage by getting into cloth.
				plc.PLASMAGUARD_ONLY = 1
				plc.GENETIC_CORRUPTION = 5 //Chance of genetic corruption as well as toxic damage, X in 1000.
				plc.SKIN_BURNS = 1       //Plasma has an effect similar to mustard gas on the un-suited.
				plc.EYE_BURNS = 1 //Plasma burns the eyes of anyone not wearing eye protection.
				plc.PLASMA_HALLUCINATION = 1
				plc.CONTAMINATION_LOSS = 0.075

			if("ZAS - Normal")
				airflow_push=0
				airflow_lightest_pressure = 20
				airflow_light_pressure = 35
				airflow_medium_pressure = 50
				airflow_heavy_pressure = 65
				airflow_dense_pressure = 85
				airflow_stun_pressure = 60
				airflow_stun_cooldown = 60
				airflow_stun = 1
				airflow_damage = 2
				airflow_speed_decay = 1.5
				airflow_delay = 30
				airflow_mob_slowdown = 1

			if("ZAS - Forgiving")
				airflow_push=0
				airflow_lightest_pressure = 45
				airflow_light_pressure = 60
				airflow_medium_pressure = 120
				airflow_heavy_pressure = 110
				airflow_dense_pressure = 200
				airflow_stun_pressure = 150
				airflow_stun_cooldown = 90
				airflow_stun = 0.15
				airflow_damage = 0.15
				airflow_speed_decay = 1.5
				airflow_delay = 50
				airflow_mob_slowdown = 0

			if("ZAS - Dangerous")
				airflow_push=1
				airflow_lightest_pressure = 15
				airflow_light_pressure = 30
				airflow_medium_pressure = 45
				airflow_heavy_pressure = 55
				airflow_dense_pressure = 70
				airflow_stun_pressure = 50
				airflow_stun_cooldown = 50
				airflow_stun = 2
				airflow_damage = 3
				airflow_speed_decay = 1.2
				airflow_delay = 25
				airflow_mob_slowdown = 2

			if("ZAS - Hellish")
				airflow_push=1
				airflow_lightest_pressure = 20
				airflow_light_pressure = 30
				airflow_medium_pressure = 40
				airflow_heavy_pressure = 50
				airflow_dense_pressure = 60
				airflow_stun_pressure = 40
				airflow_stun_cooldown = 40
				airflow_stun = 3
				airflow_damage = 4
				airflow_speed_decay = 1
				airflow_delay = 20
				airflow_mob_slowdown = 3


		world << "\blue <b>[key_name(user)] changed the global plasma/ZAS settings to \"[def]\"</b>"

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
		var/newvalue
		if("[V]_RANDOM" in vars)
			if(isnum(vars["[V]_RANDOM"]))
				newvalue = prob(vars["[V]_RANDOM"])
			else if(istext(vars["[V]_RANDOM"]))
				var/txt = vars["[V]_RANDOM"]
				if(findtextEx(txt,"PROB"))
					txt = text2list(txt,"/")
					txt[1] = replacetext(txt[1],"PROB","")
					var/p = text2num(txt[1])
					var/r = txt[2]
					if(prob(p))
						newvalue = roll(r)
					else
						newvalue = vars[V]
				else if(findtextEx(txt,"PICK"))
					txt = replacetext(txt,"PICK","")
					txt = text2list(txt,",")
					newvalue = pick(txt)
				else
					newvalue = roll(txt)
			else
				newvalue = vars[V]
			vars[V] = newvalue
