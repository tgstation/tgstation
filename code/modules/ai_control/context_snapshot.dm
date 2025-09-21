/// Captures situational data consumed by the AI planner each evaluation cadence.

/datum/ai_context_snapshot
	var/timestamp
	var/turf/location
	var/list/zone_metadata
	var/list/nearby_entities
	var/list/environmental_alerts
	var/list/available_equipment
	var/list/player_orders

/datum/ai_context_snapshot/New(turf/location, list/zone_metadata = null, list/nearby_entities = null, list/environmental_alerts = null, list/available_equipment = null, list/player_orders = null)
	..()
	timestamp = world.time
	src.location = location
	src.zone_metadata = zone_metadata?.Copy() || list()
	src.nearby_entities = nearby_entities?.Copy() || list()
	src.environmental_alerts = environmental_alerts?.Copy() || list()
	src.available_equipment = available_equipment?.Copy() || list()
	src.player_orders = player_orders?.Copy() || list()

/// Returns TRUE when the snapshot should be discarded.
/datum/ai_context_snapshot/proc/is_expired(current_time = world.time)
	return (current_time - timestamp) > AI_CONTEXT_SNAPSHOT_TTL

/datum/ai_context_snapshot/proc/age(current_time = world.time)
	return max(current_time - timestamp, 0)

/datum/ai_context_snapshot/proc/set_alerts(list/new_alerts)
	environmental_alerts = new_alerts?.Copy() || list()

/datum/ai_context_snapshot/proc/add_alert(alert_id)
	if(isnull(alert_id))
		return
	if(!environmental_alerts)
		environmental_alerts = list()
	environmental_alerts += alert_id

/datum/ai_context_snapshot/proc/clone()
	return new /datum/ai_context_snapshot(location, zone_metadata, nearby_entities, environmental_alerts, available_equipment, player_orders)

/datum/ai_context_snapshot/proc/to_list()
	return list(
		"timestamp" = timestamp,
		"location" = location,
		"zone_metadata" = zone_metadata?.Copy(),
		"nearby_entities" = nearby_entities?.Copy(),
		"environmental_alerts" = environmental_alerts?.Copy(),
		"available_equipment" = available_equipment?.Copy(),
		"player_orders" = player_orders?.Copy(),
	)
