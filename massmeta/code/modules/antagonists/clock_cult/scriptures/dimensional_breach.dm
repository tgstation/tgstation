//==================================//
// !      Dimensional Breach      ! //
//==================================//
/datum/clockcult/scripture/ark_activation
	name = "Активировать Ковчег"
	desc = "Подготавливает Ковчег к активации, предупреждая экипаж о вашем существовании. Требуется 6 вызывающих."
	tip = "Подготавливает Ковчег к активации, предупреждая экипаж о вашем существовании."
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
	if(!is_reebe(AR.z))
		to_chat(invoker, span_brass("Нужно быть рядом с Ковчегом!"))
		return FALSE
	return TRUE

/datum/clockcult/scripture/ark_activation/invoke_success()
	var/obj/structure/destructible/clockwork/massive/celestial_gateway/gateway = GLOB.celestial_gateway
	if(!gateway)
		to_chat(invoker, span_brass("Пук."))
		return FALSE
	gateway.open_gateway()
