// For all of the items that are really just the user's hand used in different ways, mostly (all, really) from emotes

/obj/item/slapper
	name = "slapper"
	desc = "This is how real men fight."
	icon_state = "latexballon"
	inhand_icon_state = "nothing"
	force = 0
	throwforce = 0
	item_flags = DROPDEL | ABSTRACT | HAND_ITEM
	attack_verb_continuous = list("slaps")
	attack_verb_simple = list("slap")
	hitsound = 'sound/effects/snap.ogg'

/obj/item/slapper/attack(mob/M, mob/living/carbon/human/user)
	if(ishuman(M))
		var/mob/living/carbon/human/L = M
		if(L && L.dna && L.dna.species)
			L.dna.species.stop_wagging_tail(M)
	user.do_attack_animation(M)
	playsound(M, 'sound/weapons/slap.ogg', 50, TRUE, -1)
	user.visible_message("<span class='danger'>[user] slaps [M]!</span>",
	"<span class='notice'>You slap [M]!</span>",\
	"<span class='hear'>You hear a slap.</span>")
	return

/obj/item/noogie
	name = "noogie"
	desc = "Get someone in an aggressive grab then use this on them to ruin their day."
	icon_state = "latexballon"
	inhand_icon_state = "nothing"
	force = 0
	throwforce = 0
	item_flags = DROPDEL | ABSTRACT | HAND_ITEM

/obj/item/noogie/attack(mob/living/carbon/target, mob/living/carbon/human/user)
	if(!istype(target))
		to_chat(user, "<span class='warning'>You don't think you can give this a noogie!</span>")
		return

	if(!(target?.get_bodypart(BODY_ZONE_HEAD)) || user.pulling != target || user.grab_state < GRAB_AGGRESSIVE || user.getStaminaLoss() > 80)
		return FALSE

	var/obj/item/bodypart/head/the_head = target.get_bodypart(BODY_ZONE_HEAD)
	if((target.get_biological_state() != BIO_FLESH_BONE && target.get_biological_state() != BIO_JUST_FLESH) || !the_head.is_organic_limb())
		to_chat(user, "<span class='warning'>You can't noogie [target], [target.p_they()] [target.p_have()] no skin on [target.p_their()] head!</span>")
		return

	// [user] gives [target] a [prefix_desc] noogie[affix_desc]!
	var/brutal_noogie = FALSE // was it an extra hard noogie?
	var/prefix_desc = "rough"
	var/affix_desc = ""
	var/affix_desc_target = ""

	if(HAS_TRAIT(target, TRAIT_ANTENNAE))
		prefix_desc = "violent"
		affix_desc = "on [target.p_their()] sensitive antennae"
		affix_desc_target = "on your highly sensitive antennae"
		brutal_noogie = TRUE
	if(user.dna?.check_mutation(HULK))
		prefix_desc = "sickeningly brutal"
		brutal_noogie = TRUE

	var/message_others = "[prefix_desc] noogie[affix_desc]"
	var/message_target = "[prefix_desc] noogie[affix_desc_target]"

	user.visible_message("<span class='danger'>[user] begins giving [target] a [message_others]!</span>", "<span class='warning'>You start giving [target] a [message_others]!</span>", vision_distance=COMBAT_MESSAGE_RANGE, ignored_mobs=target)
	to_chat(target, "<span class='userdanger'>[user] starts giving you a [message_target]!</span>")

	if(!do_after(user, 1.5 SECONDS, target))
		to_chat(user, "<span class='warning'>You fail to give [target] a noogie!</span>")
		to_chat(target, "<span class='danger'>[user] fails to give you a noogie!</span>")
		return

	if(brutal_noogie)
		SEND_SIGNAL(target, COMSIG_ADD_MOOD_EVENT, "noogie_harsh", /datum/mood_event/noogie_harsh)
	else
		SEND_SIGNAL(target, COMSIG_ADD_MOOD_EVENT, "noogie", /datum/mood_event/noogie)

	noogie_loop(user, target, 0)

/// The actual meat and bones of the noogie'ing
/obj/item/noogie/proc/noogie_loop(mob/living/carbon/human/user, mob/living/carbon/target, iteration)
	if(!(target?.get_bodypart(BODY_ZONE_HEAD)) || user.pulling != target)
		return FALSE

	if(user.getStaminaLoss() > 80)
		to_chat(user, "<span class='warning'>You're too tired to continue giving [target] a noogie!</span>")
		to_chat(target, "<span class='danger'>[user] is too tired to continue giving you a noogie!</span>")
		return

	var/damage = rand(1, 5)
	if(HAS_TRAIT(target, TRAIT_ANTENNAE))
		damage += rand(3,7)
	if(user.dna?.check_mutation(HULK))
		damage += rand(3,7)

	if(damage >= 5)
		target.emote("scream")

	log_combat(user, target, "given a noogie to", addition = "([damage] brute before armor)")
	target.apply_damage(damage, BRUTE, BODY_ZONE_HEAD)
	user.adjustStaminaLoss(iteration + 5)
	playsound(get_turf(user), pick('sound/effects/rustle1.ogg','sound/effects/rustle2.ogg','sound/effects/rustle3.ogg','sound/effects/rustle4.ogg','sound/effects/rustle5.ogg'), 50)

	if(prob(33))
		user.visible_message("<span class='danger'>[user] continues noogie'ing [target]!</span>", "<span class='warning'>You continue giving [target] a noogie!</span>", vision_distance=COMBAT_MESSAGE_RANGE, ignored_mobs=target)
		to_chat(target, "<span class='userdanger'>[user] continues giving you a noogie!</span>")

	if(!do_after(user, 1 SECONDS + (iteration * 2), target))
		to_chat(user, "<span class='warning'>You fail to give [target] a noogie!</span>")
		to_chat(target, "<span class='danger'>[user] fails to give you a noogie!</span>")
		return

	iteration++
	noogie_loop(user, target, iteration)


/obj/item/kisser
	name = "kiss blower"
	desc = "I want you all to know, everyone and anyone, to seal it with a kiss."
	icon = 'icons/mob/animal.dmi'
	icon_state = "heart"
	inhand_icon_state = "nothing"
	force = 0
	throwforce = 0
	item_flags = DROPDEL | ABSTRACT | HAND_ITEM

/obj/item/kisser/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	user.visible_message("<b>[user]</b> blows a kiss at [target]!", "<span class='notice'>You blow a kiss at [target]!</span>")
	var/kiss_type = HAS_TRAIT(user, TRAIT_KISS_OF_DEATH) ? /obj/projectile/kiss/death : /obj/projectile/kiss
	var/obj/projectile/kiss/blown_kiss = new kiss_type(get_turf(user))

	//Shooting Code:
	blown_kiss.spread = 0
	blown_kiss.original = target
	blown_kiss.fired_from = user
	blown_kiss.firer = user // don't hit ourself that would be really annoying
	blown_kiss.impacted = list(user = TRUE) // just to make sure we don't hit the wearer
	blown_kiss.def_zone = BODY_ZONE_HEAD
	blown_kiss.preparePixelProjectile(target, user)
	blown_kiss.fire()
	qdel(src)

/obj/projectile/kiss
	name = "kiss"
	icon = 'icons/mob/animal.dmi'
	icon_state = "heart"
	gender = PLURAL
	hitsound = 'sound/effects/kiss.ogg'
	hitsound_wall = 'sound/effects/kiss.ogg'
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage_type = BRUTE
	damage = 0
	nodamage = TRUE // love can't actually hurt you
	armour_penetration = 100 // but if it could, it would cut through even the thickest plate
	flag = MAGIC // and most importantly, love is magic~

/obj/projectile/kiss/fire(angle, atom/direct_target)
	if(firer)
		name = "[name] blown by [firer]"
	return ..()

/obj/projectile/kiss/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(ismob(target))
		SEND_SIGNAL(target, COMSIG_ADD_MOOD_EVENT, "kiss", /datum/mood_event/kiss, firer)

/obj/projectile/kiss/death
	name = "kiss of death"
	nodamage = FALSE // okay i kinda lied about love not being able to hurt you
	damage = 35
	sharpness = SHARP_POINTY

/obj/projectile/kiss/death/Initialize()
	. = ..()
	color = COLOR_BLACK
