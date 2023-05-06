/datum/scripture/integration_cog
	name = "Integration Cog"
	desc = "Fabricates an integration cog, which can be inserted into APCs to draw power and unlock scriptures."
	tip = "Install integration cogs into APCs to increase your energy stores and unlock new scriptures."
	button_icon_state = "Integration Cog"
	invocation_time = 1 SECONDS
	invocation_text = list("Tick tock Eng'Ine...")
	category = SPELLTYPE_SERVITUDE

/datum/scripture/integration_cog/invoke_success()
	if(invoker.put_in_hands(new /obj/item/clockwork/integration_cog))
		to_chat(invoker, span_brass("You summon an integration cog into your hands."))
		playsound(src, 'sound/machines/click.ogg', 50)
		return TRUE

	else
		to_chat(invoker, span_brass("You summon an integration cog on the floor."))
		playsound(src, 'sound/machines/click.ogg', 50)
		return FALSE
