/obj/item/gun/ballistic/shotgun
	name = "shotgun"
	desc = "A traditional shotgun with wood furniture and a four-shell capacity underneath."
	icon_state = "shotgun"
	worn_icon_state = null
	lefthand_file = 'icons/mob/inhands/weapons/64x_guns_left.dmi'
	righthand_file = 'icons/mob/inhands/weapons/64x_guns_right.dmi'
	inhand_icon_state = "shotgun"
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	fire_sound = 'sound/weapons/gun/shotgun/shot.ogg'
	vary_fire_sound = FALSE
	fire_sound_volume = 90
	rack_sound = 'sound/weapons/gun/shotgun/rack.ogg'
	load_sound = 'sound/weapons/gun/shotgun/insert_shell.ogg'
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	mag_type = /obj/item/ammo_box/magazine/internal/shot
	semi_auto = FALSE
	internal_magazine = TRUE
	casing_ejector = FALSE
	bolt_wording = "pump"
	cartridge_wording = "shell"
	tac_reloads = FALSE
	weapon_weight = WEAPON_HEAVY

	pb_knockback = 2

/obj/item/gun/ballistic/shotgun/blow_up(mob/user)
	. = 0
	if(chambered?.loaded_projectile)
		process_fire(user, user, FALSE)
		. = 1

/obj/item/gun/ballistic/shotgun/lethal
	mag_type = /obj/item/ammo_box/magazine/internal/shot/lethal

// RIOT SHOTGUN //

/obj/item/gun/ballistic/shotgun/riot //for spawn in the armory
	name = "riot shotgun"
	desc = "A sturdy shotgun with a longer magazine and a fixed tactical stock designed for non-lethal riot control."
	icon_state = "riotshotgun"
	inhand_icon_state = "shotgun"
	fire_delay = 8
	mag_type = /obj/item/ammo_box/magazine/internal/shot/riot
	sawn_desc = "Come with me if you want to live."
	can_be_sawn_off = TRUE

// Automatic Shotguns//

/obj/item/gun/ballistic/shotgun/automatic/shoot_live_shot(mob/living/user)
	..()
	rack()

/obj/item/gun/ballistic/shotgun/automatic/combat
	name = "combat shotgun"
	desc = "A semi automatic shotgun with tactical furniture and a six-shell capacity underneath."
	icon_state = "cshotgun"
	inhand_icon_state = "shotgun_combat"
	fire_delay = 5
	mag_type = /obj/item/ammo_box/magazine/internal/shot/com
	w_class = WEIGHT_CLASS_HUGE

//Dual Feed Shotgun

/obj/item/gun/ballistic/shotgun/automatic/dual_tube
	name = "cycler shotgun"
	desc = "An advanced shotgun with two separate magazine tubes, allowing you to quickly toggle between ammo types."
	icon_state = "cycler"
	inhand_icon_state = "bulldog"
	worn_icon_state = "cshotgun"
	w_class = WEIGHT_CLASS_HUGE
	semi_auto = TRUE
	mag_type = /obj/item/ammo_box/magazine/internal/shot/tube
	/// If defined, the secondary tube is this type, if you want different shell loads
	var/alt_mag_type
	/// If TRUE, we're drawing from the alternate_magazine
	var/toggled = FALSE
	/// The B tube
	var/obj/item/ammo_box/magazine/internal/shot/alternate_magazine

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/bounty
	name = "bounty cycler shotgun"
	desc = "An advanced shotgun with two separate magazine tubes. This one shows signs of bounty hunting customization, meaning it likely has a dual rubbershot/fire slug load."
	alt_mag_type = /obj/item/ammo_box/magazine/internal/shot/tube/fire

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click to pump it.")

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/Initialize(mapload)
	. = ..()
	alt_mag_type = alt_mag_type || mag_type
	alternate_magazine = new alt_mag_type(src)

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/attack_self(mob/living/user)
	if(!chambered && magazine.contents.len)
		rack()
	else
		toggle_tube(user)

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/proc/toggle_tube(mob/living/user)
	var/current_mag = magazine
	var/alt_mag = alternate_magazine
	magazine = alt_mag
	alternate_magazine = current_mag
	toggled = !toggled
	if(toggled)
		to_chat(user, span_notice("You switch to tube B."))
	else
		to_chat(user, span_notice("You switch to tube A."))

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/AltClick(mob/living/user)
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, TRUE))
		return
	rack()

//The Riot Blaster

/obj/item/gun/ballistic/shotgun/blaster
	name = "riot blaster energy shotgun"
	desc = "The Aussec riot blaster energy shotgun utilizes bluespace rifling to reduce friction and drag significantly, propelling bullets at much faster speeds than conventional shots. This requires power upkeep."
	icon_state = "meltra" //To be replaced, don't stress this being misnamed.
	inhand_icon_state = "meltra"
	worn_icon_state = "meltra"
	fire_delay = 8
	mag_type = /obj/item/ammo_box/magazine/internal/shot/blaster
	can_modify_ammo = TRUE
	initial_caliber = CALIBER_SHOTGUN_ENERGY
	alternative_caliber = CALIBER_SHOTGUN
	projectile_damage_multiplier = 0.50

	///What cell are we using
	var/obj/item/stock_parts/cell/cell
	var/cell_type = /obj/item/stock_parts/cell

	///Is our gun charged
	var/charged_shot = FALSE //This becomes TRUE if our gun is able to successfully use battery charge, which empowers the gun for 10 seconds (does standard damage).
	///How much battery charge does our shotgun use
	var/shot_cell_cost = 200 //Effectively 5 empowerments from full battery.
	///Empowered damage multiplier
	var/empowered_damage_multiplier = 1.0
	///The multiplier for what our weapon resets too once depowered
	var/normal_damage_multiplier = 0.5
	///The cooldown timer
	var/cooldown_reset_time = 5 SECONDS //How long it takes before the shotgun needs to consume more charge, can probably magdump an entire shotgun in this time
	var/timerid

/obj/item/gun/ballistic/shotgun/blaster/Initialize(mapload)
	. = ..()
	if(cell_type)
		cell = new cell_type(src)
	else
		cell = new(src)

/obj/item/gun/ballistic/shotgun/blaster/Destroy()
	if(cell)
		QDEL_NULL(cell)
	. = ..()

/obj/item/gun/ballistic/shotgun/blaster/get_cell()
	return cell

/obj/item/gun/ballistic/shotgun/blaster/examine(mob/user)
	. = ..()
	if(cell)
		. += span_notice("\The [src] is [round(cell.percent())]% charged.")
	. += span_notice("\The [src] has a fire power strength of [round(100*projectile_damage_multiplier)]%.")

/obj/item/gun/ballistic/shotgun/blaster/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	. = ..()
	if(!.)
		return
	if(!charged_shot && reduce_cell_charge(shot_cell_cost))
		charged_shot = TRUE
		timerid = addtimer(CALLBACK(src, .proc/handle_reset, FALSE), cooldown_reset_time, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)
		playsound(src.loc, 'sound/weapons/kenetic_reload.ogg', 60, TRUE)
	if(charged_shot)
		handle_empowerment()

/obj/item/gun/ballistic/shotgun/blaster/proc/handle_empowerment()
	if(projectile_damage_multiplier < empowered_damage_multiplier)
		projectile_damage_multiplier = empowered_damage_multiplier

/obj/item/gun/ballistic/shotgun/blaster/proc/handle_reset(deltimer)
	projectile_damage_multiplier = normal_damage_multiplier
	charged_shot = FALSE
	playsound(src.loc, 'sound/weapons/gun/general/empty_alarm.ogg', 60, TRUE)
	if(deltimer && timerid)
		deltimer(timerid)

/obj/item/gun/ballistic/shotgun/blaster/proc/reduce_cell_charge(cell_deduction)
	if(!cell)
		return
	return cell.use(cell_deduction)

/obj/item/gun/ballistic/shotgun/blaster/emp_act(severity)
	. = ..()
	if (!cell)
		return
	if (!(. & EMP_PROTECT_SELF))
		reduce_cell_charge(1000 / severity)
		handle_reset(TRUE)

// Bulldog shotgun //

/obj/item/gun/ballistic/shotgun/bulldog
	name = "\improper Bulldog Shotgun"
	desc = "A semi-auto, mag-fed shotgun for combat in narrow corridors, nicknamed 'Bulldog' by boarding parties. Compatible only with specialized 8-round drum magazines."
	icon_state = "bulldog"
	inhand_icon_state = "bulldog"
	worn_icon_state = "cshotgun"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	weapon_weight = WEAPON_MEDIUM
	mag_type = /obj/item/ammo_box/magazine/m12g
	can_suppress = FALSE
	burst_size = 1
	fire_delay = 0
	pin = /obj/item/firing_pin/implant/pindicate
	fire_sound = 'sound/weapons/gun/shotgun/shot_alt.ogg'
	actions_types = list()
	mag_display = TRUE
	empty_indicator = TRUE
	empty_alarm = TRUE
	special_mags = TRUE
	mag_display_ammo = TRUE
	semi_auto = TRUE
	internal_magazine = FALSE
	tac_reloads = TRUE


/obj/item/gun/ballistic/shotgun/bulldog/unrestricted
	pin = /obj/item/firing_pin
/////////////////////////////
// DOUBLE BARRELED SHOTGUN //
/////////////////////////////

/obj/item/gun/ballistic/shotgun/doublebarrel
	name = "double-barreled shotgun"
	desc = "A true classic."
	icon_state = "dshotgun"
	inhand_icon_state = "shotgun_db"
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_MEDIUM
	force = 10
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	mag_type = /obj/item/ammo_box/magazine/internal/shot/dual
	sawn_desc = "Omar's coming!"
	obj_flags = UNIQUE_RENAME
	rack_sound_volume = 0
	unique_reskin = list("Default" = "dshotgun",
						"Dark Red Finish" = "dshotgun_d",
						"Ash" = "dshotgun_f",
						"Faded Grey" = "dshotgun_g",
						"Maple" = "dshotgun_l",
						"Rosewood" = "dshotgun_p"
						)
	semi_auto = TRUE
	bolt_type = BOLT_TYPE_NO_BOLT
	can_be_sawn_off = TRUE
	pb_knockback = 3 // it's a super shotgun!

/obj/item/gun/ballistic/shotgun/doublebarrel/AltClick(mob/user)
	. = ..()
	if(unique_reskin && !current_skin && user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY))
		reskin_obj(user)

/obj/item/gun/ballistic/shotgun/doublebarrel/sawoff(mob/user)
	. = ..()
	if(.)
		weapon_weight = WEAPON_MEDIUM

/obj/item/gun/ballistic/shotgun/doublebarrel/slugs
	name = "hunting shotgun"
	desc = "A hunting shotgun used by the wealthy to hunt \"game\"."
	sawn_desc = "A sawn-off hunting shotgun. In its new state, it's remarkably less effective at hunting... anything."
	mag_type = /obj/item/ammo_box/magazine/internal/shot/dual/slugs

/obj/item/gun/ballistic/shotgun/hook
	name = "hook modified sawn-off shotgun"
	desc = "Range isn't an issue when you can bring your victim to you."
	icon_state = "hookshotgun"
	inhand_icon_state = "hookshotgun"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	mag_type = /obj/item/ammo_box/magazine/internal/shot/bounty
	weapon_weight = WEAPON_MEDIUM
	semi_auto = TRUE
	flags_1 = CONDUCT_1
	force = 18 //it has a hook on it
	sharpness = SHARP_POINTY //it does in fact, have a hook on it
	attack_verb_continuous = list("slashes", "hooks", "stabs")
	attack_verb_simple = list("slash", "hook", "stab")
	hitsound = 'sound/weapons/bladeslice.ogg'
	//our hook gun!
	var/obj/item/gun/magic/hook/bounty/hook

/obj/item/gun/ballistic/shotgun/hook/Initialize(mapload)
	. = ..()
	hook = new /obj/item/gun/magic/hook/bounty(src)

/obj/item/gun/ballistic/shotgun/hook/examine(mob/user)
	. = ..()
	. += span_notice("Right-click to shoot the hook.")

/obj/item/gun/ballistic/shotgun/hook/afterattack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	hook.afterattack(target, user, proximity_flag, click_parameters)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
