//Quick Emote Binds
/datum/keybinding/emote
	category = CATEGORY_EMOTE
	weight = WEIGHT_EMOTE
	var/emote_key
	keybind_signal = COMSIG_KB_EMOTE_QUICK_EMOTE

/datum/keybinding/emote/proc/link_to_emote(datum/emote/faketype)
	key = "Unbound"
	emote_key = initial(faketype.key)
	name = initial(faketype.key)
	full_name = capitalize(initial(faketype.key))
	description = "Do the emote '*[emote_key]'"

/datum/keybinding/emote/down(client/user)
	. = ..()
	return user.mob.emote(emote_key, intentional=TRUE)

/datum/keybinding/human/equip_swap
	key = "Alt-E"
	name = "equip_swap"
	full_name = "Quick-Swap Equipment"
	description = "Directly swaps held equippable item with its equipped counterpart, if possible.  Requires a free hand!"
	keybind_signal = COMSIG_KB_HUMAN_EQUIPSWAP_DOWN

/datum/keybinding/human/equip_swap/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = user.mob
	H.equip_swap()
	return TRUE
