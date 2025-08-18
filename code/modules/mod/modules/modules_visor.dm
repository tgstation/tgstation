//Visor modules for MODsuits

///Base Visor - Adds a specific HUD and traits to you.
/obj/item/mod/module/visor
	name = "MOD visor module"
	desc = "A heads-up display installed into the visor of the suit. They say these also let you see behind you."
	module_type = MODULE_TOGGLE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/visor)
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_EYES|ITEM_SLOT_MASK)
	/// The traits given by the visor.
	var/list/visor_traits = list()

/obj/item/mod/module/visor/on_activation()
	if(length(visor_traits))
		mod.wearer.add_traits(visor_traits, REF(src))
	mod.wearer.update_sight()

/obj/item/mod/module/visor/on_deactivation(display_message = TRUE, deleting = FALSE)
	if(length(visor_traits))
		mod.wearer.remove_traits(visor_traits, REF(src))
	mod.wearer.update_sight()

//Medical Visor - Gives you a medical HUD.
/obj/item/mod/module/visor/medhud
	name = "MOD medical visor module"
	desc = "A heads-up display installed into the visor of the suit. This cross-references suit sensor data with a modern \
		biological scanning suite, allowing the user to visualize the current health of organic lifeforms, as well as \
		access data such as patient files in a convenient readout. They say these also let you see behind you."
	icon_state = "medhud_visor"
	visor_traits = list(TRAIT_MEDICAL_HUD)

//Diagnostic Visor - Gives you a diagnostic HUD.
/obj/item/mod/module/visor/diaghud
	name = "MOD diagnostic visor module"
	desc = "A heads-up display installed into the visor of the suit. This uses a series of advanced sensors to access data \
		from advanced machinery, exosuits, and other devices, allowing the user to visualize current power levels \
		and integrity of such. They say these also let you see behind you."
	icon_state = "diaghud_visor"
	visor_traits = list(TRAIT_DIAGNOSTIC_HUD, TRAIT_BOT_PATH_HUD)

//Security Visor - Gives you a security HUD.
/obj/item/mod/module/visor/sechud
	name = "MOD security visor module"
	desc = "A heads-up display installed into the visor of the suit. This module is a heavily-retrofitted targeting system, \
		plugged into various criminal databases to be able to view arrest records, command simple security-oriented robots, \
		and generally know who to shoot. They say these also let you see behind you."
	icon_state = "sechud_visor"
	visor_traits = list(TRAIT_SECURITY_HUD)

//Meson Visor - Gives you meson vision.
/obj/item/mod/module/visor/meson
	name = "MOD meson visor module"
	desc = "A heads-up display installed into the visor of the suit. This module is based off well-loved meson scanner \
		technology, used by construction workers and miners across the galaxy to see basic structural and terrain layouts \
		through walls, regardless of lighting conditions. They say these also let you see behind you."
	icon_state = "meson_visor"
	visor_traits = list(TRAIT_MESON_VISION, TRAIT_MADNESS_IMMUNE)

//Thermal Visor - Gives you thermal vision.
/obj/item/mod/module/visor/thermal
	name = "MOD thermal visor module"
	desc = "A heads-up display installed into the visor of the suit. This uses a small IR scanner to detect and identify \
		the thermal radiation output of objects near the user. While it can detect the heat output of even something as \
		small as a rodent, it still produces irritating red overlay. They say these also let you see behind you."
	icon_state = "thermal_visor"
	visor_traits = list(TRAIT_THERMAL_VISION)

//Night Visor - Gives you night vision.
/obj/item/mod/module/visor/night
	name = "MOD night visor module"
	desc = "A heads-up display installed into the visor of the suit. Typical for both civilian and military applications, \
		this allows the user to perceive their surroundings while in complete darkness, enhancing the view by tenfold; \
		yet brightening everything into a spooky green glow. They say these also let you see behind you."
	icon_state = "night_visor"
	incompatible_modules = list(/obj/item/mod/module/visor, /obj/item/mod/module/night)
	visor_traits = list(TRAIT_TRUE_NIGHT_VISION)

/obj/item/mod/module/night // Not Visor type so that it remains compatible with other visors
	name = "MOD night vision module"
	desc = "A heads-up display installed into the visor of the suit. Typical for both civilian and military applications, \
		this allows the user to perceive their surroundings while in complete darkness, enhancing the view by tenfold; \
		yet brightening everything into a spooky green glow. They say these also let you see behind you. \
		These ones are a special version which remain compatible with the other visor modules."
	icon_state = "night_visor"
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.1
	complexity = 0
	removable = FALSE
	module_type = MODULE_TOGGLE
	incompatible_modules = list(/obj/item/mod/module/night, /obj/item/mod/module/visor/night)
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_EYES|ITEM_SLOT_MASK)

/obj/item/mod/module/night/on_activation()
	ADD_TRAIT(mod.wearer, TRAIT_TRUE_NIGHT_VISION, REF(src))
	mod.wearer.update_sight()

/obj/item/mod/module/night/on_deactivation(display_message = TRUE, deleting = FALSE)
	REMOVE_TRAIT(mod.wearer, TRAIT_TRUE_NIGHT_VISION, REF(src))
	mod.wearer.update_sight()
