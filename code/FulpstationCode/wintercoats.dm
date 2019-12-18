// HEAD OF STAFF WINTER COATS
// Sprites designed by Papaporo Paprito, code done by Cosmic Phoenix.

/obj/item/clothing/suit/hooded/wintercoat/security/head
	name = "\improper Head of Security's winter coat"
	desc = "This is the Head of Security's personal winter coat. Although it looks like a normal coat, it actually has armor woven inside."
	icon = 'icons/fulpicons/phoenix_nest/wintercoats_icons.dmi'
	mob_overlay_icon = 'icons/fulpicons/phoenix_nest/wintercoats.dmi'
	icon_state = "wintercoat_hos"
	item_state = "wintercoat_hos"
	lefthand_file = 'icons/fulpicons/phoenix_nest/wintercoat_lefthand.dmi'
	righthand_file = 'icons/fulpicons/phoenix_nest/wintercoat_righthand.dmi'
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 90) // Same as the HoS trench coat
	cold_protection = CHEST|GROIN|LEGS|ARMS // Alright, so *technically* the coat doesn't actually cover the legs, but this has to be as good as the HoS trench coat otherwise it will never be used.
	heat_protection = CHEST|GROIN|LEGS|ARMS // This may or may not kill the game.
	strip_delay = 80 // Anti-ERP Technology
	hoodtype = /obj/item/clothing/head/hooded/winterhood/security/head

/obj/item/clothing/head/hooded/winterhood/security/head
	mob_overlay_icon = 'icons/fulpicons/phoenix_nest/wintercoats.dmi'
	icon = 'icons/fulpicons/phoenix_nest/wintercoathoods.dmi'
	icon_state = "winterhood_hos"


/obj/item/clothing/suit/hooded/wintercoat/medical/head
	name = "\improper Chief Medical Officer's winter coat"
	desc = "This is the Chief Medical Officer's personal winter coat."
	icon = 'icons/fulpicons/phoenix_nest/wintercoats_icons.dmi'
	mob_overlay_icon = 'icons/fulpicons/phoenix_nest/wintercoats.dmi'
	icon_state = "wintercoat_cmo"
	item_state = "wintercoat_cmo"
	lefthand_file = 'icons/fulpicons/phoenix_nest/wintercoat_lefthand.dmi'
	righthand_file = 'icons/fulpicons/phoenix_nest/wintercoat_righthand.dmi'
	allowed = list(/obj/item/analyzer, /obj/item/sensor_device, /obj/item/stack/medical, /obj/item/dnainjector, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray, /obj/item/healthanalyzer, /obj/item/flashlight/pen, /obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/reagent_containers/pill, /obj/item/storage/pill_bottle, /obj/item/paper, /obj/item/melee/classic_baton/telescopic, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/assembly/flash/handheld)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 50, "rad" = 0, "fire" = 50, "acid" = 50) // Same as CMO's labcoat.
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical/head

/obj/item/clothing/head/hooded/winterhood/medical/head
	mob_overlay_icon = 'icons/fulpicons/phoenix_nest/wintercoats.dmi'
	icon = 'icons/fulpicons/phoenix_nest/wintercoathoods.dmi'
	icon_state = "winterhood_cmo"


/obj/item/clothing/suit/hooded/wintercoat/science/head
	name = "\improper Research Director's winter coat"
	desc = "This is the Research Director's personal winter coat."
	icon = 'icons/fulpicons/phoenix_nest/wintercoats_icons.dmi'
	mob_overlay_icon = 'icons/fulpicons/phoenix_nest/wintercoats.dmi'
	icon_state = "wintercoat_rd"
	item_state = "wintercoat_rd"
	lefthand_file = 'icons/fulpicons/phoenix_nest/wintercoat_lefthand.dmi'
	righthand_file = 'icons/fulpicons/phoenix_nest/wintercoat_righthand.dmi'
	allowed = list(/obj/item/analyzer, /obj/item/stack/medical, /obj/item/dnainjector, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray, /obj/item/healthanalyzer, /obj/item/flashlight/pen, /obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/reagent_containers/pill, /obj/item/storage/pill_bottle, /obj/item/paper, /obj/item/melee/classic_baton/telescopic, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/assembly/flash/handheld)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 10, "bio" = 40, "rad" = 0, "fire" = 40, "acid" = 40) // -10 from normal labcoat, +10 to bomb from Sci winter coat.
	hoodtype = /obj/item/clothing/head/hooded/winterhood/science/head

/obj/item/clothing/head/hooded/winterhood/science/head
	mob_overlay_icon = 'icons/fulpicons/phoenix_nest/wintercoats.dmi'
	icon = 'icons/fulpicons/phoenix_nest/wintercoathoods.dmi'
	icon_state = "winterhood_rd"

/obj/item/clothing/suit/hooded/wintercoat/engineering/head
	name = "\improper Chief Engineer's winter coat"
	desc = "This is the Chief Engineer's personal winter coat."
	icon = 'icons/fulpicons/phoenix_nest/wintercoats_icons.dmi'
	mob_overlay_icon = 'icons/fulpicons/phoenix_nest/wintercoats.dmi'
	icon_state = "wintercoat_ce"
	item_state = "wintercoat_ce"
	lefthand_file = 'icons/fulpicons/phoenix_nest/wintercoat_lefthand.dmi'
	righthand_file = 'icons/fulpicons/phoenix_nest/wintercoat_righthand.dmi'
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 40, "fire" = 30, "acid" = 45) // 20 extra rad protection. Why not?
	allowed = list(/obj/item/flashlight, /obj/item/assembly/flash/handheld, /obj/item/melee/classic_baton/telescopic, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/t_scanner, /obj/item/construction/rcd, /obj/item/pipe_dispenser, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering/head

/obj/item/clothing/head/hooded/winterhood/engineering/head
	mob_overlay_icon = 'icons/fulpicons/phoenix_nest/wintercoats.dmi'
	icon = 'icons/fulpicons/phoenix_nest/wintercoathoods.dmi'
	icon_state = "winterhood_ce"


/obj/item/clothing/suit/hooded/wintercoat/captain/hop
	name = "\improper Head of Personel's winter coat"
	desc = "This is the Head of Personel's personal winter coat. It has a small armor vest woven inside."
	icon = 'icons/fulpicons/phoenix_nest/wintercoats_icons.dmi'
	mob_overlay_icon = 'icons/fulpicons/phoenix_nest/wintercoats.dmi'
	icon_state = "wintercoat_hop"
	item_state = "wintercoat_hop"
	lefthand_file = 'icons/fulpicons/phoenix_nest/wintercoat_lefthand.dmi'
	righthand_file = 'icons/fulpicons/phoenix_nest/wintercoat_righthand.dmi'
	armor = list("melee" = 25, "bullet" = 25, "laser" = 25, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50) // Weaker armor vest. (-5% Melee, Bullet, Laser)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/captain/hop

/obj/item/clothing/head/hooded/winterhood/captain/hop
	mob_overlay_icon = 'icons/fulpicons/phoenix_nest/wintercoats.dmi'
	icon = 'icons/fulpicons/phoenix_nest/wintercoathoods.dmi'
	icon_state = "winterhood_hop"

/obj/item/clothing/suit/hooded/wintercoat/cargo/head
	name = "\improper Quarter Master's cargo winter coat"
	desc = "It's just a regular cargo winter coat... it seems the Quarter Master still isn't a head of staff..."

/* Commented out for now. This'll go into the QM's locker on Halloween or something.
/obj/item/clothing/suit/cardborg/qm
	name = "\improper Quarter Master's hardsuit"
	desc = "Might as well make your own hardsuit if CentCom won't give you one."
*/
