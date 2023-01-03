/obj/item/gun/energy/ionrifle
	name = "ion rifle"
	desc = "A man-portable anti-armor weapon designed to disable mechanical threats at range."
	icon_state = "ionrifle"
	inhand_icon_state = null //so the human update icon uses the icon_state instead.
	worn_icon_state = null
	shaded_charge = TRUE
	w_class = WEIGHT_CLASS_HUGE
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	ammo_type = list(/obj/item/ammo_casing/energy/ion)

/obj/item/gun/energy/ionrifle/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 17, \
		overlay_y = 9)

/obj/item/gun/energy/ionrifle/emp_act(severity)
	return

/obj/item/gun/energy/ionrifle/carbine
	name = "ion carbine"
	desc = "The MK.II Prototype Ion Projector is a lightweight carbine version of the larger ion rifle, built to be ergonomic and efficient."
	icon_state = "ioncarbine"
	worn_icon_state = "gun"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BELT

/obj/item/gun/energy/ionrifle/carbine/add_seclight_point()
	. = ..()
	// We use the same overlay as the parent, so we can just let the component inherit the correct offsets here
	AddComponent(/datum/component/seclite_attachable, overlay_x = 18, overlay_y = 11)

/obj/item/gun/energy/decloner
	name = "biological demolecularisor"
	desc = "A gun that discharges high amounts of controlled radiation to slowly break a target into component elements."
	icon_state = "decloner"
	ammo_type = list(/obj/item/ammo_casing/energy/declone)
	ammo_x_offset = 1

/obj/item/gun/energy/decloner/update_overlays()
	. = ..()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(!QDELETED(cell) && (cell.charge > shot.e_cost))
		. += "decloner_spin"

/obj/item/gun/energy/decloner/unrestricted
	pin = /obj/item/firing_pin
	ammo_type = list(/obj/item/ammo_casing/energy/declone/weak)

/obj/item/gun/energy/floragun
	name = "floral somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells."
	icon_state = "flora"
	inhand_icon_state = "gun"
	ammo_type = list(/obj/item/ammo_casing/energy/flora/yield, /obj/item/ammo_casing/energy/flora/mut, /obj/item/ammo_casing/energy/flora/revolution)
	modifystate = 1
	ammo_x_offset = 1
	selfcharge = 1
	gun_flags = NOT_A_REAL_GUN

/obj/item/gun/energy/meteorgun
	name = "meteor gun"
	desc = "For the love of god, make sure you're aiming this the right way!"
	icon_state = "meteor_gun"
	inhand_icon_state = "c20r"
	w_class = WEIGHT_CLASS_BULKY
	ammo_type = list(/obj/item/ammo_casing/energy/meteor)
	cell_type = /obj/item/stock_parts/cell/potato
	clumsy_check = 0 //Admin spawn only, might as well let clowns use it.
	selfcharge = 1
	automatic_charge_overlays = FALSE

/obj/item/gun/energy/meteorgun/pen
	name = "meteor pen"
	desc = "The pen is mightier than the sword."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	inhand_icon_state = "pen"
	worn_icon_state = "pen"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	automatic_charge_overlays = FALSE

/obj/item/gun/energy/mindflayer
	name = "\improper Mind Flayer"
	desc = "A prototype weapon recovered from the ruins of Research-Station Epsilon."
	icon_state = "xray"
	w_class = WEIGHT_CLASS_BULKY
	inhand_icon_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/mindflayer)
	ammo_x_offset = 2

/obj/item/gun/energy/plasmacutter
	name = "plasma cutter"
	desc = "A mining tool capable of expelling concentrated plasma bursts. You could use it to cut limbs off xenos! Or, you know, mine stuff."
	icon_state = "plasmacutter"
	inhand_icon_state = "plasmacutter"
	ammo_type = list(/obj/item/ammo_casing/energy/plasma)
	flags_1 = CONDUCT_1
	attack_verb_continuous = list("attacks", "slashes", "cuts", "slices")
	attack_verb_simple = list("attack", "slash", "cut", "slice")
	force = 12
	sharpness = SHARP_EDGED
	can_charge = FALSE
	gun_flags = NOT_A_REAL_GUN

	heat = 3800
	usesound = list('sound/items/welder.ogg', 'sound/items/welder2.ogg')
	tool_behaviour = TOOL_WELDER
	toolspeed = 0.7 //plasmacutters can be used as welders, and are faster than standard welders
	var/charge_weld = 25 //amount of charge used up to start action (multiplied by amount) and per progress_flash_divisor ticks of welding

/obj/item/gun/energy/plasmacutter/Initialize(mapload)
	AddElement(/datum/element/update_icon_blocker)
	. = ..()
	AddComponent(/datum/component/butchering, \
		speed = 2.5 SECONDS, \
		effectiveness = 105, \
		bonus_modifier = 0, \
		butcher_sound = 'sound/weapons/plasma_cutter.ogg', \
	)
	AddElement(/datum/element/tool_flash, 1)

/obj/item/gun/energy/plasmacutter/examine(mob/user)
	. = ..()
	if(cell)
		. += span_notice("[src] is [round(cell.percent())]% charged.")

/obj/item/gun/energy/plasmacutter/attackby(obj/item/I, mob/user)
	var/charge_multiplier = 0 //2 = Refined stack, 1 = Ore
	if(istype(I, /obj/item/stack/sheet/mineral/plasma))
		charge_multiplier = 2
	if(istype(I, /obj/item/stack/ore/plasma))
		charge_multiplier = 1
	if(charge_multiplier)
		if(cell.charge == cell.maxcharge)
			balloon_alert(user, "already fully charged!")
			return
		I.use(1)
		cell.give(500*charge_multiplier)
		balloon_alert(user, "cell recharged")
	else
		..()

/obj/item/gun/energy/plasmacutter/emp_act(severity)
	if(!cell.charge)
		return
	cell.use(cell.charge/3)
	if(isliving(loc))
		var/mob/living/user = loc
		user.visible_message(span_danger("Concentrated plasma discharges from [src] onto [user], burning them!"), span_userdanger("[src] malfunctions, spewing concentrated plasma onto you! It burns!"))
		user.adjust_fire_stacks(4)
		user.ignite_mob()

// Can we weld? Plasma cutter does not use charge continuously.
// Amount cannot be defaulted to 1: most of the code specifies 0 in the call.
/obj/item/gun/energy/plasmacutter/tool_use_check(mob/living/user, amount)
	if(QDELETED(cell))
		balloon_alert(user, "no cell inserted!")
		return FALSE
	// Amount cannot be used if drain is made continuous, e.g. amount = 5, charge_weld = 25
	// Then it'll drain 125 at first and 25 periodically, but fail if charge dips below 125 even though it still can finish action
	// Alternately it'll need to drain amount*charge_weld every period, which is either obscene or makes it free for other uses
	if(amount ? cell.charge < charge_weld * amount : cell.charge < charge_weld)
		balloon_alert(user, "not enough charge!")
		return FALSE

	return TRUE

/obj/item/gun/energy/plasmacutter/use(amount)
	return (!QDELETED(cell) && cell.use(amount ? amount * charge_weld : charge_weld))

/obj/item/gun/energy/plasmacutter/use_tool(atom/target, mob/living/user, delay, amount=1, volume=0, datum/callback/extra_checks)

	if(amount)
		var/mutable_appearance/sparks = mutable_appearance('icons/effects/welding_effect.dmi', "welding_sparks", GASFIRE_LAYER, src, ABOVE_LIGHTING_PLANE)
		target.add_overlay(sparks)
		LAZYADD(update_overlays_on_z, sparks)
		. = ..()
		LAZYREMOVE(update_overlays_on_z, sparks)
		target.cut_overlay(sparks)
	else
		. = ..(amount=1)

/obj/item/gun/energy/plasmacutter/adv
	name = "advanced plasma cutter"
	icon_state = "adv_plasmacutter"
	inhand_icon_state = "adv_plasmacutter"
	force = 15
	ammo_type = list(/obj/item/ammo_casing/energy/plasma/adv)

#define AMMO_SELECT_BLUE 1
#define AMMO_SELECT_ORANGE 2

/obj/item/gun/energy/wormhole_projector
	name = "bluespace wormhole projector"
	desc = "A projector that emits high density quantum-coupled bluespace beams. Requires a bluespace anomaly core to function. Fits in a bag."
	ammo_type = list(/obj/item/ammo_casing/energy/wormhole, /obj/item/ammo_casing/energy/wormhole/orange)
	can_select = FALSE // left-click for blue, right-click for orange.
	w_class = WEIGHT_CLASS_NORMAL
	inhand_icon_state = null
	icon_state = "wormhole_projector"
	base_icon_state = "wormhole_projector"
	automatic_charge_overlays = FALSE
	var/obj/effect/portal/p_blue
	var/obj/effect/portal/p_orange
	var/firing_core = FALSE
	gun_flags = NOT_A_REAL_GUN

/obj/item/gun/energy/wormhole_projector/examine(mob/user)
	. = ..()
	. += span_notice("<b>Left-click</b> to fire blue wormholes and <b><font color=orange>right-click</font></b> to fire orange wormholes.")

/obj/item/gun/energy/wormhole_projector/attackby(obj/item/C, mob/user)
	if(istype(C, /obj/item/assembly/signaler/anomaly/bluespace))
		to_chat(user, span_notice("You insert [C] into the wormhole projector and the weapon gently hums to life."))
		firing_core = TRUE
		playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
		qdel(C)
		return

/obj/item/gun/energy/wormhole_projector/can_shoot()
	if(!firing_core)
		return FALSE
	return ..()

/obj/item/gun/energy/wormhole_projector/shoot_with_empty_chamber(mob/living/user)
	. = ..()
	to_chat(user, span_danger("The display says, 'NO CORE INSTALLED'."))

/obj/item/gun/energy/wormhole_projector/update_icon_state()
	. = ..()
	icon_state = inhand_icon_state = "[base_icon_state][select]"

/obj/item/gun/energy/wormhole_projector/update_ammo_types()
	. = ..()
	for(var/i in 1 to ammo_type.len)
		var/obj/item/ammo_casing/energy/wormhole/W = ammo_type[i]
		if(istype(W))
			W.gun = WEAKREF(src)
			var/obj/projectile/beam/wormhole/WH = W.loaded_projectile
			if(istype(WH))
				WH.gun = WEAKREF(src)

/obj/item/gun/energy/wormhole_projector/afterattack(atom/target, mob/living/user, flag, params)
	if(select == AMMO_SELECT_ORANGE) //Last fired in right click mode. Switch to blue wormhole (left click).
		select_fire()
	return ..()

/obj/item/gun/energy/wormhole_projector/afterattack_secondary(atom/target, mob/living/user, flag, params)
	if(select == AMMO_SELECT_BLUE) //Last fired in left click mode. Switch to orange wormhole (right click).
		select_fire()
	fire_gun(target, user, flag, params)
	return SECONDARY_ATTACK_CONTINUE_CHAIN

/obj/item/gun/energy/wormhole_projector/proc/on_portal_destroy(obj/effect/portal/P)
	SIGNAL_HANDLER
	if(P == p_blue)
		p_blue = null
	else if(P == p_orange)
		p_orange = null

/obj/item/gun/energy/wormhole_projector/proc/has_blue_portal()
	if(istype(p_blue) && !QDELETED(p_blue))
		return TRUE
	return FALSE

/obj/item/gun/energy/wormhole_projector/proc/has_orange_portal()
	if(istype(p_orange) && !QDELETED(p_orange))
		return TRUE
	return FALSE

/obj/item/gun/energy/wormhole_projector/proc/crosslink()
	if(!has_blue_portal() && !has_orange_portal())
		return
	if(!has_blue_portal() && has_orange_portal())
		p_orange.link_portal(null)
		return
	if(!has_orange_portal() && has_blue_portal())
		p_blue.link_portal(null)
		return
	p_orange.link_portal(p_blue)
	p_blue.link_portal(p_orange)

/obj/item/gun/energy/wormhole_projector/proc/create_portal(obj/projectile/beam/wormhole/W, turf/target)
	var/obj/effect/portal/P = new /obj/effect/portal(target, 300, null, FALSE, null)
	RegisterSignal(P, COMSIG_PARENT_QDELETING, PROC_REF(on_portal_destroy))
	if(istype(W, /obj/projectile/beam/wormhole/orange))
		qdel(p_orange)
		p_orange = P
		P.icon_state = "portal1"
	else
		qdel(p_blue)
		p_blue = P
	crosslink()

/obj/item/gun/energy/wormhole_projector/core_inserted
	firing_core = TRUE

#undef AMMO_SELECT_BLUE
#undef AMMO_SELECT_ORANGE

/* 3d printer 'pseudo guns' for borgs */

/obj/item/gun/energy/printer
	name = "cyborg lmg"
	desc = "An LMG that fires 3D-printed flechettes. They are slowly resupplied using the cyborg's internal power source."
	icon_state = "l6_cyborg"
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	cell_type = /obj/item/stock_parts/cell/secborg
	ammo_type = list(/obj/item/ammo_casing/energy/c3dbullet)
	can_charge = FALSE
	use_cyborg_cell = TRUE

/obj/item/gun/energy/printer/Initialize(mapload)
	AddElement(/datum/element/update_icon_blocker)
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.3 SECONDS)

/obj/item/gun/energy/printer/emp_act()
	return

/obj/item/gun/energy/temperature
	name = "temperature gun"
	icon_state = "freezegun"
	desc = "A gun that changes temperatures. Comes with a collapsible stock."
	w_class = WEIGHT_CLASS_NORMAL
	ammo_type = list(/obj/item/ammo_casing/energy/temp, /obj/item/ammo_casing/energy/temp/hot)
	cell_type = /obj/item/stock_parts/cell/high
	pin = null

/obj/item/gun/energy/temperature/security
	name = "security temperature gun"
	desc = "A weapon that can only be used to its full potential by the truly robust."
	pin = /obj/item/firing_pin

/obj/item/gun/energy/temperature/freeze
	name = "cryogenic temperature gun"
	desc = "A gun that reduces temperatures. Only for those with ice in their veins."
	pin = /obj/item/firing_pin
	ammo_type = list(/obj/item/ammo_casing/energy/temp)

/obj/item/gun/energy/gravity_gun
	name = "one-point gravitational manipulator"
	desc = "An experimental, multi-mode device that fires bolts of Zero-Point Energy, causing local distortions in gravity. Requires a gravitational anomaly core to function."
	w_class = WEIGHT_CLASS_BULKY
	ammo_type = list(/obj/item/ammo_casing/energy/gravity/repulse, /obj/item/ammo_casing/energy/gravity/attract, /obj/item/ammo_casing/energy/gravity/chaos)
	inhand_icon_state = "gravity_gun"
	icon_state = "gravity_gun"
	automatic_charge_overlays = FALSE
	var/power = 4
	var/firing_core = FALSE
	gun_flags = NOT_A_REAL_GUN

/obj/item/gun/energy/gravity_gun/attackby(obj/item/C, mob/user)
	if(istype(C, /obj/item/assembly/signaler/anomaly/grav))
		to_chat(user, span_notice("You insert [C] into the gravitational manipulator and the weapon gently hums to life."))
		firing_core = TRUE
		playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
		qdel(C)
		return
	return ..()

/obj/item/gun/energy/gravity_gun/can_shoot()
	if(!firing_core)
		return FALSE
	return ..()

/obj/item/gun/energy/tesla_cannon
	name = "tesla cannon"
	icon_state = "tesla"
	inhand_icon_state = "tesla"
	desc = "A gun that shoots balls of \"tesla\", whatever that is."
	ammo_type = list(/obj/item/ammo_casing/energy/tesla_cannon)
	shaded_charge = TRUE
	weapon_weight = WEAPON_HEAVY

/obj/item/gun/energy/tesla_cannon/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.1 SECONDS)

/obj/item/gun/energy/marksman_revolver
	name = "marksman revolver"
	desc = "Uses electric pulses to fire microscopic pieces of metal at incredibly high speeds. Alternate fire flips a coin that can be targeted for extra firepower."
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	icon_state = "revolver"
	ammo_type = list(/obj/item/ammo_casing/energy/marksman)
	fire_sound = 'sound/weapons/gun/revolver/shot_alt.ogg'
	automatic_charge_overlays = FALSE
	/// How many coins we can have at a time. Set to 0 for infinite
	var/max_coins = 4
	/// How many coins we currently have available
	var/coin_count = 0
	/// How long it takes to regen a coin
	var/coin_regen_rate = 2 SECONDS
	/// The cooldown for regenning coins
	COOLDOWN_DECLARE(coin_regen_cd)

/obj/item/gun/energy/marksman_revolver/Initialize(mapload)
	. = ..()
	coin_count = max_coins

/obj/item/gun/energy/marksman_revolver/examine(mob/user)
	. = ..()
	if(max_coins)
		. += "It currently has [coin_count] out of [max_coins] coins, and takes [coin_regen_rate/10] seconds to recharge each one."
	else
		. += "It has infinite coins available for use."

/obj/item/gun/energy/marksman_revolver/process(delta_time)
	if(!max_coins || coin_count >= max_coins)
		STOP_PROCESSING(SSobj, src)
		return

	if(COOLDOWN_FINISHED(src, coin_regen_cd))
		if(ismob(loc))
			var/mob/owner = loc
			owner.playsound_local(owner, 'sound/machines/ding.ogg', 20)
		coin_count++
		COOLDOWN_START(src, coin_regen_cd, coin_regen_rate)

/obj/item/gun/energy/marksman_revolver/afterattack_secondary(atom/target, mob/living/user, params)
	if(!can_see(user, get_turf(target), length = 9))
		return ..()

	if(max_coins && coin_count <= 0)
		to_chat(user, span_warning("You don't have any coins right now!"))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(max_coins)
		START_PROCESSING(SSobj, src)
		coin_count = max(0, coin_count - 1)

	var/turf/target_turf = get_offset_target_turf(target, rand(-1, 1), rand(-1, 1)) // choose a random tile adjacent to the clicked one
	playsound(user.loc, 'sound/effects/coin2.ogg', 50, TRUE)
	user.visible_message(span_warning("[user] flips a coin towards [target]!"), span_danger("You flip a coin towards [target]!"))
	var/obj/projectile/bullet/coin/new_coin = new(get_turf(user), target_turf, user)
	new_coin.preparePixelProjectile(target_turf, user)
	new_coin.fire()

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
