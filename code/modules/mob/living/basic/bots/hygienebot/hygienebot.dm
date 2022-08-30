///Hygiene bot, chases dirty people!
/mob/living/basic/bot/hygienebot
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

	///Is the bot currently washing it's target/everything else that crosses it?
	var/washing = FALSE

	///Visual overlay of the bot spraying water.
	var/mutable_appearance/water_overlay
	///Visual overlay of the bot commiting warcrimes.
	var/mutable_appearance/fire_overlay



/mob/living/basic/bot/hygienebot/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_ICON)

	// Doing this hurts my soul, but simplebot access reworks are for another day.
	var/datum/id_trim/job/jani_trim = SSid_access.trim_singletons_by_path[/datum/id_trim/job/janitor]
	access_card.add_access(jani_trim.access + jani_trim.wildcard_access)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

	ADD_TRAIT(src, TRAIT_SPRAY_PAINTABLE, INNATE_TRAIT)

/mob/living/basic/bot/hygienebot/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	set_mob_speed(0.75)
	start_washing()

/mob/living/basic/bot/hygienebot/explode()
	new /obj/effect/particle_effect/fluid/foam(loc)

	return ..()

/mob/living/basic/bot/hygienebot/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(washing)
		do_wash(AM)

/mob/living/basic/bot/hygienebot/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][bot_mode_flags & BOT_MODE_ON ? "-on" : null]"


/mob/living/basic/bot/hygienebot/update_overlays()
	. = ..()
	if(bot_mode_flags & BOT_MODE_ON)
		. += mutable_appearance(icon, "hygienebot-flame")

	if(washing)
		. += mutable_appearance(icon, bot_cover_flags & BOT_COVER_EMAGGED ? "hygienebot-fire" : "hygienebot-water")

/mob/living/basic/bot/hygienebot/proc/start_washing()
	washing = TRUE
	update_appearance()

/mob/living/basic/bot/hygienebot/proc/stop_washing()
	if(bot_cover_flags & BOT_COVER_EMAGGED) //can't be turned off if emagged!
		return
	washing = FALSE
	update_appearance()
	var/turf/open/tile = get_turf(src)
	if(isopenturf(tile))
		tile.MakeSlippery(TURF_WET_WATER, min_wet_time = 10 SECONDS, wet_time_to_add = 5 SECONDS)

/mob/living/basic/bot/hygienebot/proc/do_wash(atom/A)
	if(bot_cover_flags & BOT_COVER_EMAGGED)
		A.fire_act()  //lol pranked no cleaning besides that
	else
		A.wash(CLEAN_WASH)


/mob/living/basic/bot/hygienebot/speak(message, channel, angry = FALSE)
	. = ..()
	if(angry)
		playsound(get_turf(src), 'sound/effects/hygienebot_angry.ogg', 60, 1)
	else
		playsound(get_turf(src), 'sound/effects/hygienebot_happy.ogg', 60, 1)
