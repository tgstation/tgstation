//Kitchenbot
/mob/living/simple_animal/bot/kitchenbot
	name = "\improper Kitchenbot"
	desc = "Not everyone can become a great artist, but a great artist can come from anywhere. \
	It is difficult to imagine more humble origins than those of the genius now cooking at Nanotrasen's, \
	who is, in this critic's opinion, nothing less than the finest chef in Spinward Sector. \
	I will be returning to Nanotrasen's soon, hungry for more."
	icon = 'icons/mob/aibots.dmi'
	icon_state = "kitchenbot"
	density = FALSE
	anchored = FALSE
	health = 100
	maxHealth = 100
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE //Service
	///Override so it uses datum ai
	can_have_ai = FALSE
	AIStatus = AI_OFF
	//...And use this instead!
	ai_controller = /datum/ai_controller/kitchenbot
	bot_type = KITCHEN_BOT
	model = "Kitchenbot"
	bot_core_type = /obj/machinery/bot_core/kitchenbot
	window_id = "autoclean"
	window_name = "Super Kitchenbot 9001"
	pass_flags = PASSMOB | PASSFLAPS | PASSTABLE | PASSMACHINE
	path_image_color = "#fff5bc"
	allow_pai = FALSE
	layer = ABOVE_MOB_LAYER
	auto_patrol = FALSE

/mob/living/simple_animal/bot/kitchenbot/Initialize()
	. = ..()
	update_appearance(UPDATE_ICON)

	// Doing this hurts my soul, but simplebot access reworks are for another day.
	var/datum/id_trim/job/jani_trim = SSid_access.trim_singletons_by_path[/datum/id_trim/job/janitor]
	access_card.add_access(jani_trim.access + jani_trim.wildcard_access)
	prev_access = access_card.access.Copy()

/mob/living/simple_animal/bot/kitchenbot/explode()
	walk_to(src,0)
	visible_message("<span class='boldannounce'>[src] blows apart, plates clattering to the ground!</span>")
	do_sparks(3, TRUE, src)
	on = FALSE
	new /obj/item/trash/plate(loc)
	new /obj/item/trash/plate(loc)
	..()

/mob/living/simple_animal/bot/kitchenbot/update_icon_state()
	. = ..()
	var/mode = ai_controller.blackboard[BB_KITCHENBOT_MODE]

	var/list/mode2iconsuffix = list(
		KITCHENBOT_MODE_IDLE = 1,
		KITCHENBOT_MODE_REFUSE = 2,
		KITCHENBOT_MODE_THE_GRIDDLER = 3,
		KITCHENBOT_MODE_WAITER = 4
	)
	if(on)
		icon_state = "[initial(icon_state)][mode2iconsuffix[mode]]"
	else
		icon_state = "[initial(icon_state)]0"

/mob/living/simple_animal/bot/kitchenbot/hack(mob/user)
	var/hack
	if(issilicon(user) || isAdminGhostAI(user)) //Allows silicons or admins to toggle the emag status of a bot.
		hack += "[emagged == 2 ? "Software compromised! Unit may exhibit dangerous or erratic behavior." : "Unit operating normally. Release safety lock?"]<BR>"
		hack += "Harm Prevention Safety System: <A href='?src=[REF(src)];operation=hack'>[emagged ? "<span class='bad'>DANGER</span>" : "Engaged"]</A><BR>"
	else if(!locked) //Humans with access can use this option to hide a bot from the AI's remote control panel and PDA control.
		hack += "Remote network control radio: <A href='?src=[REF(src)];operation=remote'>[remote_disabled ? "Disconnected" : "Connected"]</A><BR>"
	return hack

/mob/living/simple_animal/bot/kitchenbot/get_controls(mob/user)
	var/dat
	dat += hack(user)
	dat += text({"
Status: <A href='?src=[REF(src)];power=1'>[on ? "On" : "Off"]</A><BR>
Behaviour controls are [locked ? "locked" : "unlocked"]<BR>
Maintenance panel panel is [open ? "opened" : "closed"]"})
	if(!on)
		return dat
	var/mode = ai_controller.blackboard[BB_KITCHENBOT_MODE]
	dat += "<BR>Kitchenbot Mode:"
	if(!locked || issilicon(user)|| isAdminGhostAI(user))
		dat += "<BR>Idle Mode (Nothing. Kitchen Mascot?): [mode == KITCHENBOT_MODE_IDLE ? "<b>Selected</b>" : "<A href='?src=[REF(src)];operation=idle'>Select</A>"]"
		dat += "<BR>Cleanup Dishes and Clutter (Empty condiment bags, dirty plates): [mode == KITCHENBOT_MODE_REFUSE ? "<b>Selected</b>" : "<A href='?src=[REF(src)];operation=trash'>Select</A>"]"
		dat += "<BR>The Griddler (You give it food, it griddles and manages it): [mode == KITCHENBOT_MODE_THE_GRIDDLER ? "<b>Selected</b>" : "<A href='?src=[REF(src)];operation=griddler'>Select</A>"]</A>"
		dat += "<BR>Waiter (Take finished dishes, serve tourists): [mode == KITCHENBOT_MODE_WAITER ? "<b>Selected</b>" : "<A href='?src=[REF(src)];operation=waiter'>Select</A>"]</A>"
	else
		dat += "<BR><BR>Sorry, you do not have access to the inner machinations of the amazing and illustrious Kitchenbot."
	return dat

/mob/living/simple_animal/bot/kitchenbot/Topic(href, href_list)
	if(..())
		return TRUE
	var/datum/ai_controller/kitchenbot/ai = ai_controller
	if(href_list["operation"])
		switch(href_list["operation"])
			if("idle")
				ai.change_mode(KITCHENBOT_MODE_IDLE)
			if("trash")
				ai.change_mode(KITCHENBOT_MODE_REFUSE)
			if("griddler")
				ai.change_mode(KITCHENBOT_MODE_THE_GRIDDLER)
			if("waiter")
				ai.change_mode(KITCHENBOT_MODE_WAITER)
		update_appearance(UPDATE_ICON)
		update_controls()

/mob/living/simple_animal/bot/kitchenbot/turn_off()
	. = ..()
	//kitchenbot forgets a lot of stuff when you turn them off (lets them relearn new things)
	ai_controller.blackboard[BB_KITCHENBOT_MODE] = KITCHENBOT_MODE_IDLE
	ai_controller.blackboard[BB_KITCHENBOT_CHOSEN_DISPOSALS] = null
	var/obj/item/held_refuse = ai_controller.blackboard[BB_KITCHENBOT_TARGET_TO_DISPOSE]
	if(held_refuse && held_refuse in src)
		held_refuse.forceMove(drop_location())
	ai_controller.blackboard[BB_KITCHENBOT_TARGET_TO_DISPOSE] = null
	ai_controller.blackboard[BB_KITCHENBOT_CHOSEN_GRIDDLE] = null
	ai_controller.blackboard[BB_KITCHENBOT_CHOSEN_STOCKPILE] = null
	ai_controller.blackboard[BB_KITCHENBOT_ITEMS_WATCHED] = list()
	var/obj/item/held_grillable = ai_controller.blackboard[BB_KITCHENBOT_TARGET_IN_STOCKPILE]
	if(held_grillable && held_grillable in src)
		held_grillable.forceMove(drop_location())
	ai_controller.blackboard[BB_KITCHENBOT_TARGET_IN_STOCKPILE] = null

/obj/machinery/bot_core/kitchenbot
	req_one_access = list(ACCESS_KITCHEN, ACCESS_ROBOTICS)
