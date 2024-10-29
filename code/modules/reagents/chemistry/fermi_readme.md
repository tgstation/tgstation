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

# How reactions mechanics work

For the effects starting/during/at the end of a reaction see below:

![image](https://user-images.githubusercontent.com/33956696/103941281-88c2b180-5126-11eb-8740-207dc9bb830d.png)

Maybe this makes no sense.

In brief:

Holder.dm now sets up reactions, while equilibrium.dm runs them. Holder itself is processed when there is a list of reactions, but the equilibrium does the calculating. In essence, it holds onto a list of objects to run. Handle_reactions() is used to update the reaction list, with a few checks at the start to prevent any unnecessary updates.

#### When a reaction is detected:
- If it’s REACTION_INSTANT then it’ll use a method similar to the old mechanics.
- If not then it’ll set up an equilibrium, which checks to see if the reaction is valid on creation.
- If it’s valid, then on_reaction is called.
- If the reaction’s temperature is over the overheat_temp overheated() is called
- When equilibriums detect they’re invalid, they flag for deletion and holder.dm deletes them.
- If there’s a list of reactions, then the holder starts processing.

#### When holder is processing:
- Each equilibrium is processed, and it handles it’s own reaction. For each step it handles every reaction.
- At the start, the equilibrium checks it’s conditions and calculates how much it can make in this step.
- It checks the temp, reagents and catalyst.
- If it’s overheated, call overheated()
- If it’s too impure call overly_impure()
- The offset of optimal pH and temp is calculated, and these correlate with purity and yield.

#### How a holder stops reacting:
When one of the checks fails in the equilibrium object, it is flagged for deletion. The holder will detect this and call reaction_finish() and delete the equilibrium object – ending that reaction.

## Recipe and processing mechanics

Lets go over the reaction vars below. These can be edited and set on a per chemical_reaction basis
```dm
/datum/chemical_reaction
	...
    var/required_temp			= 100
    var/optimal_temp			= 500			// Upper end for above
	var/overheat_temp 			= 900 			// Temperature at which reaction explodes - If any reaction is this hot, it procs overheated()
	var/optimal_ph_min 			= 5         	// Lowest value of pH determining pH a 1 value for pH based rate reactions (Plateu phase)
	var/optimal_ph_max 			= 9	        	// Higest value for above
	var/determin_ph_range 		= 4         	// How far out pH wil react, giving impurity place (Exponential phase)
	var/temp_exponent_factor 	= 2         	// How sharp the temperature exponential curve is (to the power of value)
	var/ph_exponent_factor 		= 1         	// How sharp the pH exponential curve is (to the power of value)
	var/thermic_constant		= 1         	// Temperature change per 1u produced
	var/H_ion_release 			= 0.01       	// pH change per 1u reaction
	var/rate_up_lim 			= 20			// Optimal/max rate possible if all conditions are perfect
	var/purity_min 				= 0.15 			// If purity is below 0.15, it calls OverlyImpure() too. Set to 0 to disable this.
	var/reaction_flags							// bitflags for clear conversions; REACTION_CLEAR_IMPURE, REACTION_CLEAR_INVERSE, REACTION_CLEAR_RETAIN, REACTION_INSTANT
```

### How temperature ranges are set and how reaction rate is determined

Reaction rates are determined by the current temperature of the reagents holder. There are a few variables related to this:

```dm
/datum/chemical_reaction
    var/required_temp			= 100
    var/optimal_temp			= 500			// Upper end for above
	var/overheat_temp 			= 900 			// Temperature at which reaction explodes - If any reaction is this hot, it procs overheated()
	var/temp_exponent_factor 	= 2         	// How sharp the temperature exponential curve is (to the power of value)
	var/rate_up_lim 			= 20			// Optimal/max rate possible if all conditions are perfect
```

The amount added is based off the recipies’ required_temp, optimal_temp, overheat_temp and temp_exponent_factor. See below:
![image](https://user-images.githubusercontent.com/33956696/104081088-5e571e00-5224-11eb-8834-87aa36b3e45f.png)

the y axis is the normalised value of growth, which is then muliplied by the rate_up_lim. You can see that temperatures below the required_temp produce no result (the reaction doesn't start, or if it is reacting, the reaction will stop). Between the required and optimal is a region that is defined by the temp_exponent_factor, so in this case the value is ^2, so we see exponential growth. Between the optimal_temp and the overheat_temp is the optimal phase - where the rate factor is 1. After that it continues to react, but will call overheated() per timestep. Presently the default for overheated() is to reduce the yield of the product (i.e. it's faster but you get less). The rate_up_lim is the maximum rate the reaction can go at optimal temperatures, so in this case a rate factor of 1 i.e. a temperature between 500+ will produce 10u, or a temperature of 400 will roughly produce 4u per step (independant of product ratio produced, if you put 10, it will only create 10 maximum regardless of how much product is defined in the results list).

### How pH ranges are set and what pH mechanics do

Optimal pH ranges are set on a per recipe basis - though at the moment all recipes use a default recipe, so they all have the same window (except for the buffers). Hopefully either as a community effort/or in future PRs we can create unique profiles for the present reactions in the game.

As for how you define the reaction variables for a reaction, there are a few new variables for the chemical_recipe datum. I'll go over specifically how pH works for the default reaction.
```dm
/datum/chemical_reaction
	...
	var/optimal_ph_min 			= 5         	// Lowest value of pH determining pH a 1 value for pH based rate reactions (Plateu phase)
	var/optimal_ph_max 			= 9	        	// Higest value for above
	var/determin_ph_range 		= 4         	// How far out pH wil react, giving impurity place (Exponential phase)
	var/ph_exponent_factor 		= 1         	// How sharp the pH exponential curve is (to the power of value)
	var/purity_min 				= 0.15 			// If purity is below 0.15, it calls overly_impure(). In addition, if the product's purity is below this value at the end, the product will be 100% converted into the reagent's failed_chem. Set to 0 to disable this.
```

For this default reaction, the curve looks like this:
![image](https://user-images.githubusercontent.com/33956696/104081030-0fa98400-5224-11eb-822e-ffc614799ddc.png)

The y axis is the purity of the product made for that time step. This is recalculated based off the beaker's sum pH for every tick in the reaction. The rate in which your product is made based off the temperature (If you want me to describe that too I can.) So say our reaction has 10u of a purity 1 of product in there, and for our step we're making another 10u with our pH at (roughly) 3, from the curve our purity is (roughly) 0.5. So we will be adding 10u of 0.5 purity to 10u of 1 purity, resulting in 20u of 0.75 purity product. (Though - to note the reactant's purities also modify the purity of volume created on top of this).

If you're designing a reaction you can define an optimal range between the OptimalpHMin to OptimalpHMax (5 - 7 in this case) and a deterministic region set by the ReactpHLim (5 - 4, 9 + 4 aka between 1 to 5 and 9 to 13). This deterministic region is exponential, so if you set it to 2 then it’ll exponentially grow, but since our CurveSharpph = 1, it’s linear (basically normalise the range in the determinsitic region, then put that to the power of CurveSharppH). Finally values outside of these ranges will prevent reactions from starting, but if a reaction drifts out during a reaction, the purity of volume created for each step will be 0 (It does not stop ongoing reactions). It’s entirely possible to design a reaction without a deterministic or optimal phase if you wanted.

Though to note; if your purity dips below the PurityMin of a reaction it’ll call the overly_impure() function – which by default reduces the purity of all reagents in the beaker. Additionally, if the purity at the end of a reaction is below the PurityMin, it’ll convert into the failed chem defined by the product’s failed_chem defined in its reagent datum. For default the PurityMin is 0.15, and is pretty difficult to fail. This is all customisable however, if you wanted to use these hooks to design a even more unique reaction, just don’t call the parent proc when using methods.


### Conditional changes in reagents datum per timestep

```dm
/datum/chemical_reaction
	...
	var/thermic_constant		= 1         	// Temperature change per 1u produced
	var/H_ion_release 			= 0.01       	// pH change per 1u reaction
```

The thermic_constant is how much the temperature changes per u created, so for 10u created the temperature will increase by 10K. The H_ion_release is how much the pH changes per u created, for 10u created the pH will increase by 0.1. During a reaction this is the only factor in pH changes - presently the addition/removal of reagents tie to the reaction won't affect this, though other reactions ongoing in the beaker will also affect pH, as well as the removal/addition of reagents outside of the reaction.

### Reaction flags

Reaction_flags can be used to set these defines:

```dm
#define REACTION_CLEAR_IMPURE   //Convert into impure/pure on reaction completion in the datum/reagents holder instead of on consumption
#define REACTION_CLEAR_INVERSE  //Convert into inverse on reaction completion when purity is low enough in the datum/reagents holder instead of on consumption
#define REACTION_CLEAR_RETAIN	//Clear converted chems retain their purities/inverted purities. Requires 1 or both of the above. This is so that it can split again after splitting from a reaction (i.e. if your impure_chem or inverse_chem has its own impure_chem/inverse_chem and you want it to split again on consumption).
#define REACTION_INSTANT        //Used to create instant reactions

/datum/chemical_reaction
	var/reaction_flags
```

For REACTION_CLEAR – this causes the purity mechanics to resolve in the beaker at the end of the reaction, instead of when added to a mob.

#### A note on cold recipies

Is_cold_recipie requires you to set your overheat_temp and optimal_temp descend instead.
Eg:
```dm
/datum/chemical_reaction
	...
	var/required_temp			= 300
	var/optimal_temp			= 200
	var/overheat_temp 			= 50
```

# Reagents
The new vars that are introduced are below:
```dm
/datum/reagent
	/// pH of the reagent
	var/ph = 7
	///Purity of the reagent
	var/purity = 1
	///the purity of the reagent on creation (i.e. when it's added to a mob and its purity split it into 2 chems; the purity of the resultant chems are kept as 1, this tracks what the purity was before that)
	var/creation_purity = 1
	//impure chem values (see fermi_readme.dm for more details):
	var/impure_chem		 = /datum/reagent/impurity			// What chemical path is made when metabolised as a function of purity
	var/inverse_chem_val = 0.2								// If the impurity is below 0.5, replace ALL of the chem with inverse_chem upon metabolising
	var/inverse_chem	 = /datum/reagent/impurity/toxic		// What chem is metabolised when purity is below inverse_chem_val
	var/failed_chem		 = /datum/reagent/consumable/failed_reaction //what chem is made at the end of a reaction IF the purity is below the recipies purity_min
    var/chemical_flags
```

- `pH` is the innate pH of the reagent and is used to calculate the pH of a reagents datum on addition/removal. This does not change and is a reference value. The reagents datum pH changes.
- `purity` is the INTERNAL value for splitting. This is set to 1 after splitting so that it doesn't infinite split
- `creation_purity` is the purity of the reagent on creation. This won't change. If you want to write code that checks the purity in any of the methods, use this.
- `impure_chem` is the datum type that is created provided that its `creation_purity` is above the `inverse_chem_val`. When the reagent is consumed it will split into this OR if the associated `datum/chemical_recipe` has a REACTION_CLEAR_IMPURE flag it will split at the end of the reaction in the `datum/reagents` holder
- `inverse_chem_val` if a reagent's purity is below this value it will 100% convert into `inverse_chem`. If above it will split into `impure_chem`. See the note on purity effects above
- `inverse_chem` is the datum type that is created provided that its `creation_purity` is below the `inverse_chem_val`. When the reagent is consumed it will 100% convert into this OR if the associated  `datum/chemical_recipe` has a REACTION_CLEAR_INVERSE flag it will 100% convert at the end of the reaction in the `datum/reagents` holder
- `failed_chem` is the chem that the product is 100% converted into if the purity is below the associated `datum/chemical_recipies`' `PurityMin` AT THE END OF A REACTION.

When writing any reagent code ALWAYS use creation_purity. Purity is kept for internal mechanics only and won’t reflect the purity on creation.

See above for purity mechanics, but this is where you set the reagents that are created. If you’re making an impure reagent I recommend looking at impure_reagents.dm to see how they’re set up and consider using the `datum/reagents/impure` as a parent.

The flags you can set for `var/chemical_flags` are:
```dm
#define REAGENT_DEAD_PROCESS		(1<<0)	//allows on_mob_dead() if present in a dead body
#define REAGENT_DONOTSPLIT			(1<<1)	//Do not split the chem at all during processing - ignores all purity effects
#define REAGENT_INVISIBLE			(1<<2)	//Doesn't appear on handheld health analyzers.
#define REAGENT_SNEAKYNAME          (1<<3)  //When inverted, the inverted chem uses the name of the original chem
#define REAGENT_SPLITRETAINVOL      (1<<4)  //Retains initial volume of chem when splitting for purity effects

/datum/reagent
	var/chemical_flags
```

While you might think reagent_flags is a more sensible name - it is already used for beakers. Hopefully this doesn't trip anyone up.

# Relivant vars from the holder.dm / reagents datum

There are a few variables that are useful to know about
```dm
/datum/reagents
	/// Current temp of the holder volume
	var/chem_temp = 150
	///pH of the whole system
	var/ph = CHEMICAL_NORMAL_PH //aka 7
	///cached list of reagents
	var/list/datum/reagent/previous_reagent_list = new/list()
	///Hard check to see if the reagents is presently reacting
	var/is_reacting = FALSE
```
- chem_temp is the temperature used in the `datum/chemical_recipe`
- pH is a result of the sum of all reagents, as well as any changes from buffers and reactions. This is the pH used in `datum/chemical_recipe`.
- isReacting is a bool that can be used outside to ensure that you don't touch a reagents that is reacting.
- previous_reagent_list is a list of the previous reagents (just the typepaths, not the objects) that was present on the last handle_reactions() method. This is to prevent pointless method calls.
