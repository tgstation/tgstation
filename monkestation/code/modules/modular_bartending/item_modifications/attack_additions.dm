/obj/item/stack/cable_coil/attackby(obj/item/item, mob/user, params)
	. = ..()
	if(item.tool_behaviour != TOOL_WIRECUTTER)
		return
	playsound(src, 'sound/weapons/slice.ogg', 50, TRUE, -1)
	to_chat(user, "<span class='notice'>You start cutting the insulation off of [src]...</span>")
	if(!do_after(user, 1 SECONDS, src))
		return
	var/obj/item/result = new /obj/item/garnish/wire(drop_location())
	var/give_to_user = user.is_holding(src)
	use(1)
	if(QDELETED(src) && give_to_user)
		user.put_in_hands(result)
	to_chat(user, "<span class='notice'>You finish cutting [src]</span>")

/obj/item/stack/sheet/mineral/silver/attackby(obj/item/item, mob/user, params)
	. = ..()
	if(item.tool_behaviour != TOOL_WIRECUTTER)
		return
	playsound(src, 'sound/weapons/slice.ogg', 50, TRUE, -1)
	to_chat(user, "<span class='notice'>You start whittling away some of [src]...</span>")
	if(!do_after(user, 1 SECONDS, src))
		return
	var/obj/item/result = new /obj/item/garnish/silver(drop_location())
	var/give_to_user = user.is_holding(src)
	use(1)
	if(QDELETED(src) && give_to_user)
		user.put_in_hands(result)
	to_chat(user, "<span class='notice'>You finish cutting [src]</span>")

/obj/item/stack/sheet/mineral/gold/attackby(obj/item/item, mob/user, params)
	. = ..()
	if(item.tool_behaviour != TOOL_WIRECUTTER)
		return
	playsound(src, 'sound/weapons/slice.ogg', 50, TRUE, -1)
	to_chat(user, "<span class='notice'>You start whittling away some of [src]...</span>")
	if(!do_after(user, 1 SECONDS, src))
		return
	var/obj/item/result = new /obj/item/garnish/gold(drop_location())
	var/give_to_user = user.is_holding(src)
	use(1)
	if(QDELETED(src) && give_to_user)
		user.put_in_hands(result)
	to_chat(user, "<span class='notice'>You finish cutting [src]</span>")
