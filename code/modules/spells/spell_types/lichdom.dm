/obj/effect/proc_holder/spell/targeted/lichdom
	name = "Bind Soul"
	desc = "A spell that binds your soul to an item in your hands. \
		Binding your soul to an item will turn you into an immortal Lich. \
		So long as the item remains intact, you will revive from death, \
		no matter the circumstances."
	action_icon = 'icons/mob/actions/actions_spells.dmi'
	action_icon_state = "skeleton"
	centcom_cancast = FALSE
	invocation = "NECREM IMORTIUM!"
	invocation_type = INVOCATION_SHOUT
	school = SCHOOL_NECROMANCY
	level_max = 0 // Cannot be improved (yet)
	range = -1
	charge_max = 1 SECONDS
	cooldown_min = 1 SECONDS
	clothes_req = FALSE
	include_user = TRUE

/obj/effect/proc_holder/spell/targeted/lichdom/cast(list/targets, mob/user = usr)
	for(var/mob/living/caster in targets)

		if(HAS_TRAIT(caster, TRAIT_NO_SOUL))
			to_chat(caster, span_warning("You don't have a soul to bind!"))
			return

		var/obj/item/marked_item = caster.get_active_held_item()
		if(marked_item.item_flags & ABSTRACT)
			return
		if(HAS_TRAIT(marked_item, TRAIT_NODROP))
			to_chat(caster, span_warning("[marked_item] is stuck to your hand - it wouldn't be a wise idea to place your soul into it."))
			return
		// I ensouled the nuke disk once.
		// But it's a really mean tactic,
		// so we probably should disallow it.
		if(SEND_SIGNAL(marked_item, COMSIG_ITEM_IMBUE_SOUL, user) & COMPONENT_BLOCK_IMBUE)
			to_chat(caster, span_warning("[marked_item] is not suitable for emplacement of your fragile soul."))
			return

		playsound(user, 'sound/effects/pope_entry.ogg', 100)

		to_chat(caster, span_green("You begin to focus your very being into [marked_item]..."))
		if(!do_after(caster, 5 SECONDS, target = marked_item, timed_action_flags = IGNORE_HELD_ITEM))
			to_chat(caster, span_warning("Your soul snaps back to your body as you stop ensouling [marked_item]!"))
			return

		marked_item.AddComponent(/datum/component/phylactery, caster.mind)

		caster.set_species(/datum/species/skeleton)
		to_chat(caster, span_userdanger("With a hideous feeling of emptiness you watch in horrified fascination \
			as skin sloughs off bone! Blood boils, nerves disintegrate, eyes boil in their sockets! \
			As your organs crumble to dust in your fleshless chest you come to terms with your choice. \
			You're a lich!"))

		if(iscarbon(caster))
			var/mob/living/carbon/carbon_caster = caster
			var/obj/item/organ/internal/brain/lich_brain = carbon_caster.getorganslot(ORGAN_SLOT_BRAIN)
			if(lich_brain) // This prevents MMIs being used to stop lich revives
				lich_brain.organ_flags &= ~ORGAN_VITAL
				lich_brain.decoy_override = TRUE

		if(ishuman(caster))
			var/mob/living/carbon/human/human_caster = caster
			human_caster.dropItemToGround(human_caster.w_uniform)
			human_caster.dropItemToGround(human_caster.wear_suit)
			human_caster.dropItemToGround(human_caster.head)
			human_caster.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/black(human_caster), ITEM_SLOT_OCLOTHING)
			human_caster.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/black(human_caster), ITEM_SLOT_HEAD)
			human_caster.equip_to_slot_or_del(new /obj/item/clothing/under/color/black(human_caster), ITEM_SLOT_ICLOTHING)

		// You only get one phylactery.
		caster.mind.RemoveSpell(src)
		// And no soul. You just sold it
		ADD_TRAIT(caster, TRAIT_NO_SOUL, LICH_TRAIT)
