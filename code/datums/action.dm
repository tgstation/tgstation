#define AB_CHECK_HANDS_BLOCKED (1<<0)
#define AB_CHECK_IMMOBILE (1<<1)
#define AB_CHECK_LYING (1<<2)
#define AB_CHECK_CONSCIOUS (1<<3)

/datum/action
	var/name = "Generic Action"
	var/desc
	var/datum/target
	var/check_flags = NONE
	var/processing = FALSE
	var/atom/movable/screen/movable/action_button/button = null
	var/buttontooltipstyle = ""
	var/transparent_when_unavailable = TRUE

	var/button_icon = 'icons/mob/actions/backgrounds.dmi' //This is the file for the BACKGROUND icon
	var/background_icon_state = ACTION_BUTTON_DEFAULT_BACKGROUND //And this is the state for the background icon

	var/icon_icon = 'icons/hud/actions.dmi' //This is the file for the ACTION icon
	var/button_icon_state = "default" //And this is the state for the action icon
	var/mob/owner
	///All mobs that are sharing our action button.
	var/list/sharers = list()

/datum/action/New(Target)
	link_to(Target)
	button = new
	button.linked_action = src
	button.name = name
	button.actiontooltipstyle = buttontooltipstyle
	if(desc)
		button.desc = desc

/datum/action/proc/link_to(Target)
	target = Target
	RegisterSignal(Target, COMSIG_ATOM_UPDATED_ICON, .proc/OnUpdatedIcon)

/datum/action/Destroy()
	if(owner)
		Remove(owner)
	target = null
	QDEL_NULL(button)
	return ..()

/datum/action/proc/Grant(mob/M)
	if(M)
		if(owner)
			if(owner == M)
				return
			Remove(owner)
		owner = M
		RegisterSignal(owner, COMSIG_PARENT_QDELETING, .proc/owner_deleted)

		//button id generation
		var/counter = 0
		var/bitfield = 0
		for(var/datum/action/A in M.actions)
			if(A.name == name && A.button.id)
				counter += 1
				bitfield |= A.button.id
		bitfield = ~bitfield
		var/bitflag = 1
		for(var/i in 1 to (counter + 1))
			if(bitfield & bitflag)
				button.id = bitflag
				break
			bitflag *= 2

		LAZYADD(M.actions, src)
		if(M.client)
			M.client.screen += button
			button.locked = M.client.prefs.read_preference(/datum/preference/toggle/buttons_locked) || button.id ? M.client.prefs.action_buttons_screen_locs["[name]_[button.id]"] : FALSE //even if it's not defaultly locked we should remember we locked it before
			button.moved = button.id ? M.client.prefs.action_buttons_screen_locs["[name]_[button.id]"] : FALSE
		M.update_action_buttons()
	else
		Remove(owner)

/datum/action/proc/owner_deleted(datum/source)
	SIGNAL_HANDLER
	Remove(owner)

/datum/action/proc/Remove(mob/M)
	for(var/datum/weakref/reference as anything in sharers)
		var/mob/freeloader = reference.resolve()
		if(!freeloader)
			continue
		Unshare(freeloader)
	sharers = null
	if(M)
		if(M.client)
			M.client.screen -= button
		LAZYREMOVE(M.actions, src)
		M.update_action_buttons()
	if(owner)
		UnregisterSignal(owner, COMSIG_PARENT_QDELETING)
		owner = null
	button.moved = FALSE //so the button appears in its normal position when given to another owner.
	button.locked = FALSE
	button.id = null

/datum/action/proc/Trigger()
	if(!IsAvailable())
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_ACTION_TRIGGER, src) & COMPONENT_ACTION_BLOCK_TRIGGER)
		return FALSE
	return TRUE


/datum/action/proc/IsAvailable()
	if(!owner)
		return FALSE
	if((check_flags & AB_CHECK_HANDS_BLOCKED) && HAS_TRAIT(owner, TRAIT_HANDS_BLOCKED))
		return FALSE
	if((check_flags & AB_CHECK_IMMOBILE) && HAS_TRAIT(owner, TRAIT_IMMOBILIZED))
		return FALSE
	if((check_flags & AB_CHECK_LYING) && isliving(owner))
		var/mob/living/action_user = owner
		if(action_user.body_position == LYING_DOWN)
			return FALSE
	if((check_flags & AB_CHECK_CONSCIOUS) && owner.stat != CONSCIOUS)
		return FALSE
	return TRUE


/datum/action/proc/UpdateButtonIcon(status_only = FALSE, force = FALSE)
	if(button)
		if(!status_only)
			button.name = name
			button.desc = desc
			if(owner?.hud_used && background_icon_state == ACTION_BUTTON_DEFAULT_BACKGROUND)
				var/list/settings = owner.hud_used.get_action_buttons_icons()
				if(button.icon != settings["bg_icon"])
					button.icon = settings["bg_icon"]
				if(button.icon_state != settings["bg_state"])
					button.icon_state = settings["bg_state"]
			else
				if(button.icon != button_icon)
					button.icon = button_icon
				if(button.icon_state != background_icon_state)
					button.icon_state = background_icon_state

			ApplyIcon(button, force)

		if(!IsAvailable())
			button.color = transparent_when_unavailable ? rgb(128,0,0,128) : rgb(128,0,0)
		else
			button.color = rgb(255,255,255,255)
			return 1

/datum/action/proc/ApplyIcon(atom/movable/screen/movable/action_button/current_button, force = FALSE)
	if(icon_icon && button_icon_state && ((current_button.button_icon_state != button_icon_state) || force))
		current_button.cut_overlays(TRUE)
		current_button.add_overlay(mutable_appearance(icon_icon, button_icon_state))
		current_button.button_icon_state = button_icon_state

/datum/action/proc/OnUpdatedIcon()
	SIGNAL_HANDLER
	UpdateButtonIcon()

//Adds our action button to the screen of another player
/datum/action/proc/Share(mob/freeloader)
	if(!freeloader.client)
		return
	sharers += WEAKREF(freeloader)
	freeloader.client.screen += button
	freeloader.actions += src
	freeloader.update_action_buttons()

//Removes our action button from the screen of another player
/datum/action/proc/Unshare(mob/freeloader)
	if(!freeloader.client)
		return
	for(var/freeloader_reference in sharers)
		if(IS_WEAKREF_OF(freeloader, freeloader_reference))
			sharers -= freeloader_reference
			break
	freeloader.client.screen -= button
	freeloader.actions -= src
	freeloader.update_action_buttons()

//Presets for item actions
/datum/action/item_action
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_CONSCIOUS
	button_icon_state = null
	// If you want to override the normal icon being the item
	// then change this to an icon state

/datum/action/item_action/New(Target)
	..()
	var/obj/item/I = target
	LAZYINITLIST(I.actions)
	I.actions += src

/datum/action/item_action/Destroy()
	var/obj/item/I = target
	I.actions -= src
	UNSETEMPTY(I.actions)
	return ..()

/datum/action/item_action/Trigger()
	. = ..()
	if(!.)
		return FALSE
	if(target)
		var/obj/item/I = target
		I.ui_action_click(owner, src)
	return TRUE

/datum/action/item_action/ApplyIcon(atom/movable/screen/movable/action_button/current_button, force)
	var/obj/item/item_target = target
	if(button_icon && button_icon_state)
		// If set, use the custom icon that we set instead
		// of the item appearence
		..()
	else if((target && current_button.appearance_cache != item_target.appearance) || force) //replace with /ref comparison if this is not valid.
		var/old_layer = item_target.layer
		var/old_plane = item_target.plane
		item_target.layer = FLOAT_LAYER //AAAH
		item_target.plane = FLOAT_PLANE //^ what that guy said
		current_button.cut_overlays()
		current_button.add_overlay(item_target)
		item_target.layer = old_layer
		item_target.plane = old_plane
		current_button.appearance_cache = item_target.appearance

/datum/action/item_action/toggle_light
	name = "Toggle Light"

/datum/action/item_action/toggle_light/Trigger()
	if(istype(target, /obj/item/pda))
		var/obj/item/pda/P = target
		P.toggle_light(owner)
		return
	..()

/datum/action/item_action/toggle_hood
	name = "Toggle Hood"

/datum/action/item_action/toggle_firemode
	name = "Toggle Firemode"

/datum/action/item_action/rcl_col
	name = "Change Cable Color"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "rcl_rainbow"

/datum/action/item_action/rcl_gui
	name = "Toggle Fast Wiring Gui"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "rcl_gui"

/datum/action/item_action/startchainsaw
	name = "Pull The Starting Cord"

/datum/action/item_action/toggle_gunlight
	name = "Toggle Gunlight"

/datum/action/item_action/toggle_mode
	name = "Toggle Mode"

/datum/action/item_action/toggle_barrier_spread
	name = "Toggle Barrier Spread"

/datum/action/item_action/equip_unequip_ted_gun
	name = "Equip/Unequip TED Gun"

/datum/action/item_action/toggle_paddles
	name = "Toggle Paddles"

/datum/action/item_action/set_internals
	name = "Set Internals"

/datum/action/item_action/set_internals/UpdateButtonIcon(status_only = FALSE, force)
	if(..()) //button available
		if(iscarbon(owner))
			var/mob/living/carbon/C = owner
			if(target == C.internal)
				button.icon_state = "template_active"

/datum/action/item_action/pick_color
	name = "Choose A Color"

/datum/action/item_action/toggle_mister
	name = "Toggle Mister"

/datum/action/item_action/activate_injector
	name = "Activate Injector"

/datum/action/item_action/toggle_helmet_light
	name = "Toggle Helmet Light"

/datum/action/item_action/toggle_welding_screen
	name = "Toggle Welding Screen"

/datum/action/item_action/toggle_welding_screen/Trigger()
	var/obj/item/clothing/head/hardhat/weldhat/H = target
	if(istype(H))
		H.toggle_welding_screen(owner)

/datum/action/item_action/toggle_welding_screen/plasmaman
	name = "Toggle Welding Screen"

/datum/action/item_action/toggle_welding_screen/plasmaman/Trigger()
	var/obj/item/clothing/head/helmet/space/plasmaman/H = target
	if(istype(H))
		H.toggle_welding_screen(owner)

/datum/action/item_action/toggle_spacesuit
	name = "Toggle Suit Thermal Regulator"
	icon_icon = 'icons/mob/actions/actions_spacesuit.dmi'
	button_icon_state = "thermal_off"

/datum/action/item_action/toggle_spacesuit/New(Target)
	. = ..()
	RegisterSignal(target, COMSIG_SUIT_SPACE_TOGGLE, .proc/toggle)

/datum/action/item_action/toggle_spacesuit/Destroy()
	UnregisterSignal(target, COMSIG_SUIT_SPACE_TOGGLE)
	return ..()

/datum/action/item_action/toggle_spacesuit/Trigger()
	var/obj/item/clothing/suit/space/suit = target
	if(!istype(suit))
		return
	suit.toggle_spacesuit()

/// Toggle the action icon for the space suit thermal regulator
/datum/action/item_action/toggle_spacesuit/proc/toggle(obj/item/clothing/suit/space/suit)
	SIGNAL_HANDLER

	button_icon_state = "thermal_[suit.thermal_on ? "on" : "off"]"
	UpdateButtonIcon()

/datum/action/item_action/vortex_recall
	name = "Vortex Recall"
	desc = "Recall yourself, and anyone nearby, to an attuned hierophant beacon at any time.<br>If the beacon is still attached, will detach it."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "vortex_recall"

/datum/action/item_action/vortex_recall/IsAvailable()
	var/area/current_area = get_area(target)
	if(current_area.area_flags & NOTELEPORT)
		to_chat(owner, span_notice("[target] fizzles uselessly."))
		return
	if(istype(target, /obj/item/hierophant_club))
		var/obj/item/hierophant_club/H = target
		if(H.teleporting)
			return FALSE
	return ..()

/datum/action/item_action/berserk_mode
	name = "Berserk"
	desc = "Increase your movement and melee speed while also increasing your melee armor for a short amount of time."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "berserk_mode"
	background_icon_state = "bg_demon"

/datum/action/item_action/berserk_mode/Trigger()
	if(istype(target, /obj/item/clothing/head/hooded/berserker))
		var/obj/item/clothing/head/hooded/berserker/berzerk = target
		if(berzerk.berserk_active)
			to_chat(owner, span_warning("You are already berserk!"))
			return
		if(berzerk.berserk_charge < 100)
			to_chat(owner, span_warning("You don't have a full charge."))
			return
		berzerk.berserk_mode(owner)
		return
	..()

/datum/action/item_action/toggle_helmet_flashlight
	name = "Toggle Helmet Flashlight"

/datum/action/item_action/toggle_helmet_mode
	name = "Toggle Helmet Mode"

/datum/action/item_action/crew_monitor
	name = "Interface With Crew Monitor"

/datum/action/item_action/toggle

/datum/action/item_action/toggle/New(Target)
	..()
	var/obj/item/item_target = target
	name = "Toggle [item_target.name]"
	button.name = name

/datum/action/item_action/halt
	name = "HALT!"

/datum/action/item_action/toggle_voice_box
	name = "Toggle Voice Box"

/datum/action/item_action/change
	name = "Change"

/datum/action/item_action/nano_picket_sign
	name = "Retext Nano Picket Sign"
	var/obj/item/picket_sign/S

/datum/action/item_action/nano_picket_sign/New(Target)
	..()
	if(istype(Target, /obj/item/picket_sign))
		S = Target

/datum/action/item_action/nano_picket_sign/Trigger()
	if(istype(S))
		S.retext(owner)

/datum/action/item_action/adjust

/datum/action/item_action/adjust/New(Target)
	..()
	var/obj/item/item_target = target
	name = "Adjust [item_target.name]"
	button.name = name

/datum/action/item_action/switch_hud
	name = "Switch HUD"

/datum/action/item_action/toggle_human_head
	name = "Toggle Human Head"

/datum/action/item_action/toggle_helmet
	name = "Toggle Helmet"

/datum/action/item_action/toggle_jetpack
	name = "Toggle Jetpack"

/datum/action/item_action/jetpack_stabilization
	name = "Toggle Jetpack Stabilization"

/datum/action/item_action/jetpack_stabilization/IsAvailable()
	var/obj/item/tank/jetpack/J = target
	if(!istype(J) || !J.on)
		return FALSE
	return ..()

/datum/action/item_action/hands_free
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/item_action/hands_free/activate
	name = "Activate"

/datum/action/item_action/hands_free/shift_nerves
	name = "Shift Nerves"

/datum/action/item_action/explosive_implant
	check_flags = NONE
	name = "Activate Explosive Implant"

/datum/action/item_action/toggle_research_scanner
	name = "Toggle Research Scanner"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "scan_mode"
	var/active = FALSE

/datum/action/item_action/toggle_research_scanner/Trigger()
	if(IsAvailable())
		active = !active
		if(active)
			owner.research_scanner++
		else
			owner.research_scanner--
		to_chat(owner, span_notice("[target] research scanner has been [active ? "activated" : "deactivated"]."))
		return 1

/datum/action/item_action/toggle_research_scanner/Remove(mob/M)
	if(owner && active)
		owner.research_scanner--
		active = FALSE
	..()

/datum/action/item_action/instrument
	name = "Use Instrument"
	desc = "Use the instrument specified"

/datum/action/item_action/instrument/Trigger()
	if(istype(target, /obj/item/instrument))
		var/obj/item/instrument/I = target
		I.interact(usr)
		return
	return ..()

/datum/action/item_action/activate_remote_view
	name = "Activate Remote View"
	desc = "Activates the Remote View of your spy sunglasses."

/datum/action/item_action/organ_action
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/item_action/organ_action/IsAvailable()
	var/obj/item/organ/I = target
	if(!I.owner)
		return FALSE
	return ..()

/datum/action/item_action/organ_action/toggle/New(Target)
	..()
	var/obj/item/organ/organ_target = target
	name = "Toggle [organ_target.name]"
	button.name = name

/datum/action/item_action/organ_action/use/New(Target)
	..()
	var/obj/item/organ/organ_target = target
	name = "Use [organ_target.name]"
	button.name = name

/datum/action/item_action/cult_dagger
	name = "Draw Blood Rune"
	desc = "Use the ritual dagger to create a powerful blood rune"
	icon_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "draw"
	buttontooltipstyle = "cult"
	background_icon_state = "bg_demon"

/datum/action/item_action/cult_dagger/Grant(mob/M)
	if(!IS_CULTIST(M))
		Remove(owner)
		return

	. = ..()
	button.screen_loc = "6:157,4:-2"
	button.moved = "6:157,4:-2"

/datum/action/item_action/cult_dagger/Trigger()
	for(var/obj/item/held_item as anything in owner.held_items) // In case we were already holding a dagger
		if(istype(held_item, /obj/item/melee/cultblade/dagger))
			held_item.attack_self(owner)
			return
	var/obj/item/target_item = target
	if(owner.can_equip(target_item, ITEM_SLOT_HANDS))
		owner.temporarilyRemoveItemFromInventory(target_item)
		owner.put_in_hands(target_item)
		target_item.attack_self(owner)
		return

	if(!isliving(owner))
		to_chat(owner, span_warning("You lack the necessary living force for this action."))
		return

	var/mob/living/living_owner = owner
	if (living_owner.usable_hands <= 0)
		to_chat(living_owner, span_warning("You don't have any usable hands!"))
	else
		to_chat(living_owner, span_warning("Your hands are full!"))


///MGS BOX!
/datum/action/item_action/agent_box
	name = "Deploy Box"
	desc = "Find inner peace, here, in the box."
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_IMMOBILE|AB_CHECK_CONSCIOUS
	background_icon_state = "bg_agent"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "deploy_box"
	///The type of closet this action spawns.
	var/boxtype = /obj/structure/closet/cardboard/agent
	COOLDOWN_DECLARE(box_cooldown)

///Handles opening and closing the box.
/datum/action/item_action/agent_box/Trigger()
	. = ..()
	if(!.)
		return FALSE
	if(istype(owner.loc, /obj/structure/closet/cardboard/agent))
		var/obj/structure/closet/cardboard/agent/box = owner.loc
		owner.playsound_local(box, 'sound/misc/box_deploy.ogg', 50, TRUE)
		box.open()
		return
	//Box closing from here on out.
	if(!isturf(owner.loc)) //Don't let the player use this to escape mechs/welded closets.
		to_chat(owner, span_warning("You need more space to activate this implant!"))
		return
	if(!COOLDOWN_FINISHED(src, box_cooldown))
		return
	COOLDOWN_START(src, box_cooldown, 10 SECONDS)
	var/box = new boxtype(owner.drop_location())
	owner.forceMove(box)
	owner.playsound_local(box, 'sound/misc/box_deploy.ogg', 50, TRUE)

/datum/action/item_action/agent_box/Grant(mob/M)
	..()
	if(owner)
		RegisterSignal(owner, COMSIG_HUMAN_SUICIDE, .proc/suicide_act)

/datum/action/item_action/agent_box/Remove(mob/M)
	if(owner)
		UnregisterSignal(owner, COMSIG_HUMAN_SUICIDE)
	..()

/datum/action/item_action/agent_box/proc/suicide_act(datum/source)
	if(istype(owner.loc, /obj/structure/closet/cardboard/agent))
		var/obj/structure/closet/cardboard/agent/box = owner.loc
		owner.playsound_local(box, 'sound/misc/box_deploy.ogg', 50, TRUE)
		box.open()
		owner.visible_message(span_suicide("[owner] falls out of [box]! It looks like [owner.p_they()] committed suicide!"))
		owner.throw_at(get_turf(owner))
		return OXYLOSS

//Preset for spells
/datum/action/spell_action
	check_flags = NONE
	background_icon_state = "bg_spell"

/datum/action/spell_action/New(Target)
	..()
	var/obj/effect/proc_holder/S = target
	S.action = src
	name = S.name
	desc = S.desc
	icon_icon = S.action_icon
	button_icon_state = S.action_icon_state
	background_icon_state = S.action_background_icon_state
	button.name = name

/datum/action/spell_action/Destroy()
	var/obj/effect/proc_holder/S = target
	S.action = null
	return ..()

/datum/action/spell_action/Trigger()
	if(!..())
		return FALSE
	if(target)
		var/obj/effect/proc_holder/S = target
		S.Click()
		return TRUE

/datum/action/spell_action/IsAvailable()
	if(!target)
		return FALSE
	return TRUE

/datum/action/spell_action/spell

/datum/action/spell_action/spell/IsAvailable()
	if(!target)
		return FALSE
	var/obj/effect/proc_holder/spell/S = target
	if(owner)
		return S.can_cast(owner)
	return FALSE

/datum/action/spell_action/alien

/datum/action/spell_action/alien/IsAvailable()
	if(!target)
		return FALSE
	var/obj/effect/proc_holder/alien/ab = target
	if(owner)
		return ab.cost_check(ab.check_turf,owner,1)
	return FALSE



//Preset for general and toggled actions
/datum/action/innate
	check_flags = NONE
	var/active = 0

/datum/action/innate/Trigger()
	if(!..())
		return FALSE
	if(!active)
		Activate()
	else
		Deactivate()
	return TRUE

/datum/action/innate/proc/Activate()
	return

/datum/action/innate/proc/Deactivate()
	return

//Preset for an action with a cooldown

/datum/action/cooldown
	check_flags = NONE
	transparent_when_unavailable = FALSE
	var/cooldown_time = 0
	var/next_use_time = 0

/datum/action/cooldown/New()
	..()
	button.maptext = ""
	button.maptext_x = 8
	button.maptext_y = 0
	button.maptext_width = 24
	button.maptext_height = 12

/datum/action/cooldown/IsAvailable()
	return next_use_time <= world.time

/datum/action/cooldown/proc/StartCooldown()
	next_use_time = world.time + cooldown_time
	button.maptext = MAPTEXT("<b>[round(cooldown_time/10, 0.1)]</b>")
	UpdateButtonIcon()
	START_PROCESSING(SSfastprocess, src)

/datum/action/cooldown/process()
	if(!owner)
		button.maptext = ""
		STOP_PROCESSING(SSfastprocess, src)
	var/timeleft = max(next_use_time - world.time, 0)
	if(timeleft == 0)
		button.maptext = ""
		UpdateButtonIcon()
		STOP_PROCESSING(SSfastprocess, src)
	else
		button.maptext = MAPTEXT("<b>[round(timeleft/10, 0.1)]</b>")

/datum/action/cooldown/Grant(mob/M)
	..()
	if(owner)
		UpdateButtonIcon()
		if(next_use_time > world.time)
			START_PROCESSING(SSfastprocess, src)

///Like a cooldown action, but with an associated proc holder.
/datum/action/cooldown/spell_like

/datum/action/cooldown/spell_like/New(Target)
	..()
	var/obj/effect/proc_holder/our_proc_holder = target
	our_proc_holder.action = src
	name = our_proc_holder.name
	desc = our_proc_holder.desc
	icon_icon = our_proc_holder.action_icon
	button_icon_state = our_proc_holder.action_icon_state
	background_icon_state = our_proc_holder.action_background_icon_state
	button.name = name

/datum/action/cooldown/spell_like/Trigger()
	if(!..())
		return FALSE
	if(target)
		var/obj/effect/proc_holder/our_proc_holder = target
		our_proc_holder.Click()
		return TRUE

//Stickmemes
/datum/action/item_action/stickmen
	name = "Summon Stick Minions"
	desc = "Allows you to summon faithful stickmen allies to aide you in battle."
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "art_summon"

//surf_ss13
/datum/action/item_action/bhop
	name = "Activate Jump Boots"
	desc = "Activates the jump boot's internal propulsion system, allowing the user to dash over 4-wide gaps."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "jetboot"

/datum/action/item_action/bhop/brocket
	name = "Activate Rocket Boots"
	desc = "Activates the boot's rocket propulsion system, allowing the user to hurl themselves great distances."

/datum/action/language_menu
	name = "Language Menu"
	desc = "Open the language menu to review your languages, their keys, and select your default language."
	button_icon_state = "language_menu"
	check_flags = NONE

/datum/action/language_menu/Trigger()
	if(!..())
		return FALSE
	if(ismob(owner))
		var/mob/M = owner
		var/datum/language_holder/H = M.get_language_holder()
		H.open_language_menu(usr)

/datum/action/item_action/wheelys
	name = "Toggle Wheels"
	desc = "Pops out or in your shoes' wheels."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "wheelys"

/datum/action/item_action/kindle_kicks
	name = "Activate Kindle Kicks"
	desc = "Kick you feet together, activating the lights in your Kindle Kicks."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "kindleKicks"

//Small sprites
/datum/action/small_sprite
	name = "Toggle Giant Sprite"
	desc = "Others will always see you as giant"
	icon_icon = 'icons/mob/actions/actions_xeno.dmi'
	button_icon_state = "smallqueen"
	background_icon_state = "bg_alien"
	var/small = FALSE
	var/small_icon
	var/small_icon_state

/datum/action/small_sprite/queen
	small_icon = 'icons/mob/alien.dmi'
	small_icon_state = "alienq"

/datum/action/small_sprite/megafauna
	icon_icon = 'icons/mob/actions/actions_xeno.dmi'
	button_icon_state = "smallqueen"
	background_icon_state = "bg_alien"
	small_icon = 'icons/mob/lavaland/lavaland_monsters.dmi'

/datum/action/small_sprite/megafauna/drake
	small_icon_state = "ash_whelp"

/datum/action/small_sprite/megafauna/colossus
	small_icon_state = "Basilisk"

/datum/action/small_sprite/megafauna/bubblegum
	small_icon_state = "goliath2"

/datum/action/small_sprite/megafauna/legion
	small_icon_state = "mega_legion"

/datum/action/small_sprite/mega_arachnid
	small_icon = 'icons/mob/jungle/arachnid.dmi'
	small_icon_state = "arachnid_mini"
	background_icon_state = "bg_demon"

/datum/action/small_sprite/Trigger()
	..()
	if(!small)
		var/image/I = image(icon = small_icon, icon_state = small_icon_state, loc = owner)
		I.override = TRUE
		I.pixel_x -= owner.pixel_x
		I.pixel_y -= owner.pixel_y
		owner.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic, "smallsprite", I, AA_TARGET_SEE_APPEARANCE | AA_MATCH_TARGET_OVERLAYS)
		small = TRUE
	else
		owner.remove_alt_appearance("smallsprite")
		small = FALSE

/datum/action/item_action/storage_gather_mode
	name = "Switch gathering mode"
	desc = "Switches the gathering mode of a storage object."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "storage_gather_switch"

/datum/action/item_action/storage_gather_mode/ApplyIcon(atom/movable/screen/movable/action_button/current_button)
	. = ..()
	var/obj/item/item_target = target
	var/old_layer = item_target.layer
	var/old_plane = item_target.plane
	item_target.layer = FLOAT_LAYER //AAAH
	item_target.plane = FLOAT_PLANE //^ what that guy said
	current_button.cut_overlays()
	current_button.add_overlay(target)
	item_target.layer = old_layer
	item_target.plane = old_plane
	current_button.appearance_cache = item_target.appearance
