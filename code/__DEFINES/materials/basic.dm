// Basic and tier-0 materials. These are typically of the lowest value, and the simplest/purest elements.

#define MAT_hydro "h2"
/datum/mat/hydrogen
	id = MAT_hydro
	name = "Hydrogen"
	specific_heat = 300
	state = GAS
	value = 10
	desc = "A highly combustible, colourless, odorless, gas."

#define MAT_liq_hydro "liq_h2"
/datum/mat/hydrogen/liquid
	id = MAT_liq_hydro
	state = LIQUID
	desc = "A highly flammable, colourless, cryogenic liquid."

#define MAT_oxy "o2"
/datum/mat/oxygen
	id = MAT_oxy
	name = "Oxygen"
	state = GAS
	value = 5
	desc = "A highly reactive, colourless, odorless, gas."
	color = "#CCCCFF" // Periwinkle Blue
	alpha = 8 // at ultra-high pressures you might be able to see it.

#define MAT_liq_oxy "liq_o2"
/datum/mat/oxygen/liquid
	id = MAT_liq_oxy
	state = LIQUID
	value = 5
	desc = "A highly reactive, cryogenic liquid."
	alpha = 128

// Water Stuff //

#define MAT_gas_h2o "gas_h2o"
/datum/mat/water/gas
	id = MAT_gas_h2o
	name = "Steam"
	state = PLASMA
	desc = "A scalding gas produced by boiling water."
	color = "#EEEEEE"
	alpha = 16

#define MAT_h2o "h2o"
/datum/mat/water
	id = MAT_h2o
	name = "Water"
	specific_heat = 80
	state = LIQUID
	value = 5
	desc = "A wettening thirst-quenching substance like none ever seen before!"
	color = "#AAAABB"
	alpha = 64

#define MAT_sol_h2o "sol_h2o"
/datum/mat/water/solid
	id = MAT_sol_h2o
	name = "Ice"
	state = SOLID
	desc = "A cold material produced by freezing water."
	color = "#EEEEFF"
	alpha = 255
	robustness = 5

// Carbon Stuff //

#define MAT_carbon "carbon"
/datum/mat/carbon
	id = MAT_carbon
	name = "Carbon"
	state = SOLID
	value = 5
	desc = "The building block of life as we know it. It's quite reactive."
	color = "#333333"
	alpha = 255

#define MAT_co2 "co2"
/datum/mat/carbon_dioxide
	id = MAT_co2
	name = "Carbon Dioxide"
	state = GAS
	value = 1
	desc = "An extremely inert, toxic, colourless gas produced by the oxidization of organic material."
	color = "#808080"
	alpha = 0

#define MAT_sol_co2 "sol_co2"
/datum/mat/carbon_dioxide/solid
	id = MAT_sol_co2
	state = SOLID
	value = 1
	desc = "The solid form of carbon dioxide. It is frequently used as a refrigerant."
	color = "#FFFFFF"
	alpha = 255

#define MAT_co1 "co1"
/datum/mat/carbon_monoxide
	id = MAT_co1
	name = "Carbon Monoxide"
	state = GAS
	value = 1
	desc = "An extremely toxic, colourless gas produced by the partial oxidization of organic material."
	color = "#808080"
	alpha = 0

// Nitrogen Stuff //

#define MAT_nitro "n2"
/datum/mat/nitrogen
	id = MAT_nitro
	name = "Nitrogen"
	state = GAS
	value = 1 // Pretty much worthless.
	desc = "An extremely inert, colourless gas."
	color = "#808080"
	alpha = 0

#define MAT_liq_nitro "liq_n2"
/datum/mat/nitrogen/liquid
	id = MAT_liq_nitro
	state = LIQUID
	value = 1
	desc = "An extremely inert, colourless, cryogenic liquid."

#define MAT_n2o "n2o"
/datum/mat/nitrous_oxide
	id = MAT_n2o
	name = "Nitrous Oxide"
	state = PLASMA
	value = 2
	desc = "Typically used as a medical anaesthetic. At high temperatures it becomes an oxidizer."
	color = "#808080"
	alpha = 0

#define MAT_nitroxy "no"
/datum/mat/nitric_oxide
	id = MAT_nitroxy
	name = "Nitric Oxide"
	state = PLASMA
	value = 2
	desc = "Not to be confused with nitrous oxide. It is a toxic and weakly oxidizing substance."
	color = "#808080"
	alpha = 0

#define MAT_nitroxy2 "no2"
/datum/mat/nitro_dioxide
	id = MAT_nitroxy2
	name = "Nitrogen Dioxide"
	state = PLASMA
	value = 3
	desc = "Not to be confused with nitrous oxide. It is a toxic and oxidizing substance."
	color = "#883300"
	alpha = 192

#define MAT_liq_nitroxy2 "liq_no2"
/datum/mat/nitro_dioxide/liquid
	id = MAT_liq_nitroxy2
	name = "Nitrogen Dioxide"
	state = LIQUID
	value = 3
	desc = "Not to be confused with nitrous oxide. It is a toxic and oxidizing substance."
	color = "#883300"
	alpha = 192

#define MAT_nitroxy4 "n2o4"
/datum/mat/nitro_dioxide/plus
	id = MAT_nitroxy4
	name = "Dinitrogen Tetroxide"
	state = LIQUID
	value = 5
	desc = "Not to be confused with nitrous oxide. It is a toxic and powerful oxidizing substance."
	color = "#883300"
	alpha = 192

// Misc Stuff //

#define MAT_flourine "flourine"
/datum/mat/flourine
	id = MAT_flourine
	name = "Flourine"
	state = PLASMA
	value = 2
	desc = "An extremely reactive, toxic, pale yellow gas."
	color = "#DDEE88"
	alpha = 128

#define MAT_liq_flourine "liq_flourine"
/datum/mat/flourine/liquid
	id = MAT_liq_flourine
	state = LIQUID
	value = 2
	desc = "An extremely reactive, toxic, pale yellow fluid."

#define MAT_chlorine "chlorine"
/datum/mat/chlorine
	id = MAT_chlorine
	name = "Chlorine"
	state = PLASMA
	value = 2
	desc = "An highly reactive, toxic, pale yellow gas."
	color = "#DDEE88"
	alpha = 64

#define MAT_liq_chlorine "liq_chlorine"
/datum/mat/chlorine/liquid
	id = MAT_liq_chlorine
	state = LIQUID
	value = 2
	desc = "An highly reactive, toxic, pale yellow fluid."

#define MAT_iodine "iodine"
/datum/mat/iodine
	id = MAT_iodine
	name = "Iodine"
	specific_heat = 30
	state = PLASMA
	value = 2
	desc = "A vibrantly coloured purple gas." // Can be used for plasma memes.
	color = "#BB22CC"
	alpha = 192

#define MAT_sol_iodine "sol_iodine"
/datum/mat/iodine/solid
	id = MAT_sol_iodine
	state = SOLID
	value = 2
	desc = "A lustrous metallic element."
	color = "#444444"
	alpha = 255
	robustness = 25

#define MAT_helium "helium"
/datum/mat/helium
	id = MAT_helium
	name = "Helium"
	state = GAS
	value = 1
	desc = "An extremely inert, colourless gas."
	color = "#808080"
	alpha = 0

#define MAT_liq_helium "liq_helium"
/datum/mat/helium/liquid
	id = MAT_liq_helium
	state = LIQUID
	value = 1
	desc = "An extremely inert, colourless, cryogenic liquid."

#define MAT_potass "potass"
/datum/mat/potassium
	id = MAT_potass
	name = "Potassium"
	state = SOLID
	value = 5
	desc = "A dull and highly reactive metallic element."
	color = "#BBBBBB"
	alpha = 255

#define MAT_sodium "sodium"
/datum/mat/sodium
	id = MAT_sodium
	name = "Sodium"
	state = SOLID
	value = 5
	desc = "A dull and highly reactive metallic element."
	color = "#BBBBBB"
	alpha = 255

#define MAT_silicon "silicon"
/datum/mat/silicon
	id = MAT_silicon
	name = "Silicon"
	state = SOLID
	value = 1
	desc = "A very common semi-conductive material useful in electronic components."
	color = "#777777"
	alpha = 255

#define MAT_sulfur "sulfur"
/datum/mat/sulfur
	id = MAT_sulfur
	name = "Sulfur"
	state = SOLID
	value = 5
	desc = "A highly reactive, foul smelling substance."
	color = "#FFEE55"
	alpha = 255

#define MAT_phosphor "phosphorous"
/datum/mat/phosphorous
	id = MAT_phosphor
	name = "Phosphorous"
	state = SOLID
	value = 5
	desc = "A highly reactive, glowing material."
	color = "#FFEE55" // White-ish
	alpha = 255

#define MAT_lithium "lithium"
/datum/mat/lithium
	id = MAT_lithium
	name = "Lithium"
	state = SOLID
	value = 5
	desc = "A highly reactive, dull metallic substance."
	color = "#BBBBBB"
	alpha = 255

#define MAT_calcium "calcium"
/datum/mat/calcium
	id = MAT_calcium
	name = "Calcium"
	state = SOLID
	value = 2
	desc = "A highly reactive, material that can be found in many minerals and animal tissues."
	color = "#FFFFFF"
	alpha = 255

#define MAT_radium "radium"
/datum/mat/radium
	id = MAT_radium
	name = "Radium"
	state = SOLID
	value = 5
	desc = "A highly reactive and radioactive glowing material."
	color = "#BBFFBB"
	alpha = 255

#define MAT_magnesium "magnesium"
/datum/mat/magnesium
	id = MAT_magnesium
	name = "Magnesium"
	state = SOLID
	value = 2
	desc = "A highly reactive metal. It is capable of burning even without oxygen."
	color = "#BBBBBB"
	alpha = 255