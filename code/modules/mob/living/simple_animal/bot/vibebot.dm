/mob/living/simple_animal/bot/vibebot
	name = "\improper Vibebot"
	desc = "A little robot. It's just vibing, doing its thing."
	icon = 'icons/mob/silicon/aibots.dmi'
	icon_state = "vibebot1"
	base_icon_state = "vibebot"
	density = FALSE
	anchored = FALSE
	health = 25
	maxHealth = 25
	pass_flags = PASSMOB | PASSFLAPS
	light_system = MOVABLE_LIGHT
	light_range = 7
	light_power = 3

	hackables = "vibing scanners"
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE
	bot_type = VIBE_BOT
	data_hud_type = DATA_HUD_DIAGNOSTIC_BASIC
	path_image_color = "#2cac12"

	///The vibe ability given to vibebots, so sentient ones can still change their color.
	var/datum/action/innate/vibe/vibe_ability

/mob/living/simple_animal/bot/vibebot/Initialize(mapload)
	. = ..()
	vibe_ability = new(src)
	vibe_ability.Grant(src)
	update_appearance(UPDATE_ICON)

/mob/living/simple_animal/bot/vibebot/Destroy()
	QDEL_NULL(vibe_ability)
	return ..()

/mob/living/simple_animal/bot/vibebot/handle_automated_action()
	. = ..()
	if(!.)
		return

	if(bot_mode_flags & BOT_MODE_ON)
		vibe_ability.Trigger()

	if(!(bot_mode_flags & BOT_MODE_AUTOPATROL))
		return

	switch(mode)
		if(BOT_IDLE, BOT_START_PATROL)
			start_patrol()
		if(BOT_PATROL)
			bot_patrol()

/mob/living/simple_animal/bot/vibebot/turn_off()
	vibe_ability.remove_colors()
	return ..()

/**
 * Vibebot's vibe ability
 *
 * Given to vibebots so sentient ones can change/reset thier colors at will.
 */
/datum/action/innate/vibe
	name = "Vibe"
	desc = "LMB: Change vibe color. RMB: Reset vibe color."
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "funk"

/datum/action/innate/vibe/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(isbot(owner))
		var/mob/living/simple_animal/bot/bot_mob = owner
		if(!(bot_mob.bot_mode_flags & BOT_MODE_ON))
			return FALSE
	return TRUE

/datum/action/innate/vibe/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	if(trigger_flags & TRIGGER_SECONDARY_ACTION)
		remove_colors()
	else
		vibe()

///Gives a random color
/datum/action/innate/vibe/proc/vibe()
	owner.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	owner.add_atom_colour("#[random_color()]", TEMPORARY_COLOUR_PRIORITY)
	owner.set_light_color(owner.color)

///Removes all colors
/datum/action/innate/vibe/proc/remove_colors()
	owner.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	owner.set_light_color(null)
