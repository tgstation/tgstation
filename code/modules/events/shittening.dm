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
	for(var/obj/machinery/turret/T in global_turret_list)
		T.say("Firmware update complete: Switching to High Explosive Rounds.")
		T.lasertype = 7

	for(var/obj/machinery/porta_turret/T in global_turret_list)
		T.say("Firmware update complete: Switching to High Explosive Rounds.")
		T.projectile = /obj/item/projectile/bullet/gyro
		T.eprojectile = /obj/item/projectile/bullet/gyro

	for(var/obj/item/weapon/storage/box/monkeycubes/B in global_monkeycubebox_list)
		B.visible_message("<span class = 'notice'>[B] appears to go through box division, and has divided into 2 separate boxes! What could be inside the new box?")
		new /obj/item/weapon/storage/box/clowncubes(B.loc)

	for(var/obj/item/weapon/reagent_containers/food/snacks/pie/P in global_pie_list)
		if(istype(P, /obj/item/weapon/reagent_containers/food/snacks/pie/syndicate))
			continue
		P.visible_message("<span class = 'notice'>[P] transforms into a syndicate pie!</span>")
		new /obj/item/weapon/reagent_containers/food/snacks/pie/syndicate(P.loc)
		qdel(P)
	for(var/obj/item/weapon/reagent_containers/food/snacks/customizable/pie/P in global_pie_list)
		P.visible_message("<span class = 'notice'>[P] transforms into a syndicate pie!</span>")
		new /obj/item/weapon/reagent_containers/food/snacks/pie/syndicate(P.loc)
		qdel(P)