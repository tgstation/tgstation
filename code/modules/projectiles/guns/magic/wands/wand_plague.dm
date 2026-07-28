/// Makes the target cough out frogs and locusts and such
/obj/item/gun/magic/wand/plague
	name = "pestilent wand"
	desc = "A vile implement which forces its victims' bodies to disgorge frogs and insects."
	school = SCHOOL_CONJURATION
	ammo_type = /obj/item/ammo_casing/magic/plague
	icon_state = "plaguewand"
	base_icon_state = "plaguewand"
	fire_sound = 'sound/effects/smoke.ogg'
	max_charges = 6

/obj/item/gun/magic/wand/plague/zap_self(mob/living/user, suicide)
	. = ..()
	var/obj/projectile/magic/plague/germ = new(user.drop_location())
	germ.firer = user
	user.projectile_hit(germ, BODY_ZONE_CHEST)
	qdel(germ)
	charges--

/obj/item/gun/magic/wand/plague/do_suicide(mob/living/user)
	. = ..()

	new /obj/effect/temp_visual/circle_wave/bioscrambler(get_turf(src))
	var/datum/disease/verminous_plague/curse = new()
	for(var/mob/living/carbon/human/infectee in (hearers(2, user) - user))
		infectee.ContactContractDisease(curse)

	return TOXLOSS

/obj/item/ammo_casing/magic/plague
	projectile_type = /obj/projectile/magic/plague

/// Makes the target sick with frogs
/obj/projectile/magic/plague
	name = "pestilent bolt"
	icon_state = "blastwave"
	damage = 20
	damage_type = TOX

/obj/projectile/magic/plague/on_hit(mob/living/carbon/human/target, blocked, pierce_hit)
	. = ..()
	if (. == BULLET_ACT_BLOCK || !istype(target) || blocked >= 100)
		return
	target.ContactContractDisease(new /datum/disease/verminous_plague())
	var/datum/disease/verminous_plague/curse = locate() in target.diseases
	if (!QDELETED(curse))
		if (curse.stage < 2)
			curse.update_stage(2)
		else
			curse.spawn_mob()
