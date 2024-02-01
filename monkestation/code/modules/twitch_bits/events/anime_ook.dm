/datum/twitch_event/anime_ook
	event_name = "Anime Ook"
	event_duration = 1 SECONDS
	event_flags = TWITCH_AFFECTS_STREAMER | CLEAR_TARGETS_AFTER_EFFECTS
	id_tag = T_EVENT_ANIME_OOK
	token_cost = 100

/datum/twitch_event/anime_ook/apply_effects()
	for(var/target in targets)
		var/mob/living/ook = target
		if(ishuman(ook))
			var/mob/living/carbon/human/human_ook = target
			human_ook.alternative_laughs += 'monkestation/sound/misc/ook_loves_cats.ogg'

			var/obj/item/organ/internal/ears/cat/new_ears = new
			new_ears.replace_into(human_ook)
			var/obj/item/organ/external/tail/cat/new_tail = new
			new_tail.replace_into(human_ook)
