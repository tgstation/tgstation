/obj/item/stack/sheet
	name = "sheet"
	lefthand_file = 'icons/mob/inhands/misc/sheets_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/sheets_righthand.dmi'
	full_w_class = WEIGHT_CLASS_NORMAL
	force = 5
	throwforce = 5
	max_amount = 50
	throw_speed = 1
	throw_range = 3
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "smashed")
	novariants = FALSE
	var/sheettype = null //this is used for girders in the creation of walls/false walls
	var/point_value = 0 //turn-in value for the gulag stacker - loosely relative to its rarity.
	///What type of wall does this sheet spawn
	var/walltype
	///What the sheet will shatter to if you slap the floor
	var/obj/item/shards_to

/obj/item/stack/sheet/Initialize(mapload, new_amount, merge)
	. = ..()
	pixel_x = rand(-4, 4)
	pixel_y = rand(-4, 4)

/**
 * Facilitates sheets being smacked on the floor
 *
 * This is used for crafting by hitting the floor with items.
 * The inital use case is glass sheets breaking in to shards when the floor is hit.
 * Args:
 * * user: The user that did the action
 * * params: paramas passed in from attackby
 */
/obj/item/stack/sheet/proc/on_attack_floor(mob/user, params)
	if(!shards_to)
		return FALSE
	user.do_attack_animation(src, ATTACK_EFFECT_BOOP)
	playsound(src, "shatter", 70, TRUE)
	use(1)
	to_chat(user, "<span class='notice'>You shatter one sheet of [name] on the floor.</span>")
	var/obj/item/shard/new_shard = new shards_to(user.loc)
	new_shard.add_fingerprint(user)
	return TRUE
