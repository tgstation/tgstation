/obj/item/essential_oil
	name = "-brand essential oil"
	desc = "A plastic container of essential oils. Use for back massages."
	icon = 'icons/obj/barber_and_tailor.dmi'
	icon_state = "oil"
	var/list/reagents_to_apply = list()
	var/potency = 100

/obj/item/essential_oil/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	if(target == user)
		var/static/regex/last_name = new("\[^\\s-\]+$")
		last_name.Find(user.name)
		to_chat(user, "You can't give yourself a massage. How are you going to reach your back? Think, [last_name.match], think!")
		return
	if(ishuman(target))
		var/mob/living/carbon/human/massage_target = target
		if(massage_target.wear_suit)
			to_chat(user, "You can't give a massage to someone wearing a suit. You can't reach their back!")
			return
		if(massage_target.w_uniform)
			to_chat(user, "You can't give a massage to someone wearing a jumpsuit. You can't reach their back!")
			return
		playsound(massage_target, 'sound/items/oil_application.ogg', 100)
		user.balloon_alert(user, "beginning massage")
		if(do_after(user, 5 SECONDS, massage_target))
			playsound(massage_target, 'sound/items/oil_applied.ogg', 100)
			user.balloon_alert(user, "finished massage")
			to_chat(user, "You finish giving a massage to [massage_target].")
			var/datum/status_effect/reagent_massage/massage_status = massage_target.apply_status_effect(STATUS_EFFECT_REAGENT_MASSAGE)
			massage_status.potency = potency
			massage_status.reagents_to_apply = reagents_to_apply.Copy()
			qdel(src)
