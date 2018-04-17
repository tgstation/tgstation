/obj/item/grenade/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/wirekit))
		var/obj/structure/boobytrap/T = new(get_turf(src))
		user.dropItemToGround(src)
		src.forceMove(T)
		T.grenade = src
		T.owner = user
		message_admins("[ADMIN_LOOKUPFLW(user)] поставил растяжку [ADMIN_COORDJMP(user)].")
		log_game("[key_name(user)] поставил растяжку [COORD(user)].")
	..()

/obj/structure/boobytrap
	name = "РастЯжка ебать"
	desc = "Пиздец, не подходи - убьет!"
	icon_state = "boobytrap"
	icon = 'code/white/hule/weapons/weapons.dmi'
	anchored = TRUE
	can_buckle = TRUE
	buckle_lying = TRUE
	resistance_flags = FLAMMABLE
	max_integrity = 25
	integrity_failure = 1
	var/obj/item/grenade/grenade
	var/mob/owner

/obj/structure/boobytrap/proc/activate()
	if(grenade)
		grenade.prime()
		qdel(src)

/obj/structure/boobytrap/Crossed(atom/movable/AM as mob|obj)
	if(ismob(AM))
		var/mob/MM = AM
		if(MM.movement_type & FLYING)
			return
		if(ismouse(MM))
			return
		if(ishuman(AM))
			var/mob/living/carbon/human/H = AM
			if(H.m_intent == MOVE_INTENT_WALK && H.has_trait(TRAIT_LIGHT_STEP))
				return
	activate()

/obj/structure/boobytrap/attack_hand(mob/user)
	activate()

/obj/structure/boobytrap/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/boobytrap/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/wirecutters) && !(flags_1&NODECONSTRUCT_1))
		if(do_after(user, 30, target = src))
			W.play_tool_sound(src)
			if(prob(80) && user.mind.antag_datums == null && user != owner)
				to_chat(user, "<span class='userdanger'>Дебил блядь! Кто тебя учил растяжки обезвреживать?</span>")
				activate()
				return
			if(grenade)
				grenade.forceMove(get_turf(user))
			qdel(src)
	..()

/obj/item/wirekit
	name = "Wiring kit"
	desc = "Содержит все необходимое для создания растяжек."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "matchbox"
	item_state = "zippo"
	w_class = WEIGHT_CLASS_TINY

/datum/crafting_recipe/wiringkit
	name = "Wiring kit"
	result = /obj/item/wirekit
	reqs = list(/obj/item/stack/cable_coil = 30,
				/obj/item/stack/rods = 5)
	tools = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	time = 200
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON