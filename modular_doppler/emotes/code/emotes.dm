/datum/emote
	var/cant_muffle = FALSE

// Makes everyone able to do custom emotes regardless of what they are
/datum/emote/living/custom
	mob_type_blacklist_typecache = list(/mob/living/brain)
	stat_allowed = SOFT_CRIT
