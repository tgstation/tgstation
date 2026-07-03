/datum/buildmode_mode/offer
	key = "offer"

/datum/buildmode_mode/offer/show_help(client/builder)
	to_chat(
		builder,
		span_purple(boxed_message("[span_bold("Предложить моба призракам")] -> ЛКМ по мобу"))
	)

/datum/buildmode_mode/offer/handle_click(client/user, params, object)
	if (!ismob(object))
		return

	var/list/modifiers = params2list(params)
	if (!LAZYACCESS(modifiers, LEFT_CLICK))
		return

	if (!check_rights(R_ADMIN))
		return

	offer_control(object)
