//These objects are used in the cardinal sin-themed ruins (i.e. Gluttony, Pride...)

/obj/structure/cursed_slot_machine //Greed's slot machine: Used in the Greed ruin. Deals clone damage on each use, with a successful use giving a d20 of fate.
	name = "greed's slot machine"
	desc = "High stakes, high rewards."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "slots"
	var/icon_screen = "slots_screen"
	var/brightness_on = 1
	anchored = TRUE
	density = TRUE
	var/win_prob = 5
	/// clone damaged dealt each roll
	var/damage_on_roll = 20
	/// machine's reward when you hit jackpot
	var/prize = /obj/structure/cursed_money

/obj/structure/cursed_slot_machine/Initialize(mapload)
	. = ..()
	update_appearance()
	set_light(brightness_on)

/obj/structure/cursed_slot_machine/interact(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(obj_flags & IN_USE)
		return
	obj_flags |= IN_USE
	user.adjustCloneLoss(damage_on_roll)
	if(user.stat)
		to_chat(user, span_userdanger("No... just one more try..."))
		user.investigate_log("has been gibbed by [src].", INVESTIGATE_DEATHS)
		user.gib()
	else
		user.visible_message(span_warning("[user] pulls [src]'s lever with a glint in [user.p_their()] eyes!"), "<span class='warning'>You feel a draining as you pull the lever, but you \
		know it'll be worth it.</span>")
	icon_screen = "slots_screen_working"
	update_appearance()
	playsound(src, 'sound/lavaland/cursed_slot_machine.ogg', 50, FALSE)
	addtimer(CALLBACK(src, PROC_REF(determine_victor), user), 50)

/obj/structure/cursed_slot_machine/proc/determine_victor(mob/living/user)
	icon_screen = "slots_screen"
	update_appearance()
	obj_flags &= ~IN_USE
	if(prob(win_prob))
		playsound(src, 'sound/lavaland/cursed_slot_machine_jackpot.ogg', 50, FALSE)
		new prize(get_turf(src))
		if(user)
			to_chat(user, span_boldwarning("You've hit jackpot. Laughter echoes around you as your reward appears in the machine's place."))
		qdel(src)
	else
		if(user)
			to_chat(user, span_boldwarning("Fucking machine! Must be rigged. Still... one more try couldn't hurt, right?"))

/obj/structure/cursed_slot_machine/update_overlays()
	. = ..()
	var/overlay_state = icon_screen
	. += mutable_appearance(icon, overlay_state)
	. += emissive_appearance(icon, overlay_state, src)

/obj/structure/cursed_money
	name = "bag of money"
	desc = "RICH! YES! YOU KNEW IT WAS WORTH IT! YOU'RE RICH! RICH! RICH!"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "moneybag"
	anchored = FALSE
	density = TRUE

/obj/structure/cursed_money/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(collapse)), 600)

/obj/structure/cursed_money/proc/collapse()
	visible_message("<span class='warning'>[src] falls in on itself, \
		canvas rotting away and contents vanishing.</span>")
	qdel(src)

/obj/structure/cursed_money/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	user.visible_message("<span class='warning'>[user] opens the bag and \
		and removes a die. The bag then vanishes.</span>",
		"[span_boldwarning("You open the bag...!")]\n\
		<span class='danger'>And see a bag full of dice. Confused, \
		you take one... and the bag vanishes.</span>")
	var/turf/T = get_turf(user)
	var/obj/item/dice/d20/fate/one_use/critical_fail = new(T)
	user.put_in_hands(critical_fail)
	qdel(src)

/obj/effect/gluttony //Gluttony's wall: Used in the Gluttony ruin. Only lets the overweight through.
	name = "gluttony's wall"
	desc = "Only those who truly indulge may pass."
	anchored = TRUE
	density = TRUE
	icon_state = "blob"
	icon = 'icons/mob/nonhuman-player/blob.dmi'
	color = rgb(145, 150, 0)

/obj/effect/gluttony/CanAllowThrough(atom/movable/mover, border_dir)//So bullets will fly over and stuff.
	. = ..()
	if(ishuman(mover))
		var/mob/living/carbon/human/H = mover
		if(H.nutrition >= NUTRITION_LEVEL_FAT)
			H.visible_message(span_warning("[H] pushes through [src]!"), span_notice("You've seen and eaten worse than this."))
			return TRUE
		else
			to_chat(H, span_warning("You're repulsed by even looking at [src]. Only a pig could force themselves to go through it."))
	if(istype(mover, /mob/living/basic/morph))
		return TRUE

//can't be bothered to do sloth right now, will make later

/obj/item/knife/envy //Envy's knife: Found in the Envy ruin. Attackers take on the appearance of whoever they strike.
	name = "envy's knife"
	desc = "Their success will be yours."
	icon = 'icons/obj/weapons/khopesh.dmi'
	icon_state = "render"
	inhand_icon_state = "knife"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	force = 18
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/knife/envy/afterattack(atom/movable/AM, mob/living/carbon/human/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(!istype(user))
		return
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(user.real_name != H.dna.real_name)
			user.real_name = H.dna.real_name
			H.dna.transfer_identity(user, transfer_SE=1)
			user.updateappearance(mutcolor_update=1)
			user.domutcheck()
			user.visible_message(span_warning("[user]'s appearance shifts into [H]'s!"), \
			span_boldannounce("[H.p_They()] think[H.p_s()] [H.p_theyre()] <i>sooo</i> much better than you. Not anymore, [H.p_they()] won't."))
