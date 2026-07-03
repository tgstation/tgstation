/obj/item/melee/baseball_bat/homerun/centcom
	name = "Nanotrasen Fleet tactical bat"
	desc = "Выдвижная тактическая бита Центрального Командования Nanotrasen. \
	В официальных документах эта бита проходит под элегантным названием \"Высокоскоростная система доставки СРП\". \
	Выдаваясь только самым верным и эффективным офицерам Nanotrasen, это оружие является одновременно символом статуса \
	и инструментом высшего правосудия."
	w_class = WEIGHT_CLASS_SMALL
	/// Force when concealed
	force = 5
	/// Force when extended
	throwforce = 12
	wound_bonus = -50
	icon = 'modular_bandastation/weapon/icons/melee/baseball.dmi'
	lefthand_file = 'modular_bandastation/weapon/icons/melee/inhands/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/melee/inhands/righthand.dmi'
	inhand_icon_state = "centcom_bat"
	icon_state = "centcom_bat"
	attack_verb_simple = list("hit", "poked")
	homerun_able = TRUE
	always_homerun = TRUE
	/// Sound of extending the bat
	var/on_sound = 'sound/items/weapons/batonextend.ogg'
	/// Force when extended
	var/force_on = 100
	/// Wound bonus when extended
	var/wound_bonus_on = 100
	/// Attack verbs when extended (created on Initialize)
	var/list/attack_verb_on = list("smacked", "struck", "cracked", "beaten")

/obj/item/melee/baseball_bat/homerun/centcom/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)
	AddComponent( \
		/datum/component/transforming, \
		force_on = force_on, \
		hitsound_on = hitsound, \
		w_class_on = WEIGHT_CLASS_HUGE, \
		clumsy_check = FALSE, \
		attack_verb_continuous_on = list("smacks", "strikes", "cracks", "beats"), \
		attack_verb_simple_on = list("smack", "strike", "crack", "beat"), \
	)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/obj/item/melee/baseball_bat/homerun/centcom/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	if(user)
		balloon_alert(user, active ? "вытянуто" : "втянуто")
	if(active)
		wound_bonus = wound_bonus_on
	else
		wound_bonus = initial(wound_bonus)
	playsound(src, on_sound, 50, TRUE)

	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/melee/baseball_bat/homerun/centcom/pickup(mob/user)
	. = ..()
	if(!isliving(user))
		return
	var/mob/living/living_user = user
	if(living_user.mind.centcom_role)
		return
	living_user.AdjustKnockdown(10 SECONDS, daze_amount = 3 SECONDS)
	living_user.Stun(5 SECONDS, TRUE)
	to_chat(user, span_userdanger("Это - оружие истинного правосудия. Тебе не дано обуздать его мощь."))
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		human_user.apply_damage(rand(force/2, force), BRUTE, human_user.get_active_hand())
	else
		living_user.adjust_brute_loss(rand(force/2, force))

/obj/item/melee/baseball_bat/homerun/centcom/pre_attack(atom/movable/target, mob/living/user, params)
	var/datum/component/transforming/transform_component = GetComponent(/datum/component/transforming)
	if(transform_component.active)
		return FALSE

	target.visible_message(
		span_warning("[capitalize(user.declent_ru(NOMINATIVE))] тыкает [target.declent_ru(ACCUSATIVE)] с помощью [declent_ru(GENITIVE)]. К счастью, оно было выключено."),
		span_warning("[capitalize(user.declent_ru(NOMINATIVE))] тыкает вас с помощью [declent_ru(GENITIVE)]. К счастью, оно было выключено.")
	)

	return TRUE
