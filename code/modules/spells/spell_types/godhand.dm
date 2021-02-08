/obj/item/melee/touch_attack
	name = "\improper outstretched hand"
	desc = "High Five?"
	var/catchphrase = "High Five!"
	var/on_use_sound = null
	var/obj/effect/proc_holder/spell/targeted/touch/attached_spell
	icon = 'icons/obj/items_and_weapons.dmi'
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'
	icon_state = "latexballon"
	inhand_icon_state = null
	item_flags = NEEDS_PERMIT | ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	force = 0
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	var/charges = 1

/obj/item/melee/touch_attack/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

/obj/item/melee/touch_attack/attack(mob/target, mob/living/carbon/user)
	if(!iscarbon(user)) //Look ma, no hands
		return
	if(!(user.mobility_flags & MOBILITY_USE))
		to_chat(user, "<span class='warning'>You can't reach out!</span>")
		return
	..()

/obj/item/melee/touch_attack/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(catchphrase)
		user.say(catchphrase, forced = "spell")
	playsound(get_turf(user), on_use_sound,50,TRUE)
	charges--
	if(charges <= 0)
		qdel(src)

/obj/item/melee/touch_attack/Destroy()
	if(attached_spell)
		attached_spell.on_hand_destroy(src)
	return ..()

/obj/item/melee/touch_attack/disintegrate
	name = "\improper smiting touch"
	desc = "This hand of mine glows with an awesome power!"
	catchphrase = "EI NATH!!"
	on_use_sound = 'sound/magic/disintegrate.ogg'
	icon_state = "disintegrate"
	inhand_icon_state = "disintegrate"

/obj/item/melee/touch_attack/disintegrate/afterattack(mob/living/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !istype(target) || !iscarbon(user) || !(user.mobility_flags & MOBILITY_USE)) //exploding after touching yourself would be bad
		return
	if(!user.can_speak_vocal())
		to_chat(user, "<span class='warning'>You can't get the words out!</span>")
		return
	do_sparks(4, FALSE, target.loc)
	for(var/mob/living/L in view(src, 7))
		if(L != user)
			L.flash_act(affect_silicon = FALSE)
	var/atom/A = target.anti_magic_check()
	if(A)
		if(isitem(A))
			target.visible_message("<span class='warning'>[target]'s [A] glows brightly as it wards off the spell!</span>")
		user.visible_message("<span class='warning'>The feedback blows [user]'s arm off!</span>","<span class='userdanger'>The spell bounces from [target]'s skin back into your arm!</span>")
		user.flash_act()
		var/obj/item/bodypart/part = user.get_holding_bodypart_of_item(src)
		if(part)
			part.dismember()
		return ..()
	var/obj/item/clothing/suit/hooded/bloated_human/suit = target.get_item_by_slot(ITEM_SLOT_OCLOTHING)
	if(istype(suit))
		target.visible_message("<span class='danger'>[target]'s [suit] explodes off of them into a puddle of gore!</span>")
		target.dropItemToGround(suit)
		qdel(suit)
		new /obj/effect/gibspawner(target.loc)
		return ..()
	target.gib()
	return ..()

/obj/item/melee/touch_attack/fleshtostone
	name = "\improper petrifying touch"
	desc = "That's the bottom line, because flesh to stone said so!"
	catchphrase = "STAUN EI!!"
	on_use_sound = 'sound/magic/fleshtostone.ogg'
	icon_state = "fleshtostone"
	inhand_icon_state = "fleshtostone"

/obj/item/melee/touch_attack/fleshtostone/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !isliving(target) || !iscarbon(user)) //getting hard after touching yourself would also be bad
		return
	if(!(user.mobility_flags & MOBILITY_USE))
		to_chat(user, "<span class='warning'>You can't reach out!</span>")
		return
	if(!user.can_speak_vocal())
		to_chat(user, "<span class='warning'>You can't get the words out!</span>")
		return
	var/mob/living/M = target
	if(M.anti_magic_check())
		to_chat(user, "<span class='warning'>The spell can't seem to affect [M]!</span>")
		to_chat(M, "<span class='warning'>You feel your flesh turn to stone for a moment, then revert back!</span>")
		..()
		return
	M.Stun(40)
	M.petrify()
	return ..()


/obj/item/melee/touch_attack/duffelbag
	name = "\improper burdening touch"
	desc = "Where is the bar from here?"
	catchphrase = "HU'SWCH H'ANS!!"
	on_use_sound = 'sound/magic/mm_hit.ogg'
	icon_state = "duffelcurse"
	inhand_icon_state = "duffelcurse"

/obj/item/melee/touch_attack/duffelbag/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !isliving(target) || !iscarbon(user)) //Roleplay involving touching is equally as bad
		return
	if(!(user.mobility_flags & MOBILITY_USE))
		to_chat(user, "<span class='warning'>You can't reach out!</span>")
		return
	if(!user.can_speak_vocal())
		to_chat(user, "<span class='warning'>You can't get the words out!</span>")
		return
	var/mob/living/carbon/duffelvictim = target
	var/elaborate_backstory = pick("spacewar origin story", "military background", "corporate connections", "life in the colonies", "anti-government activities", "upbringing on the space farm", "fond memories with your buddy Keith")
	if(duffelvictim.anti_magic_check())
		to_chat(user, "<span class='warning'>The spell can't seem to affect [duffelvictim]!</span>")
		to_chat(duffelvictim, "<span class='warning'>You really don't feel like talking about your [elaborate_backstory] with complete strangers today.</span>")
		..()
		return

	duffelvictim.flash_act()
	duffelvictim.Immobilize(5 SECONDS)
	duffelvictim.apply_damage(80, STAMINA)
	duffelvictim.Knockdown(5 SECONDS)

	if(HAS_TRAIT(target, TRAIT_DUFFEL_CURSED))
		to_chat(user, "<span class='warning'>The burden of [duffelvictim]'s duffel bag becomes too much, shoving them to the floor!</span>")
		to_chat(duffelvictim, "<span class='warning'>The weight of this bag becomes overburdening!</span>")
		return ..()
	
	var/obj/item/storage/backpack/duffelbag/cursed/conjuredduffel= new get_turf(target)

	duffelvictim.visible_message("<span class='danger'>A growling duffel bag appears on [duffelvictim]!</span>", \
						   "<span class='danger'>You feel something attaching itself to you, and a strong desire to discuss your [elaborate_backstory] at length!</span>")

	if(duffelvictim.dropItemToGround(duffelvictim.back))
		duffelvictim.equip_to_slot_if_possible(conjuredduffel, ITEM_SLOT_BACK, TRUE, TRUE)
	else
		if(!duffelvictim.put_in_hands(conjuredduffel))
			duffelvictim.dropItemToGround(duffelvictim.get_inactive_held_item())
			if(!duffelvictim.put_in_hands(conjuredduffel))
				duffelvictim.dropItemToGround(duffelvictim.get_active_held_item())
				duffelvictim.put_in_hands(conjuredduffel)
			else
				return ..()
	return ..()
