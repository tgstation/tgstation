
/obj/item/organ/cyberimp
	name = "cybernetic implant"
	desc = "A state-of-the-art implant that improves a baseline's functionality."
	status = ORGAN_ROBOTIC
	var/implant_color = "#FFFFFF"
	var/implant_overlay
	var/syndicate_implant = FALSE //Makes the implant invisible to health analyzers and medical HUDs.

/obj/item/organ/cyberimp/New(var/mob/M = null)
	if(iscarbon(M))
		src.Insert(M)
	if(implant_overlay)
		var/mutable_appearance/overlay = mutable_appearance(icon, implant_overlay)
		overlay.color = implant_color
		add_overlay(overlay)
	return ..()



//[[[[BRAIN]]]]

/obj/item/organ/cyberimp/brain
	name = "cybernetic brain implant"
	desc = "Injectors of extra sub-routines for the brain."
	icon_state = "brain_implant"
	implant_overlay = "brain_implant_overlay"
	zone = BODY_ZONE_HEAD
	w_class = WEIGHT_CLASS_TINY

/obj/item/organ/cyberimp/brain/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	var/stun_amount = 200/severity
	owner.Stun(stun_amount)
	to_chat(owner, "<span class='warning'>Your body seizes up!</span>")


/obj/item/organ/cyberimp/brain/anti_drop
	name = "anti-drop implant"
	desc = "This cybernetic brain implant will allow you to force your hand muscles to contract, preventing item dropping. Twitch ear to toggle."
	var/active = 0
	var/list/stored_items = list()
	implant_color = "#DE7E00"
	slot = ORGAN_SLOT_BRAIN_ANTIDROP
	actions_types = list(/datum/action/item_action/organ_action/toggle)

/obj/item/organ/cyberimp/brain/anti_drop/ui_action_click()
	active = !active
	if(active)
		for(var/obj/item/I in owner.held_items)
			if(!(I.item_flags & NODROP))
				stored_items += I

		var/list/L = owner.get_empty_held_indexes()
		if(LAZYLEN(L) == owner.held_items.len)
			to_chat(owner, "<span class='notice'>You are not holding any items, your hands relax...</span>")
			active = 0
			stored_items = list()
		else
			for(var/obj/item/I in stored_items)
				to_chat(owner, "<span class='notice'>Your [owner.get_held_index_name(owner.get_held_index_of_item(I))]'s grip tightens.</span>")
				I.item_flags |= NODROP

	else
		release_items()
		to_chat(owner, "<span class='notice'>Your hands relax...</span>")


/obj/item/organ/cyberimp/brain/anti_drop/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	var/range = severity ? 10 : 5
	var/atom/A
	if(active)
		release_items()
	for(var/obj/item/I in stored_items)
		A = pick(oview(range))
		I.throw_at(A, range, 2)
		to_chat(owner, "<span class='warning'>Your [owner.get_held_index_name(owner.get_held_index_of_item(I))] spasms and throws the [I.name]!</span>")
	stored_items = list()


/obj/item/organ/cyberimp/brain/anti_drop/proc/release_items()
	for(var/obj/item/I in stored_items)
		I.item_flags &= ~NODROP
	stored_items = list()


/obj/item/organ/cyberimp/brain/anti_drop/Remove(var/mob/living/carbon/M, special = 0)
	if(active)
		ui_action_click()
	..()

/obj/item/organ/cyberimp/brain/anti_stun
	name = "CNS Rebooter implant"
	desc = "This implant will automatically give you back control over your central nervous system, reducing downtime when stunned."
	implant_color = "#FFFF00"
	slot = ORGAN_SLOT_BRAIN_ANTISTUN
	var/datum/component/redirect/listener
	var/datum/callback/CB
	var/stun_cap_amount = 40
	var/working = FALSE

/obj/item/organ/cyberimp/brain/anti_stun/Initialize()
	. = ..()
	initialize_callback()

/obj/item/organ/cyberimp/brain/anti_stun/proc/initialize_callback()
	if(CB)
		return
	CB = CALLBACK(src, .proc/on_signal)

/obj/item/organ/cyberimp/brain/anti_stun/Remove()
	. = ..()
	QDEL_NULL(listener)

/obj/item/organ/cyberimp/brain/anti_stun/Insert()
	. = ..()
	if(listener)
		qdel(listener)
	listener = owner.AddComponent(/datum/component/redirect, list(
	COMSIG_LIVING_STATUS_STUN = CB,
	COMSIG_LIVING_STATUS_KNOCKDOWN = CB,
	COMSIG_LIVING_STATUS_IMMOBILIZE = CB,
	COMSIG_LIVING_STATUS_PARALYZE = CB
	))

/obj/item/organ/cyberimp/brain/anti_stun/proc/on_signal()
	if(crit_fail || working)
		return
	working = TRUE
	if(owner.AmountStun() > stun_cap_amount)
		owner.SetStun(stun_cap_amount)
	if(owner.AmountKnockdown() > stun_cap_amount)
		owner.SetKnockdown(stun_cap_amount)
	if(owner.AmountImmobilized() > stun_cap_amount)
		owner.SetImmobilized(stun_cap_amount)
	if(owner.AmountParalyzed() > stun_cap_amount)
		owner.SetParalyzed(stun_cap_amount)
	working = FALSE

/obj/item/organ/cyberimp/brain/anti_stun/emp_act(severity)
	. = ..()
	if(crit_fail || . & EMP_PROTECT_SELF)
		return
	crit_fail = TRUE
	addtimer(CALLBACK(src, .proc/reboot), 90 / severity)

/obj/item/organ/cyberimp/brain/anti_stun/proc/reboot()
	crit_fail = FALSE

//[[[[MOUTH]]]]
/obj/item/organ/cyberimp/mouth
	zone = BODY_ZONE_PRECISE_MOUTH

/obj/item/organ/cyberimp/mouth/breathing_tube
	name = "breathing tube implant"
	desc = "This simple implant adds an internals connector to your back, allowing you to use internals without a mask and protecting you from being choked."
	icon_state = "implant_mask"
	slot = ORGAN_SLOT_BREATHING_TUBE
	w_class = WEIGHT_CLASS_TINY

/obj/item/organ/cyberimp/mouth/breathing_tube/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	if(prob(60/severity))
		to_chat(owner, "<span class='warning'>Your breathing tube suddenly closes!</span>")
		owner.losebreath += 2

//BOX O' IMPLANTS

/obj/item/storage/box/cyber_implants
	name = "boxed cybernetic implants"
	desc = "A sleek, sturdy box."
	icon_state = "cyber_implants"
	var/list/boxed = list(
		/obj/item/autosurgeon/thermal_eyes,
		/obj/item/autosurgeon/xray_eyes,
		/obj/item/autosurgeon/anti_stun,
		/obj/item/autosurgeon/reviver)
	var/amount = 5

/obj/item/storage/box/cyber_implants/PopulateContents()
	var/implant
	while(contents.len <= amount)
		implant = pick(boxed)
		new implant(src)
