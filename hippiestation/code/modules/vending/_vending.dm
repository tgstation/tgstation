/*
	There's some Hippie-related vars here that help us unobtrusively manage the products/contraband/premium

	hippie_products contains the normal items available
	hippie_contraband contains the items you need to hack to acquire
	hippie_premium contains the items which require a coin to acquire

	Add items to these lists if you want them to appear in their respective lists
	You can also take away items by using a negative value. If the sum of products + hippie_products
	is less than 0 then the item is taken out altogether (so use -100 to completely remove an item)
*/

/obj/machinery/vending
	icon_hippie = 'hippiestation/icons/obj/vending.dmi'
	var/hippie_products = list()
	var/hippie_contraband = list()
	var/hippie_premium = list()

/obj/machinery/vending/Initialize()
	// Add our items to the list
	// If the item is already a product then add items to it
	if (LAZYLEN(products) && LAZYLEN(hippie_products))
		for (var/i in hippie_products)
			if (products[i])
				if (products[i] + hippie_products[i] <= 0)
					LAZYREMOVE(products, i)
				else
					products[i] = products[i] + hippie_products[i]
			else
				products[i] = hippie_products[i]

	if (LAZYLEN(contraband) && LAZYLEN(hippie_contraband))
		for (var/i in hippie_contraband)
			if (contraband[i])
				if (contraband[i] + hippie_contraband[i] <= 0)
					LAZYREMOVE(contraband, i)
				else
					contraband[i] = contraband[i] + hippie_contraband[i]
			else
				contraband[i] = hippie_contraband[i]

	if (LAZYLEN(premium) && LAZYLEN(hippie_premium))
		for (var/i in hippie_premium)
			if (premium[i])
				if (premium[i] + hippie_premium[i] <= 0)
					LAZYREMOVE(premium, i)
				else
					premium[i] = premium[i] + hippie_premium[i]
			else
				premium[i] = hippie_premium[i]

	return ..()