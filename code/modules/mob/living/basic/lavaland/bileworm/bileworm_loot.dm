
//skin

/obj/item/stack/sheet/animalhide/bileworm
	name = "bileworm skin"
	desc = "The slushy, squishy and slightly shiny skin of a postmortem bileworm."
	singular_name = "bileworm skin piece"
	icon = 'icons/mob/simple/lavaland/bileworm.dmi'
	icon_state = "sheet-bileworm"
	inhand_icon_state = null
	merge_type = /obj/item/stack/sheet/animalhide/bileworm

//trophy

/obj/item/crusher_trophy/bileworm_spewlet
	name = "bileworm spewlet"
	icon = 'icons/mob/simple/lavaland/bileworm.dmi'
	icon_state = "bileworm_spewlet"
	desc = "A baby bileworm. Suitable as a trophy for a kinetic crusher."
	denied_type = /obj/item/crusher_trophy/bileworm_spewlet
	///item ability that handles the effect
	var/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/spewlet/ability

/obj/item/crusher_trophy/bileworm_spewlet/Initialize(mapload)
	. = ..()
	ability = new()

/obj/item/crusher_trophy/bileworm_spewlet/Destroy(force)
	. = ..()
	QDEL_NULL(ability)

/obj/item/crusher_trophy/bileworm_spewlet/add_to(obj/item/kinetic_crusher/crusher, mob/living/user)
	. = ..()
	if(.)
		crusher.add_item_action(ability)

/obj/item/crusher_trophy/bileworm_spewlet/remove_from(obj/item/kinetic_crusher/crusher, mob/living/user)
	. = ..()
	crusher.remove_item_action(ability)

/obj/item/crusher_trophy/bileworm_spewlet/effect_desc()
	return "mark detonation launches projectiles in cardinal directions on a 10 second cooldown"

/obj/item/crusher_trophy/bileworm_spewlet/on_mark_detonation(mob/living/target, mob/living/user)
	//ability itself handles cooldowns.
	ability.InterceptClickOn(user, null, target)

//yes this is a /mob_cooldown subtype being added to an item. I can't recommend you do what I'm doing
/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/spewlet
	check_flags = NONE
	owner_has_control = FALSE
	cooldown_time = 10 SECONDS
	projectile_type = /obj/projectile/bileworm_acid
	projectile_sound = 'sound/creatures/bileworm/bileworm_spit.ogg'

/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/spewlet/New(Target)
	firing_directions = GLOB.cardinals.Copy()
	return ..()
