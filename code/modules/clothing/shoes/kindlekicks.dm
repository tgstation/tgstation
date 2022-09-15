/obj/item/clothing/shoes/kindle_kicks
	name = "Kindle Kicks"
	desc = "They'll sure kindle something in you, and it's not childhood nostalgia..."
	icon_state = "kindleKicks"
	inhand_icon_state = "kindleKicks"
	actions_types = list(/datum/action/item_action/kindle_kicks)
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 3
	light_on = FALSE
	var/lightCycle = 0
	var/active = FALSE

/obj/item/clothing/shoes/kindle_kicks/ui_action_click(mob/user, action)
	if(active)
		return
	active = TRUE
	set_light_color(rgb(rand(0, 255), rand(0, 255), rand(0, 255)))
	set_light_on(active)
	addtimer(CALLBACK(src, .proc/lightUp), 0.5 SECONDS)

/obj/item/clothing/shoes/kindle_kicks/proc/lightUp(mob/user)
	if(lightCycle < 15)
		set_light_color(rgb(rand(0, 255), rand(0, 255), rand(0, 255)))
		lightCycle++
		addtimer(CALLBACK(src, .proc/lightUp), 0.5 SECONDS)
	else
		lightCycle = 0
		active = FALSE
		set_light_on(active)
