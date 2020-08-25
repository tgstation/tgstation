// This used to be in paper.dm, it was some snowflake code that was
// used ONLY on april's fool.  I moved it to a component so it could be
// used in other places

/datum/component/honkspam
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/spam_flag = FALSE

/datum/component/honkspam/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, .proc/interact)

/datum/component/honkspam/proc/reset_spamflag()
	spam_flag = FALSE

/datum/component/honkspam/proc/interact(mob/user)
	if(!spam_flag)
		spam_flag = TRUE
		var/obj/item/parent_item = parent
		playsound(parent_item.loc, 'sound/items/bikehorn.ogg', 50, TRUE)
		addtimer(CALLBACK(src, .proc/reset_spamflag), 2 SECONDS)
