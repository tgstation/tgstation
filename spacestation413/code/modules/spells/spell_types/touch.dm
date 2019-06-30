/obj/item/melee/touch_attack/rathens
	name = "\improper ass-blasting touch"
	desc = "This hand of mine glows with an awesome power!"
	catchphrase = "ARSE NATH!!"
	on_use_sound = 'spacestation413/sound/effects/superfart.ogg'
	icon_state = "disintegrate"
	item_state = "disintegrate"



/obj/item/melee/touch_attack/rathens/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !ismob(target) || !iscarbon(user) || !(user.mobility_flags & MOBILITY_USE)) //exploding after touching yourself would be bad
		return
	if(!user.can_speak_vocal())
		to_chat(user, "<span class='notice'>You can't get the words out!</span>")
		return
	var/mob/living/M = target
	for(var/mob/living/L in view(src, 7))
		if(L != user)
			L.flash_act(affect_silicon = FALSE)
	var/atom/A = M.anti_magic_check()
	if(A)
		if(isitem(A))
			target.visible_message("<span class='warning'>[target]'s [A] glows brightly as it wards off the spell!</span>")
		user.visible_message("<span class='warning'>The feedback blows [user]'s ass off!</span>","<span class='userdanger'>The spell bounces from [M]'s skin back into your ass!</span>")
		user.flash_act()
		var/obj/item/organ/butt/B = user.getorgan(/obj/item/organ/butt)
		if(!B)
			to_chat(user, "<span class='danger'>You don't have a butt!</span>")
		else
			B.Remove(M) //i should DEFINITELY remove this to another proc.
			B.forceMove(get_turf(M))
			var/obj/effect/decal/cleanable/blood/blood = new /obj/effect/decal/cleanable/blood(M.loc)
			blood.set_blood_color(M.blood_color)
			M.nutrition = max(M.nutrition - 500, NUTRITION_LEVEL_STARVING)
			M.apply_damage(50,BRUTE,BODY_ZONE_PRECISE_GROIN)
			M.visible_message("<span class='warning'><b>[M]'s</b> ass blows clean off!</span>", "<span class='warning'>Holy shit, your butt flies off in an arc!</span>")
		return ..()
	var/obj/item/organ/butt/B = M.getorgan(/obj/item/organ/butt)
	if(B)
		B.Remove(M)
		B.forceMove(get_turf(M))
		var/obj/effect/decal/cleanable/blood/blood = new /obj/effect/decal/cleanable/blood(M.loc)
		blood.set_blood_color(M.blood_color)
		M.nutrition = max(M.nutrition - 500, NUTRITION_LEVEL_STARVING)
		M.apply_damage(50,BRUTE,BODY_ZONE_PRECISE_GROIN)
		M.visible_message("<span class='warning'><b>[M]'s</b> ass blows clean off!</span>", "<span class='warning'>Holy shit, your butt flies off in an arc!</span>")
	else
		M.visible_message("<span class='warning'><b>[M] begins glowing suspiciously...</span>","<span class='warning'>You feel the effects of the spell try to find your ass, but you don't have one! You can feel it start to fill the rest of your body!</span>")
		var/obj/item/clothing/suit/hooded/bloated_human/suit = M.get_item_by_slot(SLOT_WEAR_SUIT)
		if(istype(suit))
			M.visible_message("<span class='danger'>[M]'s [suit] explodes off of [M.p_them()] into a puddle of gore!</span>")
			M.dropItemToGround(suit)
			qdel(suit)
			new /obj/effect/gibspawner(M.loc)
			return ..()
		M.gib()
	return ..()

/obj/effect/proc_holder/spell/targeted/touch/rathens
	name = "Rathen's Secret"
	desc = "Summons a powerful shockwave around you that tears the arses and limbs off of enemies."
	hand_path = /obj/item/melee/touch_attack/rathens

	school = "evocation"
	charge_max = 400
	clothes_req = TRUE
	cooldown_min = 40 //90 deciseconds reduction per rank

	action_icon_state = "gib"

/datum/spellbook_entry/disintegrate //THIS IS INTENTIONAL -- REPLACING EI NATH WITH ARSE NATH (also makes it easy to fix later by just renaming)
	name = "Rathen's Secret"
	spell_type = /obj/effect/proc_holder/spell/targeted/touch/rathens
