/atom/movable/screen/fullscreen/uncanny_cat
	icon = 'newstuff/nikitauou/icons/uncanny.dmi'
	icon_state = "uncanny_cat"
	show_when_dead = TRUE

/datum/smite/uncanny_cat
	name = "Uncanny cat"

/datum/smite/uncanny_cat/effect(client/user, mob/living/target)
	. = ..()
	target.uncanny_cat(5 SECONDS)

/mob/living/proc/uncanny_cat(paralyze_time = 0)
	src.overlay_fullscreen("uncanny_cat", /atom/movable/screen/fullscreen/uncanny_cat)
	src.Paralyze(paralyze_time)
	SEND_SOUND(src, sound('newstuff/nikitauou/sound/stalkerscream.mp3'))
	sleep(5)
	src.clear_fullscreen("uncanny_cat", animated = 5)

/obj/item/gun/magic/wand/uncanny
	name = "Жезл ужаса"
	desc = "stalkerscream.mp3"
	icon = 'newstuff/nikitauou/icons/guns.dmi'
	base_icon_state = "uncanny"
	icon_state = "uncanny"
	ammo_type = /obj/item/ammo_casing/magic/uncanny
	variable_charges = FALSE
	max_charges = 100

/obj/item/ammo_casing/magic/uncanny
	projectile_type = /obj/projectile/magic/uncanny

/obj/projectile/magic/uncanny
	name = "Снаряд ужаса"
	icon = 'newstuff/nikitauou/icons/projectiles.dmi'
	icon_state = "uncanny"

/obj/projectile/magic/uncanny/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(isliving(target))
		var/mob/living/M = target
		M.uncanny_cat(1 SECONDS)

/obj/item/gun/magic/wand/uncanny/zap_self(mob/living/target)
	. = ..()
	charges--
	if(isliving(target))
		target.uncanny_cat(1 SECONDS)

