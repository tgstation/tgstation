///Hygiene bot, chases dirty people!
/mob/living/basic/bot/hygiene
	name = "\improper Hygienebot"
	desc = "A flying cleaning robot, he'll chase down people who can't shower properly!"
	icon = 'icons/mob/aibots.dmi'
	icon_state = "hygienebot"
	base_icon_state = "hygienebot"
	pass_flags = PASSMOB | PASSFLAPS | PASSTABLE
	layer = MOB_UPPER_LAYER
	density = FALSE
	anchored = FALSE
	health = 100
	maxHealth = 100

	maints_access_required = list(ACCESS_ROBOTICS, ACCESS_JANITOR)
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE //Service
	bot_mode_flags = ~BOT_MODE_PAI_CONTROLLABLE
	bot_type = HYGIENE_BOT
	hackables = "cleaning service protocols"
	path_image_color = "#993299"

	///The human target the bot is trying to wash.
	var/mob/living/carbon/human/target
	///The mob's current speed, which varies based on how long the bot chases it's target.
	var/currentspeed = 5
	///Is the bot currently washing it's target/everything else that crosses it?
	var/washing = FALSE
	///Have the target evaded the bot for long enough that it will swear at it like kirk did to kahn?
	var/mad = FALSE
	///The last time that the previous/current target was found.
	var/last_found
	///Name of the previous target the bot was pursuing.
	var/oldtarget_name
	///Visual overlay of the bot spraying water.
	var/mutable_appearance/water_overlay
	///Visual overlay of the bot commiting warcrimes.
	var/mutable_appearance/fire_overlay
