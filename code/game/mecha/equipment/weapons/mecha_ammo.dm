/obj/item/mecha_ammo
	name = "Generic Ammo Box"
	desc = "A box of ammo for an unknown weapon."
	icon = 'icons/mecha/mecha_ammo.dmi'
	icon_state = "empty"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	var/rounds = 0
	var/round_term = "round"
	var/direct_load
	var/ammo_type

/obj/item/mecha_ammo/proc/update_name()
	if(!rounds)
		name = "empty ammo box"
		desc = "An empty ammo box. Please recycle."
		icon_state = "empty"

/obj/item/mecha_ammo/attack_self(mob/user)
	..()
	if(rounds)
		to_chat(user, "<span class='warning'>You cannot flatten the ammo box until it's empty!</span>")
		return

	to_chat(user, "<span class='notice'>You fold [src] flat.</span>")
	var/I = new /obj/item/stack/sheet/metal(user.loc)
	qdel(src)
	user.put_in_hands(I)

/obj/item/mecha_ammo/examine(mob/user)
	..()
	if(rounds)
		to_chat(user, "There [rounds > 1?"are":"is"] [rounds] [round_term][rounds > 1?"s":""] left.")

/obj/item/mecha_ammo/incendiary
	name = "Incendiary Ammo"
	desc = "A box of incendiary ammunition for use with exosuit weapons."
	icon_state = "incendiary"
	rounds = 24
	ammo_type = "incendiary"

/obj/item/mecha_ammo/scattershot
	name = "Scattershot Ammo"
	desc = "A box of scaled-up buckshot, for use in exosuit shotguns."
	icon_state = "scattershot"
	rounds = 40
	ammo_type = "scattershot"

/obj/item/mecha_ammo/lmg
	name = "Machine Gun Ammo"
	desc = "A box of linked ammunition, designed for the Ultra AC 2 exosuit weapon."
	icon_state = "lmg"
	rounds = 300
	ammo_type = "lmg"

/obj/item/mecha_ammo/missiles
	name = "Anti-Armor missiles"
	desc = "A box of large missiles, ready for loading into an SRM-8 exosuit missile rack."
	icon_state = "missile"
	rounds = 8
	round_term = "missile"
	direct_load = TRUE
	ammo_type = "missiles"

/obj/item/mecha_ammo/flashbang
	name = "Launchable Flashbangs"
	desc = "A box of smooth flashbangs, for use with a large exosuit launcher. Cannot be primed by hand."
	icon_state = "flashbang"
	rounds = 6
	round_term = "grenade"
	ammo_type = "flashbang"

/obj/item/mecha_ammo/clusterbang
	name = "Launchable Flashbang Clusters"
	desc = "A box of clustered flashbangs, for use with a specialized exosuit cluster launcher. Cannot be primed by hand."
	icon_state = "clusterbang"
	rounds = 3
	round_term = "cluster"
	ammo_type = "clusterbang"