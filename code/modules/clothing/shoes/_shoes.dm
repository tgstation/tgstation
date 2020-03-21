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
	///any alerts we have active
	var/obj/screen/alert/our_alert

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
	if(can_be_tied && tied == SHOES_UNTIED)
		our_alert = user.throw_alert("shoealert", /obj/screen/alert/shoes/untied)
		RegisterSignal(src, COMSIG_SHOES_STEP_ACTION, .proc/check_trip, override=TRUE)

/obj/item/clothing/shoes/proc/restore_offsets(mob/user)
	equipped_before_drop = FALSE
	user.pixel_y -= offset
	worn_y_dimension = world.icon_size

/obj/item/clothing/shoes/dropped(mob/user)
	if(our_alert && our_alert.owner == user)
		user.clear_alert("shoealert")
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

/**
  * adjust_laces adjusts whether our shoes (assuming they can_be_tied) and tied, untied, or knotted
  *
  * In addition to setting the state, it will deal with getting rid of alerts if they exist, as well as registering and unregistering the stepping signals
  *
  * Arguments:
  * *
  * * state: SHOES_UNTIED, SHOES_TIED, or SHOES_KNOTTED, depending on what you want them to become
  * * user: used to check to see if we're the ones unknotting our own laces
  */
/obj/item/clothing/shoes/proc/adjust_laces(state, mob/user)
	if(!can_be_tied)
		return

	var/mob/living/carbon/human/our_guy
	if(ishuman(loc))
		our_guy = loc

	tied = state
	if(tied == SHOES_TIED)
		if(our_guy)
			our_guy.clear_alert("shoealert")
		UnregisterSignal(src, COMSIG_SHOES_STEP_ACTION)
	else
		if(tied == SHOES_UNTIED && our_guy && user == our_guy)
			our_alert = our_guy.throw_alert("shoealert", /obj/screen/alert/shoes/untied) // if we're the ones unknotting our own laces, of course we know they're untied
		RegisterSignal(src, COMSIG_SHOES_STEP_ACTION, .proc/check_trip, override=TRUE)

/**
  * handle_tying deals with all the actual tying/untying/knotting, inferring your intent from who you are in relation to the state of the laces
  *
  * If you're the wearer, you want them to move towards tied-ness (knotted -> untied -> tied). If you're not, you're pranking them, so you're moving towards knotted-ness (tied -> untied -> knotted)
  *
  * Arguments:
  * *
  * * user: who is the person interacting with the shoes?
  */
/obj/item/clothing/shoes/proc/handle_tying(mob/living/carbon/human/user)
	///our_guy here is the wearer, if one exists (and he must exist, or we don't care)
	var/mob/living/carbon/human/our_guy = loc
	if(!istype(our_guy))
		return

	if(user == loc && tied != SHOES_TIED) // if they're our own shoes, go tie-wards
		user.visible_message("<span class='notice'>[user] begins [tied ? "unknotting" : "tying"] the laces of [user.p_their()] [src.name].</span>", "<span class='notice'>You begin [tied ? "unknotting" : "tying"] the laces of your [src.name]...</span>")

		if(do_after(user, lace_time, needhand=TRUE, target=src))
			to_chat(user, "<span class='notice'>You [tied ? "unknot" : "tie"] the laces of your [src.name].</span>")
			if(tied == SHOES_UNTIED)
				adjust_laces(SHOES_TIED, user)
			else
				adjust_laces(SHOES_UNTIED, user)

	else // if they're someone else's shoes, go knot-wards
		if(user.mobility_flags & MOBILITY_STAND)
			to_chat(user, "<span class='warning'>You must be on the floor to interact with [src]!</span>")
			return
		if(tied == SHOES_KNOTTED)
			to_chat(user, "<span class='warning'>The laces on [loc]'s [src.name] are already a hopelessly tangled mess!</span>")
			return

		var/mod_time = lace_time
		to_chat(user, "<span class='notice'>You quietly set to work [tied ? "untying" : "knotting"] [loc]'s [src.name]...</span>")
		if(HAS_TRAIT(user, TRAIT_CLUMSY)) // based clowns trained their whole lives for this
			mod_time *= 0.75

		if(do_after(user, mod_time, needhand=TRUE, target=src))
			to_chat(user, "<span class='notice'>You [tied ? "untie" : "knot"] the laces on [loc]'s [src.name].</span>")
			if(tied == SHOES_UNTIED)
				adjust_laces(SHOES_KNOTTED, user)
			else
				adjust_laces(SHOES_UNTIED, user)
		else // if one of us moved
			user.visible_message("<span class='danger'>[our_guy] stamps on [user]'s hand, mid-shoelace [tied ? "knotting" : "untying"]!</span>", "<span class='userdanger'>Ow! [our_guy] stamps on your hand!</span>", user)
			to_chat(our_guy, "<span class='userdanger'>You stamp on [user]'s hand! What the- they were [tied ? "knotting" : "untying"] your shoelaces!</span>")
			user.emote("scream")
			var/obj/item/bodypart/ouchie = user.get_bodypart(pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
			if(ouchie)
				ouchie.receive_damage(15)
			user.Paralyze(5)

/**
  * check_trip runs on each step to see if we fall over as a result of our lace status. Knotted laces are a guaranteed trip, while untied shoes are just a chance to stumble
  */
/obj/item/clothing/shoes/proc/check_trip()
	var/mob/living/carbon/human/our_guy = loc
	if(!istype(our_guy)) // are they REALLY /our guy/?
		return

	if(tied == SHOES_KNOTTED)
		our_guy.Paralyze(5)
		our_guy.Knockdown(10)
		our_guy.visible_message("<span class='danger'>[our_guy] trips on [our_guy.p_their()] knotted shoelaces and falls! What a klutz!</span>", "<span class='userdanger'>You trip on your knotted shoelaces and fall over!</span>")
		SEND_SIGNAL(our_guy, COMSIG_ADD_MOOD_EVENT, "trip", /datum/mood_event/tripped) // well we realized they're knotted now!
		our_alert = our_guy.throw_alert("shoealert", /obj/screen/alert/shoes/knotted)
	else if(tied ==  SHOES_UNTIED)
		var/wiser = TRUE // did we stumble and realize our laces are undone?
		switch(rand(1, 1000))
			if(1) // .1% chance to trip and fall over (note these are per step while our laces are undone)
				our_guy.Paralyze(5)
				our_guy.Knockdown(10)
				our_guy.visible_message("<span class='danger'>[our_guy] trips on [our_guy.p_their()] untied shoelaces and falls! What a klutz!</span>", "<span class='userdanger'>You trip on your untied shoelaces and fall over!</span>")
			if(2 to 5) // .4% chance to stumble and lurch forward
				our_guy.throw_at(get_step(our_guy, our_guy.dir), 3, 2)
				to_chat(our_guy, "<span class='danger'>You stumble on your untied shoelaces and lurch forward!</span>")
			if(6 to 13) // .7% chance to stumble and fling what we're holding
				var/have_anything = FALSE
				for(var/obj/item/I in our_guy.held_items)
					have_anything = TRUE
					our_guy.accident(I)
				to_chat(our_guy, "<span class='danger'>You trip on your shoelaces a bit[have_anything ? ", flinging what you were holding" : ""]!</span>")
			if(14 to 25) // 1.3ish% chance to stumble and be a bit off balance (like being disarmed)
				to_chat(our_guy, "<span class='danger'>You stumble a bit on your untied shoelaces!</span>")
				if(!our_guy.has_movespeed_modifier(/datum/movespeed_modifier/shove))
					our_guy.add_movespeed_modifier(/datum/movespeed_modifier/shove)
					addtimer(CALLBACK(our_guy, /mob/living/carbon/human/proc/clear_shove_slowdown), SHOVE_SLOWDOWN_LENGTH)
			if(26 to 1000)
				wiser = FALSE

		if(wiser)
			SEND_SIGNAL(our_guy, COMSIG_ADD_MOOD_EVENT, "untied", /datum/mood_event/untied) // well we realized they're untied now!
			our_alert = our_guy.throw_alert("shoealert", /obj/screen/alert/shoes/untied)


/obj/item/clothing/shoes/attack_hand(mob/living/carbon/human/user)
	if(!istype(user))
		return ..()
	if(loc == user && tied != SHOES_TIED)
		handle_tying(user)
		return
	..()

/obj/item/clothing/shoes/attack_self(mob/user)
	. = ..()

	to_chat(user, "<span class='notice'>You begin [tied ? "untying" : "tying"] the laces on [src]...</span>")
	if(do_after(user, lace_time, needhand=TRUE, target=src))
		to_chat(user, "<span class='notice'>You [tied ? "untie" : "tie"] the laces on [src].</span>")
		if(tied == SHOES_UNTIED)
			adjust_laces(SHOES_TIED, user)
		else
			adjust_laces(SHOES_UNTIED, user)
