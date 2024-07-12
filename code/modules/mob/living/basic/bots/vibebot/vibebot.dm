/mob/living/basic/bot/vibebot
	name = "\improper Vibebot"
	desc = "A little robot. It's just vibing, doing its thing."
	icon = 'icons/mob/silicon/aibots.dmi'
	icon_state = "vibebot1"
	base_icon_state = "vibebot"
	pass_flags = PASSMOB | PASSFLAPS
	light_system = OVERLAY_LIGHT
	light_range = 6
	ai_controller = /datum/ai_controller/basic_controller/bot/vibebot
	light_power = 2

	hackables = "vibing scanners"
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE
	bot_type = VIBE_BOT
	data_hud_type = DATA_HUD_DIAGNOSTIC_BASIC
	path_image_color = "#2cac12"
	possessed_message = "You are a vibebot! Maintain the station's vibes to the best of your ability!"

/mob/living/basic/bot/vibebot/Initialize(mapload)
	. = ..()
	var/static/list/innate_actions = list(
		/datum/action/cooldown/mob_cooldown/bot/vibe = BB_VIBEBOT_PARTY_ABILITY,
	)

	grant_actions_by_list(innate_actions)
	var/obj/item/instrument/piano_synth/piano = new(src)
	ai_controller.set_blackboard_key(BB_SONG_INSTRUMENT, piano)
	update_appearance(UPDATE_ICON)
