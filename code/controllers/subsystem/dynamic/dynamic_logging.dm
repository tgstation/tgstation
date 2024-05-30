/// A "snapshot" of dynamic at an important point in time.
/// Exported to JSON in the dynamic.json log file.
/datum/dynamic_snapshot
	/// The remaining midround threat
	var/remaining_threat

	/// The world.time when the snapshot was taken
	var/time

	/// The total number of players in the server
	var/total_players

	/// The number of alive players
	var/alive_players

	/// The number of dead players
	var/dead_players

	/// The number of observers
	var/observers

	/// The number of alive antags
	var/alive_antags

	/// The rulesets chosen this snapshot
	var/datum/dynamic_snapshot_ruleset/ruleset_chosen

	/// The cached serialization of this snapshot
	var/serialization

/// A ruleset chosen during a snapshot
/datum/dynamic_snapshot_ruleset
	/// The name of the ruleset chosen
	var/name

	/// If it is a round start ruleset, how much it was scaled by
	var/scaled

	/// The number of assigned antags
	var/assigned

/datum/dynamic_snapshot_ruleset/New(datum/dynamic_ruleset/ruleset)
	name = ruleset.name
	assigned = ruleset.assigned.len

	if (istype(ruleset, /datum/dynamic_ruleset/roundstart))
		scaled = ruleset.scaled_times

/// Convert the snapshot to an associative list
/datum/dynamic_snapshot/proc/to_list()
	if (!isnull(serialization))
		return serialization

	serialization = list(
		"remaining_threat" = remaining_threat,
		"time" = time,
		"total_players" = total_players,
		"alive_players" = alive_players,
		"dead_players" = dead_players,
		"observers" = observers,
		"alive_antags" = alive_antags,
		"ruleset_chosen" = list(
			"name" = ruleset_chosen.name,
			"scaled" = ruleset_chosen.scaled,
			"assigned" = ruleset_chosen.assigned,
		),
	)

	return serialization

/// Updates the log for the current snapshots.
/datum/controller/subsystem/dynamic/proc/update_log()
	var/list/serialized = list()
	serialized["threat_level"] = threat_level
	serialized["round_start_budget"] = initial_round_start_budget
	serialized["mid_round_budget"] = threat_level - initial_round_start_budget
	serialized["shown_threat"] = shown_threat

	var/list/serialized_snapshots = list()
	for (var/datum/dynamic_snapshot/snapshot as anything in snapshots)
		serialized_snapshots += list(snapshot.to_list())
	serialized["snapshots"] = serialized_snapshots

	rustg_file_write(json_encode(serialized), "[GLOB.log_directory]/dynamic.json")

/// Creates a new snapshot with the given rulesets chosen, and writes to the JSON output.
/datum/controller/subsystem/dynamic/proc/new_snapshot(datum/dynamic_ruleset/ruleset_chosen)
	var/datum/dynamic_snapshot/new_snapshot = new

	new_snapshot.remaining_threat = mid_round_budget
	new_snapshot.time = world.time
	new_snapshot.alive_players = GLOB.alive_player_list.len
	new_snapshot.dead_players = GLOB.dead_player_list.len
	new_snapshot.observers = GLOB.current_observers_list.len
	new_snapshot.total_players = new_snapshot.alive_players + new_snapshot.dead_players + new_snapshot.observers
	new_snapshot.alive_antags = GLOB.current_living_antags.len
	new_snapshot.ruleset_chosen = new /datum/dynamic_snapshot_ruleset(ruleset_chosen)

	LAZYADD(snapshots, new_snapshot)

	update_log()
