/datum/uplink_category/events
	name = "Events & Chaos"
	weight = 4

/datum/uplink_item/events
	category = /datum/uplink_category/events


/datum/uplink_item/events/summoncarpmigration
	name = "Summon Carp Migration"
	desc = "When purchased, your uplink will send an encrypted signal to one of our nearby outposts, they'll then bluespace over some space carps to invade the station."
	item = /obj/effect/gibspawner/generic
	surplus = 0
	progression_minimum = 10 MINUTES
	limited_stock = 1
	cost = 5
	cant_discount = TRUE
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/events/summoncarpmigration/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	force_event(/datum/round_event_control/carp_migration, "a strange signal")
	return source //For log icon

/datum/uplink_item/events/nukiecarpmigration
	name = "Summon Carp Invaders"
	desc = "When purchased, we'll bluespace over a wave or two of space carps to invade the station after a short delay. This can be rather helpful in making the medical department a bit more busy."
	item = /obj/effect/gibspawner/generic
	surplus = 0
	limited_stock = 1
	cost = 10
	cant_discount = TRUE
	purchasable_from = (UPLINK_CLOWN_OPS | UPLINK_NUKE_OPS)

/datum/uplink_item/events/carpmigration/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	force_event(/datum/round_event_control/carp_migration, "a nuclear operative support agent")
	return source //For log icon

/datum/uplink_item/events/telecomm_blackout
	name = "Disable Telecomms"
	desc = "When purchased, a virus will be uploaded to the telecommunication processing servers to temporarily disable themselves."
	item = /obj/effect/gibspawner/generic
	surplus = 0
	progression_minimum = 15 MINUTES
	limited_stock = 1
	cost = 4
	restricted = TRUE
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/events/telecomm_blackout/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	force_event(/datum/round_event_control/communications_blackout, "a syndicate virus")
	return source //For log icon

/datum/uplink_item/events/blackout
	name = "Trigger Stationwide Blackout"
	desc = "When purchased, a virus will be uploaded to the engineering processing servers to force a routine power grid check, forcing all APCs on the station to be temporarily disabled."
	item = /obj/effect/gibspawner/generic
	surplus = 0
	progression_minimum = 20 MINUTES
	limited_stock = 1
	cost = 6
	restricted = TRUE
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/events/blackout/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	force_event(/datum/round_event_control/grid_check, "a syndicate virus")
	return source //For log icon

/datum/uplink_item/events/camera_failure
	name = "Mass Camera Sabotage"
	desc = "When purchased, our support agents will hack into the station's camera system and begin shutting off as many cameras as possible before the system kicks them out. Unfortunately, they're kicked out rather quickly and can only turn off several cameras per purchase."
	item = /obj/effect/gibspawner/generic
	surplus = 0
	limited_stock = 5
	cost = 1
	cant_discount = TRUE
	purchasable_from = (UPLINK_CLOWN_OPS | UPLINK_NUKE_OPS)

/datum/uplink_item/events/camera_failure/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	force_event(/datum/round_event_control/camera_failure, "a nuclear operative support agent")
	return source //For log icon

/datum/uplink_item/events/communications_blackout
	name = "Blackout Communications"
	desc = "When purchased, our support agents will hack into the station's communication network and shut it down temporarily."
	item = /obj/effect/gibspawner/generic
	surplus = 0
	limited_stock = 1
	cost = 7
	cant_discount = TRUE
	purchasable_from = (UPLINK_CLOWN_OPS | UPLINK_NUKE_OPS)

/datum/uplink_item/events/communications_blackout/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	force_event(/datum/round_event_control/communications_blackout, "a nuclear operative support agent")
	return source //For log icon

/datum/uplink_item/events/brand_intelligence
	name = "Inflict Brand Intelligence"
	desc = "When purchased, we'll send over a single digital intelligence virus to mess with on-station vendors."
	item = /obj/effect/gibspawner/generic
	surplus = 0
	limited_stock = 1
	cost = 6
	cant_discount = TRUE
	purchasable_from = (UPLINK_CLOWN_OPS | UPLINK_NUKE_OPS)

/datum/uplink_item/events/brand_intelligence/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	force_event(/datum/round_event_control/brand_intelligence, "a nuclear operative support agent")
	return source //For log icon

/datum/uplink_item/events/gravity_generator_blackout
	name = "Disable Gravity Generator"
	desc = "When purchased, our agents will hack into the station's networks and shut down the gravity generator temporarily."
	item = /obj/effect/gibspawner/generic
	surplus = 0
	limited_stock = 1
	cost = 8
	cant_discount = TRUE
	purchasable_from = (UPLINK_CLOWN_OPS | UPLINK_NUKE_OPS)

/datum/uplink_item/events/gravity_generator_blackout/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	force_event(/datum/round_event_control/gravity_generator_blackout, "a nuclear operative support agent")
	return source //For log icon

/datum/uplink_item/events/portal_storm_syndicate
	name = "Syndicate Portal Invaders"
	desc = "When purchased, we'll send in many of our newly cloned and expendable agents with little self-destructive gear as possible to cause mayhem."
	item = /obj/effect/gibspawner/generic
	surplus = 0
	limited_stock = 1
	cost = 20
	cant_discount = TRUE
	purchasable_from = (UPLINK_CLOWN_OPS | UPLINK_NUKE_OPS)

/datum/uplink_item/events/portal_storm_syndicate/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	force_event(/datum/round_event_control/portal_storm_syndicate, "a nuclear operative support agent")
	return source //For log icon

/datum/uplink_item/events/stray_cargo
	name = "Send Stray Cargo Pods"
	desc = "When purchased, we'll send in a bunch of stray cargo pods to impact the station. Be warned that purchasing this is ill-advised as it'll give away your presence and possibly arm the crew."
	item = /obj/effect/gibspawner/generic
	surplus = 0
	limited_stock = 2
	cost = 4
	cant_discount = TRUE
	purchasable_from = UPLINK_CLOWN_OPS

/datum/uplink_item/events/stray_cargo/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	force_event(/datum/round_event_control/stray_cargo, "a clown operative support agent")
	force_event(/datum/round_event_control/stray_cargo, "a clown operative support agent")
	force_event(/datum/round_event_control/stray_cargo, "a clown operative support agent")
	force_event(/datum/round_event_control/stray_cargo, "a clown operative support agent")
	force_event(/datum/round_event_control/stray_cargo, "a clown operative support agent")
	return source //For log icon

/datum/uplink_item/events/stray_cargo/syndicate
	name = "Send Stray Syndicate Pod"
	desc = "When purchased, we'll be-grudgingly send over one of our supply pods to drop random gear in a random part of the station. This is ill-advised as it could arm the crew, but it'll likely bring attention away from your infiltration. The pod's contents may even be claimed by your team."
	item = /obj/effect/gibspawner/generic
	surplus = 0
	limited_stock = 1
	cost = 10
	cant_discount = TRUE
	purchasable_from = (UPLINK_CLOWN_OPS | UPLINK_NUKE_OPS)

/datum/uplink_item/events/stray_cargo/syndicate/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	force_event(/datum/round_event_control/stray_cargo/syndicate, "a nuclear operative support agent")
	return source //For log icon

/datum/uplink_item/events/scrubber_overflow/catastrophic
	name = "Mass Scrubber Overflow"
	desc = "When purchased, we'll hack into the station's scrubber network and cause it to overflow. This'll flood most of the scrubber on the station with random reagent foams."
	item = /obj/effect/gibspawner/generic
	surplus = 0
	limited_stock = 1
	cost = 8
	cant_discount = TRUE
	purchasable_from = (UPLINK_CLOWN_OPS | UPLINK_NUKE_OPS)

/datum/uplink_item/events/scrubber_overflow/catastrophic/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	force_event(/datum/round_event_control/scrubber_overflow/catastrophic, "a nuclear operative support agent")
	return source //For log icon

/datum/uplink_item/events/radiation_storm
	name = "Send Radiation Storm"
	desc = "When purchased, we'll authorize a radiation storm projection and send it over to the station with a short delay. This should only be used if your entire team is away or in maintenance."
	item = /obj/effect/gibspawner/generic
	surplus = 0
	limited_stock = 1
	cost = 18
	cant_discount = TRUE
	purchasable_from = (UPLINK_CLOWN_OPS | UPLINK_NUKE_OPS)

/datum/uplink_item/events/radiation_storm/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	force_event(/datum/round_event_control/radiation_storm, "a nuclear operative support agent")
	return source //For log icon

/datum/uplink_item/events/space_dragon
	name = "Call Space Dragon"
	desc = "When purchased, we'll send one of our highly experimental space carp specimens to wreck havok upon the station. Be warned that the specimen will likely be hostile. \
			(WARNING: THIS IS A GHOST ROLE AND YOU WILL NOT BE REFUNDED SHOULD NOBODY CLAIM THE ROLE.)"
	item = /obj/effect/gibspawner/generic
	surplus = 0
	limited_stock = 1
	cost = 35
	cant_discount = TRUE
	purchasable_from = (UPLINK_CLOWN_OPS | UPLINK_NUKE_OPS)

/datum/uplink_item/events/space_dragon/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	force_event(/datum/round_event_control/space_dragon, "a nuclear operative support agent")
	return source //For log icon

/datum/uplink_item/events/space_ninja
	name = "Call Space Ninja"
	desc = "When purchased, we'll contact a local ninja group and we'll convince them to send an agent onto the station. Be warned that the ninja will likely be hostile. \
			(WARNING: THIS IS A GHOST ROLE AND YOU WILL NOT BE REFUNDED SHOULD NOBODY CLAIM THE ROLE.)"
	item = /obj/effect/gibspawner/generic
	surplus = 0
	limited_stock = 1
	cost = 25
	cant_discount = TRUE
	purchasable_from = (UPLINK_CLOWN_OPS | UPLINK_NUKE_OPS)

/datum/uplink_item/events/space_ninja/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	force_event(/datum/round_event_control/space_ninja, "a nuclear operative support agent")
	return source //For log icon

/datum/uplink_item/events/meteor_wave
	name = "Send Meteor Wave"
	desc = "When purchased, we'll use our gravity manipulation devices to hurl a bunch of rocks at the station of choice. This will likely amount to several hull breaches and a distracted engineering team."
	item = /obj/effect/gibspawner/generic
	surplus = 0
	limited_stock = 1
	cost = 9
	cant_discount = TRUE
	purchasable_from = (UPLINK_CLOWN_OPS | UPLINK_NUKE_OPS)

/datum/uplink_item/events/meteor_wave/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	force_event(/datum/round_event_control/meteor_wave, "a nuclear operative support agent")
	return source //For log icon

/datum/uplink_item/events/operative
	name = "Call in Lone Operative"
	desc = "When purchased, we'll send in a Nuclear Operative directly to the station to attempt to destroy the station. This may or may not conflict with your objective."
	item = /obj/effect/gibspawner/generic
	surplus = 0
	limited_stock = 1
	cost = 40
	cant_discount = TRUE
	purchasable_from = UPLINK_CLOWN_OPS

/datum/uplink_item/events/operative/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	force_event(/datum/round_event_control/operative, "a nuclear operative support agent")
	return source //For log icon





/datum/uplink_item/role_restricted/lesser_nuclear_signal
	name = "Nuclear Request Signal"
	desc = "When purchased, we'll authorize ONE of our operatives to scope out the situation and attempt to destroy the station with the on-board nuclear device. Be prepared to aid them, or die trying."
	item = /obj/effect/gibspawner/generic
	surplus = 0
	progression_minimum = 40 MINUTES
	limited_stock = 1
	cost = 30
	cant_discount = TRUE
	restricted = TRUE
	restricted_roles = list(JOB_HEAD_OF_PERSONNEL, JOB_QUARTERMASTER, JOB_CHIEF_ENGINEER, JOB_CHIEF_MEDICAL_OFFICER, JOB_RESEARCH_DIRECTOR)

/datum/uplink_item/role_restricted/lesser_nuclear_signal/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	force_event(/datum/round_event_control/operative, "a strange signal")
	return source //For log icon

/datum/uplink_item/role_restricted/spacepirates
	name = "Summon Space Pirates"
	desc = "When purchased, your uplink will send an encrypted signal to one of our nearby outposts, and we'll then send in the station coordinates to one of our pirate groups. Be warned that they may destroy cargo's operations. \
			ATTENTION: WE CANNOT SEND PIRATES TO ANY STATIONS RESIDING UPON A PLANET (IceBox)"
	item = /obj/effect/gibspawner/generic
	surplus = 0
	progression_minimum = 30 MINUTES
	limited_stock = 1
	cost = 20
	cant_discount = TRUE
	restricted = TRUE
	restricted_roles = list(JOB_QUARTERMASTER)

/datum/uplink_item/role_restricted/spacepirates/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	force_event(/datum/round_event_control/pirates, "an encrypted signal")
	return

/datum/uplink_item/role_restricted/sentient_disease
	name = "Send a Sentient Virus to the Station"
	desc = "When purchased, we'll authorize ONE of our classified micro-organisms to be sent onto the station via bluespace technology. Do be mindful, that the virus is very unpredictable."
	item = /obj/effect/gibspawner/generic
	surplus = 0
	progression_minimum = 30 MINUTES
	limited_stock = 1
	cost = 20
	cant_discount = TRUE
	restricted = TRUE
	restricted_roles = list(JOB_CHIEF_MEDICAL_OFFICER)

/datum/uplink_item/role_restricted/sentient_disease/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	force_event(/datum/round_event_control/sentient_disease, "bluespaced onto the station by the syndicate")
	return source //For log icon

