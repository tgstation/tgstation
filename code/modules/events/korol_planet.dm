GLOBAL_VAR_INIT(korolized, FALSE)
GLOBAL_LIST_EMPTY(korol_sacrifices)

/datum/round_event_control/korol
	name = "Korol is watching you"
	typepath = /datum/round_event/korol
	max_occurrences = 0

/datum/round_event/korol/start()
	GLOB.korolized = TRUE
	for(var/i in GLOB.player_list)
		var/mob/M = i
		M.hud_used.update_parallax_pref(M)

/obj/structure/altar_of_korol
	name = "\improper Altar of Korol"
	desc = "An altar which allows you to pay off your debts."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "convertaltar-red"
	density = TRUE
	anchored = TRUE
	layer = TABLE_LAYER
	climbable = TRUE
	pass_flags = LETPASSTHROW
	can_buckle = TRUE
	buckle_lying = 90 //we turn to you!

/obj/structure/altar_of_korol/attackby(obj/item/I, mob/user, params) //if you can carry it, fuck it why not
	if(I.GetComponent(/datum/component/stationloving))
		to_chat(user, "<span class='nicegreen'>This cannot leave the mortal realm!</span>")
		return
	GLOB.korol_sacrifices[I.type] += 1
	qdel(I)
	to_chat(user, "<span class='nicegreen'>You have sacrificed to the mighty Korol Head.</span>")
	SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "korol_sac", /datum/mood_event/blessing_korol)
