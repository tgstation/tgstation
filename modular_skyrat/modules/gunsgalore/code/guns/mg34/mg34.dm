/obj/item/gun/ballistic/automatic/mg34
	name = "\improper MG-9 GPMG"
	desc = "A reproduction of the German MG-3 general purpose machine gun, this one is a revision from the 2200's and was one of several thousand distributed to SolFed expedition teams. It has been rechambered to fire 7.92mm Mauser instead of 7.62mm NATO."
	icon = 'modular_skyrat/modules/gunsgalore/icons/guns/mg34/mg34.dmi'
	lefthand_file = 'modular_skyrat/modules/gunsgalore/icons/guns/mg34/mg34_lefthand.dmi'
	righthand_file = 'modular_skyrat/modules/gunsgalore/icons/guns/mg34/mg34_righthand.dmi'
	worn_icon = 'modular_skyrat/modules/gunsgalore/icons/guns/mg34/mg34_back.dmi'
	icon_state = "mg34"
	base_icon_state = "mg34"
	worn_icon_state = "mg34"
	inhand_icon_state = "mg34"
	fire_select_modes = list(SELECT_SEMI_AUTOMATIC, SELECT_FULLY_AUTOMATIC)
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_HUGE
	spread = 15
	mag_type = /obj/item/ammo_box/magazine/mg34
	fire_sound = 'modular_skyrat/modules/gunsgalore/sound/guns/fire/mg34/mg34.ogg'
	fire_sound_volume = 70
	can_suppress = FALSE
	fire_delay = 1
	realistic = TRUE
	dirt_modifier = 0.1
	bolt_type = BOLT_TYPE_OPEN
	show_bolt_icon = FALSE
	tac_reloads = FALSE
	fire_sound = 'sound/weapons/gun/l6/shot.ogg'
	rack_sound = 'sound/weapons/gun/l6/l6_rack.ogg'
	suppressed_sound = 'sound/weapons/gun/general/heavy_shot_suppressed.ogg'
	var/cover_open = FALSE


/obj/item/gun/ballistic/automatic/mg34/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/gun/ballistic/automatic/mg34/examine(mob/user)
	. = ..()
	. += "<b>alt + click</b> to [cover_open ? "close" : "open"] the dust cover."
	if(cover_open && magazine)
		. += "<span class='notice'>It seems like you could use an <b>empty hand</b> to remove the magazine.</span>"


/obj/item/gun/ballistic/automatic/mg34/AltClick(mob/user)
	. = ..()
	if(!user.canUseTopic(src))
		return
	cover_open = !cover_open
	to_chat(user, "<span class='notice'>You [cover_open ? "open" : "close"] [src]'s cover.</span>")
	playsound(src, 'sound/weapons/gun/l6/l6_door.ogg', 60, TRUE)
	update_appearance()

/obj/item/gun/ballistic/automatic/mg34/update_icon_state()
	. = ..()
	inhand_icon_state = "[base_icon_state][cover_open ? "open" : "closed"][magazine ? "mag":"nomag"]"

/obj/item/gun/ballistic/automatic/mg34/update_overlays()
	. = ..()
	. += "[base_icon_state]_door_[cover_open ? "open" : "closed"]"


/obj/item/gun/ballistic/automatic/mg34/afterattack(atom/target as mob|obj|turf, mob/living/user as mob|obj, flag, params)
	if(cover_open)
		to_chat(user, "<span class='warning'>[src]'s cover is open! Close it before firing!</span>")
		return
	else
		. = ..()
		update_appearance()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/gun/ballistic/automatic/mg34/attack_hand(mob/user, list/modifiers)
	if (loc != user)
		..()
		return
	if (!cover_open)
		to_chat(user, "<span class='warning'>[src]'s cover is closed! Open it before trying to remove the magazine!</span>")
		return
	..()

/obj/item/gun/ballistic/automatic/mg34/attackby(obj/item/A, mob/user, params)
	if(!cover_open && istype(A, mag_type))
		to_chat(user, "<span class='warning'>[src]'s dust cover prevents a magazine from being fit.</span>")
		return
	..()

/obj/item/ammo_box/magazine/mg34
	name = "mg9 drum (7.92×57mm)"
	icon = 'modular_skyrat/modules/gunsgalore/icons/guns/mg34/mg34.dmi'
	icon_state = "mg34_drum"
	ammo_type = /obj/item/ammo_casing/realistic/a792x57
	caliber = "a792x57"
	max_ammo = 75
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/gun/ballistic/automatic/mg34/packapunch //INFINITY GUNNNNNNNN
	name = "MG34 UBER"
	desc = "Here, there, seems like everywhere. Nasty things are happening, now everyone is scared. Old Jeb Brown the Blacksmith, he saw his mother die. A critter took a bite from her and now she's in the sky. "
	icon_state = "mg34_packapunch"
	base_icon_state = "mg34_packapunch"
	worn_icon_state = "mg34_packapunch"
	inhand_icon_state = "mg34_packapunch"
	fire_delay = 0.04
	burst_size = 5
	spread = 5
	dirt_modifier = 0
	durability = 500
	mag_type = /obj/item/ammo_box/magazine/mg34/packapunch

/obj/item/ammo_box/magazine/mg34/packapunch
	max_ammo = 999
	multiple_sprites = AMMO_BOX_ONE_SPRITE

/obj/item/gun/ballistic/automatic/mg34/packapunch/process_chamber(empty_chamber, from_firing, chamber_next_round)
	. = ..()
	magazine.top_off()
