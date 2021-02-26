/datum/component/greentext
	var/mob/living/last_holder = null
	var/mob/living/current_holder
	var/list/color_altered_mobs = list()
	var/quiet = FALSE

/datum/component/greentext/Initialize()
	if (!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_PICKUP, .proc/equip)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/unequip)
	roundend_callback = CALLBACK(src, .proc/check_winner)
	SSticker.OnRoundend(roundend_callback)

/datum/component/greentext/proc/equip(item , mob/living/user as mob)
	SIGNAL_HANDLER
	if (user == current_holder)
		return
	to_chat(user, "<font color='green'>So long as you leave this place with greentext in hand you know will be happy...</font>")
	var/list/other_objectives = user.mind.get_all_objectives()
	if(user.mind && other_objectives.len > 0)
		to_chat(user, "<span class='warning'>... so long as you still perform your other objectives that is!</span>")
	current_holder = user
	if(!last_holder)
		last_holder = user
	if(!(user in color_altered_mobs))
		color_altered_mobs += user
	user.add_atom_colour("#00FF00", ADMIN_COLOUR_PRIORITY)
	START_PROCESSING(SSobj, src)

/datum/component/greentext/proc/unequip(item , mob/living/user as mob)
	SIGNAL_HANDLER
	if(user in color_altered_mobs)
		to_chat(user, "<span class='warning'>A sudden wave of failure washes over you...</span>")
		user.add_atom_colour("#FF0000", ADMIN_COLOUR_PRIORITY) //ya blew it
	last_holder = null
	current_holder = null
	STOP_PROCESSING(SSobj, src)

/datum/component/greentext/proc/check_winner()
	if(!current_holder)
		return

	if(is_centcom_level(current_holder.z))//you're winner!
		to_chat(current_holder, "<font color='green'>At last it feels like victory is assured!</font>")
		current_holder.mind.add_antag_datum(/datum/antagonist/greentext)
		current_holder.log_message("won with greentext!!!", LOG_ATTACK, color="green")
		color_altered_mobs -= current_holder
		qdel(src)
