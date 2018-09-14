/datum/antagonist/highlander
	name = "highlander"
	var/obj/item/claymore/highlander/sword
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	can_hijack = HIJACK_HIJACKER

/datum/antagonist/highlander/apply_innate_effects(mob/living/mob_override)
	var/mob/living/L = owner.current || mob_override
	L.add_trait(TRAIT_NOGUNS, "highlander")

/datum/antagonist/highlander/remove_innate_effects(mob/living/mob_override)
	var/mob/living/L = owner.current || mob_override
	L.remove_trait(TRAIT_NOGUNS, "highlander")

/datum/antagonist/highlander/proc/forge_objectives()
	var/datum/objective/steal/steal_objective = new
	steal_objective.owner = owner
	steal_objective.set_target(new /datum/objective_item/steal/nukedisc)
	objectives += steal_objective

	var/datum/objective/hijack/hijack_objective = new
	hijack_objective.explanation_text = "Escape on the shuttle alone. Ensure that nobody else makes it out."
	hijack_objective.owner = owner
	objectives += hijack_objective

	owner.objectives |= objectives

/datum/antagonist/highlander/on_gain()
	forge_objectives()
	owner.special_role = "highlander"
	give_equipment()
	. = ..()

/datum/antagonist/highlander/greet()
	to_chat(owner, "<span class='boldannounce'>Your [sword.name] cries out for blood. Claim the lives of others, and your own will be restored!\n\
	Activate it in your hand, and it will lead to the nearest target. Attack the nuclear authentication disk with it, and you will store it.</span>")

	owner.announce_objectives()

/datum/antagonist/highlander/proc/give_equipment()
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return

	for(var/obj/item/I in H.get_equipped_items(TRUE))
		qdel(I)
	for(var/obj/item/I in H.held_items)
		qdel(I)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/kilt/highlander(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/radio/headset/heads/captain(H), SLOT_EARS)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/beret/highlander(H), SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/pinpointer/nuke(H), SLOT_L_STORE)
	for(var/obj/item/pinpointer/nuke/P in H)
		P.attack_self(H)
	var/obj/item/card/id/W = new(H)
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	W.access += get_all_centcom_access()
	W.assignment = "Highlander"
	W.registered_name = H.real_name
	W.item_flags |= NODROP
	W.update_label(H.real_name)
	H.equip_to_slot_or_del(W, SLOT_WEAR_ID)

	sword = new(H)
	if(!GLOB.highlander)
		sword.flags_1 |= ADMIN_SPAWNED_1 //To prevent announcing
	sword.pickup(H) //For the stun shielding
	H.put_in_hands(sword)


	var/obj/item/bloodcrawl/antiwelder = new(H)
	antiwelder.name = "compulsion of honor"
	antiwelder.desc = "You are unable to hold anything in this hand until you're the last one left!"
	antiwelder.icon_state = "bloodhand_right"
	H.put_in_hands(antiwelder)