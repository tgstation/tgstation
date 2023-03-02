/obj/item/return_device
	name = "return device"
	desc = "A complicated multiverse device that you can use on another multiverse jumper to bring you and them back to your homeworld. If you know how to work it, that is."
	icon = 'code/modules/stories_system/icons/return_device.dmi'
	icon_state = "beam_me_up_scotty"
	w_class = WEIGHT_CLASS_SMALL
	var/mob/living/carbon/human/second_jumper
	var/mob/living/carbon/human/worldjumper

/obj/item/return_device/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return // not adjacent
	if(user != second_jumper)
		to_chat(user, "You don't understand how to work this device!")
		return
	if(target != worldjumper)
		to_chat(user, "This isn't the correct person to use this on!")
		return
	user.balloon_alert_to_viewers("[src] begins charging...")
	if(do_after(user, 10 SECONDS, target))
		var/turf/turf_to_explode = get_turf(second_jumper)
		new /obj/effect/temp_visual/emp/pulse(turf_to_explode)
		new /obj/effect/temp_visual/emp/pulse(get_turf(worldjumper))
		second_jumper.gib(TRUE, FALSE, FALSE)
		worldjumper.gib(TRUE, FALSE, FALSE)
		explosion(turf_to_explode, 0, 0, 3, 0, 5) // per writer: (simulating returning to their home dimension… or maybe just showing the device was faulty and killing the pair of them in a hilarious moment of dark humour)
		qdel(src)
