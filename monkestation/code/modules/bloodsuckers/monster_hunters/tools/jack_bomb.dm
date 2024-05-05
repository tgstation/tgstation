/obj/item/grenade/jack
	name = "jack in the bomb"
	desc = "Best kids' toy"
	icon = 'monkestation/icons/bloodsuckers/weapons.dmi'
	icon_state = "jack_in_the_bomb"
	inhand_icon_state = "flashbang"
	worn_icon_state = "grenade"
	w_class = WEIGHT_CLASS_SMALL
	det_time = 12 SECONDS
	ex_dev = 1
	ex_heavy = 2
	ex_light = 4
	ex_flame = 2

/obj/item/grenade/jack/arm_grenade(mob/user, delayoverride, msg = TRUE, volume = 60)
	log_grenade(user) //Inbuilt admin procs already handle null users
	if(user)
		add_fingerprint(user)
		if(msg)
			user.balloon_alert(user, "primed [src]!")
			to_chat(user, span_warning("You prime [src]! [capitalize(DisplayTimeText(det_time))]!"))
	playsound(src, 'monkestation/sound/bloodsuckers/jackinthebomb.ogg', volume, vary = TRUE)
	if(istype(user))
		user.add_mob_memory(/datum/memory/bomb_planted, protagonist = user, antagonist = src)
	active = TRUE
	icon_state = "jack_in_the_bomb_active"
	SEND_SIGNAL(src, COMSIG_GRENADE_ARMED, det_time, delayoverride)
	addtimer(CALLBACK(src, PROC_REF(detonate)), isnull(delayoverride) ? det_time : delayoverride)

/obj/item/grenade/jack/detonate(mob/living/lanced_by)
	if (dud_flags)
		active = FALSE
		update_appearance()
		return FALSE
	dud_flags |= GRENADE_USED // Don't detonate if we have already detonated.
	icon_state = "jack_in_the_bomb_live"
	addtimer(CALLBACK(src, PROC_REF(exploding)), 1 SECONDS)

/obj/item/grenade/jack/botch_check(mob/living/carbon/human/user)
	if(!IS_MONSTERHUNTER(user))
		to_chat(user, span_danger("You can't begin to comprehend how to properly arm [src], it's as if it were designed by madmen!"))
		arm_grenade(user, 0.5 SECONDS, FALSE)
		return TRUE
	return ..()

/obj/item/grenade/jack/proc/exploding(mob/living/lanced_by)
	SEND_SIGNAL(src, COMSIG_GRENADE_DETONATE, lanced_by)
	explosion(src, ex_dev, ex_heavy, ex_light, ex_flame)
