//Ninja modules for MODsuits

///Cloaking - Lowers the user's visibility, can be interrupted by being touched or attacked.
/obj/item/mod/module/stealth
	name = "MOD prototype cloaking module"
	desc = "A complete retrofitting of the suit, this is a form of visual concealment tech employing esoteric technology \
		to bend light around the user, as well as mimetic materials to make the surface of the suit match the \
		surroundings based off sensor data. For some reason, this tech is rarely seen."
	icon_state = "cloak"
	module_type = MODULE_TOGGLE
	complexity = 4
	active_power_cost = DEFAULT_CHARGE_DRAIN * 2
	use_power_cost = DEFAULT_CHARGE_DRAIN * 10
	incompatible_modules = list(/obj/item/mod/module/stealth)
	cooldown_time = 5 SECONDS
	/// Whether or not the cloak turns off on bumping.
	var/bumpoff = TRUE
	/// The alpha applied when the cloak is on.
	var/stealth_alpha = 50

/obj/item/mod/module/stealth/on_activation()
	. = ..()
	if(!.)
		return
	if(bumpoff)
		RegisterSignal(mod.wearer, COMSIG_LIVING_MOB_BUMP, .proc/unstealth)
	RegisterSignal(mod.wearer, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, .proc/on_unarmed_attack)
	RegisterSignal(mod.wearer, COMSIG_ATOM_BULLET_ACT, .proc/on_bullet_act)
	RegisterSignal(mod.wearer, list(COMSIG_ITEM_ATTACK, COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_HITBY, COMSIG_ATOM_HULK_ATTACK, COMSIG_ATOM_ATTACK_PAW, COMSIG_CARBON_CUFF_ATTEMPTED), .proc/unstealth)
	animate(mod.wearer, alpha = stealth_alpha, time = 1.5 SECONDS)
	drain_power(use_power_cost)

/obj/item/mod/module/stealth/on_deactivation(display_message = TRUE, deleting = FALSE)
	. = ..()
	if(!.)
		return
	if(bumpoff)
		UnregisterSignal(mod.wearer, COMSIG_LIVING_MOB_BUMP)
	UnregisterSignal(mod.wearer, list(COMSIG_HUMAN_MELEE_UNARMED_ATTACK, COMSIG_ITEM_ATTACK, COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_BULLET_ACT, COMSIG_ATOM_HITBY, COMSIG_ATOM_HULK_ATTACK, COMSIG_ATOM_ATTACK_PAW, COMSIG_CARBON_CUFF_ATTEMPTED))
	animate(mod.wearer, alpha = 255, time = 1.5 SECONDS)

/obj/item/mod/module/stealth/proc/unstealth(datum/source)
	SIGNAL_HANDLER

	to_chat(mod.wearer, span_warning("[src] gets discharged from contact!"))
	do_sparks(2, TRUE, src)
	drain_power(use_power_cost)
	on_deactivation(display_message = TRUE, deleting = FALSE)

/obj/item/mod/module/stealth/proc/on_unarmed_attack(datum/source, atom/target)
	SIGNAL_HANDLER

	if(!isliving(target))
		return
	unstealth(source)

/obj/item/mod/module/stealth/proc/on_bullet_act(datum/source, obj/projectile/projectile)
	SIGNAL_HANDLER

	if(projectile.nodamage)
		return
	unstealth(source)

//Advanced Cloaking - Doesn't turf off on bump, less power drain, more stealthy.
/obj/item/mod/module/stealth/ninja
	name = "MOD advanced cloaking module"
	desc = "The latest in stealth technology, this module is a definite upgrade over previous versions. \
		The field has been tuned to be even more responsive and fast-acting, with enough stability to \
		continue operation of the field even if the user bumps into others. \
		The power draw has been reduced drastically, making this perfect for activities like \
		standing near sentry turrets for extended periods of time."
	icon_state = "cloak_ninja"
	bumpoff = FALSE
	stealth_alpha = 20
	active_power_cost = DEFAULT_CHARGE_DRAIN
	use_power_cost = DEFAULT_CHARGE_DRAIN * 5
	cooldown_time = 3 SECONDS

///Camera Vision - Prevents flashes, blocks tracking.
/obj/item/mod/module/welding/camera_vision
	name = "MOD camera vision module"
	desc = "A module installed into the suit's helmet. This replaces the standard visor with a set of camera eyes, \
		which protect from bright flashes as well as using special track-blocking technology. Become the unseen."
	removable = FALSE
	complexity = 0
	overlay_state_inactive = null

/obj/item/mod/module/welding/camera_vision/on_suit_activation()
	. = ..()
	RegisterSignal(mod.wearer, COMSIG_LIVING_CAN_TRACK, .proc/can_track)

/obj/item/mod/module/welding/camera_vision/on_suit_deactivation(deleting = FALSE)
	. = ..()
	UnregisterSignal(mod.wearer, COMSIG_LIVING_CAN_TRACK)

/obj/item/mod/module/welding/camera_vision/proc/can_track(datum/source, mob/user)
	SIGNAL_HANDLER

	return COMPONENT_CANT_TRACK

//Ninja Star Dispenser - Dispenses ninja stars.
/obj/item/mod/module/dispenser/ninja
	name = "MOD ninja star dispenser module"
	desc = "This piece of Spider Clan technology can immediately print a ninja-star using pure electricity."
	dispense_type = /obj/item/throwing_star/stamina/ninja
	cooldown_time = 0.5 SECONDS

///Hacker - This module overrides
/obj/item/mod/module/hacker

/**
 * # Ninja Gloves
 *
 * Space ninja's gloves.  Gives access to a number of special interactions.
 *
 * Gloves only found from space ninjas.  Allows the wearer to access special interactions with various objects.
 * These interactions are detailed in ninjaDrainAct.dm in the suit file.
 * These interactions are toggled by an action tied to the gloves.  The interactions will not activate if the user is also not wearing a ninja suit.
 *
 */
/obj/item/clothing/gloves/space_ninja
	desc = "These nano-enhanced gloves insulate from electricity and provide fire resistance."
	name = "ninja gloves"
	icon_state = "black"
	inhand_icon_state = "s-ninjan"
	siemens_coefficient = 0
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	strip_delay = 120
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	armor = list(MELEE = 40, BULLET = 30, LASER = 20, ENERGY = 15, BOMB = 30, BIO = 100, FIRE = 100, ACID = 100)
	///Whether or not we're currently draining something
	var/draining = FALSE
	///Minimum amount of power we can drain in a single drain action
	var/mindrain = 200
	///Maximum amount of power we can drain in a single drain action
	var/maxdrain = 400
	///Whether or not the communication console hack was used to summon another antagonist
	var/communication_console_hack_success = FALSE
	///How many times the gloves have been used to force open doors.
	var/door_hack_counter = 0


/obj/item/clothing/gloves/space_ninja/Touch(atom/A,proximity,modifiers)
	if(!LAZYACCESS(modifiers, RIGHT_CLICK) || draining)
		return FALSE
	if(!ishuman(loc))
		return FALSE //Only works while worn

	var/mob/living/carbon/human/wearer = loc

	var/obj/item/clothing/suit/space/space_ninja/suit = wearer.wear_suit
	if(!istype(suit))
		return FALSE
	if(isturf(A))
		return FALSE

	if(!proximity)
		return FALSE

	A.add_fingerprint(wearer)

	draining = TRUE
	. = A.ninjadrain_act(suit,wearer,src)
	draining = FALSE

	if(isnum(.)) //Numerical values of drained handle their feedback here, Alpha values handle it themselves (Research hacking)
		if(.)
			to_chat(wearer, span_notice("Gained <B>[display_energy(.)]</B> of energy from [A]."))
		else
			to_chat(wearer, span_danger("\The [A] has run dry of energy, you must find another source!"))
	else
		. = FALSE //as to not cancel attack_hand()

/obj/item/clothing/gloves/space_ninja/examine(mob/user)
	. = ..() + "[p_their(TRUE)] energy drain mechanism is activated by touching objects in a disarming manner."

