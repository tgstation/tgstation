#define AB_CHECK_RESTRAINED 1
#define AB_CHECK_STUN 2
#define AB_CHECK_LYING 4
#define AB_CHECK_CONSCIOUS 8

/datum/action
	var/name = "Generic Action"
	var/desc = null
	var/obj/target = null
	var/check_flags = 0
	var/processing = FALSE
	var/obj/screen/movable/action_button/button = null
	var/buttontooltipstyle = ""

	var/button_icon = 'icons/mob/actions/backgrounds.dmi' //This is the file for the BACKGROUND icon
	var/background_icon_state = ACTION_BUTTON_DEFAULT_BACKGROUND //And this is the state for the background icon

	var/icon_icon = 'icons/mob/actions.dmi' //This is the file for the ACTION icon
	var/button_icon_state = "default" //And this is the state for the action icon
	var/mob/owner

/datum/action/New(Target)
	target = Target
	button = new
	button.linked_action = src
	button.name = name
	button.actiontooltipstyle = buttontooltipstyle
	if(desc)
		button.desc = desc

/datum/action/Destroy()
	if(owner)
		Remove(owner)
	target = null
	qdel(button)
	button = null
	return ..()

/datum/action/proc/Grant(mob/M)
	if(M)
		if(owner)
			if(owner == M)
				return
			Remove(owner)
		owner = M
		M.actions += src
		if(M.client)
			M.client.screen += button
			button.locked = M.client.prefs.buttons_locked
		M.update_action_buttons()
	else
		Remove(owner)

/datum/action/proc/Remove(mob/M)
	if(M)
		if(M.client)
			M.client.screen -= button
		M.actions -= src
		M.update_action_buttons()
	owner = null
	button.moved = FALSE //so the button appears in its normal position when given to another owner.
	button.locked = FALSE

/datum/action/proc/Trigger()
	if(!IsAvailable())
		return 0
	return 1

/datum/action/proc/Process()
	return

/datum/action/proc/IsAvailable()
	if(!owner)
		return 0
	if(check_flags & AB_CHECK_RESTRAINED)
		if(owner.restrained())
			return 0
	if(check_flags & AB_CHECK_STUN)
		if(owner.IsKnockdown() || owner.IsStun())
			return 0
	if(check_flags & AB_CHECK_LYING)
		if(owner.lying)
			return 0
	if(check_flags & AB_CHECK_CONSCIOUS)
		if(owner.stat)
			return 0
	return 1

/datum/action/proc/UpdateButtonIcon(status_only = FALSE)
	if(button)
		if(!status_only)
			button.name = name
			button.desc = desc
			if(owner && owner.hud_used && background_icon_state == ACTION_BUTTON_DEFAULT_BACKGROUND)
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

			ApplyIcon(button)

		if(!IsAvailable())
			button.color = rgb(128,0,0,128)
		else
			button.color = rgb(255,255,255,255)
			return 1

/datum/action/proc/ApplyIcon(obj/screen/movable/action_button/current_button)
	if(icon_icon && button_icon_state && current_button.button_icon_state != button_icon_state)
		current_button.cut_overlays(TRUE)
		current_button.add_overlay(mutable_appearance(icon_icon, button_icon_state))
		current_button.button_icon_state = button_icon_state


//Presets for item actions
/datum/action/item_action
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN|AB_CHECK_LYING|AB_CHECK_CONSCIOUS
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
	if(!..())
		return 0
	if(target)
		var/obj/item/I = target
		I.ui_action_click(owner, src)
	return 1

/datum/action/item_action/ApplyIcon(obj/screen/movable/action_button/current_button)
	if(button_icon && button_icon_state)
		// If set, use the custom icon that we set instead
		// of the item appearence
		..(current_button)
	else if(target && current_button.appearance_cache != target.appearance) //replace with /ref comparison if this is not valid.
		var/obj/item/I = target
		current_button.appearance_cache = I.appearance
		var/old_layer = I.layer
		var/old_plane = I.plane
		I.layer = FLOAT_LAYER //AAAH
		I.plane = FLOAT_PLANE //^ what that guy said
		current_button.overlays = list(I)
		I.layer = old_layer
		I.plane = old_plane

/datum/action/item_action/toggle_light
	name = "Toggle Light"

/datum/action/item_action/toggle_hood
	name = "Toggle Hood"

/datum/action/item_action/toggle_firemode
	name = "Toggle Firemode"

/datum/action/item_action/rcl
	name = "Change Cable Color"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "rcl_rainbow"

/datum/action/item_action/startchainsaw
	name = "Pull The Starting Cord"

/datum/action/item_action/toggle_gunlight
	name = "Toggle Gunlight"

/datum/action/item_action/toggle_mode
	name = "Toggle Mode"

/datum/action/item_action/toggle_barrier_spread
	name = "Toggle Barrier Spread"

/datum/action/item_action/equip_unequip_TED_Gun
	name = "Equip/Unequip TED Gun"

/datum/action/item_action/toggle_paddles
	name = "Toggle Paddles"

/datum/action/item_action/set_internals
	name = "Set Internals"

/datum/action/item_action/set_internals/UpdateButtonIcon(status_only = FALSE)
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

/datum/action/item_action/toggle_headphones
	name = "Toggle Headphones"
	desc = "UNTZ UNTZ UNTZ"

/datum/action/item_action/toggle_headphones/Trigger()
	var/obj/item/clothing/ears/headphones/H = target
	if(istype(H))
		H.toggle(owner)

/datum/action/item_action/toggle_unfriendly_fire
	name = "Toggle Friendly Fire \[ON\]"
	desc = "Toggles if the club's blasts cause friendly fire."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "vortex_ff_on"

/datum/action/item_action/toggle_unfriendly_fire/Trigger()
	if(..())
		UpdateButtonIcon()

/datum/action/item_action/toggle_unfriendly_fire/UpdateButtonIcon(status_only = FALSE)
	if(istype(target, /obj/item/weapon/hierophant_club))
		var/obj/item/weapon/hierophant_club/H = target
		if(H.friendly_fire_check)
			button_icon_state = "vortex_ff_off"
			name = "Toggle Friendly Fire \[OFF\]"
		else
			button_icon_state = "vortex_ff_on"
			name = "Toggle Friendly Fire \[ON\]"
	..()

/datum/action/item_action/synthswitch
	name = "Change Synthesizer Instrument"
	desc = "Change the type of instrument your synthesizer is playing as."

/datum/action/item_action/synthswitch/Trigger()
	if(istype(target, /obj/item/device/instrument/piano_synth))
		var/obj/item/device/instrument/piano_synth/synth = target
		var/chosen = input("Choose the type of instrument you want to use", "Instrument Selection", "piano") as null|anything in synth.insTypes
		if(!synth.insTypes[chosen])
			return
		return synth.changeInstrument(chosen)
	return ..()

/datum/action/item_action/vortex_recall
	name = "Vortex Recall"
	desc = "Recall yourself, and anyone nearby, to an attuned hierophant beacon at any time.<br>If the beacon is still attached, will detach it."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "vortex_recall"

/datum/action/item_action/vortex_recall/IsAvailable()
	if(istype(target, /obj/item/weapon/hierophant_club))
		var/obj/item/weapon/hierophant_club/H = target
		if(H.teleporting)
			return 0
	return ..()

/datum/action/item_action/clock
	icon_icon = 'icons/mob/actions/actions_clockcult.dmi'
	background_icon_state = "bg_clock"
	buttontooltipstyle = "clockcult"

/datum/action/item_action/clock/IsAvailable()
	if(!is_servant_of_ratvar(owner))
		return 0
	return ..()

/datum/action/item_action/clock/toggle_visor
	name = "Create Judicial Marker"
	desc = "Allows you to create a stunning Judicial Marker at any location in view. Click again to disable."

/datum/action/item_action/clock/toggle_visor/IsAvailable()
	if(!is_servant_of_ratvar(owner))
		return 0
	if(istype(target, /obj/item/clothing/glasses/judicial_visor))
		var/obj/item/clothing/glasses/judicial_visor/V = target
		if(V.recharging)
			return 0
	return ..()

/datum/action/item_action/clock/hierophant
	name = "Hierophant Network"
	desc = "Lets you discreetly talk with all other servants. Nearby listeners can hear you whispering, so make sure to do this privately."
	button_icon_state = "hierophant_slab"

/datum/action/item_action/clock/quickbind
	name = "Quickbind"
	desc = "If you're seeing this, file a bug report."
	var/scripture_index = 0 //the index of the scripture we're associated with

/datum/action/item_action/toggle_helmet_flashlight
	name = "Toggle Helmet Flashlight"

/datum/action/item_action/toggle_helmet_mode
	name = "Toggle Helmet Mode"

/datum/action/item_action/toggle

/datum/action/item_action/toggle/New(Target)
	..()
	name = "Toggle [target.name]"
	button.name = name

/datum/action/item_action/halt
	name = "HALT!"

/datum/action/item_action/toggle_voice_box
	name = "Toggle Voice Box"

/datum/action/item_action/change
	name = "Change"

/datum/action/item_action/adjust

/datum/action/item_action/adjust/New(Target)
	..()
	name = "Adjust [target.name]"
	button.name = name

/datum/action/item_action/switch_hud
	name = "Switch HUD"

/datum/action/item_action/toggle_wings
	name = "Toggle Wings"

/datum/action/item_action/toggle_human_head
	name = "Toggle Human Head"

/datum/action/item_action/toggle_helmet
	name = "Toggle Helmet"

/datum/action/item_action/toggle_jetpack
	name = "Toggle Jetpack"

/datum/action/item_action/jetpack_stabilization
	name = "Toggle Jetpack Stabilization"

/datum/action/item_action/jetpack_stabilization/IsAvailable()
	var/obj/item/weapon/tank/jetpack/J = target
	if(!istype(J) || !J.on)
		return 0
	return ..()

/datum/action/item_action/hands_free
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/item_action/hands_free/activate
	name = "Activate"

/datum/action/item_action/hands_free/shift_nerves
	name = "Shift Nerves"

/datum/action/item_action/explosive_implant
	check_flags = 0
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
		to_chat(owner, "<span class='notice'>[target] research scanner has been [active ? "activated" : "deactivated"].</span>")
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
	if(istype(target, /obj/item/device/instrument))
		var/obj/item/device/instrument/I = target
		I.interact(usr)
		return
	return ..()

/datum/action/item_action/initialize_ninja_suit
	name = "Toggle ninja suit"

/datum/action/item_action/ninjajaunt
	name = "Phase Jaunt (10E)"
	desc = "Utilizes the internal VOID-shift device to rapidly transit in direction facing."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "ninja_phase"

/datum/action/item_action/ninjasmoke
	name = "Smoke Bomb"
	desc = "Blind your enemies momentarily with a well-placed smoke bomb."
	button_icon_state = "smoke"

/datum/action/item_action/ninjaboost
	name = "Adrenaline Boost"
	desc = "Inject a secret chemical that will counteract all movement-impairing effect."
	button_icon_state = "repulse"

/datum/action/item_action/ninjapulse
	name = "EM Burst (25E)"
	desc = "Disable any nearby technology with a electro-magnetic pulse."
	button_icon_state = "emp"

/datum/action/item_action/ninjastar
	name = "Create Throwing Stars (1E)"
	desc = "Creates some throwing stars"
	button_icon_state = "throwingstar"
	icon_icon = 'icons/obj/weapons.dmi'

/datum/action/item_action/ninjanet
	name = "Energy Net (20E)"
	desc = "Captures a fallen opponent in a net of energy. Will teleport them to a holding facility after 30 seconds."
	button_icon_state = "energynet"
	icon_icon = 'icons/effects/effects.dmi'

/datum/action/item_action/ninja_sword_recall
	name = "Recall Energy Katana (Variable Cost)"
	desc = "Teleports the Energy Katana linked to this suit to its wearer, cost based on distance."
	button_icon_state = "energy_katana"
	icon_icon = 'icons/obj/weapons.dmi'

/datum/action/item_action/ninja_stealth
	name = "Toggle Stealth"
	desc = "Toggles stealth mode on and off."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "ninja_cloak"

/datum/action/item_action/toggle_glove
	name = "Toggle interaction"
	desc = "Switch between normal interaction and drain mode."
	button_icon_state = "s-ninjan"
	icon_icon = 'icons/obj/clothing/gloves.dmi'


/datum/action/item_action/organ_action
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/item_action/organ_action/IsAvailable()
	var/obj/item/organ/I = target
	if(!I.owner)
		return 0
	return ..()

/datum/action/item_action/organ_action/toggle/New(Target)
	..()
	name = "Toggle [target.name]"
	button.name = name

/datum/action/item_action/organ_action/use/New(Target)
	..()
	name = "Use [target.name]"
	button.name = name




//Preset for spells
/datum/action/spell_action
	check_flags = 0
	background_icon_state = "bg_spell"

/datum/action/spell_action/New(Target)
	..()
	var/obj/effect/proc_holder/spell/S = target
	S.action = src
	name = S.name
	desc = S.desc
	icon_icon = S.action_icon
	button_icon_state = S.action_icon_state
	background_icon_state = S.action_background_icon_state
	button.name = name

/datum/action/spell_action/Destroy()
	var/obj/effect/proc_holder/spell/S = target
	S.action = null
	return ..()

/datum/action/spell_action/Trigger()
	if(!..())
		return 0
	if(target)
		var/obj/effect/proc_holder/spell = target
		spell.Click()
		return 1

/datum/action/spell_action/IsAvailable()
	if(!target)
		return 0
	var/obj/effect/proc_holder/spell/spell = target
	if(owner)
		return spell.can_cast(owner)
	return 0


/datum/action/spell_action/alien

/datum/action/spell_action/alien/IsAvailable()
	if(!target)
		return 0
	var/obj/effect/proc_holder/alien/ab = target
	if(owner)
		return ab.cost_check(ab.check_turf,owner,1)
	return 0



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

//Preset for action that call specific procs (consider innate).
/datum/action/generic
	check_flags = 0
	var/procname

/datum/action/generic/Trigger()
	if(!..())
		return 0
	if(target && procname)
		call(target, procname)(usr)
	return 1

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

/datum/action/language_menu
	name = "Language Menu"
	desc = "Open the language menu to review your languages, their keys, and select your default language."
	button_icon_state = "language_menu"
	check_flags = 0

/datum/action/language_menu/Trigger()
	if(!..())
		return FALSE
	if(ismob(owner))
		var/mob/M = owner
		var/datum/language_holder/H = M.get_language_holder()
		H.open_language_menu(usr)
