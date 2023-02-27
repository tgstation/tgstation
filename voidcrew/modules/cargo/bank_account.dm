//PARENT TYPE
/datum/bank_account
	///List of all shipping containers we have connected to us.
	var/list/obj/structure/shipping_container/shipping_containers = list()

//SHIP SUBTYPE
/datum/bank_account/ship/New(newname, job, modifier, player_account, obj/structure/overmap/ship/ship)
	. = ..()
	SSeconomy.department_accounts += list("[newname]" = "[newname] Budget")

/datum/bank_account/ship/Destroy()
	. = ..()
	SSeconomy.department_accounts -= list("[account_holder]" = "[account_holder] Budget")
