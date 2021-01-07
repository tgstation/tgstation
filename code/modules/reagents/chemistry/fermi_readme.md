# How to make fermi reactions from a code perspective

## How purity works

Purity by default only splits on a mob’s consumption unless reaction_flags in the recipe is set to one of the CLEAR_CONVERT defines. Here is a bad flowchart for the on mob process.

I am not good at flowcharts sorry.

![image](https://user-images.githubusercontent.com/33956696/103941231-78123b80-5126-11eb-9d89-635a6b810454.png)

Essentially
For purity:
If 1: normal
If above inverse_chem_val: normal + impure
If below: inverse

## How reactions mechanics work

For the effects starting/during/at the end of a reaction see below:

![image](https://user-images.githubusercontent.com/33956696/103941281-88c2b180-5126-11eb-8740-207dc9bb830d.png)

Maybe this makes no sense.

In brief:

Holder.dm now sets up reactions, while equilibrium.dm runs them. Holder itself is processed when there is a list of reactions, but the equilibrium does the calculating. In essence, it holds onto a list of objects to run. Handle_reactions() is used to update the reaction list, with a few checks at the start to prevent any unnecessary updates.

When a reaction is detected:
If it’s REACTION_INSTANT then it’ll use a method similar to the old mechanics.
If not then it’ll set up an equilibrium, which checks to see if the reaction is valid on creation.
If it’s valid, then on_reaction is called.
If the reaction’s temperature is over the overheatTemp overheated() is called
When equilibriums detect they’re invalid, they flag for deletion and holder.dm deletes them.
If there’s a list of reactions, then the holder starts processing.

When holder is processing:
Each equilibrium is processed, and it handles it’s own reaction. For each step it handles every reaction.
At the start, the equilibrium checks it’s conditions and calculates how much it can make in this step.
It checks the temp, reagents and catalyst.
If it’s overheated, call overheated()
If it’s too impure call overly_impure()
The offset of optimal pH and temp is calculated, and these correlate with purity and yield.


When one of the checks fails in the equilibrium object, it is flagged for deletion. The holder will detect this and call reaction_finish() and delete the equilibrium object – ending that reaction.

## Recipe and processing mechanics

Lets go over the reaction vars below
``` 	var/required_temp			= 100
    var/OptimalTempMax			= 500			// Upper end for above
	var/overheatTemp 			= 900 			// Temperature at which reaction explodes - If any reaction is this hot, it explodes!
	var/OptimalpHMin 			= 5         	// Lowest value of pH determining pH a 1 value for pH based rate reactions (Plateu phase)
	var/OptimalpHMax 			= 9	        	// Higest value for above
	var/ReactpHLim 				= 4         	// How far out pH wil react, giving impurity place (Exponential phase)
	var/CurveSharpT 			= 2         	// How sharp the temperature exponential curve is (to the power of value)
	var/CurveSharppH 			= 1         	// How sharp the pH exponential curve is (to the power of value)
	var/ThermicConstant 		= 1         	// Temperature change per 1u produced
	var/HIonRelease 			= 0.01       	// pH change per 1u reaction
	var/RateUpLim 				= 20			// Optimal/max rate possible if all conditions are perfect
	var/PurityMin 				= 0.15 			// If purity is below 0.15, it calls OverlyImpure() too. Set to 0 to disable this.
	var/reactionFlags							// bitflags for clear conversions; REACTION_CLEAR_IMPURE, REACTION_CLEAR_INVERSE, REACTION_CLEAR_RETAIN, REACTION_INSTANT```

The amount added is based off the recipies’ required_temp, OptimalTempMax, overheatTemp and CurveSharpT. See below:
![image](https://user-images.githubusercontent.com/33956696/103941344-9d06ae80-5126-11eb-951d-aa5302641eb9.png)

The purity is calculated using the OptimalpHMin OptimalpHMax, ReactpHLim and CurveSharppH. See Below:
![image](https://user-images.githubusercontent.com/33956696/103941429-bc054080-5126-11eb-856d-7965c2a9cb1f.png)

Finally the ThermicConstant is how much the temperature changes per u created. The HIonRelease is how much the pH changes per u created. During a reaction this is the only factor in pH changes. The RateUpLim is the maximum rate the reaction can go at optimal temperatures.

PurityMin will set when overly_impure is called – if the purity of the product is below this value it will call overly_impure. In addition, on the end of a reaction, by default reaction_finish() will convert any products below the PurityMin into the product’s failed_chem.

Reaction_flags can be used to set these defines:
``` #define REACTION_CLEAR_IMPURE   //Convert into impure/pure on reaction completion
#define REACTION_CLEAR_INVERSE     //Convert into inverse on reaction completion when purity is low enough
#define REACTION_CLEAR_RETAIN	//Clear converted chems retain their purities/inverted purities. Requires 1 or both of the above.
#define REACTION_INSTANT          //Used to create instant reactions```

For REACTION_CLEAR – this causes the purity mechanics to resolve in the beaker at the end of the reaction, instead of when added to a mob.

Is_cold_recipie requires you to set your overheatTemp and OptimalTempMax descend instead.
Eg:
```var/required_temp			= 300
var/OptimalTempMax			= 200
#var/overheatTemp 			= 50 ```

## Reagents
The new vars that are introduced are below:
```
	/// pH of the reagent
	var/pH = 7
	///Purity of the reagent
	var/purity = 1
	///the purity of the reagent on creation (i.e. when it's added to a mob and it's purity split it into 2 chems; the purity of the resultant chems are kept as 1, this tracks what the purity was before that)
	var/creation_purity = 1	var/chemical_flags 
	//impure chem values (see fermi_readme.dm for more details):
	var/impure_chem		 = /datum/reagent/impure			// What chemical path is made when metabolised as a function of purity
	var/inverse_chem_val = 0.2								// If the impurity is below 0.5, replace ALL of the chem with inverse_chem upon metabolising
	var/inverse_chem	 = /datum/reagent/impure/toxic		// What chem is metabolised when purity is below inverse_chem_val
	var/failed_chem		 = /datum/reagent/consumable/failed_reaction //what chem is made at the end of a reaction IF the purity is below the recipies PurityMin
var/chemical_flags ```

When writing any reagent code ALWAYS use creation_purity. Purity is kept for internal mechanics only and won’t reflect the purity on creation.

See above for purity mechanics, but this is where you set the reagents that are created. If you’re making an impure reagent I recommend looking at impure_reagents.dm to see how they’re set up.

The flags you can set for var/chemical_flags are:
``` #define REAGENT_DEAD_PROCESS		(1<<0)	//allows on_mob_dead() if present in a dead body
#define REAGENT_DONOTSPLIT			(1<<1)	//Do not split the chem at all during processing - ignores all purity effects
#define REAGENT_INVISIBLE			(1<<2)	//Doesn't appear on handheld health analyzers.
#define REAGENT_SNEAKYNAME          (1<<3)  //When inverted, the inverted chem uses the name of the original chem
#define REAGENT_SPLITRETAINVOL      (1<<4)  //Retains initial volume of chem when splitting for purity effects ```
