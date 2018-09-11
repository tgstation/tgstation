/datum/antagonist/magic_servant
	name = "Magic Servant"
	show_in_roundend = FALSE
	show_in_antagpanel = FALSE

/datum/antagonist/magic_servant/proc/setup_master(mob/M)
	var/datum/objective/O = new("Serve [M.real_name].")
	O.owner = owner
	objectives |= O