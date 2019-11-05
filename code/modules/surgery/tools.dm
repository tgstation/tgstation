/obj/item/retractor
	name = "retractor"
	desc = "Retracts stuff."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "retractor"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	item_state = "clamps"
	custom_materials = list(/datum/material/iron=6000, /datum/material/glass=3000)
	flags_1 = CONDUCT_1
	item_flags = SURGICAL_TOOL
	w_class = WEIGHT_CLASS_TINY
	tool_behaviour = TOOL_RETRACTOR
	toolspeed = 1

/obj/item/retractor/augment
	desc = "Micro-mechanical manipulator for retracting stuff."
	toolspeed = 0.5


/obj/item/hemostat
	name = "hemostat"
	desc = "You think you have seen this before."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hemostat"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	item_state = "clamps"
	custom_materials = list(/datum/material/iron=5000, /datum/material/glass=2500)
	flags_1 = CONDUCT_1
	item_flags = SURGICAL_TOOL
	w_class = WEIGHT_CLASS_TINY
	attack_verb = list("attacked", "pinched")
	tool_behaviour = TOOL_HEMOSTAT
	toolspeed = 1

/obj/item/hemostat/augment
	desc = "Tiny servos power a pair of pincers to stop bleeding."
	toolspeed = 0.5


/obj/item/cautery
	name = "cautery"
	desc = "This stops bleeding."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "cautery"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	item_state = "cautery"
	custom_materials = list(/datum/material/iron=2500, /datum/material/glass=750)
	flags_1 = CONDUCT_1
	item_flags = SURGICAL_TOOL
	w_class = WEIGHT_CLASS_TINY
	attack_verb = list("burnt")
	tool_behaviour = TOOL_CAUTERY
	toolspeed = 1

/obj/item/cautery/augment
	desc = "A heated element that cauterizes wounds."
	toolspeed = 0.5


/obj/item/surgicaldrill
	name = "surgical drill"
	desc = "You can drill using this item. You dig?"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "drill"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	hitsound = 'sound/weapons/circsawhit.ogg'
	custom_materials = list(/datum/material/iron=10000, /datum/material/glass=6000)
	flags_1 = CONDUCT_1
	item_flags = SURGICAL_TOOL
	force = 15
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("drilled")
	tool_behaviour = TOOL_DRILL
	toolspeed = 1

/obj/item/surgicaldrill/augment
	desc = "Effectively a small power drill contained within your arm, edges dulled to prevent tissue damage. May or may not pierce the heavens."
	hitsound = 'sound/weapons/circsawhit.ogg'
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	toolspeed = 0.5


/obj/item/scalpel
	name = "scalpel"
	desc = "Cut, cut, and once more cut."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	item_state = "scalpel"
	flags_1 = CONDUCT_1
	item_flags = SURGICAL_TOOL
	force = 10
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	custom_materials = list(/datum/material/iron=4000, /datum/material/glass=1000)
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = IS_SHARP_ACCURATE
	tool_behaviour = TOOL_SCALPEL
	toolspeed = 1

/obj/item/scalpel/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 80 * toolspeed, 100, 0)

/obj/item/scalpel/augment
	desc = "Ultra-sharp blade attached directly to your bone for extra-accuracy."
	toolspeed = 0.5

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
	mob_throw_hit_sound =  'sound/weapons/pierce.ogg'
	flags_1 = CONDUCT_1
	item_flags = SURGICAL_TOOL
	force = 15
	w_class = WEIGHT_CLASS_NORMAL
	throwforce = 9
	throw_speed = 2
	throw_range = 5
	custom_materials = list(/datum/material/iron=10000, /datum/material/glass=6000)
	attack_verb = list("attacked", "slashed", "sawed", "cut")
	sharpness = IS_SHARP
	tool_behaviour = TOOL_SAW
	toolspeed = 1

/obj/item/circular_saw/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 40 * toolspeed, 100, 5, 'sound/weapons/circsawhit.ogg') //saws are very accurate and fast at butchering

/obj/item/circular_saw/augment
	desc = "A small but very fast spinning saw. Edges dulled to prevent accidental cutting inside of the surgeon."
	w_class = WEIGHT_CLASS_SMALL
	force = 10
	toolspeed = 0.5


/obj/item/surgical_drapes
	name = "surgical drapes"
	desc = "Nanotrasen brand surgical drapes provide optimal safety and infection control."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "surgical_drapes"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	item_state = "drapes"
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
	item_flags = SURGICAL_TOOL

/obj/item/organ_storage/afterattack(obj/item/I, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(contents.len)
		to_chat(user, "<span class='warning'>[src] already has something inside it!</span>")
		return
	if(!isorgan(I) && !isbodypart(I))
		to_chat(user, "<span class='warning'>[src] can only hold body parts!</span>")
		return

	user.visible_message("<span class='notice'>[user] puts [I] into [src].</span>", "<span class='notice'>You put [I] inside [src].</span>")
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
		user.visible_message("<span class='notice'>[user] dumps [I] from [src].</span>", "<span class='notice'>You dump [I] from [src].</span>")
		cut_overlays()
		I.forceMove(get_turf(src))
		icon_state = "evidenceobj"
		desc = "A container for holding body parts."
	else
		to_chat(user, "<span class='notice'>[src] is empty.</span>")
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
	desc = "An advanced scalpel which uses laser technology to cut."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel_a"
	hitsound = 'sound/weapons/blade1.ogg'
	force = 16
	toolspeed = 0.7
	light_color = LIGHT_COLOR_GREEN
	sharpness = IS_SHARP_ACCURATE

/obj/item/scalpel/advanced/Initialize()
	. = ..()
	set_light(1)

/obj/item/scalpel/advanced/attack_self(mob/user)
	playsound(get_turf(user), 'sound/machines/click.ogg', 50, TRUE)
	if(tool_behaviour == TOOL_SCALPEL)
		tool_behaviour = TOOL_SAW
		to_chat(user, "<span class='notice'>You increase the power of [src], now it can cut bones.</span>")
		set_light(2)
		force += 1 //we don't want to ruin sharpened stuff
		icon_state = "saw_a"
	else
		tool_behaviour = TOOL_SCALPEL
		to_chat(user, "<span class='notice'>You lower the power of [src], it can no longer cut bones.</span>")
		set_light(1)
		force -= 1
		icon_state = "scalpel_a"

/obj/item/scalpel/advanced/examine()
	. = ..()
	. += " It's set to [tool_behaviour == TOOL_SCALPEL ? "scalpel" : "saw"] mode."

/obj/item/retractor/advanced
	name = "mechanical pinches"
	desc = "An agglomerate of rods and gears."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "retractor_a"
	toolspeed = 0.7

/obj/item/retractor/advanced/attack_self(mob/user)
	playsound(get_turf(user), 'sound/items/change_drill.ogg', 50, TRUE)
	if(tool_behaviour == TOOL_RETRACTOR)
		tool_behaviour = TOOL_HEMOSTAT
		to_chat(user, "<span class='notice'>You configure the gears of [src], they are now in hemostat mode.</span>")
		icon_state = "hemostat_a"
	else
		tool_behaviour = TOOL_RETRACTOR
		to_chat(user, "<span class='notice'>You configure the gears of [src], they are now in retractor mode.</span>")
		icon_state = "retractor_a"

/obj/item/retractor/advanced/examine()
	. = ..()
	. += " It resembles a [tool_behaviour == TOOL_RETRACTOR ? "retractor" : "hemostat"]."

/obj/item/surgicaldrill/advanced
	name = "searing tool"
	desc = "It projects a high power laser used for medical application."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "surgicaldrill_a"
	hitsound = 'sound/items/welder.ogg'
	toolspeed = 0.7
	light_color = LIGHT_COLOR_RED

/obj/item/surgicaldrill/advanced/Initialize()
	. = ..()
	set_light(1)

/obj/item/surgicaldrill/advanced/attack_self(mob/user)
	playsound(get_turf(user), 'sound/weapons/tap.ogg', 50, TRUE)
	if(tool_behaviour == TOOL_DRILL)
		tool_behaviour = TOOL_CAUTERY
		to_chat(user, "<span class='notice'>You focus the lenses of [src], it is now in mending mode.</span>")
		icon_state = "cautery_a"
	else
		tool_behaviour = TOOL_DRILL
		to_chat(user, "<span class='notice'>You dilate the lenses of [src], it is now in drilling mode.</span>")
		icon_state = "surgicaldrill_a"

/obj/item/surgicaldrill/advanced/examine()
	. = ..()
	. += " It's set to [tool_behaviour == TOOL_DRILL ? "drilling" : "mending"] mode."
