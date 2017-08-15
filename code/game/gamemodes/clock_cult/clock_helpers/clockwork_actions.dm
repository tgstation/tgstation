//Sends a string to all servants and optionally ghosts, who will get a follow link to whatever is provided as the target.
/proc/hierophant_message(message, servantsonly, atom/target)
	if(!message)
		return FALSE
	for(var/M in GLOB.mob_list)
		if(!servantsonly && isobserver(M))
			if(target)
				var/link = FOLLOW_LINK(M, target)
				to_chat(M, "[link] [message]")
			else
				to_chat(M, message)
		else if(is_servant_of_ratvar(M))
			to_chat(M, message)
	return TRUE

//Sends a titled message from a mob to all servants of ratvar and ghosts.
/proc/titled_hierophant_message(mob/user, message, name_span = "heavy_brass", message_span = "brass", user_title = "Servant")
	if(!user || !message)
		return FALSE
	var/parsed_message = "<span class='[name_span]'>[user_title ? "[user_title] ":""][findtextEx(user.name, user.real_name) ? user.name : "[user.real_name] (as [user.name])"]: \
	</span><span class='[message_span]'>\"[message]\"</span>"
	hierophant_message(parsed_message, FALSE, user)
	return TRUE

//Hierophant Network action, allows a servant with it to communicate to other servants.
/datum/action/innate/hierophant
	name = "Hierophant Network"
	desc = "Allows you to communicate with other Servants."
	icon_icon = 'icons/mob/actions/actions_clockcult.dmi'
	button_icon_state = "hierophant"
	background_icon_state = "bg_clock"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN|AB_CHECK_CONSCIOUS
	buttontooltipstyle = "clockcult"
	var/title = "Servant"
	var/span_for_name = "heavy_brass"
	var/span_for_message = "brass"

/datum/action/innate/hierophant/IsAvailable()
	if(!is_servant_of_ratvar(owner))
		return FALSE
	return ..()

/datum/action/innate/hierophant/Activate()
	var/input = stripped_input(usr, "Please enter a message to send to other servants.", "Hierophant Network", "")
	if(!input || !IsAvailable())
		return

	clockwork_say(owner, "[text2ratvar("Servants, hear my words: [input]")]", TRUE)
	log_talk(owner,"CLOCK:[key_name(owner)] : [input]",LOGSAY)
	titled_hierophant_message(owner, input, span_for_name, span_for_message, title)

//Summon Spear action: Calls forth a Ratvarian spear.
/datum/action/innate/summon_spear
	name = "Summon Spear"
	desc = "Allows you to summon or dismiss your Ratvarian spear."
	icon_icon = 'icons/mob/actions/actions_clockcult.dmi'
	button_icon_state = "ratvarian_spear"
	background_icon_state = "bg_clock"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN|AB_CHECK_CONSCIOUS
	buttontooltipstyle = "clockcult"
	var/cooldown = 0
	var/dismiss_cooldown = 20
	var/break_cooldown = 300
	var/obj/item/clockwork/ratvarian_spear/spear

/datum/action/innate/summon_spear/IsAvailable()
	if(!is_servant_of_ratvar(owner) || cooldown > world.time)
		return FALSE
	return ..()

/datum/action/innate/summon_spear/Activate()
	if(!QDELETED(spear))
		to_chat(owner, "<span class='brass'>You dismiss your Ratvarian spear.</span>")
		cooldown = world.time + dismiss_cooldown
		owner.update_action_buttons_icon()
		addtimer(CALLBACK(owner, /mob.proc/update_action_buttons_icon), dismiss_cooldown)
		spear.break_spear()
		return TRUE
	if(!owner.get_empty_held_indexes())
		to_chat(usr, "<span class='warning'>You need an empty hand to call forth your Ratvarian spear!</span>")
		return FALSE
	owner.visible_message("<span class='warning'>A strange spear materializes in [owner]'s hands!</span>", "<span class='heavy_brass'>You call forth your Ratvarian spear!</span>")
	spear = new(get_turf(usr))
	spear.summon_action = src
	owner.put_in_hands(spear)
	cooldown = world.time + dismiss_cooldown
	owner.update_action_buttons_icon()
	addtimer(CALLBACK(owner, /mob.proc/update_action_buttons_icon), dismiss_cooldown)
	return TRUE

//Call Cuirass action: Calls forth a set of clockwork armor
/datum/action/innate/call_cuirass
	name = "Call Cuirass"
	desc = "Allows you to summon or dismiss your set of clockwork armor."
	icon_icon = 'icons/mob/actions/actions_clockcult.dmi'
	button_icon_state = "clockwork_armor"
	background_icon_state = "bg_clock"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN|AB_CHECK_CONSCIOUS
	buttontooltipstyle = "clockcult"
	var/cooldown = 0
	var/dismiss_cooldown = 20
	var/list/summoned_armor = list()
	var/static/list/better_armor_typecache = typecacheof(list(
	/obj/item/clothing/suit/space,
	/obj/item/clothing/head/helmet/space,
	/obj/item/clothing/shoes/magboots))

/datum/action/innate/call_cuirass/IsAvailable()
	if(!is_servant_of_ratvar(owner))
		return FALSE
	return ..()

/datum/action/innate/call_cuirass/Activate()
	if(LAZYLEN(summoned_armor))
		var/did_dismiss = FALSE
		for(var/i in summoned_armor)
			var/obj/item/clothing/C = i
			if(!QDELETED(C))
				did_dismiss = TRUE
				qdel(C)
			summoned_armor -= i
		if(did_dismiss) //maybe it got deleted, so only show a message and don't summon more if we did delete something doing this
			to_chat(owner, "<span class='brass'>You dismiss your clockwork armor.</span>")
			cooldown = world.time + dismiss_cooldown
			owner.update_action_buttons_icon()
			addtimer(CALLBACK(owner, /mob.proc/update_action_buttons_icon), dismiss_cooldown)
			return TRUE
	var/list/failure_message = list()
	var/obj/item/I = owner.get_item_by_slot(slot_gloves)
	if(check_if_item_prevents(I, owner))
		failure_message += "gloves"
	I = owner.get_item_by_slot(slot_shoes)
	if(check_if_item_prevents(I, owner))
		failure_message += "shoes"
	I = owner.get_item_by_slot(slot_wear_suit)
	if(check_if_item_prevents(I, owner))
		failure_message += "suit"
	I = owner.get_item_by_slot(slot_head)
	if(check_if_item_prevents(I, owner))
		failure_message += "helmet"
	if(LAZYLEN(failure_message))
		var/list/temp_message = list()
		for(var/i in 1 to LAZYLEN(failure_message))
			if(i != 1)
				if(i == LAZYLEN(failure_message))
					if(i != 2)
						temp_message += ", and "
					else
						temp_message += " and "
				else
					temp_message += ", "
			temp_message += failure_message[i]
		to_chat(owner, "<span class='warning'>You need to remove your [temp_message.Join()] before you can summon your clockwork armor!</span>")
		return FALSE
	var/do_message = 0
	var/static/list/clockwork_armor_to_slot_assoc = list(
	/obj/item/clothing/suit/armor/clockwork = slot_wear_suit,
	/obj/item/clothing/head/helmet/clockwork = slot_head,
	/obj/item/clothing/gloves/clockwork = slot_gloves,
	/obj/item/clothing/shoes/clockwork = slot_shoes)
	for(var/i in clockwork_armor_to_slot_assoc)
		I = owner.get_item_by_slot(clockwork_armor_to_slot_assoc[i])
		if(owner.dropItemToGround(I))
			var/obj/item/clothing/C = new i()
			do_message += owner.equip_to_slot_or_del(C, clockwork_armor_to_slot_assoc[i])
			if(!QDELETED(C))
				summoned_armor += C
	if(do_message)
		owner.visible_message("<span class='warning'>Strange armor appears on [owner]!</span>", "<span class='heavy_brass'>A bright shimmer runs down your body as you summon your clockwork armor.</span>")
		playsound(owner, 'sound/magic/clockwork/fellowship_armory.ogg', 10*do_message, 1, -5) //get sound loudness based on how much we equipped
		cooldown = world.time + dismiss_cooldown
		owner.update_action_buttons_icon()
		addtimer(CALLBACK(owner, /mob.proc/update_action_buttons_icon), dismiss_cooldown)
	return do_message

/datum/action/innate/call_cuirass/proc/check_if_item_prevents(obj/item/I, mob/user)
	if(!GLOB.ratvar_awakens && is_type_in_typecache(I, better_armor_typecache))
		return TRUE
	return FALSE
