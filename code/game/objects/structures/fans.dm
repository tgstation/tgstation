//Fans
/obj/structure/fans
	icon = 'icons/obj/mining_zones/survival_pod.dmi'
	icon_state = "fans"
	name = "environmental regulation system"
	desc = "A large machine releasing a constant gust of air."
	anchored = TRUE
	density = TRUE
	var/buildstacktype = /obj/item/stack/sheet/iron
	var/buildstackamount = 5
	can_atmos_pass = ATMOS_PASS_NO

/obj/structure/fans/atom_deconstruct(disassembled = TRUE)
	if(buildstacktype)
		new buildstacktype(loc,buildstackamount)

/obj/structure/fans/wrench_act(mob/living/user, obj/item/I)
	user.visible_message(span_warning("[user] disassembles [src]."),
		span_notice("You start to disassemble [src]..."), span_hear("You hear clanking and banging noises."))
	if(I.use_tool(src, user, 20, volume=50))
		deconstruct(TRUE)
	return TRUE

/obj/structure/fans/tiny
	name = "tiny fan"
	desc = "A tiny fan, releasing a thin gust of air."
	layer = ABOVE_NORMAL_TURF_LAYER
	density = FALSE
	icon_state = "fan_tiny"
	buildstackamount = 2

/obj/structure/fans/Initialize(mapload)
	. = ..()
	air_update_turf(TRUE, TRUE)

/obj/structure/fans/Destroy()
	air_update_turf(TRUE, FALSE)
	. = ..()

//Invisible, indestructible fans
/obj/structure/fans/tiny/invisible
	name = "air flow blocker"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	invisibility = INVISIBILITY_ABSTRACT

/obj/structure/fans/tiny/shield
	name = "shuttle bay shield"
	desc = "A tenuously thin energy shield only capable of holding in air, but not solid objects or people."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-old" // We should probably get these their own icon at some point
	light_color = LIGHT_COLOR_BLUE
	light_range = 4

/obj/structure/fans/tiny/shield/wrench_act(mob/living/user, obj/item/I)
	return ITEM_INTERACT_SKIP_TO_ATTACK //how you gonna wrench disassemble a shield?????????
