
/obj/item/organ/internal/cyberimp
	name = "cybernetic implant"
	desc = "A state-of-the-art implant that improves a baseline's functionality."
	visual = FALSE
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC
	var/implant_color = "#FFFFFF"
	var/implant_overlay
	var/syndicate_implant = FALSE //Makes the implant invisible to health analyzers and medical HUDs.

/obj/item/organ/internal/cyberimp/New(mob/implanted_mob = null)
	if(iscarbon(implanted_mob))
		src.Insert(implanted_mob)
	if(implant_overlay)
		var/mutable_appearance/overlay = mutable_appearance(icon, implant_overlay)
		overlay.color = implant_color
		add_overlay(overlay)
	return ..()

//[[[[BRAIN]]]]

/obj/item/organ/internal/cyberimp/brain
	name = "cybernetic brain implant"
	desc = "Injectors of extra sub-routines for the brain."
	icon_state = "brain_implant"
	implant_overlay = "brain_implant_overlay"
	zone = BODY_ZONE_HEAD
	w_class = WEIGHT_CLASS_TINY

/obj/item/organ/internal/cyberimp/brain/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	var/stun_amount = 200/severity
	owner.Stun(stun_amount)
	to_chat(owner, span_warning("Your body seizes up!"))


/obj/item/organ/internal/cyberimp/brain/anti_drop
	name = "anti-drop implant"
	desc = "This cybernetic brain implant will allow you to force your hand muscles to contract, preventing item dropping. Twitch ear to toggle."
	var/active = FALSE
	var/list/stored_items = list()
	implant_color = "#DE7E00"
	slot = ORGAN_SLOT_BRAIN_ANTIDROP
	actions_types = list(/datum/action/item_action/organ_action/toggle)

/obj/item/organ/internal/cyberimp/brain/anti_drop/ui_action_click()
	active = !active
	if(active)
		var/list/hold_list = owner.get_empty_held_indexes()
		if(LAZYLEN(hold_list) == owner.held_items.len)
			to_chat(owner, span_notice("You are not holding any items, your hands relax..."))
			active = FALSE
			return
		for(var/obj/item/held_item as anything in owner.held_items)
			if(!held_item)
				continue
			stored_items += held_item
			to_chat(owner, span_notice("Your [owner.get_held_index_name(owner.get_held_index_of_item(held_item))]'s grip tightens."))
			ADD_TRAIT(held_item, TRAIT_NODROP, IMPLANT_TRAIT)
			RegisterSignal(held_item, COMSIG_ITEM_DROPPED, PROC_REF(on_held_item_dropped))
	else
		release_items()
		to_chat(owner, span_notice("Your hands relax..."))


/obj/item/organ/internal/cyberimp/brain/anti_drop/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	var/range = severity ? 10 : 5
	var/atom/throw_target
	if(active)
		release_items()
	for(var/obj/item/stored_item as anything in stored_items)
		throw_target = pick(oview(range))
		stored_item.throw_at(throw_target, range, 2)
		to_chat(owner, span_warning("Your [owner.get_held_index_name(owner.get_held_index_of_item(stored_item))] spasms and throws the [stored_item.name]!"))
	stored_items = list()


/obj/item/organ/internal/cyberimp/brain/anti_drop/proc/release_items()
	for(var/obj/item/stored_item as anything in stored_items)
		REMOVE_TRAIT(stored_item, TRAIT_NODROP, IMPLANT_TRAIT)
		UnregisterSignal(stored_item, COMSIG_ITEM_DROPPED)
	stored_items = list()


/obj/item/organ/internal/cyberimp/brain/anti_drop/Remove(mob/living/carbon/implant_owner, special = 0)
	if(active)
		ui_action_click()
	..()

/obj/item/organ/internal/cyberimp/brain/anti_drop/proc/on_held_item_dropped(obj/item/source, mob/user)
	SIGNAL_HANDLER
	REMOVE_TRAIT(source, TRAIT_NODROP, IMPLANT_TRAIT)
	UnregisterSignal(source, COMSIG_ITEM_DROPPED)
	stored_items -= source

/obj/item/organ/internal/cyberimp/brain/anti_stun
	name = "CNS Rebooter implant"
	desc = "This implant will automatically give you back control over your central nervous system, reducing downtime when stunned."
	implant_color = "#FFFF00"
	slot = ORGAN_SLOT_BRAIN_ANTISTUN

	var/static/list/signalCache = list(
		COMSIG_LIVING_STATUS_STUN,
		COMSIG_LIVING_STATUS_KNOCKDOWN,
		COMSIG_LIVING_STATUS_IMMOBILIZE,
		COMSIG_LIVING_STATUS_PARALYZE,
	)

	var/stun_cap_amount = 40

/obj/item/organ/internal/cyberimp/brain/anti_stun/Remove(mob/living/carbon/implant_owner, special = FALSE)
	. = ..()
	UnregisterSignal(implant_owner, signalCache)

/obj/item/organ/internal/cyberimp/brain/anti_stun/Insert(special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	RegisterSignals(owner, signalCache, PROC_REF(on_signal))

/obj/item/organ/internal/cyberimp/brain/anti_stun/proc/on_signal(datum/source, amount)
	SIGNAL_HANDLER
	if(!(organ_flags & ORGAN_FAILING) && amount > 0)
		addtimer(CALLBACK(src, PROC_REF(clear_stuns)), stun_cap_amount, TIMER_UNIQUE|TIMER_OVERRIDE)

/obj/item/organ/internal/cyberimp/brain/anti_stun/proc/clear_stuns()
	if(owner || !(organ_flags & ORGAN_FAILING))
		owner.SetStun(0)
		owner.SetKnockdown(0)
		owner.SetImmobilized(0)
		owner.SetParalyzed(0)

/obj/item/organ/internal/cyberimp/brain/anti_stun/emp_act(severity)
	. = ..()
	if((organ_flags & ORGAN_FAILING) || . & EMP_PROTECT_SELF)
		return
	organ_flags |= ORGAN_FAILING
	addtimer(CALLBACK(src, PROC_REF(reboot)), 90 / severity)

/obj/item/organ/internal/cyberimp/brain/anti_stun/proc/reboot()
	organ_flags &= ~ORGAN_FAILING

//[[[[MOUTH]]]]
/obj/item/organ/internal/cyberimp/mouth
	zone = BODY_ZONE_PRECISE_MOUTH

/obj/item/organ/internal/cyberimp/mouth/breathing_tube
	name = "breathing tube implant"
	desc = "This simple implant adds an internals connector to your back, allowing you to use internals without a mask and protecting you from being choked."
	icon_state = "implant_mask"
	slot = ORGAN_SLOT_BREATHING_TUBE
	w_class = WEIGHT_CLASS_TINY

/obj/item/organ/internal/cyberimp/mouth/breathing_tube/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	if(prob(60/severity))
		to_chat(owner, span_warning("Your breathing tube suddenly closes!"))
		owner.losebreath += 2

/obj/item/organ/internal/cyberimp/muscle
	name = "empovered musculature implant"
	desc = "A cybernetic implant that empowers the strength of a human arm. You shouldn't see it."
	icon_state = "muscle_implant"
	var/pucnh_damage = 13 //The amount of damage dealt by your punches. Not really high, but better then normall punches.

/obj/item/organ/internal/cyberimp/muscle/Insert(mob/living/carbon/reciever, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	if(ishuman(receiver)) //Sorry, only humans
		RegisterSignal(reciever, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, PROC_REF(on_attack_hand))

/obj/item/organ/internal/cyberimp/muscle/Remove(mob/living/carbon/implant_owner, special = 0)
	. = ..()
	UnregisterSignal(implant_owner, COMSIG_HUMAN_EARLY_UNARMED_ATTACK)

/obj/item/organ/internal/cyberimp/proc/on_attack_hand(mob/living/carbon/human/source, atom/target, proximity, modifiers)
	SIGNAL_HANDLER

	if(source.get_active_hand() != source.get_bodypart(zone))
		return
	if(!proximity)
		return
	if(!source.combat_mode || LAZYACCESS(modifiers, RIGHT_CLICK))
		return
	if(isliving(target))
		var/mob/living/living_target = target

		var/picked_hit_type = pick("punch", "smash", "kick")

		source.changeNext_move(CLICK_CD_MELEE)
		if(ishuman(target))
			var/mob/living/carbon/human/human_target = target
			if(human_target.check_shields(source, pucnh_damage, "[source]'s' [picked_hit_type]"))
				source.do_attack_animation(target)
				playsound(living_target.loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
				log_combat(source, target, "attempted to [picked_hit_type]", "muscle implant")
				return COMPONENT_CANCEL_ATTACK_CHAIN

		source.do_attack_animation(target, ATTACK_EFFECT_SMASH)
		playsound(living_target.loc, 'sound/weapons/punch1.ogg', 25, TRUE, -1)

		living_target.apply_damage(pucnh_damage, BRUTE)

		if(source.body_position != LYING_DOWN) //Throw them if we are standing
			var/atom/throw_target = get_edge_target_turf(living_target, source.dir)
			living_target.throw_at(throw_target, 1, rand(1,4), source, gentle = TRUE)

		living_target.visible_message(span_danger("[source] [picked_hit_type]ed [living_target]!"), \
					span_userdanger("You're [picked_hit_type]ed by [source]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, source)
		to_chat(source, span_danger("You [picked_hit_type] [target]!"))

		log_combat(source, target, "[picked_hit_type]ed", "muscle implant")

		return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/item/organ/internal/cyberimp/muscle/left
	name = "empovered left arm implant"
	desc = "A cybernetic implant that empowers the strength of a left human arm."
	zone = BODY_ZONE_PRECISE_L_HAND
	slot = ORGAN_SLOT_LEFT_ARM_AUG

/obj/item/organ/internal/cyberimp/muscle/right
	name = "empovered right arm implant"
	desc = "A cybernetic implant that empowers the strength of a right human arm."
	zone = BODY_ZONE_PRECISE_R_HAND
	slot = ORGAN_SLOT_RIGHT_ARM_AUG

//BOX O' IMPLANTS

/obj/item/storage/box/cyber_implants
	name = "boxed cybernetic implants"
	desc = "A sleek, sturdy box."
	icon_state = "cyber_implants"
	var/list/boxed = list(
		/obj/item/autosurgeon/syndicate/thermal_eyes,
		/obj/item/autosurgeon/syndicate/xray_eyes,
		/obj/item/autosurgeon/syndicate/anti_stun,
		/obj/item/autosurgeon/syndicate/reviver)
	var/amount = 5

/obj/item/storage/box/cyber_implants/PopulateContents()
	var/implant
	while(contents.len <= amount)
		implant = pick(boxed)
		new implant(src)
