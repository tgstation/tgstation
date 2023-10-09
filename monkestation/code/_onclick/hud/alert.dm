//clock cult
/atom/movable/screen/alert/clockwork/clocksense
	name = "The Ark of the Clockwork Justicar"
	desc = "Shows infomation about the Ark of the Clockwork Justicar"
	icon = 'monkestation/icons/hud/screen_alert.dmi'
	icon_state = "clockinfo"
//	alerttooltipstyle = "clockwork" //clockwork tooltips are currently broken, this is a known issue on TG

/atom/movable/screen/alert/clockwork/clocksense/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSprocessing, src)

/atom/movable/screen/alert/clockwork/clocksense/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/atom/movable/screen/alert/clockwork/clocksense/process()
	if(GLOB.ratvar_risen)
		desc = "<b>RAT'VAR HAS RISEN.<b>"
		return
	desc = "Stored Power - <b>[display_power(GLOB.clock_power)]</b>.<br>"
	desc += "Stored Vitality - <b>[GLOB.clock_vitality]</b>.<br>"
	desc += "We current have [GLOB.main_clock_cult?.human_servants.len] human servants out of [GLOB.main_clock_cult?.max_human_servants] maximum human servants, \
			 as well as [GLOB.main_clock_cult?.members.len] servants all together.<br>"

	if(GLOB.clock_ark?.charging_for)
		desc += "The Ark will open in [600 - GLOB.clock_ark?.charging_for] seconds!<br>"
		return //we dont care about anchoring crystals at this point

	if(get_charged_anchor_crystals()) //only put this here if we need to use it
		var/datum/objective/anchoring_crystals/crystals_objective = locate() in GLOB.main_clock_cult?.objectives
		if(!crystals_objective)
			return

		var/list/area_list = list()
		for(var/area/added_area in crystals_objective.valid_areas)
			area_list += added_area.get_original_area_name()
		desc += "Additional Anchoring Crystals can be summoned in [english_list(area_list)].<br>"
	else
		desc += "We must summon and protect an Anchoring crystal before the ark may open.<br>"
