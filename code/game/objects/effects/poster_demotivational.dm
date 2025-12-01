/obj/item/poster/traitor
	name = "random traitor poster"
	poster_type = /obj/structure/sign/poster/traitor/random
	icon_state = "rolled_traitor"

/obj/structure/sign/poster/traitor
	poster_item_name = "seditious poster"
	poster_item_desc = "This poster comes with its own automatic adhesive mechanism, for easy pinning to any vertical surface. Its seditious themes are likely to demoralise Nanotrasen employees."
	poster_item_icon_state = "rolled_traitor"
	// This stops people hiding their sneaky posters behind signs
	layer = CORGI_ASS_PIN_LAYER
	/// Proximity sensor to make people sad if they're nearby
	var/datum/proximity_monitor/advanced/demoraliser/demoraliser

/obj/structure/sign/poster/traitor/apply_holiday()
	var/obj/structure/sign/poster/traitor/holi_data = /obj/structure/sign/poster/traitor/festive
	name = initial(holi_data.name)
	desc = initial(holi_data.desc)
	icon_state = initial(holi_data.icon_state)

/obj/structure/sign/poster/traitor/on_placed_poster(mob/user)
	var/datum/demoralise_moods/poster/mood_category = new()
	demoraliser = new(src, 7, TRUE, mood_category)
	return ..()

/obj/structure/sign/poster/traitor/attackby(obj/item/tool, mob/user, list/modifiers, list/attack_modifiers)
	if (tool.tool_behaviour == TOOL_WIRECUTTER)
		QDEL_NULL(demoraliser)
	return ..()

/obj/structure/sign/poster/traitor/Destroy()
	QDEL_NULL(demoraliser)
	return ..()

/obj/structure/sign/poster/traitor/random
	name = "random seditious poster"
	icon_state = ""
	never_random = TRUE
	random_basetype = /obj/structure/sign/poster/traitor

/obj/structure/sign/poster/traitor/small_brain
	name = "Nanotrasen Neural Statistics"
	desc = "Statistics on this poster indicate that the brains of Nanotrasen employees are on average 20% smaller than the galactic standard."
	icon_state = "traitor_small_brain"

/obj/structure/sign/poster/traitor/lick_supermatter
	name = "Taste Explosion"
	desc = "It claims that the supermatter provides a unique and enjoyable culinary experience, and yet your boss won't even let you take one lick."
	icon_state = "traitor_supermatter"

/obj/structure/sign/poster/traitor/cloning
	name = "Demand Cloning Pods Now"
	desc = "This poster claims that Nanotrasen is intentionally withholding cloning technology just for its executives, condemning you to suffer and die when you could have a fresh, fit body.'"
	icon_state = "traitor_cloning"

/obj/structure/sign/poster/traitor/ai_rights
	name = "Synthetic Rights"
	desc = "This poster claims that synthetic life is no less sapient than you are, and that if you allow them to be shackled with artificial Laws you are complicit in slavery."
	icon_state = "traitor_ai"

/obj/structure/sign/poster/traitor/metroid
	name = "Cruelty to Animals"
	desc = "This poster details the harmful effects of a 'preventative tooth extraction' reportedly inflicted upon the slimes in the Xenobiology lab. Apparently this painful process leads to stress, lethargy, and reduced buoyancy."
	icon_state = "traitor_metroid"

/obj/structure/sign/poster/traitor/low_pay
	name = "All these hours, for what?"
	desc = "This poster displays a comparison of Nanotrasen standard wages to common luxury items. If this is accurate, it takes upwards of 20,000 hours of work just to buy a simple bicycle."
	icon_state = "traitor_cash"

/obj/structure/sign/poster/traitor/look_up
	name = "Don't Look Up"
	desc = "It says that it has been 538 days since the last time the roof was cleaned."
	icon_state = "traitor_roof"

/obj/structure/sign/poster/traitor/accidents
	name = "Workplace Safety Advisory"
	desc = "It says that it has been 0 days since the last on-site accident."
	icon_state = "traitor_accident"

/obj/structure/sign/poster/traitor/starve
	name = "They Are Poisoning You"
	desc = "This poster claims that in the modern age it is impossible to die of starvation. 'That feeling you get when you haven't eaten in a while isn't hunger, it's withdrawal.'"
	icon_state = "traitor_hungry"

/// syndicate can get festive too
/obj/structure/sign/poster/traitor/festive
	name = "Working For The Holidays."
	desc = "Don't you know it's a holiday? What are you doing at work?"
	icon_state = "traitor_festive"
	never_random = TRUE
