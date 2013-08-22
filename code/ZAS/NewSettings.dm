/***************************
* FUCKING EXPERIMENTAL WILL EAT YOUR CHILDREN
****************************

Okay, so VariableSettings is a mess of spaghetticode.

This is an attempt to fix that by using getters and
	setters instead of stupidity.  It may or may
	not work, but dammit, it's better than hackery.
*/

var/global/ZAS_Settings/vsc = new

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

/**
* ZAS Settings
*
* Stores our settings for ZAS in an editable form.
* @author N3X15 <nexis@7chan.org>
* @package SS13
* @subpackage ZAS
*/
/ZAS_Settings
	var/list/datum/ZAS_Setting/settings = list()
	pl_control/plc = new()

/ZAS_Settings/New()
	.=..()
	for(var/S in typesof(/datum/ZAS_Setting) - /datum/ZAS_Setting)
		testing("Creating [S]")
		var/id=idfrompath("[S]")
		settings[id]=new S

/ZAS_Settings/proc/idfrompath(var/str)
	return replacetext(str,"/datum/ZAS_Setting/","")

/ZAS_Settings/proc/Set(var/id, var/value)
	var/datum/ZAS_Setting/setting = settings[id]
	switch(setting.valtype)
		if(ZAS_TYPE_NUMERIC)
			setting.value = input(user,"Enter a number:","Settings",newvar) as num
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
			setting.value = !newvar
		/*
		if(ZAS_TYPE_STRING)
			setting.value = input(user,"Enter text:","Settings",newvar) as message
		*/
		else
			error("[S] has an invalid type.  Enjoy your hard crash bb.")
			var/lol=1/0
			error("[lol]") // Just in case this compiler optimizes out unused vars.

/ZAS_Settings/proc/Get(var/id)
	return settings[id].value

/ZAS_Settings/proc/ChangeSettingsDialog(mob/user,list/L)
	//var/which = input(user,"Choose a setting:") in L
	var/dat = "<dl>"
	for(var/datum/ZAS_Setting/s in settings)
		dat += "<dt><b>[s.name] = [s.value]</b> <A href='?src=\ref[src];changevar=[idfrompath(s.type)]'>\[Change\]</A></dt>"
		dat += "<dd>[s.desc]</i></dd>"
	dat += "</dl>"
	user << browse(dat,"window=settings")

/ZAS_Settings/Topic(href,href_list)
	if("changevar" in href_list)
		ChangeSetting(usr,href_list["changevar"])