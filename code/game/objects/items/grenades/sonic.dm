/obj/item/grenade/sonic
	name = "sonic grenade"
	desc = "It is set to detonate in 3 seconds."
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "sonic"
	inhand_icon_state = "flashbang"
	det_time = 3 SECONDS
	var/base_damage = 16
	var/sonicbomb_range = 7 //how many tiles away the mob will be stunned.

/obj/item/grenade/sonic/detonate()
	update_mob()

	var/sonicbomb_turf = get_turf(src)
	if(!sonicbomb_turf)
		return

	playsound(sonicbomb_turf, 'sound/effects/screech.ogg', 25, TRUE)

	for(var/mob/living/M in get_hearers_in_view(sonicbomb_range, sonicbomb_turf))
		bang(get_turf(M), M)

	sleep(2 SECONDS) // Give it a delay before deletion for style points.
	qdel(src)
	return

/obj/item/grenade/sonic/proc/bang(turf/T , mob/living/M)
	if(M.stat == DEAD)	//They're dead!
		return
	M.show_message(span_userdanger("SCREECH"), MSG_AUDIBLE)
	M.Paralyze(5 SECONDS)
	M.Knockdown(15 SECONDS)
	M.adjust_confusion(24 SECONDS)
	M.adjust_jitter(5 SECONDS)
	M.soundbang_act(1, 20, 10, 15)
	M.adjustOrganLoss(ORGAN_SLOT_EARS, -base_damage)
