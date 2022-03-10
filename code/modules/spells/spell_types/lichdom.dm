/obj/effect/proc_holder/spell/targeted/lichdom
	name = "Bind Soul"
	desc = "A dark necromantic pact that can forever bind your soul to an \
		item of your choosing. So long as your mind and the item remain \
		intact and on the same plane you can revive from death, though the time \
		between reincarnations grows steadily with use, along with the weakness \
		that the new skeleton body will experience upon 'birth'."
	action_icon = 'icons/mob/actions/actions_spells.dmi'
	action_icon_state = "skeleton"
	centcom_cancast = FALSE
	invocation = "NECREM IMORTIUM!"
	invocation_type = INVOCATION_SHOUT
	school = SCHOOL_NECROMANCY
	level_max = 0 //cannot be improved
	range = -1
	charge_max = 10
	cooldown_min = 10
	clothes_req = FALSE
	include_user = TRUE

/obj/effect/proc_holder/spell/targeted/lichdom/cast(list/targets, mob/user = usr)
	for(var/mob/living/caster in targets)

		var/obj/item/marked_item
		for(var/obj/item/item in caster.held_items)
			// I ensouled the nuke disk once. But it's probably a really mean tactic, so probably should discourage it.
			if((item.item_flags & ABSTRACT))
				continue
			if(HAS_TRAIT(item, TRAIT_NODROP))
				continue
			if(SEND_SIGNAL(item, COMSIG_ITEM_IMBUE_SOUL, user) & COMPONENT_BLOCK_IMBUE)
				continue

			marked_item = item
			to_chat(caster, span_green("You begin to focus your very being into [item]..."))
			break

		if(!marked_item)
			to_chat(caster, span_warning("None of the items you hold are suitable for emplacement of your fragile soul."))
			return

		playsound(user, 'sound/effects/pope_entry.ogg', 100)

		if(!do_after(caster, 5 SECONDS, target = marked_item, timed_action_flags = IGNORE_HELD_ITEM))
			to_chat(caster, span_warning("Your soul snaps back to your body as you stop ensouling [marked_item]!"))
			return

		marked_item.AddComponent(/datum/component/phylactery, caster.mind)

		to_chat(caster, span_userdanger("With a hideous feeling of emptiness you watch in horrified fascination as skin sloughs off bone! Blood boils, nerves disintegrate, eyes boil in their sockets! As your organs crumble to dust in your fleshless chest you come to terms with your choice. You're a lich!"))
		caster.set_species(/datum/species/skeleton)
		if(ishuman(caster))
			var/mob/living/carbon/human/human_caster = caster
			human_caster.dropItemToGround(human_caster.w_uniform)
			human_caster.dropItemToGround(human_caster.wear_suit)
			human_caster.dropItemToGround(human_caster.head)
			human_caster.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/black(human_caster), ITEM_SLOT_OCLOTHING)
			human_caster.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/black(human_caster), ITEM_SLOT_HEAD)
			human_caster.equip_to_slot_or_del(new /obj/item/clothing/under/color/black(human_caster), ITEM_SLOT_ICLOTHING)

		// you only get one phylactery.
		caster.mind.RemoveSpell(src)
		ADD_TRAIT(caster, TRAIT_NO_SOUL, LICH_TRAIT)
