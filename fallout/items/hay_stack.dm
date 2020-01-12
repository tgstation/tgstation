//Contains new hay craftable objects, will be moved into their relevant files eventually
//For now these are collated here for ease of my lazyness times -Gomble

GLOBAL_LIST_INIT(hay_recipes, list ( \
	new/datum/stack_recipe("rice hat", /obj/item/clothing/head/rice_hat, 4, time = 5, one_per_turf = FALSE, on_floor = FALSE), \
))
//TODO - Thread/Rope for tailoring from hay fibres
/obj/item/stack/sheet/hay
	name = "hay"
	desc = "A bundle of hay. Food for livestock, and useful for weaving. Hail the Wickerman."
	singular_name = "hay stalk"
	icon = 'fallout/icons/objects/items.dmi'
	icon_state = "sheet-hay_3" //Holy someone made this sprite so tiny and having to pixel hunt for, i'll just leave it at the big sprite
	item_state = "sheet-hay_3"
	force = 1
	throwforce = 1
	throw_speed = 1
	throw_range = 2
	max_amount = 50
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 0)
	resistance_flags = FLAMMABLE
	attack_verb = list("tickled", "poked", "whipped")

/obj/item/stack/sheet/hay/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.hay_recipes
	return ..()

/obj/item/stack/sheet/hay/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins shoving hay up [user.p_their()] arse! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	addtimer(CALLBACK(user, /mob/proc/gib), 30) //fancy callback bullshit
	return BRUTELOSS

/obj/item/stack/sheet/hay/fifty
	amount = 50

/obj/item/stack/sheet/hay/twenty
	amount = 20

/obj/item/stack/sheet/hay/ten
	amount = 10

/obj/item/stack/sheet/hay/five
	amount = 5
