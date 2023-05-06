/datum/scripture/create_structure/tinkerers_cache
	name = "Tinkerer's Cache"
	desc = "Creates a tinkerer's cache, a powerful forge capable of crafting elite equipment."
	tip = "Use the cache to create more powerful equipment at the cost of power and time."
	button_icon_state = "Tinkerer's Cache"
	power_cost = 700
	invocation_time = 5 SECONDS
	invocation_text = list("Guide my hand and we shall create greatness.")
	summoned_structure = /obj/structure/destructible/clockwork/gear_base/powered/tinkerers_cache
	cogs_required = 4
	category = SPELLTYPE_STRUCTURES
