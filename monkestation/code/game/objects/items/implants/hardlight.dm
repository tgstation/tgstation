/*/obj/item/implant/hard_spear
	name = "hardlight spear implant"
	icon = 'monkestation/icons/obj/implants.dmi'
	icon_state = "lightspear" //Shows up as the action button icon
	implant_color = "b"
	uses = -1
	COOLDOWN_DECLARE(hardlight_implant_cooldown)

/obj/item/implant/hard_spear/activate()
	if(!COOLDOWN_FINISHED(src, hardlight_implant_cooldown)) //Thanks implant_abductor.dm for the help <3
		to_chat(imp_in, "<span class='warning'>You must wait [COOLDOWN_TIMELEFT(src, hardlight_implant_cooldown)*0.1] seconds to use [src] again!</span>")
		return

	var/obj/item/spear/hardlight_spear/summoned_spear
	summoned_spear = new /obj/item/spear/hardlight_spear(imp_in.loc)
	if(imp_in.put_in_hands(summoned_spear,TRUE))
		to_chat(imp_in, "<span class='notice'>A spear manifests in your hand.</span>")
		playsound(imp_in, 'sound/weapons/saberon.ogg', 35, 1)
		QDEL_IN(summoned_spear, 10 SECONDS)
		COOLDOWN_START(src, hardlight_implant_cooldown, 20 SECONDS)
	else
		to_chat(imp_in, "<span class='warning'>You must have a free hand to summon a spear!</span>")
		return
*/
/datum/action/cooldown/spell/conjure_item/hardlight_spear
	school = SCHOOL_CONJURATION
	cooldown_time = 20 SECONDS

	invocation_type = INVOCATION_NONE

	item_type = /obj/item/gun/ballistic/rifle
	delete_old = FALSE

/obj/item/implanter/hard_spear
	name = "implanter (hardlight spear)"
	imp_type = /obj/item/implant/hard_spear

/obj/item/implantcase/hard_spear
	name = "implant case - 'Hardlight Spear'"
	desc = "A glass case containing a hardlight spear implant."
	imp_type = /obj/item/implant/hard_spear

/*/obj/item/spear/hardlight_spear
	icon = 'monkestation/icons/obj/items_and_weapons.dmi'
	icon_state = "lightspear"
	inhand_icon_state = "lightspear"
	icon_prefix = "lightspear"
	worn_icon_state = "none"
	lefthand_file = 'monkestation/icons/mob/inhands/polearms_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/polearms_righthand.dmi'
	name = "hardlight spear"
	desc = "A spear made out of hardened light."
	force = 15
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = NONE
	light_system = MOVABLE_LIGHT
	light_outer_range = 3
	light_power = 1
	throwforce = 25
	throw_speed = 6
	armour_penetration = 18
	hitsound = 'sound/weapons/blade1.ogg'
	sharpness = SHARP_POINTY

/obj/item/spear/hardlight_spear/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(hit_atom && !QDELETED(hit_atom))
		if(istype(hit_atom, /mob/living)) //Living mobs handle hit sounds differently.
			var/volume = get_volume_by_throwforce_and_or_w_class()
			playsound(hit_atom, 'sound/weapons/genhit.ogg',volume, TRUE, -1)
		else
			playsound(src, drop_sound, 60, ignore_walls = FALSE)
		qdel(src) //Deletes when it gets thrown at somethign
		return hit_atom.hitby(src, 0, 0, throwingdatum=throwingdatum)

/obj/item/spear/hardlight_spear/unembedded()
	. = ..()
	QDEL_NULL(src) //Deletes itself when unembedded
	return TRUE
*/
/obj/item/gun/magic/hardlight_spear //listen man
	name = "hardlight spear"
	desc = "A spear made out of hardened light."
	fire_sound = 'sound/weapons/emitter.ogg'
	pin = /obj/item/firing_pin/magic
	force = 15
	armour_penetration = 18
	sharpness = SHARP_POINTY
	w_class = WEIGHT_CLASS_HUGE
	antimagic_flags = NONE
	hitsound = 'sound/weapons/blade1.ogg'
	icon = 'monkestation/icons/obj/items_and_weapons.dmi'
	icon_state = "lightspear"
	inhand_icon_state = "lightspear"
	worn_icon_state = "none"
	lefthand_file = 'monkestation/icons/mob/inhands/polearms_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/polearms_righthand.dmi'
	slot_flags = null
	can_charge = FALSE
	can_bayonet = FALSE //ITS A SPEAR
	item_flags = NEEDS_PERMIT | DROPDEL | ABSTRACT | NO_MAT_REDEMPTION
	var/spears_left = 5
	max_charges = spears_left
	ammo_type = /obj/item/ammo_casing/magic/hardlight_spear

/obj/item/gun/magic/hardlight_spear/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/jousting)

	AddComponent(/datum/component/butchering, \
		speed = 10 SECONDS, \
		effectiveness = 70, \
	)

/obj/item/gun/magic/hardlight_spear/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	. = ..()
	if(!.)
		return
	if(spears_left)
		var/obj/item/gun/magic/hardlight_spear/spear = new type
		spear.spears_left = spears_left - 1
		qdel(src)
		user.put_in_hands(spear)
	else
		user.dropItemToGround(src, TRUE)

/obj/projectile/bullet/hardlight_spear
	name = "hardlight spear"
	icon_state = "gauss"
	damage = 35
	armour_penetration = 50
	bare_wound_bonus = 80
	wound_falloff_tile = -5
	shrapnel_type = /obj/item/shrapnel/bullet/spear
	embedding = list(embed_chance=100, fall_chance=3, jostle_chance=4, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.4, pain_mult=5, jostle_pain_mult=6, rip_time=10)

/obj/item/shrapnel/bullet/spear
	name = "hardlight spear"
	icon = 'monkestation/icons/obj/items_and_weapons.dmi'
	icon_state = "lightspear"
/obj/item/shrapnel/bullet/spear/unembedded()
	. = ..()
	QDEL_NULL(src) //Deletes itself when unembedded
	return TRUE
