/datum/round_event_control/shittening
	name = "Shitty Suggestion Activation"
	typepath = /datum/round_event/shittening
	weight = 0
	earliest_start = INFINITY //a REAL failsafe against it happening ever without admin intervention
	max_occurrences = 1

/datum/round_event/shittening
	announceWhen = 0
	startWhen = 1

/datum/round_event/shittening/announce()
	priority_announce("Unknown, possibly hostile alien lifeforms resembling feces detected aboard [station_name()], please be wary of shitty behaviors.", "Shit Alert")

/datum/round_event/shittening/start()
	ticker.mode.shitty = 1
	for(var/mob/M in living_mob_list)
		M << "<span class='userdanger'>You suddenly feel as if the universe is just that much shittier.</span>"
		if(M.job == "Chaplain")
			M << "<span class='notice'><b><font size=3>The light of [ticker.Bible_deity_name ? ticker.Bible_deity_name : "the gods"] suffuses you, igniting an inner fire. You are now a paladin!</font></span>"
			M.verbs += /mob/living/carbon/human/proc/smite_evil
			M.say("PRAISE")

	for(var/obj/item/weapon/reagent_containers/food/snacks/faggot/F in world)
		if(istype(F, /obj/item/weapon/reagent_containers/food/snacks/faggot/deadchat))
			continue
		F.visible_message("<span class='deadsay'><b><i>Strange energies suddenly swirl around \the [F], which begins to glow with an eldritch light.</i></b></span>")
		new /obj/item/weapon/reagent_containers/food/snacks/faggot/deadchat(F.loc)
		qdel(F)
