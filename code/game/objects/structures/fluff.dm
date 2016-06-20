//Fluff structures serve no purpose and exist only for enriching the environment. They can be destroyed with a wrench.

/obj/structure/fluff
	name = "fluff structure"
	desc = "Fluffier than a sheep. This shouldn't exist."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "minibar"
	anchored = TRUE
	density = FALSE
	opacity = 0

/obj/structure/fluff/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/weapon/wrench))
		user.visible_message("<span class='notice'>[user] starts disassembling [src]...</span>", "<span class='notice'>You start disassembling [src]...</span>")
		playsound(user, 'sound/items/Ratchet.ogg', 50, 1)
		if(!do_after(user, 50, target = src))
			return 0
		user.visible_message("<span class='notice'>[user] disassembles [src]!</span>", "<span class='notice'>You break down [src] into scrap metal.</span>")
		playsound(user, 'sound/items/Deconstruct.ogg', 50, 1)
		new/obj/item/stack/sheet/metal(get_turf(src))
		qdel(src)
		return
	..()

/obj/structure/fluff/empty_terrarium //Empty terrariums are created when a preserved terrarium in a lavaland seed vault is activated.
	name = "empty terrarium"
	desc = "An ancient machine that seems to be used for storing plant matter. Its hatch is ajar."
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "terrarium_open"
	density = TRUE

/obj/structure/fluff/empty_sleeper //Empty sleepers are created by a good few ghost roles in lavaland.
	name = "empty sleeper"
	desc = "An open sleeper. It looks as though it would be awaiting another patient, were it not broken."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper-open"

/obj/structure/fluff/empty_sleeper/syndicate
	icon_state = "sleeper_s-open"

/obj/structure/fluff/empty_cryostasis_sleeper //Empty cryostasis sleepers are created when a malfunctioning cryostasis sleeper in a lavaland shelter is activated
	name = "empty cryostasis sleeper"
	desc = "Although comfortable, this sleeper won't function as anything but a bed ever again."
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "cryostasis_sleeper_open"
