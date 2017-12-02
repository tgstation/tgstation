#define SHARP_DESC_ADD "This one appears to have a bunch of sharp edges peeking out from under its leaves."
#define EMAG_DESC_ADD "This plant appears to have been illegally modified."

/obj/item/twohanded/required/kirbyplants
	var/disable = 0 //for screwdriver
	var/sharp_prefix = "thorny"

/obj/item/twohanded/required/kirbyplants/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/screwdriver)) //If you screwdrive it, it is attachable
		add_fingerprint(user)
		disable = !disable
		if(disable)
			user.visible_message("[user] prepares the foliage for connection.", "<span class='notice'>You can now attach the potted plant!</span>")
		if(!disable)
			user.visible_message("[user] impedes the foliage from connection.", "<span class='notice'>You can no longer attach the potted plant.</span>")
	if(W.is_sharp() && disable)  //If screwdriven and the item is sharp, it creates sharp plant
		user.visible_message("[user] places something sharp inside the plant's branches..", "<span class='notice'>You've sharpened the potted plant!</span>")
		name = "[sharp_prefix] [name]"
		desc = "[desc] " + SHARP_DESC_ADD
		sharpness = W.sharpness
		hitsound='hippiestation/sound/weapons/sharpBushHit.ogg' //cool sound
		qdel(W)
	if(istype(W, /obj/item/reagent_containers) && emagged)
		if(W.reagents.has_reagent("lean"))
			W.reagents.clear_reagents()
			playsound(src.loc, 'hippiestation/sound/effects/pottedLeanSpawnSound', 25)
			new /mob/living/simple_animal/hostile/retaliate/pottedlean(get_turf(src))
			qdel(src)


	else
		return ..()

/obj/item/twohanded/required/kirbyplants/emag_act(mob/user)
	if(emagged)
		return
	do_sparks(8, FALSE, get_turf(src))
	user.visible_message("<span class='warning'>Sparks burst from the plant as a jolt of electricity courses through your arm.</span>")
	emagged = TRUE
	force_wielded = 0
	wielded = 0
	desc = "[desc] " + EMAG_DESC_ADD
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/twohanded/required/kirbyplants/photosynthetic/emag_act(mob/user) //do not emag this one!
	explosion(get_turf(src), 0, 1, 5, flame_range = 5)
	qdel(src)

/obj/item/twohanded/required/kirbyplants/equipped(mob/user, slot)
	if(emagged && wielded)
		unwield(user) //This is a ghetto way to make it one-handed and it works
	var/image/I = image(icon = 'icons/obj/flora/plants.dmi' , icon_state = src.icon_state, loc = user)
	I.copy_overlays(src)
	I.override = 1
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/everyone, "sneaking_mission", I)
	I.layer = ABOVE_MOB_LAYER

