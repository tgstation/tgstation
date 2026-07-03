/obj/item/clothing/head/costume/foilhat
	name = "tinfoil hat"
	desc = "Thought control rays, psychotronic scanning. Don't mind that, I'm protected cause I made this hat."
	icon_state = "foilhat"
	inhand_icon_state = null
	armor_type = /datum/armor/costume_foilhat
	equip_delay_other = 14 SECONDS
	clothing_flags = ANTI_TINFOIL_MANEUVER
	clothing_traits = list(TRAIT_DONT_HEAR_PRAYERS) //stops you from hearing prayers as well, yes
	var/datum/brain_trauma/mild/phobia/conspiracies/paranoia
	var/warped = FALSE
	interaction_flags_mouse_drop = NEED_HANDS

/datum/armor/costume_foilhat
	laser = -5
	energy = -15

/obj/item/clothing/head/costume/foilhat/Initialize(mapload)
	. = ..()
	if(warped)
		warp_up()
		return

	AddComponent(
		/datum/component/anti_magic, \
		antimagic_flags = MAGIC_RESISTANCE_MIND, \
		inventory_flags = ITEM_SLOT_HEAD, \
		charges = 6, \
		block_magic = CALLBACK(src, PROC_REF(drain_antimagic)), \
		expiration = CALLBACK(src, PROC_REF(warp_up)) \
	)


/obj/item/clothing/head/costume/foilhat/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_HEAD) || warped)
		return
	if(paranoia)
		QDEL_NULL(paranoia)
	paranoia = new()

	RegisterSignal(user, COMSIG_HUMAN_SUICIDE_ACT, PROC_REF(call_suicide))

	user.gain_trauma(paranoia, TRAUMA_RESILIENCE_MAGIC)
	to_chat(user, span_warning("As you don the foiled hat, an entire world of conspiracy theories and seemingly insane ideas suddenly rush into your mind. What you once thought unbelievable suddenly seems.. undeniable. Everything is connected and nothing happens just by accident. You know too much and now they're out to get you. "))

/obj/item/clothing/head/costume/foilhat/mouse_drop_dragged(atom/over_object, mob/user)
	//God Im sorry
	if(!warped && iscarbon(user))
		var/mob/living/carbon/C = user
		if(src == C.head)
			to_chat(C, span_userdanger("Why would you want to take this off? Do you want them to get into your mind?!"))
			return
	return ..()

/obj/item/clothing/head/costume/foilhat/dropped(mob/user)
	. = ..()
	if(paranoia)
		QDEL_NULL(paranoia)
	UnregisterSignal(user, COMSIG_HUMAN_SUICIDE_ACT)

/// When the foilhat is drained an anti-magic charge.
/obj/item/clothing/head/costume/foilhat/proc/drain_antimagic(mob/user)
	to_chat(user, span_warning("[src] crumples slightly. Something is trying to get inside your mind!"))

/obj/item/clothing/head/costume/foilhat/proc/warp_up()
	name = "scorched tinfoil hat"
	desc = "A badly warped up hat. Quite unlikely this will still work against any of the fictional or real dangers it used to."
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

/obj/item/clothing/head/costume/foilhat/attack_hand(mob/user, list/modifiers)
	if(!warped && iscarbon(user))
		var/mob/living/carbon/wearer = user
		if(src == wearer.head)
			to_chat(user, span_userdanger("Why would you want to take this off? Do you want them to get into your mind?!"))
			return
	return ..()

/obj/item/clothing/head/costume/foilhat/microwave_act(obj/machinery/microwave/microwave_source, mob/microwaver, randomize_pixel_offset)
	. = ..()
	if(warped)
		return

	warp_up()
	return . | COMPONENT_MICROWAVE_SUCCESS

/obj/item/clothing/head/costume/foilhat/proc/call_suicide(datum/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(suicide_act), source) //SIGNAL_HANDLER doesn't like things waiting; INVOKE_ASYNC bypasses that
	return OXYLOSS

/obj/item/clothing/head/costume/foilhat/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] gets a crazed look in [user.p_their()] eyes! [capitalize(user.p_they())] [user.p_have()] witnessed the truth, and try to commit suicide!"))
	var/static/list/conspiracy_line = list(
		";ОНИ СКРЫВАЮТ КАМЕРЫ В ПОТОЛКАХ! ОНИ ВИДЯТ ВСЁ, ЧТО МЫ ДЕЛАЕМ!!",
		";КАК Я МОГУ ЖИТЬ В МИРЕ, ГДЕ МОЯ СУДЬБА И СУЩЕСТВОВАНИЕ РЕШАЕТСЯ КАКОЙ-ТО ГРУППОЙ ЛИЦ?!!",
		";ОНИ ИГРАЮТ СО ВСЕМИ ВАШИМИ УМАМИ И ОТНОСЯТСЯ К ВАМ КАК К ПОДОПЫТНЫМ!!",
		";ОНИ НАНИМАЮТ АССИСТЕНТОВ, НЕ ПРОВЕРЯЯ ИХ БИОГРАФИЮ!!",
		";МЫ ЖИВЕМ В ЗООПАРКЕ, И МЫ - ТЕ, ЗА КЕМ ЗДЕСЬ ПРИСМАТРИВАЮТ!!",
		";МЫ ПОВТОРЯЕМ СВОЮ ЖИЗНЬ ЕЖЕДНЕВНО, НЕ ЗАДАВАЯ ЛИШНИХ ВОПРОСОВ!!"
	)
	user.say(pick(conspiracy_line), forced=type)
	var/obj/item/organ/brain/brain = user.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(brain)
		brain.set_organ_damage(BRAIN_DAMAGE_DEATH)
	return OXYLOSS
