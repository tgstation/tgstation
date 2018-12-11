/obj/item/retractor
	name = "retractor"
	desc = "Retracts stuff."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "retractor"
	materials = list(MAT_METAL=6000, MAT_GLASS=3000)
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_TINY


/obj/item/retractor/augment
	name = "retractor"
	desc = "Micro-mechanical manipulator for retracting stuff."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "retractor"
	materials = list(MAT_METAL=6000, MAT_GLASS=3000)
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_TINY
	toolspeed = 0.5


/obj/item/hemostat
	name = "hemostat"
	desc = "You think you have seen this before."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hemostat"
	materials = list(MAT_METAL=5000, MAT_GLASS=2500)
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_TINY
	attack_verb = list("attacked", "pinched")


/obj/item/hemostat/augment
	name = "hemostat"
	desc = "Tiny servos power a pair of pincers to stop bleeding."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hemostat"
	materials = list(MAT_METAL=5000, MAT_GLASS=2500)
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_TINY
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
	attack_verb = list("burnt")


/obj/item/cautery/augment
	name = "cautery"
	desc = "A heated element that cauterizes wounds."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "cautery"
	materials = list(MAT_METAL=2500, MAT_GLASS=750)
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_TINY
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
	attack_verb = list("drilled")


/obj/item/surgicaldrill/augment
	name = "surgical drill"
	desc = "Effectively a small power drill contained within your arm, edges dulled to prevent tissue damage. May or may not pierce the heavens."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "drill"
	hitsound = 'sound/weapons/circsawhit.ogg'
	materials = list(MAT_METAL=10000, MAT_GLASS=6000)
	flags_1 = CONDUCT_1
	force = 10
	w_class = WEIGHT_CLASS_SMALL
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
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = IS_SHARP_ACCURATE

/obj/item/scalpel/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 80 * toolspeed, 100, 0)

/obj/item/scalpel/augment
	name = "scalpel"
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
	attack_verb = list("attacked", "slashed", "sawed", "cut")
	sharpness = IS_SHARP

/obj/item/circular_saw/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 40 * toolspeed, 100, 5, 'sound/weapons/circsawhit.ogg') //saws are very accurate and fast at butchering

/obj/item/circular_saw/augment
	name = "circular saw"
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
	toolspeed = 0.5
	attack_verb = list("attacked", "slashed", "sawed", "cut")
	sharpness = IS_SHARP

/obj/item/surgical_drapes
	name = "surgical drapes"
	desc = "Nanotrasen brand surgical drapes provide optimal safety and infection control."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "surgical_drapes"
	w_class = WEIGHT_CLASS_TINY
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
	. = ..()
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
	I.forceMove(src)
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

/obj/item/surgical_processor //allows medical cyborgs to scan and initiate advanced surgeries
	name = "\improper Surgical Processor"
	desc = "A device for scanning and initiating surgeries from a disk or operating computer."
	icon = 'icons/obj/device.dmi'
	icon_state = "spectrometer"
	item_flags = NOBLUDGEON
	var/list/advanced_surgeries = list()

/obj/item/surgical_processor/afterattack(obj/item/O, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(istype(O, /obj/item/disk/surgery))
		to_chat(user, "<span class='notice'>You load the surgery protocol from [O] into [src].</span>")
		var/obj/item/disk/surgery/D = O
		if(do_after(user, 10, target = O))
			advanced_surgeries |= D.surgeries
		return TRUE
	if(istype(O, /obj/machinery/computer/operating))
		to_chat(user, "<span class='notice'>You copy surgery protocols from [O] into [src].</span>")
		var/obj/machinery/computer/operating/OC = O
		if(do_after(user, 10, target = O))
			advanced_surgeries |= OC.advanced_surgeries
		return TRUE
	return

/obj/item/scalpel/advanced
	name = "laser scalpel"
	desc = "An advanced scalpel which uses laser technology to cut. It's set to scalpel mode."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel_a"
	hitsound = 'sound/weapons/blade1.ogg'
	force = 16
	toolspeed = 0.7
	light_color = LIGHT_COLOR_GREEN

/obj/item/scalpel/advanced/Initialize()
	set_light(1)
	START_PROCESSING(SSobj, src)

/obj/item/scalpel/advanced/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/scalpel/advanced/attack_self(mob/user)
	playsound(get_turf(user),'sound/machines/click.ogg',50,1)
	var/obj/item/circular_saw/advanced/saw = new /obj/item/circular_saw/advanced(drop_location())
	to_chat(user, "<span class='notice'>You incease the power, now it can cut bones.</span>")
	qdel(src)
	user.put_in_active_hand(saw)

/obj/item/circular_saw/advanced
	name = "laser scalpel"
	desc = "An advanced scalpel which uses laser technology to cut. It's set to saw mode."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw_a"
	hitsound = 'sound/weapons/blade1.ogg'
	force = 17
	toolspeed = 0.7
	sharpness = IS_SHARP_ACCURATE
	light_color = LIGHT_COLOR_GREEN

/obj/item/circular_saw/advanced/Initialize()
	set_light(2)
	START_PROCESSING(SSobj, src)
	..()

/obj/item/circular_saw/advanced/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/circular_saw/advanced/attack_self(mob/user)
	playsound(get_turf(user),'sound/machines/click.ogg',50,1)
	var/obj/item/scalpel/advanced/scalpel = new /obj/item/scalpel/advanced(drop_location())
	to_chat(user, "<span class='notice'>You lower the power.</span>")
	qdel(src)
	user.put_in_active_hand(scalpel)

/obj/item/retractor/advanced
	name = "mechanical pinches"
	desc = "An agglomerate of rods and gears. It resembles a retractor."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "retractor_a"
	toolspeed = 0.7

/obj/item/retractor/advanced/attack_self(mob/user)
	playsound(get_turf(user),'sound/items/change_drill.ogg',50,1)
	var/obj/item/hemostat/advanced/hemostat = new /obj/item/hemostat/advanced(drop_location())
	to_chat(user, "<span class='notice'>You set the [src] to hemostat mode.</span>")
	qdel(src)
	user.put_in_active_hand(hemostat)

/obj/item/hemostat/advanced
	name = "mechanical pinches"
	desc = "An agglomerate of rods and gears. It resembles an hemostat."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hemostat_a"
	toolspeed = 0.7

/obj/item/hemostat/advanced/attack_self(mob/user)
	playsound(get_turf(user),'sound/items/change_drill.ogg',50,1)
	var/obj/item/retractor/advanced/retractor = new /obj/item/retractor/advanced(drop_location())
	to_chat(user, "<span class='notice'>You set the [src] to retractor mode.</span>")
	qdel(src)
	user.put_in_active_hand(retractor)

/obj/item/surgicaldrill/advanced
	name = "searing tool"
	desc = "It projects a high power laser used for medical application. It's set to drilling mode."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "surgicaldrill_a"
	hitsound = 'sound/items/welder.ogg'
	toolspeed = 0.7
	light_color = LIGHT_COLOR_RED

/obj/item/surgicaldrill/advanced/Initialize()
	set_light(1)
	START_PROCESSING(SSobj, src)
	..()

/obj/item/surgicaldrill/advanced/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/surgicaldrill/advanced/attack_self(mob/user)
	playsound(get_turf(user),'sound/weapons/tap.ogg',50,1)
	var/obj/item/cautery/advanced/cautery = new /obj/item/cautery/advanced(drop_location())
	to_chat(user, "<span class='notice'>You dilate the lenses, setting it to mending mode.</span>")
	qdel(src)
	user.put_in_active_hand(cautery)

/obj/item/cautery/advanced
	name = "searing tool"
	desc = "It projects a high power laser used for medical application. It's set to mending mode."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "cautery_a"
	hitsound = 'sound/items/welder2.ogg'
	force = 15
	toolspeed = 0.7
	light_color = LIGHT_COLOR_RED

/obj/item/cautery/advanced/Initialize()
	set_light(1)
	START_PROCESSING(SSobj, src)
	..()

/obj/item/cautery/advanced/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/cautery/advanced/attack_self(mob/user)
	playsound(get_turf(user),'sound/items/welderdeactivate.ogg',50,1)
	var/obj/item/surgicaldrill/advanced/surgicaldrill = new /obj/item/surgicaldrill/advanced(drop_location())
	to_chat(user, "<span class='notice'>You focus the lensess, it is now set to drilling mode.</span>")
	qdel(src)
	user.put_in_active_hand(surgicaldrill)
