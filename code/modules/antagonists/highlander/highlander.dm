/datum/antagonist/highlander
	name = "\improper Highlander"
	var/obj/item/claymore/highlander/sword
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	can_elimination_hijack = ELIMINATION_ENABLED
	suicide_cry = "FOR SCOTLAND!!" // If they manage to lose their no-drop stuff somehow
	count_against_dynamic_roll_chance = FALSE
	/// Traits we apply/remove to our target on-demand.
	var/static/list/applicable_traits = list(
		TRAIT_NOBREATH,
		TRAIT_NODISMEMBER,
		TRAIT_NOFIRE,
		TRAIT_NOGUNS,
		TRAIT_TOSS_GUN_HARD,
		TRAIT_SHOCKIMMUNE,
	)

/datum/antagonist/highlander/apply_innate_effects(mob/living/mob_override)
	var/mob/living/subject = owner.current || mob_override
	subject.add_traits(applicable_traits, HIGHLANDER_TRAIT)
	REMOVE_TRAIT(subject, TRAIT_PACIFISM, ROUNDSTART_TRAIT)

/datum/antagonist/highlander/remove_innate_effects(mob/living/mob_override)
	var/mob/living/subject = owner.current || mob_override
	subject.remove_traits(applicable_traits, HIGHLANDER_TRAIT)
	if(subject.has_quirk(/datum/quirk/nonviolent))
		ADD_TRAIT(subject, TRAIT_PACIFISM, ROUNDSTART_TRAIT)

/datum/antagonist/highlander/forge_objectives()
	var/datum/objective/steal/steal_objective = new
	steal_objective.owner = owner
	steal_objective.set_target(new /datum/objective_item/steal/nukedisc)
	objectives += steal_objective
	var/datum/objective/elimination/highlander/elimination_objective = new
	elimination_objective.owner = owner
	objectives += elimination_objective

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

	H.drop_everything(del_on_drop = FALSE, force = TRUE, del_if_nodrop = TRUE)

	H.regenerate_icons()
	H.revive(ADMIN_HEAL_ALL)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/costume/kilt/highlander(H), ITEM_SLOT_ICLOTHING)
	H.equip_to_slot_or_del(new /obj/item/radio/headset/syndicate(H), ITEM_SLOT_EARS)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/beret/highlander(H), ITEM_SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(H), ITEM_SLOT_FEET)
	H.equip_to_slot_or_del(new /obj/item/pinpointer/nuke(H), ITEM_SLOT_LPOCKET)
	for(var/obj/item/pinpointer/nuke/P in H)
		P.attack_self(H)
	var/obj/item/card/id/advanced/highlander/W = new(H)
	W.registered_name = H.real_name
	ADD_TRAIT(W, TRAIT_NODROP, HIGHLANDER_TRAIT)
	W.update_label()
	W.update_icon()
	H.equip_to_slot_or_del(W, ITEM_SLOT_ID)

	sword = new(H)
	if(!GLOB.highlander_controller)
		sword.flags_1 |= ADMIN_SPAWNED_1 //To prevent announcing
	sword.pickup(H) //For the stun shielding
	H.put_in_hands(sword)


	var/obj/item/bloodcrawl/antiwelder = new(H)
	antiwelder.name = "compulsion of honor"
	antiwelder.desc = "You are unable to hold anything in this hand until you're the last one left!"
	antiwelder.icon_state = "bloodhand_right"
	H.put_in_hands(antiwelder)

/datum/antagonist/highlander/robot
	name = "\improper highlander"

/datum/antagonist/highlander/robot/greet()
	to_chat(owner, "<span class='boldannounce'>Your integrated claymore cries out for blood. Claim the lives of others, and your own will be restored!\n\
	Activate it in your hand, and it will lead to the nearest target. Attack the nuclear authentication disk with it, and you will store it.</span>")

/datum/antagonist/highlander/robot/give_equipment()
	var/mob/living/silicon/robot/robotlander = owner.current
	if(!istype(robotlander))
		return ..()
	robotlander.revive(ADMIN_HEAL_ALL)
	robotlander.set_connected_ai() //DISCONNECT FROM AI
	robotlander.laws.clear_inherent_laws()
	robotlander.laws.set_zeroth_law("THERE CAN BE ONLY ONE")
	robotlander.laws.show_laws(robotlander)
	robotlander.model.transform_to(/obj/item/robot_model/syndicate/kiltborg)
	sword = locate(/obj/item/claymore/highlander/robot) in robotlander.model.basic_modules
