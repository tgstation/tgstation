//body_position values
#define POS_STANDING 0
#define POS_PRONE 1

//These refer to whether the mob is effectively standing or prone, regardless of how the visual representation of it is handled.
#define IS_STANDING(living) (living.body_position == POS_STANDING)
#define IS_PRONE(living) (living.body_position == POS_PRONE)

//These refers to whether the sprite has been rotated or not. This is how humans lay down, but the same is not true for xeno larvas, for example.
#define IS_HORIZONTAL(living) (living.lying_angle == 90 || living.lying_angle == 270)

//Mob mobility var flags
/// can move
#define MOBILITY_MOVE			(1<<0)
/// can stand up and remain in that position
#define MOBILITY_STAND			(1<<1)
/// can hold and use items
#define MOBILITY_HANDS_USE		(1<<2)
/// can pickup items
#define MOBILITY_PICKUP			(1<<3)
/// can use interfaces like machinery
#define MOBILITY_UI				(1<<4)
/// can use storage item
#define MOBILITY_STORAGE		(1<<5)
/// can pull things
#define MOBILITY_PULL			(1<<6)

#define MOBILITY_FLAGS_DEFAULT (MOBILITY_MOVE | MOBILITY_STAND | MOBILITY_PICKUP | MOBILITY_HANDS_USE | MOBILITY_UI | MOBILITY_STORAGE | MOBILITY_PULL)
#define MOBILITY_FLAGS_INTERACTION (MOBILITY_HANDS_USE | MOBILITY_PICKUP | MOBILITY_UI | MOBILITY_STORAGE)

//Would they be able to if they wanted? mobility_flags checks for potential, HAS_TRAIT checks for temporary blocks.
#define LIVING_CAN_MOVE(living) (living.mobility_flags & MOBILITY_MOVE && !HAS_TRAIT(living, TRAIT_IMMOBILE))
#define LIVING_CAN_STAND(living) (living.mobility_flags & MOBILITY_STAND && !HAS_TRAIT(living, TRAIT_STANDINGBLOCKED))
#define LIVING_CAN_USE_HANDS(living) (living.mobility_flags & MOBILITY_HANDS_USE && !HAS_TRAIT(living, TRAIT_HANDSBLOCKED))
#define LIVING_CAN_PICK_UP(living) (living.mobility_flags & MOBILITY_PICKUP && !HAS_TRAIT(living, TRAIT_PICKUPBLOCKED))
#define LIVING_CAN_UI(living) (living.mobility_flags & MOBILITY_UI && !HAS_TRAIT(living, TRAIT_UIBLOCKED))
#define LIVING_CAN_STORAGE(living) (living.mobility_flags & MOBILITY_STORAGE && !HAS_TRAIT(living, TRAIT_STORAGEBLOCKED))
#define LIVING_CAN_PULL(living) (living.mobility_flags & MOBILITY_PULL && !HAS_TRAIT(living, TRAIT_PULLBLOCKED))

//Common check, for inability to both move or use items.
#define IS_STUNNED(living) (!LIVING_CAN_MOVE(living) && !LIVING_CAN_USE_HANDS(living))
//Common check, restrained + stunned.
#define IS_INCAPACITATED(living) (HAS_TRAIT(living, TRAIT_RESTRAINED) || IS_STUNNED(living))
//Unable to move, stand or use hands. Like the side-effects of unconsciousness.
#define IS_PARALYZED(living) (!LIVING_CAN_MOVE(living) && !LIVING_CAN_STAND(living) && !LIVING_CAN_USE_HANDS(living))
//A lot of incapacitated() checks meant to look for something like this.
#define IS_UP_AND_ABLE(living) (IS_STANDING(living) && LIVING_CAN_MOVE(living) && LIVING_CAN_USE_HANDS(living))
//Checks against restraints, or that ignore the mob being restrained.
#define IS_UP_AND_MOBILE(living) (IS_STANDING(living) && LIVING_CAN_MOVE(living))

//Pretty snowflakey, formely a form of restraint (is resistible) but was more different than similar to the other restraint sources.
#define IS_NECKGRABBED(movable) (movable.pulledby && movable.pulledby.grab_state >= GRAB_AGGRESSIVE)
