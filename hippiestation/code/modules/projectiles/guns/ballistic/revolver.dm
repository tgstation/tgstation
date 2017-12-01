/obj/item/gun/ballistic/revolver
	fire_sound = 'hippiestation/sound/weapons/gunshot_magnum.ogg'

/obj/item/gun/ballistic/revolver/detective
	fire_sound = 'hippiestation/sound/weapons/gunshot_38special.ogg'

/obj/item/gun/ballistic/revolver/doublebarrel
	fire_sound = 'hippiestation/sound/weapons/shotgun_shoot.ogg'

/obj/item/gun/ballistic/revolver/detective
    var/interact_sound_timeout = 0
    var/interact_sound_cooldown = 50 // How long before we can play these sounds again
    var/pullout_sound = 'hippiestation/sound/weapons/mysterious_out.ogg'
    var/putaway_sound = 'hippiestation/sound/weapons/mysterious_in.ogg'

/obj/item/gun/ballistic/revolver/detective/pickup(mob/user)
    ..()

    addtimer(CALLBACK(src, .proc/check_location, user), 1)

/obj/item/gun/ballistic/revolver/detective/dropped(mob/user)
    ..()

    addtimer(CALLBACK(src, .proc/check_location, user), 1)

/obj/item/gun/ballistic/revolver/detective/equipped(mob/user, slot)
    ..()

    addtimer(CALLBACK(src, .proc/check_location, user), 1)

// Because of how pickup() and dropped() are handled I need to wait a very short time before finding where the item goes
/obj/item/gun/ballistic/revolver/detective/proc/check_location(mob/user)
    if (src in user.held_items)
        if (interact_sound_timeout < world.time)
            playsound(user, pullout_sound, 50, 0)
            interact_sound_timeout = world.time + interact_sound_cooldown
    else
        if (interact_sound_timeout < world.time)
            playsound(user, putaway_sound, 50, 0)
            interact_sound_timeout = world.time + interact_sound_cooldown

