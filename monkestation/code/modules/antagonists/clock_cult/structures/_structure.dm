/// The base clockwork structure. Can have an alternate desc and will show up in the list of clockwork objects.
/obj/structure/destructible/clockwork
	name = "meme structure"
	desc = "Some frog or something, the fuck?"
	icon = 'monkestation/icons/obj/clock_cult/clockwork_objects.dmi'
	icon_state = "rare_pepe"
	anchored = TRUE
	density = TRUE
	resistance_flags = FIRE_PROOF | ACID_PROOF
	break_message = span_warning("Sparks fly as the brass structure shatters across the ground.") //The message shown when a structure breaks
	break_sound = 'sound/magic/clockwork/anima_fragment_death.ogg' //The sound played when a structure breaks
	debris = list(
		/obj/structure/fluff/clockwork/alloy_shards/large = 1,
		/obj/structure/fluff/clockwork/alloy_shards/medium = 2,
		/obj/structure/fluff/clockwork/alloy_shards/small = 3,
	)
	///if we ignore attacks from servants of ratvar instead of taking damage
	var/immune_to_servant_attacks = FALSE
	///The person who placed this structure
	var/datum/mind/owner = null
	///Shown to servants when they examine
	var/clockwork_desc = ""
	///Shown to servants when they examine and are on reebe
	var/reebe_desc = ""
	///can this structure be rotated with a crowbar
	var/can_rotate = TRUE
	///if set, then the maximum amount of damage this structure can take from take_damage()
	var/damage_cap
	///a basic cooldown declare for anything that will use it
	COOLDOWN_DECLARE(use_cooldown)

/obj/structure/destructible/clockwork/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/clockwork_description, clockwork_desc, reebe_desc)

/obj/structure/destructible/clockwork/Destroy()
	owner = null

	return ..()

/obj/structure/destructible/clockwork/attacked_by(obj/item/I, mob/living/user)
	if(immune_to_servant_attacks && (IS_CLOCK(user)))
		return

	return ..()


/obj/structure/destructible/clockwork/crowbar_act(mob/living/user, obj/item/tool)
	if(IS_CLOCK(user) && can_rotate)
		setDir(turn(dir, 90))
		balloon_alert(user, "rotated [dir2text(dir)]")

	return TRUE

/obj/structure/destructible/clockwork/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	if(damage_cap)
		damage_amount = min(damage_cap, damage_amount)
	. = ..()
