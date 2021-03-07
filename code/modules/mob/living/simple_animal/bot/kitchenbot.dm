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
	pass_flags = PASSMOB | PASSFLAPS | PASSTABLE | PASSMACHINE
	path_image_color = "#fff5bc"
	allow_pai = FALSE
	layer = ABOVE_MOB_LAYER
	auto_patrol = FALSE
	uses_interact = FALSE

/mob/living/simple_animal/bot/kitchenbot/Initialize()
	. = ..()
	update_appearance(UPDATE_ICON)

	// Doing this hurts my soul, but simplebot access reworks are for another day.
	var/datum/id_trim/job/cook_trim = SSid_access.trim_singletons_by_path[/datum/id_trim/job/cook]
	access_card.add_access(cook_trim.access + cook_trim.wildcard_access)
	prev_access = access_card.access.Copy()
	ai_controller.blackboard[BB_KITCHENBOT_TASK_TEXT] = "makes a delighted ping"
	ai_controller.blackboard[BB_KITCHENBOT_TASK_SOUND] = 'sound/machines/ping.ogg'

/mob/living/simple_animal/bot/kitchenbot/emag_act(mob/user)
	. = ..()
	explode()

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
	icon_state = "[initial(icon_state)][mode2iconsuffix[mode]]"

/mob/living/simple_animal/bot/kitchenbot/show_controls(mob/M)
	return

/obj/machinery/bot_core/kitchenbot
	req_one_access = list(ACCESS_KITCHEN, ACCESS_ROBOTICS)
