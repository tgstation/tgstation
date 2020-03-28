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
	item_state = null
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
	item_state = "disintegrate"

/obj/item/melee/touch_attack/disintegrate/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !ismob(target) || !iscarbon(user) || !(user.mobility_flags & MOBILITY_USE)) //exploding after touching yourself would be bad
		return
	if(!user.can_speak_vocal())
		to_chat(user, "<span class='warning'>You can't get the words out!</span>")
		return
	var/mob/M = target
	do_sparks(4, FALSE, M.loc)
	for(var/mob/living/L in view(src, 7))
		if(L != user)
			L.flash_act(affect_silicon = FALSE)
	var/atom/A = M.anti_magic_check()
	if(A)
		if(isitem(A))
			target.visible_message("<span class='warning'>[target]'s [A] glows brightly as it wards off the spell!</span>")
		user.visible_message("<span class='warning'>The feedback blows [user]'s arm off!</span>","<span class='userdanger'>The spell bounces from [M]'s skin back into your arm!</span>")
		user.flash_act()
		var/obj/item/bodypart/part = user.get_holding_bodypart_of_item(src)
		if(part)
			part.dismember()
		return ..()
	var/obj/item/clothing/suit/hooded/bloated_human/suit = M.get_item_by_slot(ITEM_SLOT_OCLOTHING)
	if(istype(suit))
		M.visible_message("<span class='danger'>[M]'s [suit] explodes off of them into a puddle of gore!</span>")
		M.dropItemToGround(suit)
		qdel(suit)
		new /obj/effect/gibspawner(M.loc)
		return ..()
	M.gib()
	return ..()

/obj/item/melee/touch_attack/fleshtostone
	name = "\improper petrifying touch"
	desc = "That's the bottom line, because flesh to stone said so!"
	catchphrase = "STAUN EI!!"
	on_use_sound = 'sound/magic/fleshtostone.ogg'
	icon_state = "fleshtostone"
	item_state = "fleshtostone"

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

/obj/item/melee/touch_attack/honk
	name = "\improper silly touch"
	desc = "Can you hear it? The pained laughter? The dull smack of a forehead against metal and glass? The incessant need to honk without end?"
	catchphrase = "Lonk-Lonk-Lonk, FMR'shNK Cluw-NR!!!"
	on_use_sound = 'sound/items/airhorn.ogg'
	icon_state = "clown"
	item_state = "clown"

/obj/item/melee/touch_attack/honk/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || !ishuman(target) || !iscarbon(user))
		return
	if(!(user.mobility_flags & MOBILITY_USE))
		to_chat(user, "<span class='warning'>You can't reach out!</span>")
		return
	if(!user.can_speak_vocal())
		to_chat(user, "<span class='warning'>You can't get the rage out of your system!</span>")
		return
	var/mob/living/carbon/human/H = target // Only humans can wear stuff
	// Check if they already have clown gear on, if so, turn that suit into a clown simplemob
	var/obj/item/clothing/under/rank/civilian/clown/suit = H.get_item_by_slot(ITEM_SLOT_ICLOTHING)
	if(istype(suit))
		H.visible_message("<span class='danger'>[H]'s [suit] animates and jumps off of [H.p_them()], turning into a clown!</span>")
		H.dropItemToGround(suit)
		qdel(suit)
		new /mob/living/simple_animal/hostile/retaliate/clown(H.loc)
		return ..()

	if(HAS_TRAIT(H, TRAIT_CLUMSY)) //Your holyness can't save you now!
		to_chat(user, "<span class='warning'>The clown's rage doesn't seem to affect [H]!</span>")
		to_chat(H, "<span class='notice'>You feel silly for a moment, but you realize you're already silly.</span>")
		..()
		return
	// Turn em into a clown
	for(var/obj/item/W in H)
		H.dropItemToGround(W)
	if(isplasmaman(H)) // Too lazy to make cluwne outfit for plasmamen also i'm a terrible coderspriter
		H.equipOutfit(/datum/outfit/job/clown/cluwne/plasma) // regardless, plasmamen are stuck in the plasmaclown suit due to their nature
	else
		H.equipOutfit(/datum/outfit/job/clown/cluwne) // See clothing/outfits/standard.dm for cluwne gear
	H.say("HONK HONK HUENK HENK HONK HAAANK!!!!!", forced = "curse of the clown")
	to_chat(H, "<span class='userdanger'>You've been turned into a clumsy cluwne! You have an incessent urge to HONK.</span>")
	to_chat(H, "<span class='big bold info'>As a Cluwne, you are valid at all times and can be killed for any reason, by anyone, but you are not an antagonist. \
	You are treated as a normal crewmember in terms of instigating violence.</span>")
	return ..()
