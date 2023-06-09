//clock cult
/atom/movable/screen/alert/clocksense
	name = "The Ark of the Clockwork Justicar"
	desc = "Shows infomation about the Ark of the Clockwork Justicar"
	icon = 'monkestation/icons/hud/screen_alert.dmi'
	icon_state = "clockinfo"
	alerttooltipstyle = "clockcult"

/atom/movable/screen/alert/clockwork/clocksense/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSprocessing, src)

/atom/movable/screen/alert/clockwork/clocksense/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/atom/movable/screen/alert/clockwork/clocksense/process()
	var/datum/antagonist/clock_cultist/servant = owner.mind.has_antag_datum(/datum/antagonist/clock_cultist)
	if(!(servant?.clock_team))
		message_admins("NOTALERTTEAM")
		return
	if(GLOB.ratvar_risen)
		desc = "<b>RAT'VAR HAS RISEN.<b>"
		return
	desc = "Stored Power - <b>[display_power(GLOB.clock_power)]</b>.<br>"
	desc += "Stored Vitality - <b>[GLOB.clock_vitality]</b>.<br>"
/*	if(GLOB.ratvar_arrival_tick) ARK STUFF HERE
		if(GLOB.ratvar_arrival_tick - world.time > 6000)
			desc += "The Ark is preparing to open, it will activate in <b>[round((GLOB.ratvar_arrival_tick - world.time - 6000) / 10)]</b> seconds.<br>"
		else
			desc += "Ratvar will rise in <b>[round((GLOB.ratvar_arrival_tick - world.time) / 10)]</b> seconds, protect the Ark with your life!<br>" */
/*	if(GLOB.human_servants_of_ratvar) SERVANT STUFF HERE
		desc += "There [GLOB.human_servants_of_ratvar.len == 1?"is" : "are"] currently [GLOB.human_servants_of_ratvar.len] loyal servant\s.<br>"
	if(GLOB.critical_servant_count)
		desc += "Upon reaching [GLOB.critical_servant_count] servants, the Ark will open, or it can be opened immediately by invoking Gateway Activation with 6 servants."*/
