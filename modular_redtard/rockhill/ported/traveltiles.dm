/obj/structure/rockhill/traveltile
	name = "travel"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/turf/roguefloor.dmi'
	icon_state = "travel"
	aportalid = "REPLACETHIS"
	aportalgoesto = "REPLACETHIS"
	travel_time = 5 SECONDS
	travel_message = "I begin to travel..."
	travel_deny_message = "It is a dead end."
	travel_access_hint = null
	watchable = TRUE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = 2.04

/obj/structure/rockhill/traveltile/bandit
	name = "travel"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/turf/roguefloor.dmi'
	icon_state = "travel"
	aportalid = "REPLACETHIS"
	aportalgoesto = "REPLACETHIS"
	required_trait = "banditcamp"
	travel_time = 5 SECONDS
	travel_message = "I begin to travel..."
	travel_deny_message = "It is a dead end."
	travel_access_hint = null
	watchable = TRUE
	resistance_flags = INDESTRUCTIBLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = 2.04

/obj/structure/rockhill/traveltile/bathhouse_passage
	name = "suspicious passage"
	desc = "A crevice in the wall. It looks like it leads somewhere."
	icon = 'modular_redtard/rockhill/icons/turf/roguefloor.dmi'
	icon_state = "travel"
	aportalid = "smuggler_bathhouse"
	aportalgoesto = "smuggler_cove"
	required_trait = "Agent of the Bathhouse"
	required_jobs = list("Bathmaster", "Bathhouse Attendant")
	travel_time = 15 SECONDS
	travel_message = "I begin to squeeze through the passage..."
	travel_deny_message = "You're not supple enough to use this passage."
	travel_access_hint = "A tight passage that leads between the bathhouse and the northern coast, with many twists and turns - only a bathhouse staff member can fit through it. It takes a while to travel through, and is a popular route for smuggling goods in and out of town."
	watchable = FALSE
	resistance_flags = INDESTRUCTIBLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = 2.04

/obj/structure/rockhill/traveltile/bathhouse_passage/cave
	name = "suspicious passage"
	desc = "A crevice in the wall. It looks like it leads somewhere."
	icon = 'modular_redtard/rockhill/icons/turf/roguefloor.dmi'
	icon_state = "travel"
	aportalid = "smuggler_cove"
	aportalgoesto = "smuggler_bathhouse"
	required_trait = "Agent of the Bathhouse"
	required_jobs = list("Bathmaster", "Bathhouse Attendant")
	travel_time = 15 SECONDS
	travel_message = "I begin to squeeze through the passage..."
	travel_deny_message = "You're not supple enough to use this passage."
	travel_access_hint = "A tight passage that leads between the bathhouse and the northern coast, with many twists and turns - only a bathhouse staff member can fit through it. It takes a while to travel through, and is a popular route for smuggling goods in and out of town."
	watchable = FALSE
	resistance_flags = INDESTRUCTIBLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = 2.04

/obj/structure/rockhill/traveltile/dungeoneer
	name = "travel"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/turf/roguefloor.dmi'
	icon_state = "travel"
	aportalid = "REPLACETHIS"
	aportalgoesto = "REPLACETHIS"
	required_trait = "dungeonmasterlaborcamp"
	travel_time = 5 SECONDS
	travel_message = "I begin to travel..."
	travel_deny_message = "It is a dead end."
	travel_access_hint = null
	watchable = TRUE
	resistance_flags = INDESTRUCTIBLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = 2.04

/obj/structure/rockhill/traveltile/lich
	name = "travel"
	desc = "forboding, warping magick. Where could it possibly lead? Somewhere terrible, you must assume..."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "shitportal"
	color = "#fcff5e"
	aportalid = "REPLACETHIS"
	aportalgoesto = "REPLACETHIS"
	required_trait = "lichlair"
	travel_time = 5 SECONDS
	travel_message = "I begin to travel..."
	travel_deny_message = "It is a dead end."
	travel_access_hint = null
	watchable = TRUE
	resistance_flags = INDESTRUCTIBLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = 2.04

/obj/structure/rockhill/traveltile/magicportal
	name = "mysterious portal"
	desc = "flickering, warping magick"
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "shitportal"
	aportalid = "REPLACETHIS"
	aportalgoesto = "REPLACETHIS"
	travel_time = 5 SECONDS
	travel_message = "I begin to travel..."
	travel_deny_message = "It is a dead end."
	travel_access_hint = null
	watchable = TRUE
	resistance_flags = INDESTRUCTIBLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = 2.04

/obj/structure/rockhill/traveltile/magicportal/unstable
	name = "unstable portal"
	desc = "flickering, warping magick. Where could it possibly lead?"
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "shitportal"
	color = "#ff0d00"
	aportalid = "REPLACETHIS"
	aportalgoesto = "REPLACETHIS"
	travel_time = 5 SECONDS
	travel_message = "I begin to travel..."
	travel_deny_message = "It is a dead end."
	travel_access_hint = null
	watchable = TRUE
	resistance_flags = INDESTRUCTIBLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = 2.04

/obj/structure/rockhill/traveltile/rockhillentrance
	name = "To Rockhill"
	desc = "Awake from this dream. The road to Rockhill awaits."
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "underworldportal"
	aportalid = "REPLACETHIS"
	aportalgoesto = "REPLACETHIS"
	travel_time = 5 SECONDS
	travel_message = "I begin to travel..."
	travel_deny_message = "It is a dead end."
	travel_access_hint = null
	watchable = TRUE
	resistance_flags = INDESTRUCTIBLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = 2.04

/obj/structure/rockhill/traveltile/vampire
	name = "travel"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/turf/roguefloor.dmi'
	icon_state = "travel"
	aportalid = "REPLACETHIS"
	aportalgoesto = "REPLACETHIS"
	required_trait = "vampiremansion"
	travel_time = 5 SECONDS
	travel_message = "I begin to travel..."
	travel_deny_message = "It is a dead end."
	travel_access_hint = null
	watchable = TRUE
	resistance_flags = INDESTRUCTIBLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = 2.04

/obj/structure/rockhill/traveltile/wretch
	name = "travel"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/turf/roguefloor.dmi'
	icon_state = "travel"
	aportalid = "REPLACETHIS"
	aportalgoesto = "REPLACETHIS"
	required_trait = "Hidden Domiciles"
	travel_time = 5 SECONDS
	travel_message = "I begin to travel..."
	travel_deny_message = "It is a dead end."
	travel_access_hint = null
	watchable = TRUE
	resistance_flags = INDESTRUCTIBLE
	rockhill_dulling = "bashchop"
	rockhill_hit_sounds = list('modular_redtard/rockhill/sound/blank.ogg')
	rockhill_break_sounds = list('modular_redtard/rockhill/sound/foley/breaksound.ogg')
	layer = 2.04
