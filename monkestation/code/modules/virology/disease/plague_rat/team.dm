GLOBAL_VAR_INIT(static_plague_team, null)

/datum/team/plague_rat
	name = "Plague Rats"
	member_name = "plague rat"

	var/disease_id = ""
	var/datum/disease/advanced/bacteria/plague
	var/turf/invasion
	var/list/hud_icons = list("plague-logo")
	var/logo_state = "plague-logo"

/datum/team/plague_rat/proc/setup_diseases()
	GLOB.static_plague_team = src
	if (!plague)
		plague = new

		var/list/anti = list(
			ANTIGEN_BLOOD	= 0,
			ANTIGEN_COMMON	= 0,
			ANTIGEN_RARE	= 1,
			ANTIGEN_ALIEN	= 2,
			)
		var/list/bad = list(
			EFFECT_DANGER_HELPFUL	= 0,
			EFFECT_DANGER_FLAVOR	= 0,
			EFFECT_DANGER_ANNOYING	= 1,
			EFFECT_DANGER_HINDRANCE	= 1,
			EFFECT_DANGER_HARMFUL	= 3,
			EFFECT_DANGER_DEADLY	= 5,
			)
		if(prob(2)) //Dan's Discount products are notoriously bad
			plague.origin = "Discount Dan's Gas Station Sushi"
		else if(prob(3))
			plague.origin = pick("Nurgle's Cauldron", "Public Bathroom", "Thrax",
								"A spaceman got a mouse disease, this is what happened to his body")
		else
			plague.origin = pick("Black Plague", "Javorian Pox", "Gray Death", "Doom of Pandyssia", "Thrassian Plague",
								"Redlight", "Khaara Bacterium", "MEV-1")

		plague.spread_flags = DISEASE_SPREAD_BLOOD|DISEASE_SPREAD_CONTACT_FLUIDS|DISEASE_SPREAD_CONTACT_SKIN|DISEASE_SPREAD_AIRBORNE //gotta ensure that our mice can spread that disease

		plague.infectivity = 75
		plague.color = "#ADAEAA"
		plague.pattern = 3
		plague.pattern_color = "#EE9A9C"
		plague.max_stages = 4 //4 stages, unlocks the really dangerous symptoms rather than just DNA Degradation
		plague.speed = 2 //Takes about 100 seconds to advance to the next stage, max stage in 5 minutes

		plague.makerandom(list(90,100),list(40,75),anti,bad,null)
		for(var/datum/symptom/e in plague.symptoms)
			e.chance *= 2 //More likely to trigger symptoms per tick

		disease_id = "[plague.uniqueID]-[plague.subID]"

	if (!invasion)
		var/list/found_vents = list()
		for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/temp_vent in GLOB.machines)
			var/turf/scrubber_turf = get_turf(temp_vent)
			if(!is_station_level(scrubber_turf.z))
				continue
			found_vents.Add(temp_vent)
		if(length(found_vents))
			invasion = get_turf(pick(found_vents))
		else
			var/area/kitchen = locate(/area/station/service/kitchen)
			var/list/turf/open/floors = list()
			for(var/turf/open/floor/F in kitchen)
				floors += F
			invasion = pick(floors)//or any floor really. And if your station has no kitchen then you don't deserve those mice.

	var/datum/objective/plague/new_plague = new
	new_plague.disease_id = disease_id
	add_objective(new_plague)


/datum/team/plague_rat/proc/update_hud_icons(offset = 0, factions_with_icons = 0)
	//let's remove every icons
	for(var/datum/mind/R in members)
		if(R.current && R.current.client)
			for(var/image/I in R.current.client.images)
				if(I.icon_state in hud_icons)
					R.current.client.images -= I

	//then re-add them
	for(var/datum/mind/R in members)
		if(R.current && R.current && R.current.client)
			for (var/mob/living/L in GLOB.mob_living_list)//except instead of just tracking our fellow plague mice, let's track everyone that's been infected with our plague
				if (length(L.diseases))
					for(var/datum/disease/disease in L.diseases)
						if("[disease.uniqueID]-[disease.subID]" != disease_id)
							continue
						var/imageloc = L
						if(istype(L.loc,/obj/vehicle/sealed/mecha))
							imageloc = L.loc
						var/image/I = image('monkestation/code/modules/virology/icons/role_HUD_icons.dmi', loc = imageloc, icon_state = logo_state)
						I.pixel_x = 20
						I.pixel_y = 20
						I.plane = HUD_PLANE
						I.appearance_flags |= RESET_COLOR|RESET_ALPHA
						R.current.client.images += I
