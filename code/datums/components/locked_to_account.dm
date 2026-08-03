
#define DENY_SOUND_COOLDOWN (2 SECONDS)

/datum/component/locked_to_account
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/datum/bank_account/buyer_account
	var/datum/bank_account/department/department_account
	COOLDOWN_DECLARE(deny_cooldown)

/datum/component/locked_to_account/Initialize(datum/bank_account/buyer_account, datum/bank_account/department/department_account)
	. = ..()
	if(!istype(parent, /obj/structure/closet))
		return COMPONENT_INCOMPATIBLE
	src.buyer_account = buyer_account
	src.department_account = department_account

/datum/component/locked_to_account/InheritComponent(datum/component/locked_to_account/new_comp, i_am_original, datum/bank_account/buyer_account, datum/bank_account/department/department_account)
	src.buyer_account = buyer_account
	src.department_account = department_account

/datum/component/locked_to_account/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ATOM_EMAG_ACT, PROC_REF(on_emag))
	RegisterSignal(parent, COMSIG_CLOSET_PRE_OPEN, PROC_REF(on_pre_open))

/datum/component/locked_to_account/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_EXAMINE,
		COMSIG_ATOM_EMAG_ACT,
		COMSIG_CLOSET_PRE_OPEN,
	))

/datum/component/locked_to_account/proc/on_examine(obj/structure/closet/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_warning("An account lock prevents this from opening except by the purchasing account holder.")

/datum/component/locked_to_account/proc/on_pre_open(obj/structure/closet/source, mob/living/user, force)
	SIGNAL_HANDLER
	if(force)
		return

	if(!user)
		return BLOCK_OPEN

	var/obj/item/card/id/id_card = user.get_idcard(TRUE)
	if(!id_card)
		deny(source, user, "No ID detected!")
		return BLOCK_OPEN

	if(!id_card.registered_account)
		deny(source, user, "No linked bank account detected!")
		return BLOCK_OPEN

	var/account_matches = (id_card.registered_account == buyer_account) || \
		(department_account && id_card.registered_account?.account_job?.paycheck_department == department_account.department_id)

	if(!account_matches)
		deny(source, user, "Bank account does not match with buyer!")
		return BLOCK_OPEN

	if(iscarbon(user))
		source.add_fingerprint(user)
	remove_lock(source, user)

/datum/component/locked_to_account/proc/deny(obj/structure/closet/source, mob/living/user, message)
	to_chat(user, span_warning(message))
	if(COOLDOWN_FINISHED(src, deny_cooldown))
		playsound(source, 'sound/machines/buzz/buzz-two.ogg', 30, TRUE)
		COOLDOWN_START(src, deny_cooldown, DENY_SOUND_COOLDOWN)

/datum/component/locked_to_account/proc/on_emag(obj/structure/closet/source, mob/emagger)
	SIGNAL_HANDLER
	emagger.balloon_alert(emagger, "account lock bypassed")
	remove_lock(source, emagger)

/datum/component/locked_to_account/proc/remove_lock(obj/structure/closet/source, mob/user)
	source.visible_message(span_notice("[source]'s account lock disengages with a soft click."))
	if(user)
		to_chat(user, span_notice("You unlock [source]."))
	source.update_appearance()
	qdel(src)

#undef DENY_SOUND_COOLDOWN
