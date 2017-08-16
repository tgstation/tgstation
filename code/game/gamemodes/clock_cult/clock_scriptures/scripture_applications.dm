//////////////////
// APPLICATIONS //
//////////////////

//Sigil of Transmission: Creates a sigil of transmission that can drain and store power for clockwork structures.
/datum/clockwork_scripture/create_object/sigil_of_transmission
	descname = "Structure Power Generator & Battery"
	name = "Sigil of Transmission"
	desc = "Places a sigil that can drain and will store energy to power clockwork structures."
	invocations = list("Divinity...", "...power our creations!")
	channel_time = 70
	consumed_components = list(VANGUARD_COGWHEEL = 2, GEIS_CAPACITOR = 2, HIEROPHANT_ANSIBLE = 4)
	whispered = TRUE
	object_path = /obj/effect/clockwork/sigil/transmission
	creator_message = "<span class='brass'>A sigil silently appears below you. It will automatically power clockwork structures near it and will drain power when activated.</span>"
	usage_tip = "Cyborgs can charge from this sigil by remaining over it for 5 seconds."
	tier = SCRIPTURE_APPLICATION
	one_per_tile = TRUE
	primary_component = HIEROPHANT_ANSIBLE
	sort_priority = 5
	quickbind = TRUE
	quickbind_desc = "Creates a Sigil of Transmission, which can drain and will store power for clockwork structures."


//Prolonging Prism: Creates a prism that will delay the shuttle at a power cost
/datum/clockwork_scripture/create_object/prolonging_prism
	descname = "Powered Structure, Delay Emergency Shuttles"
	name = "Prolonging Prism"
	desc = "Creates a mechanized prism which will delay the arrival of an emergency shuttle by 2 minutes at a massive power cost."
	invocations = list("May this prism...", "...grant us time to enact his will!")
	channel_time = 80
	consumed_components = list(VANGUARD_COGWHEEL = 5, GEIS_CAPACITOR = 2, REPLICANT_ALLOY = 2)
	object_path = /obj/structure/destructible/clockwork/powered/prolonging_prism
	creator_message = "<span class='brass'>You form a prolonging prism, which will delay the arrival of an emergency shuttle at a massive power cost.</span>"
	observer_message = "<span class='warning'>An onyx prism forms in midair and sprouts tendrils to support itself!</span>"
	invokers_required = 2
	multiple_invokers_used = TRUE
	usage_tip = "The power cost to delay a shuttle increases based on the number of times activated."
	tier = SCRIPTURE_APPLICATION
	one_per_tile = TRUE
	primary_component = VANGUARD_COGWHEEL
	sort_priority = 7
	quickbind = TRUE
	quickbind_desc = "Creates a Prolonging Prism, which will delay the arrival of an emergency shuttle by 2 minutes at a massive power cost."

/datum/clockwork_scripture/create_object/prolonging_prism/check_special_requirements()
	if(SSshuttle.emergency.mode == SHUTTLE_DOCKED || SSshuttle.emergency.mode == SHUTTLE_IGNITING || SSshuttle.emergency.mode == SHUTTLE_STRANDED || SSshuttle.emergency.mode == SHUTTLE_ESCAPE)
		to_chat(invoker, "<span class='inathneq'>\"It is too late to construct one of these, champion.\"</span>")
		return FALSE
	var/turf/T = get_turf(invoker)
	if(!T || T.z != ZLEVEL_STATION)
		to_chat(invoker, "<span class='inathneq'>\"You must be on the station to construct one of these, champion.\"</span>")
		return FALSE
	return ..()


//Mania Motor: Creates a malevolent transmitter that will broadcast the whispers of Sevtug into the minds of nearby nonservants, causing a variety of mental effects at a power cost.
/datum/clockwork_scripture/create_object/mania_motor
	descname = "Powered Structure, Area Denial"
	name = "Mania Motor"
	desc = "Creates a mania motor which causes minor damage and a variety of negative mental effects in nearby non-Servant humans, potentially up to and including conversion."
	invocations = list("May this transmitter...", "...break the will of all who oppose us!")
	channel_time = 80
	consumed_components = list(GEIS_CAPACITOR = 5, REPLICANT_ALLOY = 2, HIEROPHANT_ANSIBLE = 2)
	object_path = /obj/structure/destructible/clockwork/powered/mania_motor
	creator_message = "<span class='brass'>You form a mania motor, which causes minor damage and negative mental effects in non-Servants.</span>"
	observer_message = "<span class='warning'>A two-pronged machine rises from the ground!</span>"
	invokers_required = 2
	multiple_invokers_used = TRUE
	usage_tip = "It will also cure hallucinations and brain damage in nearby Servants."
	tier = SCRIPTURE_APPLICATION
	one_per_tile = TRUE
	primary_component = GEIS_CAPACITOR
	sort_priority = 8
	quickbind = TRUE
	quickbind_desc = "Creates a Mania Motor, which causes minor damage and negative mental effects in non-Servants."


//Tinkerer's Daemon: Creates an efficient machine that rapidly produces components at a power cost.
/datum/clockwork_scripture/create_object/tinkerers_daemon
	descname = "Powered Structure, Component Generator"
	name = "Tinkerer's Daemon"
	desc = "Creates a tinkerer's daemon which can rapidly collect components. It will only function if it has sufficient power, active daemons are outnumbered by Servants by a ratio of 5:1, \
	and there is at least one existing cache."
	invocations = list("May this generator...", "...collect Engine parts that yet hold greatness!")
	channel_time = 80
	consumed_components = list(BELLIGERENT_EYE = 2, GEIS_CAPACITOR = 2, REPLICANT_ALLOY = 5)
	object_path = /obj/structure/destructible/clockwork/powered/tinkerers_daemon
	creator_message = "<span class='brass'>You form a tinkerer's daemon which can rapidly collect components at a power cost.</span>"
	invokers_required = 2
	multiple_invokers_used = TRUE
	usage_tip = "Vital to your success!"
	tier = SCRIPTURE_APPLICATION
	one_per_tile = TRUE
	primary_component = REPLICANT_ALLOY
	sort_priority = 9
	quickbind = TRUE
	quickbind_desc = "Creates a Tinkerer's Daemon, which can rapidly collect components for power."
