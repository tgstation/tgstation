#define GEAR_LOOSE 2

//floodlights because apparently we use defines now
#define FLOODLIGHT_NEEDS_WIRES 0
#define FLOODLIGHT_NEEDS_LIGHTS 1
#define FLOODLIGHT_NEEDS_SECURING 2
#define FLOODLIGHT_NEEDS_WRENCHING 3

//other construction-related things

//windows affected by Nar'Sie turn this color.
#define NARSIE_WINDOW_COLOUR "#7D1919"

//let's just pretend fulltile windows being children of border windows is fine
#define FULLTILE_WINDOW_DIR NORTHEAST

//Material defines, for determining how much of a given material an item contains
#define MAT_METAL		"$metal"
#define MAT_GLASS		"$glass"
#define MAT_SILVER		"$silver"
#define MAT_GOLD		"$gold"
#define MAT_DIAMOND		"$diamond"
#define MAT_URANIUM		"$uranium"
#define MAT_PLASMA		"$plasma"
#define MAT_BLUESPACE	"$bluespace"
#define MAT_BANANIUM	"$bananium"
#define MAT_TITANIUM	"$titanium"
#define MAT_BIOMASS		"$biomass"
#define MAT_PLASTIC	"$plastic"
//The amount of materials you get from a sheet of mineral like iron/diamond/glass etc
#define MINERAL_MATERIAL_AMOUNT 2000
//The maximum size of a stack object.
#define MAX_STACK_SIZE 50
//maximum amount of cable in a coil
#define MAXCOIL 30

//tablecrafting defines
#define CAT_NONE	""
#define CAT_WEAPONRY	"Weaponry"
#define CAT_WEAPON	"Weapons"
#define CAT_AMMO	"Ammunition"
#define CAT_ROBOT	"Robots"
#define CAT_MISC	"Misc"
#define CAT_PRIMAL  "Tribal"
#define CAT_CLOTHING	"Clothing"
#define CAT_FOOD	"Foods"
#define CAT_BREAD	"Breads"
#define CAT_BURGER	"Burgers"
#define CAT_CAKE	"Cakes"
#define CAT_EGG	"Egg-Based Food"
#define CAT_MEAT	"Meats"
#define CAT_MISCFOOD	"Misc. Food"
#define CAT_PASTRY	"Pastries"
#define CAT_PIE	"Pies"
#define CAT_PIZZA	"Pizzas"
#define CAT_SALAD	"Salads"
#define CAT_SANDWICH	"Sandwiches"
#define CAT_SOUP	"Soups"
#define CAT_SPAGHETTI	"Spaghettis"

#define RCD_FLOORWALL 1
#define RCD_AIRLOCK 2
#define RCD_DECONSTRUCT 3
#define RCD_WINDOWGRILLE 4
#define RCD_MACHINE 8
#define RCD_COMPUTER 16