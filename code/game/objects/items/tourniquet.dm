/obj/item/tourniquet
	name = "tourniquet"
	desc = "A medical device used to stop severe bleeding from a limb."
	icon = 'icons/obj/medical/firstaid.dmi'
	icon_state = "tourniquet"

	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	max_integrity = 50
	item_flags = NOBLUDGEON
	custom_premium_price = PAYCHECK_CREW * 2

/obj/item/tourniquet/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/limb_applicable, \
		valid_zones = GLOB.limb_zones.Copy() + BODY_ZONE_HEAD, \
		apply_category = LIMB_ITEM_TOURNIQUET, \
		can_apply = CALLBACK(src, PROC_REF(can_apply_tourniquet)), \
	)
	RegisterSignal(src, COMSIG_ITEM_APPLIED_TO_LIMB, PROC_REF(on_applied_to_limb))
	RegisterSignal(src, COMSIG_ITEM_UNAPPLIED_FROM_LIMB, PROC_REF(on_removed_from_limb))

/obj/item/tourniquet/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/tourniquet/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] begins to wrap [src] around [p_their()] neck too tight! It looks like [user.p_theyre()] trying to commit suicide!"))
	if(!do_after(user, 5 SECONDS, user))
		return SHAME
	var/obj/item/bodypart/head = user.get_bodypart(BODY_ZONE_HEAD)
	if(!head || !head.dismember())
		return SHAME
	return OXYLOSS

/obj/item/tourniquet/proc/on_applied_to_limb(datum/source, obj/item/bodypart/limb)
	SIGNAL_HANDLER
	limb.refresh_bleed_rate()
	switch(limb.body_zone)
		if(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
			var/obj/item/bodypart/arm/arm = limb
			arm.set_speed_modifiers(arm.interaction_modifier + 0.5, arm.click_cd_modifier + 0.5)
		if(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			var/obj/item/bodypart/leg/leg = limb
			leg.set_speed_modifier(leg.speed_modifier + 0.5)
		if(BODY_ZONE_HEAD)
			START_PROCESSING(SSobj, src)

/obj/item/tourniquet/proc/on_removed_from_limb(datum/source, obj/item/bodypart/limb)
	SIGNAL_HANDLER
	limb.refresh_bleed_rate()
	switch(limb.body_zone)
		if(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
			var/obj/item/bodypart/arm/arm = limb
			arm.set_speed_modifiers(arm.interaction_modifier - 0.5, arm.click_cd_modifier - 0.5)
		if(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			var/obj/item/bodypart/leg/leg = limb
			leg.set_speed_modifier(leg.speed_modifier - 0.5)
		if(BODY_ZONE_HEAD)
			START_PROCESSING(SSobj, src)

/obj/item/tourniquet/process(seconds_per_tick)
	var/obj/item/bodypart/limb = loc
	if(!istype(limb) || isnull(limb.owner))
		return PROCESS_KILL
	if(HAS_TRAIT(limb.owner, TRAIT_NOBREATH))
		return // you win this time

	limb.owner.losebreath += 1 * seconds_per_tick // incapable of breathing
	limb.owner.apply_damage(1 * seconds_per_tick, OXY, BODY_ZONE_HEAD, forced = TRUE) // no blood getting to brain
	if(SPT_PROB(6, seconds_per_tick))
		limb.owner.apply_damage(10, STAMINA, BODY_ZONE_HEAD, forced = TRUE)
	if(SPT_PROB(5, seconds_per_tick))
		limb.owner.adjust_eye_blur(4 SECONDS)
	if(SPT_PROB(4, seconds_per_tick))
		limb.owner.adjust_dizzy(4 SECONDS)
		limb.owner.adjust_confusion(2 SECONDS)

/obj/item/tourniquet/proc/can_apply_tourniquet(mob/user, mob/living/patient, obj/item/bodypart/limb)
	var/speed_multiplier = 2
	var/speed_boosted = FALSE
	for(var/datum/wound/woundies as anything in limb.wounds)
		if(!woundies.blood_flow)
			continue
		if(HAS_TRAIT(woundies, TRAIT_WOUND_SCANNED) && limb.body_zone != BODY_ZONE_HEAD)
			speed_multiplier = 0.5
			speed_boosted = TRUE
			break
		speed_multiplier = 1

	if(limb.body_zone == BODY_ZONE_HEAD)
		speed_multiplier *= 2 // are you sure about that?

	else if(user != patient)
		speed_multiplier *= 0.5

	if(limb.body_zone == BODY_ZONE_HEAD)
		user.visible_message(
			span_warning("[user] begins applying [src] to [user == patient ? p_their() : "[patient]'s"] neck..."),
			span_userdanger("You begin applying [src] to [user == patient ? "your" : "[patient]'s"] neck, though you begin wonder if this is a good idea...?"),
			visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
			ignored_mobs = patient,
		)
		if(user != patient)
			patient.show_message(
				span_userdanger("[user] begins applying [src] to your neck! That can't be a good idea...!"),
				MSG_VISUAL,
				span_userdanger("You feel [user] start wrapping something tight around your neck! That can't be a good idea...!"),
			)

	else if(speed_boosted)
		user.visible_message(
			span_notice("[user] begins expertly applying [src] to [user == patient ? p_their() : "[patient]'s"] own [limb.plaintext_zone]..."),
			span_notice("You begin expertly applying [src] to [user == patient ? "your" : "[patient]'s"] own [limb.plaintext_zone], keeping the holo-image indications in mind..."),
			visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
			ignored_mobs = patient,
		)
		if(user != patient)
			patient.show_message(
				span_notice("[user] begins expertly applying [src] to your [limb.plaintext_zone]..."),
				MSG_VISUAL,
				span_notice("You feel [user] start wrapping something around your [limb.plaintext_zone] with expert precision..."),
			)

	else
		user.visible_message(
			span_warning("[user] begins applying [src] to [user == patient ? p_their() : "[patient]'s"] [limb.plaintext_zone]..."),
			span_warning("You begin applying [src] to [user == patient ? "your" : "[patient]'s"] [limb.plaintext_zone]..."),
			visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
			ignored_mobs = patient,
		)
		if(user != patient)
			patient.show_message(
				span_warning("[user] begins applying [src] to your [limb.plaintext_zone]..."),
				MSG_VISUAL,
				span_warning("You feel [user] start wrapping something around your [limb.plaintext_zone]..."),
			)

	if(!do_after(user, 5 SECONDS * speed_multiplier, patient))
		return FALSE

	// pain from tight wrapping
	patient.apply_damage(5, BRUTE, limb, attacking_item = src)
	patient.apply_damage(20, STAMINA, limb, attacking_item = src)
	return TRUE
