/obj/item/clothing/suit/hooded/wintercoat
	mutant_variants = NONE

/obj/item/clothing/suit/hooded/wintercoat/paramedic
	icon = 'modular_skyrat/modules/customization/icons/obj/clothing/suits.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/mob/clothing/suit.dmi'
	name = "paramedic winter coat"
	desc = "A winter coat with blue markings. Warm, but probably won't protect from biological agents. For the cozy doctor on the go."
	icon_state = "coatparamed"
	inhand_icon_state = "coatparamed"
	allowed = list(/obj/item/analyzer, /obj/item/stack/medical, /obj/item/dnainjector, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray, /obj/item/healthanalyzer, /obj/item/flashlight/pen, /obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/reagent_containers/pill, /obj/item/storage/pill_bottle, /obj/item/paper, /obj/item/melee/classic_baton/telescopic, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 50, "rad" = 0, "fire" = 0, "acid" = 45, "wound" = 3)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/paramedic

/obj/item/clothing/head/hooded/winterhood/paramedic
	icon = 'modular_skyrat/modules/customization/icons/obj/clothing/hats.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/mob/clothing/head.dmi'
	desc = "A white winter coat hood with blue markings."
	icon_state = "winterhood_paramed"

/obj/item/clothing/suit/hooded/wintercoat/robotics
	icon = 'modular_skyrat/modules/customization/icons/obj/clothing/suits.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/mob/clothing/suit.dmi'
	name = "robotics winter coat"
	desc = "A black winter coat with a badass flaming robotic skull for the zipper tab. This one has bright red designs and a few useless buttons."
	icon_state = "coatrobotics"
	inhand_icon_state = "coatrobotics"
	allowed = list(/obj/item/analyzer, /obj/item/stack/medical, /obj/item/dnainjector, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray, /obj/item/healthanalyzer, /obj/item/melee/classic_baton/telescopic, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/screwdriver, /obj/item/crowbar, /obj/item/wrench, /obj/item/stack/cable_coil, /obj/item/weldingtool, /obj/item/multitool)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0, "wound" = 0)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/robotics

/obj/item/clothing/head/hooded/winterhood/robotics
	icon = 'modular_skyrat/modules/customization/icons/obj/clothing/hats.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/mob/clothing/head.dmi'
	desc = "A black winter coat hood. You can pull it down over your eyes and pretend that you're an outdated, late 1980s interpretation of a futuristic mechanized police force. They'll fix you. They fix everything."
	icon_state = "winterhood_robotics"


/obj/item/clothing/suit/hooded/wintercoat/aformal
	icon = 'modular_skyrat/modules/customization/icons/obj/clothing/suits.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/mob/clothing/suit.dmi'
	name = "assistant's formal winter coat"
	desc = "A black button up winter coat."
	icon_state = "coataformal"
	inhand_icon_state = "coataformal"
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter,/obj/item/clothing/gloves/color/yellow)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/aformal

/obj/item/clothing/head/hooded/winterhood/aformal
	icon = 'modular_skyrat/modules/customization/icons/obj/clothing/hats.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/mob/clothing/head.dmi'
	desc = "A black winter coat hood."
	icon_state = "winterhood_aformal"

/obj/item/clothing/suit/hooded/wintercoat/ratvar
	icon = 'modular_skyrat/modules/customization/icons/obj/clothing/suits.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/mob/clothing/suit.dmi'
	name = "ratvarian winter coat"
	desc = "A brass-plated button up winter coat. Instead of a zipper tab, it has a brass cog with a tiny red gemstone inset."
	icon_state = "coatratvar"
	inhand_icon_state = "coatratvar"
	armor = list("melee" = 30, "bullet" = 45, "laser" = -10, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 60, "acid" = 60, "wound" = 10)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/ratvar
	var/real = TRUE

/obj/item/clothing/head/hooded/winterhood/ratvar
	icon = 'modular_skyrat/modules/customization/icons/obj/clothing/hats.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/mob/clothing/head.dmi'
	icon_state = "winterhood_ratvar"
	desc = "A brass-plated winter hood that glows softly, hinting at its divinity."
	light_range = 3
	light_power = 1
	light_color = "#B18B25" //clockwork slab background top color

/*/obj/item/clothing/suit/hooded/wintercoat/ratvar/equipped(mob/living/user,slot)
	..()
	if (slot != SLOT_WEAR_SUIT || !real)
		return
	if (is_servant_of_ratvar(user))
		return
	else
		user.dropItemToGround(src)
		to_chat(user,"<span class='large_brass'>\"Amusing that you think you are fit to wear this.\"</span>")
		to_chat(user,"<span class='userdanger'>Your skin burns where the coat touched your skin!</span>")
		user.adjustFireLoss(rand(10,16))*/

/obj/item/clothing/suit/hooded/wintercoat/narsie
	icon = 'modular_skyrat/modules/customization/icons/obj/clothing/suits.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/mob/clothing/suit.dmi'
	name = "narsian winter coat"
	desc = "A somber button-up in tones of grey entropy and a wicked crimson zipper. When pulled all the way up, the zipper looks like a bloody gash. The zipper pull looks like a single drop of blood."
	icon_state = "coatnarsie"
	inhand_icon_state = "coatnarsie"
	armor = list("melee" = 30, "bullet" = 20, "laser" = 30,"energy" = 10, "bomb" = 30, "bio" = 10, "rad" = 10, "fire" = 30, "acid" = 30, "wound" = 10)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/restraints/legcuffs/bola/cult,/obj/item/melee/cultblade,/obj/item/melee/cultblade/dagger,/obj/item/reagent_containers/glass/beaker/unholywater,/obj/item/cult_shift,/obj/item/flashlight/flare/culttorch,/obj/item/cult_spear)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/narsie
	var/real = TRUE

/*/obj/item/clothing/suit/hooded/wintercoat/narsie/equipped(mob/living/user,slot)
	..()
	if (slot != SLOT_WEAR_SUIT || !real)
		return
	if (iscultist(user))
		return
	else
		user.dropItemToGround(src)
		to_chat(user,"<span class='cultlarge'>\"You are not fit to wear my follower's coat!\"</span>")
		to_chat(user,"<span class='userdanger'>Sharp spines jab you from within the coat!</span>")
		user.adjustBruteLoss(rand(10,16))*/

/obj/item/clothing/head/hooded/winterhood/narsie
	icon = 'modular_skyrat/modules/customization/icons/obj/clothing/hats.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/mob/clothing/head.dmi'
	desc = "A black winter hood full of whispering secrets that only She shall ever know."
	icon_state = "winterhood_narsie"

/obj/item/clothing/suit/hooded/wintercoat/ratvar/fake
	name = "brass winter coat"
	desc = "A brass-plated button up winter coat. Instead of a zipper tab, it has a brass cog with a tiny red piece of plastic as an inset."
	icon_state = "coatratvar"
	inhand_icon_state = "coatratvar"
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0, "wound" = 0)
	real = FALSE

/obj/item/clothing/suit/hooded/wintercoat/narsie/fake
	name = "runed winter coat"
	desc = "A dusty button up winter coat in the tones of oblivion and ash. The zipper pull looks like a single drop of blood."
	icon_state = "coatnarsie"
	inhand_icon_state = "coatnarsie"
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0, "wound" = 0)
	real = FALSE

/obj/item/clothing/suit/flakjack
	icon = 'modular_skyrat/modules/customization/icons/obj/clothing/suits.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/mob/clothing/suit.dmi'
	name = "flak jacket"
	desc = "A dilapidated jacket made of a supposedly bullet-proof material (Hint: It isn't.). Smells faintly of napalm."
	icon_state = "flakjack"
	inhand_icon_state = "redtag"
	blood_overlay_type = "armor"
	body_parts_covered = CHEST
	resistance_flags = NONE
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 5, "bio" = 0, "rad" = 0, "fire" = -5, "acid" = -15, "wound" = 0) //nylon sucks against acid
	mutant_variants = NONE

/obj/item/clothing/suit/hooded/cloak/david
	icon = 'modular_skyrat/modules/customization/icons/obj/clothing/suits.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/mob/clothing/suit.dmi'
	name = "red cloak"
	icon_state = "goliath_cloak"
	desc = "Ever wanted to look like a badass without ANY effort? Try this nanotrasen brand red cloak, perfect for kids"
	hoodtype = /obj/item/clothing/head/hooded/cloakhood/david
	body_parts_covered = CHEST|GROIN|ARMS
	mutant_variants = NONE

/obj/item/clothing/head/hooded/cloakhood/david
	icon = 'modular_skyrat/modules/customization/icons/obj/clothing/hats.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/mob/clothing/head.dmi'
	name = "red cloak hood"
	icon_state = "golhood"
	desc = "conceal your face in shame with this nanotrasen brand hood"
	flags_inv = HIDEEARS|HIDEEYES|HIDEHAIR|HIDEFACIALHAIR
	mutant_variants = NONE
