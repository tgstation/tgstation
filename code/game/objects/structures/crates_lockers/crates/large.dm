
//Crate that must first be unlocked with a crowbar. From then on out, it just acts like a regular crate, albeit wooden.
/obj/structure/closet/crate/large
	name = "large crate"
	desc = "A hefty wooden crate. You'll need a crowbar to get it open."
	icon_state = "largecrate"
	density = TRUE
	locked = TRUE
	material_drop = /obj/item/stack/sheet/mineral/wood
	material_drop_amount = 4
	delivery_icon = "deliverybox"
	integrity_failure = 0 //Makes the crate break when integrity reaches 0, instead of opening and becoming an invisible sprite.
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25
	close_sound_volume = 50

/obj/structure/closet/crate/large/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(locked)
		to_chat(user, "<span class='warning'>You need a crowbar to pry this open!</span>")
		return

/obj/structure/closet/crate/large/attackby(obj/item/W, mob/user, params)
	if(opened)
		return ..()
	if(W.tool_behaviour == TOOL_CROWBAR)
		if(manifest)
			tear_manifest(user)
			return
		user.visible_message("<span class='notice'>[user] pries \the [src] open.</span>", \
			"<span class='notice'>You pry open \the [src].</span>", \
			"<span class='hear'>You hear splitting wood.</span>")
		playsound(src.loc, 'sound/weapons/slashmiss.ogg', 75, TRUE)
		locked = FALSE
		open()
	else
		if(user.a_intent == INTENT_HARM)
			return ..()
		else
			to_chat(user, "<span class='warning'>You need a crowbar to pry this open!</span>")
			return FALSE
