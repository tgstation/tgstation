// Generated from the vibestation13 periodic table data. Element facts are real; game effects are not.

/// All 118 elements in atomic order. Index n is element n.
GLOBAL_LIST_INIT(periodic_table, init_periodic_table())

/// One element of the periodic table and the reagent that represents it.
/datum/periodic_element
	/// Atomic number
	var/number
	/// Chemical symbol, e.g. "Fe"
	var/symbol
	/// Element name, matching the reagent's name
	var/name
	/// Standard atomic weight, or the mass number of the longest-lived isotope for elements with no stable ones
	var/atomic_weight
	/// One of the ELEMENT_CATEGORY_* defines
	var/category
	/// State at room temperature and pressure, one of the ELEMENT_STATE_* defines
	var/state
	/// Periodic table row, 1 to 7
	var/period
	/// IUPAC group, 1 to 18, or 0 for the lanthanides and actinides
	var/group
	/// The reagent typepath for this element
	var/datum/reagent/reagent_type

/datum/periodic_element/New(number, symbol, name, atomic_weight, category, state, period, group, reagent_type)
	src.number = number
	src.symbol = symbol
	src.name = name
	src.atomic_weight = atomic_weight
	src.category = category
	src.state = state
	src.period = period
	src.group = group
	src.reagent_type = reagent_type

/// Returns the element a reagent represents, or null if it isn't an element.
/proc/get_periodic_element(datum/reagent/reagent)
	var/reagent_type = ispath(reagent) ? reagent : reagent?.type
	for(var/datum/periodic_element/element as anything in GLOB.periodic_table)
		if(element.reagent_type == reagent_type)
			return element
	return null

/// Returns the reagent typepaths of all 118 elements, in atomic order.
/proc/get_periodic_table_reagents()
	var/list/reagent_types = list()
	for(var/datum/periodic_element/element as anything in GLOB.periodic_table)
		reagent_types += element.reagent_type
	return reagent_types

/// Returns TRUE if this element was added by the periodic table module rather than by upstream.
/datum/periodic_element/proc/is_new_element()
	return ispath(reagent_type, /datum/reagent/element) || ispath(reagent_type, /datum/reagent/toxin/element) || ispath(reagent_type, /datum/reagent/uranium/element)

/// Returns TRUE for elements that have never been found in nature (americium onwards).
/datum/periodic_element/proc/is_synthetic()
	return number >= FIRST_SYNTHETIC_ELEMENT

/**
 * The new elements the standard chem dispenser adds to its menu: every natural element
 * this module added. Synthetic elements stay code-only, and upstream's own elements keep
 * their upstream availability (gold, silver, uranium, lead and polonium aren't dispensed).
 */
/proc/get_chem_dispenser_elements()
	var/static/list/dispenser_elements
	if(isnull(dispenser_elements))
		dispenser_elements = list()
		for(var/datum/periodic_element/element as anything in GLOB.periodic_table)
			if(element.is_new_element() && !element.is_synthetic())
				dispenser_elements += element.reagent_type
	return dispenser_elements

#define ELEMENT_ENTRY(number, symbol, name, weight, category, state, period, group, reagent) . += new /datum/periodic_element(number, symbol, name, weight, category, state, period, group, reagent)

/proc/init_periodic_table()
	. = list()
	ELEMENT_ENTRY(1, "H", "Hydrogen", 1.008, ELEMENT_CATEGORY_NONMETAL, ELEMENT_STATE_GAS, 1, 1, /datum/reagent/hydrogen)
	ELEMENT_ENTRY(2, "He", "Helium", 4.0026, ELEMENT_CATEGORY_NOBLE_GAS, ELEMENT_STATE_GAS, 1, 18, /datum/reagent/element/helium)
	ELEMENT_ENTRY(3, "Li", "Lithium", 6.94, ELEMENT_CATEGORY_ALKALI_METAL, ELEMENT_STATE_SOLID, 2, 1, /datum/reagent/lithium)
	ELEMENT_ENTRY(4, "Be", "Beryllium", 9.0122, ELEMENT_CATEGORY_ALKALINE_EARTH_METAL, ELEMENT_STATE_SOLID, 2, 2, /datum/reagent/toxin/element/beryllium)
	ELEMENT_ENTRY(5, "B", "Boron", 10.81, ELEMENT_CATEGORY_METALLOID, ELEMENT_STATE_SOLID, 2, 13, /datum/reagent/element/boron)
	ELEMENT_ENTRY(6, "C", "Carbon", 12.011, ELEMENT_CATEGORY_NONMETAL, ELEMENT_STATE_SOLID, 2, 14, /datum/reagent/carbon)
	ELEMENT_ENTRY(7, "N", "Nitrogen", 14.007, ELEMENT_CATEGORY_NONMETAL, ELEMENT_STATE_GAS, 2, 15, /datum/reagent/nitrogen)
	ELEMENT_ENTRY(8, "O", "Oxygen", 15.999, ELEMENT_CATEGORY_NONMETAL, ELEMENT_STATE_GAS, 2, 16, /datum/reagent/oxygen)
	ELEMENT_ENTRY(9, "F", "Fluorine", 18.998, ELEMENT_CATEGORY_HALOGEN, ELEMENT_STATE_GAS, 2, 17, /datum/reagent/fluorine)
	ELEMENT_ENTRY(10, "Ne", "Neon", 20.180, ELEMENT_CATEGORY_NOBLE_GAS, ELEMENT_STATE_GAS, 2, 18, /datum/reagent/element/neon)
	ELEMENT_ENTRY(11, "Na", "Sodium", 22.990, ELEMENT_CATEGORY_ALKALI_METAL, ELEMENT_STATE_SOLID, 3, 1, /datum/reagent/sodium)
	ELEMENT_ENTRY(12, "Mg", "Magnesium", 24.305, ELEMENT_CATEGORY_ALKALINE_EARTH_METAL, ELEMENT_STATE_SOLID, 3, 2, /datum/reagent/element/magnesium)
	ELEMENT_ENTRY(13, "Al", "Aluminium", 26.982, ELEMENT_CATEGORY_POST_TRANSITION_METAL, ELEMENT_STATE_SOLID, 3, 13, /datum/reagent/aluminium)
	ELEMENT_ENTRY(14, "Si", "Silicon", 28.085, ELEMENT_CATEGORY_METALLOID, ELEMENT_STATE_SOLID, 3, 14, /datum/reagent/silicon)
	ELEMENT_ENTRY(15, "P", "Phosphorus", 30.974, ELEMENT_CATEGORY_NONMETAL, ELEMENT_STATE_SOLID, 3, 15, /datum/reagent/phosphorus)
	ELEMENT_ENTRY(16, "S", "Sulfur", 32.06, ELEMENT_CATEGORY_NONMETAL, ELEMENT_STATE_SOLID, 3, 16, /datum/reagent/sulfur)
	ELEMENT_ENTRY(17, "Cl", "Chlorine", 35.45, ELEMENT_CATEGORY_HALOGEN, ELEMENT_STATE_GAS, 3, 17, /datum/reagent/chlorine)
	ELEMENT_ENTRY(18, "Ar", "Argon", 39.95, ELEMENT_CATEGORY_NOBLE_GAS, ELEMENT_STATE_GAS, 3, 18, /datum/reagent/element/argon)
	ELEMENT_ENTRY(19, "K", "Potassium", 39.098, ELEMENT_CATEGORY_ALKALI_METAL, ELEMENT_STATE_SOLID, 4, 1, /datum/reagent/potassium)
	ELEMENT_ENTRY(20, "Ca", "Calcium", 40.078, ELEMENT_CATEGORY_ALKALINE_EARTH_METAL, ELEMENT_STATE_SOLID, 4, 2, /datum/reagent/element/calcium)
	ELEMENT_ENTRY(21, "Sc", "Scandium", 44.956, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 4, 3, /datum/reagent/element/scandium)
	ELEMENT_ENTRY(22, "Ti", "Titanium", 47.867, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 4, 4, /datum/reagent/element/titanium)
	ELEMENT_ENTRY(23, "V", "Vanadium", 50.942, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 4, 5, /datum/reagent/element/vanadium)
	ELEMENT_ENTRY(24, "Cr", "Chromium", 51.996, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 4, 6, /datum/reagent/element/chromium)
	ELEMENT_ENTRY(25, "Mn", "Manganese", 54.938, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 4, 7, /datum/reagent/element/manganese)
	ELEMENT_ENTRY(26, "Fe", "Iron", 55.845, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 4, 8, /datum/reagent/iron)
	ELEMENT_ENTRY(27, "Co", "Cobalt", 58.933, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 4, 9, /datum/reagent/toxin/element/cobalt)
	ELEMENT_ENTRY(28, "Ni", "Nickel", 58.693, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 4, 10, /datum/reagent/element/nickel)
	ELEMENT_ENTRY(29, "Cu", "Copper", 63.546, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 4, 11, /datum/reagent/copper)
	ELEMENT_ENTRY(30, "Zn", "Zinc", 65.38, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 4, 12, /datum/reagent/element/zinc)
	ELEMENT_ENTRY(31, "Ga", "Gallium", 69.723, ELEMENT_CATEGORY_POST_TRANSITION_METAL, ELEMENT_STATE_SOLID, 4, 13, /datum/reagent/element/gallium)
	ELEMENT_ENTRY(32, "Ge", "Germanium", 72.630, ELEMENT_CATEGORY_METALLOID, ELEMENT_STATE_SOLID, 4, 14, /datum/reagent/element/germanium)
	ELEMENT_ENTRY(33, "As", "Arsenic", 74.922, ELEMENT_CATEGORY_METALLOID, ELEMENT_STATE_SOLID, 4, 15, /datum/reagent/toxin/element/arsenic)
	ELEMENT_ENTRY(34, "Se", "Selenium", 78.971, ELEMENT_CATEGORY_NONMETAL, ELEMENT_STATE_SOLID, 4, 16, /datum/reagent/toxin/element/selenium)
	ELEMENT_ENTRY(35, "Br", "Bromine", 79.904, ELEMENT_CATEGORY_HALOGEN, ELEMENT_STATE_LIQUID, 4, 17, /datum/reagent/bromine)
	ELEMENT_ENTRY(36, "Kr", "Krypton", 83.798, ELEMENT_CATEGORY_NOBLE_GAS, ELEMENT_STATE_GAS, 4, 18, /datum/reagent/element/krypton)
	ELEMENT_ENTRY(37, "Rb", "Rubidium", 85.468, ELEMENT_CATEGORY_ALKALI_METAL, ELEMENT_STATE_SOLID, 5, 1, /datum/reagent/element/rubidium)
	ELEMENT_ENTRY(38, "Sr", "Strontium", 87.62, ELEMENT_CATEGORY_ALKALINE_EARTH_METAL, ELEMENT_STATE_SOLID, 5, 2, /datum/reagent/element/strontium)
	ELEMENT_ENTRY(39, "Y", "Yttrium", 88.906, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 5, 3, /datum/reagent/element/yttrium)
	ELEMENT_ENTRY(40, "Zr", "Zirconium", 91.224, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 5, 4, /datum/reagent/element/zirconium)
	ELEMENT_ENTRY(41, "Nb", "Niobium", 92.906, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 5, 5, /datum/reagent/element/niobium)
	ELEMENT_ENTRY(42, "Mo", "Molybdenum", 95.95, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 5, 6, /datum/reagent/element/molybdenum)
	ELEMENT_ENTRY(43, "Tc", "Technetium", 98, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 5, 7, /datum/reagent/uranium/element/technetium)
	ELEMENT_ENTRY(44, "Ru", "Ruthenium", 101.07, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 5, 8, /datum/reagent/element/ruthenium)
	ELEMENT_ENTRY(45, "Rh", "Rhodium", 102.91, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 5, 9, /datum/reagent/element/rhodium)
	ELEMENT_ENTRY(46, "Pd", "Palladium", 106.42, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 5, 10, /datum/reagent/element/palladium)
	ELEMENT_ENTRY(47, "Ag", "Silver", 107.87, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 5, 11, /datum/reagent/silver)
	ELEMENT_ENTRY(48, "Cd", "Cadmium", 112.41, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 5, 12, /datum/reagent/toxin/element/cadmium)
	ELEMENT_ENTRY(49, "In", "Indium", 114.82, ELEMENT_CATEGORY_POST_TRANSITION_METAL, ELEMENT_STATE_SOLID, 5, 13, /datum/reagent/element/indium)
	ELEMENT_ENTRY(50, "Sn", "Tin", 118.71, ELEMENT_CATEGORY_POST_TRANSITION_METAL, ELEMENT_STATE_SOLID, 5, 14, /datum/reagent/element/tin)
	ELEMENT_ENTRY(51, "Sb", "Antimony", 121.76, ELEMENT_CATEGORY_METALLOID, ELEMENT_STATE_SOLID, 5, 15, /datum/reagent/toxin/element/antimony)
	ELEMENT_ENTRY(52, "Te", "Tellurium", 127.60, ELEMENT_CATEGORY_METALLOID, ELEMENT_STATE_SOLID, 5, 16, /datum/reagent/toxin/element/tellurium)
	ELEMENT_ENTRY(53, "I", "Iodine", 126.90, ELEMENT_CATEGORY_HALOGEN, ELEMENT_STATE_SOLID, 5, 17, /datum/reagent/iodine)
	ELEMENT_ENTRY(54, "Xe", "Xenon", 131.29, ELEMENT_CATEGORY_NOBLE_GAS, ELEMENT_STATE_GAS, 5, 18, /datum/reagent/element/xenon)
	ELEMENT_ENTRY(55, "Cs", "Caesium", 132.91, ELEMENT_CATEGORY_ALKALI_METAL, ELEMENT_STATE_SOLID, 6, 1, /datum/reagent/element/caesium)
	ELEMENT_ENTRY(56, "Ba", "Barium", 137.33, ELEMENT_CATEGORY_ALKALINE_EARTH_METAL, ELEMENT_STATE_SOLID, 6, 2, /datum/reagent/toxin/element/barium)
	ELEMENT_ENTRY(57, "La", "Lanthanum", 138.91, ELEMENT_CATEGORY_LANTHANIDE, ELEMENT_STATE_SOLID, 6, 0, /datum/reagent/element/lanthanum)
	ELEMENT_ENTRY(58, "Ce", "Cerium", 140.12, ELEMENT_CATEGORY_LANTHANIDE, ELEMENT_STATE_SOLID, 6, 0, /datum/reagent/element/cerium)
	ELEMENT_ENTRY(59, "Pr", "Praseodymium", 140.91, ELEMENT_CATEGORY_LANTHANIDE, ELEMENT_STATE_SOLID, 6, 0, /datum/reagent/element/praseodymium)
	ELEMENT_ENTRY(60, "Nd", "Neodymium", 144.24, ELEMENT_CATEGORY_LANTHANIDE, ELEMENT_STATE_SOLID, 6, 0, /datum/reagent/element/neodymium)
	ELEMENT_ENTRY(61, "Pm", "Promethium", 145, ELEMENT_CATEGORY_LANTHANIDE, ELEMENT_STATE_SOLID, 6, 0, /datum/reagent/uranium/element/promethium)
	ELEMENT_ENTRY(62, "Sm", "Samarium", 150.36, ELEMENT_CATEGORY_LANTHANIDE, ELEMENT_STATE_SOLID, 6, 0, /datum/reagent/element/samarium)
	ELEMENT_ENTRY(63, "Eu", "Europium", 151.96, ELEMENT_CATEGORY_LANTHANIDE, ELEMENT_STATE_SOLID, 6, 0, /datum/reagent/element/europium)
	ELEMENT_ENTRY(64, "Gd", "Gadolinium", 157.25, ELEMENT_CATEGORY_LANTHANIDE, ELEMENT_STATE_SOLID, 6, 0, /datum/reagent/element/gadolinium)
	ELEMENT_ENTRY(65, "Tb", "Terbium", 158.93, ELEMENT_CATEGORY_LANTHANIDE, ELEMENT_STATE_SOLID, 6, 0, /datum/reagent/element/terbium)
	ELEMENT_ENTRY(66, "Dy", "Dysprosium", 162.50, ELEMENT_CATEGORY_LANTHANIDE, ELEMENT_STATE_SOLID, 6, 0, /datum/reagent/element/dysprosium)
	ELEMENT_ENTRY(67, "Ho", "Holmium", 164.93, ELEMENT_CATEGORY_LANTHANIDE, ELEMENT_STATE_SOLID, 6, 0, /datum/reagent/element/holmium)
	ELEMENT_ENTRY(68, "Er", "Erbium", 167.26, ELEMENT_CATEGORY_LANTHANIDE, ELEMENT_STATE_SOLID, 6, 0, /datum/reagent/element/erbium)
	ELEMENT_ENTRY(69, "Tm", "Thulium", 168.93, ELEMENT_CATEGORY_LANTHANIDE, ELEMENT_STATE_SOLID, 6, 0, /datum/reagent/element/thulium)
	ELEMENT_ENTRY(70, "Yb", "Ytterbium", 173.05, ELEMENT_CATEGORY_LANTHANIDE, ELEMENT_STATE_SOLID, 6, 0, /datum/reagent/element/ytterbium)
	ELEMENT_ENTRY(71, "Lu", "Lutetium", 174.97, ELEMENT_CATEGORY_LANTHANIDE, ELEMENT_STATE_SOLID, 6, 0, /datum/reagent/element/lutetium)
	ELEMENT_ENTRY(72, "Hf", "Hafnium", 178.49, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 6, 4, /datum/reagent/element/hafnium)
	ELEMENT_ENTRY(73, "Ta", "Tantalum", 180.95, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 6, 5, /datum/reagent/element/tantalum)
	ELEMENT_ENTRY(74, "W", "Tungsten", 183.84, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 6, 6, /datum/reagent/element/tungsten)
	ELEMENT_ENTRY(75, "Re", "Rhenium", 186.21, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 6, 7, /datum/reagent/element/rhenium)
	ELEMENT_ENTRY(76, "Os", "Osmium", 190.23, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 6, 8, /datum/reagent/element/osmium)
	ELEMENT_ENTRY(77, "Ir", "Iridium", 192.22, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 6, 9, /datum/reagent/element/iridium)
	ELEMENT_ENTRY(78, "Pt", "Platinum", 195.08, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 6, 10, /datum/reagent/element/platinum)
	ELEMENT_ENTRY(79, "Au", "Gold", 196.97, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 6, 11, /datum/reagent/gold)
	ELEMENT_ENTRY(80, "Hg", "Mercury", 200.59, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_LIQUID, 6, 12, /datum/reagent/mercury)
	ELEMENT_ENTRY(81, "Tl", "Thallium", 204.38, ELEMENT_CATEGORY_POST_TRANSITION_METAL, ELEMENT_STATE_SOLID, 6, 13, /datum/reagent/toxin/element/thallium)
	ELEMENT_ENTRY(82, "Pb", "Lead", 207.2, ELEMENT_CATEGORY_POST_TRANSITION_METAL, ELEMENT_STATE_SOLID, 6, 14, /datum/reagent/lead)
	ELEMENT_ENTRY(83, "Bi", "Bismuth", 208.98, ELEMENT_CATEGORY_POST_TRANSITION_METAL, ELEMENT_STATE_SOLID, 6, 15, /datum/reagent/element/bismuth)
	ELEMENT_ENTRY(84, "Po", "Polonium", 209, ELEMENT_CATEGORY_POST_TRANSITION_METAL, ELEMENT_STATE_SOLID, 6, 16, /datum/reagent/toxin/polonium)
	ELEMENT_ENTRY(85, "At", "Astatine", 210, ELEMENT_CATEGORY_HALOGEN, ELEMENT_STATE_SOLID, 6, 17, /datum/reagent/uranium/element/astatine)
	ELEMENT_ENTRY(86, "Rn", "Radon", 222, ELEMENT_CATEGORY_NOBLE_GAS, ELEMENT_STATE_GAS, 6, 18, /datum/reagent/uranium/element/radon)
	ELEMENT_ENTRY(87, "Fr", "Francium", 223, ELEMENT_CATEGORY_ALKALI_METAL, ELEMENT_STATE_SOLID, 7, 1, /datum/reagent/uranium/element/francium)
	ELEMENT_ENTRY(88, "Ra", "Radium", 226, ELEMENT_CATEGORY_ALKALINE_EARTH_METAL, ELEMENT_STATE_SOLID, 7, 2, /datum/reagent/uranium/radium)
	ELEMENT_ENTRY(89, "Ac", "Actinium", 227, ELEMENT_CATEGORY_ACTINIDE, ELEMENT_STATE_SOLID, 7, 0, /datum/reagent/uranium/element/actinium)
	ELEMENT_ENTRY(90, "Th", "Thorium", 232.04, ELEMENT_CATEGORY_ACTINIDE, ELEMENT_STATE_SOLID, 7, 0, /datum/reagent/uranium/element/thorium)
	ELEMENT_ENTRY(91, "Pa", "Protactinium", 231.04, ELEMENT_CATEGORY_ACTINIDE, ELEMENT_STATE_SOLID, 7, 0, /datum/reagent/uranium/element/protactinium)
	ELEMENT_ENTRY(92, "U", "Uranium", 238.03, ELEMENT_CATEGORY_ACTINIDE, ELEMENT_STATE_SOLID, 7, 0, /datum/reagent/uranium)
	ELEMENT_ENTRY(93, "Np", "Neptunium", 237, ELEMENT_CATEGORY_ACTINIDE, ELEMENT_STATE_SOLID, 7, 0, /datum/reagent/uranium/element/neptunium)
	ELEMENT_ENTRY(94, "Pu", "Plutonium", 244, ELEMENT_CATEGORY_ACTINIDE, ELEMENT_STATE_SOLID, 7, 0, /datum/reagent/uranium/element/plutonium)
	ELEMENT_ENTRY(95, "Am", "Americium", 243, ELEMENT_CATEGORY_ACTINIDE, ELEMENT_STATE_SOLID, 7, 0, /datum/reagent/uranium/element/americium)
	ELEMENT_ENTRY(96, "Cm", "Curium", 247, ELEMENT_CATEGORY_ACTINIDE, ELEMENT_STATE_SOLID, 7, 0, /datum/reagent/uranium/element/curium)
	ELEMENT_ENTRY(97, "Bk", "Berkelium", 247, ELEMENT_CATEGORY_ACTINIDE, ELEMENT_STATE_SOLID, 7, 0, /datum/reagent/uranium/element/berkelium)
	ELEMENT_ENTRY(98, "Cf", "Californium", 251, ELEMENT_CATEGORY_ACTINIDE, ELEMENT_STATE_SOLID, 7, 0, /datum/reagent/uranium/element/californium)
	ELEMENT_ENTRY(99, "Es", "Einsteinium", 252, ELEMENT_CATEGORY_ACTINIDE, ELEMENT_STATE_SOLID, 7, 0, /datum/reagent/uranium/element/einsteinium)
	ELEMENT_ENTRY(100, "Fm", "Fermium", 257, ELEMENT_CATEGORY_ACTINIDE, ELEMENT_STATE_SOLID, 7, 0, /datum/reagent/uranium/element/fermium)
	ELEMENT_ENTRY(101, "Md", "Mendelevium", 258, ELEMENT_CATEGORY_ACTINIDE, ELEMENT_STATE_SOLID, 7, 0, /datum/reagent/uranium/element/mendelevium)
	ELEMENT_ENTRY(102, "No", "Nobelium", 259, ELEMENT_CATEGORY_ACTINIDE, ELEMENT_STATE_SOLID, 7, 0, /datum/reagent/uranium/element/nobelium)
	ELEMENT_ENTRY(103, "Lr", "Lawrencium", 266, ELEMENT_CATEGORY_ACTINIDE, ELEMENT_STATE_SOLID, 7, 0, /datum/reagent/uranium/element/lawrencium)
	ELEMENT_ENTRY(104, "Rf", "Rutherfordium", 267, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 7, 4, /datum/reagent/uranium/element/rutherfordium)
	ELEMENT_ENTRY(105, "Db", "Dubnium", 268, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 7, 5, /datum/reagent/uranium/element/dubnium)
	ELEMENT_ENTRY(106, "Sg", "Seaborgium", 269, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 7, 6, /datum/reagent/uranium/element/seaborgium)
	ELEMENT_ENTRY(107, "Bh", "Bohrium", 270, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 7, 7, /datum/reagent/uranium/element/bohrium)
	ELEMENT_ENTRY(108, "Hs", "Hassium", 269, ELEMENT_CATEGORY_TRANSITION_METAL, ELEMENT_STATE_SOLID, 7, 8, /datum/reagent/uranium/element/hassium)
	ELEMENT_ENTRY(109, "Mt", "Meitnerium", 278, ELEMENT_CATEGORY_UNKNOWN, ELEMENT_STATE_UNKNOWN, 7, 9, /datum/reagent/uranium/element/meitnerium)
	ELEMENT_ENTRY(110, "Ds", "Darmstadtium", 281, ELEMENT_CATEGORY_UNKNOWN, ELEMENT_STATE_UNKNOWN, 7, 10, /datum/reagent/uranium/element/darmstadtium)
	ELEMENT_ENTRY(111, "Rg", "Roentgenium", 282, ELEMENT_CATEGORY_UNKNOWN, ELEMENT_STATE_UNKNOWN, 7, 11, /datum/reagent/uranium/element/roentgenium)
	ELEMENT_ENTRY(112, "Cn", "Copernicium", 285, ELEMENT_CATEGORY_UNKNOWN, ELEMENT_STATE_UNKNOWN, 7, 12, /datum/reagent/uranium/element/copernicium)
	ELEMENT_ENTRY(113, "Nh", "Nihonium", 286, ELEMENT_CATEGORY_UNKNOWN, ELEMENT_STATE_UNKNOWN, 7, 13, /datum/reagent/uranium/element/nihonium)
	ELEMENT_ENTRY(114, "Fl", "Flerovium", 289, ELEMENT_CATEGORY_UNKNOWN, ELEMENT_STATE_UNKNOWN, 7, 14, /datum/reagent/uranium/element/flerovium)
	ELEMENT_ENTRY(115, "Mc", "Moscovium", 290, ELEMENT_CATEGORY_UNKNOWN, ELEMENT_STATE_UNKNOWN, 7, 15, /datum/reagent/uranium/element/moscovium)
	ELEMENT_ENTRY(116, "Lv", "Livermorium", 293, ELEMENT_CATEGORY_UNKNOWN, ELEMENT_STATE_UNKNOWN, 7, 16, /datum/reagent/uranium/element/livermorium)
	ELEMENT_ENTRY(117, "Ts", "Tennessine", 294, ELEMENT_CATEGORY_UNKNOWN, ELEMENT_STATE_UNKNOWN, 7, 17, /datum/reagent/uranium/element/tennessine)
	ELEMENT_ENTRY(118, "Og", "Oganesson", 294, ELEMENT_CATEGORY_UNKNOWN, ELEMENT_STATE_UNKNOWN, 7, 18, /datum/reagent/uranium/element/oganesson)

#undef ELEMENT_ENTRY
