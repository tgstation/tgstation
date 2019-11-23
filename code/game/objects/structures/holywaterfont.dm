/obj/structure/holywaterfont
	name = "holy water font"
	desc = "A vessel for holy water, usually placed by a church entrance. Used to bless oneself after entering."
	icon = 'icons/obj/structures.dmi'
	icon_state = "holywaterfont"
	density = TRUE
	anchored = TRUE
	var/mob/living/baptism = null	//the mob being given a baptism
	var/buildstacktype = /obj/item/stack/sheet/metal
	var/buildstackamount = 1
	var/amount_per_transfer_from_this = 5	//shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/max_volume = 30
	var/bless_amt = 5
	var/baptise_amt = 15
	var/baptise_time = 100

/obj/structure/holywaterfont/Initialize()
	. = ..()
	create_reagents(max_volume, OPENCONTAINER)

/obj/structure/holywaterfont/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(baptism)
		user.changeNext_move(CLICK_CD_MELEE)
		playsound(src.loc, "swing_hit", 25, TRUE)
		baptism.visible_message("<span class='danger'>[user] slams [baptism]'s head into [src]!</span>", "<span class='userdanger'>[user] slams your head into [src]!</span>", "<span class='hear'>You hear reverberating metal.</span>")
		baptism.adjustBruteLoss(5)

	else if(user.pulling && user.a_intent == INTENT_GRAB && isliving(user.pulling))
		user.changeNext_move(CLICK_CD_MELEE)
		var/mob/living/carbon/human/GM = user.pulling
		if(user.grab_state >= GRAB_AGGRESSIVE)
			if(!Adjacent(GM))
				to_chat(user, "<span class='warning'>[GM] needs to be beside [src]!</span>")
				return
			if(HAS_TRAIT(user, TRAIT_PACIFISM))
				to_chat(user, "<span class='warning'>You don't want to risk hurting [GM]!</span>")
				return
			if(!baptism && reagents.total_volume >= baptise_amt)
				GM.visible_message("<span class='danger'>[user] starts to baptise [GM]!</span>", "<span class='userdanger'>[user] starts to baptise you...</span>")
				baptism = GM
				if(do_after(user, baptise_time, 0, target = src))
					GM.visible_message("<span class='danger'>[user] baptises [GM]!</span>", "<span class='userdanger'>[user] baptises you!</span>")
					playsound(loc, 'sound/effects/slosh.ogg', 25, TRUE)
					reagents.reaction(GM, method = TOUCH, volume_modifier = baptise_amt/reagents.total_volume, show_message = 1)
					reagents.remove_all(amount = baptise_amt)
					update_icon_state()
					if(!GM.internal)
						GM.adjustOxyLoss(5)
					if((user.mind && user.mind.isholy) && !(HAS_TRAIT(GM, TRAIT_BAPTISED)))
						ADD_TRAIT(GM, TRAIT_BAPTISED, "baptised")
						playsound(src, 'sound/effects/pray_chaplain.ogg', 50)
						SEND_SIGNAL(GM, COMSIG_ADD_MOOD_EVENT, "baptised", /datum/mood_event/baptised)
				baptism = null
			else
				playsound(src.loc, 'sound/effects/bang.ogg', 25, TRUE)
				GM.visible_message("<span class='danger'>[user] slams [GM.name] into [src]!</span>", "<span class='userdanger'>[user] slams you into [src]!</span>")
				GM.adjustBruteLoss(5)
		else
			to_chat(user, "<span class='warning'>You need a tighter grip!</span>")

	else if(user.CanReach(src))
		if(reagents.total_volume < 1)
			to_chat(user, "<span class='warning'>[src] is empty.</span>")
		else
			if(ishuman(user) && reagents.total_volume >= bless_amt)
				to_chat(user, "<span class='notice'>You bless yourself.</span>")
				reagents.reaction(user, method = TOUCH, volume_modifier = bless_amt/reagents.total_volume, show_message = 1)
				reagents.remove_all(amount = bless_amt)
				update_icon_state()

/obj/structure/holywaterfont/update_icon_state()
	if(reagents.total_volume > 0)
		icon_state = "holywaterfont_filled"
	else
		icon_state = "holywaterfont"

/obj/structure/holywaterfont/deconstruct()
	if(!(flags_1 & NODECONSTRUCT_1))
		if(buildstacktype)
			new buildstacktype(loc,buildstackamount)
		else
			for(var/i in custom_materials)
				var/datum/material/M = i
				new M.sheet_type(loc, FLOOR(custom_materials[M] / MINERAL_MATERIAL_AMOUNT, 1))
	..()

/obj/structure/holywaterfont/attackby(obj/item/I, mob/living/user, params)
	add_fingerprint(user)
	if(I.tool_behaviour == TOOL_WRENCH && !(flags_1&NODECONSTRUCT_1))
		I.play_tool_sound(src)
		deconstruct()
	if(istype(I, /obj/item/mop))
		if(reagents.total_volume < 1)
			to_chat(user, "<span class='warning'>[src] is empty!</span>")
		else
			reagents.trans_to(I, 5, transfered_by = user)
			to_chat(user, "<span class='notice'>You wet [I] in [src].[user.mind && user.mind.isholy ? "" : " Sacrilegious!"]</span>")
			playsound(loc, 'sound/effects/slosh.ogg', 25, TRUE)
			update_icon_state()
	if(istype(I, /obj/item/card/id))
		var/obj/item/card/id/ID = I
		if(ACCESS_CHAPEL_OFFICE in ID.access && reagents.total_volume > 0)
			if(alert(user, "Would you like to empty the vessel?","Empty the vessel?","Yes","No") == "Yes")
				reagents.remove_all(amount = reagents.total_volume)
				user.visible_message("<span class='notice'>[user] drains [src].</span>")
	else if(istype(I, /obj/item/reagent_containers))
		if(istype(I, /obj/item/reagent_containers/food/snacks/monkeycube))
			if(reagents && reagents.has_reagent(/datum/reagent/water))
				var/obj/item/reagent_containers/food/snacks/monkeycube/cube = I
				cube.Expand()
			else
				to_chat(user, "<span class='notice'>Nothing happens.</span>")
//		var/obj/item/reagent_containers/RG = I
//		if(RG.reagents.total_volume < 1 && reagents.total_volume > 0 )
//			reagents.trans_to(RG, min(RG.volume - RG.reagents.total_volume, RG.amount_per_transfer_from_this), transfered_by = user)
//			to_chat(user, "<span class='notice'>You fill [RG] from [src].[user.mind && user.mind.isholy ? "" : " Sacrilegious!"]</span>") //no work
		update_icon_state()
	else
		return ..()