/obj/item/gun/ballistic/revolver
	fire_sound = 'hippiestation/sound/weapons/gunshot_magnum.ogg'

/obj/item/gun/ballistic/revolver/detective
    fire_sound = 'hippiestation/sound/weapons/gunshot_38special.ogg'
    interact_sound_cooldown = 50
    pullout_sound = 'hippiestation/sound/weapons/mysterious_out.ogg'
    putaway_sound = 'hippiestation/sound/weapons/mysterious_in.ogg'

/obj/item/gun/ballistic/revolver/doublebarrel
	fire_sound = 'hippiestation/sound/weapons/shotgun_shoot.ogg'

/obj/item/gun/ballistic/revolver/detective/try_play_interact_sound(mob/user)
	if (istype(user.loc, /turf))
		var/lumcount = user.loc.get_lumcount()

		if (lumcount >= 0.4) // Don't wait to spook people in maint when you pull out your shooter
			if (src in user.held_items)
				if (interact_sound_timeout < world.time && pullout_sound)
					playsound(user, pullout_sound, 50, 0)
					interact_sound_timeout = world.time + interact_sound_cooldown
			else
				if (interact_sound_timeout < world.time && putaway_sound)
					playsound(user, putaway_sound, 50, 0)
					interact_sound_timeout = world.time + interact_sound_cooldown