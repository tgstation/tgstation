/obj/item/clothing/head/foilhat
	name = "tinfoil hat"
	desc = "Thought control rays, psychotronic scanning. Don't mind that, I'm protected cause I made this hat."
	icon_state = "foilhat"
	inhand_icon_state = "foilhat"
	armor = list(MELEE = 0, BULLET = 0, LASER = -5,ENERGY = -15, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	equip_delay_other = 140
	clothing_flags = ANTI_TINFOIL_MANEUVER
	var/datum/brain_trauma/mild/phobia/conspiracies/paranoia
	var/warped = FALSE

/obj/item/clothing/head/foilhat/Initialize(mapload)
	. = ..()
	if(!warped)
		AddComponent(/datum/component/anti_magic, FALSE, FALSE, TRUE, ITEM_SLOT_HEAD,  6, TRUE, null, CALLBACK(src, .proc/warp_up))
	else
		warp_up()

/obj/item/clothing/head/foilhat/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot != ITEM_SLOT_HEAD || warped)
		return
	if(paranoia)
		QDEL_NULL(paranoia)
	paranoia = new()

	RegisterSignal(user, COMSIG_HUMAN_SUICIDE_ACT, .proc/call_suicide)

	user.gain_trauma(paranoia, TRAUMA_RESILIENCE_MAGIC)
	to_chat(user, span_warning("As you don the foiled hat, an entire world of conspiracy theories and seemingly insane ideas suddenly rush into your mind. What you once thought unbelievable suddenly seems.. undeniable. Everything is connected and nothing happens just by accident. You know too much and now they're out to get you. "))

/obj/item/clothing/head/foilhat/MouseDrop(atom/over_object)
	//God Im sorry
	if(!warped && iscarbon(usr))
		var/mob/living/carbon/C = usr
		if(src == C.head)
			to_chat(C, span_userdanger("Why would you want to take this off? Do you want them to get into your mind?!"))
			return
	return ..()

/obj/item/clothing/head/foilhat/dropped(mob/user)
	. = ..()
	if(paranoia)
		QDEL_NULL(paranoia)

/obj/item/clothing/head/foilhat/proc/warp_up()
	name = "scorched tinfoil hat"
	desc = "A badly warped up hat. Quite unprobable this will still work against any of fictional and contemporary dangers it used to."
	warped = TRUE
	clothing_flags &= ~ANTI_TINFOIL_MANEUVER
	if(!isliving(loc) || !paranoia)
		return
	var/mob/living/target = loc
	UnregisterSignal(target, COMSIG_HUMAN_SUICIDE_ACT)
	if(target.get_item_by_slot(ITEM_SLOT_HEAD) != src)
		return
	QDEL_NULL(paranoia)
	if(target.stat < UNCONSCIOUS)
		to_chat(target, span_warning("Your zealous conspirationism rapidly dissipates as the donned hat warps up into a ruined mess. All those theories starting to sound like nothing but a ridicolous fanfare."))

/obj/item/clothing/head/foilhat/attack_hand(mob/user, list/modifiers)
	if(!warped && iscarbon(user))
		var/mob/living/carbon/wearer = user
		if(src == wearer.head)
			to_chat(user, span_userdanger("Why would you want to take this off? Do you want them to get into your mind?!"))
			return
	return ..()

/obj/item/clothing/head/foilhat/microwave_act(obj/machinery/microwave/M)
	. = ..()
	if(!warped)
		warp_up()

/obj/item/clothing/head/foilhat/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] gets a crazed look in [user.p_their()] eyes! [capitalize(user.p_they())] [user.p_have()] witnessed the truth, and try to commit suicide!"))
	var/conspiracy_line = pick(list(
		";THEY'RE HIDING CAMERAS IN THE CEILINGS! THEY WITNESS EVERYTHING WE DO!!",
		";HOW CAN I LIVE IN A WORLD WHERE MY FATE AND EXISTANCE IS DECIDED BY A GROUP OF INDIVIDUALS?!!",
		";THEY'RE TOYING WITH ALL OF YOUR MINDS AND TREATING YOU AS EXPERIMENTS!!",
		";THEY HIRE ASSISTANTS WITHOUT DOING BACKGROUND CHECKS!!",
		";WE LIVE IN A ZOO AND WE ARE THE ONES BEING OBSERVED!!",
		";WE REPEAT OUR LIVES DAILY WITHOUT FURTHER QUESTIONS!!"
	))
	user.say(conspiracy_line)
	var/obj/item/organ/brain/brain = user.getorganslot(ORGAN_SLOT_BRAIN)
	if(brain)
		brain.damage = BRAIN_DAMAGE_DEATH
		user.death(gibbed = FALSE)
		user.ghostize(can_reenter_corpse = FALSE)
		return MANUAL_SUICIDE
	return OXYLOSS

/obj/item/clothing/head/foilhat/proc/call_suicide(datum/source)
	SIGNAL_HANDLER
	suicide_act(source)
