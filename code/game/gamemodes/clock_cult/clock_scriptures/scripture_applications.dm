//////////////////
// APPLICATIONS //
//////////////////


//Clockwork Marauder: Creates a construct shell for a clockwork marauder, a well-rounded frontline fighter.
/datum/clockwork_scripture/create_object/construct/clockwork_marauder
	descname = "Well-Rounded Combat Construct"
	name = "Clockwork Marauder"
	desc = "Creates a shell for a clockwork marauder, a balanced frontline construct."
	invocations = list("Arise, avatar of Arbiter!", "Defend the Ark with vengeful zeal.")
	channel_time = 50
	power_cost = 1000
	creator_message = "<span class='brass'>Your slab disgorges several chunks of replicant alloy that form into a suit of thrumming armor.</span>"
	usage_tip = "The marauder's shield can effectively deflect energy-based projectiles."
	tier = SCRIPTURE_APPLICATION
	one_per_tile = TRUE
	primary_component = BELLIGERENT_EYE
	sort_priority = 1
	quickbind = TRUE
	quickbind_desc = "Creates a clockwork marauder, used for frontline combat."
	object_path = /obj/item/clockwork/construct_chassis/clockwork_marauder
	construct_type = /mob/living/simple_animal/hostile/clockwork/marauder
	combat_construct = TRUE

/datum/clockwork_scripture/create_object/construct/clockwork_marauder/update_construct_limit()
	var/human_servants = 0
	for(var/V in SSticker.mode.servants_of_ratvar)
		var/datum/mind/M = V
		if(ishuman(M.current))
			human_servants++
	construct_limit = human_servants / 4 //1 per 4 human servants, and a maximum of 3 marauders
	construct_limit = Clamp(construct_limit, 1, 3)

/datum/clockwork_scripture/create_object/prolonging_prism/check_special_requirements()
	if(SSshuttle.emergency.mode == SHUTTLE_DOCKED || SSshuttle.emergency.mode == SHUTTLE_IGNITING || SSshuttle.emergency.mode == SHUTTLE_STRANDED || SSshuttle.emergency.mode == SHUTTLE_ESCAPE)
		to_chat(invoker, "<span class='inathneq'>\"It is too late to construct one of these, champion.\"</span>")
		return FALSE
	var/turf/T = get_turf(invoker)
	if(!T || !(T.z in GLOB.station_z_levels))
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
	power_cost = 750
	object_path = /obj/structure/destructible/clockwork/powered/mania_motor
	creator_message = "<span class='brass'>You form a mania motor, which causes minor damage and negative mental effects in non-Servants.</span>"
	observer_message = "<span class='warning'>A two-pronged machine rises from the ground!</span>"
	invokers_required = 2
	multiple_invokers_used = TRUE
	usage_tip = "It will also cure hallucinations and brain damage in nearby Servants."
	tier = SCRIPTURE_APPLICATION
	one_per_tile = TRUE
	primary_component = GEIS_CAPACITOR
	sort_priority = 2
	quickbind = TRUE
	quickbind_desc = "Creates a Mania Motor, which causes minor damage and negative mental effects in non-Servants."


//Sigil of Transmission: Creates a sigil of transmission that can drain and store power for clockwork structures.
/datum/clockwork_scripture/create_object/sigil_of_transmission
	descname = "Structure Power Generator & Battery"
	name = "Sigil of Transmission"
	desc = "Places a sigil that can drain and will store energy to power clockwork structures."
	invocations = list("Divinity...", "...power our creations!")
	channel_time = 70
	power_cost = 200
	whispered = TRUE
	object_path = /obj/effect/clockwork/sigil/transmission
	creator_message = "<span class='brass'>A sigil silently appears below you. It will automatically power clockwork structures near it and will drain power when activated.</span>"
	usage_tip = "Cyborgs can charge from this sigil by remaining over it for 5 seconds."
	tier = SCRIPTURE_APPLICATION
	one_per_tile = TRUE
	primary_component = HIEROPHANT_ANSIBLE
	sort_priority = 3
	quickbind = TRUE
	quickbind_desc = "Creates a Sigil of Transmission, which can drain and will store power for clockwork structures."


//Clockwork Obelisk: Creates a powerful obelisk that can be used to broadcast messages or open a gateway to any servant or clockwork obelisk at a power cost.
/datum/clockwork_scripture/create_object/clockwork_obelisk
	descname = "Powered Structure, Teleportation Hub"
	name = "Clockwork Obelisk"
	desc = "Creates a clockwork obelisk that can broadcast messages over the Hierophant Network or open a Spatial Gateway to any living Servant or clockwork obelisk."
	invocations = list("May this obelisk...", "...take us to all places!")
	channel_time = 80
	power_cost = 300
	object_path = /obj/structure/destructible/clockwork/powered/clockwork_obelisk
	creator_message = "<span class='brass'>You form a clockwork obelisk which can broadcast messages or produce Spatial Gateways.</span>"
	observer_message = "<span class='warning'>A brass obelisk appears hanging in midair!</span>"
	invokers_required = 2
	multiple_invokers_used = TRUE
	usage_tip = "Producing a gateway has a high power cost. Gateways to or between clockwork obelisks receive double duration and uses."
	tier = SCRIPTURE_APPLICATION
	one_per_tile = TRUE
	primary_component = HIEROPHANT_ANSIBLE
	sort_priority = 4
	quickbind = TRUE
	quickbind_desc = "Creates a Clockwork Obelisk, which can send messages or open Spatial Gateways with power."
