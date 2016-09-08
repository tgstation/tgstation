// Basic Plasma Materials.

// Plasma (CP4), it has similar properties as to methane (CH4) but is much more dangerous.
// It burns at 10,000C, but isn't anywhere near as dangerous or reactive as purified plasma.
#define MAT_plasma "plasma"
/datum/mat/plasma
	id = MAT_plasma
	name = "Plasma"
	specific_heat = 6000 // fuck.
	state = PLASMA
	value = 50 // Sell this shit.
	desc = "An extremely flammable, toxic, and reactive purple gas known to interact with bluespace."
	color = "#BB22CC"
	alpha = 255

#define MAT_liq_plasma "liq_plasma"
/datum/mat/plasma/liquid
	id = MAT_liq_plasma
	state = LIQUID
	desc = "An extremely flammable, toxic, and reactive purple fluid known to interact with bluespace."

#define MAT_sol_plasma "sol_plasma"
/datum/mat/plasma/solid
	id = MAT_sol_plasma
	state = SOLID
	desc = "An extremely flammable, toxic, and reactive purple material known to interact with bluespace."
	robustness = 50 // Not very sound, structurally. But you could use it.

// Pure Plasma Gas (P2), it has similar properties as to hydrogen (H2) but is much more dangerous.
// Reacts with oxygen to make a really big boom. Autoignites at 400C. It burns at temperatures high enough to achieve fusion of some materials.
#define MAT_pure_plasma "pure_plasma"
/datum/mat/pure_plasma
	id = MAT_pure_plasma
	name = "Enriched Plasma"
	specific heat = 6000
	state = PLASMA
	value = 50
	desc = "An extremely volatile and explosive gas."
	color = "#BB22CC"
	alpha = 255

// Plasma-Hydrogen Gas. Still dangerous, just not AS dangerous. It's also good for stretching out your resources.
#define MAT_hplasma "hplasma"
/datum/mat/hypoplasma
	id = MAT_hplasma
	name = "Hydroplasma"
	specific_heat = 3000 // still fuck.
	state = PLASMA
	value = 35 // Sell this shit.
	desc = "A highly flammable, toxic, and reactive purple gas known to interact with bluespace. It's been partially stabilized using hydrogen."
	color = "#BB22CC"
	alpha = 255

#define MAT_liq_hplasma "liq_hplasma"
/datum/mat/hypoplasma/liquid
	id = MAT_liq_hplasma
	state = LIQUID
	desc = "An extremely flammable, toxic, and reactive purple fluid known to interact with bluespace. It's been partially stabilized using hydrogen."

#define MAT_sol_hplasma "sol_hplasma"
/datum/mat/hypoplasma/solid
	id = MAT_sol_hplasma
	state = SOLID
	desc = "An extremely flammable, toxic, and reactive purple material known to interact with bluespace. It's been partially stabilized using hydrogen."
	robustness = 25

// Oxy-Xilide (using 'xil' for temporary plasma-chemical nomenclature.) It's 'water' made from plasma. Extremely corrosive, reasonably stable chemical used in xil-x chemical production.
#define MAT_p2o "oxyxil"
/datum/mat/oxyxilide
	id = MAT_p2o
	name = "Superheated Xiloxide"
	specific_heat = 400
	state = GAS
	value = 25 // Sell this shit.
	desc = "A highly toxic and corrosive substance created by oxidizing plasma under very specific conditions. It'll melt your face."
	color = "#BB22CC"
	alpha = 128

#define MAT_liq_p2o "liq_oxyxil"
/datum/mat/oxyxilide/liquid
	id = MAT_liq_p2o
	name = "Xiloxide"
	state = LIQUID

#define MAT_sol_p2o "sol_oxyxil"
/datum/mat/oxyxilide/solid
	id = MAT_sol_p2o
	name = "Xiloxide"
	state = SOLID
	robustness = 10

// Hypoxy-Xilide. It's water made from hypoplasma. Extemely corrosive, extremely stable. Very useful for creating plasma-chemicals, though of a shittier-grade.
#define MAT_hpo "hoxyxil"
/datum/mat/hypoxyxilide
	id = MAT_hpo
	name = "Superheated Hydroxiloxide"
	specific_heat = 200
	state = GAS
	value = 15 // Sell this shit.
	desc = "A highly toxic and corrosive substance created by oxidizing hypoplasma under very specific conditions. It'll melt your face."
	color = "#BB22CC"
	alpha = 128

#define MAT_liq_hpo "liq_hoxyxil"
/datum/mat/hypoxyxilide/liquid
	id = MAT_liq_hpo
	name = "Hydroxiloxide"
	state = LIQUID

#define MAT_sol_hpo "sol_hoxyxil"
/datum/mat/hypoxyxilide/solid
	id = MAT_sol_hpo
	name = "Hydroxiloxide"
	state = SOLID
	robustness = 5

// Plasma-Alloys. Both are worth substantially more than the standard materials, and are much more durable as well.
#define MAT_plasteel "plasteel"
/datum/mat/plasteel
	id = MAT_plasteel
	name = "Plasteel"
	specific_heat = 1000 // Heats up very slowly.
	state = SOLID
	value = 10 // You lose a lot of value in the alloying process.
	desc = "An extremely durable metal-plasma alloy. Despite being made from plasma, it's quite flame resistant."
	color = "#777788"
	alpha = 255
	robustness = 500 // Five times as strong as pure iron.

#define MAT_plastitanium "plastitanium"
/datum/mat/plastitanium
	id = MAT_plastitanium
	name = "Plastitanium"
	specific_heat = 1000 // Heats up very slowly.
	state = SOLID
	value = 15 // You lose a lot of value in the alloying process.
	desc = "An extremely durable titanium-plasma alloy. Despite being made from plasma, it's quite flame resistant."
	color = "#555566"
	alpha = 255
	robustness = 500

#define MAT_hypersteel "hypersteel"
/datum/mat/hypersteel
	id = MAT_hypersteel
	name = "Hypersteel"
	specific_heat = 10000 // Heats up extremely slowly.
	state = SOLID
	value = 50 // You lose a lot of value in the alloying process.
	desc = "An extremely durable metal-hypercrystal alloy. Despite being made from supermatter crystals, it's extremely flame resistant."
	color = "#883333"
	alpha = 255
	robustness = 2500 // Five times as strong as pure plasteel.

#define MAT_hypertitanium "hypertitanium"
/datum/mat/hypertitanium
	id = MAT_hypertitanium
	name = "Hypertitanium"
	specific_heat = 10000 // Heats up extremely slowly.
	state = SOLID
	value = 55 // You lose a bit of value in the alloying process.
	desc = "An extremely durable titanium-hypercrystal alloy. Despite being made from supermatter crystals, it's extremely flame resistant."
	color = "#334488"
	alpha = 255
	robustness = 2500

// A Precursor to growing your own supermatter shard! It's ridiculously difficult and dangerous to make. You will die.
#define MAT_hyperplasma "hyperplasma"
/datum/mat/hyperplasma
	id = MAT_hyperplasma
	name = "Hyperplasma"
	specific_heat = 6000 // fuck.
	state = PLASMA
	value = 250 // It's worth a lot more when it condenses.
	desc = "An extremely unstable, radioactive, and hyper-reactive yellow vapour known to interact with bluespace."
	color = "#FFDD00"
	alpha = 255

// If you somehow manage to collect hyperplasma and cool it without dying, you'll have some pretty little yellow crystals growing.
#define MAT_supermatter "supermatter"
/datum/mat/hyperplasma/crystal
	id = MAT_supermatter
	name = "Supermatter Crystals"
	specific_heat = 300 // Lol.
	value = 500 // Sell this shit.
	state = SOLID
	desc = "An extremely unstable, radioactive, and hyper-reactive yellow crystal."
	robustness = 100 // About as strong as iron. I wouldn't recommend using it though.