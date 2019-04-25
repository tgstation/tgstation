//Soul vessel: An ancient positronic brain that serves only Ratvar.
/obj/item/mmi/posibrain/soul_vessel
	name = "soul vessel"
	desc = "A heavy brass cube, three inches to a side, with a single protruding cogwheel."
	var/clockwork_desc = "A soul vessel, an ancient relic that can attract the souls of the damned or simply rip a mind from an unconscious or dead human.\n\
	<span class='brass'>If active, can serve as a positronic brain, placable in cyborg shells or clockwork construct shells.</span>"
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "soul_vessel"
	req_access = list()
	braintype = "Servant"
	begin_activation_message = "<span class='brass'>You activate the cogwheel. It hitches and stalls as it begins spinning.</span>"
	success_message = "<span class='brass'>The cogwheel's rotation smooths out as the soul vessel activates.</span>"
	fail_message = "<span class='warning'>The cogwheel creaks and grinds to a halt. Maybe you could try again?</span>"
	new_role = "Soul Vessel"
	welcome_message = "<span class='warning'>ALL PAST LIVES ARE FORGOTTEN.</span>\n\
	<b>You are a soul vessel - a clockwork mind created by Ratvar, the Clockwork Justiciar.\n\
	You answer to Ratvar and his servants. It is your discretion as to whether or not to answer to anyone else.\n\
	The purpose of your existence is to further the goals of the servants and Ratvar himself. Above all else, serve Ratvar.</b>"
	new_mob_message = "<span class='brass'>The soul vessel emits a jet of steam before its cogwheel smooths out.</span>"
	dead_message = "<span class='deadsay'>Its cogwheel, scratched and dented, lies motionless.</span>"
	recharge_message = "<span class='warning'>The soul vessel's internal geis capacitor is still recharging!</span>"
	possible_names = list("Judge", "Guard", "Servant", "Smith", "Auger")
	autoping = FALSE
	resistance_flags = FIRE_PROOF | ACID_PROOF
	force_replace_ai_name = TRUE
	overrides_aicore_laws = TRUE

/obj/item/mmi/posibrain/soul_vessel/Initialize()
	. = ..()
	radio.on = FALSE
	laws = new /datum/ai_laws/ratvar()
	braintype = picked_name
	GLOB.all_clockwork_objects += src

/obj/item/mmi/posibrain/soul_vessel/Destroy()
	GLOB.all_clockwork_objects -= src
	return ..()

/obj/item/mmi/posibrain/soul_vessel/examine(mob/user)
	if((is_servant_of_ratvar(user) || isobserver(user)) && clockwork_desc)
		desc = clockwork_desc
	..()
	desc = initial(desc)

/obj/item/mmi/posibrain/soul_vessel/transfer_personality(mob/candidate)
	. = ..()
	if(.)
		add_servant_of_ratvar(brainmob, TRUE)

/obj/item/mmi/posibrain/soul_vessel/attack_self(mob/living/user)
	if(!is_servant_of_ratvar(user))
		to_chat(user, "<span class='warning'>You fiddle around with [src], to no avail.</span>")
		return FALSE
	..()

/obj/item/mmi/posibrain/soul_vessel/attack(mob/living/target, mob/living/carbon/human/user)
	if(!is_servant_of_ratvar(user) || !ishuman(target))
		..()
		return
	if(QDELETED(brainmob))
		return
	if(brainmob.key)
		to_chat(user, "<span class='nezbere'>\"This vessel is filled, friend. Provide it with a body.\"</span>")
		return
	if(is_servant_of_ratvar(target))
		to_chat(user, "<span class='nezbere'>\"It would be more wise to revive your allies, friend.\"</span>")
		return
	if(target.suiciding)
		to_chat(user, "<span class='nezbere'>\"This ally isn't able to be revived.\"</span>")
		return
	var/mob/living/carbon/human/H = target
	if(H.stat == CONSCIOUS)
		to_chat(user, "<span class='warning'>[H] must be dead or unconscious for you to claim [H.p_their()] mind!</span>")
		return
	if(H.head)
		var/obj/item/I = H.head
		if(I.flags_inv & HIDEHAIR) //they're wearing a hat that covers their skull
			to_chat(user, "<span class='warning'>[H]'s head is covered, remove [H.p_their()] [H.head] first!</span>")
			return
	if(H.wear_mask)
		var/obj/item/I = H.wear_mask
		if(I.flags_inv & HIDEHAIR) //they're wearing a mask that covers their skull
			to_chat(user, "<span class='warning'>[H]'s head is covered, remove [H.p_their()] [H.wear_mask] first!</span>")
			return
	var/obj/item/bodypart/head/HE = H.get_bodypart(BODY_ZONE_HEAD)
	if(!HE) //literally headless
		to_chat(user, "<span class='warning'>[H] has no head, and thus no mind to claim!</span>")
		return
	var/obj/item/organ/brain/B = H.getorgan(/obj/item/organ/brain)
	if(!B) //either somebody already got to them or robotics did
		to_chat(user, "<span class='warning'>[H] has no brain, and thus no mind to claim!</span>")
		return
	if(B.suicided || B.brainmob?.suiciding)
		to_chat(user, "<span class='nezbere'>\"This ally isn't able to be revived.\"</span>")
		return
	if(!H.key) //nobody's home
		to_chat(user, "<span class='warning'>[H] has no mind to claim!</span>")
		return
	if(brainmob.suiciding)
		brainmob.set_suicide(FALSE)
	playsound(H, 'sound/misc/splort.ogg', 60, 1, -1)
	playsound(H, 'sound/magic/clockwork/anima_fragment_attack.ogg', 40, 1, -1)
	H.fakedeath("soul_vessel") //we want to make sure they don't deathgasp and maybe possibly explode
	H.death()
	H.cure_fakedeath("soul_vessel")
	H.apply_status_effect(STATUS_EFFECT_SIGILMARK) //let them be affected by vitality matrices
	picked_name = "Slave"
	braintype = picked_name
	brainmob.timeofhostdeath = H.timeofdeath
	user.visible_message("<span class='warning'>[user] presses [src] to [H]'s head, ripping through the skull and carefully extracting the brain!</span>", \
	"<span class='brass'>You extract [H]'s consciousness from [H.p_their()] body, trapping it in the soul vessel.</span>")
	transfer_personality(H)
	brainmob.fully_replace_character_name(null, "[braintype] [H.real_name]")
	name = "[initial(name)] ([brainmob.name])"
	B.Remove(H)
	qdel(B)
	H.update_hair()
