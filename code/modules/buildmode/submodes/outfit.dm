/datum/buildmode_mode/outfit
	key = "outfit"
	var/datum/outfit/dressuptime

/datum/buildmode_mode/outfit/Destroy()
	dressuptime = null
	return ..()

/datum/buildmode_mode/outfit/show_help(client/c)
	to_chat(c, "<span class='notice'>***********************************************************</span>")
	to_chat(c, "<span class='notice'>Right Mouse Button on buildmode button = Select outfit to equip.</span>")
	to_chat(c, "<span class='notice'>Left Mouse Button on mob/living/carbon/human = Equip the selected outfit.</span>")
	to_chat(c, "<span class='notice'>Right Mouse Button on mob/living/carbon/human = Strip and delete current outfit.</span>")
	to_chat(c, "<span class='notice'>***********************************************************</span>")

/datum/buildmode_mode/outfit/Reset()
	. = ..()
	dressuptime = null

/datum/buildmode_mode/outfit/change_settings(client/c)
	dressuptime = c.robust_dress_shop()

/datum/buildmode_mode/outfit/handle_click(client/c, params, object)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/right_click = pa.Find("right")

	if(!ishuman(object))
		return
	var/mob/living/carbon/human/dollie = object

	if(left_click)
		if(isnull(dressuptime))
			to_chat(c, "<span class='warning'>Pick an outfit first.</span>")
			return

		for (var/obj/item/I in dollie.get_equipped_items(TRUE))
			qdel(I)
		if(dressuptime != "Naked")
			dollie.equipOutfit(dressuptime)

	if(right_click)
		for (var/obj/item/I in dollie.get_equipped_items(TRUE))
			qdel(I)
