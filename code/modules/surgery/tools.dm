/obj/item/retractor
	name = "retractor"
	desc = "Retracts stuff."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "retractor"
	materials = list(MAT_METAL=6000, MAT_GLASS=3000)
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=1;biotech=1"


/obj/item/retractor/augment
	name = "toolarm retractor"
	desc = "Micro-mechanical manipulator for retracting stuff."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "retractor"
	materials = list(MAT_METAL=6000, MAT_GLASS=3000)
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=1;biotech=1"
	toolspeed = 0.5


/obj/item/hemostat
	name = "hemostat"
	desc = "You think you have seen this before."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hemostat"
	materials = list(MAT_METAL=5000, MAT_GLASS=2500)
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("attacked", "pinched")


/obj/item/hemostat/augment
	name = "toolarm hemostat"
	desc = "Tiny servos power a pair of pincers to stop bleeding."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hemostat"
	materials = list(MAT_METAL=5000, MAT_GLASS=2500)
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=1;biotech=1"
	toolspeed = 0.5
	attack_verb = list("attacked", "pinched")


/obj/item/cautery
	name = "cautery"
	desc = "This stops bleeding."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "cautery"
	materials = list(MAT_METAL=2500, MAT_GLASS=750)
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("burnt")


/obj/item/cautery/augment
	name = "toolarm cautery"
	desc = "A heated element that cauterizes wounds."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "cautery"
	materials = list(MAT_METAL=2500, MAT_GLASS=750)
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=1;biotech=1"
	toolspeed = 0.5
	attack_verb = list("burnt")


/obj/item/surgicaldrill
	name = "surgical drill"
	desc = "You can drill using this item. You dig?"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "drill"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	hitsound = 'sound/weapons/circsawhit.ogg'
	materials = list(MAT_METAL=10000, MAT_GLASS=6000)
	flags_1 = CONDUCT_1
	force = 15
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("drilled")


/obj/item/surgicaldrill/augment
	name = "toolarm surgical drill"
	desc = "Effectively a small power drill contained within your arm, edges dulled to prevent tissue damage. May or may not pierce the heavens."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "drill"
	hitsound = 'sound/weapons/circsawhit.ogg'
	materials = list(MAT_METAL=10000, MAT_GLASS=6000)
	flags_1 = CONDUCT_1
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "materials=1;biotech=1"
	toolspeed = 0.5
	attack_verb = list("drilled")


/obj/item/scalpel
	name = "scalpel"
	desc = "Cut, cut, and once more cut."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 10
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL=4000, MAT_GLASS=1000)
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = IS_SHARP_ACCURATE

/obj/item/scalpel/augment
	name = "toolarm scalpel"
	desc = "Ultra-sharp blade attached directly to your bone for extra-accuracy."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel"
	flags_1 = CONDUCT_1
	force = 10
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL=4000, MAT_GLASS=1000)
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	toolspeed = 0.5
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = IS_SHARP_ACCURATE

/obj/item/scalpel/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is slitting [user.p_their()] [pick("wrists", "throat", "stomach")] with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (BRUTELOSS)


/obj/item/circular_saw
	name = "circular saw"
	desc = "For heavy duty cutting."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	hitsound = 'sound/weapons/circsawhit.ogg'
	throwhitsound =  'sound/weapons/pierce.ogg'
	flags_1 = CONDUCT_1
	force = 15
	w_class = WEIGHT_CLASS_NORMAL
	throwforce = 9
	throw_speed = 2
	throw_range = 5
	materials = list(MAT_METAL=10000, MAT_GLASS=6000)
	origin_tech = "biotech=1;combat=1"
	attack_verb = list("attacked", "slashed", "sawed", "cut")
	sharpness = IS_SHARP

/obj/item/circular_saw/augment
	name = "toolarm circular saw"
	desc = "A small but very fast spinning saw. Edges dulled to prevent accidental cutting inside of the surgeon."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw"
	hitsound = 'sound/weapons/circsawhit.ogg'
	throwhitsound =  'sound/weapons/pierce.ogg'
	flags_1 = CONDUCT_1
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 9
	throw_speed = 2
	throw_range = 5
	materials = list(MAT_METAL=10000, MAT_GLASS=6000)
	origin_tech = "biotech=1;combat=1"
	toolspeed = 0.5
	attack_verb = list("attacked", "slashed", "sawed", "cut")
	sharpness = IS_SHARP

/obj/item/surgical_drapes
	name = "surgical drapes"
	desc = "Nanotrasen brand surgical drapes provide optimal safety and infection control."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "surgical_drapes"
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "biotech=1"
	attack_verb = list("slapped")

/obj/item/surgical_drapes/attack(mob/living/M, mob/user)
	if(!attempt_initiate_surgery(src, M, user))
		..()

/obj/item/organ_storage //allows medical cyborgs to manipulate organs without hands
	name = "organ storage bag"
	desc = "A container for holding body parts."
	icon = 'icons/obj/storage.dmi'
	icon_state = "evidenceobj"

/obj/item/organ_storage/afterattack(obj/item/I, mob/user, proximity)
	if(!proximity)
		return
	if(contents.len)
		to_chat(user, "<span class='notice'>[src] already has something inside it.</span>")
		return
	if(!isorgan(I) && !isbodypart(I))
		to_chat(user, "<span class='notice'>[src] can only hold body parts!</span>")
		return

	user.visible_message("[user] puts [I] into [src].", "<span class='notice'>You put [I] inside [src].</span>")
	icon_state = "evidence"
	var/xx = I.pixel_x
	var/yy = I.pixel_y
	I.pixel_x = 0
	I.pixel_y = 0
	var/image/img = image("icon"=I, "layer"=FLOAT_LAYER)
	img.plane = FLOAT_PLANE
	I.pixel_x = xx
	I.pixel_y = yy
	add_overlay(img)
	add_overlay("evidence")
	desc = "An organ storage container holding [I]."
	I.loc = src
	w_class = I.w_class

/obj/item/organ_storage/attack_self(mob/user)
	if(contents.len)
		var/obj/item/I = contents[1]
		user.visible_message("[user] dumps [I] from [src].", "<span class='notice'>You dump [I] from [src].</span>")
		cut_overlays()
		I.forceMove(get_turf(src))
		icon_state = "evidenceobj"
		desc = "A container for holding body parts."
	else
		to_chat(user, "[src] is empty.")
	return

/// SYNDICATE VARIANTS

/obj/item/retractor/syndicate
	name = "syndicate retractor"
	desc = "Reinforced with carbon-plasma alloy for a stalwart grip."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "sretractor"
	origin_tech = "materials=3;biotech=3;syndicate=3"
	toolspeed = 0.3

/obj/item/hemostat/syndicate
	name = "syndicate hemostat"
	desc = "Comes with carp-style teeth for complete bleeding control."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "shemostat"
	origin_tech = "materials=3;biotech=3;syndicate=3"
	toolspeed = 0.3

/obj/item/cautery/syndicate
	name = "syndicate cautery"
	desc = "Uses state-of-the-art heating techniques to bring the pain!"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scautery"
	origin_tech = "materials=3;biotech=3;syndicate=3"
	toolspeed = 0.3

/obj/item/surgicaldrill/syndicate
	name = "syndicate surgical drill"
	desc = "Outfitted with plasmic nanotubes in the bit and a suped-up motor."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "sdrill"
	lefthand_file = 'hippiestation/icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'hippiestation/icons/mob/inhands/equipment/medical_righthand.dmi'
	force = 18
	origin_tech = "materials=3;biotech=3;syndicate=3"
	toolspeed = 0.3

/obj/item/scalpel/syndicate
	name = "syndicate scalpel"
	desc = "It incises effortlessly with it's fixium blade."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "sscalpel"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	force = 15
	origin_tech = "materials=3;biotech=3;syndicate=3"
	toolspeed = 0.3

/obj/item/circular_saw/syndicate
	name = "syndicate circular saw"
	desc = "It has a little sub-sentient AI on it to correct errors in the cutting process and guide the blade for extremely efficient cuts."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "ssaw"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	force = 18
	origin_tech = "biotech=3;combat=3;syndicate=3"
	toolspeed = 0.3
