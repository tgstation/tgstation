///from mind/transfer_to. Sent after the mind has been transferred: (mob/previous_body)
#define COMSIG_MIND_TRANSFERRED "mind_transferred"

/// Called on the mind when an antagonist is being gained, after the antagonist list has updated (datum/antagonist/antagonist)
#define COMSIG_ANTAGONIST_GAINED "antagonist_gained"

/// Called on the mind when an antagonist is being removed, after the antagonist list has updated (datum/antagonist/antagonist)
#define COMSIG_ANTAGONIST_REMOVED "antagonist_removed"

/// Called when an observer attempts to possess a ghost_role_spawnpoint component-bearing mob
#define COMSIG_ATTEMPT_POSSESSION "attempt_possession" //Find a better file to put this in
