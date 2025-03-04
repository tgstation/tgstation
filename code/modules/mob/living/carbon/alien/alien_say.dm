/mob/living/proc/alien_talk(message, shown_name = real_name, big_voice = FALSE)
	src.log_talk(message, LOG_SAY)
	message = trim(message)
	if(!message)
		return

	var/message_a = say_quote(message)
	var/hivemind_spans = "alien"
	if(big_voice)
		hivemind_spans += " big"
	var/rendered = "<i><span class='[hivemind_spans]'>Hivemind, [span_name("[shown_name]")] <span class='message'>[message_a]</span></span></i>"
	for(var/mob/player in GLOB.player_list)
		if(!player.stat && player.hivecheck())
			to_chat(player, rendered, type = MESSAGE_TYPE_RADIO, avoid_highlighting = player == src)
		else if(player in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(player, src)
			to_chat(player, "[link] [rendered]", type = MESSAGE_TYPE_RADIO)

/mob/living/carbon/alien/adult/royal/queen/alien_talk(message, shown_name = name)
	..(message, shown_name, TRUE)

/mob/living/carbon/hivecheck()
	var/obj/item/organ/alien/hivenode/N = get_organ_by_type(/obj/item/organ/alien/hivenode)
	if(N && !N.recent_queen_death) //Mob has alien hive node and is not under the dead queen special effect.
		return TRUE
