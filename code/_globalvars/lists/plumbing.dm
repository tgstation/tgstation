/// List of plumbing layers as name => bitflag
GLOBAL_LIST_INIT(plumbing_layers, list(
	"First Layer" = FIRST_DUCT_LAYER,
	"Second Layer" = SECOND_DUCT_LAYER,
	"Default Layer" = THIRD_DUCT_LAYER,
	"Fourth Layer" = FOURTH_DUCT_LAYER,
	"Fifth Layer" = FIFTH_DUCT_LAYER,
))

/// Reverse of plumbing_layers, as "[bitflag]" => name
GLOBAL_LIST_INIT(plumbing_layer_names, list(
	"[FIRST_DUCT_LAYER]" = "First Layer",
	"[SECOND_DUCT_LAYER]" = "Second Layer",
	"[THIRD_DUCT_LAYER]" = "Default Layer",
	"[FOURTH_DUCT_LAYER]" = "Fourth Layer",
	"[FIFTH_DUCT_LAYER]" = "Fifth Layer",
))
