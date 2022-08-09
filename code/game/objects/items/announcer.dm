/obj/item/announcer
	name = "Station-Wide News Announcer"
	desc = "İstasyonda herkesin duyabileceği şekilde önemli haberleri duyurmanı sağlar."
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-white"
	w_class = WEIGHT_CLASS_SMALL
	var/charge = 1
	var/charge_time = 1800

/obj/item/announcer/attack_self(mob/living/user)
	if(!ISJOURNALIST(user))
		to_chat(user, span_warning("Bu aletin nasıl çalıştığını anlamıyorsun."))
		return
	if(charge <= 0)
		to_chat(user, span_warning("Alet şarz oluyor!")) //henüz çalışmıyor bir ara yapıcam
		return
	var/input = tgui_input_text(user, "Message to announce to the station crew", "Announcement")
	var/list/players = get_communication_players()
	if(ISJOURNALIST(user))
		make_announcement(user, input, players)
		return

/obj/item/announcer/proc/make_announcement(mob/living/user, input, list/players)
	priority_announce(html_decode(user.treat_message(input)), null, 'sound/misc/breaking_news.ogg', "News", has_important_message = TRUE, players = players)

/obj/item/announcer/proc/get_communication_players()
	return GLOB.player_list
