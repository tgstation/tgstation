///////////////
// JUDGEMENT //
///////////////

//Ark of the Clockwork Justiciar: Creates a Gateway to the Celestial Derelict, either summoning ratvar or proselytizing everything.
/datum/clockwork_scripture/ark_of_the_clockwork_justiciar
	descname = "Structure, Win Condition"
	name = "Ark of the Clockwork Justiciar"
	desc = "Tears apart a rift in spacetime to Reebe, the Celestial Derelict.\n\
	This gateway will either call forth Ratvar from his exile if that is the task He has set you, or proselytize the entire station if it is not."
	invocations = list("ARMORER! FRIGHT! AMPERAGE! VANGUARD! I CALL UPON YOU!!", \
	"THE TIME HAS COME FOR OUR MASTER TO BREAK THE CHAINS OF EXILE!!", \
	"LEND US YOUR AID! ENGINE COMES!!")
	channel_time = 150
	required_components = list(BELLIGERENT_EYE = 10, VANGUARD_COGWHEEL = 10, GEIS_CAPACITOR = 10, REPLICANT_ALLOY = 10, HIEROPHANT_ANSIBLE = 10)
	consumed_components = list(BELLIGERENT_EYE = 10, VANGUARD_COGWHEEL = 10, GEIS_CAPACITOR = 10, REPLICANT_ALLOY = 10, HIEROPHANT_ANSIBLE = 10)
	invokers_required = 5
	multiple_invokers_used = TRUE
	usage_tip = "The gateway is completely vulnerable to attack during its five-minute duration. It will periodically give indication of its general position to everyone on the station \
	as well as being loud enough to be heard throughout the entire sector. Defend it with your life!"
	tier = SCRIPTURE_JUDGEMENT
	sort_priority = 1

/datum/clockwork_scripture/ark_of_the_clockwork_justiciar/New()
	if(ticker && ticker.mode && ticker.mode.clockwork_objective != CLOCKCULT_GATEWAY)
		invocations = list("ARMORER! FRIGHT! AMPERAGE! VANGUARD! I CALL UPON YOU!!", \
		"THIS STATION WILL BE A BEACON OF HOPE IN THE DARKNESS OF SPACE!!", \
		"HELP US MAKE THIS SHOW ENGINE'S GLORY!!")
	..()

/datum/clockwork_scripture/ark_of_the_clockwork_justiciar/check_special_requirements()
	if(!slab.no_cost)
		if(ratvar_awakens)
			invoker << "<span class='big_brass'>\"I am already here, idiot.\"</span>"
			return FALSE
		for(var/obj/structure/destructible/clockwork/massive/celestial_gateway/G in all_clockwork_objects)
			var/area/gate_area = get_area(G)
			invoker << "<span class='userdanger'>There is already a gateway at [gate_area.map_name]!</span>"
			return FALSE
		var/area/A = get_area(invoker)
		var/turf/T = get_turf(invoker)
		if(!T || T.z != ZLEVEL_STATION || istype(A, /area/shuttle) || !A.blob_allowed)
			invoker << "<span class='warning'>You must be on the station to activate the Ark!</span>"
			return FALSE
		if(clockwork_gateway_activated)
			if(ticker && ticker.mode && ticker.mode.clockwork_objective != CLOCKCULT_GATEWAY)
				invoker << "<span class='nezbere'>\"Look upon his works. Is it not glorious?\"</span>"
			else
				invoker << "<span class='warning'>Ratvar's recent banishment renders him too weak to be wrung forth from Reebe!</span>"
			return FALSE
	return TRUE

/datum/clockwork_scripture/ark_of_the_clockwork_justiciar/scripture_effects()
	var/turf/T = get_turf(invoker)
	if(T)
		new/obj/structure/destructible/clockwork/massive/celestial_gateway(T)
		return TRUE
	return FALSE
