/datum/round_event_control/wizard/summon_gifts
	name = "Gifts For Everyone!"
	weight = 3
	max_occurrences = 2
	earliest_start = 0 MINUTES
	typepath = /datum/round_event/wizard/summon_gifts
	description = "Gives every sentient carbon mob an xmas gift."

/datum/round_event/wizard/summon_gifts/start()
	for(var/mob/living/carbon/gifted_mob in GLOB.alive_player_list) //sentient monkeys get gifts too!
		var/obj/item/gift = new /obj/item/a_gift/anything/wiz_name(get_turf(gifted_mob))
		gifted_mob.put_in_hands(gift)
		playsound(get_turf(gifted_mob),'sound/magic/summon_guns.ogg', 50, 1)
		to_chat(gifted_mob, "A magical gift appears before you!")

/obj/item/a_gift/anything/wiz_name
	name = "Mysterious Gift" //these are not chrimstmas gifts and should not be named as such
