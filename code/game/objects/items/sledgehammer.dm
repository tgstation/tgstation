/*
 * Sledgehammer
 */
/obj/item/sledge  // DEM AXES MAN, marker -Agouri
	icon_state = "hammeroff"
	item_state = "hammeroff"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	name = "sledgehammer"
	desc = "Used for knocking the everloving hell out of whatever, or whoever, you hit."
	force = 5
	throwforce = 15
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	attack_verb = list("battered", "crushed", "slammed", "hammered")
	hitsound = 'sound/weapons/smash.ogg'
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 30)
	resistance_flags = FIRE_PROOF
	var/wielded = FALSE // track wielded status on item

/obj/item/sledge/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, .proc/on_wield)
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, .proc/on_unwield)
	RegisterSignal(src, COMSIG_UNWIELDY_BONK, .proc/bonk)

/obj/item/sledge/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=5, force_wielded=20, icon_wielded="hammeron")

/// triggered on wield of two handed item
/obj/item/sledge/proc/on_wield(obj/item/source, mob/user)
	wielded = TRUE
	AddElement(/datum/element/unwieldy)

/// triggered on unwield of two handed item
/obj/item/sledge/proc/on_unwield(obj/item/source, mob/user)
	wielded = FALSE
	RemoveElement(/datum/element/unwieldy)

/obj/item/sledge/update_icon_state()
	icon_state = "hammeroff"

/obj/item/sledge/proc/bonk(obj/item/I, mob/living/user, atom/intended_target, atom/obstruction)
	user.visible_message("<span class='danger'>[user] slams [src] into [obstruction] mid-swing!</span>", "<span class='danger'><b>Your swing intended for [intended_target] is cut short by [obstruction]!</b></span>")
	playsound(get_turf(src), 'sound/effects/clang.ogg', 100, TRUE, -1)
	obstruction.attackby(src, user)
	user.Stun(0.5 SECONDS)
	if(isturf(obstruction))
		user.do_attack_animation(obstruction)

/obj/item/sledge/afterattack(atom/A, mob/living/carbon/user, proximity)
	. = ..()
	if(!proximity || !istype(user))
		return

	if(!wielded || isopenturf(A)) //ignore whiffs
		return

	if(istype(A, /obj/structure/window) || istype(A, /obj/structure/grille))
		var/obj/structure/W = A
		W.obj_destruction("fireaxe")

	var/atom/movable/AM = A
	if(istype(AM) && !AM.anchored)
		var/clockwise = (user.active_hand_index % 2 == 0) // right hand means we're swinging counterclockwise, so check clockwise tile
		var/dir = dir2angle(get_dir(user, AM))

		if(clockwise)
			dir = (dir + 45) % 360
		else
			dir = (dir + 315) % 360

		var/turf/tile_check = get_step(user, angle2dir(dir))
		var/turf/target_tile = get_step_away(AM, tile_check)
		AM.throw_at(target_tile, 1, 2, user)

	user.force_hand_swap()
	user.swap_hand()
