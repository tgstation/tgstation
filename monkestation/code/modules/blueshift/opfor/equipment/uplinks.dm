/datum/opposing_force_equipment/uplink
	category = OPFOR_EQUIPMENT_CATEGORY_CLOTHING_UPLINK

//Uplinks
/datum/opposing_force_equipment/uplink/uplink_old_radio
	item_type = /obj/item/uplink/old_radio
	name = "Old Syndicate Uplink"
	description = "An old-school Syndicate uplink without a password and an empty TC account. Perfect for the aspiring operatives."
	admin_note = "Traitor uplink without telecrystals."

/datum/opposing_force_equipment/uplink/uplink_implant
	item_type = /obj/item/implanter/uplink
	name = "Syndicate Uplink Implanter"
	admin_note = "Implanter for a Traitor uplink with no TC."

/datum/opposing_force_equipment/uplink/tc1
	item_type = /obj/item/stack/telecrystal
	name = "1 Raw Telecrystal"
	description = "A telecrystal in its rawest and purest form; can be utilized on active uplinks to increase their telecrystal count."

/datum/opposing_force_equipment/uplink/tc5
	item_type = /obj/item/stack/telecrystal/five
	name = "5 Raw Telecrystals"
	description = "A bunch of telecrystals in their rawest and purest form; can be utilized on active uplinks to increase their telecrystal count."

/datum/opposing_force_equipment/uplink/tc10
	item_type = /obj/item/stack/telecrystal/twenty
	name = "20 Raw Telecrystals"
	description = "A bundle of telecrystals in their rawest and purest form; can be utilized on active uplinks to increase their telecrystal count."

/datum/opposing_force_equipment/uplink/c10k
	name = "10000 Space Cash Bill"
	item_type = /obj/item/stack/spacecash/c10000
	description = "Cold hard cash."

//Tot powers
/datum/opposing_force_equipment/uplink/changeling
	item_type = /obj/item/antag_granter/changeling
	name = "Changeling Injector"
	description = "A heavy-duty injector containing a highly infectious virus, turning the user into a \"Changeling\"."
	admin_note = "Changeling antag granter."

/datum/opposing_force_equipment/uplink/heretic
	item_type = /obj/item/antag_granter/heretic
	name = "Heretical Book"
	description = "A purple book with an eldritch eye on it, capable of making one into a \"Heretic\", one with the Forgotten Gods."
	admin_note = "Heretic antag granter."

/datum/opposing_force_equipment/uplink/clock_cult
	item_type = /obj/item/antag_granter/clock_cultist
	name = "Clockwork Contraption"
	description = "A cogwheel-shaped device of brass, with a glass lens floating, suspended in the center. Capable of making one become a \"Clock Cultist\"."
	admin_note = "Clockwork Cultist (solo) antag granter."

//Services
/*
/datum/opposing_force_equipment/uplink/give_exploitables
	name = "Exploitables Access"
	description = "You will be given access to a network of exploitable information of certain crewmates, viewable using either a verb or on examine."
	item_type = /obj/effect/gibspawner/generic
	admin_note = "Same effect as using the traitor panel Toggle Exploitables Override button. Usually safe to give."

/datum/opposing_force_equipment/uplink/give_exploitables/on_issue(mob/living/target)
	target.mind.has_exploitables_override = TRUE
	target.mind.handle_exploitables()
*/

/datum/opposing_force_equipment/uplink/custom_announcement
	name = "Custom Announcement"
	item_type = /obj/item/device/traitor_announcer
	admin_note = "Ask players to put the message inside the 'Reason' box, the item adminlogs but won't give a chance to preview. Can be VV'd to give more 'uses'."
	description = "A one-use device that lets you make an announcement tailored to your choice."

/datum/opposing_force_equipment/uplink/power_outage
	name = "Power Outage"
	description = "A virus will be uploaded to the engineering processing servers to force a routine power grid check, forcing all APCs on the station to be temporarily disabled."
	item_type = /obj/effect/gibspawner/generic
	admin_note = "Equivalent to the Grid Check random event."
	max_amount = 1

/datum/opposing_force_equipment/uplink/power_outage/on_issue()
	var/datum/round_event_control/event = locate(/datum/round_event_control/grid_check) in SSevents.control
	event.run_event()

/datum/opposing_force_equipment/uplink/telecom_outage
	name = "Telecomms Outage"
	description = "A virus will be uploaded to the telecommunication processing servers to temporarily disable themselves."
	item_type = /obj/effect/gibspawner/generic
	admin_note = "Equivalent to the Communications Blackout random event."
	max_amount = 1

/datum/opposing_force_equipment/uplink/telecom_outage/on_issue()
	var/datum/round_event_control/event = locate(/datum/round_event_control/communications_blackout) in SSevents.control
	event.run_event()
