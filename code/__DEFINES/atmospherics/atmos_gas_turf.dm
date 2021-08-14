///moles in a 2.5 m^3 cell at 101.325 Pa and 20 degC (103 or so)
#define MOLES_CELLSTANDARD (ONE_ATMOSPHERE*CELL_VOLUME/(T20C*R_IDEAL_GAS_EQUATION))
///compared against for superconductivity
#define M_CELL_WITH_RATIO (MOLES_CELLSTANDARD * 0.005)
/// percentage of oxygen in a normal mixture of air
#define O2STANDARD 0.21
/// same but for nitrogen
#define N2STANDARD 0.79
/// O2 standard value (21%)
#define MOLES_O2STANDARD (MOLES_CELLSTANDARD*O2STANDARD)
/// N2 standard value (79%)
#define MOLES_N2STANDARD (MOLES_CELLSTANDARD*N2STANDARD)
/// liters in a cell
#define CELL_VOLUME 2500

//CANATMOSPASS
#define ATMOS_PASS_YES 1
#define ATMOS_PASS_NO 0
/// ask CanAtmosPass()
#define ATMOS_PASS_PROC -1
/// just check density
#define ATMOS_PASS_DENSITY -2

//Adjacent turf related defines, they dictate what to do with a turf once it's been recalculated
//Used as "state" in CALCULATE_ADJACENT_TURFS
///Normal non-active turf
#define NORMAL_TURF 1
///Set the turf to be activated on the next calculation
#define MAKE_ACTIVE 2
///Disable excited group
#define KILL_EXCITED 3
