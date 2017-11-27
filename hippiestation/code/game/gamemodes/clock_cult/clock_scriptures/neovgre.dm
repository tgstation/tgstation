/datum/clockwork_scripture/create_object/summon_arbiter
	descname = "Powerful assault mech"
	name = "Summon Neovgre, the Anima Bulwark"
	desc = "Calls forth the mighty anima bulwark, a weapon of unmatched power,\
			 mech with superior defensive and offensive capabilities. It will \
			 steadily regenerate HP and triple its regeneration speed while standing \
			 on a clockwork tile. It will automatically draw power from nearby sigils of \
			 transmission should the need arise. Its Arbiter laser cannon can decimate foes \
			 from a range and is capable of smashing through any barrier presented to it. \
			 Be warned, choosing to pilot Neovgre is a lifetime commitment, once you are \
			 in you cannot leave and when it is destroyed it will explode catastrophically with you inside."
	invocations = list("By the strength of the alloy...", "...call fourth the Arbiter!")
	channel_time = 150 // This is a strong fucking weapon, 15 seconds channel time is getting off light I tell ya.
	power_cost = 7500 //7.5 KW
	usage_tip = "Neovgre is a powerful mech that will crush your enemies!"
	invokers_required = 4
	multiple_invokers_used = TRUE
	object_path = /obj/mecha/neovgre
	tier = SCRIPTURE_APPLICATION
	primary_component = REPLICANT_ALLOY
	sort_priority = 2
	creator_message = "<span class='brass'>Neovgre, the Anima Bulwark towers over you... your enemies reckoning has come.</span>"

/datum/clockwork_scripture/create_object/summon_arbiter/check_special_requirements()
	if(GLOB.neovgre_exists)
		to_chat(invoker, "<span class='brass'>\"You've already got one...\"</span>")
		return FALSE
	return ..()
