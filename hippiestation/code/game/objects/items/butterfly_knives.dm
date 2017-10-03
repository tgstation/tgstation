
/obj/item/melee/transforming/butterfly
	name = "butterfly knife"
	desc = "A stealthy knife famously used by spy organisations. Capable of piercing armour and causing massive backstab damage when used with harm intent."
	flags_1 = CONDUCT_1
	force = 0
	force_on = 10
	icon = 'hippiestation/icons/obj/items_and_weapons.dmi'
	icon_state = "butterflyknife0"
	icon_state_on = "butterflyknife1"
	hitsound_on = 'hippiestation/sound/weapons/knife.ogg'
	lefthand_file = 'hippiestation/icons/mob/inhands/lefthand.dmi'
	righthand_file = 'hippiestation/icons/mob/inhands/righthand.dmi'
	var/item_state_on = "butterfly"
	throwforce = 0
	throwforce_on = 10
	var/backstabforce = 30
	armour_penetration = 20
	attack_verb_on = list("poked", "slashed", "stabbed", "sliced", "torn", "pierced", "diced", "cut")
	attack_verb_off = list("tapped", "prodded")
	w_class = WEIGHT_CLASS_SMALL
	sharpness = IS_BLUNT
	var/sharpness_on = IS_SHARP_ACCURATE
	w_class_on = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL=12000)
	var/onsound
	var/offsound

/obj/item/melee/transforming/butterfly/transform_weapon(mob/living/user, supress_message_text)
	..()
	if(active)
		item_state = item_state_on
		sharpness = sharpness_on
	else if(!active)
		item_state = initial(item_state)
		sharpness = initial(sharpness)


/obj/item/melee/transforming/butterfly/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(check_target_facings(user, M) == FACING_SAME_DIR && active && user.a_intent != INTENT_HELP && ishuman(M))
		var/mob/living/carbon/human/U = M
		return backstab(U,user,backstabforce)

	if(user.zone_selected == "eyes" && active)
		if(user.disabilities & CLUMSY && prob(50))
			M = user
		return eyestab(M,user)
	else
		return ..()

/obj/item/melee/transforming/butterfly/transform_messages(mob/living/user, supress_message_text)//no fucking esword on sound
	playsound(user, active ? onsound  : offsound , 50, 1)
	if(!supress_message_text)
		to_chat(user, "<span class='notice'>[src] [active ? "is now active":"can now be concealed"].</span>")


/obj/item/melee/transforming/butterfly/proc/backstab(mob/living/carbon/human/U, mob/living/carbon/user, damage)
	var/obj/item/bodypart/affecting = U.get_bodypart("chest")

	if(!affecting || U == user || U.stat == DEAD) //no chest???!!!!
		return

	U.visible_message("<span class='danger'>[user] has backstabbed [U] with [src]!</span>", \
						"<span class='userdanger'>[user] backstabs you with [src]!</span>")

	src.add_fingerprint(user)
	playsound(loc,'hippiestation/sound/weapons/knifecrit.ogg', 40, 1, -1)
	user.do_attack_animation(U)
	U.apply_damage(damage, BRUTE, affecting, U.getarmor(affecting, "melee"))
	U.drop_item()

	add_logs(user, U, "backstabbed", "[src.name]", "(INTENT: [uppertext(user.a_intent)])")

/obj/item/melee/transforming/butterfly/energy
	name = "energy balisong"
	origin_tech = "combat=4;syndicate=3"
	desc = "A vicious carbon fibre blade and plasma tip allow for unparelled precision strikes against fat Nanotrasen backsides"
	force_on = 20
	throwforce_on = 20
	backstabforce = 80
	item_state_on = "balisong"
	icon_state = "butterflyknife0"
	icon_state_on = "butterflyknife_syndie"
	onsound = 'hippiestation/sound/weapons/knifeopen.ogg'
	offsound = 'hippiestation/sound/weapons/knifeclose.ogg'

