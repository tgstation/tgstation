// channel numbers for power
#define EQUIP			1
#define LIGHT			2
#define ENVIRON			3
#define TOTAL			4	//for total power used only
#define STATIC_EQUIP 	5
#define STATIC_LIGHT	6
#define STATIC_ENVIRON	7


//bitflags for door switches.
#define OPEN	1
#define IDSCAN	2
#define BOLTS	4
#define SHOCK	8
#define SAFE	16

//used in design to specify which machine can build it
#define	IMPRINTER	1	//For circuits. Uses glass/chemicals.
#define PROTOLATHE	2	//New stuff. Uses glass/metal/chemicals
#define	AUTOLATHE	4	//Uses glass/metal only.
#define CRAFTLATHE	8	//Uses fuck if I know. For use eventually.
#define MECHFAB		16 //Remember, objects utilising this flag should have construction_time and construction_cost vars.
#define BIOGENERATOR 32 //Uses biomass
#define LIMBGROWER 64 //Uses synthetic flesh
//Note: More then one of these can be added to a design but imprinter and lathe designs are incompatable.

#define MC_CPU "CPU"
#define MC_HDD "HDD"
#define MC_SDD "SDD"
#define MC_CARD "CARD"
#define MC_NET "NET"
#define MC_PRINT "PRINT"
#define MC_CELL "CELL"
#define MC_CHARGE "CHARGE"
#define MC_AI "AI"