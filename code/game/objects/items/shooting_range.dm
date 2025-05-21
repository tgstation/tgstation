/obj/item/target
	name = "shooting target"
	desc = "A shooting target."
	icon = 'icons/obj/structures.dmi'
	icon_state = "target_h"
	density = FALSE
	max_integrity = 1800
	item_flags = CAN_BE_HIT
	/// Lazylist to keep track of bullet-hole overlays.
	var/list/bullethole_overlays

/obj/item/target/welder_act(mob/living/user, obj/item/tool)
	if(tool.use_tool(src, user, 0 SECONDS, volume = 40))
		LAZYNULL(bullethole_overlays)
		balloon_alert(user, "target repaired")
		update_appearance(UPDATE_OVERLAYS)
	return TRUE

/obj/item/target/update_overlays()
	. = ..()
	. |= bullethole_overlays

/obj/item/target/bullet_act(obj/projectile/hitting_projectile, def_zone, piercing_hit = FALSE)
	if(prob(25))
		return ..() // RNG change to just not leave a mark, like walls
	if(length(overlays) > 35)
		return ..() // Too many bullets, we're done here

	// Projectiles which do not deal damage will not leave dent / scorch mark graphics.
	// However we snowflake some projectiles to leave them anyway, because they're appropriate.
	var/static/list/always_leave_marks
	if(isnull(always_leave_marks))
		always_leave_marks = typecacheof(list(
			/obj/projectile/beam/practice,
			/obj/projectile/beam/laser/carbine/practice,
		))

	var/is_invalid_damage = hitting_projectile.damage_type != BRUTE && hitting_projectile.damage_type != BURN
	var/is_safe = !hitting_projectile.is_hostile_projectile()
	var/is_generic_projectile = !is_type_in_typecache(hitting_projectile, always_leave_marks)
	if(is_generic_projectile && (is_invalid_damage || is_safe))
		return ..() // Don't bother unless it's real shit

	var/p_x = hitting_projectile.p_x + pick(0, 0, 0, 0, 0, -1, 1) // really ugly way of coding "sometimes offset p_x!"
	var/p_y = hitting_projectile.p_y + pick(0, 0, 0, 0, 0, -1, 1)
	var/icon/our_icon = icon(icon, icon_state)
	if(!our_icon.GetPixel(p_x, p_y) || hitting_projectile.original != src)
		return BULLET_ACT_FORCE_PIERCE // We, "missed", I guess?

	. = ..()
	if(. != BULLET_ACT_HIT)
		return

	var/image/bullet_hole = image('icons/effects/effects.dmi', "dent", OBJ_LAYER + 0.5)
	bullet_hole.pixel_w = p_x - 1 //offset correction
	bullet_hole.pixel_z = p_y - 1
	if(hitting_projectile.damage_type != BRUTE)
		bullet_hole.setDir(pick(GLOB.cardinals))// random scorch design
		if(hitting_projectile.damage < 20 && is_generic_projectile)
			bullet_hole.icon_state = "light_scorch"
		else
			bullet_hole.icon_state = "scorch"

	LAZYADD(bullethole_overlays, bullet_hole)
	update_appearance(UPDATE_OVERLAYS)

/obj/item/target/syndicate
	icon_state = "target_s"
	desc = "A shooting target that looks like syndicate scum."
	max_integrity = 2600

/obj/item/target/alien
	icon_state = "target_q"
	desc = "A shooting target that looks like a xenomorphic alien."
	max_integrity = 2350

/obj/item/target/alien/anchored
	anchored = TRUE

/obj/item/target/clown
	icon_state = "target_c"
	desc = "A shooting target that looks like a useless clown."
	max_integrity = 2000

/obj/item/target/clown/bullet_act(obj/projectile/proj)
	. = ..()
	playsound(src, 'sound/items/bikehorn.ogg', 50, TRUE)
