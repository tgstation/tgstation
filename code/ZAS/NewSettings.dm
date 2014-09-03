/*
ZAS Settings System 2.0

Okay, so VariableSettings is a mess of spaghetticode and
	is about as flexible as a grandmother covered in
	starch.

This is an attempt to fix that by using getters and
	setters instead of stupidity.  It's a little more difficult
	to code with, but dammit, it's better than hackery.

NOTE:  plc was merged into the main settings.  We can set up
        visual groups later.

HOW2GET:
	zas_setting.Get(/datum/ZAS_Setting/herp)

HOW2SET:
	zas_setting.Set(/datum/ZAS_Setting/herp, "dsfargeg")
*/

var/global/ZAS_Settings/zas_settings = new

#define ZAS_TYPE_UNDEFINED -1
#define ZAS_TYPE_BOOLEAN 0
#define ZAS_TYPE_NUMERIC 1

/**
* ZAS Setting Datum
*
* Stores a single setting.
* @author N3X15 <nexis@7chan.org>
* @package SS13
* @subpackage ZAS
*/
/datum/ZAS_Setting/
	var/name="Clown" // Friendly name.
	var/desc="Honk"
	var/value=null
	var/valtype=ZAS_TYPE_UNDEFINED

/datum/ZAS_Setting/fire_consumption_rate
	name = "Fire - Air Consumption Ratio"
	desc = "Ratio of air removed and combusted per tick."
	valtype=ZAS_TYPE_NUMERIC
	value = 0.75

/datum/ZAS_Setting/fire_firelevel_multiplier
	value = 25
	name = "Fire - Firelevel Constant"
	desc = "Multiplied by the equation for firelevel, affects mainly the extingiushing of fires."
	valtype=ZAS_TYPE_NUMERIC

/datum/ZAS_Setting/fire_fuel_energy_release
	value = 550000
	name = "Fire - Fuel energy release"
	desc = "The energy in joule released when burning one mol of a burnable substance"
	valtype=ZAS_TYPE_NUMERIC

/datum/ZAS_Setting/airflow_lightest_pressure
	value = 20
	name = "Airflow - Small Movement Threshold %"
	desc = "Percent of 1 Atm. at which items with the small weight classes will move."
	valtype=ZAS_TYPE_NUMERIC

/datum/ZAS_Setting/airflow_light_pressure
	value = 35
	name = "Airflow - Medium Movement Threshold %"
	desc = "Percent of 1 Atm. at which items with the medium weight classes will move."
	valtype=ZAS_TYPE_NUMERIC

/datum/ZAS_Setting/airflow_medium_pressure
	value = 50
	name = "Airflow - Heavy Movement Threshold %"
	desc = "Percent of 1 Atm. at which items with the largest weight classes will move."
	valtype=ZAS_TYPE_NUMERIC

/datum/ZAS_Setting/airflow_heavy_pressure
	value = 65
	name = "Airflow - Mob Movement Threshold %"
	desc = "Percent of 1 Atm. at which mobs will move."
	valtype=ZAS_TYPE_NUMERIC

/datum/ZAS_Setting/airflow_dense_pressure
	value = 85
	name = "Airflow - Dense Movement Threshold %"
	desc = "Percent of 1 Atm. at which items with canisters and closets will move."
	valtype=ZAS_TYPE_NUMERIC

/datum/ZAS_Setting/airflow_stun_pressure
	value = 60
	name = "Airflow - Mob Stunning Threshold %"
	desc = "Percent of 1 Atm. at which mobs will be stunned by airflow."
	valtype=ZAS_TYPE_NUMERIC

/datum/ZAS_Setting/airflow_stun_cooldown
	value = 60
	name = "Aiflow Stunning - Cooldown"
	desc = "How long, in tenths of a second, to wait before stunning them again."
	valtype=ZAS_TYPE_NUMERIC

/datum/ZAS_Setting/airflow_stun
	value = 1
	name = "Airflow Impact - Stunning"
	desc = "How much a mob is stunned when hit by an object."
	valtype=ZAS_TYPE_NUMERIC

/datum/ZAS_Setting/airflow_damage
	value = 2
	name = "Airflow Impact - Damage"
	desc = "Damage from airflow impacts."
	valtype=ZAS_TYPE_NUMERIC

/datum/ZAS_Setting/airflow_speed_decay
	value = 1.5
	name = "Airflow Speed Decay"
	desc = "How rapidly the speed gained from airflow decays."
	valtype=ZAS_TYPE_NUMERIC

/datum/ZAS_Setting/airflow_delay
	value = 30
	name = "Airflow Retrigger Delay"
	desc = "Time in deciseconds before things can be moved by airflow again."
	valtype=ZAS_TYPE_NUMERIC

/datum/ZAS_Setting/airflow_mob_slowdown
	value = 1
	name = "Airflow Slowdown"
	desc = "Time in tenths of a second to add as a delay to each movement by a mob if they are fighting the pull of the airflow."
	valtype=ZAS_TYPE_NUMERIC

// N3X15 - Added back in so we can tweak performance.
/datum/ZAS_Setting/airflow_push
	name="Airflow - Push"
	value = 0
	desc="1=yes please rape my server, 0=no"
	valtype=ZAS_TYPE_BOOLEAN

/datum/ZAS_Setting/connection_insulation
	value = 0.4
	name = "Connections - Insulation"
	desc = "How insulative a connection is, in terms of heat transfer.  1 is perfectly insulative, and 0 is perfectly conductive."
	valtype=ZAS_TYPE_NUMERIC

/datum/ZAS_Setting/connection_temperature_delta
	value = 10
	name = "Connections - Temperature Difference"
	desc = "The smallest temperature difference which will cause heat to travel through doors."
	valtype=ZAS_TYPE_NUMERIC

// N3X15 - Ice is disabled by default, per Pomf's request.
/datum/ZAS_Setting/ice_formation
	name="Airflow - Enable Ice Formation"
	value = 0
	desc="1=yes, 0=no - Slippin' and slidin' when pressure &gt; 10kPa and temperature &lt; 273K"
	valtype=ZAS_TYPE_BOOLEAN

/datum/ZAS_Setting/space_isnt_cold
	name="Airflow - Disable Cold Space"
	value = 0 // Pomf requested
	desc="1=yes, 0=no - Disables space behaving as being very fucking cold (0K)."
	valtype=ZAS_TYPE_BOOLEAN


///////////////////////////////////////
// PLASMA SHIT
///////////////////////////////////////
// ALL CAPS BECAUSE PLASMA IS HARDCORE YO
// And I'm too lazy to fix the refs.

/datum/ZAS_Setting/PLASMA_DMG
	name = "Plasma Damage Amount"
	desc = "Self Descriptive"
	value = 3
	valtype=ZAS_TYPE_NUMERIC

/datum/ZAS_Setting/CLOTH_CONTAMINATION
	name = "Cloth Contamination"
	desc = "If this is on, plasma does damage by getting into cloth."
	value = 1
	valtype=ZAS_TYPE_BOOLEAN

/datum/ZAS_Setting/PLASMAGUARD_ONLY
	name = "PlasmaGuard Only"
	desc = "If this is on, only biosuits and spacesuits protect against contamination and ill effects."
	value = 0
	valtype=ZAS_TYPE_BOOLEAN

/datum/ZAS_Setting/GENETIC_CORRUPTION
	name = "Genetic Corruption Chance"
	desc = "Chance of genetic corruption as well as toxic damage, X in 10,000."
	value = 0
	valtype=ZAS_TYPE_BOOLEAN

/datum/ZAS_Setting/SKIN_BURNS
	name = "Skin Burns"
	desc = "Plasma has an effect similar to mustard gas on the un-suited."
	value = 0
	valtype=ZAS_TYPE_BOOLEAN

/datum/ZAS_Setting/EYE_BURNS
	name = "Eye Burns"
	desc = "Plasma burns the eyes of anyone not wearing eye protection."
	value = 1
	valtype=ZAS_TYPE_BOOLEAN

/datum/ZAS_Setting/CONTAMINATION_LOSS
	name = "Contamination Loss"
	desc = "How much toxin damage is dealt from contaminated clothing"
	value = 0.02 //Per tick?  ASK ARYN
	valtype=ZAS_TYPE_NUMERIC

/datum/ZAS_Setting/PLASMA_HALLUCINATION
	name = "Plasma Hallucination"
	desc = "Does being in plasma cause you to hallucinate?"
	value = 0
	valtype=ZAS_TYPE_BOOLEAN

/datum/ZAS_Setting/N2O_HALLUCINATION
	name = "N2O Hallucination"
	desc = "Does being in sleeping gas cause you to hallucinate?"
	value = 1
	valtype=ZAS_TYPE_BOOLEAN

/**
* ZAS Settings
*
* Stores our settings for ZAS in an editable form.
* @author N3X15 <nexis@7chan.org>
* @package SS13
* @subpackage ZAS
*/
/ZAS_Settings
	// INTERNAL USE ONLY
	var/list/datum/ZAS_Setting/settings = list()

/ZAS_Settings/New()
	.=..()
	for(var/S in typesof(/datum/ZAS_Setting) - /datum/ZAS_Setting)
		var/id=idfrompath("[S]")
		//testing("Creating zas_settings\[[id]\] = new [S]")
		src.settings[id]=new S


	if(fexists("config/ZAS.txt") == 0)
		Save()
	Load()

/ZAS_Settings/proc/Save()
	var/F = file("config/ZAS.txt")
	fdel(F)
	for(var/id in src.settings)
		var/datum/ZAS_Setting/setting = src.settings[id]
		F << "# [setting.name]"
		F << "#   [setting.desc]"
		F << "[id] [setting.value]"
		F << ""

/ZAS_Settings/proc/Load()
	for(var/t in file2list("config/ZAS.txt"))
		if(!t)	continue

		t = trim(t)
		if (length(t) == 0)
			continue
		else if (copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null
		var/value = null

		if (pos)
			name = copytext(t, 1, pos)
			value = copytext(t, pos + 1)
		else
			name = t

		if (!name)
			continue

		src.SetFromConfig(name,value)

// INTERNAL USE ONLY
/ZAS_Settings/proc/idfrompath(const/path)
	return copytext(path, strpos(path, "/") + 1)

// INTERNAL USE ONLY
/ZAS_Settings/proc/ChangeSetting(var/user,var/id)
	var/datum/ZAS_Setting/setting = src.settings[id]
	var/displayedValue=""
	switch(setting.valtype)
		if(ZAS_TYPE_NUMERIC)
			setting.value = input(user,"Enter a number:","Settings",setting.value) as num
			displayedValue="\"[setting.value]\""
		/*
		if(ZAS_TYPE_BITFLAG)
			var/flag = input(user,"Toggle which bit?","Settings") in bitflags
			flag = text2num(flag)
			if(newvar & flag)
				newvar &= ~flag
			else
				newvar |= flag
		*/
		if(ZAS_TYPE_BOOLEAN)
			setting.value = !setting.value
			displayedValue = (setting.value) ? "ON" : "OFF"
		/*
		if(ZAS_TYPE_STRING)
			setting.value = input(user,"Enter text:","Settings",newvar) as message
		*/
		else
			error("[id] has an invalid typeval.")
			return
	world << "\blue <b>[key_name(user)] changed ZAS setting <i>[setting.name]</i> to <i>[displayedValue]</i>.</b>"

	ChangeSettingsDialog(user)

/**
* Set the value of a setting.
*
* Recommended to use the actual type of the setting rather than the ID, since
*  this will allow for the compiler to check the validity of id.  Kinda.
*
* @param id Either the typepath of the desired setting, or the string ID of the setting.
* @param value The value that the setting should be set to.
*/
/ZAS_Settings/proc/Set(var/id, var/value)
	var/datum/ZAS_Setting/setting = src.settings[idfrompath(id)]
	setting.value=value

// INTERNAL USE ONLY
/ZAS_Settings/proc/SetFromConfig(var/id, var/value)
	var/datum/ZAS_Setting/setting = src.settings[id]
	switch(setting.valtype)
		if(ZAS_TYPE_NUMERIC)
			setting.value = text2num(value)
		/*
		if(ZAS_TYPE_BITFLAG)
			var/flag = input(user,"Toggle which bit?","Settings") in bitflags
			flag = text2num(flag)
			if(newvar & flag)
				newvar &= ~flag
			else
				newvar |= flag
		*/
		if(ZAS_TYPE_BOOLEAN)
			setting.value = (value == "1")
		/*
		if(ZAS_TYPE_STRING)
			setting.value = input(user,"Enter text:","Settings",newvar) as message
		*/

/**
* Get a setting.
*
* Recommended to use the actual type of the setting rather than the ID, since
*  this will allow for the compiler to check the validity of id.  Kinda.
*
* @param id Either the typepath of the desired setting, or the string ID of the setting.
* @returns Value of the desired setting
*/
/ZAS_Settings/proc/Get(var/id)
	if(ispath(id))
		id="[id]"
	var/datum/ZAS_Setting/setting = src.settings[idfrompath(id)]
	if(!setting || !istype(setting))
		world.log << "ZAS_SETTING DEBUG: [id] | [idfrompath(id)]"
	return setting.value

/ZAS_Settings/proc/ChangeSettingsDialog(mob/user)
	var/dat = {"
<html>
	<head>
		<title>ZAS Settings 2.0</title>
		<style type="text/css">
body,html {
	background:#666666;
	font-family:sans-serif;
	font-size:smaller;
	color: #cccccc;
}
a { color: white; }
		</style>
	</head>
	<body>
		<h1>ZAS Configuration</h1>
		<p><a href="?src=\ref[src];save=1">Save Settings</a> | <a href="?src=\ref[src];load=1">Load Settings</a></p>
		<p>Please note that changing these settings can and probably will result in death, destruction and mayhem. <b>Change at your own risk.</b></p>
	<dl>"}
	for(var/id in src.settings)
		var/datum/ZAS_Setting/s = src.settings[id]

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\ZAS\NewSettings.dm:393: dat += "<dt><b>[s.name]</b> = <i>[s.value]</i> <A href='?src=\ref[src];changevar=[id]'>\[Change\]</A></dt>"
		dat += {"<dt><b>[s.name]</b> = <i>[s.value]</i> <A href='?src=\ref[src];changevar=[id]'>\[Change\]</A></dt>
			<dd>[s.desc]</i></dd>"}
		// END AUTOFIX
	dat += "</dl></body></html>"
	user << browse(dat,"window=settings")

/ZAS_Settings/Topic(href,href_list)
	if("changevar" in href_list)
		ChangeSetting(usr,href_list["changevar"])
	if("save" in href_list)
		var/sure = input(usr,"Are you sure?  This will overwrite your ZAS configuration!","Overwrite ZAS.txt?", "No") in list("Yes","No")
		if(sure=="Yes")
			Save()
			message_admins("[key_name(usr)] saved ZAS settings to disk.")
	if("load" in href_list)
		var/sure = input(usr,"Are you sure?","Reload ZAS.txt?", "No") in list("Yes","No")
		if(sure=="Yes")
			Load()
			message_admins("[key_name(usr)] reloaded ZAS settings from disk.")

/ZAS_Settings/proc/SetDefault(var/mob/user)
	var/list/setting_choices = list("Plasma - Standard", "Plasma - Low Hazard", "Plasma - High Hazard", "Plasma - Oh Shit!", "ZAS - Normal", "ZAS - Forgiving", "ZAS - Dangerous", "ZAS - Hellish")
	var/def = input(user, "Which of these presets should be used?") as null|anything in setting_choices
	if(!def)
		return
	switch(def)
		if("Plasma - Standard")
			Set("CLOTH_CONTAMINATION",  1)   //If this is on, plasma does damage by getting into cloth.
			Set("PLASMAGUARD_ONLY",     0)
			Set("GENETIC_CORRUPTION",   0)   //Chance of genetic corruption as well as toxic damage, X in 1000.
			Set("SKIN_BURNS",           0)   //Plasma has an effect similar to mustard gas on the un-suited.
			Set("EYE_BURNS",            1)   //Plasma burns the eyes of anyone not wearing eye protection.
			Set("PLASMA_HALLUCINATION", 0)
			Set("CONTAMINATION_LOSS",   0.02)

		if("Plasma - Low Hazard")
			Set("CLOTH_CONTAMINATION",  0) //If this is on, plasma does damage by getting into cloth.
			Set("PLASMAGUARD_ONLY",     0)
			Set("GENETIC_CORRUPTION",   0) //Chance of genetic corruption as well as toxic damage, X in 1000
			Set("SKIN_BURNS",           0) //Plasma has an effect similar to mustard gas on the un-suited.
			Set("EYE_BURNS",            1) //Plasma burns the eyes of anyone not wearing eye protection.
			Set("PLASMA_HALLUCINATION", 0)
			Set("CONTAMINATION_LOSS",   0.01)

		if("Plasma - High Hazard")
			Set("CLOTH_CONTAMINATION",  1) //If this is on, plasma does damage by getting into cloth.
			Set("PLASMAGUARD_ONLY",     0)
			Set("GENETIC_CORRUPTION",   0) //Chance of genetic corruption as well as toxic damage, X in 1000.
			Set("SKIN_BURNS",           1) //Plasma has an effect similar to mustard gas on the un-suited.
			Set("EYE_BURNS",            1) //Plasma burns the eyes of anyone not wearing eye protection.
			Set("PLASMA_HALLUCINATION", 1)
			Set("CONTAMINATION_LOSS",   0.05)

		if("Plasma - Oh Shit!")
			Set("CLOTH_CONTAMINATION",  1) //If this is on, plasma does damage by getting into cloth.
			Set("PLASMAGUARD_ONLY",     1)
			Set("GENETIC_CORRUPTION",   5) //Chance of genetic corruption as well as toxic damage, X in 1000.
			Set("SKIN_BURNS",           1) //Plasma has an effect similar to mustard gas on the un-suited.
			Set("EYE_BURNS",            1) //Plasma burns the eyes of anyone not wearing eye protection.
			Set("PLASMA_HALLUCINATION", 1)
			Set("CONTAMINATION_LOSS",   0.075)

		if("ZAS - Normal")
			Set("airflow_push",              0)
			Set("airflow_lightest_pressure", 20)
			Set("airflow_light_pressure",    35)
			Set("airflow_medium_pressure",   50)
			Set("airflow_heavy_pressure",    65)
			Set("airflow_dense_pressure",    85)
			Set("airflow_stun_pressure",     60)
			Set("airflow_stun_cooldown",     60)
			Set("airflow_stun",              1)
			Set("airflow_damage",            2)
			Set("airflow_speed_decay",       1.5)
			Set("airflow_delay",             30)
			Set("airflow_mob_slowdown",      1)

		if("ZAS - Forgiving")
			Set("airflow_push",              0)
			Set("airflow_lightest_pressure", 45)
			Set("airflow_light_pressure",    60)
			Set("airflow_medium_pressure",   120)
			Set("airflow_heavy_pressure",    110)
			Set("airflow_dense_pressure",    200)
			Set("airflow_stun_pressure",     150)
			Set("airflow_stun_cooldown",     90)
			Set("airflow_stun",              0.15)
			Set("airflow_damage",            0.15)
			Set("airflow_speed_decay",       1.5)
			Set("airflow_delay",             50)
			Set("airflow_mob_slowdown",      0)

		if("ZAS - Dangerous")
			Set("airflow_push",              1)
			Set("airflow_lightest_pressure", 15)
			Set("airflow_light_pressure",    30)
			Set("airflow_medium_pressure",   45)
			Set("airflow_heavy_pressure",    55)
			Set("airflow_dense_pressure",    70)
			Set("airflow_stun_pressure",     50)
			Set("airflow_stun_cooldown",     50)
			Set("airflow_stun",              2)
			Set("airflow_damage",            3)
			Set("airflow_speed_decay",       1.2)
			Set("airflow_delay",             25)
			Set("airflow_mob_slowdown",      2)

		if("ZAS - Hellish")
			Set("airflow_push",              1)
			Set("airflow_lightest_pressure", 20)
			Set("airflow_light_pressure",    30)
			Set("airflow_medium_pressure",   40)
			Set("airflow_heavy_pressure",    50)
			Set("airflow_dense_pressure",    60)
			Set("airflow_stun_pressure",     40)
			Set("airflow_stun_cooldown",     40)
			Set("airflow_stun",              3)
			Set("airflow_damage",            4)
			Set("airflow_speed_decay",       1)
			Set("airflow_delay",             20)
			Set("airflow_mob_slowdown",      3)
	world << "\blue <b>[key_name(usr)] loaded ZAS preset <i>[def]</i></b>"