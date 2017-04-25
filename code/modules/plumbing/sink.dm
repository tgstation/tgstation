/obj/structure/sink
	name = "sink"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "sink"
	desc = "A sink used for washing one's hands and face."
	anchored = TRUE
	var/busy = FALSE 	//Something's being washed at the moment
	var/use_reagents = TRUE//If we're reliant on the plumbing system

/obj/structure/sink/Initialize()
	create_reagents(15)
	..()

/obj/structure/sink/attack_hand(mob/living/user)
	if(!user || !istype(user))
		return
	if(!iscarbon(user))
		return
	if(!Adjacent(user))
		return
	if(use_reagents && !reagents.total_volume && !plumbing_has_reagents(15)) //15 units per use
		to_chat(user, "<span class='warning'>Nothing comes out of the spigot!</span>")
		return
	if(busy)
		to_chat(user, "<span class='notice'>Someone's already washing here.</span>")
		return
	if(use_reagents)
		master_plumber.request_liquid(src, 15)
	var/selected_area = parse_zone(user.zone_selected)
	var/washing_face = FALSE
	if(selected_area in list("head", "mouth", "eyes"))
		washing_face = TRUE
	user.visible_message("<span class='notice'>[user] starts washing their [washing_face ? "face" : "hands"]...</span>", \
						"<span class='notice'>You start washing your [washing_face ? "face" : "hands"]...</span>")
	busy = TRUE

	if(!do_after(user, 40, target = src))
		busy = FALSE
		return

	busy = FALSE

	if(use_reagents && !reagents.total_volume && !plumbing_has_reagents(15))
		to_chat(user, "<span class='warning'>The spigot suddenly runs dry!</span>")
		return
	if(use_reagents)
		master_plumber.request_liquid(src, 15)
	user.visible_message("<span class='notice'>[user] washes their [washing_face ? "face" : "hands"] using [src].</span>", \
						"<span class='notice'>You wash your [washing_face ? "face" : "hands"] using [src].</span>")
	if(washing_face)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.lip_style = null //Washes off lipstick
			H.lip_color = initial(H.lip_color)
			H.wash_cream()
			H.regenerate_icons()
		user.drowsyness = max(user.drowsyness - rand(2,3), 0) //Washing your face wakes you up if you're falling asleep
	else
		user.clean_blood()
	reagents.reaction(user, TOUCH)
	reagents.clear_reagents()


/obj/structure/sink/attackby(obj/item/O, mob/user, params)
	if(busy)
		to_chat(user, "<span class='warning'>Someone's already washing here!</span>")
		return

	if(istype(O, /obj/item/weapon/reagent_containers))
		var/obj/item/weapon/reagent_containers/RG = O
		if(RG.container_type & OPENCONTAINER)
			if(!RG.reagents.holder_full())
				var/vol_to_grab = min(RG.volume - RG.reagents.total_volume, min(RG.amount_per_transfer_from_this, 15))
				if(reagents.total_volume || !use_reagents)
					if(use_reagents)
						reagents.trans_to(RG, vol_to_grab)
					else
						RG.reagents.add_reagent("water", vol_to_grab)
					if(RG.reagents.holder_full())
						to_chat(user, "<span class='notice'>You fill [RG] to the brim from [src].</span>")
					else
						to_chat(user, "<span class='notice'>You fill [RG] from [src].</span>")
				else
					if(!plumbing_has_reagents(vol_to_grab))
						to_chat(user, "<span class='warning'>Nothing comes out of the spigot!</span>")
						return
					to_chat(user, "<span class='notice'>You fill [RG] from [src].</span>")
					master_plumber.request_liquid(RG, vol_to_grab)
				return TRUE
			to_chat(user, "<span class='notice'>\The [RG] is full.</span>")
			return FALSE

	if(istype(O, /obj/item/weapon/melee/baton) && (!use_reagents || plumbing_has_reagents(1))) //As long as there's anything at all!
		var/obj/item/weapon/melee/baton/B = O
		if(B.bcell)
			if(B.bcell.charge > 0 && B.status == TRUE)
				flick("baton_active", src)
				var/stunforce = B.stunforce
				user.Stun(stunforce)
				user.Weaken(stunforce)
				user.stuttering = stunforce
				B.deductcharge(B.hitcost)
				user.visible_message("<span class='warning'>[user] shocks themself while attempting to wash the active [B.name]!</span>", \
									"<span class='userdanger'>You unwisely attempt to wash [B] while it's still on.</span>")
				playsound(src, "sparks", 50, 1)
				return

	if(istype(O, /obj/item/weapon/mop))
		if(use_reagents && !plumbing_has_reagents(5))
			to_chat(user, "<span class='warning'>Nothing comes out of the spigot!</span>")
			return
		if(use_reagents)
			master_plumber.request_liquid(O, 5)
		else
			O.reagents.add_reagent("water", 5)
		to_chat(user, "<span class='notice'>You wet [O] in [src].</span>")
		playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
		return

	if(istype(O, /obj/item/stack/medical/gauze))
		var/obj/item/stack/medical/gauze/G = O
		new /obj/item/weapon/reagent_containers/glass/rag(src.loc)
		to_chat(user, "<span class='notice'>You tear off a strip of gauze and make a rag.</span>")
		G.use(1)
		return

	if(!istype(O) || O.flags & ABSTRACT) //Abstract items like grabs won't wash. No-drop items will though because it's still technically an item in your hand.
		return

	if(user.a_intent != INTENT_HARM)
		if(use_reagents && !plumbing_has_reagents(15))
			to_chat(user, "<span class='warning'>Nothing comes out of the spigot!</span>")
			return
		to_chat(user, "<span class='notice'>You start washing [O]...</span>")
		busy = TRUE
		if(!do_after(user, 40, target = src))
			busy = FALSE
			return 1
		if(use_reagents && !plumbing_has_reagents(15))
			to_chat(user, "<span class='warning'>The spigot suddenly runs dry!</span>")
			return
		busy = FALSE
		if(use_reagents)
			master_plumber.request_liquid(src, 15)
		O.clean_blood()
		O.acid_level = 0
		reagents.reaction(O, TOUCH)
		reagents.clear_reagents()
		user.visible_message("<span class='notice'>[user] washes [O] using [src].</span>", \
							"<span class='notice'>You wash [O] using [src].</span>")
		return 1
	else
		return ..()

/obj/structure/sink/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal (loc, 3)
	qdel(src)



/obj/structure/sink/kitchen
	name = "kitchen sink"
	icon_state = "sink_alt"


/obj/structure/sink/puddle	//splishy splashy ^_^
	name = "puddle"
	desc = "A puddle used for washing one's hands and face."
	icon_state = "puddle"
	use_reagents = FALSE

/obj/structure/sink/puddle/attack_hand(mob/M)
	icon_state = "puddle-splash"
	..()
	icon_state = "puddle"

/obj/structure/sink/puddle/attackby(obj/item/O, mob/user, params)
	icon_state = "puddle-splash"
	. = ..()
	icon_state = "puddle"
