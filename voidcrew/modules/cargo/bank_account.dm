/datum/bank_account/ship/New(newname, job, modifier, player_account, obj/structure/overmap/ship/ship)
	. = ..()
	SSeconomy.department_accounts += list("[newname]" = "[newname] Budget")

/datum/bank_account/ship/Destroy()
	. = ..()
	SSeconomy.department_accounts -= list("[account_holder]" = "[account_holder] Budget")
