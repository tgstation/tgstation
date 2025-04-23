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
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 10
	incompatible_modules = list(/obj/item/mod/module/stealth)
	cooldown_time = 5 SECONDS
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_MASK, ITEM_SLOT_OCLOTHING|ITEM_SLOT_ICLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET)
	/// Whether or not the cloak turns off on bumping.
	var/bumpoff = TRUE
	/// The alpha applied when the cloak is on.
	var/stealth_alpha = 50

/obj/item/mod/module/stealth/on_activation()
	if(bumpoff)
		RegisterSignal(mod.wearer, COMSIG_LIVING_MOB_BUMP, PROC_REF(unstealth))
	RegisterSignal(mod.wearer, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))
	RegisterSignal(mod.wearer, COMSIG_ATOM_BULLET_ACT, PROC_REF(on_bullet_act))
	RegisterSignals(mod.wearer, list(COMSIG_MOB_ITEM_ATTACK, COMSIG_ATOM_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_HITBY, COMSIG_ATOM_HULK_ATTACK, COMSIG_ATOM_ATTACK_PAW, COMSIG_CARBON_CUFF_ATTEMPTED), PROC_REF(unstealth))
	animate(mod.wearer, alpha = stealth_alpha, time = 1.5 SECONDS)
	drain_power(use_energy_cost)

/obj/item/mod/module/stealth/on_deactivation(display_message = TRUE, deleting = FALSE)
	if(bumpoff)
		UnregisterSignal(mod.wearer, COMSIG_LIVING_MOB_BUMP)
	UnregisterSignal(mod.wearer, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_MOB_ITEM_ATTACK, COMSIG_ATOM_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_BULLET_ACT, COMSIG_ATOM_HITBY, COMSIG_ATOM_HULK_ATTACK, COMSIG_ATOM_ATTACK_PAW, COMSIG_CARBON_CUFF_ATTEMPTED))
	animate(mod.wearer, alpha = 255, time = 1.5 SECONDS)

/obj/item/mod/module/stealth/proc/unstealth(datum/source)
	SIGNAL_HANDLER

	to_chat(mod.wearer, span_warning("[src] gets discharged from contact!"))
	do_sparks(2, TRUE, src)
	drain_power(use_energy_cost)
	deactivate()

/obj/item/mod/module/stealth/proc/on_unarmed_attack(datum/source, atom/target)
	SIGNAL_HANDLER

	if(!isliving(target))
		return
	unstealth(source)

/obj/item/mod/module/stealth/proc/on_bullet_act(datum/source, obj/projectile/projectile)
	SIGNAL_HANDLER

	if(!projectile.is_hostile_projectile())
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
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 5
	cooldown_time = 3 SECONDS

/obj/item/mod/module/stealth/ninja/on_activation()
	. = ..()
	ADD_TRAIT(mod.wearer, TRAIT_SILENT_FOOTSTEPS, REF(src))

/obj/item/mod/module/stealth/ninja/on_deactivation(display_message = TRUE, deleting = FALSE)
	. = ..()
	REMOVE_TRAIT(mod.wearer, TRAIT_SILENT_FOOTSTEPS, REF(src))

///Camera Vision - Prevents flashes, blocks tracking.
/obj/item/mod/module/welding/camera_vision
	name = "MOD camera vision module"
	desc = "A module installed into the suit's helmet. This specialized piece of technology is built for subterfuge, \
		replacing the standard visor with a nanotech display; capable of displaying specialized imagery at \
		just the right frequency to jam all known forms of camera tracking and facial recognition, \
		as well as automatically dimming incoming flashes of light to protect the user's eyes. Become the unseen."
	icon_state = "welding_camera"
	removable = FALSE
	complexity = 0
	overlay_state_inactive = null
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_EYES|ITEM_SLOT_MASK)

/obj/item/mod/module/welding/camera_vision/on_part_activation()
	RegisterSignal(mod.wearer, COMSIG_LIVING_CAN_TRACK, PROC_REF(can_track))

/obj/item/mod/module/welding/camera_vision/on_part_deactivation(deleting = FALSE)
	UnregisterSignal(mod.wearer, COMSIG_LIVING_CAN_TRACK)

/obj/item/mod/module/welding/camera_vision/proc/can_track(datum/source, mob/user)
	SIGNAL_HANDLER

	return COMPONENT_CANT_TRACK

//Ninja Star Dispenser - Dispenses ninja stars.
/obj/item/mod/module/dispenser/ninja
	name = "MOD ninja star dispenser module"
	desc = "This piece of Spider Clan technology can exploit known energy-matter equivalence principles, \
		using the nanites already hosted in the wearer's suit to transmute into monomolecular shuriken. \
		While these lack the intense bleeding edge of conventional throwing stars, \
		they have been set to electrify fleeing targets; and branded with the Spider Clan symbol."
	dispense_type = /obj/item/throwing_star/stamina/ninja
	cooldown_time = 0.5 SECONDS

///Hacker - This module hooks onto your right-clicks with empty hands and causes ninja actions.
/obj/item/mod/module/hacker
	name = "MOD hacker module"
	desc = "Built for one purpose, electronic warfare, this module is built into the hands. \
		Using near-field communication alongside precise electro-stimulation of the wires in machines, \
		this decker's dream is normally used to pass through doors like a phantom. \
		It's also capable of non-precise electro-stimulation of an assassin-saboteur's opponents on disarming attacks."
	icon_state = "hacker"
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/hacker)
	required_slots = list(ITEM_SLOT_GLOVES)
	/// Whether or not the communication console hack was used to summon another antagonist.
	var/communication_console_hack_success = FALSE
	/// How many times the module has been used to force open doors.
	var/door_hack_counter = 0

/obj/item/mod/module/hacker/on_part_activation()
	RegisterSignal(mod.wearer, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(hack))

/obj/item/mod/module/hacker/on_part_deactivation(deleting = FALSE)
	UnregisterSignal(mod.wearer, COMSIG_LIVING_UNARMED_ATTACK)

/obj/item/mod/module/hacker/proc/hack(mob/living/carbon/human/source, atom/target, proximity, modifiers)
	SIGNAL_HANDLER

	if(!LAZYACCESS(modifiers, RIGHT_CLICK) || !proximity)
		return NONE
	target.add_fingerprint(mod.wearer)
	return target.ninjadrain_act(mod.wearer, src)

/obj/item/mod/module/hacker/proc/charge_message(atom/drained_atom, drain_amount)
	if(drain_amount)
		to_chat(mod.wearer, span_notice("Gained <B>[drain_amount]</B> units of energy from [drained_atom]."))
	else
		to_chat(mod.wearer, span_warning("[drained_atom] has run dry of energy, you must find another source!"))

///Weapon Recall - Teleports your katana to you, prevents gun use.
/obj/item/mod/module/weapon_recall
	name = "MOD weapon recall module"
	desc = "The cornerstone of a clanmember's life as a blademaster, and a module symbolizing their eternal bond with their weapon. \
		This hooks to the micro bluespace drive inside an energy katana's handle, capable of recalling it to the user's \
		skilled hands wherever they are. However, those that make such a bond with their weapon are cursed to \
		fusing their existence with acts of combat, with a singular purpose; Cutting Down Their Opponent. \
		Their hand a hand that is cutting, their body a body that is cutting, their mind, a mind that is cutting. \
		Ranged weapons are forbidden."
	icon_state = "recall"
	removable = FALSE
	module_type = MODULE_USABLE
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 2
	incompatible_modules = list(/obj/item/mod/module/weapon_recall)
	cooldown_time = 0.5 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES, ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	/// The item linked to the module that will get recalled.
	var/obj/item/linked_weapon
	/// The accepted typepath we can link to.
	var/accepted_type = /obj/item/energy_katana

/obj/item/mod/module/weapon_recall/on_part_activation()
	mod.wearer.add_traits(list(TRAIT_NOGUNS, TRAIT_TOSS_GUN_HARD), REF(src))

/obj/item/mod/module/weapon_recall/on_part_deactivation(deleting = FALSE)
	mod.wearer.remove_traits(list(TRAIT_NOGUNS, TRAIT_TOSS_GUN_HARD), REF(src))

/obj/item/mod/module/weapon_recall/on_use()
	if(!linked_weapon)
		var/obj/item/weapon_to_link = mod.wearer.is_holding_item_of_type(accepted_type)
		if(!weapon_to_link)
			balloon_alert(mod.wearer, "no linked weapon!")
			return
		set_weapon(weapon_to_link)
		balloon_alert(mod.wearer, "[linked_weapon.name] linked")
		return
	if(linked_weapon in mod.wearer.get_all_contents())
		balloon_alert(mod.wearer, "already on self!")
		return
	var/distance = get_dist(mod.wearer, linked_weapon)
	var/in_view = (linked_weapon in view(mod.wearer)) && !(linked_weapon in get_turf(mod.wearer))
	if(!in_view && !drain_power(use_energy_cost * distance))
		balloon_alert(mod.wearer, "not enough charge!")
		return
	linked_weapon.forceMove(linked_weapon.drop_location())
	if(in_view)
		do_sparks(5, FALSE, linked_weapon)
		mod.wearer.visible_message(span_danger("[linked_weapon] flies towards [mod.wearer]!"),span_warning("You hold out your hand and [linked_weapon] flies towards you!"))
		linked_weapon.throw_at(mod.wearer, distance+1, linked_weapon.throw_speed, mod.wearer)
	else
		recall_weapon()

/obj/item/mod/module/weapon_recall/proc/set_weapon(obj/item/weapon)
	linked_weapon = weapon
	RegisterSignal(linked_weapon, COMSIG_MOVABLE_PRE_IMPACT, PROC_REF(catch_weapon))
	RegisterSignal(linked_weapon, COMSIG_QDELETING, PROC_REF(deleted_weapon))

/obj/item/mod/module/weapon_recall/proc/recall_weapon(caught = FALSE)
	linked_weapon.forceMove(get_turf(src))
	var/alert = ""
	if(mod.wearer.put_in_hands(linked_weapon))
		alert = "[linked_weapon.name] teleports to your hand"
	else if(mod.wearer.equip_to_slot_if_possible(linked_weapon, ITEM_SLOT_BELT, disable_warning = TRUE))
		alert = "[linked_weapon.name] sheathes itself in your belt"
	else
		alert = "[linked_weapon.name] teleports under you"
	if(caught)
		if(mod.wearer.is_holding(linked_weapon))
			alert = "you catch [linked_weapon.name]"
		else
			alert = "[linked_weapon.name] lands under you"
	else
		do_sparks(5, FALSE, linked_weapon)
	if(alert)
		balloon_alert(mod.wearer, alert)

/obj/item/mod/module/weapon_recall/proc/catch_weapon(obj/item/source, atom/hit_atom, datum/thrownthing/thrownthing)
	SIGNAL_HANDLER

	if(!mod)
		return
	if(hit_atom != mod.wearer)
		return
	INVOKE_ASYNC(src, PROC_REF(recall_weapon), TRUE)
	return COMPONENT_MOVABLE_IMPACT_NEVERMIND

/obj/item/mod/module/weapon_recall/proc/deleted_weapon(obj/item/source)
	SIGNAL_HANDLER

	linked_weapon = null

//Reinforced DNA Lock - Gibs if wrong DNA, emp-proof.
/obj/item/mod/module/dna_lock/reinforced
	name = "MOD reinforced DNA lock module"
	desc = "A module which engages with the various locks and seals tied to the suit's systems, \
		enabling it to only be worn by someone corresponding with the user's exact DNA profile. \
		Due to utilizing a skintight dampening shield, this one is entirely sealed against electromagnetic interference; \
		it also dutifully protects the secrets of the Spider Clan from unknowing outsiders."
	icon_state = "dnalock_ninja"
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 0.5

/obj/item/mod/module/dna_lock/reinforced/on_mod_activation(datum/source, mob/user)
	. = ..()
	if(. != MOD_CANCEL_ACTIVATE || !isliving(user))
		return
	if(mod.ai_assistant == user)
		to_chat(mod.ai_assistant, span_danger("<B>fATaL EERRoR</B>: 381200-*#00CODE <B>BLUE</B>\nAI INTErFERenCE DEtECted\nACTi0N DISrEGArdED"))
		return
	var/mob/living/living_user = user
	to_chat(living_user, span_danger("<B>fATaL EERRoR</B>: 382200-*#00CODE <B>RED</B>\nUNAUTHORIZED USE DETECteD\nCoMMENCING SUB-R0UTIN3 13...\nTERMInATING U-U-USER..."))
	living_user.investigate_log("has been gibbed by using a MODsuit equipped with [src].", INVESTIGATE_DEATHS)
	living_user.gib(DROP_ALL_REMAINS)

/obj/item/mod/module/dna_lock/reinforced/on_emp(datum/source, severity)
	return

//EMP Pulse - In addition to normal shielding, can also launch an EMP itself.
/obj/item/mod/module/emp_shield/pulse
	name = "MOD EMP pulse module"
	desc = "This module is normally set to activate on dramatic gestures, inverting and expanding the suit's \
		EMP dampening shield to cause an electromagnetic pulse of its own. While this won't interfere with the wearer, \
		it will piss off everyone around them."
	icon_state = "emp_pulse"
	module_type = MODULE_USABLE
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 10
	cooldown_time = 8 SECONDS

/obj/item/mod/module/emp_shield/pulse/on_use()
	playsound(src, 'sound/effects/empulse.ogg', 60, TRUE)
	empulse(src, heavy_range = 4, light_range = 6)
	drain_power(use_energy_cost)

/// Ninja Status Readout - Like the normal status display (see the base type), but with a clock.
/obj/item/mod/module/status_readout/ninja
	name = "MOD Spider Clan status readout module"
	desc = "A once-common module, this technology unfortunately went out of fashion in the safer regions of space; \
		and, according to the extra markings on this particular unit's casing, right into the arachnid grip of the Spider Clan. \
		Like other similar units, this one hooks into the suit's spine, and is capable of capturing and displaying \
		all possible biometric data of the wearer; sleep, nutrition, fitness, fingerprints, \
		and even useful information such as their overall health and wellness. This one comes with a clock that calibrates to the \
		local system time, and an operational ID number display. The vital monitor's speaker has been removed."
	display_time = TRUE
	death_sound = null
	death_sound_volume = null

///Energy Net - Ensnares enemies in a net that prevents movement.
/obj/item/mod/module/energy_net
	name = "MOD energy net module"
	desc = "A custom-built net-thrower. While conventional implementations of this capturing device \
		utilize monomolecular fibers or cutting razorwire, this uses hardlight technology to deploy a \
		trapping field capable of immobilizing even the strongest opponents."
	icon_state = "energy_net"
	removable = FALSE
	module_type = MODULE_ACTIVE
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 6
	incompatible_modules = list(/obj/item/mod/module/energy_net)
	cooldown_time = 5 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES)
	/// List of all energy nets this module made.
	var/list/energy_nets = list()

/obj/item/mod/module/energy_net/on_part_deactivation(deleting)
	for(var/obj/structure/energy_net/net as anything in energy_nets)
		net.atom_destruction(ENERGY)

/obj/item/mod/module/energy_net/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(IS_SPACE_NINJA(mod.wearer) && isliving(target))
		mod.wearer.say("Get over here!", forced = type)
	var/obj/projectile/net = new /obj/projectile/energy_net(mod.wearer.loc, src)
	net.aim_projectile(target, mod.wearer)
	net.firer = mod.wearer
	playsound(src, 'sound/items/weapons/punchmiss.ogg', 25, TRUE)
	INVOKE_ASYNC(net, TYPE_PROC_REF(/obj/projectile, fire))
	drain_power(use_energy_cost)

/obj/item/mod/module/energy_net/proc/add_net(obj/structure/energy_net/net)
	energy_nets += net
	RegisterSignal(net, COMSIG_QDELETING, PROC_REF(remove_net))

/obj/item/mod/module/energy_net/proc/remove_net(obj/structure/energy_net/net)
	SIGNAL_HANDLER
	energy_nets -= net

/obj/projectile/energy_net
	name = "energy net"
	icon_state = "net_projectile"
	icon = 'icons/obj/clothing/modsuit/mod_modules.dmi'
	damage = 0
	range = 9
	hitsound = 'sound/items/fulton/fultext_deploy.ogg'
	hitsound_wall = 'sound/items/fulton/fultext_deploy.ogg'
	/// Reference to the beam following the projectile.
	var/line
	/// Reference to the energy net module.
	var/datum/weakref/net_module

/obj/projectile/energy_net/Initialize(mapload, net_module)
	. = ..()
	src.net_module = WEAKREF(net_module)

/obj/projectile/energy_net/fire(setAngle)
	if(firer)
		line = firer.Beam(src, "net_beam", 'icons/obj/clothing/modsuit/mod_modules.dmi')
	return ..()

/obj/projectile/energy_net/on_hit(mob/living/target, blocked = 0, pierce_hit)
	. = ..()
	if(!istype(target))
		return
	if(locate(/obj/structure/energy_net) in get_turf(target))
		return
	var/obj/structure/energy_net/net = new /obj/structure/energy_net(target.drop_location())
	var/obj/item/mod/module/energy_net/module = net_module?.resolve()
	if(module)
		module.add_net(net)
	firer?.visible_message(span_danger("[firer] caught [target] with an energy net!"), span_notice("You caught [target] with an energy net!"))
	if(target.buckled)
		target.buckled.unbuckle_mob(target, force = TRUE)
	net.buckle_mob(target, force = TRUE)

/obj/projectile/energy_net/Destroy()
	QDEL_NULL(line)
	return ..()

///Adrenaline Boost - Stops all stuns the ninja is affected with, increases his speed.
/obj/item/mod/module/adrenaline_boost
	name = "MOD adrenaline boost module"
	desc = "The secrets of the Spider Clan are many. The exact specifications of their suits, \
		the techniques they use to make every singular cut make their enemies weep with admiration, \
		but one of their greatest mysteries is the chemical compound their assassin-saboteurs use in times of need. \
		It's capable of clearing any fatigue whatsoever from the user, any immobilizing effect, and can even \
		cure total paralysis. All that's known is that the fluid requires radiation to properly 'cook,' \
		so this module demands radium to be refilled with."
	icon_state = "adrenaline_boost"
	removable = FALSE
	module_type = MODULE_USABLE
	allow_flags = MODULE_ALLOW_INCAPACITATED
	incompatible_modules = list(/obj/item/mod/module/adrenaline_boost)
	cooldown_time = 12 SECONDS
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	/// What reagent we need to refill?
	var/reagent_required = /datum/reagent/uranium/radium
	/// How much of a reagent we need to refill the boost.
	var/reagent_required_amount = 20

/obj/item/mod/module/adrenaline_boost/Initialize(mapload)
	. = ..()
	create_reagents(reagent_required_amount)
	reagents.add_reagent(reagent_required, reagent_required_amount)

/obj/item/mod/module/adrenaline_boost/used()
	if(!reagents.has_reagent(reagent_required, reagent_required_amount))
		balloon_alert(mod.wearer, "no charge!")
		return FALSE
	return ..()

/obj/item/mod/module/adrenaline_boost/on_use()
	if(IS_SPACE_NINJA(mod.wearer))
		mod.wearer.say(pick_list_replacements(NINJA_FILE, "lines"), forced = type)
	to_chat(mod.wearer, span_notice("You have used the adrenaline boost."))
	mod.wearer.SetAllImmobility(0)
	mod.wearer.adjustStaminaLoss(-200)
	mod.wearer.remove_status_effect(/datum/status_effect/speech/stutter)
	mod.wearer.reagents.add_reagent(/datum/reagent/medicine/stimulants, 5)
	reagents.remove_reagent(reagent_required, reagents.total_volume * 0.75)
	addtimer(CALLBACK(src, PROC_REF(boost_aftereffects), mod.wearer), 7 SECONDS)

/obj/item/mod/module/adrenaline_boost/on_install()
	. = ..()
	RegisterSignal(mod, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(try_boost))

/obj/item/mod/module/adrenaline_boost/on_uninstall(deleting = FALSE)
	. = ..()
	UnregisterSignal(mod, COMSIG_ATOM_ITEM_INTERACTION)

/obj/item/mod/module/adrenaline_boost/proc/try_boost(source, mob/user, obj/item/attacking_item)
	SIGNAL_HANDLER
	if(charge_boost(attacking_item))
		return COMPONENT_NO_AFTERATTACK
	return NONE

/obj/item/mod/module/adrenaline_boost/proc/charge_boost(obj/item/attacking_item)
	if(!attacking_item.is_open_container())
		return FALSE
	if(reagents.has_reagent(reagent_required, reagent_required_amount))
		balloon_alert(mod.wearer, "already charged!")
		return FALSE
	if(!attacking_item.reagents.trans_to(src, reagent_required_amount, target_id = reagent_required))
		return FALSE
	balloon_alert(mod.wearer, "charge [reagents.has_reagent(reagent_required, reagent_required_amount) ? "fully" : "partially"] reloaded")
	return TRUE

/obj/item/mod/module/adrenaline_boost/proc/boost_aftereffects(mob/affected_mob)
	if(!affected_mob)
		return
	reagents.trans_to(affected_mob, reagents.total_volume)
	to_chat(affected_mob, span_danger("You are beginning to feel the after-effect of the injection."))
