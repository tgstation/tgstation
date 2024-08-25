//Finger Guns *blows smoke off his finger tips*
/datum/emote/living/carbon/fingergun
	key = "fingergun"
	key_third_person = "fingerguns"
	hands_use_check = TRUE
	cooldown = 3 SECONDS

/datum/emote/living/carbon/fingergun/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return
	var/obj/item/gun/ballistic/fingergun_emote/N = new(user)
	if(user.put_in_hands(N))
		to_chat(user, span_notice("You fold your hand into a finger gun."))
		user.manual_emote("folds [user.p_their()] hand into a finger gun.")
	else
		qdel(N)
		to_chat(user, span_warning("You're incapable of readying a finger gun in your current state."))

/obj/item/ammo_casing/caseless/fingergun_bullet
	name = "imaginary bullet"
	desc = "Bullets are not real idiot."
	projectile_type = /obj/projectile/bullet/fingergun_bullet
	item_flags = DROPDEL
	caliber = "bulletsarenotrealyouidiot"
	custom_materials = list()
	harmful = FALSE

/obj/projectile/bullet/fingergun_bullet
	name = "imaginary bullet"
	desc = "Bullets are not real idiot."
	icon = 'monkestation/icons/obj/weapons/guns/fingergun_emote.dmi'
	icon_state = "projectile"
	damage = 0
	hitsound_wall = ""
	impact_effect_type = null
	embedding = list(embed_chance=0)

/obj/item/ammo_box/magazine/fingergun_emote
	name = "finger gun magazine"
	desc = "You should not be seeing this..."
	ammo_type = /obj/item/ammo_casing/caseless/fingergun_bullet
	caliber = "bulletsarenotrealyouidiot"
	max_ammo = 8

/obj/item/gun/ballistic/fingergun_emote
	name = "finger gun"
	desc = "''Ya' need a count?'' ''Nah sir.'' *abruptly gets shot in the head. ''Well.. that ain't good...'' *falls over backwards ''I should'a seen this comming.''"
	icon = 'monkestation/icons/obj/weapons/guns/fingergun_emote.dmi'
	icon_state = "item"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	inhand_icon_state = "nothing"
	item_flags = DROPDEL | HAND_ITEM | ABSTRACT
	force = 0
	throwforce = 0
	load_sound_volume = 0
	rack_sound_volume = 0
	lock_back_sound_volume = 0
	eject_sound_volume = 0
	bolt_drop_sound_volume = 0
	dry_fire_sound = ""
	pinless = TRUE
	clumsy_check = FALSE
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	gun_flags = NONE
	accepted_magazine_type = /obj/item/ammo_box/magazine/fingergun_emote
	spawnwithmagazine = TRUE
	internal_magazine = TRUE
	bolt_type = BOLT_TYPE_NO_BOLT
	fire_delay = 0.5

/obj/item/gun/ballistic/fingergun_emote/shoot_live_shot(mob/living/user, pointblank = 0, atom/pbtarget = null) //mostly copied from /obj/item/gun/proc/shoot_live_shot(
	if(!HAS_TRAIT(user, TRAIT_MIMING))
		user.say("'s hand flying upwards with imaginary recoil*BANG!")
	if(tk_firing(user))
		visible_message(
				span_danger("[src] fires itself[pointblank ? " point blank at [pbtarget]!" : "!"]"),
				vision_distance = COMBAT_MESSAGE_RANGE
		)
	else if(pointblank)
		user.visible_message(
				span_danger("[user] fires [src] point blank at [pbtarget]!"),
				span_danger("You fire [src] point blank at [pbtarget]!"),
		)
		to_chat(pbtarget, span_userdanger("[user] fires [src] point blank at you!"))
		if(pb_knockback > 0 && ismob(pbtarget))
			var/mob/PBT = pbtarget
			var/atom/throw_target = get_edge_target_turf(PBT, user.dir)
			PBT.throw_at(throw_target, pb_knockback, 2)
	else if(!tk_firing(user))
		user.visible_message(
				span_danger("[user] fires [src]!"),
				vision_distance = COMBAT_MESSAGE_RANGE,
				ignored_mobs = user
		)

/obj/item/gun/ballistic/fingergun_emote/attack_self()
	return

/obj/item/gun/ballistic/fingergun_emote/attackby()
	return

/obj/item/gun/ballistic/fingergun_emote/eject_magazine()
	return
