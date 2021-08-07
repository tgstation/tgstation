// This used to be in paper.dm, it was some snowflake code that was
// used ONLY on april's fool.  I moved it to a component so it could be
// used in other places

//This is copypasted on other obj so if you are readin this go refactor it, start on objs with var/limiting_spam
/datum/component/honkspam
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/limiting_spam = FALSE

/datum/component/honkspam/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, .proc/interact)

/datum/component/honkspam/proc/reset_spamflag()
	limiting_spam = FALSE

/datum/component/honkspam/proc/interact(mob/user)
	SIGNAL_HANDLER
	if(!limiting_spam)
		limiting_spam = TRUE
		var/obj/item/parent_item = parent
		playsound(parent_item.loc, 'sound/items/bikehorn.ogg', 50, TRUE)
		addtimer(CALLBACK(src, .proc/reset_spamflag), 2 SECONDS)
