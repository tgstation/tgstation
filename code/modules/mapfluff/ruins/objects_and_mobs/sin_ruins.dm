//These objects are used in the cardinal sin-themed ruins (i.e. Gluttony, Pride...)

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
	icon = 'icons/obj/weapons/stabby.dmi'
	icon_state = "envyknife"
	inhand_icon_state = "knife"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	force = 18
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/knife/envy/afterattack(atom/target, mob/living/carbon/human/user, click_parameters)
	if(!istype(user) || !ishuman(target))
		return

	var/mob/living/carbon/human/H = target
	if(user.real_name == H.dna.real_name)
		return

	user.real_name = H.dna.real_name
	H.dna.transfer_identity(user, transfer_SE=1)
	user.updateappearance(mutcolor_update=1)
	user.domutcheck()
	user.visible_message(span_warning("[user]'s appearance shifts into [H]'s!"), \
	span_boldannounce("[H.p_They()] think[H.p_s()] [H.p_theyre()] <i>sooo</i> much better than you. Not anymore, [H.p_they()] won't."))
