/obj/item/stack/teeth
	name = "teeth"
	singular_name = "tooth"
	w_class = 1
	throwforce = 2
	max_amount = 32
	// gender = PLURAL
	desc = "Welp. Someone had their teeth knocked out."
	icon = 'hippiestation/icons/obj/teeth.dmi'
	icon_state = "teeth"

/obj/item/stack/teeth/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] jams [src] into \his eyes! It looks like \he's trying to commit suicide.</span>")
	return (BRUTELOSS)

/obj/item/stack/teeth/human
	name = "human teeth"
	singular_name = "human tooth"

/obj/item/stack/teeth/human/Initialize()
	..()
	transform *= TransformUsingVariable(0.25, 1, 0.5) //Half-size the teeth

/obj/item/stack/teeth/human/gold //Special traitor objective maybe?
	name = "golden teeth"
	singular_name = "gold tooth"
	desc = "Someone spent a fortune on these."
	icon_state = "teeth_gold"

/obj/item/stack/teeth/human/wood
	name = "wooden teeth"
	singular_name = "wooden tooth"
	desc = "Made from the worst trees botany can provide."
	icon_state = "teeth_wood"

/obj/item/stack/teeth/generic //Used for species without unique teeth defined yet
	name = "teeth"

/obj/item/stack/teeth/generic/Initialize()
	..()
	transform *= TransformUsingVariable(0.25, 1, 0.5) //Half-size the teeth

/obj/item/stack/teeth/replacement
	name = "replacement teeth"
	singular_name = "replacement tooth"
	// gender = PLURAL
	desc = "First teeth, now replacements. When does it end?"
	icon_state = "dentals"

/obj/item/stack/teeth/replacement/Initialize()
	..()
	transform *= TransformUsingVariable(0.25, 1, 0.5) //Half-size the teeth

/obj/item/stack/teeth/cat
	name = "tarajan teeth"
	singular_name = "tarajan tooth"
	desc = "Treasured trophy."
	sharpness = IS_SHARP
	icon_state = "teeth_cat"

/obj/item/stack/teeth/cat/Initialize()
	..()
	transform *= TransformUsingVariable(0.35, 1, 0.5) //resize the teeth

/obj/item/stack/teeth/lizard
	name = "lizard teeth"
	singular_name = "lizard tooth"
	desc = "They're quite sharp."
	sharpness = IS_SHARP
	icon_state = "teeth_cat"

/obj/item/stack/teeth/lizard/Initialize()
	..()
	transform *= TransformUsingVariable(0.30, 1, 0.5) //resize the teeth

/obj/item/stack/teeth/xeno
	name = "xenomorph teeth"
	singular_name = "xenomorph tooth"
	desc = "The only way to get these is to capture a xenomorph and surgically remove their teeth."
	throwforce = 4
	sharpness = IS_SHARP
	icon_state = "teeth_xeno"
	max_amount = 48

/datum/design/replacement_teeth
	name = "Replacement teeth"
	id = "replacement_teeth"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 250)
	build_path = /obj/item/stack/teeth/replacement
	category = list("initial", "Medical")

/datum/surgery/teeth_reinsertion
	name = "teeth reinsertion"
	steps = list(/datum/surgery_step/handle_teeth)
	possible_locs = list("mouth")

/datum/surgery_step/handle_teeth
	accept_hand = 1
	accept_any_item = 1
	time = 64

/datum/surgery_step/handle_teeth/preop(mob/user, mob/living/carbon/human/target, target_zone, obj/item/stack/teeth/T, datum/surgery/surgery)
	var/obj/item/bodypart/head/O = locate(/obj/item/bodypart/head) in target.bodyparts
	if(!O)
		user.visible_message("<span class='notice'>What the... [target] has no head!</span>")
		return -1
	if(istype(T))
		if(O.get_teeth() >= O.max_teeth)
			to_chat(user, "<span class='notice'>All of [target]'s teeth are intact.")
			return -1
		user.visible_message("<span class='notice'>[user] begins to insert [T] into [target]'s [target_zone].</span>")
	else
		user.visible_message("<span class='notice'>[user] checks for teeth in [target]'s [target_zone].</span>")

/datum/surgery_step/handle_teeth/success(mob/user, mob/living/carbon/human/target, target_zone, obj/item/stack/teeth/T, datum/surgery/surgery)
	var/obj/item/bodypart/head/O = locate(/obj/item/bodypart/head) in target.bodyparts
	if(!O)
		user.visible_message("<span class='notice'>What the... [target] has no head!</span>")
		return -1
	if(istype(T))
		if(O.get_teeth()) //Has teeth, check if they need "refilling"
			if(O.get_teeth() >= O.max_teeth)
				user.visible_message("<span class='notice'>[user] can't seem to fit [T] in [target]'s [target_zone].</span>", "<span class='notice'>All of [target]'s teeth are intact.</span>")
				return 0
			var/obj/item/stack/teeth/F = locate(T.type) in O.teeth_list //Look for same type of teeth inside target's mouth for merging
			var/amt = T.amount
			if(F)
				amt = T.merge(F) //Try to merge provided teeth into person's teeth.
			else
				amt = min(T.amount, O.max_teeth-O.get_teeth())
				T.use(amt)
				var/obj/item/stack/teeth/E = new T.type(target, amt)
				O.teeth_list += E
				// E.loc = target
				T = E
			user.visible_message("<span class='notice'>[user] inserts [amt] [T] into [target]'s [target_zone]!</span>")
			return 1
		else //No teeth to speak of.
			var/amt = min(T.amount, O.max_teeth)
			T.use(amt)
			var/obj/item/stack/teeth/F = new T.type(target, amt)
			O.teeth_list += F
			// F.loc = target
			T = F
			user.visible_message("<span class='notice'>[user] inserts [amt] [T] into [target]'s [target_zone]!</span>")
			return 1
	else
		if(O.teeth_list.len)
			user.visible_message("<span class='notice'>[user] pulls all teeth out of [target]'s [target_zone]!</span>")
			for(var/obj/item/stack/teeth/F in O.teeth_list)
				O.teeth_list -= F
				F.loc = get_turf(target)
			return 1
		else
			user.visible_message("<span class='notice'>[user] doesn't find anything in [target]'s [target_zone].</span>")
			return 0

/datum/species
	var/teeth_type = /obj/item/stack/teeth/generic

/datum/species/human
	teeth_type = /obj/item/stack/teeth/human

/datum/species/skeleton
	teeth_type = /obj/item/stack/teeth/human
