//shorthand
#define GET_COMPONENT_FROM(varname, path, target) var##path/##varname = ##target.GetComponent(##path)
#define GET_COMPONENT(varname, path) GET_COMPONENT_FROM(varname, path, src)

// How multiple components of the exact same type are handled in the same datum

#define COMPONENT_DUPE_HIGHLANDER 0 //old component is deleted (default)
#define COMPONENT_DUPE_ALLOWED 1    //duplicates allowed
#define COMPONENT_DUPE_UNIQUE 2     //new component is deleted

// All signals. Format:
// When the signal is called: (signal arguments)

// /datum signals
#define COMSIG_COMPONENT_ADDED "component_added"				//when a component is added to a datum: (datum/component)
#define COMSIG_COMPONENT_REMOVING "component_removing"			//before a component is removed from a datum because of RemoveComponent: (datum/component)
#define COMSIG_PARENT_QDELETED "parent_qdeleted"				//before a datum's Destroy() is called: ()

// /atom signals
#define COMSIG_PARENT_ATTACKBY "atom_attackby"			        //from base of atom/attackby(): (obj/item, mob/living, params)
#define COMSIG_ATOM_HULK_ATTACK "hulk_attack"					//from base of atom/attack_hulk(): (mob/living/carbon/human)
#define COMSIG_PARENT_EXAMINE "atom_examine"                    //from base of atom/examine(): (mob)
#define COMSIG_ATOM_ENTERED "atom_entered"                      //from base of atom/Entered(): (atom/movable, atom)
#define COMSIG_ATOM_EX_ACT "atom_ex_act"						//from base of atom/ex_act(): (severity, target)
#define COMSIG_ATOM_EMP_ACT "atom_emp_act"						//from base of atom/emp_act(): (severity)
#define COMSIG_ATOM_FIRE_ACT "atom_fire_act"					//from base of atom/fire_act(): (exposed_temperature, exposed_volume)
#define COMSIG_ATOM_BULLET_ACT "atom_bullet_act"				//from base of atom/bullet_act(): (obj/item/projectile, def_zone)
#define COMSIG_ATOM_BLOB_ACT "atom_blob_act"					//from base of atom/blob_act(): (obj/structure/blob)
#define COMSIG_ATOM_ACID_ACT "atom_acid_act"					//from base of atom/acid_act(): (acidpwr, acid_volume)
#define COMSIG_ATOM_EMAG_ACT "atom_emag_act"					//from base of atom/emag_act(): ()
#define COMSIG_ATOM_NARSIE_ACT "atom_narsie_act"				//from base of atom/narsie_act(): ()
#define COMSIG_ATOM_RATVAR_ACT "atom_ratvar_act"				//from base of atom/ratvar_act(): ()
#define COMSIG_ATOM_RCD_ACT "atom_rcd_act"						//from base of atom/rcd_act(): (mob, obj/item/construction/rcd, passed_mode)
#define COMSIG_ATOM_SING_PULL "atom_sing_pull"					//from base of atom/singularity_pull(): (S, current_size)

// /atom/movable signals
#define COMSIG_MOVABLE_MOVED "movable_moved"					//from base of atom/movable/Moved(): (atom, dir)
#define COMSIG_MOVABLE_CROSSED "movable_crossed"                //from base of atom/movable/Crossed(): (atom/movable)
#define COMSIG_MOVABLE_COLLIDE "movable_collide"				//from base of atom/movable/Collide(): (atom)
#define COMSIG_MOVABLE_IMPACT "movable_impact"					//from base of atom/movable/throw_impact(): (atom, throwingdatum)

// /obj/machinery signals
#define COMSIG_MACHINE_PROCESS "machine_process"				//from machinery subsystem fire(): ()
#define COMSIG_MACHINE_PROCESS_ATMOS "machine_process_atmos"	//from air subsystem process_atmos_machinery(): () 