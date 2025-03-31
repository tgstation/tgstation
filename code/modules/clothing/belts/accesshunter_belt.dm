/obj/item/access_hunter
	name = "access hunter"
	desc = "Found in an archeological digsite in Space New Zealand, this highly sought after belt grants \
	the wearer strange unknown mystical powers unknown to anyone..."
	slot_flags = ITEM_SLOT_BELT
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "access_hunter"
	worn_icon_state = "access_hunter"
	base_icon_state = "access_hunter"
	var/list/stolen_id_cards

/obj/item/access_hunter/examine(mob/user)
	. = ..()
	. += span_notice("A note drawn in orange, blue, and gray crayon is attached to the belt. It reads...")
	. += span_notice("<font style='color: #af6025; font-family: FontinSmallCaps, Verdana, Arial, Helvetica, sans-serif;'>Access Hunter Belt (for the captain's eyes only!)</font>")
	. += span_notice("<font style='color: #8888ff; font-family: FontinSmallCaps, Verdana, Arial, Helvetica, sans-serif;'>When wearing an ID card, recently struck crewmembers have one of their access levels on their ID card, if any, stolen on death.")
	. += span_notice("<font style='color: #7f7f7f; font-family: FontinSmallCaps, Verdana, Arial, Helvetica, sans-serif;'>Struck refers to being hit with an object or your fists, not guns. Recently refers to the past 4 seconds. Don't you dare ask about &quot;nearby&quot;.</font>")
	. += span_notice("This belt has stolen the access from <b>[length(stolen_id_cards)]</b> different crewmembers.")

/obj/item/access_hunter/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_BELT && ishuman(user))
		RegisterSignal(user, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_attack_hand))
		RegisterSignal(user, COMSIG_MOB_ITEM_ATTACK, PROC_REF(on_attack_item))

/obj/item/access_hunter/dropped(mob/user, silent)
	. = ..()
	UnregisterSignal(user, list(COMSIG_LIVING_UNARMED_ATTACK,COMSIG_MOB_ITEM_ATTACK))

/obj/item/access_hunter/Destroy()
	. = ..()
	stolen_id_cards?.Cut()

/obj/item/access_hunter/proc/on_attack_hand(mob/living/source, atom/target, proximity, modifiers)

	SIGNAL_HANDLER

	if(!proximity || !source.combat_mode || !ishuman(target)) //Check if it's actually a punch.
		return

	apply_status_to(target)

/obj/item/access_hunter/proc/on_attack_item(mob/user, mob/target)

	SIGNAL_HANDLER

	if(!ishuman(target))
		return

	apply_status_to(target)


/obj/item/access_hunter/proc/apply_status_to(mob/living/carbon/human/target)

	if(target.stat & DEAD) //Already dead. Nani.
		return

	var/datum/status_effect/accesshunter/applied_status_effect = target.apply_status_effect(/datum/status_effect/accesshunter)
	if(applied_status_effect)
		applied_status_effect.linked_belt = WEAKREF(src)

/obj/item/access_hunter/proc/steal_access(mob/living/carbon/human/target)

	var/mob/living/carbon/human/source = loc
	if(!ishuman(source))
		return

	var/obj/item/card/id/source_id_card = source.wear_id?.GetID()
	if(!source_id_card)
		return

	var/obj/item/card/id/target_id_card = target.wear_id?.GetID()
	if(!target_id_card || !target_id_card.registered_name)
		return

	var/datum/weakref/target_id_card_ref = WEAKREF(target_id_card)
	if(length(stolen_id_cards) && stolen_id_cards[target_id_card_ref])
		return

	var/list/access_difference = target_id_card.access - source_id_card.access
	if(!length(access_difference))
		return

	var/list/stolen_access = list(pick(access_difference))
	source_id_card.add_access(stolen_access,mode = FORCE_ADD_ALL)
	target_id_card.remove_access(stolen_access)

	if(!stolen_id_cards)
		stolen_id_cards = list()
	stolen_id_cards[target_id_card_ref] = TRUE

	playsound(source, 'sound/items/access_hunter_steal.ogg', 50, TRUE, -1) //Feedback

	return
