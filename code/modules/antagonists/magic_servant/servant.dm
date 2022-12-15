/datum/antagonist/magic_servant
	name = "\improper Magic Servant"
	show_in_roundend = FALSE
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	silent = TRUE //don't announce until the servant is taken by a ghost

/datum/antagonist/magic_servant/proc/setup_master(mob/M)
	var/datum/objective/O = new("Serve [M.real_name].")
	O.owner = owner
	objectives |= O

/datum/antagonist/magic_servant/greet()
	. = ..()
	owner.announce_objectives()
