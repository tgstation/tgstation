//Antag modules for MODsuits

///Energy Shield - Gives you a rechargeable energy shield that nullifies attacks.
/obj/item/mod/module/energy_shield
	name = "MOD energy shield module"
	desc = "A personal, protective forcefield typically seen in military applications. \
		This advanced deflector shield is essentially a scaled down version of those seen on starships, \
		and the power cost can be an easy indicator of this. However, it is capable of blocking nearly any incoming attack, \
		but only once every few seconds; a grim reminder of the users mortality."
	icon_state = "energy_shield"
	complexity = 3
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 2
	incompatible_modules = list(/obj/item/mod/module/energy_shield)
	required_slots = list(ITEM_SLOT_BACK)
	/// Max charges of the shield.
	var/max_charges = 1
	/// The time it takes for the first charge to recover.
	var/recharge_start_delay = 10 SECONDS
	/// How much time it takes for charges to recover after they started recharging.
	var/charge_increment_delay = 1 SECONDS
	/// How much charge is recovered per recovery.
	var/charge_recovery = 1
	/// Whether or not this shield can lose multiple charges.
	var/lose_multiple_charges = FALSE
	/// The icon file of the shield.
	var/shield_icon_file = 'icons/effects/effects.dmi'
	/// The icon_state of the shield.
	var/shield_icon = "shield-red"
	/// Charges the shield should start with.
	var/charges

/obj/item/mod/module/energy_shield/Initialize(mapload)
	. = ..()
	charges = max_charges

/obj/item/mod/module/energy_shield/on_part_activation()
	mod.AddComponent(\
		/datum/component/shielded, \
		max_charges = max_charges, \
		recharge_start_delay = recharge_start_delay, \
		charge_increment_delay = charge_increment_delay, \
		charge_recovery = charge_recovery, \
		lose_multiple_charges = lose_multiple_charges, \
		starting_charges = charges, \
		shield_icon_file = shield_icon_file, \
		shield_icon = shield_icon)
	RegisterSignal(mod.wearer, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(shield_reaction))

/obj/item/mod/module/energy_shield/on_part_deactivation(deleting = FALSE)
	var/datum/component/shielded/shield = mod.GetComponent(/datum/component/shielded)
	charges = shield.current_charges
	qdel(shield)
	UnregisterSignal(mod.wearer, COMSIG_LIVING_CHECK_BLOCK)

/obj/item/mod/module/energy_shield/proc/shield_reaction(mob/living/carbon/human/owner,
	atom/movable/hitby,
	damage = 0,
	attack_text = "the attack",
	attack_type = MELEE_ATTACK,
	armour_penetration = 0,
	damage_type = BRUTE
)
	SIGNAL_HANDLER

	if(mod.hit_reaction(owner, hitby, attack_text, 0, damage, attack_type))
		drain_power(use_energy_cost)
		return SUCCESSFUL_BLOCK
	return NONE

/obj/item/mod/module/energy_shield/wizard
	name = "MOD battlemage shield module"
	desc = "The caster wielding this spell gains a visible barrier around them, channeling arcane power through \
		specialized runes engraved onto the surface of the suit to generate a wall of force. \
		This shield can perfectly nullify attacks ranging from high-caliber rifles to magic missiles, \
		though can also be drained by more mundane attacks. It will not protect the caster from social ridicule."
	icon_state = "battlemage_shield"
	idle_power_cost = 0 //magic
	use_energy_cost = 0 //magic too
	max_charges = 5
	shield_icon_file = 'icons/effects/magic.dmi'
	shield_icon = "mageshield"
	required_slots = list()

///Magic Nullifier - Protects you from magic.
/obj/item/mod/module/anti_magic
	name = "MOD magic nullifier module"
	desc = "A series of obsidian rods installed into critical points around the suit, \
		vibrated at a certain low frequency to enable them to resonate. \
		This creates a low-range, yet strong, magic nullification field around the user, \
		aided by a full replacement of the suit's normal coolant with holy water. \
		Spells will spall right off this field, though it'll do nothing to help others believe you about all this."
	icon_state = "magic_nullifier"
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/anti_magic)
	required_slots = list(ITEM_SLOT_BACK)

/obj/item/mod/module/anti_magic/on_part_activation()
	mod.wearer.add_traits(list(TRAIT_ANTIMAGIC, TRAIT_HOLY), REF(src))

/obj/item/mod/module/anti_magic/on_part_deactivation(deleting = FALSE)
	mod.wearer.remove_traits(list(TRAIT_ANTIMAGIC, TRAIT_HOLY), REF(src))

/obj/item/mod/module/anti_magic/wizard
	name = "MOD magic neutralizer module"
	desc = "The caster wielding this spell gains an invisible barrier around them, channeling arcane power through \
		specialized runes engraved onto the surface of the suit to generate anti-magic field. \
		The field will neutralize all magic that comes into contact with the user. \
		It will not protect the caster from social ridicule."
	icon_state = "magic_neutralizer"
	required_slots = list()

/obj/item/mod/module/anti_magic/wizard/on_part_activation()
	mod.wearer.add_traits(list(TRAIT_ANTIMAGIC, TRAIT_ANTIMAGIC_NO_SELFBLOCK), REF(src))

/obj/item/mod/module/anti_magic/wizard/on_part_deactivation(deleting = FALSE)
	mod.wearer.remove_traits(list(TRAIT_ANTIMAGIC, TRAIT_ANTIMAGIC_NO_SELFBLOCK), REF(src))

///Insignia - Gives you a skin specific stripe.
/obj/item/mod/module/insignia
	name = "MOD insignia module"
	desc = "Despite the existence of IFF systems, radio communique, and modern methods of deductive reasoning involving \
		the wearer's own eyes, colorful paint jobs remain a popular way for different factions in the galaxy to display who \
		they are. This system utilizes a series of tiny moving paint sprayers to both apply and remove different \
		color patterns to and from the suit."
	icon_state = "insignia"
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/insignia)
	overlay_state_inactive = "module_insignia"
	mask_worn_overlay = TRUE

/obj/item/mod/module/insignia/generate_worn_overlay(obj/item/source, mutable_appearance/standing)
	overlay_state_inactive = "[initial(overlay_state_inactive)]-[mod.skin]"
	. = ..()
	for(var/mutable_appearance/appearance as anything in .)
		appearance.color = color

/obj/item/mod/module/insignia/commander
	color = "#4980a5"

/obj/item/mod/module/insignia/security
	color = "#b30d1e"

/obj/item/mod/module/insignia/engineer
	color = "#e9c80e"

/obj/item/mod/module/insignia/medic
	color = "#ebebf5"

/obj/item/mod/module/insignia/janitor
	color = "#7925c7"

/obj/item/mod/module/insignia/clown
	color = "#ff1fc7"

/obj/item/mod/module/insignia/chaplain
	color = "#f0a00c"

/obj/item/mod/module/insignia/syndie
	color = COLOR_SYNDIE_RED

///Anti Slip - Prevents you from slipping on water.
/obj/item/mod/module/noslip
	name = "MOD anti slip module"
	desc = "These are a modified variant of standard magnetic boots, utilizing piezoelectric crystals on the soles. \
		The two plates on the bottom of the boots automatically extend and magnetize as the user steps; \
		a pull that's too weak to offer them the ability to affix to a hull, but just strong enough to \
		protect against the fact that you didn't read the wet floor sign. Honk Co. has come out numerous times \
		in protest of these modules being legal."
	icon_state = "noslip"
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.1
	incompatible_modules = list(/obj/item/mod/module/noslip)
	required_slots = list(ITEM_SLOT_FEET)

/obj/item/mod/module/noslip/on_part_activation()
	ADD_TRAIT(mod.wearer, TRAIT_NO_SLIP_WATER, REF(src))

/obj/item/mod/module/noslip/on_part_deactivation(deleting = FALSE)
	REMOVE_TRAIT(mod.wearer, TRAIT_NO_SLIP_WATER, REF(src))

//Bite of 87 Springlock - Equips faster, disguised as DNA lock.
/obj/item/mod/module/springlock/bite_of_87
	name = /obj/item/mod/module/dna_lock::name
	desc = /obj/item/mod/module/dna_lock::desc
	icon_state = /obj/item/mod/module/dna_lock::icon_state
	complexity = /obj/item/mod/module/dna_lock::complexity
	use_energy_cost = /obj/item/mod/module/dna_lock::use_energy_cost
	step_change = 0.1

/obj/item/mod/module/springlock/bite_of_87/on_part_activation()
	..()
	if(check_holidays(APRIL_FOOLS) || prob(1))
		mod.set_mod_color("#b17f00")
		mod.wearer.remove_atom_colour(WASHABLE_COLOUR_PRIORITY) // turns purple guy purple
		mod.wearer.add_atom_colour("#704b96", FIXED_COLOUR_PRIORITY)

///Flamethrower - Launches fire across the area.
/obj/item/mod/module/flamethrower
	name = "MOD flamethrower module"
	desc = "A custom-manufactured flamethrower, used to burn through your path. Burn well."
	icon_state = "flamethrower"
	module_type = MODULE_ACTIVE
	complexity = 3
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 3
	incompatible_modules = list(/obj/item/mod/module/flamethrower)
	cooldown_time = 2.5 SECONDS
	overlay_state_inactive = "module_flamethrower"
	overlay_state_active = "module_flamethrower_on"
	required_slots = list(ITEM_SLOT_OCLOTHING|ITEM_SLOT_ICLOTHING)

/obj/item/mod/module/flamethrower/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	var/obj/projectile/flame = new /obj/projectile/bullet/incendiary/fire(mod.wearer.loc)
	flame.aim_projectile(target, mod.wearer)
	flame.firer = mod.wearer
	playsound(src, 'sound/items/modsuit/flamethrower.ogg', 75, TRUE)
	INVOKE_ASYNC(flame, TYPE_PROC_REF(/obj/projectile, fire))
	drain_power(use_energy_cost)

///Power kick - Lets the user launch themselves at someone to kick them.
/obj/item/mod/module/power_kick
	name = "MOD power kick module"
	desc = "This module uses high-power myomer to generate an incredible amount of energy, transferred into the power of a kick."
	icon_state = "power_kick"
	module_type = MODULE_ACTIVE
	removable = FALSE
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 5
	incompatible_modules = list(/obj/item/mod/module/power_kick)
	cooldown_time = 5 SECONDS
	required_slots = list(ITEM_SLOT_FEET)
	/// Damage on kick.
	var/damage = 20
	/// The wound bonus of the kick.
	var/wounding_power = 35
	/// How long we knockdown for on the kick.
	var/knockdown_time = 2 SECONDS

/obj/item/mod/module/power_kick/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	mod.wearer.visible_message(span_warning("[mod.wearer] starts charging a kick!"), \
		blind_message = span_hear("You hear a charging sound."))
	playsound(src, 'sound/items/modsuit/loader_charge.ogg', 75, TRUE)
	balloon_alert(mod.wearer, "you start charging...")
	animate(mod.wearer, 0.3 SECONDS, pixel_z = 16, flags = ANIMATION_RELATIVE, easing = SINE_EASING|EASE_OUT)
	addtimer(CALLBACK(mod.wearer, TYPE_PROC_REF(/atom, SpinAnimation), 3, 2), 0.3 SECONDS)
	if(!do_after(mod.wearer, 1 SECONDS, target = mod))
		animate(mod.wearer, 0.2 SECONDS, pixel_z = -16, flags = ANIMATION_RELATIVE, easing = SINE_EASING|EASE_IN)
		return
	animate(mod.wearer)
	drain_power(use_energy_cost)
	playsound(src, 'sound/items/modsuit/loader_launch.ogg', 75, TRUE)
	var/angle = get_angle(mod.wearer, target) + 180
	mod.wearer.transform = mod.wearer.transform.Turn(angle)
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_IMPACT, PROC_REF(on_throw_impact))
	mod.wearer.throw_at(target, range = 7, speed = 2, thrower = mod.wearer, spin = FALSE, gentle = TRUE, callback = CALLBACK(src, PROC_REF(on_throw_end), mod.wearer, -angle))

/obj/item/mod/module/power_kick/proc/on_throw_end(mob/user, angle)
	if(!user)
		return
	user.transform = user.transform.Turn(angle)
	animate(user, 0.2 SECONDS, pixel_z = -16, flags = ANIMATION_RELATIVE, easing = SINE_EASING|EASE_IN)

/obj/item/mod/module/power_kick/proc/on_throw_impact(mob/living/source, atom/target, datum/thrownthing/thrownthing)
	SIGNAL_HANDLER

	UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)
	if(!mod?.wearer)
		return
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.apply_damage(damage, BRUTE, mod.wearer.zone_selected, wound_bonus = wounding_power)
		living_target.Knockdown(knockdown_time)
	else if(target.uses_integrity)
		target.take_damage(damage, BRUTE, MELEE)
	else
		return
	mod.wearer.do_attack_animation(target, ATTACK_EFFECT_SMASH)

///Chameleon - lets the suit disguise as any item that would fit on that slot.
/obj/item/mod/module/chameleon
	name = "MOD chameleon module"
	desc = "A module using chameleon technology to disguise the suit as another object."
	icon_state = "chameleon"
	module_type = MODULE_USABLE
	complexity = 2
	incompatible_modules = list(/obj/item/mod/module/chameleon)
	cooldown_time = 0.5 SECONDS
	allow_flags = MODULE_ALLOW_INACTIVE
	/// A list of all the items the suit can disguise as.
	var/list/possible_disguises = list()
	/// The path of the item we're disguised as.
	var/obj/item/current_disguise

/obj/item/mod/module/chameleon/on_install()
	. = ..()
	var/list/all_disguises = sort_list(subtypesof(get_path_by_slot(mod.slot_flags)), GLOBAL_PROC_REF(cmp_typepaths_asc))
	for(var/clothing_path in all_disguises)
		var/obj/item/clothing = clothing_path
		if(!initial(clothing.icon_state))
			continue
		var/chameleon_item_name = "[initial(clothing.name)] ([initial(clothing.icon_state)])"
		possible_disguises[chameleon_item_name] = clothing_path

/obj/item/mod/module/chameleon/on_uninstall(deleting = FALSE)
	. = ..()
	if(current_disguise)
		return_look()
	possible_disguises = null

/obj/item/mod/module/chameleon/used()
	if(mod.active || mod.activating)
		balloon_alert(mod.wearer, "unit active!")
		return FALSE
	return ..()

/obj/item/mod/module/chameleon/on_use()
	if(current_disguise)
		return_look()
		return
	var/picked_name = tgui_input_list(mod.wearer, "Select look to change into", "Chameleon Settings", possible_disguises)
	if(!possible_disguises[picked_name] || mod.active || mod.activating)
		return
	current_disguise = possible_disguises[picked_name]
	update_look()

/obj/item/mod/module/chameleon/proc/update_look()
	mod.name = initial(current_disguise.name)
	mod.desc = initial(current_disguise.desc)
	mod.icon_state = initial(current_disguise.icon_state)
	mod.icon = initial(current_disguise.icon)
	mod.worn_icon = initial(current_disguise.worn_icon)
	mod.alternate_worn_layer = initial(current_disguise.alternate_worn_layer)
	mod.lefthand_file = initial(current_disguise.lefthand_file)
	mod.righthand_file = initial(current_disguise.righthand_file)
	mod.worn_icon_state = initial(current_disguise.worn_icon_state)
	mod.inhand_icon_state = initial(current_disguise.inhand_icon_state)
	update_clothing_slots()
	RegisterSignal(mod, COMSIG_MOD_ACTIVATE, PROC_REF(return_look))

/obj/item/mod/module/chameleon/proc/return_look()
	mod.name = "[mod.theme.name] [initial(mod.name)]"
	mod.desc = "[initial(mod.desc)] [mod.theme.desc]"
	mod.icon_state = "[mod.skin]-[initial(mod.icon_state)]"
	var/list/mod_skin = mod.theme.variants[mod.skin]
	mod.icon = mod_skin[MOD_ICON_OVERRIDE] || 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	mod.worn_icon = mod_skin[MOD_WORN_ICON_OVERRIDE] || 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	mod.lefthand_file = initial(mod.lefthand_file)
	mod.righthand_file = initial(mod.righthand_file)
	mod.worn_icon_state = null
	mod.inhand_icon_state = null
	update_clothing_slots()
	current_disguise = null
	UnregisterSignal(mod, COMSIG_MOD_ACTIVATE)

///Plate Compression - Compresses the suit to normal size
/obj/item/mod/module/plate_compression
	name = "MOD plate compression module"
	desc = "A module that keeps the suit in a very tightly fit state, lowering the overall size. \
		Due to the pressure on all the parts, typical storage modules do not fit."
	icon_state = "plate_compression"
	complexity = 2
	incompatible_modules = list(/obj/item/mod/module/plate_compression, /obj/item/mod/module/storage)
	/// The size we set the suit to.
	var/new_size = WEIGHT_CLASS_NORMAL
	/// The suit's size before the module is installed.
	var/old_size

/obj/item/mod/module/plate_compression/on_install()
	. = ..()
	old_size = mod.w_class
	mod.update_weight_class(new_size)

/obj/item/mod/module/plate_compression/on_uninstall(deleting = FALSE)
	. = ..()
	mod.update_weight_class(old_size)
	old_size = null
	if(!mod.loc)
		return
	var/datum/storage/holding_storage = mod.loc.atom_storage
	if(!holding_storage || holding_storage.max_specific_storage >= mod.w_class)
		return
	mod.forceMove(drop_location())

/obj/item/mod/module/demoralizer
	name = "MOD psi-echo demoralizer module"
	desc = "One incredibly morbid member of the RND team at Roseus Galactic posed a question to her colleagues. \
	'I desire the power to scar my enemies mentally as I murder them. Who will stop me implementing this in our next project?' \
	And thus the Psi-Echo Demoralizer Device was reluctantly invented. The future of psychological warfare, today!"
	icon_state = "brain_hurties"
	complexity = 0
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.1
	removable = FALSE
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	var/datum/proximity_monitor/advanced/demoraliser/demoralizer

/obj/item/mod/module/demoralizer/on_part_activation()
	var/datum/demoralise_moods/module/mood_category = new()
	demoralizer = new(mod.wearer, 7, TRUE, mood_category)

/obj/item/mod/module/demoralizer/on_part_deactivation(deleting = FALSE)
	QDEL_NULL(demoralizer)

/obj/item/mod/module/infiltrator
	name = "MOD infiltration core programs module"
	desc = "The primary stealth systems operating within the suit. Utilizing electromagnetic signals, \
		the wearer simply cannot be observed closely, or heard clearly by those around them.\
		It also contains some dampening systems to help protect a user from blows to the head."
	icon_state = "infiltrator"
	complexity = 0
	removable = FALSE
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0
	incompatible_modules = list(/obj/item/mod/module/infiltrator, /obj/item/mod/module/welding/syndicate, /obj/item/mod/module/welding, /obj/item/mod/module/headprotector)
	required_slots = list(ITEM_SLOT_FEET, ITEM_SLOT_HEAD, ITEM_SLOT_OCLOTHING)
	/// List of traits added when the suit is activated
	var/list/traits_to_add = list(TRAIT_SILENT_FOOTSTEPS, TRAIT_UNKNOWN, TRAIT_HEAD_INJURY_BLOCKED)

/obj/item/mod/module/infiltrator/on_install()
	. = ..()
	ADD_TRAIT(mod, TRAIT_EXAMINE_SKIP, REF(src))

/obj/item/mod/module/infiltrator/on_uninstall(deleting = FALSE)
	. = ..()
	REMOVE_TRAIT(mod, TRAIT_EXAMINE_SKIP, REF(src))

/obj/item/mod/module/infiltrator/on_part_activation()
	mod.wearer.add_traits(traits_to_add, REF(src))
	RegisterSignal(mod.wearer, COMSIG_TRY_MODIFY_SPEECH, PROC_REF(on_speech_modification))
	var/obj/item/organ/tongue/user_tongue = mod.wearer.get_organ_slot(ORGAN_SLOT_TONGUE)
	user_tongue.temp_say_mod = "states"
	var/obj/item/clothing/head_cover = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	if(istype(head_cover))
		head_cover.flash_protect = FLASH_PROTECTION_WELDER_HYPER_SENSITIVE

/obj/item/mod/module/infiltrator/on_part_deactivation(deleting = FALSE)
	mod.wearer.remove_traits(traits_to_add, REF(src))
	UnregisterSignal(mod.wearer, COMSIG_TRY_MODIFY_SPEECH)
	var/obj/item/organ/tongue/user_tongue = mod.wearer.get_organ_slot(ORGAN_SLOT_TONGUE)
	user_tongue.temp_say_mod = initial(user_tongue.temp_say_mod)
	if(deleting)
		return
	var/obj/item/clothing/head_cover = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	if(istype(head_cover))
		head_cover.flash_protect = initial(head_cover.flash_protect)

/obj/item/mod/module/infiltrator/proc/on_speech_modification(datum/source)
	SIGNAL_HANDLER
	if(!mod.active)
		return
	//Prevent speech modifications if the suit is active
	return PREVENT_MODIFY_SPEECH

///Medbeam - Medbeam but built into a modsuit
/obj/item/mod/module/medbeam
	name = "MOD medical beamgun module"
	desc = "A wrist mounted variant of the medbeam gun, allowing the user to heal their allies without the risk of dropping it."
	icon_state = "chronogun"
	module_type = MODULE_ACTIVE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN
	device = /obj/item/gun/medbeam/mod
	incompatible_modules = list(/obj/item/mod/module/medbeam)
	removable = TRUE
	cooldown_time = 0.05 SECONDS
	required_slots = list(ITEM_SLOT_BACK)

/obj/item/gun/medbeam/mod
	name = "MOD medbeam"

/obj/item/mod/module/stealth/wraith
	name = "MOD Wraith Cloaking Module"
	desc = "A more destructive adaptation of the stealth module. Incompatible with armor modules"
	icon_state = "cloak_traitor"
	stealth_alpha = 30
	module_type = MODULE_ACTIVE
	cooldown_time = 2 SECONDS
	incompatible_modules = list(/obj/item/mod/module/stealth, /obj/item/mod/module/welding/syndicate)
	/// How much time before we are able to cloak again after the cloak is broken (not disabled)
	COOLDOWN_DECLARE(recloak_timer)
	/// If the stealth portion of the module is active
	var/stealth_active = FALSE

/obj/item/mod/module/stealth/wraith/on_select_use(atom/target)
	. = ..()
	if(!. || target == mod.wearer)
		return
	if(get_dist(mod.wearer, target) > 6)
		balloon_alert(mod.wearer, "can't reach that!")
		return
	if(istype(target, /obj/machinery/power/apc)) //Bit too strong for a module so this is blacklisted
		balloon_alert(mod.wearer, "can't disable apc!")
		return

	var/list/things_to_disrupt = list(target)
	if(isliving(target))
		var/mob/living/live_target = target
		things_to_disrupt += live_target.get_all_gear()

	for(var/atom/disrupted as anything in things_to_disrupt)
		if(disrupted.on_saboteur(src, 1 MINUTES))
			mod.add_charge(DEFAULT_CHARGE_DRAIN * 250)

/obj/item/mod/module/stealth/wraith/on_activation()
	return // Don't activate stealth when the module is activated because the stealth portion of the module is fully passive

/obj/item/mod/module/stealth/wraith/on_deactivation(display_message = TRUE, deleting = FALSE)
	. = ..()
	UnregisterSignal(mod.wearer, list(COMSIG_LIVING_MOB_BUMP, COMSIG_ATOM_BUMPED, COMSIG_MOB_FIRED_GUN))

/obj/item/mod/module/stealth/wraith/on_part_activation()
	start_stealth()

/obj/item/mod/module/stealth/wraith/on_part_deactivation(deleting)
	UnregisterSignal(mod.wearer, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_MOB_ITEM_ATTACK, COMSIG_ATOM_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_BULLET_ACT, COMSIG_ATOM_HITBY, COMSIG_ATOM_HULK_ATTACK, COMSIG_ATOM_ATTACK_PAW, COMSIG_CARBON_CUFF_ATTEMPTED, COMSIG_LIVING_MOB_BUMP, COMSIG_ATOM_BUMPED, COMSIG_MOB_FIRED_GUN))
	animate(mod.wearer, alpha = 255, time = 1.5 SECONDS)
	stealth_active = FALSE

/obj/item/mod/module/stealth/wraith/proc/start_stealth()
	if(!COOLDOWN_FINISHED(src, recloak_timer)) // Prevents being able to bypass the cooldown by disabling and re-enabling the module
		addtimer(CALLBACK(src, PROC_REF(start_stealth)), recloak_timer)
		return
	RegisterSignals(mod.wearer, list(COMSIG_LIVING_MOB_BUMP, COMSIG_ATOM_BUMPED, COMSIG_MOB_FIRED_GUN), PROC_REF(unstealth))
	RegisterSignal(mod.wearer, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))
	RegisterSignal(mod.wearer, COMSIG_ATOM_BULLET_ACT, PROC_REF(on_bullet_act))
	RegisterSignals(mod.wearer, list(COMSIG_MOB_ITEM_ATTACK, COMSIG_ATOM_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_HITBY, COMSIG_ATOM_HULK_ATTACK, COMSIG_ATOM_ATTACK_PAW, COMSIG_CARBON_CUFF_ATTEMPTED), PROC_REF(unstealth))
	animate(mod.wearer, alpha = stealth_alpha, time = 1.5 SECONDS)
	drain_power(use_energy_cost)
	stealth_active = TRUE

/obj/item/mod/module/stealth/wraith/unstealth(datum/source)
	if(!stealth_active)
		return
	. = ..()
	if(mod.active)
		COOLDOWN_START(src, recloak_timer, 20 SECONDS)
		addtimer(CALLBACK(src, PROC_REF(start_stealth)), 20 SECONDS)
		stealth_active = FALSE

/obj/item/mod/module/stealth/wraith/examine_more(mob/user)
	. = ..()
	. += span_info( \
		"The Wraith Module does not simply bend light around the user to obscure their visual pattern, \
		but actively attacks and overloads surrounding light emitting objects, repurposing this energy to power the suit. \
		It is possible that this technology has its origins in Spider Clan advancements, \
		but the exact source of the Wraith Module is highly disputed. \
		No group has stepped forward to claim it as their handiwork due to the political consequences of having stolen Spider Clan tech and their inevitable retaliation for such transgressions. \
		Most point fingers at Cybersun Industries, but murmurs suggest it could even be even more clandestine organizations amongst the Syndicate branches. \
		Whatever the case, if you are looking at one of these right now, don't show it to a space ninja." \
	)
