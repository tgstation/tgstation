//Vehicle control flags

#define VEHICLE_CONTROL_PERMISSION 1
#define VEHICLE_CONTROL_DRIVE 2
#define VEHICLE_CONTROL_KIDNAPPED 4 //Can't leave vehicle voluntarily, has to resist.


//Car trait flags
#define CAN_KIDNAP 1

#define ISDIAGONALDIR(d) (d&(d-1))
#define NSCOMPONENT(d)   (d&(NORTH|SOUTH))
#define EWCOMPONENT(d)   (d&(EAST|WEST))
#define NSDIRFLIP(d)     (d^(NORTH|SOUTH))
#define EWDIRFLIP(d)     (d^(EAST|WEST))
#define DIRFLIP(d)       turn(d, 180)
