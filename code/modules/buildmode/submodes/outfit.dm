/datum/buildmode_mode/outfit
	key = "outfit"
	var/datum/outfit/dressuptime

/datum/buildmode_mode/outfit/Destroy()
	dressuptime = null
	return ..()

/datum/buildmode_mode/outfit/show_help(client/builder)
	to_chat(builder, span_purple(boxed_message(
		"[span_bold("Select outfit to equip")] -> Right Mouse Button on buildmode button\n\
		[span_bold("Equip the selected outfit")] -> Left Mouse Button on mob/living/carbon/human\n\
		[span_bold("Strip and delete current outfit")] -> Right Mouse Button on mob/living/carbon/human"))
	)

/datum/buildmode_mode/outfit/Reset()
	. = ..()
	dressuptime = null

/datum/buildmode_mode/outfit/change_settings(client/c)
	dressuptime = c.robust_dress_shop()

/datum/buildmode_mode/outfit/handle_click(client/c, params, object)
	var/list/modifiers = params2list(params)

	if(!ishuman(object))
		return
	var/mob/living/carbon/human/dollie = object

	if(LAZYACCESS(modifiers, LEFT_CLICK))
		if(isnull(dressuptime))
			to_chat(c, span_warning("Pick an outfit first."))
			return

		for (var/item in dollie.get_equipped_items(INCLUDE_POCKETS))
			qdel(item)
		if(dressuptime != "Naked")
			dollie.equipOutfit(dressuptime)

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		for (var/item in dollie.get_equipped_items(INCLUDE_POCKETS))
			qdel(item)
