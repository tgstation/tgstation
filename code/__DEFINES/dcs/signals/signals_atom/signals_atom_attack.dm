// Atom attack signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

///from base of atom/attackby(): (/obj/item, /mob/living, params)
#define COMSIG_ATOM_ATTACKBY "atom_attackby"
/// From base of [atom/proc/attacby_secondary()]: (/obj/item/weapon, /mob/user, params)
#define COMSIG_ATOM_ATTACKBY_SECONDARY "atom_attackby_secondary"
/// From [/item/attack()], sent by an atom which was just attacked by an item: (/obj/item/weapon, /mob/user, proximity_flag, click_parameters)
#define COMSIG_ATOM_AFTER_ATTACKEDBY "atom_after_attackby"
/// From base of [/atom/proc/attack_hand_secondary]: (mob/user, list/modifiers) - Called when the atom receives a secondary unarmed attack.
#define COMSIG_ATOM_ATTACK_HAND_SECONDARY "atom_attack_hand_secondary"
///Return this in response if you don't want afterattack to be called
	#define COMPONENT_NO_AFTERATTACK (1<<0)
///from base of atom/attack_hulk(): (/mob/living/carbon/human)
#define COMSIG_ATOM_HULK_ATTACK "hulk_attack"
///from base of atom/animal_attack(): (/mob/user)
#define COMSIG_ATOM_ATTACK_ANIMAL "attack_animal"
//from base of atom/attack_basic_mob(): (/mob/user)
#define COMSIG_ATOM_ATTACK_BASIC_MOB "attack_basic_mob"
	#define COMSIG_BASIC_ATTACK_CANCEL_CHAIN (1<<0)
/// from /atom/proc/atom_break: (damage_flag)
#define COMSIG_ATOM_BREAK "atom_break"
/// from base of [/atom/proc/atom_fix]: ()
#define COMSIG_ATOM_FIX "atom_fix"
/// from base of [/atom/proc/atom_destruction]: (damage_flag)
#define COMSIG_ATOM_DESTRUCTION "atom_destruction"
/// from base of [/atom/proc/extinguish]
#define COMSIG_ATOM_EXTINGUISH "atom_extinguish"
///from base of [/atom/proc/update_integrity]: (old_value, new_value)
#define COMSIG_ATOM_INTEGRITY_CHANGED "atom_integrity_changed"
///from base of [/atom/proc/take_damage]: (damage_amount, damage_type, damage_flag, sound_effect, attack_dir, aurmor_penetration)
#define COMSIG_ATOM_TAKE_DAMAGE "atom_take_damage"
	/// Return bitflags for the above signal which prevents the atom taking any damage.
	#define COMPONENT_NO_TAKE_DAMAGE (1<<0)
/* Attack signals. They should share the returned flags, to standardize the attack chain. */
/// tool_act -> pre_attack -> target.attackby (item.attack) -> afterattack
	///Ends the attack chain. If sent early might cause posterior attacks not to happen.
	#define COMPONENT_CANCEL_ATTACK_CHAIN (1<<0)
	///Skips the specific attack step, continuing for the next one to happen.
	#define COMPONENT_SKIP_ATTACK (1<<1)
///from base of atom/attack_ghost(): (mob/dead/observer/ghost)
#define COMSIG_ATOM_ATTACK_GHOST "atom_attack_ghost"
///from base of atom/attack_hand(): (mob/user, list/modifiers)
#define COMSIG_ATOM_ATTACK_HAND "atom_attack_hand"
///from base of atom/attack_paw(): (mob/user)
#define COMSIG_ATOM_ATTACK_PAW "atom_attack_paw"
///from base of atom/mech_melee_attack(): (obj/vehicle/sealed/mecha/mecha_attacker, mob/living/user)
#define COMSIG_ATOM_ATTACK_MECH "atom_attack_mech"
/// from base of atom/attack_robot(): (mob/user)
#define COMSIG_ATOM_ATTACK_ROBOT "atom_attack_robot"
/// from base of atom/attack_robot_secondary(): (mob/user)
#define COMSIG_ATOM_ATTACK_ROBOT_SECONDARY "atom_attack_robot_secondary"
///from relay_attackers element: (atom/attacker, attack_flags)
#define COMSIG_ATOM_WAS_ATTACKED "atom_was_attacked"
///Called before a atom gets something tilted on them. If [COMPONENT_IMMUNE_TO_TILT_AND_CRUSH] is returned in a signal, the atom will be unaffected: (atom/target, atom/source)
#define COMSIG_PRE_TILT_AND_CRUSH "atom_pre_tilt_and_crush"
	#define COMPONENT_IMMUNE_TO_TILT_AND_CRUSH (1<<0)
///Called when a atom gets something tilted on them: (atom/target, atom/source)
#define COMSIG_POST_TILT_AND_CRUSH "atom_post_tilt_and_crush"
/// Called when an atom is splashed with something: (atom/source)
#define COMSIG_ATOM_SPLASHED "atom_splashed"

	///The damage type of the weapon projectile is non-lethal stamina
	#define ATTACKER_STAMINA_ATTACK (1<<0)
	///the attacker is shoving the source
	#define ATTACKER_SHOVING (1<<1)
	/// The attack is a damaging-type attack
	#define ATTACKER_DAMAGING_ATTACK (1<<2)

/// Called on the atom being hit, from /datum/component/anti_magic/on_attack() : (obj/item/weapon, mob/user, antimagic_flags)
#define COMSIG_ATOM_HOLYATTACK "atom_holyattacked"
