/obj/item/circular_saw/folding
	name = "Folding surgical saw"
	desc = "Elder surgical tool. Sometimes doing strange things"
	icon = 'code/white/Gargule/icons.dmi'
	icon_state = "saw"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'//fix that later
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'//that too
	hitsound = 'sound/weapons/bladeslice.ogg'
	force = 10//
	toolspeed = 1.25
	throwforce = 5//
	materials = list(MAT_METAL=10000)//
	var/folded = 0

/obj/item/circular_saw/folding/attack_self(user)
	if(!folded)
		folded = 1
		force = 0
		hitsound = null
		icon_state = "saw_folded"
		w_class = WEIGHT_CLASS_SMALL
		to_chat(user, "You fold your saw")
	else
		folded = 0
		force = initial(force)
		hitsound = initial(hitsound)
		icon_state = "saw"
		w_class = initial(w_class)
		to_chat(user, "You retract blade of your saw. Looks dangerous")

/obj/item/circular_saw/folding/attack(mob/living/M, mob/living/carbon/human/H)
	if(folded)
		H.dropItemToGround(src, TRUE)//drop saw
		to_chat(H, "You tried to saw with folded blade, but just drop your tool")
	else
		return ..()

/obj/item/circular_saw/folding/attackby(obj/item/autosurgeon/I, mob/user, params)
	if(I.uses>-1)
		I.uses -= 1+I.uses
		I.icon = 'code/white/Gargule/icons.dmi'
		I.icon_state = "thing"
		I.name = "strange thing"
		I.desc = "This thing is very strange. Who knows, what it can do?"
		to_chat(user, "Strange thing happens")
	else
		to_chat(user, "Strange thing already happened")
		return ..()


/obj/item/slapper_mark_two
	name = "slapper MK2"
	desc = "This is how real men fight. New functions avalible"
	icon_state = "latexballon"
	item_state = "nothing"
	force = 0
	throwforce = 0
	item_flags = DROPDEL | ABSTRACT
	attack_verb = list("slapped")
	hitsound = 'sound/effects/snap.ogg'

/obj/item/slapper_mark_two/attack(mob/M, mob/living/carbon/human/user)
	if(ishuman(M))
		var/mob/living/carbon/human/L = M
		L.endTailWag()
		if(user.a_intent != INTENT_HARM)
			if((user.zone_selected == BODY_ZONE_PRECISE_MOUTH) || (user.zone_selected == BODY_ZONE_PRECISE_EYES) || (user.zone_selected == BODY_ZONE_HEAD))
				user.do_attack_animation(M)
				playsound(M, 'sound/weapons/slap.ogg', 50, 1, -1)
				user.visible_message("<span class='danger'>[user] slaps [M]!</span>",
		 		"<span class='notice'>You slap [M]!</span>",\
		 		"You hear a slap.")
			if(user.zone_selected == BODY_ZONE_PRECISE_GROIN && istype(L.w_uniform, /obj/item/clothing/under/jabroni))
				user.do_attack_animation(M)
				playsound(M, 'code/white/Gargule/sounds/pidr_oret.ogg', 75, 1, -1)//bringigng gachislaps
				playsound(M, 'sound/weapons/slap.ogg', 50, 1, -1)
				user.visible_message("<span class='danger'>[user] slaps the ass of [M]!</span>",
		 		"<span class='notice'>You slap the ass of [M]!</span>",\
		 		"You hear a slap.")
		 return
	else
		..()