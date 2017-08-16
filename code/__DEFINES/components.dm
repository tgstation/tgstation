//shorthand
#define GET_COMPONENT_FROM(varname, path, target) var##path/##varname = ##target.GetComponent(##path)
#define GET_COMPONENT(varname, path) GET_COMPONENT_FROM(varname, path, src)

// How multiple components of the exact same type are handled in the same datum

#define COMPONENT_DUPE_HIGHLANDER 0 //old component is deleted (default)
#define COMPONENT_DUPE_ALLOWED 1    //duplicates allowed 
#define COMPONENT_DUPE_UNIQUE 2     //new component is deleted

// All signals. Format:
// When the signal is called: (signal arguments)

#define COMSIG_COMPONENT_ADDED "component_added"				//when a component is added to a datum: (datum/component)
#define COMSIG_COMPONENT_REMOVING "component_removing"			//before a component is removed from a datum because of RemoveComponent: (datum/component)
#define COMSIG_PARENT_QDELETED "parent_qdeleted"				//before a datum's Destroy() is called: ()
#define COMSIG_ATOM_ENTERED "atom_entered"						//from base of atom/Entered(): (atom/movable, atom)
#define COMSIG_MOVABLE_CROSSED "movable_crossed"				//from base of atom/movable/Crossed(): (atom/movable)
