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
	/// Any incompatible upgrade types.
	var/list/incompatible_attachments = list()
	/// The added heat produced by having this module installed.
	var/heat_addition = 0
	/// The slot this attachment is installed in.
	var/slot = GUN_SLOT_UNIQUE
	/// How much extra power do we use?
	var/power_usage = 0
	/// Spread adjustment. Moved up to the base attachment type because of barrel mods and grips being in separate slots.
	var/spread_adjust
	/// Recoil adjustment. Also moved up to base attachment because of barrel mods and grips being in separate slots.
	var/recoil_adjust

/obj/item/microfusion_gun_attachment/examine(mob/user)
	. = ..()
	. += "Compatible slot: <b>[slot]</b>."

/obj/item/microfusion_gun_attachment/proc/run_attachment(obj/item/gun/microfusion/microfusion_gun)
	SHOULD_CALL_PARENT(TRUE)
	microfusion_gun.heat_per_shot += heat_addition
	microfusion_gun.update_appearance()
	microfusion_gun.extra_power_usage += power_usage
	microfusion_gun.chambered?.refresh_shot()
	if(spread_adjust)
		microfusion_gun.attachment_spread += spread_adjust
		microfusion_gun.recalculate_spread()
	if(recoil_adjust)
		microfusion_gun.attachment_recoil += recoil_adjust
		microfusion_gun.recalculate_recoil()
	return

/obj/item/microfusion_gun_attachment/proc/process_attachment(obj/item/gun/microfusion/microfusion_gun, seconds_per_tick)
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
	if(spread_adjust)
		microfusion_gun.attachment_spread -= spread_adjust
		microfusion_gun.recalculate_spread()
	if(recoil_adjust)
		microfusion_gun.attachment_recoil -= recoil_adjust
		microfusion_gun.recalculate_recoil()
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

// base type for the barrel mods because i got Really Tired of re-re-redefined variables
/obj/item/microfusion_gun_attachment/barrel
	slot = GUN_SLOT_BARREL
	/// If this isn't null, we're replacing our next loaded projectile with this type.
	var/projectile_override
	/// If this isn't null, on attachment, this becomes the new fire sound.
	var/new_fire_sound
	/// If this isn't null or zero, adds this fire delay to the gun.
	var/delay_to_add
	/// If this isn't null or zero, adds this burst to the gun's burst size.
	var/burst_to_add

/obj/item/microfusion_gun_attachment/barrel/process_fire(obj/item/gun/microfusion/microfusion_gun, obj/item/ammo_casing/chambered)
	. = ..()
	if(projectile_override)
		chambered.loaded_projectile = new projectile_override

/obj/item/microfusion_gun_attachment/barrel/run_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	if(new_fire_sound)
		microfusion_gun.fire_sound = new_fire_sound
	if(delay_to_add)
		microfusion_gun.fire_delay += delay_to_add
	if(burst_to_add)
		microfusion_gun.burst_size += burst_to_add

/obj/item/microfusion_gun_attachment/barrel/remove_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	if(new_fire_sound)
		microfusion_gun.fire_sound = microfusion_gun.chambered?.fire_sound
	if(delay_to_add)
		microfusion_gun.fire_delay -= delay_to_add
	if(burst_to_add)
		microfusion_gun.burst_size -= burst_to_add

/*
SCATTER ATTACHMENT

Turns the gun into a shotgun.
*/
/obj/item/microfusion_gun_attachment/barrel/scatter
	name = "diffuser microfusion lens upgrade"
	desc = "A diffusing lens system capable of splitting one beam into three."
	icon_state = "attachment_scatter"
	attachment_overlay_icon_state = "attachment_scatter"
	slot = GUN_SLOT_BARREL
	projectile_override = /obj/projectile/beam/laser/microfusion/scatter
	/// How many pellets are we going to add to the existing amount on the gun?
	var/pellets_to_add = 2
	/// The variation in pellet scatter.
	var/variance_to_add = 20

/obj/item/microfusion_gun_attachment/barrel/scatter/run_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.microfusion_lens.pellets += pellets_to_add
	microfusion_gun.microfusion_lens.variance += variance_to_add

/obj/item/microfusion_gun_attachment/barrel/scatter/process_fire(obj/item/gun/microfusion/microfusion_gun, obj/item/ammo_casing/chambered)
	. = ..()
	chambered.loaded_projectile?.damage = chambered.loaded_projectile.damage / chambered.pellets

/obj/item/microfusion_gun_attachment/barrel/scatter/remove_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.microfusion_lens.pellets -= pellets_to_add
	microfusion_gun.microfusion_lens.variance -= variance_to_add

/*
CRYSTALLINE SCATTER ATTACHMENT

An overclocked shotgun.
*/

/obj/item/microfusion_gun_attachment/barrel/scatter/max
	name = "crystalline diffuser microfusion lens upgrade"
	desc = "An experimental diffusing lens system capable of splitting one beam into seven. However, it imparts recoil and causes an increased power draw."
	icon_state = "attachment_scattermax"
	attachment_overlay_icon_state = "attachment_scattermax"
	slot = GUN_SLOT_BARREL
	pellets_to_add = 6
	variance_to_add = 25
	recoil_adjust = 1
	spread_adjust = 15
	projectile_override = /obj/projectile/beam/laser/microfusion/scatter/max
	power_usage = 20

/*
SUPERHEAT ATTACHMENT

Lasers set the target on fire.
*/

/obj/item/microfusion_gun_attachment/barrel/superheat
	name = "superheating phase emitter upgrade"
	desc = "A barrel attachment hooked to the phase emitter, this adjusts the beam's wavelength to carry an intense wave of heat; causing targets to ignite."
	icon_state = "attachment_superheat"
	attachment_overlay_icon_state = "attachment_superheat"
	heat_addition = 90
	slot = GUN_SLOT_BARREL
	projectile_override = /obj/projectile/beam/laser/microfusion/superheated
	new_fire_sound = 'modular_skyrat/modules/microfusion/sound/vaporize.ogg'

/*
HELLFIRE ATTACHMENT

Makes the gun shoot hellfire lasers.
*/
/obj/item/microfusion_gun_attachment/barrel/hellfire
	name = "hellfire emitter upgrade"
	desc = "A barrel attachment hooked to the phase emitter, this adjusts the beam's wavelength to carry an extra wave of heat; causing nastier wounds and more damage."
	icon_state = "attachment_hellfire"
	attachment_overlay_icon_state = "attachment_hellfire"
	heat_addition = 50
	power_usage = 20
	slot = GUN_SLOT_BARREL
	projectile_override = /obj/projectile/beam/laser/microfusion/hellfire
	new_fire_sound = 'modular_skyrat/modules/microfusion/sound/melt.ogg'

/*
REPEATER ATTACHMENT

The gun can fire volleys of shots.
*/
/obj/item/microfusion_gun_attachment/barrel/repeater
	name = "repeating phase emitter upgrade"
	desc = "This barrel attachment upgrades the central phase emitter to fire off two beams in quick succession. While offering an increased rate of fire, the heat output and recoil rises too."
	icon_state = "attachment_repeater"
	attachment_overlay_icon_state = "attachment_repeater"
	heat_addition = 40
	slot = GUN_SLOT_BARREL
	spread_adjust = 15
	recoil_adjust = 1
	burst_to_add = 1
	delay_to_add = 5
	projectile_override = /obj/projectile/beam/laser/microfusion/repeater

/*
FOCUSED REPEATER ATTACHMENT

The gun can fire volleys of shots that penetrate armor.
*/

/obj/item/microfusion_gun_attachment/barrel/repeater/penetrator
	name = "focused repeating phase emitter upgrade"
	desc = "A focused variant of the repeating phase controller. It allows the lasers to penetrate armor however this results in higher power usage."
	icon_state = "attachment_penetrator"
	attachment_overlay_icon_state = "attachment_penetrator"
	power_usage = 20
	slot = GUN_SLOT_BARREL
	projectile_override = /obj/projectile/beam/laser/microfusion/penetrator
	power_usage = 80 // A price to pay to penetrate through armor

/*
X-RAY ATTACHMENT

The gun can fire X-RAY shots.
*/
/obj/item/microfusion_gun_attachment/barrel/xray
	name = "quantum phase inverter array" //Yes quantum makes things sound cooler.
	desc = "An experimental barrel attachment that modifies the central phase emitter, causing the wave frequency to shift into X-ray. \
	Capable of penetrating both glass and solid matter with ease; though, unlike a more traditional x-ray laser gun, \
	the bolts don't carry a greater effect against armor, due to going through the target and doing more minimal internal damage. \
	These attachments are power-hungry and overheat easily, though engineers have deemed the costs necessary drawbacks."
	icon_state = "attachment_xray"
	slot = GUN_SLOT_BARREL
	attachment_overlay_icon_state = "attachment_xray"
	heat_addition = 90
	power_usage = 50
	new_fire_sound = 'modular_skyrat/modules/microfusion/sound/incinerate.ogg'
	projectile_override = /obj/projectile/beam/laser/microfusion/xray

/obj/item/microfusion_gun_attachment/barrel/xray/examine(mob/user)
	. = ..()
	. += span_warning("CAUTION: Phase emitter heats up extremely quickly, sustained fire not recommended!")

/*
SUPPRESSOR ATTACHMENT

Makes operators operate operatingly.
*/

/obj/item/microfusion_gun_attachment/barrel/suppressor
	name = "laser suppressor" // sure it makes no sense but its cool
	desc = "An experimental barrel attachment that dampens the soundwave of the emitter, making the laser shots far more stealthy. Best paired with black camo."
	icon_state = "attachment_suppressor"
	slot = GUN_SLOT_BARREL
	attachment_overlay_icon_state = "attachment_suppressor"

/obj/item/microfusion_gun_attachment/barrel/suppressor/run_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.suppressed = TRUE

/obj/item/microfusion_gun_attachment/barrel/suppressor/remove_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.suppressed = null

/*
BIKEHORN ATTACHMENT

HONK!! Does subpar stamina damage but slips people.
*/

/obj/item/microfusion_gun_attachment/barrel/honk
	name = "bananium phase emitter upgrade"
	desc = "An honksperimental barrel attachment that makes your lasers funnier."
	icon_state = "attachment_honk"
	attachment_overlay_icon_state = "attachment_honk"
	delay_to_add = 2 SECONDS
	new_fire_sound = 'sound/items/bikehorn.ogg'
	projectile_override = /obj/projectile/beam/laser/microfusion/honk

/obj/item/microfusion_gun_attachment/barrel/honk/examine(mob/user)
	. = ..()
	. += span_warning("CAUTION: The gun you are about to handle is extremely funny!")

/*
LANCE ATTACHMENT

The gun fires fast heavy lasers but takes a long time to fire.
*/
/obj/item/microfusion_gun_attachment/barrel/lance
	name = "lance induction carriage"
	desc = "A modification kit that turns the MCR into a designated marksman rifle. Fired beams boast greater firepower and speed, \
	but the enhanced throughput is very draining on the cell, as well as generating an extreme amount of heat. \
	Users are advised to make their shots count."
	icon = 'icons/obj/weapons/improvised.dmi'
	icon_state = "kitsuitcase"
	incompatible_attachments = list(/obj/item/microfusion_gun_attachment/camo, /obj/item/microfusion_gun_attachment/camo/nanotrasen, /obj/item/microfusion_gun_attachment/camo/honk)
	attachment_overlay_icon_state = "attachment_lance"
	heat_addition = 150
	power_usage = 100
	delay_to_add = 2.5 SECONDS
	new_fire_sound = 'sound/weapons/lasercannonfire.ogg'
	projectile_override = /obj/projectile/beam/laser/microfusion/lance

/obj/item/microfusion_gun_attachment/barrel/lance/examine(mob/user)
	. = ..()
	. += span_warning("CAUTION: Phase emitter heats up extremely quickly!")

/*
PULSE ATTACHMENT

The gun can fire PULSE shots.
*/
/obj/item/microfusion_gun_attachment/barrel/pulse
	name = "pulse induction carriage"
	desc = "A cutting-edge bluespace capacitor array and distributing lens overhaul produced in laboratories by Nanotrasen scientists that allow microfusion rifles to fire military-grade pulse rounds. Comes equipped with cyclic cooling to ensure maximum combat efficiency, a munitions counter, and an extra-secure drop cage for the power source. May shorten trigger lifetime."
	icon_state = "attachment_pulse"
	attachment_overlay_icon_state = "attachment_pulse"
	heat_addition = 150
	power_usage = 50
	projectile_override = /obj/projectile/beam/pulse
	burst_to_add = 2
	delay_to_add = 2

/obj/item/microfusion_gun_attachment/barrel/pulse/examine(mob/user)
	. = ..()
	. += span_warning("CAUTION: Phase emitter heats up extremely quickly, sustained fire not recommended!")

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
	spread_adjust = -10
	recoil_adjust = -1

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
	/// Cooling bonus.
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
	microfusion_gun.AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'modular_skyrat/modules/microfusion/icons/microfusion_gun40x32.dmi', \
		light_overlay = "flight")
	microfusion_gun.can_bayonet = TRUE

/obj/item/microfusion_gun_attachment/rail/remove_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	var/component_to_delete = microfusion_gun.GetComponent(/datum/component/seclite_attachable)
	if(component_to_delete)
		qdel(component_to_delete)
	microfusion_gun.can_bayonet = initial(microfusion_gun.can_bayonet)
	if(microfusion_gun.bayonet)
		microfusion_gun.bayonet.forceMove(get_turf(microfusion_gun))
		microfusion_gun.bayonet = null
		microfusion_gun.update_appearance()
	microfusion_gun.remove_all_attachments()

/*
SCOPE ATTACHMENT

Allows for a scope to be attached to the gun.
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

/obj/item/microfusion_gun_attachment/scope/remove_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	var/datum/component_datum = microfusion_gun.GetComponent(/datum/component/scope)
	if(component_datum)
		qdel(component_datum)

/*
BLACK CAMO ATTACHMENT

Allows for a black camo to be applied to the gun.
All tactical, all the time.
*/

/obj/item/microfusion_gun_attachment/camo
	name = "black camo microfusion frame"
	desc = "A frame modification for the MCR-01, changing the color of the gun to black."
	slot = GUN_SLOT_CAMO
	icon_state = "attachment_black"
	attachment_overlay_icon_state = "attachment_black"

/*
HONK CAMO ATTACHMENT

Allows for a clown camo to be applied to the gun.
HONK!!
*/
/obj/item/microfusion_gun_attachment/camo/honk
	name = "bananium microfusion frame"
	desc = "A frame modification for the MCR-01, plating the gun in bananium."
	icon_state = "attachment_honk_camo"
	attachment_overlay_icon_state = "attachment_honk_camo"

/*
SYNDIE CAMO ATTACHMENT

Allows for a blood red camo to be applied to the gun.
Totally not property of a hostile corporation.
*/
/obj/item/microfusion_gun_attachment/camo/syndicate
	name = "blood red camo microfusion frame"
	desc = "A frame modification for the MCR-01, changing the color of the gun to a slick blood red."
	icon_state = "attachment_syndi_camo"
	attachment_overlay_icon_state = "attachment_syndi_camo"

/*
NANOTRASEN CAMO ATTACHMENT

Allows for an official blue camo to be applied to the gun.
Hail Nanotrasen.
*/
/obj/item/microfusion_gun_attachment/camo/nanotrasen
	name = "\improper Nanotrasen brand microfusion frame"
	desc = "A frame modification for the MCR-01, changing the color of the gun to blue."
	icon_state = "attachment_nt_camo"
	attachment_overlay_icon_state = "attachment_nt_camo"
