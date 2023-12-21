/datum/round_event_control/abductor
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_TARGETED, TAG_SPOOKY, TAG_EXTERNAL)
	checks_antag_cap = TRUE

/datum/round_event_control/anomaly
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_DESTRUCTIVE)

/datum/round_event_control/alien_infestation
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_COMBAT, TAG_DESTRUCTIVE, TAG_EXTERNAL)
	checks_antag_cap = TRUE

/datum/round_event_control/aurora_caelus
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_COMMUNAL, TAG_POSITIVE, TAG_SPACE)

/datum/round_event_control/blob
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_DESTRUCTIVE, TAG_COMBAT, TAG_EXTERNAL)
	checks_antag_cap = TRUE

/datum/round_event_control/brain_trauma
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_TARGETED)

/datum/round_event_control/brand_intelligence
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_DESTRUCTIVE, TAG_COMMUNAL)

/datum/round_event_control/bureaucratic_error
	track = EVENT_TRACK_MAJOR // if you've ever dealt with 10 mimes you understand why.
	tags = list(TAG_COMMUNAL)

/datum/round_event_control/camera_failure
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_COMMUNAL, TAG_SPOOKY)

/datum/round_event_control/carp_migration
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_DESTRUCTIVE, TAG_COMBAT, TAG_SPACE, TAG_EXTERNAL)

/datum/round_event_control/changeling //THIS IS THE METEOR EVENT, IT NEEDS TO BE A METEOR, DO NOT SPAWN THIS ON PLANETARY MAPS
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_COMBAT, TAG_SPACE, TAG_EXTERNAL)
	checks_antag_cap = TRUE

/datum/round_event_control/communications_blackout
	max_occurrences = 2
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_COMMUNAL, TAG_SPOOKY)

/datum/round_event_control/disease_outbreak
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_TARGETED, TAG_COMMUNAL, TAG_EXTERNAL)

/datum/round_event_control/electrical_storm
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_SPOOKY)

/datum/round_event_control/fake_virus
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_TARGETED)

/datum/round_event_control/falsealarm
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_COMMUNAL)

/datum/round_event_control/fugitives
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_COMBAT, TAG_EXTERNAL)
	checks_antag_cap = TRUE

/datum/round_event_control/gravity_generator_blackout
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_COMMUNAL, TAG_SPACE)

/datum/round_event_control/grey_tide
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_DESTRUCTIVE, TAG_SPOOKY)

/datum/round_event_control/grid_check
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_COMMUNAL, TAG_SPOOKY)

/datum/round_event_control/heart_attack
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_TARGETED)

/datum/round_event_control/immovable_rod
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_DESTRUCTIVE, TAG_EXTERNAL)

/datum/round_event_control/ion_storm
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_TARGETED)

/datum/round_event_control/mass_hallucination
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_COMMUNAL)

/datum/round_event_control/meteor_wave
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_COMMUNAL, TAG_SPACE, TAG_DESTRUCTIVE, TAG_EXTERNAL)

/datum/round_event_control/mice_migration
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_DESTRUCTIVE)

/datum/round_event_control/morph
	track = EVENT_TRACK_ROLESET
	tags = list(TAG_COMBAT, TAG_SPOOKY, TAG_EXTERNAL)
	checks_antag_cap = TRUE

/datum/round_event_control/nightmare
	track = EVENT_TRACK_ROLESET
	tags = list(TAG_COMBAT, TAG_SPOOKY, TAG_EXTERNAL)
	checks_antag_cap = TRUE

/datum/round_event_control/obsessed
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_CREW_ANTAG, TAG_TARGETED)

/datum/round_event_control/operative
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_DESTRUCTIVE, TAG_COMBAT, TAG_EXTERNAL)
	checks_antag_cap = TRUE

/datum/round_event_control/portal_storm_syndicate
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_COMBAT, TAG_EXTERNAL)

/datum/round_event_control/processor_overload
	max_occurrences = 2
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_COMMUNAL)

/datum/round_event_control/radiation_leak
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_COMMUNAL)

/datum/round_event_control/radiation_storm
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_COMMUNAL)

/datum/round_event_control/revenant
	track = EVENT_TRACK_ROLESET
	tags = list(TAG_DESTRUCTIVE, TAG_SPOOKY, TAG_EXTERNAL)
	checks_antag_cap = TRUE

/datum/round_event_control/sandstorm
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_DESTRUCTIVE, TAG_EXTERNAL)

/datum/round_event_control/scrubber_clog
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_COMMUNAL)

/datum/round_event_control/scrubber_clog/critical
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_COMMUNAL, TAG_COMBAT, TAG_EXTERNAL)

/datum/round_event_control/scrubber_overflow
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_COMMUNAL)

/datum/round_event_control/sentience
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_COMMUNAL, TAG_SPOOKY)

/datum/round_event_control/sentient_disease
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_COMBAT, TAG_DESTRUCTIVE, TAG_EXTERNAL)
	checks_antag_cap = TRUE

/datum/round_event_control/shuttle_catastrophe
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_COMMUNAL)

/datum/round_event_control/shuttle_insurance
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_COMMUNAL)

/datum/round_event_control/slaughter
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_COMBAT, TAG_SPOOKY, TAG_EXTERNAL)
	checks_antag_cap = TRUE

/datum/round_event_control/space_dust
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_DESTRUCTIVE, TAG_SPACE, TAG_EXTERNAL)

/datum/round_event_control/space_dragon
	track = EVENT_TRACK_ROLESET
	tags = list(TAG_COMBAT, TAG_SPACE, TAG_EXTERNAL)
	checks_antag_cap = TRUE

/datum/round_event_control/space_ninja
	track = EVENT_TRACK_ROLESET
	tags = list(TAG_COMBAT, TAG_DESTRUCTIVE, TAG_EXTERNAL)
	checks_antag_cap = TRUE

/datum/round_event_control/spacevine
	track = EVENT_TRACK_MAJOR
	tags = list(TAG_COMBAT, TAG_DESTRUCTIVE)
	checks_antag_cap = TRUE

/datum/round_event_control/spider_infestation
	track = EVENT_TRACK_ROLESET
	tags = list(TAG_COMBAT, TAG_DESTRUCTIVE, TAG_EXTERNAL)

/datum/round_event_control/stray_cargo
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_COMMUNAL)

/datum/round_event_control/stray_meteor
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_DESTRUCTIVE, TAG_SPACE, TAG_EXTERNAL)

/datum/round_event_control/tram_malfunction
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_COMMUNAL)

/datum/round_event_control/wisdomcow
	track = EVENT_TRACK_MUNDANE
	tags = list(TAG_COMMUNAL, TAG_POSITIVE)

/datum/round_event_control/wormholes
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_COMMUNAL)
