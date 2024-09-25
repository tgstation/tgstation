///The key to access the 'optimal' amount of a material key from its assoc value list.
#define MATERIAL_LIST_OPTIMAL_AMOUNT "optimal_amount"
///The key to access the multiplier used to selectively control effects and modifiers of a material.
#define MATERIAL_LIST_MULTIPLIER "multiplier"
///A macro that ensures some multiplicative modifiers higher than 1 don't become lower than 1 and viceversa because of the multiplier.
#define GET_MATERIAL_MODIFIER(modifier, multiplier) (modifier >= 1 ? (modifier - 1) + (((modifier) - 1) * (multiplier)) : (modifier)**(multiplier))
