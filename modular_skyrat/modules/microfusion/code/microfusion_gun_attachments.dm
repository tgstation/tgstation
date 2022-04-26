/**
*MICROFUSION GUN UPGRADE ATTACHMENTS
*For adding unique abilities to microfusion guns, these can directly interact with the gun!
*/

/obj/item/microfusion_gun_attachment
	name = "microfusion gun attachment"
	desc = "If you see this yell at a coder"
	icon = 'modular_skyrat/modules/microfusion/icons/microfusion_gun_attachments.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	/// The attachment overlay icon state.
	var/attachment_overlay_icon_state
	/// Any incompatable upgrade types.
	var/list/incompatable_attachments = list()
	/// The added heat produced by having this module installed.
	var/heat_addition = 0
	/// The slot this attachment is installed in.
	var/slot = GUN_SLOT_UNIQUE
	/// How much extra power do we use?
	var/power_usage = 0

/obj/item/microfusion_gun_attachment/examine(mob/user)
	. = ..()
	. += "Compatible slot: <b>[slot]</b>."

/obj/item/microfusion_gun_attachment/proc/run_attachment(obj/item/gun/microfusion/microfusion_gun)
	SHOULD_CALL_PARENT(TRUE)
	microfusion_gun.heat_per_shot += heat_addition
	microfusion_gun.update_appearance()
	microfusion_gun.extra_power_usage += power_usage
	microfusion_gun.chambered?.refresh_shot()
	return

/obj/item/microfusion_gun_attachment/proc/process_attachment(obj/item/gun/microfusion/microfusion_gun)
	return

//Firing the gun right before we let go of it, tis is called.
/obj/item/microfusion_gun_attachment/proc/process_fire(obj/item/gun/microfusion/microfusion_gun, obj/item/ammo_casing/chambered)
	return

/obj/item/microfusion_gun_attachment/proc/remove_attachment(obj/item/gun/microfusion/microfusion_gun)
	SHOULD_CALL_PARENT(TRUE)
	microfusion_gun.heat_per_shot -= heat_addition
	microfusion_gun.update_appearance()
	microfusion_gun.extra_power_usage -= power_usage
	microfusion_gun.chambered?.refresh_shot()
	return

/*
Returns a list of modifications of this attachment, it must return a list within a list list(list()).
All of the following must be returned.
list(list("title" = "Toggle [toggle ? "OFF" : "ON"]", "icon" = "power-off", "color" = "blue" "reference" = "toggle_on_off"))
title - The title of the modification button
icon - The icon of the modification button
color - The color of the modification button
reference - The reference of the modification button, this is used to call the proc when the run modify data proc is called.
*/
/obj/item/microfusion_gun_attachment/proc/get_modify_data()
	return

/obj/item/microfusion_gun_attachment/proc/run_modify_data(params, mob/living/user, obj/item/gun/microfusion/microfusion_gun)
	return

/obj/item/microfusion_gun_attachment/proc/get_information_data()
	return

/*
SCATTER ATTACHMENT

Turns the gun into a shotgun.
*/
/obj/item/microfusion_gun_attachment/scatter
	name = "diffuser microfusion lens upgrade"
	desc = "A diffusing lens system capable of splitting one beam into three. However, the additional ionizing of the air will cause higher recoil."
	icon_state = "attachment_scatter"
	attachment_overlay_icon_state = "attachment_scatter"
	slot = GUN_SLOT_BARREL
	/// How many pellets are we going to add to the existing amount on the gun?
	var/pellets_to_add = 2
	/// The variation in pellet scatter.
	var/variance_to_add = 20
	/// How much recoil are we adding?
	var/recoil_to_add = 1
	/// The spread to add.
	var/spread_to_add = 10
	var/projectile_override = /obj/projectile/beam/laser/microfusion/scatter

/obj/item/microfusion_gun_attachment/scatter/run_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.recoil += recoil_to_add
	microfusion_gun.spread += spread_to_add
	microfusion_gun.microfusion_lens.pellets += pellets_to_add
	microfusion_gun.microfusion_lens.variance += variance_to_add

/obj/item/microfusion_gun_attachment/scatter/process_fire(obj/item/gun/microfusion/microfusion_gun, obj/item/ammo_casing/chambered)
	. = ..()
	chambered.loaded_projectile = new projectile_override
	chambered.loaded_projectile?.damage = chambered.loaded_projectile.damage / chambered.pellets

/obj/item/microfusion_gun_attachment/scatter/remove_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.recoil -= recoil_to_add
	microfusion_gun.spread -= spread_to_add
	microfusion_gun.microfusion_lens.pellets -= pellets_to_add
	microfusion_gun.microfusion_lens.variance -= variance_to_add

/*
CRYSTALLINE SCATTER ATTACHMENT

An overclocked shotgun.
*/
/obj/item/microfusion_gun_attachment/scattermax
	name = "crystalline diffuser microfusion lens upgrade"
	desc = "An experimental diffusing lens system capable of splitting one beam into 7. However, it requires higher power usage as well as results in higher recoil."
	icon_state = "attachment_scattermax"
	attachment_overlay_icon_state = "attachment_scattermax"
	slot = GUN_SLOT_BARREL
	/// How many pellets are we going to add to the existing amount on the gun?
	var/pellets_to_add = 6
	/// The variation in pellet scatter.
	var/variance_to_add = 25
	/// How much recoil are we adding?
	var/recoil_to_add = 1
	/// The spread to add.
	var/spread_to_add = 15
	var/projectile_override =/obj/projectile/beam/laser/microfusion/scattermax
	power_usage = 20

/obj/item/microfusion_gun_attachment/scattermax/run_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.recoil += recoil_to_add
	microfusion_gun.spread += spread_to_add
	microfusion_gun.microfusion_lens.pellets += pellets_to_add
	microfusion_gun.microfusion_lens.variance += variance_to_add

/obj/item/microfusion_gun_attachment/scattermax/process_fire(obj/item/gun/microfusion/microfusion_gun, obj/item/ammo_casing/chambered)
	. = ..()
	chambered.loaded_projectile = new projectile_override
	chambered.loaded_projectile?.damage = chambered.loaded_projectile.damage / chambered.pellets

/obj/item/microfusion_gun_attachment/scattermax/remove_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.recoil -= recoil_to_add
	microfusion_gun.spread -= spread_to_add
	microfusion_gun.microfusion_lens.pellets -= pellets_to_add
	microfusion_gun.microfusion_lens.variance -= variance_to_add

/*
SUPERHEAT ATTACHMENT

Lasers set the target on fire.
*/
/obj/item/microfusion_gun_attachment/superheat
	name = "superheating phase emitter upgrade"
	desc = "A barrel attachment hooked to the phase emitter, this adjusts the beam's wavelength to carry an intense wave of heat; causing targets to ignite."
	icon_state = "attachment_superheat"
	attachment_overlay_icon_state = "attachment_superheat"
	incompatable_attachments = list(/obj/item/microfusion_gun_attachment/scatter, /obj/item/microfusion_gun_attachment/hellfire)
	heat_addition = 90
	slot = GUN_SLOT_BARREL
	var/projectile_override =/obj/projectile/beam/laser/microfusion/scatter

/obj/item/microfusion_gun_attachment/superheat/run_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.fire_sound = 'modular_skyrat/modules/microfusion/sound/vaporize.ogg'

/obj/item/microfusion_gun_attachment/superheat/remove_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.fire_sound = microfusion_gun.chambered?.fire_sound


/obj/item/microfusion_gun_attachment/superheat/process_fire(obj/item/gun/microfusion/microfusion_gun, obj/item/ammo_casing/chambered)
	. = ..()
	chambered.loaded_projectile = new projectile_override

/*
HELLFIRE ATTACHMENT

Makes the gun shoot hellfire lasers.
*/
/obj/item/microfusion_gun_attachment/hellfire
	name = "hellfire emitter upgrade"
	desc = "A barrel attachment hooked to the phase emitter, this adjusts the beam's wavelength to carry an extra wave of heat; causing nastier wounds and more damage."
	icon_state = "attachment_hellfire"
	attachment_overlay_icon_state = "attachment_hellfire"
	incompatable_attachments = list(/obj/item/microfusion_gun_attachment/scatter, /obj/item/microfusion_gun_attachment/superheat)
	heat_addition = 50
	power_usage = 20
	slot = GUN_SLOT_BARREL
	var/projectile_override =/obj/projectile/beam/laser/microfusion/hellfire

/obj/item/microfusion_gun_attachment/hellfire/run_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.fire_sound = 'modular_skyrat/modules/microfusion/sound/melt.ogg'

/obj/item/microfusion_gun_attachment/hellfire/remove_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.fire_sound = microfusion_gun.chambered?.fire_sound


/obj/item/microfusion_gun_attachment/hellfire/process_fire(obj/item/gun/microfusion/microfusion_gun, obj/item/ammo_casing/chambered)
	. = ..()
	chambered.loaded_projectile = new projectile_override

/*
REPEATER ATTACHMENT

The gun can fire volleys of shots.
*/
/obj/item/microfusion_gun_attachment/repeater
	name = "repeating phase emitter upgrade"
	desc = "This barrel attachment upgrades the central phase emitter to fire off two beams in quick succession. While offering an increased rate of fire, the heat output and recoil rises too."
	icon_state = "attachment_repeater"
	attachment_overlay_icon_state = "attachment_repeater"
	heat_addition = 40
	slot = GUN_SLOT_BARREL
	/// The spread to add to the gun.
	var/spread_to_add = 15
	/// The recoil to add to the gun.
	var/recoil_to_add = 1
	/// The burst to add to the gun.
	var/burst_to_add = 1
	/// The delay to add to the firing.
	var/delay_to_add = 5
	var/projectile_override =/obj/projectile/beam/laser/microfusion/repeater

/obj/item/microfusion_gun_attachment/repeater/run_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.recoil += recoil_to_add
	microfusion_gun.burst_size += burst_to_add
	microfusion_gun.fire_delay += delay_to_add
	microfusion_gun.spread += spread_to_add

/obj/item/microfusion_gun_attachment/repeater/remove_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.recoil -= recoil_to_add
	microfusion_gun.burst_size -= burst_to_add
	microfusion_gun.fire_delay -= delay_to_add
	microfusion_gun.spread -= spread_to_add

/obj/item/microfusion_gun_attachment/repeater/process_fire(obj/item/gun/microfusion/microfusion_gun, obj/item/ammo_casing/chambered)
	. = ..()
	chambered.loaded_projectile = new projectile_override
/*
FOCUSED REPEATER ATTACHMENT

The gun can fire volleys of shots that penetrate armor.
*/
/obj/item/microfusion_gun_attachment/penetrator
	name = "focused repeating phase emitter upgrade"
	desc = "A focused variant of the repeating phase controller. It allows the lasers to penetrate armor however this results in higher power usage."
	icon_state = "attachment_penetrator"
	attachment_overlay_icon_state = "attachment_penetrator"
	heat_addition = 40
	power_usage = 20
	slot = GUN_SLOT_BARREL
	/// The spread to add to the gun.
	var/spread_to_add = 15
	/// The recoil to add to the gun.
	var/recoil_to_add = 1
	/// The burst to add to the gun.
	var/burst_to_add = 1
	/// The delay to add to the firing.
	var/delay_to_add = 5
	var/projectile_override =/obj/projectile/beam/laser/microfusion/penetrator
	power_usage = 80 // A price to pay to penetrate through armor

/obj/item/microfusion_gun_attachment/penetrator/run_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.recoil += recoil_to_add
	microfusion_gun.burst_size += burst_to_add
	microfusion_gun.fire_delay += delay_to_add
	microfusion_gun.spread += spread_to_add

/obj/item/microfusion_gun_attachment/penetrator/remove_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.recoil -= recoil_to_add
	microfusion_gun.burst_size -= burst_to_add
	microfusion_gun.fire_delay -= delay_to_add
	microfusion_gun.spread -= spread_to_add

/obj/item/microfusion_gun_attachment/penetrator/process_fire(obj/item/gun/microfusion/microfusion_gun, obj/item/ammo_casing/chambered)
	. = ..()
	chambered.loaded_projectile = new projectile_override


/*
X-RAY ATTACHMENT

The gun can fire X-RAY shots.
*/
/obj/item/microfusion_gun_attachment/xray
	name = "quantum phase inverter array" //Yes quantum makes things sound cooler.
	desc = "An experimental barrel attachment that modifies the central phase emitter, causing the wave frequency to shift into X-ray. Capable of penetrating both glass and solid matter with ease, though the bolts don't carry a greater effect against armor, due to going through the target and doing more minimal internal damage. These attachments are power-hungry and overheat easily, though engineers have deemed the costs necessary drawbacks."
	icon_state = "attachment_xray"
	slot = GUN_SLOT_BARREL
	attachment_overlay_icon_state = "attachment_xray"
	heat_addition = 90
	power_usage = 50

/obj/item/microfusion_gun_attachment/xray/examine(mob/user)
	. = ..()
	. += span_warning("CAUTION: Phase emitter heats up extremely quickly, sustained fire not recommended!")

/obj/item/microfusion_gun_attachment/xray/run_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.fire_sound = 'modular_skyrat/modules/microfusion/sound/incinerate.ogg'

/obj/item/microfusion_gun_attachment/xray/remove_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.fire_sound = microfusion_gun.chambered?.fire_sound

/obj/item/microfusion_gun_attachment/xray/process_fire(obj/item/gun/microfusion/microfusion_gun, obj/item/ammo_casing/chambered)
	. = ..()
	chambered.loaded_projectile.icon_state = "laser_greyscale"
	chambered.loaded_projectile.color = COLOR_GREEN
	chambered.loaded_projectile.light_color = COLOR_GREEN
	chambered.loaded_projectile.projectile_piercing = PASSCLOSEDTURF|PASSGRILLE|PASSGLASS

/*
GRIP ATTACHMENT

Greatly reduces recoil and spread.
*/
/obj/item/microfusion_gun_attachment/grip
	name = "grip attachment"
	desc = "A simple grip that increases accuracy."
	icon_state = "attachment_grip"
	attachment_overlay_icon_state = "attachment_grip"
	slot = GUN_SLOT_UNDERBARREL
	/// How much recoil are we removing?
	var/recoil_to_remove = 1
	/// How much spread are we removing?
	var/spread_to_remove = 10

/obj/item/microfusion_gun_attachment/grip/run_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.recoil -= recoil_to_remove
	microfusion_gun.spread -= spread_to_remove

/obj/item/microfusion_gun_attachment/grip/remove_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.recoil += recoil_to_remove
	microfusion_gun.spread += spread_to_remove

/*
HEATSINK ATTACHMENT

"Greatly increases the phase emitter cooling rate."
*/
/obj/item/microfusion_gun_attachment/heatsink
	name = "phase emitter heatsink"
	desc = "Greatly increases the phase emitter cooling rate."
	icon_state = "attachment_heatsink"
	attachment_overlay_icon_state = "attachment_heatsink"
	slot = GUN_SLOT_UNDERBARREL
	/// Coolant bonus
	var/cooling_rate_increase = 50

/obj/item/microfusion_gun_attachment/heatsink/run_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.heat_dissipation_bonus += cooling_rate_increase

/obj/item/microfusion_gun_attachment/heatsink/remove_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.heat_dissipation_bonus -= cooling_rate_increase


/*
RGB ATTACHMENT

Enables you to change the light color of the laser.
*/
/obj/item/microfusion_gun_attachment/rgb
	name = "phase emitter spectrograph"
	desc = "An attachment hooked up to the phase emitter, allowing the user to adjust the color of the beam outputted. This has seen widespread use by various factions capable of getting their hands on microfusion weapons, whether as a calling card or simply for entertainment."
	icon_state = "attachment_rgb"
	attachment_overlay_icon_state = "attachment_rgb"
	/// What color are we changing the sprite to?
	var/color_to_apply = COLOR_MOSTLY_PURE_RED

/obj/item/microfusion_gun_attachment/rgb/process_fire(obj/item/gun/microfusion/microfusion_gun, obj/item/ammo_casing/chambered)
	. = ..()
	chambered?.loaded_projectile.icon_state = "laser_greyscale"
	chambered?.loaded_projectile.color = color_to_apply
	chambered?.loaded_projectile.light_color = color_to_apply

/obj/item/microfusion_gun_attachment/rgb/proc/select_color(mob/living/user)
	var/new_color = input(user, "Please select your new projectile color", "Laser color", color_to_apply) as null|color

	if(!new_color)
		return

	color_to_apply = new_color

/obj/item/microfusion_gun_attachment/rgb/attack_self(mob/user, modifiers)
	. = ..()
	select_color(user)

/obj/item/microfusion_gun_attachment/rgb/get_modify_data()
	return list(list("title" = "Change Color", "icon" = "wrench", "reference" = "color", "color" = "blue"))

/obj/item/microfusion_gun_attachment/rgb/run_modify_data(params, mob/living/user)
	if(params == "color")
		select_color(user)

/*
RAIL ATTACHMENT

Allows for flashlights bayonets and adds 1 slot to equipment.
*/
/obj/item/microfusion_gun_attachment/rail
	name = "gun rail attachment"
	desc = "A simple set of rails that attaches to weapon hardpoints. Allows for 3 more attachment slots and the instillation of a flashlight or bayonet."
	icon_state = "attachment_rail"
	attachment_overlay_icon_state = "attachment_rail"
	slot = GUN_SLOT_RAIL

/obj/item/microfusion_gun_attachment/rail/run_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.can_flashlight = TRUE
	microfusion_gun.can_bayonet = TRUE

/obj/item/microfusion_gun_attachment/rail/remove_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.gun_light = initial(microfusion_gun.can_flashlight)
	if(microfusion_gun.gun_light)
		microfusion_gun.gun_light.forceMove(get_turf(microfusion_gun))
		microfusion_gun.clear_gunlight()
	microfusion_gun.can_bayonet = initial(microfusion_gun.can_bayonet)
	if(microfusion_gun.bayonet)
		microfusion_gun.bayonet.forceMove(get_turf(microfusion_gun))
		microfusion_gun.clear_bayonet()
	microfusion_gun.remove_all_attachments()

/*
SCOPE ATTACHMENT

Allows for a scope to be attached to the gun.
DANGER: SNOWFLAKE ZONE
*/
/obj/item/microfusion_gun_attachment/scope
	name = "scope attachment"
	desc = "A simple telescopic scope, allowing for long-ranged use of the weapon. However, these do not provide any night vision."
	icon_state = "attachment_scope"
	attachment_overlay_icon_state = "attachment_scope"
	slot = GUN_SLOT_RAIL

/obj/item/microfusion_gun_attachment/scope/run_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	if(microfusion_gun.GetComponent(/datum/component/scope))
		return
	microfusion_gun.AddComponent(/datum/component/scope, range_modifier = 1.5)
	microfusion_gun.update_action_buttons()

/obj/item/microfusion_gun_attachment/scope/remove_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	var/datum/component_datum = microfusion_gun.GetComponent(/datum/component/scope)
	if(component_datum)
		qdel(component_datum)
	microfusion_gun.update_action_buttons()

/*
BLACK CAMO ATTACHMENT

Allows for a black camo to be applied to the gun.
All tactical, all the time.
*/
/obj/item/microfusion_gun_attachment/black_camo
	name = "black camo microfusion frame"
	desc = "A frame modification for the MCR-01, changing the color of the gun to black."
	icon_state = "attachment_black"
	attachment_overlay_icon_state = "attachment_black"

/*
HONK CAMO ATTACHMENT

Allows for a clown camo to be applied to the gun.
HONK!!
*/
/obj/item/microfusion_gun_attachment/honk_camo
	name = "bananium microfusion frame"
	desc = "A frame modification for the MCR-01, plating the gun in bananium."
	icon_state = "attachment_honk_camo"
	attachment_overlay_icon_state = "attachment_honk_camo"

/*
SYNDIE CAMO ATTACHMENT

Allows for a blood red camo to be applied to the gun.
Totally not property of a hostile corporation.
*/
/obj/item/microfusion_gun_attachment/syndi_camo
	name = "blood red camo microfusion frame"
	desc = "A frame modification for the MCR-01, changing the color of the gun to a slick blood red."
	icon_state = "attachment_syndi_camo"
	attachment_overlay_icon_state = "attachment_syndi_camo"

/*
NANOTRASEN CAMO ATTACHMENT

Allows for an official blue camo to be applied to the gun.
Hail NanoTrasen.
*/
/obj/item/microfusion_gun_attachment/nt_camo
	name = "\improper NanoTrasen brand microfusion frame"
	desc = "A frame modification for the MCR-01, changing the color of the gun to blue."
	icon_state = "attachment_nt_camo"
	attachment_overlay_icon_state = "attachment_nt_camo"

/*
PULSE ATTACHMENT

The gun can fire PULSE shots.
*/
/obj/item/microfusion_gun_attachment/pulse
	name = "pulse induction carriage"
	desc = "A cutting-edge bluespace capacitor array and distributing lens overhaul produced in laboratories by Nanotrasen scientists that allow microfusion rifles to fire military-grade pulse rounds. Comes equipped with cyclic cooling to ensure maximum combat efficiency, a munitions counter, and an extra-secure drop cage for the power source. May shorten trigger lifetime."
	icon_state = "attachment_pulse"
	slot = GUN_SLOT_BARREL
	attachment_overlay_icon_state = "attachment_pulse"
	heat_addition = 150
	power_usage = 50
	var/added_burst_size = 2
	var/added_fire_delay = 2

/obj/item/microfusion_gun_attachment/pulse/examine(mob/user)
	. = ..()
	. += span_warning("CAUTION: Phase emitter heats up extremely quickly, sustained fire not recommended!")

/obj/item/microfusion_gun_attachment/pulse/run_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.burst_size += added_burst_size
	microfusion_gun.fire_delay += added_fire_delay

/obj/item/microfusion_gun_attachment/pulse/remove_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.burst_size -= added_burst_size
	microfusion_gun.fire_delay -= added_fire_delay

/obj/item/microfusion_gun_attachment/pulse/process_fire(obj/item/gun/microfusion/microfusion_gun, obj/item/ammo_casing/chambered)
	. = ..()
	chambered.loaded_projectile = new /obj/projectile/beam/pulse

/*
SUPPRESSOR ATTACHMENT

Makes operators operate operatingly.
*/

/obj/item/microfusion_gun_attachment/suppressor
	name = "laser suppressor" // sure it makes no sense but its cool
	desc = "An experimental barrel attachment that dampens the soundwave of the emitter, making the laser shots far more stealthy. Best paired with black camo."
	icon_state = "attachment_suppressor"
	slot = GUN_SLOT_BARREL
	attachment_overlay_icon_state = "attachment_suppressor"

/obj/item/microfusion_gun_attachment/suppressor/run_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.suppressed = TRUE

/obj/item/microfusion_gun_attachment/suppressor/remove_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.suppressed = null

/*
BIKEHORN ATTACHMENT

HONK!! Does subpar stamina damage but slips people.
*/

/obj/item/microfusion_gun_attachment/honk
	name = "bananium phase emitter upgrade"
	desc = "An honksperimental barrel attachment that makes your lasers funnier."
	icon_state = "attachment_honk"
	incompatable_attachments = list(/obj/item/microfusion_gun_attachment/scatter, /obj/item/microfusion_gun_attachment/scattermax)
	slot = GUN_SLOT_BARREL
	attachment_overlay_icon_state = "attachment_honk"
	var/added_fire_delay = 20

/obj/item/microfusion_gun_attachment/honk/examine(mob/user)
	. = ..()
	. += span_warning("CAUTION: The gun you are about to handle is extremely funny!")

/obj/item/microfusion_gun_attachment/honk/run_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.fire_sound = 'sound/items/bikehorn.ogg'
	microfusion_gun.fire_delay += added_fire_delay

/obj/item/microfusion_gun_attachment/honk/remove_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.fire_sound = microfusion_gun.chambered?.fire_sound
	microfusion_gun.fire_delay += added_fire_delay

/obj/item/microfusion_gun_attachment/honk/process_fire(obj/item/gun/microfusion/microfusion_gun, obj/item/ammo_casing/chambered)
	. = ..()
	chambered.loaded_projectile.icon_state = "laser_greyscale"
	chambered.loaded_projectile.color = COLOR_VIVID_YELLOW
	chambered.loaded_projectile.light_color = COLOR_VIVID_YELLOW
	chambered.loaded_projectile.damage_type = STAMINA
	chambered.loaded_projectile.damage = 20
	chambered.loaded_projectile.armor_flag = ENERGY
	chambered.loaded_projectile.AddComponent(/datum/component/slippery, 20)
	chambered.loaded_projectile.hitsound = 'sound/misc/slip.ogg'
	chambered.loaded_projectile.impact_type = /obj/effect/projectile/impact/disabler

/*
LANCE ATTACHMENT

The gun fires fast heavy lasers but takes a long time to fire.
*/
/obj/item/microfusion_gun_attachment/lance
	name = "lance induction carriage"
	desc = "A modification kit that turns the MCR into a designated marksman rifle. Fired beams boast greater firepower and speed however it is very draining on battery as well as generates an extreme amount of heat."
	icon = 'icons/obj/improvised.dmi'
	icon_state = "kitsuitcase"
	incompatable_attachments = list(/obj/item/microfusion_gun_attachment/black_camo, /obj/item/microfusion_gun_attachment/nt_camo, /obj/item/microfusion_gun_attachment/honk_camo)
	slot = GUN_SLOT_BARREL
	attachment_overlay_icon_state = "attachment_lance"
	heat_addition = 150
	power_usage = 100
	var/added_fire_delay = 25

/obj/item/microfusion_gun_attachment/lance/examine(mob/user)
	. = ..()
	. += span_warning("CAUTION: Phase emitter heats up extremely quickly!")

/obj/item/microfusion_gun_attachment/lance/run_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.fire_delay += added_fire_delay
	microfusion_gun.fire_sound = 'sound/weapons/lasercannonfire.ogg'

/obj/item/microfusion_gun_attachment/lance/remove_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.fire_delay -= added_fire_delay
	microfusion_gun.fire_sound = microfusion_gun.chambered?.fire_sound

/obj/item/microfusion_gun_attachment/lance/process_fire(obj/item/gun/microfusion/microfusion_gun, obj/item/ammo_casing/chambered)
	. = ..()
	chambered.loaded_projectile = new /obj/projectile/beam/laser/microfusion/lance
