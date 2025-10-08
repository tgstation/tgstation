//Bluespace crystals, used in telescience and when crushed it will blink you to a random turf.
/obj/item/stack/ore/bluespace_crystal
	name = "bluespace crystal"
	desc = "A glowing bluespace crystal, not much is known about how they work. It looks very delicate."
	icon = 'icons/obj/ore.dmi'
	icon_state = "bluespace_crystal"
	singular_name = "bluespace crystal"
	dye_color = DYE_COSMIC
	w_class = WEIGHT_CLASS_TINY
	mats_per_unit = list(/datum/material/bluespace=SHEET_MATERIAL_AMOUNT)
	points = 50
	refined_type = /obj/item/stack/sheet/bluespace_crystal
	grind_results = list(/datum/reagent/bluespace = 20)
	scan_state = "rock_bscrystal"
	merge_type = /obj/item/stack/ore/bluespace_crystal
	/// The teleport range when crushed/thrown at someone.
	var/blink_range = 8

/obj/item/stack/ore/bluespace_crystal/refined
	name = "refined bluespace crystal"
	points = 0
	refined_type = null
	merge_type = /obj/item/stack/ore/bluespace_crystal/refined
	drop_sound = null //till I make a better one
	pickup_sound = null

/obj/item/stack/ore/bluespace_crystal/Initialize(mapload, new_amount, merge = TRUE, list/mat_override=null, mat_amt=1)
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/item/stack/ore/bluespace_crystal/get_part_rating()
	return 1

/obj/item/stack/ore/bluespace_crystal/attack_self(mob/user)
	user.visible_message(span_warning("[user] crushes [src]!"), span_danger("You crush [src]!"))
	new /obj/effect/particle_effect/sparks(loc)
	playsound(loc, SFX_PORTAL_ENTER, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	blink_mob(user)
	use(1)

/obj/item/stack/ore/bluespace_crystal/proc/blink_mob(mob/living/L)
	do_teleport(L, get_turf(L), blink_range, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)

/obj/item/stack/ore/bluespace_crystal/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..()) // not caught in mid-air
		visible_message(span_notice("[src] fizzles and disappears upon impact!"))
		var/turf/T = get_turf(hit_atom)
		new /obj/effect/particle_effect/sparks(T)
		playsound(loc, SFX_PORTAL_ENTER, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		if(isliving(hit_atom))
			blink_mob(hit_atom)
		use(1)

//Artificial bluespace crystal, doesn't give you much research.
/obj/item/stack/ore/bluespace_crystal/artificial
	name = "artificial bluespace crystal"
	desc = "An artificially made bluespace crystal, it looks delicate."
	mats_per_unit = list(/datum/material/bluespace=SHEET_MATERIAL_AMOUNT*0.5)
	blink_range = 4 // Not as good as the organic stuff!
	points = 0 //nice try
	refined_type = null
	grind_results = list(/datum/reagent/bluespace = 10, /datum/reagent/silicon = 20)
	merge_type = /obj/item/stack/ore/bluespace_crystal/artificial
	drop_sound = null //till I make a better one
	pickup_sound = null

//Polycrystals, aka stacks
/obj/item/stack/sheet/bluespace_crystal
	name = "bluespace polycrystal"
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "polycrystal"
	inhand_icon_state = null
	gulag_valid = TRUE
	singular_name = "bluespace polycrystal"
	desc = "A stable polycrystal, made of fused-together bluespace crystals. You could probably break one off."
	mats_per_unit = list(/datum/material/bluespace=SHEET_MATERIAL_AMOUNT)
	attack_verb_continuous = list("bluespace polybashes", "bluespace polybatters", "bluespace polybludgeons", "bluespace polythrashes", "bluespace polysmashes")
	attack_verb_simple = list("bluespace polybash", "bluespace polybatter", "bluespace polybludgeon", "bluespace polythrash", "bluespace polysmash")
	novariants = TRUE
	grind_results = list(/datum/reagent/bluespace = 20)
	merge_type = /obj/item/stack/sheet/bluespace_crystal
	material_type = /datum/material/bluespace
	var/crystal_type = /obj/item/stack/ore/bluespace_crystal/refined


/obj/item/stack/sheet/bluespace_crystal/attack_self(mob/user)// to prevent the construction menu from ever happening
	to_chat(user, span_warning("You cannot crush the polycrystal in-hand, try breaking one off."))

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/stack/sheet/bluespace_crystal/attack_hand(mob/user, list/modifiers)
	if(user.get_inactive_held_item() == src)
		if(is_zero_amount(delete_if_zero = TRUE))
			return
		var/BC = new crystal_type(src)
		user.put_in_hands(BC)
		use(1)
		if(!amount)
			to_chat(user, span_notice("You break the final crystal off."))
		else
			to_chat(user, span_notice("You break off a crystal."))
	else
		..()

/obj/item/stack/sheet/bluespace_crystal/fifty
	amount = 50
