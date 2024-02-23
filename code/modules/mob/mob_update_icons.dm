//Most of these are defined at this level to reduce on checks elsewhere in the code.
//Having them here also makes for a nice reference list of the various overlay-updating procs available

///Redraws the entire mob. For carbons, this is rather expensive, please use the individual update_X procs.
/mob/proc/regenerate_icons() //TODO: phase this out completely if possible
	return

///Updates every item slot passed into it.
/mob/proc/update_clothing(slot_flags)
	return

/mob/proc/update_icons()
	return

///Updates the handcuff overlay & HUD element.
/mob/proc/update_worn_handcuffs()
	return

///Updates the legcuff overlay & HUD element.
/mob/proc/update_worn_legcuffs()
	return

///Updates the back overlay & HUD element.
/mob/proc/update_worn_back()
	return

///Updates the held items overlay(s) & HUD element.
/mob/proc/update_held_items()
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_HELD_ITEMS)

///Updates the mask overlay & HUD element.
/mob/proc/update_worn_mask()
	return

///Updates the neck overlay & HUD element.
/mob/proc/update_worn_neck()
	return

///Updates the oversuit overlay & HUD element.
/mob/proc/update_worn_oversuit()
	return

///Updates the undersuit/uniform overlay & HUD element.
/mob/proc/update_worn_undersuit()
	return

///Updates the belt overlay & HUD element.
/mob/proc/update_worn_belt()
	return

///Updates the on-head overlay & HUD element.
/mob/proc/update_worn_head()
	return

///Updates every part of a carbon's body. Including parts, mutant parts, lips, underwear, and socks.
/mob/proc/update_body()
	return

/mob/proc/update_hair()
	return

///Updates the glasses overlay & HUD element.
/mob/proc/update_worn_glasses()
	return

///Updates the id overlay & HUD element.
/mob/proc/update_worn_id()
	return

///Updates the shoes overlay & HUD element.
/mob/proc/update_worn_shoes()
	return

///Updates the glasses overlay & HUD element.
/mob/proc/update_worn_gloves()
	return

///Updates the handcuff overlay & HUD element.
/mob/proc/update_suit_storage()
	return

///Updates the handcuff overlay & HUD element.
/mob/proc/update_pockets()
	return

///Updates the handcuff overlay & HUD element.
/mob/proc/update_inv_ears()
	return
