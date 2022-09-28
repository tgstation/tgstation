/obj/item/announcer
	name = "Station-Wide News Announcer"
	desc = "İstasyonda herkesin duyabileceği şekilde önemli haberleri duyurmanı sağlar."
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-white"
	w_class = WEIGHT_CLASS_SMALL
	var/charge = 1
	var/list/charge_timers = list()
	var/charge_time = 600

/obj/item/announcer/attack_self(mob/living/user)
	if(!(HAS_TRAIT(user, TRAIT_JOURNALIST)))
		to_chat(user, span_warning("Bu aletin nasıl çalıştığını anlamıyorsun."))
		return
	if(charge <= 0)
		to_chat(user, span_warning("Alet şarj oluyor!"))
		return
	var/input = tgui_input_text(user, "Message to announce to the station crew", "Announcement")
	var/list/players = get_communication_players()
	if((HAS_TRAIT(user, TRAIT_JOURNALIST)))
		make_announcement(user, input, players)
		use_charge()
		return

/obj/item/announcer/proc/make_announcement(mob/living/user, input, list/players)
	priority_announce(html_decode(user.treat_message(input)), null, 'sound/misc/breaking_news.ogg', "News", has_important_message = TRUE, players = players)

/obj/item/announcer/proc/get_communication_players()
	return GLOB.player_list

/obj/item/announcer/proc/use_charge(mob/user)
	charge --
	to_chat(user, span_notice("You use [src]. It now has [charge] charge[charge == 1 ? "" : "s"] remaining."))
	charge_timers.Add(addtimer(CALLBACK(src, .proc/recharge), charge_time, TIMER_STOPPABLE))

/obj/item/announcer/proc/recharge(mob/user)
	charge = min(charge+1)
	playsound(src,'sound/machines/twobeep.ogg',10,TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)
	charge_timers.Remove(charge_timers[1])
