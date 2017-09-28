/obj/item/melee/touch_attack
	name = "\improper outstretched hand"
	desc = "High Five?"
	var/catchphrase = "High Five!"
	var/on_use_sound = null
	var/obj/effect/proc_holder/spell/targeted/touch/attached_spell
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "syndballoon"
	item_state = null
	flags_1 = ABSTRACT_1 | NODROP_1 | DROPDEL_1
	w_class = WEIGHT_CLASS_HUGE
	force = 0
	throwforce = 0
	throw_range = 0
	throw_speed = 0

/obj/item/melee/touch_attack/Initialize()
	attached_spell = loc
	. = ..()

/obj/item/melee/touch_attack/attack(mob/target, mob/living/carbon/user)
	if(!iscarbon(user)) //Look ma, no hands
		return
	if(user.lying || user.handcuffed)
		to_chat(user, "<span class='warning'>You can't reach out!</span>")
		return
	..()

/obj/item/melee/touch_attack/afterattack(atom/target, mob/user, proximity)
	user.say(catchphrase)
	playsound(get_turf(user), on_use_sound,50,1)
	if(attached_spell)
		attached_spell.attached_hand = null
	qdel(src)

/obj/item/melee/touch_attack/Destroy()
	if(attached_spell)
		attached_spell.attached_hand = null
	return ..()

/obj/item/melee/touch_attack/disintegrate
	name = "\improper disintegrating touch"
	desc = "This hand of mine glows with an awesome power!"
	catchphrase = "EI NATH!!"
	on_use_sound = 'sound/magic/disintegrate.ogg'
	icon_state = "disintegrate"
	item_state = "disintegrate"

/obj/item/melee/touch_attack/disintegrate/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !ismob(target) || !iscarbon(user) || user.lying || user.handcuffed) //exploding after touching yourself would be bad
		return
	var/mob/M = target
	do_sparks(4, FALSE, M.loc)
	M.gib()
	..()

/obj/item/melee/touch_attack/fleshtostone
	name = "\improper petrifying touch"
	desc = "That's the bottom line, because flesh to stone said so!"
	catchphrase = "STAUN EI!!"
	on_use_sound = 'sound/magic/fleshtostone.ogg'
	icon_state = "fleshtostone"
	item_state = "fleshtostone"

/obj/item/melee/touch_attack/fleshtostone/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !isliving(target) || !iscarbon(user) || user.lying || user.handcuffed) //getting hard after touching yourself would also be bad
		return
	if(user.lying || user.handcuffed)
		to_chat(user, "<span class='warning'>You can't reach out!</span>")
		return
	var/mob/living/M = target
	M.Stun(40)
	M.petrify()
	..()
