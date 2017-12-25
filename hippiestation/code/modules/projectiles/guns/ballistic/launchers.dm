/obj/item/gun/ballistic/crossbow
    name = "crossbow"
    desc = "A powerful crossbow, capable of shooting metal rods. Very effective for hunting."
    icon = 'hippiestation/icons/obj/guns/crossbow.dmi'
    icon_state = "crossbow_body"
    item_state = "crossbow_body"
    lefthand_file = 'hippiestation/icons/mob/inhands/lefthand.dmi'
    righthand_file = 'hippiestation/icons/mob/inhands/righthand.dmi'
    w_class = WEIGHT_CLASS_BULKY
    force = 10
    flags_1 = CONDUCT_1
    slot_flags = SLOT_BACK
    fire_sound = "hippiestation/sound/weapons/rodgun_fire.ogg"
    var/charge = 0
    var/max_charge = 3
    var/charging = FALSE
    var/charge_time = 10
    var/draw_sound = "sound/weapons/draw_bow.ogg"
    var/insert_sound = "sound/weapons/bulletinsert.ogg"
    weapon_weight = WEAPON_MEDIUM
    spawnwithmagazine = FALSE
    casing_ejector = FALSE

/obj/item/gun/ballistic/crossbow/attackby(obj/item/A, mob/living/user, params)
    if (!chambered)
        if (charge > 0)
            if (istype(A, /obj/item/stack/rods))
                var/obj/item/stack/rods/R = A
                if (R.use(1))
                    chambered = new /obj/item/ammo_casing/rod
                    var/obj/item/projectile/rod/PR = chambered.BB

                    if (PR)
                        PR.range = PR.range * charge
                        PR.damage = PR.damage * charge
                        PR.charge = charge

                    playsound(user, insert_sound, 50, 1)

                    user.visible_message("<span class='notice'>[user] carefully places the [chambered.BB] into the [src].</span>", \
                                         "<span class='notice'>You carefully place the [chambered.BB] into the [src].</span>")
        else
            to_chat(user, "<span class='warning'>You need to draw the bow string before loading a bolt!</span>")
    else
        to_chat(user, "<span class='warning'>There's already a [chambered.BB] loaded!<span>")

    update_icon()
    return

/obj/item/gun/ballistic/crossbow/process_chamber(empty_chamber = 0)
    chambered = null
    charge = 0
    update_icon()
    return

/obj/item/gun/ballistic/crossbow/chamber_round()
    return

/obj/item/gun/ballistic/crossbow/can_shoot()
    if (!chambered)
        return

    if (charge <= 0)
        return

    return (chambered.BB ? 1 : 0)

/obj/item/gun/ballistic/crossbow/attack_self(mob/living/user)
    if (!chambered)
        if (charge < 3)
            if (charging)
                return

            charging = TRUE

            playsound(user, draw_sound, 50, 1)

            if (do_after(user, charge_time, 0, user) && charging)
                charge = charge + 1
                charging = FALSE

                var/draw = "a little"

                if (charge > 2)
                    draw = "fully"
                else if (charge > 1)
                    draw = "further"

                user.visible_message("<span class='notice'>[user] pulls the drawstring back [draw].</span>", \
                                     "<span class='notice'>You draw the bow string back [draw].</span>")
            else
                charging = FALSE
        else
            to_chat(user, "<span class='warning'>The bow string is fully drawn!</span>")
    else
        user.visible_message("<span class='notice'>[user] removes the [chambered.BB] from the [src].</span>", \
                             "<span class='notice'>You remove the [chambered.BB] from the [src].</span>")
        user.put_in_hands(new /obj/item/stack/rods)
        chambered = null
        playsound(user, insert_sound, 50, 1)

    update_icon()
    charging = FALSE
    return

/obj/item/gun/ballistic/crossbow/examine(mob/user)
    ..()

    var/bowstring = "The bow string is "

    if (charge > 2)
        bowstring = bowstring + "drawn back fully"
    else if (charge > 1)
        bowstring = bowstring + "drawn back most the way"
    else if (charge > 0)
        bowstring = bowstring + "drawn back a little"
    else
        bowstring = bowstring + "not drawn"

    to_chat(user, "[bowstring][charge > 2 ? "!" : "."]")

    if (chambered.BB)
        to_chat(user, "A [chambered.BB] is loaded.")

/obj/item/gun/ballistic/crossbow/update_icon()
    ..()

    if (charge >= max_charge)
        add_overlay("charge_[max_charge]")
    else if (charge < 1)
        add_overlay("charge_0")
    else
        add_overlay("charge_[charge]")

    if (chambered && charge > 0)
        if (charge >= max_charge)
            add_overlay("rod_[max_charge]")
        else
            add_overlay("rod_[charge]")

    return

/obj/item/gun/ballistic/crossbow/improv
    name = "improvised crossbow"
    desc = "A poorly-built improvised crossbow, probably couldn't even hurt small game."
    icon_state = "crossbow_body_improv"
    item_state = "crossbow_body_improv"
    charge_time = 20