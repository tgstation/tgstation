/mob/living/silicon/ai
	name = "AI"
	voice_name = "synthesized voice"
	icon = 'mob.dmi'//
	icon_state = "ai"
	anchored = 1 // -- TLE
	var/network = "SS13"
	var/obj/machinery/camera/current = null
	var/list/connected_robots = list()
	var/aiRestorePowerRoutine = 0
	var/datum/ai_laws/laws_object = null
	//var/list/laws = list()
	var/alarms = list("Motion"=list(), "Fire"=list(), "Atmosphere"=list(), "Power"=list())
	var/viewalerts = 0


	var/datum/game_mode/malfunction/AI_Module/module_picker/malf_picker
	var/processing_time = 100
	var/list/datum/game_mode/malfunction/AI_Module/current_modules = list()
	var/fire_res_on_core = 0

	var/control_disabled = 0 // Set to 1 to stop AI from interacting via Click() -- TLE