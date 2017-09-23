#define STUNGLOVES_CHARGE_COST 2500

/obj/item/clothing/gloves
	var/wired = FALSE
	var/obj/item/stock_parts/cell/cell

/obj/item/clothing/gloves/Touch(atom/A, prox)
	if(!isliving(A))
		return FALSE
	if(!cell || !wired)
		return FALSE
	var/mob/living/L = A
	if(prox && cell.use(STUNGLOVES_CHARGE_COST))
		usr.visible_message("<span class='danger'>\The [A] has been touched with \the [src] by [usr]!</span>", "<span class='notice'>You stun \the [A] with \the [src]!</span>", "<span class='italics'>You hear an electric shock.</span>")
		log_attack("[A] has been stunned with \the [src] by [usr]!")
		L.Knockdown(25) //less than is needed to cuff
		return TRUE
	else
		to_chat(usr, "<span class='notice'>\The [src] doesn't have enough charge to stun [A]!</span>")

/obj/item/clothing/gloves/update_icon()
	cut_overlays()
	. = ..()
	alternate_worn_icon = initial(alternate_worn_icon)
	item_state = initial(item_state)
	if(cell || wired)
		alternate_worn_icon = 'hippiestation/icons/mob/hands.dmi'
		item_state = "stungloves"
	if(wired)
		add_overlay(mutable_appearance('hippiestation/icons/obj/weapons.dmi', "gloves_wire"))
	if(cell)
		add_overlay(mutable_appearance('hippiestation/icons/obj/weapons.dmi', "gloves_cell"))

/obj/item/clothing/gloves/proc/update_name()
	var/o_name = initial(name)
	name = o_name
	if(wired && cell)
		name = "stunning [name]"
	if(wired && !cell)
		name = "wired [name]"

/obj/item/clothing/gloves/attackby(obj/item/W, mob/user)
	update_name()
	if(istype(src, /obj/item/clothing/gloves/boxing))	//quick fix for stunglove overlay not working nicely with boxing gloves.
		to_chat(user, "<span class='notice'>That won't work.</span>")//i'm not putting my lips on that!
		return ..()
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		if(!wired)
			if(C.use(2))
				wired = TRUE
				to_chat(user, "<span class='notice'>You wrap some wires around \the [src].</span>")
				update_icon()
			else
				to_chat(user, "<span class='notice'>There is not enough wire to cover [src].</span>")
		else
			to_chat(user, "<span class='notice'>\The [src] are already wired.</span>")
		user.update_inv_gloves()
		return
	else if(istype(W, /obj/item/stock_parts/cell))
		if(!wired)
			to_chat(user, "<span class='notice'>\The [src] need to be wired first.</span>")
		else if(!cell)
			if(user.drop_item(W, src))
				cell = W
				to_chat(user, "<span class='notice'>You attach a cell to \the [src].</span>")
				update_icon()
				update_name()
		else
			to_chat(user, "<span class='notice'>\The [src] already have a cell.</span>")
		user.update_inv_gloves()
		return
	else if(istype(W, /obj/item/wirecutters))
		if(cell)
			cell.update_icon()
			cell.forceMove(get_turf(loc))
			cell = null
			to_chat(user, "<span class='notice'>You cut the cell away from \the [src].</span>")
			update_icon()
			update_name()
			user.update_inv_gloves()
			return
		if(wired)
			wired = FALSE
			new /obj/item/stack/cable_coil(get_turf(loc), 2)
			to_chat(user, "<span class='notice'>You cut the wires away from \the [src].</span>")
			update_icon()
			update_name()
			user.update_inv_gloves()
			return
	return ..()

#undef STUNGLOVES_CHARGE_COST