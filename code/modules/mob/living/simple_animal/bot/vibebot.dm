/mob/living/simple_animal/bot/vibebot
	name = "\improper vibebot"
	desc = "A little robot. It's just vibing, doing its thing."
	icon = 'icons/mob/aibots.dmi'
	icon_state = "vibebot"
	density = FALSE
	anchored = FALSE
	health = 25
	maxHealth = 25
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	pass_flags = PASSMOB

	radio_key = /obj/item/encryptionkey/headset_service //doesn't have security key
	radio_channel = RADIO_CHANNEL_SERVICE //Doesn't even use the radio anyway.
	model = "Vibebot"
	window_id = "vibebot"
	window_name = "Discomatic Vibe Bot v1.05"
	data_hud_type = DATA_HUD_DIAGNOSTIC_BASIC // show jobs
	path_image_color = "#2cac12"

	var/current_color
	var/range = 7
	var/power = 3

/mob/living/simple_animal/bot/vibebot/Initialize()
	. = ..()
	update_icon()
	auto_patrol = TRUE
	on = TRUE

/mob/living/simple_animal/bot/vibebot/get_controls(mob/user)
	var/dat
	dat += hack(user)
	dat += showpai(user)
	dat += text({"
<TT><B>Discomatic Vibe Bot v1.05 controls</B></TT><BR><BR>
Status: []<BR>
Behaviour controls are [locked ? "locked" : "unlocked"]<BR>
Maintenance panel panel is [open ? "opened" : "closed"]"},

"<A href='?src=[REF(src)];power=[TRUE]'>[on ? "On" : "Off"]</A>" )

	if(!locked || issilicon(user) || IsAdminGhost(user))
		dat += text({"<BR> Auto Patrol: []"},

"<A href='?src=[REF(src)];operation=patrol'>[auto_patrol ? "On" : "Off"]</A>" )
	return	dat
/mob/living/simple_animal/bot/vibebot/turn_on()
	. = ..()
	on = TRUE
	update_icon()
	Vibe()

/mob/living/simple_animal/bot/vibebot/turn_off()
	. = ..()
	on = FALSE
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	update_icon()

/mob/living/simple_animal/bot/vibebot/proc/Vibe()
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	current_color = random_color()
	set_light(range, power, current_color)
	add_atom_colour("#[current_color]", FIXED_COLOUR_PRIORITY)
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

	if(on == TRUE)
		Vibe()

	if(on == FALSE)
		remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
