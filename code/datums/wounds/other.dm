// stubbed toe (for when the captain needs to justify a shuttle call)
/datum/wound/brute/stubbed_toe
	name = "stubbed toe"
	desc = "Patient's large toe has been mildly bruised, resulting in moderate discomfort and an extreme need to abandon their post."
	treat_text = "Recommended firm reminder of punishment for dereliction of duty under Space Law."
	examine_desc = "is slightly bruised"
	occur_text = "bonks into a nearby object, injuring its big toe"
	sound_effect = 'sound/effects/crack1.ogg'
	var/datum/component/limp/current_limp
	wound_type = WOUND_TYPE_SPECIAL
	viable_zones = list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	treatable_by = list(/obj/item/gun) // IF YOU WILL NOT SERVE IN COMBAT, YOU WILL SERVE ON THE FIRING LINE
	severity = WOUND_SEVERITY_MODERATE
	limp_slowdown = 1

/datum/wound/brute/stubbed_toe/apply_wound(obj/item/bodypart/L, silent=FALSE, datum/wound/old_wound = NONE, special_arg=NONE)
	. = ..()
	current_limp = victim.AddComponent(/datum/component/limp)

/datum/wound/brute/stubbed_toe/try_treating(obj/item/I, mob/user)
	if(user != victim && user.zone_selected == BODY_ZONE_HEAD)
		user.visible_message("<span class='green'>[user] helpfully reminds [victim] of the punishment for gross deriliction of duty by aiming [I] point blank at [victim.p_their()] head, curing [victim.p_their()] stubbed toe!</span>", \
			"<span class='nicegreen'>You helpfully remind [victim] of the punishment for gross deriliction of duty by aiming [I] point blank at [victim.p_their()] head, curing their stubbed toe!</span>", ignored_mobs=list(victim))
		to_chat(victim, "<span class='nicegreen'><b>[user] helpfully reminds you of the punishment for gross deriliction of duty by aiming [I] point blank at your head! Suddenly your stubbed toe is cured!</b></span>")
		remove_wound()
		return TRUE
