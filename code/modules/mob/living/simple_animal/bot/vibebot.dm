/mob/living/simple_animal/bot/vibebot
	name = "\improper Vibebot"
	desc = "A little robot. It's just vibing, doing its thing."
	icon = 'icons/mob/aibots.dmi'
	icon_state = "vibebot"
	density = FALSE
	anchored = FALSE
	health = 25
	maxHealth = 25
	pass_flags = PASSMOB | PASSFLAPS
	light_system = MOVABLE_LIGHT
	light_range = 7
	light_power = 3

	hackables = "vibing scanners"
	bot_mode_flags = ~BOT_MODE_PAI_CONTROLLABLE
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE
	bot_type = VIBE_BOT
	data_hud_type = DATA_HUD_DIAGNOSTIC_BASIC
	path_image_color = "#2cac12"

	///The vibe ability given to vibebots, so sentient ones can still change their color.
	var/datum/action/innate/vibebot_vibe/vibe_ability

/mob/living/simple_animal/bot/vibebot/Initialize(mapload)
	. = ..()
	update_appearance()

/mob/living/simple_animal/bot/vibebot/Destroy()
	QDEL_NULL(vibe_ability)
	return ..()

/mob/living/simple_animal/bot/vibebot/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	vibe_ability = new()
	vibe_ability.Grant(src)
	return TRUE

/mob/living/simple_animal/bot/vibebot/Logout()
	QDEL_NULL(vibe_ability)
	return ..()

/mob/living/simple_animal/bot/vibebot/handle_automated_action()
	. = ..()
	if(!.)
		return

	if(bot_mode_flags & BOT_MODE_ON)
		vibe()

	if(!(bot_mode_flags & BOT_MODE_AUTOPATROL))
		return

	if(mode == BOT_IDLE || mode == BOT_START_PATROL)
		start_patrol()
	if(mode == BOT_PATROL)
		bot_patrol()

/mob/living/simple_animal/bot/vibebot/turn_off()
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	. = ..()

/mob/living/simple_animal/bot/vibebot/proc/vibe()
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	add_atom_colour("#[random_color()]", TEMPORARY_COLOUR_PRIORITY)
	set_light_color(color)

/**
 * Vibebot's vibe ability
 *
 * Given to sentient vibebots so they can also vibe.
 */
/datum/action/innate/vibebot_vibe
	name = "Vibe"
	desc = "Change your vibebot color."
	icon_icon = 'icons/mob/aibots.dmi'
	button_icon_state = "vibebot"
	///The vibebot this action is stored to
	var/mob/living/simple_animal/bot/vibebot/bot_mob

/datum/action/innate/vibebot_vibe/Grant(mob/user)
	. = ..()
	if(!isbot(user))
		return
	var/mob/living/simple_animal/bot/current_bot = user
	if(current_bot.bot_type != VIBE_BOT)
		return
	bot_mob = user

/datum/action/innate/vibebot_vibe/Destroy()
	bot_mob = null
	return ..()

/datum/action/innate/vibebot_vibe/IsAvailable()
	. = ..()
	if(!.)
		return FALSE
	if(!bot_mob)
		return FALSE
	if(!(bot_mob.bot_mode_flags & BOT_MODE_ON))
		return FALSE
	return TRUE

/datum/action/innate/vibebot_vibe/Activate()
	bot_mob.vibe()
