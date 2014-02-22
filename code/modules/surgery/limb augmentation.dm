
//REMOVING LIMBS\\\

/datum/surgery_step/remove_limb
	implements = list(/obj/item/weapon/scalpel = 100, /obj/item/weapon/wirecutters = 55)
	time = 32
	var/obj/item/organ/limb/L = null // L because "limb"
	allowed_organs = list("r_arm","l_arm","r_leg","l_leg")

/datum/surgery_step/clean_area
	implements = list(/obj/item/weapon/scalpel = 100, /obj/item/weapon/wirecutters = 20)
	time = 20
	allowed_organs = list("r_arm","l_arm","r_leg","l_leg")


/datum/surgery_step/remove_limb/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = new_organ
	if(L)
		user.visible_message("<span class ='notice'>[user] begins to sever [target]'s [parse_zone(user.zone_sel.selecting)] muscle.</span>")
	else
		user.visible_message("<span class ='notice'>[user] looks for [target]'s [parse_zone(user.zone_sel.selecting)].</span>")


/datum/surgery_step/remove_limb/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(L)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			L.state = ORGAN_REMOVED
			user.visible_message("<span class='notice'>[user] successfully removes [target]'s [parse_zone(user.zone_sel.selecting)]!</span>")
			if(L.body_part == HEAD || L.body_part == CHEST)
				user.visible_message("<span class='notice'>[user] successfully removes some flesh around [target]'s [parse_zone(user.zone_sel.selecting.)]!</span>")
			else
				user.visible_message("<span class='notice'>[user] successfully removes [target]'s [parse_zone(user.zone_sel.selecting)]!</span>")
				L.drop_limb(H)
			H.update_body()
			user.attack_log += "\[[time_stamp()]\]<font color='red'> Removed [target.name]'s [parse_zone(user.zone_sel.selecting)] ([target.ckey]) INTENT: [uppertext(user.a_intent)])</font>"
			target.attack_log += "\[[time_stamp()]\]<font color='orange'> limb removed by [user.name] ([user.ckey]) (INTENT: [uppertext(user.a_intent)])</font>"
			log_attack("<font color='red'>[user.name] ([user.ckey]) removed limb of [target.name] ([target.ckey]) (INTENT: [uppertext(user.a_intent)])</font>")
		else
			user.visible_message("<span class='notice'>[user] [target] has no [parse_zone(user.zone_sel.selecting)] there!</span>")
		return 1


/datum/surgery/removal
	name = "removal"
	steps = list(/datum/surgery_step/clean_area, /datum/surgery_step/incise ,/datum/surgery_step/saw, /datum/surgery_step/remove_limb)
	species = list(/mob/living/carbon/human)
	location = "anywhere"
	has_multi_loc = 1
