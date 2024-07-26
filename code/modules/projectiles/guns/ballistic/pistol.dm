/obj/item/gun/ballistic/automatic/pistol
	name = "\improper Makarov pistol"
	desc = "A small, easily concealable 9mm handgun. Has a threaded barrel for suppressors."
	icon_state = "pistol"
	w_class = WEIGHT_CLASS_SMALL
	accepted_magazine_type = /obj/item/ammo_box/magazine/m9mm
	can_suppress = TRUE
	burst_size = 1
	fire_delay = 0
	actions_types = list()
	bolt_type = BOLT_TYPE_LOCKING
	fire_sound = 'sound/weapons/gun/pistol/shot.ogg'
	dry_fire_sound = 'sound/weapons/gun/pistol/dry_fire.ogg'
	suppressed_sound = 'sound/weapons/gun/pistol/shot_suppressed.ogg'
	load_sound = 'sound/weapons/gun/pistol/mag_insert.ogg'
	load_empty_sound = 'sound/weapons/gun/pistol/mag_insert.ogg'
	eject_sound = 'sound/weapons/gun/pistol/mag_release.ogg'
	eject_empty_sound = 'sound/weapons/gun/pistol/mag_release.ogg'
	rack_sound = 'sound/weapons/gun/pistol/rack_small.ogg'
	lock_back_sound = 'sound/weapons/gun/pistol/lock_small.ogg'
	bolt_drop_sound = 'sound/weapons/gun/pistol/drop_small.ogg'
	fire_sound_volume = 90
	bolt_wording = "slide"
	suppressor_x_offset = 10
	suppressor_y_offset = -1

/obj/item/gun/ballistic/automatic/pistol/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/pistol/fire_mag
	spawn_magazine_type = /obj/item/ammo_box/magazine/m9mm/fire

/obj/item/gun/ballistic/automatic/pistol/contraband

/obj/item/gun/ballistic/automatic/pistol/contraband/Initialize(mapload)
	if(prob(10))
		pin = pick(
		list(
			/obj/item/firing_pin/clown,
			/obj/item/firing_pin/clown/ultra,
			/obj/item/firing_pin/clown/ultra/selfdestruct,
		))
	. = ..()
	pin.pin_removable = FALSE


/obj/item/gun/ballistic/automatic/pistol/suppressed/Initialize(mapload)
	. = ..()
	var/obj/item/suppressor/S = new(src)
	install_suppressor(S)

/obj/item/gun/ballistic/automatic/pistol/clandestine
	name = "\improper Ansem pistol"
	desc = "The spiritual successor of the Makarov, or maybe someone just dropped their gun in a bucket of paint. The gun is chambered in 10mm."
	icon_state = "pistol_evil"
	accepted_magazine_type = /obj/item/ammo_box/magazine/m10mm
	empty_indicator = TRUE
	suppressor_x_offset = 12

/obj/item/gun/ballistic/automatic/pistol/clandestine/fisher
	name = "\improper Ansem/SC pistol"
	desc = "A modified variant of the Ansem, spiritual successor to the Makarov, featuring an integral suppressor and push-button trigger on the grip \
	for an underbarrel-mounted disruptor, similar in operation to the standalone SC/FISHER. Chambered in 10mm."
	desc_controls = "Right-click to use the underbarrel disruptor. Two shots maximum between self-charges."
	icon_state = "pistol_evil_fisher"
	suppressed = TRUE
	can_suppress = FALSE
	can_unsuppress = FALSE
	var/obj/item/gun/energy/recharge/fisher/underbarrel

/obj/item/gun/ballistic/automatic/pistol/clandestine/fisher/examine_more(mob/user)
	. = ..()
	. += span_notice("The Ansem/SC is a Scarborough Arms-manufactured overhaul suite for the also Scarborough Arms-manufactured Ansem handgun, designed for special \
	operators who like to operate operationally, and/or people who really, really hate lightbulbs, and tend to fight people who really like lightbulbs. \
	The slide is lengthened and has an integrated suppressor, while a compact kinetic light disruptor was mounted underneath the barrel. \
	Scarborough Arms has never actually officially responded to allegations that they're involved with the modification and/or manufacture \
	of the SC/FISHER or similar disruptor weapons. Operators are reminded that kinetic light disruptors do not actually physically harm targets.<br>\
	Caveat emptor.")

/obj/item/gun/ballistic/automatic/pistol/clandestine/fisher/Initialize(mapload)
	. = ..()
	underbarrel = new /obj/item/gun/energy/recharge/fisher(src)

/obj/item/gun/ballistic/automatic/pistol/clandestine/fisher/Destroy()
	QDEL_NULL(underbarrel)
	return ..()

/obj/item/gun/ballistic/automatic/pistol/clandestine/fisher/try_fire_gun(atom/target, mob/living/user, params)
	if(LAZYACCESS(params2list(params), RIGHT_CLICK))
		return underbarrel.try_fire_gun(target, user, params)
	return ..()

/obj/item/gun/ballistic/automatic/pistol/clandestine/fisher/afterattack(atom/target, mob/user, click_parameters)
	var/obj/projectile/energy/fisher/melee/simulated_hit = new
	simulated_hit.firer = user
	simulated_hit.on_hit(target)

/obj/item/gun/ballistic/automatic/pistol/clandestine/fisher/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(.)
		return
	var/obj/projectile/energy/fisher/melee/simulated_hit = new
	simulated_hit.firer = throwingdatum.get_thrower()
	simulated_hit.on_hit(hit_atom)

/obj/item/gun/ballistic/automatic/pistol/m1911
	name = "\improper M1911"
	desc = "A classic .45 handgun with a small magazine capacity."
	icon_state = "m1911"
	w_class = WEIGHT_CLASS_NORMAL
	accepted_magazine_type = /obj/item/ammo_box/magazine/m45
	can_suppress = FALSE
	fire_sound = 'sound/weapons/gun/pistol/shot_alt.ogg'
	rack_sound = 'sound/weapons/gun/pistol/rack.ogg'
	lock_back_sound = 'sound/weapons/gun/pistol/slide_lock.ogg'
	bolt_drop_sound = 'sound/weapons/gun/pistol/slide_drop.ogg'

/**
 * Weak 1911 for syndicate chimps. It comes in a 4 TC kit.
 * 15 damage every.. second? 7 shots to kill. Not fast.
 */
/obj/item/gun/ballistic/automatic/pistol/m1911/chimpgun
	name = "\improper CH1M911"
	desc = "For the monkey mafioso on-the-go. Uses .45 rounds and has the distinct smell of bananas."
	projectile_damage_multiplier = 0.5
	projectile_wound_bonus = -12
	pin = /obj/item/firing_pin/monkey


/obj/item/gun/ballistic/automatic/pistol/m1911/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/pistol/deagle
	name = "\improper Desert Eagle"
	desc = "A robust .50 AE handgun."
	icon_state = "deagle"
	force = 14
	accepted_magazine_type = /obj/item/ammo_box/magazine/m50
	can_suppress = FALSE
	mag_display = TRUE
	fire_sound = 'sound/weapons/gun/rifle/shot.ogg'
	rack_sound = 'sound/weapons/gun/pistol/rack.ogg'
	lock_back_sound = 'sound/weapons/gun/pistol/slide_lock.ogg'
	bolt_drop_sound = 'sound/weapons/gun/pistol/slide_drop.ogg'

/obj/item/gun/ballistic/automatic/pistol/deagle/contraband

/obj/item/gun/ballistic/automatic/pistol/deagle/contraband/Initialize(mapload)
	if(prob(10))
		pin = pick(
		list(
			/obj/item/firing_pin/clown,
			/obj/item/firing_pin/clown/ultra,
			/obj/item/firing_pin/clown/ultra/selfdestruct,
		))
	. = ..()
	pin.pin_removable = FALSE

/obj/item/gun/ballistic/automatic/pistol/deagle/gold
	desc = "A gold plated Desert Eagle folded over a million times by superior martian gunsmiths. Uses .50 AE ammo."
	icon_state = "deagleg"
	inhand_icon_state = "deagleg"

/obj/item/gun/ballistic/automatic/pistol/deagle/camo
	desc = "A Deagle brand Deagle for operators operating operationally. Uses .50 AE ammo."
	icon_state = "deaglecamo"
	inhand_icon_state = "deagleg"

/obj/item/gun/ballistic/automatic/pistol/deagle/regal
	name = "\improper Regal Condor"
	desc = "Unlike the Desert Eagle, this weapon seems to utilize some kind of advanced internal stabilization system to significantly \
		reduce felt recoil and increase overall accuracy, at the cost of using a smaller caliber. \
		This does allow it to fire a very quick 2-round burst. Uses 10mm ammo."
	icon_state = "reagle"
	inhand_icon_state = "deagleg"
	burst_size = 2
	fire_delay = 1
	projectile_damage_multiplier = 1.25
	accepted_magazine_type = /obj/item/ammo_box/magazine/r10mm
	actions_types = list(/datum/action/item_action/toggle_firemode)
	obj_flags = UNIQUE_RENAME // if you did the sidequest, you get the customization

/obj/item/gun/ballistic/automatic/pistol/aps
	name = "\improper Stechkin APS machine pistol"
	desc = "An old Soviet machine pistol. It fires quickly, but kicks like a mule. Uses 9mm ammo. Has a threaded barrel for suppressors."
	icon_state = "aps"
	w_class = WEIGHT_CLASS_NORMAL
	accepted_magazine_type = /obj/item/ammo_box/magazine/m9mm_aps
	can_suppress = TRUE
	burst_size = 3
	fire_delay = 1
	spread = 10
	actions_types = list(/datum/action/item_action/toggle_firemode)
	suppressor_x_offset = 6

/obj/item/gun/ballistic/automatic/pistol/stickman
	name = "flat gun"
	desc = "A 2 dimensional gun.. what?"
	icon_state = "flatgun"
	mag_display = FALSE
	show_bolt_icon = FALSE

/obj/item/gun/ballistic/automatic/pistol/stickman/equipped(mob/user, slot)
	..()
	to_chat(user, span_notice("As you try to manipulate [src], it slips out of your possession.."))
	if(prob(50))
		to_chat(user, span_notice("..and vanishes from your vision! Where the hell did it go?"))
		qdel(src)
		user.update_icons()
	else
		to_chat(user, span_notice("..and falls into view. Whew, that was a close one."))
		user.dropItemToGround(src)
