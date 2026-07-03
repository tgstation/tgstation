/datum/action/cooldown/spell/pointed/burglar_finesse
	name = "Ловкость грабителя"
	desc = "Крадет случайны предмет из сумки жертвы."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "burglarsfinesse"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 40 SECONDS

	invocation = "Y'O'K!"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cast_range = 6

/datum/action/cooldown/spell/pointed/burglar_finesse/is_valid_target(mob/living/carbon/human/cast_on)
	if(!istype(cast_on))
		return FALSE
	var/obj/item/back_item = cast_on.get_item_by_slot(ITEM_SLOT_BACK)
	return ..() && back_item?.atom_storage

/datum/action/cooldown/spell/pointed/burglar_finesse/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_danger("Вы чувствуете легкое потягивание, но в остальном все в порядке, вы были защищены святыми силами!"))
		to_chat(owner, span_danger("[capitalize(cast_on.declent_ru(NOMINATIVE))] под защитой святой силы!"))
		return FALSE

	var/obj/storage_item = cast_on.get_item_by_slot(ITEM_SLOT_BACK)

	if(isnull(storage_item))
		return FALSE

	var/obj/item = pick(storage_item.atom_storage.return_inv(recursive = FALSE)) // TODO220 - Type it to upstream
	if(isnull(item))
		return FALSE

	to_chat(cast_on, span_warning("Ваш [storage_item.declent_ru(NOMINATIVE)] чувствуется легче..."))
	to_chat(owner, span_notice("Одним мгновением, вы вытягиваете [item.declent_ru(ACCUSATIVE)] из [storage_item.declent_ru(GENITIVE)] у [cast_on.declent_ru(GENITIVE)]."))
	owner.put_in_active_hand(item)
