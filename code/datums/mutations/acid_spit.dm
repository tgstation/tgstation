/datum/mutation/human/acidspit
	name = "Acid Spit"
	desc = "An ancient mutation originating from xenomorphs that changes the salivary glands to produce acid."
	instability = 50
	difficulty = 12
	locked = TRUE
	text_gain_indication = span_notice("Your saliva burns your mouth!")
	text_lose_indication = span_notice("Your saliva cools down.")
	power_path = /datum/action/cooldown/spell/pointed/projectile/acid_spit

/datum/action/cooldown/spell/pointed/projectile/acid_spit
	name = "Acid Spit"
	desc = "You focus your corrosive saliva to spit at your target"
	button_icon = 'icons/mob/actions/actions_xeno.dmi'
	button_icon_state = "alien_neurotoxin_0"
	active_icon_state = "alien_neurotoxin_1"
	base_icon_state = "alien_neurotoxin_0"
	active_overlay_icon_state = "bg_spell_border_active_red"
	cooldown_time = 18 SECONDS
	spell_requirements = NONE
	antimagic_flags = NONE
	school = SCHOOL_EVOCATION
	sound = 'sound/effects/spitacid.ogg'

	active_msg = "You focus your acid spit!"
	deactive_msg = "You relax."
	projectile_type = /obj/projectile/bullet/acid

/datum/action/cooldown/spell/pointed/projectile/acid_spit/can_cast_spell(feedback)
	. = ..()
	if(!get_location_accessible(owner, BODY_ZONE_PRECISE_MOUTH))
		to_chat(owner, span_notice("Something is covering your mouth!"))
		return FALSE

/obj/projectile/bullet/acid
	name = "acid spit"
	icon_state = "neurotoxin"
	damage = 2
	damage_type = BURN
	armor_flag = BIO
	range = 7
	speed = 1.8 // spit is not very fast

obj/projectile/bullet/acid/on_hit(atom/target, blocked = FALSE, pierce_hit)
	if(isalien(target)) // shouldn't work on xenos
		damage = 0
	else if(!isopenturf(target))
		target.acid_act(50, 15) // does good damage to objects and structures
	else if(iscarbon(target))
		target.acid_act(18, 15) // balanced
	return ..()
