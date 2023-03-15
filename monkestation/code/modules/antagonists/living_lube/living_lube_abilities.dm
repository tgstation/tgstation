/obj/effect/proc_holder/spell/aoe_turf/knock/living_lube
	action_background_icon_state = "bg_hive" //closest to a pink spell color we have
	charge_max = 30 SECONDS
	range = 5
	invocation = "AULIE HONKSIN FIERA"
	invocation_type = "whisper"

/obj/effect/proc_holder/spell/aimed/banana_peel/living_lube
	action_background_icon_state = "bg_hive"

/obj/effect/proc_holder/spell/voice_of_god/clown/living_lube
	action_background_icon_state = "bg_hive"
	power_mod = 0.5 //Slightly more annoying

/obj/effect/proc_holder/spell/targeted/smoke/living_lube
	action_background_icon_state = "bg_hive"

/obj/effect/proc_holder/spell/targeted/displacement
	name = "Displacement"
	desc = "Force someone through the clown dimension and launch them out somewhere else on the station."
	charge_max = 2 MINUTES
	clothes_req = FALSE
	range = 7
	invocation_type = "none"
	include_user = TRUE
	action_icon = 'icons/mob/actions/actions_spells.dmi'
	action_icon_state = "blink"
	action_background_icon_state = "bg_hive"

/obj/effect/proc_holder/spell/targeted/displacement/cast(list/targets, mob/user = usr)
	var/target = targets[1]

	if(!isliving(target))
		return

	if(get_dist(user,target)>range)
		to_chat(user, "<span class='notice'>\The [target] is too far away!</span>")
		return

	do_teleport(target,find_safe_turf(),asoundin = 'sound/items/bikehorn.ogg')
	to_chat(target,"<span class='warning'>You hear honking as you're teleported somewhere else!</span>")
	. = ..()
