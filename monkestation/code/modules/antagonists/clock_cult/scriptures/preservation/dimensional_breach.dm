/datum/scripture/ark_activation
	name = "Ark Invigoration"
	desc = "Prepares the Ark for activation, alerting the crew of your existence."
	tip = "Prepares the Ark for activation, alerting the crew of your existence."
	button_icon_state = "Spatial Gateway"
	power_cost = 5000
	invocation_time = 14 SECONDS
	invocation_text = list("Oh great Engine, take my soul...", "it is time for you to rise...", "through rifts you shall come...", "to rise among the stars again!")
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

	if(!get_charged_anchor_crystals())
		to_chat(invoker, span_warning("Reebe is not yet anchored enough to this realm, summon and protect an anchoring crystal."))
		return FALSE

	return TRUE

/datum/scripture/ark_activation/invoke_success()
	if(!GLOB.clock_ark) //checking twice just in case
		to_chat(invoker, span_userdanger("No ark located, contact the admins with an ahelp(f1)."))
		return FALSE

	GLOB.clock_ark.open_gateway()
