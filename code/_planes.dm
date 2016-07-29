//List of all preclaimed planes
//Generally 'arbitrary' planes should be given a constant number
//Planes that are dependent upon another plane value should be defined with that plane
#define CLICKCATCHER_PLANE -99
#define PLANE_SPACE_BACKGROUND -10
#define PLANE_SPACE_PARALLAX (PLANE_SPACE_BACKGROUND + 1)
#define PLANE_SPACE_DUST (PLANE_SPACE_PARALLAX + 1)

#define PLANE_TURF -6
#define PLANE_NOIR_BLOOD -5
#define PLANE_OBJ -4
#define PLANE_MOB -3
#define PLANE_EFFECTS -2
#define PLANE_LIGHTING -1

#define PLANE_BASE 0

#define PLANE_STATIC 1
#define PLANE_HUD 2

/image
	plane = FLOAT_PLANE