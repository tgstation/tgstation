/obj/item/papercutter
	name = "paper cutter"
	desc = "Standard office equipment. Precisely cuts paper using a large blade."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "papercutter"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	var/obj/item/paper/storedpaper = null
	var/obj/item/hatchet/cutterblade/storedcutter = null
	var/cuttersecured = TRUE
	pass_flags = PASSTABLE


/obj/item/papercutter/Initialize(mapload)
	. = ..()
	storedcutter = new /obj/item/hatchet/cutterblade(src)
	update_appearance()


/obj/item/papercutter/suicide_act(mob/living/user)
	if(storedcutter)
		user.visible_message(span_suicide("[user] is beheading [user.p_them()]self with [src.name]! It looks like [user.p_theyre()] trying to commit suicide!"))
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			var/obj/item/bodypart/BP = C.get_bodypart(BODY_ZONE_HEAD)
			if(BP)
				BP.drop_limb()
				playsound(loc, SFX_DESECRATION ,50, TRUE, -1)
		return BRUTELOSS
	else
		user.visible_message(span_suicide("[user] repeatedly bashes [src.name] against [user.p_their()] head! It looks like [user.p_theyre()] trying to commit suicide!"))
		playsound(loc, 'sound/items/gavel.ogg', 50, TRUE, -1)
		return BRUTELOSS


/obj/item/papercutter/update_icon_state()
	icon_state = (storedcutter ? "[initial(icon_state)]-cutter" : "[initial(icon_state)]")
	return ..()

/obj/item/papercutter/update_overlays()
	. =..()
	if(storedpaper)
		. += "paper"

/obj/item/papercutter/screwdriver_act(mob/living/user, obj/item/tool)
	if(!storedcutter)
		return
	tool.play_tool_sound(src)
	to_chat(user, span_notice("[storedcutter] has been [cuttersecured ? "unsecured" : "secured"]."))
	cuttersecured = !cuttersecured
	return TOOL_ACT_TOOLTYPE_SUCCESS


/obj/item/papercutter/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/paper) && !storedpaper && !istype(P, /obj/item/paper/paperslip))
		if(!user.transferItemToLoc(P, src))
			return
		playsound(loc, SFX_PAGE_TURN, 60, TRUE)
		to_chat(user, span_notice("You place [P] in [src]."))
		storedpaper = P
		update_appearance()
		return
	if(istype(P, /obj/item/hatchet/cutterblade) && !storedcutter)
		if(!user.transferItemToLoc(P, src))
			return
		to_chat(user, span_notice("You replace [src]'s [P]."))
		P.forceMove(src)
		storedcutter = P
		update_appearance()
		return
	..()

/obj/item/papercutter/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	add_fingerprint(user)
	if(!storedcutter)
		to_chat(user, span_warning("The cutting blade is gone! You can't use [src] now."))
		return

	if(!cuttersecured)
		to_chat(user, span_notice("You remove [src]'s [storedcutter]."))
		user.put_in_hands(storedcutter)
		storedcutter = null
		update_appearance()

	if(storedpaper)
		playsound(src.loc, 'sound/weapons/slash.ogg', 50, TRUE)
		to_chat(user, span_notice("You neatly cut [storedpaper]."))
		storedpaper = null
		qdel(storedpaper)
		new /obj/item/paper/paperslip(get_turf(src))
		new /obj/item/paper/paperslip(get_turf(src))
		update_appearance()

/obj/item/papercutter/MouseDrop(atom/over_object)
	. = ..()
	var/mob/M = usr
	if(M.incapacitated() || !Adjacent(M))
		return

	if(over_object == M)
		M.put_in_hands(src)

	else if(istype(over_object, /atom/movable/screen/inventory/hand))
		var/atom/movable/screen/inventory/hand/H = over_object
		M.putItemFromInventoryInHandIfPossible(src, H.held_index)
	add_fingerprint(M)

/obj/item/paper/paperslip
	name = "paper slip"
	desc = "A little slip of paper left over after a larger piece was cut. Whoa."
	icon_state = "paperslip"
	inhand_icon_state = "silver_id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	grind_results = list(/datum/reagent/cellulose = 1.5) //It's a normal paper sheet divided in 2. 3 divided by 2 equals 1.5, this way you can't magically dupe cellulose

/obj/item/paper/paperslip/corporate //More fancy and sturdy paper slip which is a "plastic card", used for things like spare ID safe code
	name = "corporate plastic card"
	desc = "A plastic card for confidental corporate matters. Can be written on with pen somehow."
	icon_state = "corppaperslip"
	grind_results = list(/datum/reagent/plastic_polymers = 1.5) //It's a plastic card after all
	max_integrity = 130 //Slightly more sturdy because of being made out of a plastic
	drop_sound = 'sound/items/handling/disk_drop.ogg'
	pickup_sound = 'sound/items/handling/disk_pickup.ogg'
	throw_range = 6
	throw_speed = 2

/obj/item/hatchet/cutterblade
	name = "paper cutter"
	desc = "The blade of a paper cutter. Most likely removed for polishing or sharpening."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "cutterblade"
	inhand_icon_state = "knife"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
