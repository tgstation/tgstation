///your an evil person for grinding poor slimes up into ooze

/obj/machinery/plumbing/slime_grinder
	name = "slime grinder"
	desc = "An unholy creation, does not grind the slimes quickly."

	icon = 'monkestation/code/modules/slimecore/icons/slime_grinder.dmi'
	icon_state = "slime_grinder_backdrop"
	base_icon_state = "slime_grinder_backdrop"
	idle_power_usage = 10
	active_power_usage = 1000
	buffer = 3000
	category="Distribution"

	var/grind_time = 5 SECONDS
	///this is the face you see when you start grinding the poor slime up
	var/mob/living/basic/slime/poster_boy
	///list of all the slimes we have
	var/list/soon_to_be_crushed = list()
	///the amount of souls we have grinded
	var/trapped_souls = 0
	///are we grinding some slimes
	var/GRINDING_SOME_SLIMES = FALSE


/obj/machinery/plumbing/slime_grinder/Initialize(mapload, bolt, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_supply, bolt, layer)

/obj/machinery/plumbing/slime_grinder/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(length(soon_to_be_crushed) && !GRINDING_SOME_SLIMES)
		Shake(6, 6, 10 SECONDS)
		GRINDING_SOME_SLIMES = TRUE
		var/datum/looping_sound/microwave/new_loop = new(src)
		new_loop.start()
		machine_do_after_visable(src, 10 SECONDS)
		GRINDING_SOME_SLIMES = FALSE
		new_loop.stop()
		playsound(src, 'sound/machines/blender.ogg', 50, TRUE)
		grind_slimes()

/obj/machinery/plumbing/slime_grinder/proc/grind_slimes()
	poster_boy = null
	update_appearance()
	for(var/mob/living/basic/slime/slime as anything in soon_to_be_crushed)
		trapped_souls++

		var/datum/slime_color/current_color = slime.current_color
		reagents.add_reagent(current_color.secretion_path, 25)
		soon_to_be_crushed -= slime
		qdel(slime)
	soon_to_be_crushed = list()

/obj/machinery/plumbing/slime_grinder/update_overlays()
	. = ..()
	if(poster_boy)
		var/mutable_appearance/slime = poster_boy.appearance
		. += slime
	. += mutable_appearance(icon, "slime_grinder_overlay", layer + 0.1, src)

/obj/machinery/plumbing/slime_grinder/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	. = ..()
	if(isslime(AM))
		if(!poster_boy)
			poster_boy = AM
			poster_boy.layer = layer
			poster_boy.plane = plane
		SEND_SIGNAL(AM, COMSIG_EMOTION_STORE, null, EMOTION_SCARED, "I'm trapped inside a blender, I don't want to die!")
		AM.update_appearance()
		soon_to_be_crushed |= AM
		AM.forceMove(src)
		update_appearance()
