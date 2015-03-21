/obj/item/weapon/gun/projectile/rocketlauncher
	name = "rocket launcher"
	desc = "Ranged explosions, science marches on."
	fire_sound = 'sound/weapons/shotgun.ogg'
	icon_state = "rpg"
	item_state = "rpg"
	max_shells = 1
	w_class = 4.0
	m_amt = 5000
	w_type = RECYK_METAL
	force = 10
	recoil = 5
	throw_speed = 4
	throw_range = 3
	fire_delay = 5
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BACK
	caliber = list("rpg" = 1)
	origin_tech = "combat=4;materials=2;syndicate=2"
	ammo_type = "/obj/item/ammo_casing/rocket_rpg"
	attack_verb = list("struck", "hit", "bashed")

	gun_flags = 0

/obj/item/weapon/gun/projectile/rocketlauncher/isHandgun()
	return 0

/obj/item/weapon/gun/projectile/rocketlauncher/update_icon()
	if(!getAmmo())
		icon_state = "rpg_e"
		item_state = "rpg_e"
	else
		icon_state = "rpg"
		item_state = "rpg"

/obj/item/weapon/gun/projectile/rocketlauncher/attack(mob/living/M as mob, mob/living/user as mob, def_zone)
	if(M == user && user.zone_sel.selecting == "mouth") //Are we trying to suicide by shooting our head off ?
		user.visible_message("<span class='warning'>[user] tries to fit \the [src] into \his mouth but quickly reconsiders it</span>", \
		"<span class='warning'>You try to fit \the [src] into your mouth. You feel silly and pull it out</span>")
		return // Nope
	..()

/obj/item/weapon/gun/projectile/rocketlauncher/suicide_act(var/mob/user)
	if(!src.process_chambered()) //No rocket in the rocket launcher
		user.visible_message("<span class='danger'>[user] jams down \the [src]'s trigger before noticing it isn't loaded and starts bashing \his head in with it! It looks like \he's trying to commit suicide.</span>")
		return(BRUTELOSS)
	else //Needed to get that shitty default suicide_act out of the way
		user.visible_message("<span class='danger'>[user] fiddles with \the [src]'s safeties and suddenly aims it at \his feet! It looks like \he's trying to commit suicide.</span>")
		spawn(10) //RUN YOU IDIOT, RUN
			explosion(src.loc, -1, 1, 4, 8)
			if(src) //Is the rocket launcher somehow still here ?
				qdel(src) //This never happened
			return(BRUTELOSS)
	return

