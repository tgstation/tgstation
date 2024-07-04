/datum/scripture/ark_activation
	name = "Ark Invigoration"
	desc = "Prepares the Ark for activation, alerting the crew of your existence."
	tip = "Prepares the Ark for activation, alerting the crew of your existence."
	button_icon_state = "Spatial Gateway"
	power_cost = 5000
	invocation_time = 14 SECONDS
	invocation_text = list("Oh bright Eng'ine, take my soul...", "to complete, our great goal...", "through the rifts you shall come...", "they will see where the light is from!")
	invokers_required = 6
	category = SPELLTYPE_PRESERVATION
	recital_sound = 'sound/magic/clockwork/narsie_attack.ogg'
	fast_invoke_mult = 1
	cogs_required = 5

/datum/scripture/ark_activation/check_special_requirements(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!on_reebe(invoker))
		to_chat(invoker, span_brass("You need to be near the gateway to channel its energy!"))
		return FALSE

	if(!GLOB.clock_ark)
		to_chat(invoker, span_userdanger("No ark located, contact the admins with an ahelp(f1)."))
		return FALSE

	if(!(get_charged_anchor_crystals() >= ANCHORING_CRYSTALS_TO_SUMMON))
		to_chat(invoker, span_brass("Reebe is not yet anchored enough to this realm, the ark cannot open until enough anchoring crystals are summoned and protected."))
		return FALSE

	return TRUE

/datum/scripture/ark_activation/invoke_success()
	if(!GLOB.clock_ark)
		to_chat(invoker, span_userdanger("No ark located, contact the admins with an ahelp(f1)."))
		return FALSE

	GLOB.clock_ark.open_gateway()
