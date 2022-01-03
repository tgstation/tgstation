/obj/item/scissors
	name = "scissors"
	desc = "A pair of sharp scissors."
	icon = 'icons/obj/barber_and_tailor.dmi'
	icon_state = "scissors"
	var/mob/living/carbon/human/haircut_target
	var/mob/living/carbon/human/dummy
	var/atom/movable/screen/dummy_screen

/obj/item/scissors/ui_close(mob/user)
	user.client.clear_map(dummy_screen.assigned_map)
	qdel(dummy)
	qdel(dummy_screen)

/obj/item/scissors/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		user.client.register_map_obj(dummy_screen)
		ui = new(user, src, "BarberPanel")
		ui.open()

/obj/item/scissors/ui_data(mob/user)
	var/list/data = list()
	data["hairstyles"] = GLOB.hairstyles_list
	data["selected_hairstyle"] = haircut_target.hairstyle
	data["facial_hairstyles"] = GLOB.facial_hairstyles_list
	data["selected_facial_hairstyle"] = haircut_target.facial_hairstyle
	data["assigned_map"] = dummy_screen.assigned_map
	return data

/obj/item/scissors/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("select_hair")
			var/hairstyle = params["name"]
			haircut_target.hairstyle = hairstyle
			dummy.hairstyle = hairstyle
			haircut_target.update_hair()
			dummy.update_hair()
			haircut_target.dna.update_dna_identity()
			playsound(haircut_target, 'sound/items/scissors.ogg', 100)
			. = TRUE
		if("select_beard")
			var/hairstyle = params["name"]
			haircut_target.facial_hairstyle = hairstyle
			dummy.facial_hairstyle = hairstyle
			haircut_target.update_hair()
			dummy.update_hair()
			haircut_target.dna.update_dna_identity()
			playsound(haircut_target, 'sound/items/scissors.ogg', 100)
			. = TRUE

/obj/item/scissors/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	if(target == user)
		to_chat(user, "You can't use scissors on yourself. You'll make your hair look terrible!")
		return
	if(ishuman(target))
		haircut_target = target
		dummy = generate_dummy_lookalike(REF(haircut_target), haircut_target)
		haircut_target?.client?.prefs?.safe_transfer_prefs_to(dummy)
		dummy.dna.update_dna_identity()
		dummy_screen = new
		dummy_screen.vis_contents += dummy
		dummy_screen.name = "screen"
		dummy_screen.assigned_map = "haircut_[REF(src)]_map"
		dummy_screen.del_on_map_removal = FALSE
		dummy_screen.screen_loc = "[dummy_screen.assigned_map]:1,1"
		ui_interact(user)
		return
