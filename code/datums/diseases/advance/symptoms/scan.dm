/*
//////////////////////////////////////

Observer Effect

//////////////////////////////////////
*/

/datum/symptom/observer
	name = "Observer Effect"
	desc = "The virus gains stages when exposed to rays emitted by health analyzers. Advanced analyzers do not trigger it."
	stealth = 1
	resistance = 2
	stage_speed = -2
	transmittable = 1
	level = 3
	severity = 1
	threshold_desc = "<b>Stage Speed 5:</b> Maximizes the stage when scanned.<br>\
					  <b>Stealth 4:</b> Hides the effect."

	var/maximize = FALSE
	var/hide_message = FALSE

/datum/symptom/observer/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stage_rate"] >= 5)
		maximize = TRUE
	if(A.properties["stealth"] >= 4)
		hide_message = TRUE

/datum/symptom/observer/OnScan(datum/disease/advance/A, obj/item/healthanalyzer/HA)
	if(!..())
		return
	if(maximize)
		A.stage = A.max_stages
	else
		A.stage = min(A.stage + 2, A.max_stages)
	if(!hide_message)
		var/mob/living/M = A.affected_mob
		to_chat(M, "<span class='warning'>Your body aches as it is analyzed.</span>")

/*
//////////////////////////////////////

Theracian RNA

//////////////////////////////////////
*/

/datum/symptom/scan_defense
	name = "Theracian RNA"
	desc = "The virus triggers an obscure software bug in Nanotrasen-brand health analyzers, destroying them when scanned. More recent analyzer models are unaffected."
	stealth = 0
	resistance = 1
	stage_speed = -2
	transmittable = -1
	level = 7
	severity = 5
	threshold_desc = "<b>Resistance 10:</b> Increases explosion radius.<br>"

/datum/symptom/scan_defense/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["resistance"] >= 10)
		power = 2

/datum/symptom/scan_defense/OnScan(datum/disease/advance/A, obj/item/healthanalyzer/HA)
	if(!..())
		return
	if(A.stage > 1)
		HA.visible_message("<span class='danger'>The [HA.name] explodes!</span>")
		var/range = max(1, round(power * A.stage / A.max_stages))
		explosion(get_turf(HA), 0, 0, range, range)
		qdel(HA)
