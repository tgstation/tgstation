#define AB_CHECK_RESTRAINED 1
#define AB_CHECK_STUNNED 2
#define AB_CHECK_LYING 4
#define AB_CHECK_ALIVE 8
#define AB_CHECK_INSIDE 16


/datum/action
	var/name = "Generic Action"
	var/obj/item/target = null
	var/check_flags = 0
	var/processing = 0
	var/obj/screen/movable/action_button/button = null
	var/button_icon = 'icons/mob/actions.dmi'
	var/button_icon_state = "default"
	var/background_icon_state = "bg_default"
	var/mob/living/owner

/datum/action/New(var/Target)
	target = Target

/datum/action/Destroy()
	if(owner)
		Remove(owner)
	return ..()

/datum/action/proc/Grant(mob/living/T)
	if(owner)
		if(owner == T)
			return
		Remove(owner)
	owner = T
	owner.actions.Add(src)
	owner.update_action_buttons()
	return

/datum/action/proc/Remove(mob/living/T)
	if(button)
		if(T.client)
			T.client.screen -= button
		qdel(button)
		button = null
	T.actions.Remove(src)
	T.update_action_buttons()
	owner = null
	return

/datum/action/proc/Trigger()
	if(!Checks())
		return 0
	return 1

/datum/action/proc/Process()
	return

/datum/action/proc/CheckRemoval(mob/living/user) // 1 if action is no longer valid for this mob and should be removed
	return 0

/datum/action/proc/IsAvailable()
	return Checks()

/datum/action/proc/Checks()// returns 1 if all checks pass
	if(!owner)
		return 0
	if(check_flags & AB_CHECK_RESTRAINED)
		if(owner.restrained())
			return 0
	if(check_flags & AB_CHECK_STUNNED)
		if(owner.stunned)
			return 0
	if(check_flags & AB_CHECK_LYING)
		if(owner.lying)
			return 0
	if(check_flags & AB_CHECK_ALIVE)
		if(owner.stat)
			return 0
	if(check_flags & AB_CHECK_INSIDE)
		if(!(target in owner) && !(target.action_button_internal))
			return 0
	return 1

/datum/action/proc/UpdateName()
	return name

/datum/action/proc/ApplyIcon(obj/screen/movable/action_button/current_button)
	current_button.overlays.Cut()
	if(button_icon && button_icon_state)
		var/image/img
		img = image(button_icon,current_button,button_icon_state)
		img.pixel_x = 0
		img.pixel_y = 0
		current_button.overlays += img

/obj/screen/movable/action_button
	var/datum/action/owner
	screen_loc = "WEST,NORTH"

/obj/screen/movable/action_button/Click(location,control,params)
	var/list/modifiers = params2list(params)
	if(modifiers["shift"])
		moved = 0
		return 1
	if(usr.next_move >= world.time) // Is this needed ?
		return
	owner.Trigger()
	return 1

/obj/screen/movable/action_button/proc/UpdateIcon()
	if(!owner)
		return
	icon = owner.button_icon
	icon_state = owner.background_icon_state

	owner.ApplyIcon(src)

	if(!owner.IsAvailable())
		color = rgb(128,0,0,128)
	else
		color = rgb(255,255,255,255)

//Hide/Show Action Buttons ... Button
/obj/screen/movable/action_button/hide_toggle
	name = "Hide Buttons"
	icon = 'icons/mob/actions.dmi'
	icon_state = "bg_default"
	var/hidden = 0

/obj/screen/movable/action_button/hide_toggle/Click(location,control,params)
	var/list/modifiers = params2list(params)
	if(modifiers["shift"])
		moved = 0
		return 1
	usr.hud_used.action_buttons_hidden = !usr.hud_used.action_buttons_hidden

	hidden = usr.hud_used.action_buttons_hidden
	if(hidden)
		name = "Show Buttons"
	else
		name = "Hide Buttons"
	UpdateIcon()
	usr.update_action_buttons()


/obj/screen/movable/action_button/hide_toggle/proc/InitialiseIcon(mob/living/user)
	if(isalien(user))
		icon_state = "bg_alien"
	else
		icon_state = "bg_default"
	UpdateIcon()
	return

/obj/screen/movable/action_button/hide_toggle/UpdateIcon()
	overlays.Cut()
	var/image/img = image(icon,src,hidden?"show":"hide")
	overlays += img
	return


/obj/screen/movable/action_button/MouseEntered(location,control,params)
	openToolTip(usr,src,params,title = name,content = desc)


/obj/screen/movable/action_button/MouseExited()
	closeToolTip(usr)


//This is the proc used to update all the action buttons. Properly defined in /mob/living/
/mob/proc/update_action_buttons()
	return

#define AB_MAX_COLUMNS 10

/datum/hud/proc/ButtonNumberToScreenCoords(number) // TODO : Make this zero-indexed for readabilty
	var/row = round((number-1)/AB_MAX_COLUMNS)
	var/col = ((number - 1)%(AB_MAX_COLUMNS)) + 1

	var/coord_col = "+[col-1]"
	var/coord_col_offset = 4+2*col

	var/coord_row = "[row ? -row : "+0"]"

	return "WEST[coord_col]:[coord_col_offset],NORTH[coord_row]:-6"

/datum/hud/proc/SetButtonCoords(obj/screen/button,number)
	var/row = round((number-1)/AB_MAX_COLUMNS)
	var/col = ((number - 1)%(AB_MAX_COLUMNS)) + 1
	var/x_offset = 32*(col-1) + 4 + 2*col
	var/y_offset = -32*(row+1) + 26

	var/matrix/M = matrix()
	M.Translate(x_offset,y_offset)
	button.transform = M

//Presets for item actions
/datum/action/item_action
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_LYING|AB_CHECK_ALIVE|AB_CHECK_INSIDE

/datum/action/item_action/Trigger()
	if(!..())
		return 0
	if(target)
		var/obj/item/item = target
		item.ui_action_click()
	return 1

/datum/action/item_action/CheckRemoval(mob/living/user)
	return !(target in user)

/datum/action/item_action/ApplyIcon(obj/screen/movable/action_button/current_button)
	current_button.overlays.Cut()
	if(target)
		var/obj/item/I = target
		var/old = I.layer
		I.layer = FLOAT_LAYER //AAAH
		current_button.overlays += I
		I.layer = old

/datum/action/item_action/hands_free
	check_flags = AB_CHECK_ALIVE|AB_CHECK_INSIDE

/datum/action/item_action/organ_action
	check_flags = AB_CHECK_ALIVE

/datum/action/item_action/organ_action/CheckRemoval(mob/living/carbon/user)
	if(!iscarbon(user))
		return 1
	if(target in user.internal_organs)
		return 0
	return 1

/datum/action/item_action/organ_action/IsAvailable()
	var/obj/item/organ/internal/I = target
	if(!I.owner)
		return 0
	return ..()

//Preset for spells
/datum/action/spell_action
	check_flags = 0
	background_icon_state = "bg_spell"

/datum/action/spell_action/Trigger()
	if(!..())
		return 0
	if(target)
		var/obj/effect/proc_holder/spell = target
		spell.Click()
		return 1

/datum/action/spell_action/UpdateName()
	var/obj/effect/proc_holder/spell/spell = target
	return spell.name

/datum/action/spell_action/IsAvailable()
	if(!target)
		return 0
	var/obj/effect/proc_holder/spell/spell = target

	if(usr)
		return spell.can_cast(usr)
	else
		if(owner)
			return spell.can_cast(owner)
	return 1

/datum/action/spell_action/CheckRemoval()
	if(owner.mind)
		if(target in owner.mind.spell_list)
			return 0
	return !(target in owner.mob_spell_list)

//Preset for general and toggled actions
/datum/action/innate
	check_flags = 0
	var/active = 0

/datum/action/innate/Trigger()
	if(!..())
		return 0
	if(!active)
		Activate()
	else
		Deactivate()
	return 1

/datum/action/innate/proc/Activate()
	return

/datum/action/innate/proc/Deactivate()
	return

//Preset for action that call specific procs (consider innate)
/datum/action/generic
	check_flags = 0
	var/procname

/datum/action/generic/Trigger()
	if(!..())
		return 0
	if(target && procname)
		call(target,procname)(usr)
	return 1


//Action button controlling a mob's research examine ability.
/datum/action/innate/scan_mode
	name = "Toggle Research Scanner"
	button_icon_state = "scan_mode"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_ALIVE
	var/devices = 0 //How may enabled scanners the mob has

/datum/action/innate/scan_mode/Activate()
	active = 1
	owner.research_scanner = 1
	owner << "<span class='notice'> Research analyzer is now active.</span>"

/datum/action/innate/scan_mode/Deactivate()
	active = 0
	owner.research_scanner = 0
	owner << "<span class='notice'> Research analyzer deactivated.</span>"

/datum/action/innate/scan_mode/Grant(mob/living/T)
	..(T)

/datum/action/innate/scan_mode/CheckRemoval(mob/living/user)
	if(devices)
		return 0
	return 1

/datum/action/innate/scan_mode/Remove(mob/living/T)
	owner.research_scanner = 0
	active = 0
	..(T)