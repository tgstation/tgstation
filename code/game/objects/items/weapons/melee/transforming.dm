/obj/item/weapon/melee/transforming //TODO: make transforming energy weapons a subtype of this
	var/active = FALSE
	var/force_on = 30 //force when active
	var/throwforce_on = 20
	var/icon_state_on = "axe1"
	var/hitsound_on = 'sound/weapons/blade1.ogg'
	var/list/attack_verb_on = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	var/list/attack_verb_off = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	w_class = WEIGHT_CLASS_SMALL
	sharpness = IS_SHARP
	var/w_class_on = WEIGHT_CLASS_BULKY

/obj/item/weapon/melee/transforming/Initialize()
	. = ..()
	if(active)
		if(attack_verb_on.len)
			attack_verb = attack_verb_on
	else
		if(attack_verb_off.len)
			attack_verb = attack_verb_off

/obj/item/weapon/melee/transforming/attack_self(mob/living/carbon/user)
	if(transform_weapon(user))
		clumsy_transform_effect(user)

/obj/item/weapon/melee/transforming/proc/transform_weapon(mob/living/user, supress_message_text)
	active = !active
	if(active)
		force = force_on
		throwforce = throwforce_on
		hitsound = hitsound_on
		throw_speed = 4
		if(attack_verb_on.len)
			attack_verb = attack_verb_on
		icon_state = icon_state_on
		w_class = w_class_on
	else
		force = initial(force)
		throwforce = initial(throwforce)
		hitsound = initial(hitsound)
		throw_speed = initial(throw_speed)
		if(attack_verb_off.len)
			attack_verb = attack_verb_off
		icon_state = initial(icon_state)
		w_class = initial(w_class)
	transform_messages(user, supress_message_text)
	add_fingerprint(user)
	return TRUE

/obj/item/weapon/melee/transforming/proc/transform_messages(mob/living/user, supress_message_text)
	playsound(user, active ? 'sound/weapons/saberon.ogg' : 'sound/weapons/saberoff.ogg', 35, 1)  //changed it from 50% volume to 35% because deafness
	if(!supress_message_text)
		to_chat(user, "<span class='notice'>[src] [active ? "is now active":"can now be concealed"].</span>")

/obj/item/weapon/melee/transforming/proc/clumsy_transform_effect(mob/living/user)
	if(user.disabilities & CLUMSY && prob(50))
		to_chat(user, "<span class='warning'>You accidentally cut yourself with [src], like a doofus!</span>")
		user.take_bodypart_damage(5,5)