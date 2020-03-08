/obj/item/clothing/shoes
	name = "shoes"
	icon = 'icons/obj/clothing/shoes.dmi'
	desc = "Comfortable-looking shoes."
	gender = PLURAL //Carn: for grammarically correct text-parsing
	var/chained = 0

	body_parts_covered = FEET
	slot_flags = ITEM_SLOT_FEET

	permeability_coefficient = 0.5
	slowdown = SHOES_SLOWDOWN
	strip_delay = 1 SECONDS
	var/blood_state = BLOOD_STATE_NOT_BLOODY
	var/list/bloody_shoes = list(BLOOD_STATE_HUMAN = 0,BLOOD_STATE_XENO = 0, BLOOD_STATE_OIL = 0, BLOOD_STATE_NOT_BLOODY = 0)
	var/offset = 0
	var/equipped_before_drop = FALSE
	var/can_be_bloody = TRUE
	///Whether these shoes have laces that can be tied/untied
	var/can_be_tied = TRUE
	///Are we currently tied? Can either be SHOES_UNTIED, SHOES_TIED, or SHOES_KNOTTED
	var/tied = SHOES_TIED
	///How long it takes to lace/unlace these shoes
	var/lace_time = 5 SECONDS

/obj/item/clothing/shoes/ComponentInitialize()
	. = ..()
	RegisterSignal(src, COMSIG_COMPONENT_CLEAN_ACT, .proc/clean_blood)

/obj/item/clothing/shoes/suicide_act(mob/living/carbon/user)
	if(rand(2)>1)
		user.visible_message("<span class='suicide'>[user] begins tying \the [src] up waaay too tightly! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		var/obj/item/bodypart/l_leg = user.get_bodypart(BODY_ZONE_L_LEG)
		var/obj/item/bodypart/r_leg = user.get_bodypart(BODY_ZONE_R_LEG)
		if(l_leg)
			l_leg.dismember()
		if(r_leg)
			r_leg.dismember()
		playsound(user, "desceration", 50, TRUE, -1)
		return BRUTELOSS
	else//didnt realize this suicide act existed (was in miscellaneous.dm) and didnt want to remove it, so made it a 50/50 chance. Why not!
		user.visible_message("<span class='suicide'>[user] is bashing [user.p_their()] own head in with [src]! Ain't that a kick in the head?</span>")
		for(var/i = 0, i < 3, i++)
			sleep(3)
			playsound(user, 'sound/weapons/genhit2.ogg', 50, TRUE)
		return(BRUTELOSS)

/obj/item/clothing/shoes/worn_overlays(isinhands = FALSE)
	. = list()
	if(!isinhands)
		var/bloody = FALSE
		if(HAS_BLOOD_DNA(src))
			bloody = TRUE
		else
			bloody = bloody_shoes[BLOOD_STATE_HUMAN]

		if(damaged_clothes)
			. += mutable_appearance('icons/effects/item_damage.dmi', "damagedshoe")
		if(bloody)
			. += mutable_appearance('icons/effects/blood.dmi', "shoeblood")

/obj/item/clothing/shoes/examine(mob/user)
	. = ..()

	if(!ishuman(loc))
		return ..()
	if(tied == SHOES_UNTIED)
		. += "The shoelaces are untied."
	else if(tied == SHOES_KNOTTED)
		. += "The shoelaces are all knotted together."

/obj/item/clothing/shoes/equipped(mob/user, slot)
	. = ..()
	if(offset && (slot_flags & slot))
		user.pixel_y += offset
		worn_y_dimension -= (offset * 2)
		user.update_inv_shoes()
		equipped_before_drop = TRUE

/obj/item/clothing/shoes/proc/restore_offsets(mob/user)
	equipped_before_drop = FALSE
	user.pixel_y -= offset
	worn_y_dimension = world.icon_size

/obj/item/clothing/shoes/dropped(mob/user)
	if(offset && equipped_before_drop)
		restore_offsets(user)
	. = ..()

/obj/item/clothing/shoes/update_clothes_damaged_state(damaging = TRUE)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_shoes()

/obj/item/clothing/shoes/proc/clean_blood(datum/source, strength)
	if(strength < CLEAN_STRENGTH_BLOOD)
		return
	bloody_shoes = list(BLOOD_STATE_HUMAN = 0,BLOOD_STATE_XENO = 0, BLOOD_STATE_OIL = 0, BLOOD_STATE_NOT_BLOODY = 0)
	blood_state = BLOOD_STATE_NOT_BLOODY
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_shoes()

/obj/item/proc/negates_gravity()
	return FALSE

/obj/item/clothing/shoes/proc/tie(mob/user)
	tied = SHOES_TIED
	UnregisterSignal(src, COMSIG_SHOES_STEP_ACTION)

/obj/item/clothing/shoes/proc/knot(mob/user)
	tied = SHOES_KNOTTED
	RegisterSignal(src, COMSIG_SHOES_STEP_ACTION, .proc/check_trip, override=TRUE)

/obj/item/clothing/shoes/proc/untie(mob/user)
	tied = SHOES_UNTIED
	RegisterSignal(src, COMSIG_SHOES_STEP_ACTION, .proc/check_trip, override=TRUE)

/obj/item/clothing/shoes/proc/handle_tying(mob/living/carbon/human/user)
	var/mob/living/carbon/human/our_guy = loc
	if(!istype(our_guy))
		return

	if(user != loc)
		if(user.mobility_flags & MOBILITY_STAND)
			to_chat(user, "<span class='warning'>You must be on the floor to interact with [src]!</span>")
			return

		if(tied == SHOES_KNOTTED)
			to_chat(user, "<span class='warning'>The laces on [loc]'s [src.name] are already a hopelessly tangled mess!</span>")
			return

		to_chat(user, "<span class='notice'>You quietly set to work [tied ? "untying" : "knotting"] [loc]'s [src.name]...</span>")

		var/mod_time = lace_time
		if(HAS_TRAIT(user, TRAIT_CLUMSY)) // based clowns trained their whole lives for this
			mod_time *= 0.75

		if(do_after(user, mod_time, needhand=TRUE, target=src))
			if(tied == SHOES_UNTIED)
				to_chat(user, "<span class='notice'>You knot [loc]'s [src.name].</span>")
				knot(user)
			else
				to_chat(user, "<span class='notice'>You untie [loc]'s [src.name].</span>")
				untie(user)
		else
			user.visible_message("<span class='danger'>[our_guy] stamps on [user]'s hand, mid-shoelace [tied ? "knotting" : "untying"]!</span>", "<span class='userdanger'>Ow! [our_guy] stamps on your hand!</span>", user)
			to_chat(our_guy, "<span class='userdanger'>You stamp on [user]'s hand! What the- they were [tied ? "knotting" : "untying"] your shoelaces!</span>")
			user.emote("scream")
			var/obj/item/bodypart/ouchie = user.get_bodypart(pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
			if(ouchie)
				ouchie.receive_damage(15)
			user.Paralyze(5)
	else

		if(tied == SHOES_UNTIED)
			user.visible_message("<span class='notice'>[user] begins tying the laces of [user.p_their()] [src.name].</span>", "<span class='notice'>You begin tying the laces of your [src.name]...</span>")
			if(do_after(user, lace_time, needhand=TRUE, target=src))
				tie(user)
				to_chat(user, "<span class='notice'>You tie the laces on your [src.name].</span>")
		else if(tied == SHOES_KNOTTED)
			user.visible_message("<span class='notice'>[user] begins fiddlng with the knot in the laces of [user.p_their()] [src.name].</span>", "<span class='notice'>You begin fiddling with the knot in the laces of your [src.name]...</span>")
			if(do_after(user, lace_time, needhand=TRUE, target=src))
				untie(user)
				to_chat(user, "<span class='notice'>You manage to untangle the knot in the laces on your [src.name].</span>")

/obj/item/clothing/shoes/proc/check_trip()
	var/mob/living/carbon/human/our_guy = loc
	if(!istype(our_guy)) // are they REALLY /our guy/?
		return
	if(tied == SHOES_KNOTTED)
		our_guy.Paralyze(5)
		our_guy.Knockdown(10)
		our_guy.visible_message("<span class='danger'>[our_guy] trips on [our_guy.p_their()] knotted shoelaces and falls! What a klutz!</span>", "<span class='userdanger'>You trip on your knotted shoelaces and fall over!</span>")
	else if(tied ==  SHOES_UNTIED)
		if(prob(0.5)) // 1/200
			to_chat(our_guy, "<span class='danger'>You stumble a bit on your untied shoelaces!</span>")
		else if(prob(0.1)) // 1/1000
			var/have_anything = FALSE
			for(var/obj/item/I in our_guy.held_items)
				have_anything = TRUE
				our_guy.accident(I)
			to_chat(our_guy, "<span class='danger'>You trip on your shoelaces a bit[have_anything ? ", flinging what you were holding" : ""]!</span>")
		else if(prob(0.05)) // 1/2000
			our_guy.throw_at(get_step(our_guy, our_guy.dir), range=3)
			to_chat(our_guy, "<span class='userdanger'>You stumble on your untied shoelaces and lurch forward!</span>")

/obj/item/clothing/shoes/attack_hand(mob/living/carbon/human/user)
	if(!istype(user))
		return ..()
	if(loc == user && tied != SHOES_TIED)
		handle_tying(user)
		return
	..()

/obj/item/clothing/shoes/attack_self(mob/user)
	. = ..()

	to_chat(user, "<span class='notice'>You begin [tied ? "undoing" : "tying"] the laces on [src]...</span>")
	if(do_after(user, lace_time, needhand=TRUE, target=src))
		if(tied == SHOES_UNTIED)
			to_chat(user, "<span class='notice'>You tie the laces on [src].</span>")
			tie(user)
		else
			to_chat(user, "<span class='notice'>You undo the laces on [src].</span>")
			untie(user)
