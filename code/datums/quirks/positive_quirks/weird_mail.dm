/datum/quirk/weird_mail
	name = "Eccentric Correspondent"
	desc = "A friend or family is known to send you some exceptionally unusual mail."
	value = 2
	icon = FA_ICON_ENVELOPE
	mail_weight = 50
	medical_record_text = ""
	/// Completely random stuff to add to their mail pool with high unpredictability
	var/static/list/random_mail_items = list(
		/obj/item/assembly/relic/lavaland/revealed, // immediately usable
		/obj/item/assembly/relic/revealed, // ditto
		/obj/item/chainsaw,
		/obj/item/gibtonite, // does not immediately explode, but can
		/obj/item/melee/baton/security/cattleprod/loaded, // functioning stunprod
		/obj/item/pickaxe/mini,
		/obj/item/spess_knife, // full toolset
		/obj/item/switchblade, // decent weapon
		/obj/item/tome, // useless, but cool
	)
	/// Completely random stuff to add to their mail pool, but generally safer / less likely to cause trouble
	var/static/list/limited_mail_items = list(
		/obj/item/banhammer,
		/obj/item/bikehorn/airhorn,
		/obj/item/boxcutter,
		/obj/item/clothing/neck/petcollar/wearable,
		/obj/item/disk/nuclear/fake, // useless but funny
		/obj/item/feather,
		/obj/item/flashlight/lantern/jade,
		/obj/item/gift, // not the christmas gift. fooled you!
		/obj/item/gun/ballistic/revolver/russian,
		/obj/item/newspaper,
		/obj/item/pen/fountain,
		/obj/item/phone, // entirely useless
		/obj/item/ship_in_a_bottle, // almost entirely useless
		/obj/item/stack/ore/diamond,
		/obj/item/stack/ore/uranium,
		/obj/item/stack/sheet/bluespace_crystal, // little bit of shenanigan potential, but one use
		/obj/item/stock_parts/power_store/cell,
		/obj/item/table_clock,
		/obj/item/throwing_star, // one use
		/obj/item/tourniquet,
		/obj/item/transfer_valve, // not dangerous without components
	)

/datum/quirk/weird_mail/add(client/client_source)
	RegisterSignal(quirk_holder, COMSIG_MOB_MIND_SET_ROLE, PROC_REF(update_mail))
	update_mail()

/datum/quirk/weird_mail/remove()
	UnregisterSignal(quirk_holder, COMSIG_MOB_MIND_SET_ROLE)

/datum/quirk/weird_mail/proc/update_mail(...)
	SIGNAL_HANDLER

	LAZYCLEARLIST(mail_goodies)
	LAZYOR(mail_goodies, limited_mail_items)
	if(quirk_holder.mind?.assigned_role.exclusive_mail_goodies)
		return
	LAZYOR(mail_goodies, random_mail_items)
	for(var/datum/job/other_job as anything in SSjob.joinable_occupations)
		if(other_job == quirk_holder.mind?.assigned_role || other_job.exclusive_mail_goodies)
			continue
		LAZYOR(mail_goodies, assoc_to_keys(other_job.mail_goodies))
