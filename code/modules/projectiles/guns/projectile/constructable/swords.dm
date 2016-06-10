/obj/item/weapon/sword
	name = "sword"
	desc = "A simple sword, hand-forged from smaller blades."
	icon = 'icons/obj/weaponsmithing.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	icon_state = "sword"
	w_class = W_CLASS_MEDIUM
	hitsound = "sound/weapons/bloodyslice.ogg"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT | SLOT_BACK
	force = 15
	throwforce = 10
	sharpness = 1.2
	attack_verb = list("attacks", "slashes", "stabs", "slices", "tears", "rips", "dices", "cuts")
	var/obj/item/weapon/reagent_containers/hypospray/hypo = null

	suicide_act(mob/user)
		to_chat(viewers(user), "<span class='danger'>[user] is falling on the [src.name]! It looks like \he's trying to commit suicide.</span>")
		return(BRUTELOSS)

/obj/item/weapon/sword/attack_self(mob/user as mob)
	if(!hypo)
		return
	to_chat(user, "You remove \the [hypo] from \the [src].")
	hypo.forceMove(get_turf(user.loc))
	user.put_in_hands(hypo)
	hypo = null
	overlays.len = 0

/obj/item/weapon/sword/update_icon()
	overlays.len = 0
	if(hypo)
		var/image/hypo_icon = image('icons/obj/weaponsmithing.dmi', src, "sword_hypo_overlay")
		overlays += hypo_icon

/obj/item/weapon/sword/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/metal_blade))
		to_chat(user, "You attach \the [W] to \the [src].")
		if(src.loc == user)
			user.drop_item(src, force_drop = 1)
			var/obj/item/weapon/sword/executioner/I = new (get_turf(user))
			user.put_in_hands(I)
		else
			new /obj/item/weapon/sword/executioner(get_turf(src.loc))
		qdel(src)
		qdel(W)
	if(W.type == /obj/item/weapon/reagent_containers/hypospray || W.type == /obj/item/weapon/reagent_containers/hypospray/creatine)
		to_chat(user, "You wrap \the [src]'s grip around \the [W], affixing it to the base of \the [src].")
		user.drop_item(W, force_drop = 1)
		hypo = W
		W.forceMove(src)
		update_icon()
	if(hypo && istype(W, /obj/item/weapon/aluminum_cylinder))
		to_chat(user, "You affix \the [W] to the bottom of \the [src]'s [hypo.name].")
		if(src.loc == user)
			user.drop_item(src, force_drop = 1)
			var/obj/item/weapon/sword/venom/I = new (get_turf(user))
			hypo.reagents.clear_reagents()
			I.HY = hypo
			hypo.forceMove(I)
			hypo = null
			user.put_in_hands(I)
		else
			new /obj/item/weapon/sword/venom(get_turf(src.loc))
		qdel(src)
		qdel(W)

/obj/item/weapon/sword/Destroy()
	if(hypo)
		qdel(hypo)
		hypo = null
	..()

/obj/item/weapon/sword/venom
	name = "venom sword"
	desc = "A unique and deadly sword. Its hypospray allows it to be coated in a variety of dangerous chemicals."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	icon_state = "venom_sword"
	var/beaker = null
	var/obj/item/weapon/reagent_containers/hypospray/HY = null

/obj/item/weapon/sword/venom/Destroy()
	if(beaker)
		qdel(beaker)
		beaker = null
	if(HY)
		qdel(HY)
		HY = null
	..()

/obj/item/weapon/sword/venom/proc/update_color()
	var/mob/living/carbon/human/H = loc
	overlays.len = 0

	if(beaker)
		var/obj/item/weapon/reagent_containers/glass/beaker/B = beaker
		if(B.reagents.total_volume)
			var/image/inventory = image('icons/obj/weaponsmithing.dmi', src, "venom_sword_overlay")
			var/image/rhand = image('icons/obj/weaponsmithing.dmi', src, "venom_sword_r_hand_overlay")
			var/image/lhand = image('icons/obj/weaponsmithing.dmi', src, "venom_sword_l_hand_overlay")

			inventory.icon += mix_color_from_reagents(B.reagents.reagent_list)
			inventory.alpha = mix_alpha_from_reagents(B.reagents.reagent_list)

			rhand.icon += mix_color_from_reagents(B.reagents.reagent_list)
			rhand.alpha = mix_alpha_from_reagents(B.reagents.reagent_list)

			lhand.icon += mix_color_from_reagents(B.reagents.reagent_list)
			lhand.alpha = mix_alpha_from_reagents(B.reagents.reagent_list)

			if(inventory.alpha >= 150)
				inventory.alpha -= 100
			if(rhand.alpha >= 150)
				rhand.alpha -= 100
			if(lhand.alpha >= 150)
				lhand.alpha -= 100

			dynamic_overlay["[HAND_LAYER]-[GRASP_LEFT_HAND]"] = lhand
			dynamic_overlay["[HAND_LAYER]-[GRASP_RIGHT_HAND]"] = rhand

			overlays += inventory
			if (istype(loc, /mob/living/carbon/human)) //Needs to always update its own overlay, but only update mob overlays if it's actually on a mob.
				H.update_inv_hands()
		else
			dynamic_overlay["[HAND_LAYER]-[GRASP_LEFT_HAND]"] = null
			dynamic_overlay["[HAND_LAYER]-[GRASP_RIGHT_HAND]"] = null
			if (istype(loc, /mob/living/carbon/human))
				H.update_inv_hands()

	else
		dynamic_overlay["[HAND_LAYER]-[GRASP_LEFT_HAND]"] = null
		dynamic_overlay["[HAND_LAYER]-[GRASP_RIGHT_HAND]"] = null
		if (istype(loc, /mob/living/carbon/human))
			H.update_inv_hands()

/obj/item/weapon/sword/venom/attack_self(mob/user as mob)
	if(!beaker)
		return
	else
		var/obj/item/weapon/reagent_containers/glass/beaker/B = beaker
		B.forceMove(user.loc)
		user.put_in_hands(B)
		beaker = null
		to_chat(user, "You remove \the [B] from \the [src].")
		icon_state = "venom_sword"
		update_color()

/obj/item/weapon/sword/venom/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/reagent_containers/glass/beaker))
		if(beaker)
			to_chat(user, "<span class='notice'>There is already a beaker in \the [src]'s beaker port.</span>")
			return
		if(!(W.type == /obj/item/weapon/reagent_containers/glass/beaker || W.type == /obj/item/weapon/reagent_containers/glass/beaker/noreact))
			to_chat(user, "<span class='warning'>That beaker is too large to fit into \the [src]'s beaker port.</span>")
			return
		if(!user.drop_item(W, src))
			to_chat(user, "<span class='warning'>You can't let go of \the [W]!</span>")
			return 1
		beaker = W
		to_chat(user, "You insert \the [W] into \the [src]'s beaker port.")
		icon_state = "venom_sword_beaker"
		update_color()
	if(iscrowbar(W))
		to_chat(user, "You pry the aluminum cylinder off of \the [src].")
		var/obj/item/weapon/sword/I = new (get_turf(src))
		if(HY)
			I.hypo = HY
			HY.forceMove(I)
			HY = null
		else
			var/obj/item/weapon/reagent_containers/hypospray/H = new (I)
			H.reagents.clear_reagents()
			I.hypo = H
		I.update_icon()
		if(src.loc == user)
			user.drop_item(src, force_drop = 1)
			user.put_in_hands(I)
		new /obj/item/weapon/aluminum_cylinder(get_turf(src))
		qdel(src)

/obj/item/weapon/sword/venom/attack(mob/M as mob, mob/user as mob)
	if(!..())	//If the attack missed.
		return
	if(!beaker)
		return
	var/obj/item/weapon/reagent_containers/glass/beaker/B = beaker
	if(!B.reagents.total_volume)
		update_color()
		return

	to_chat(M, "<span class='warning'>The blade's coating seeps into your wound!</span>")

	B.reagents.reaction(M, INGEST)

	if(M.reagents)
		var/list/injected = list()
		for(var/datum/reagent/R in B.reagents.reagent_list)
			injected += R.name
		var/contained = english_list(injected)
		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been injected with \the [src] by [user.name] ([user.ckey]). Reagents: [contained]</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used \the [src] to inject [M.name] ([M.key]). Reagents: [contained]</font>")
		msg_admin_attack("[user.name] ([user.ckey]) injected [M.name] ([M.key]) with \a [src]. Reagents: [contained] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
		log_attack("<font color='red'>[user.name] ([user.ckey]) injected [M.name] ([M.ckey]) with \a [src]. Reagents: [contained]</font>" )
		if(!iscarbon(user))
			M.LAssailant = null
		else
			M.LAssailant = user

		B.reagents.trans_to(M, 5)

	if(!B.reagents.total_volume)
		update_color()

/obj/item/weapon/sword/executioner //takes a long time to swing and doesn't do much more damage than the sword, however it has a much higher chance to sever a limb
	name = "executioner's sword"
	desc = "A huge sword. The top third of the blade seems weaker than the rest of it."
	icon_state = "executioners_sword_assembly"
	attack_verb = list("smacks")
	force = 5
	sharpness = 0
	hitsound = "sound/weapons/smash.ogg"
	var/complete = 0

/obj/item/weapon/sword/executioner/afterattack(null, mob/living/user as mob|obj, null, null, null)
	if(complete)
		user.delayNextAttack(30) //thrice the regular attack delay

/obj/item/weapon/sword/executioner/attack_self(mob/user as mob)
	if(complete)
		return
	to_chat(user, "You detach the metal blade from \the [src].")
	new /obj/item/weapon/metal_blade(get_turf(user.loc))
	new /obj/item/weapon/sword(get_turf(user.loc))
	qdel(src)

/obj/item/weapon/sword/executioner/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/weldingtool) && !complete)
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			to_chat(user, "You begin welding the metal blade onto \the [src].")
			playsound(user, 'sound/items/Welder.ogg', 50, 1)
			if(do_after(user, src, 30))
				to_chat(user, "You weld the metal blade onto \the [src].")
				desc = "A huge sword. It looks almost too heavy to lift."
				icon_state = "executioners_sword"
				hitsound = "sound/weapons/bloodyslice.ogg"
				w_class = W_CLASS_LARGE
				force = 25
				sharpness = 2.0
				slot_flags = SLOT_BACK
				attack_verb = list("attacks", "slashes", "stabs", "slices", "tears", "rips", "dices", "cleaves")
				complete = 1
				if (istype(loc,/mob/living/carbon/human))
					var/mob/living/carbon/human/H = loc
					H.update_inv_hands()
					H.update_inv_back()
		else
			to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
			return