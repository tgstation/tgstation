/obj/item/clothing/mask/hippie/tape
	name = "tape"
	desc = "Taking that off is going to hurt."
	icon_state = "tape"
	flags_cover = MASKCOVERSMOUTH
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0.90
	strip_delay = 10
	var/used = FALSE

/obj/item/clothing/mask/hippie/tape/attack_hand(mob/user as mob)
	if (!user) return
	if (istype(src.loc, /obj/item/storage))
		return ..()
	var/mob/living/carbon/human/H = user
	if(loc == user && H.wear_mask == src)
		to_chat(H, "<span class='userdanger'>Your tape was forcefully removed from your mouth. It's not pleasant.</span>")
		playsound(user, 'hippiestation/sound/misc/ducttape2.ogg', 50, 1)
		H.apply_damage(2, BRUTE, "head")
		user.emote("scream")
		user.dropItemToGround(user.get_active_held_item())
		used = TRUE
		qdel(src)
	else
		..()

/obj/item/clothing/mask/hippie/tape/dropped(mob/user as mob)
	if (!user) return
	if (istype(src.loc, /obj/item/storage) || used)
		return ..()
	var/mob/living/carbon/human/H = user
	..()
	if(H.wear_mask == src && !used)
		to_chat(H, "<span class='userdanger'>Your tape was forcefully removed from your mouth. It's not pleasant.</span>")
		playsound(user, 'hippiestation/sound/misc/ducttape2.ogg', 50, 1)
		H.apply_damage(2, BRUTE, "head")
		user.dropItemToGround(user.get_active_held_item())
		user.emote("scream")
		qdel(src)

/obj/item/clothing/mask/hippie/tape/speechModification(message)
	var/M = muffledspeech(message)
	return M

/obj/item/stack/ducttape
	desc = "It's duct tape. You can use it to tape something... or someone."
	name = "duct tape"
	icon = 'hippiestation/icons/obj/bureaucracy.dmi'
	lefthand_file = 'hippiestation/icons/mob/inhands/lefthand.dmi'
	righthand_file = 'hippiestation/icons/mob/inhands/righthand.dmi'
	icon_state = "tape"
	item_state = "tape"
	amount = 15
	flags_1 = NOBLUDGEON_1
	max_amount = 15
	throwforce = 0
	w_class = 2.0
	throw_speed = 3
	throw_range = 7

/obj/item/stack/ducttape/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is taping \his entire face with the [src.name]! It looks like \he's trying to commit suicide.</span>")
	return(OXYLOSS)

/obj/item/stack/ducttape/afterattack(atom/W, mob/user as mob, proximity_flag)
	if(!proximity_flag) return //It should only work on adjacent target.
	if(istype(W, /obj/item/storage/bag/tray))
		var/obj/item/shield/trayshield/new_item = new(user.loc)
		to_chat(user, "<span class='notice'>You strap [src] to \the [W].</span>")
		var/replace = (user.get_inactive_held_item()==W)
		qdel(W)
		if(src.use(3) == 0)
			user.dropItemToGround(src)
			qdel(src)
		if(replace)
			user.put_in_hands(new_item)
		playsound(user, 'hippiestation/sound/misc/ducttape1.ogg', 50, 1)
	if(istype(W, /obj/item/shard) && !istype(W, /obj/item/shard/shank))
		var/obj/item/shard/shank/new_item = new(user.loc)
		to_chat(user, "<span class='notice'>You strap [src] to \the [W].</span>")
		var/replace = (user.get_inactive_held_item()==W)
		qdel(W)
		if(src.use(3) == 0)
			user.dropItemToGround(src)
			qdel(src)
		if(replace)
			user.put_in_hands(new_item)
		playsound(user, 'hippiestation/sound/misc/ducttape1.ogg', 50, 1)
	if(ishuman(W) && (user.zone_selected == "mouth" || user.zone_selected == "head"))
		var/mob/living/carbon/human/H = W
		if(H.head && (H.head.flags_cover & HEADCOVERSMOUTH))
			to_chat(user, "<span class='danger'>You're going to need to remove [H.head] first.</span>")
			return
		if(H.wear_mask) //don't even check to see if the mask covers the mouth as the tape takes up mask slot
			to_chat(user, "<span class='danger'>You're going to need to remove [H.wear_mask] first.</span>")
			return
		playsound(loc, 'hippiestation/sound/misc/ducttape1.ogg', 30, 1)
		to_chat(user, "<span class='notice'>You start tape [H]'s mouth shut.</span>")
		if(do_mob(user, H, 20))
			// H.wear_mask = new/obj/item/clothing/mask/hippie/tape(H)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/hippie/tape(H), slot_wear_mask)
			to_chat(user, "<span class='notice'>You tape [H]'s mouth shut.</span>")
			playsound(loc, 'hippiestation/sound/misc/ducttape1.ogg', 50, 1)
			if(src.use(2) == 0)
				user.dropItemToGround(src)
				qdel(src)
			add_logs(user, H, "mouth-taped")
		else
			to_chat(user, "<span class='warning'>You fail to tape [H]'s mouth shut.</span>")
