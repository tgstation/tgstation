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

	radio_key = /obj/item/encryptionkey/headset_service //doesn't have security key
	radio_channel = RADIO_CHANNEL_SERVICE //Doesn't even use the radio anyway.
	bot_type = VIBE_BOT
	model = "Vibebot"
	window_id = "vibebot"
	window_name = "Discomatic Vibe Bot v1.05"
	data_hud_type = DATA_HUD_DIAGNOSTIC_BASIC // show jobs
	path_image_color = "#2cac12"
	auto_patrol = TRUE
	light_system = MOVABLE_LIGHT
	light_range = 7
	light_power = 3


/mob/living/simple_animal/bot/vibebot/Initialize()
	. = ..()
	update_icon()

/mob/living/simple_animal/bot/vibebot/get_controls(mob/user)
	var/list/dat = list()
	dat += hack(user)
	dat += showpai(user)
	dat += "<TT><B>DiscoMatic Vibebot v1.0</B></TT><BR><BR>"
	dat += "Status: <A href='?src=[REF(src)];power=1'>[on ? "On" : "Off"]</A><BR>"
	dat += "Maintenance panel panel is [open ? "opened" : "closed"]<BR>"

	dat += "Behaviour controls are [locked ? "locked" : "unlocked"]<BR>"
	if(!locked || issilicon(user) || isAdminGhostAI(user))
		dat += "Patrol Station: <A href='?src=[REF(src)];operation=patrol'>[auto_patrol ? "Yes" : "No"]</A><BR>"

	return dat.Join("")

/mob/living/simple_animal/bot/vibebot/turn_off()
	. = ..()
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	update_icon()

/mob/living/simple_animal/bot/vibebot/proc/Vibe()
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	add_atom_colour("#[random_color()]", TEMPORARY_COLOUR_PRIORITY)
	set_light_color(color)
	update_icon()

/mob/living/simple_animal/bot/vibebot/proc/retaliate(mob/living/carbon/human/H)


/mob/living/simple_animal/bot/vibebot/handle_automated_action()
	if(!..())
		return

	if(auto_patrol)

		if(mode == BOT_IDLE || mode == BOT_START_PATROL)
			start_patrol()

		if(mode == BOT_PATROL)
			bot_patrol()

	if(on)
		Vibe()

	else
		remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
