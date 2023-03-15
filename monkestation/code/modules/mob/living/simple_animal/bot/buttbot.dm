/mob/living/simple_animal/bot/buttbot
	name = "\improper buttbot"
	desc = "butts"
	icon = 'monkestation/icons/obj/butts.dmi'
	icon_state = "buttbot"
	density = FALSE
	anchored = FALSE
	health = 25
	maxHealth = 25
	bot_type = BUTTS_BOT
	model = "buttbot"
	window_id = "butt"
	window_name = "butts"
	pass_flags = PASSMOB
	has_unlimited_silicon_privilege = FALSE
	remote_disabled = TRUE
	allow_pai = FALSE
	var/cooling_down = FALSE
	var/butt_probability = 15
	var/listen_probability = 30

/mob/living/simple_animal/bot/buttbot/emag_act(mob/user)
	if(!emagged)
		visible_message("<span class='warning'>[user] swipes a card through the [src]'s crack!</span>", "<span class='notice'>You swipe a card through the [src]'s crack.</span>")
		listen_probability = 75
		butt_probability = 30
		emagged = TRUE
		var/turf/butt = get_turf(src)
		butt.atmos_spawn_air("miasma=5;TEMP=310.15")
		playsound(src, pick('sound/misc/fart1.ogg', 'monkestation/sound/effects/fart2.ogg', 'monkestation/sound/effects/fart3.ogg', 'monkestation/sound/effects/fart4.ogg'), 100 ,use_reverb = TRUE)

/mob/living/simple_animal/bot/buttbot/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods)
	. = ..()
	if(!cooling_down && prob(listen_probability) && ishuman(speaker))
		cooling_down = TRUE
		var/list/split_message = splittext(raw_message, " ")
		for (var/i in 1 to length(split_message))
			if(prob(butt_probability))
				split_message[i] = pick("butt", "butts")
		if(emagged)
			var/turf/butt = get_turf(src)
			butt.atmos_spawn_air("miasma=5;TEMP=310.15")
		var/joined_text = jointext(split_message, " ")
		if(!findtext(joined_text, "butt")) //We must butt, or else.
			return
		say(joined_text)
		playsound(src, pick('sound/misc/fart1.ogg', 'monkestation/sound/effects/fart2.ogg', 'monkestation/sound/effects/fart3.ogg', 'monkestation/sound/effects/fart4.ogg'), 25 ,use_reverb = TRUE)
		spawn(20)
			cooling_down = FALSE
