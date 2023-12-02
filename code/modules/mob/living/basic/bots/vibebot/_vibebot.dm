/mob/living/basic/bot/vibebot
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
	possessed_message = "You are a vibebot! Maintain the station's vibes to the best of your ability!"

	ai_controller = /datum/ai_controller/basic_controller/bot/vibebot

/mob/living/basic/bot/vibebot/Initialize(mapload)
	. = ..()
	GRANT_ACTION(/datum/action/innate/vibe)


