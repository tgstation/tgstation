/obj/item/gun/ballistic/revolver
	fire_sound = 'hippiestation/sound/weapons/gunshot_magnum.ogg'

/obj/item/gun/ballistic/revolver/detective
    fire_sound = 'hippiestation/sound/weapons/gunshot_38special.ogg'
    interact_sound_cooldown = 50
    pickup_sound = 'hippiestation/sound/weapons/mysterious_out.ogg'
    dropped_sound = 'hippiestation/sound/weapons/mysterious_in.ogg'

/obj/item/gun/ballistic/revolver/doublebarrel
	fire_sound = 'hippiestation/sound/weapons/shotgun_shoot.ogg'

/obj/item/gun/ballistic/revolver/detective/try_play_interact_sound(mob/user)
	if (istype(user.loc, /turf))
		var/turf/T = user.loc
		if (T)
			var/lumcount = T.get_lumcount()

			if (lumcount >= 0.4) // Don't wait to spook people in maint when you pull out your shooter
				..()