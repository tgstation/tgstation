///////////////
// JUDGEMENT //
///////////////

//Ark of the Clockwork Justiciar: Creates a Gateway to the Celestial Derelict, summoning ratvar.
/datum/clockwork_scripture/create_object/ark_of_the_clockwork_justiciar
	descname = "Structure, Win Condition"
	name = "Ark of the Clockwork Justiciar"
	desc = "Tears apart a rift in spacetime to Reebe, the Celestial Derelict, using a massive amount of components.\n\
	This gateway will, after some time, call forth Ratvar from his exile and massively empower all scriptures and tools."
	invocations = list("ARMORER! FRIGHT! AMPERAGE! VANGUARD! I CALL UPON YOU!!", \
	"THE TIME HAS COME FOR OUR MASTER TO BREAK THE CHAINS OF EXILE!!", \
	"LEND US YOUR AID! ENGINE COMES!!")
	channel_time = 150
	consumed_components = list(BELLIGERENT_EYE = ARK_SUMMON_COST, VANGUARD_COGWHEEL = ARK_SUMMON_COST, GEIS_CAPACITOR = ARK_SUMMON_COST, REPLICANT_ALLOY = ARK_SUMMON_COST, HIEROPHANT_ANSIBLE = ARK_SUMMON_COST)
	invokers_required = 6
	multiple_invokers_used = TRUE
	object_path = /obj/structure/destructible/clockwork/massive/celestial_gateway
	creator_message = null
	usage_tip = "The gateway is completely vulnerable to attack during its five-minute duration. It will periodically give indication of its general position to everyone on the station \
	as well as being loud enough to be heard throughout the entire sector. Defend it with your life!"
	tier = SCRIPTURE_JUDGEMENT
	sort_priority = 1

/datum/clockwork_scripture/create_object/ark_of_the_clockwork_justiciar/check_special_requirements()
	if(!slab.no_cost)
		if(ratvar_awakens)
			to_chat(invoker, "<span class='big_brass'>\"I am already here, idiot.\"</span>")
			return FALSE
		for(var/obj/structure/destructible/clockwork/massive/celestial_gateway/G in all_clockwork_objects)
			var/area/gate_area = get_area(G)
			to_chat(invoker, "<span class='userdanger'>There is already an Ark at [gate_area.map_name]!</span>")
			return FALSE
		var/area/A = get_area(invoker)
		var/turf/T = get_turf(invoker)
		if(!T || T.z != ZLEVEL_STATION || istype(A, /area/shuttle) || !A.blob_allowed)
			to_chat(invoker, "<span class='warning'>You must be on the station to activate the Ark!</span>")
			return FALSE
		if(clockwork_gateway_activated)
			to_chat(invoker, "<span class='warning'>Ratvar's recent banishment renders him too weak to be wrung forth from Reebe!</span>")
			return FALSE
	return ..()
