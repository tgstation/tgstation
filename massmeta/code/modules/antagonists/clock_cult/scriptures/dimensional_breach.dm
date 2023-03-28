//==================================//
// !      Dimensional Breach      ! //
//==================================//
/datum/clockcult/scripture/ark_activation
	name = "Dimensional Breach"
	desc = "Breaches the verge between Reebe and the station, activating The Ark and announcing about your existence."
	tip = "Activates The Ark and announcing about your existence."
	button_icon_state = "Spatial Gateway"
	power_cost = 5000
	invokation_time = 140
	invokation_text = list("О, великий двигатель, забери мою душу...", "тебе пора вставать...", "через трещины ты придёшь...", "чтобы снова подняться среди звезд!")
	invokers_required = 6
	category = SPELLTYPE_SERVITUDE
	recital_sound = 'sound/magic/clockwork/narsie_attack.ogg'

/datum/clockcult/scripture/ark_activation/New()
	. = ..()

/datum/clockcult/scripture/ark_activation/check_special_requirements()
	if(!..())
		return FALSE
	var/area/AR = get_area(invoker)
	if(!is_station_level(AR.z))
		to_chat(invoker, span_brass("You need to be at the station in order to breach the dimension!"))
		return FALSE
	return TRUE

/datum/clockcult/scripture/ark_activation/invoke_success()
	var/obj/structure/destructible/clockwork/massive/celestial_gateway/gateway = GLOB.celestial_gateway
	if(!gateway)
		to_chat(invoker, span_brass("Пук."))
		return FALSE
	gateway.open_gateway()
