///////////////
// JUDGEMENT //
///////////////

//Ark of the Clockwork Justiciar: Creates a Gateway to the Celestial Derelict, either summoning ratvar or proselytizing everything.
/datum/clockwork_scripture/ark_of_the_clockwork_justiciar
	descname = "Win Condition"
	name = "Ark of the Clockwork Justiciar"
	desc = "Pulls from the power of all of Ratvar's servants and generals to construct a massive machine used to tear apart a rift in spacetime to Reebe, the Celestial Derelict.\n\
	This gateway will either call forth Ratvar from his exile if that is the task he has set you, or proselytize the entire station if it is not."
	invocations = list("ARMORER! FRIGHT! AMPERAGE! VANGUARD! I CALL UPON YOU!!", \
	"THE TIME HAS COME FOR OUR MASTER TO BREAK THE CHAINS OF EXILE!!", \
	"LEND US YOUR AID! ENGINE COMES!!")
	channel_time = 150
	required_components = list(BELLIGERENT_EYE = 10, VANGUARD_COGWHEEL = 10, GUVAX_CAPACITOR = 10, REPLICANT_ALLOY = 10, HIEROPHANT_ANSIBLE = 10)
	consumed_components = list(BELLIGERENT_EYE = 10, VANGUARD_COGWHEEL = 10, GUVAX_CAPACITOR = 10, REPLICANT_ALLOY = 10, HIEROPHANT_ANSIBLE = 10)
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
		if(!T || T.z != ZLEVEL_STATION || istype(A, /area/shuttle))
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
	new/obj/effect/clockwork/general_marker/inathneq(T)
	if(ticker && ticker.mode && ticker.mode.clockwork_objective == CLOCKCULT_GATEWAY)
		T.visible_message("<span class='inathneq'>\"[text2ratvar("Engine, come forth and show your servants your mercy!")]\"</span>")
	else
		T.visible_message("<span class='inathneq'>\"[text2ratvar("We will show all the mercy of Engine!")]\"</span>")
	playsound(T, 'sound/magic/clockwork/invoke_general.ogg', 30, 0)
	sleep(10)
	if(!check_special_requirements())
		return FALSE
	new/obj/effect/clockwork/general_marker/sevtug(T)
	if(ticker && ticker.mode && ticker.mode.clockwork_objective == CLOCKCULT_GATEWAY)
		T.visible_message("<span class='sevtug'>\"[text2ratvar("Engine, come forth and show this station your decorating skills!")]\"</span>")
	else
		T.visible_message("<span class='sevtug'>\"[text2ratvar("We will show all Engine's decorating skills.")]\"</span>")
	playsound(T, 'sound/magic/clockwork/invoke_general.ogg', 45, 0)
	sleep(10)
	if(!check_special_requirements())
		return FALSE
	new/obj/effect/clockwork/general_marker/nezbere(T)
	if(ticker && ticker.mode && ticker.mode.clockwork_objective == CLOCKCULT_GATEWAY)
		T.visible_message("<span class='nezbere'>\"[text2ratvar("Engine, come forth and shine your light across this realm!!")]\"</span>")
	else
		T.visible_message("<span class='nezbere'>\"[text2ratvar("We will show all Engine's light!!")]\"</span>")
	playsound(T, 'sound/magic/clockwork/invoke_general.ogg', 60, 0)
	sleep(10)
	if(!check_special_requirements())
		return FALSE
	new/obj/effect/clockwork/general_marker/nzcrentr(T)
	if(ticker && ticker.mode && ticker.mode.clockwork_objective == CLOCKCULT_GATEWAY)
		T.visible_message("<span class='nzcrentr'>\"[text2ratvar("Engine, come forth.")]\"</span>")
	else
		T.visible_message("<span class='nezbere'>\"[text2ratvar("We will show all Engine's power!")]\"</span>")
	playsound(T, 'sound/magic/clockwork/invoke_general.ogg', 75, 0)
	sleep(10)
	if(check_special_requirements())
		var/obj/structure/destructible/clockwork/massive/celestial_gateway/CG = new/obj/structure/destructible/clockwork/massive/celestial_gateway(T)
		if(ticker && ticker.mode && ticker.mode.clockwork_objective != CLOCKCULT_GATEWAY)
			CG.ratvar_portal = FALSE
			hierophant_message("<span class='big_brass'>This newly constructed gateway will not free Ratvar, \
			and will instead simply proselytize and convert everything and everyone on the station.</span>", TRUE)
		playsound(T, 'sound/magic/clockwork/invoke_general.ogg', 100, 0)
		var/list/open_turfs = list()
		for(var/turf/open/OT in orange(1, T))
			var/list/dense_objects = list()
			for(var/obj/O in OT)
				if(O.density && !O.CanPass(invoker, OT, 5))
					dense_objects |= O
			if(!dense_objects.len)
				open_turfs |= OT
		if(open_turfs.len)
			for(var/mob/living/L in T)
				L.forceMove(pick(open_turfs)) //shove living mobs off of the gate's new location
		return TRUE
	return FALSE
