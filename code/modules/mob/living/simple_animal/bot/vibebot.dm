/mob/living/simple_animal/bot/vibebot
	name = "\improper Vibebot"
	desc = "A little robot. It's just vibing, doing its thing."
	icon = 'icons/mob/aibots.dmi'
	icon_state = "vibebot"
	density = FALSE
	anchored = FALSE
	health = 25
	maxHealth = 25
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	pass_flags = PASSMOB | PASSFLAPS
	light_system = MOVABLE_LIGHT
	light_range = 7
	light_power = 3

	hackables = "vibing scanners"
	bot_mode_flags = ~BOT_MODE_PAI_CONTROLLABLE
	radio_key = /obj/item/encryptionkey/headset_service //doesn't have security key
	radio_channel = RADIO_CHANNEL_SERVICE //Doesn't even use the radio anyway.
	bot_type = VIBE_BOT
	data_hud_type = DATA_HUD_DIAGNOSTIC_BASIC // show jobs
	path_image_color = "#2cac12"


/mob/living/simple_animal/bot/vibebot/Initialize(mapload)
	. = ..()
	update_appearance()

/mob/living/simple_animal/bot/vibebot/turn_off()
	. = ..()
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	update_appearance()

/mob/living/simple_animal/bot/vibebot/proc/Vibe()
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	add_atom_colour("#[random_color()]", TEMPORARY_COLOUR_PRIORITY)
	set_light_color(color)
	update_appearance()

/mob/living/simple_animal/bot/vibebot/proc/retaliate(mob/living/carbon/human/H)


/mob/living/simple_animal/bot/vibebot/handle_automated_action()
	. = ..()
	if(!.)
		return

	if(bot_mode_flags & BOT_MODE_ON)
		Vibe()

	if(!(bot_mode_flags & BOT_MODE_AUTOPATROL))
		return

	if(mode == BOT_IDLE || mode == BOT_START_PATROL)
		start_patrol()
	if(mode == BOT_PATROL)
		bot_patrol()
