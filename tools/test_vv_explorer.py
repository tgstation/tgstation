import pytest

import vv_explorer

def test_parse_dm_text():
    dm_text = "\n".join([
        "/obj/item/candle",
        "	w_class = WEIGHT_CLASS_SMALL",
        "	var/lit = TRUE",
    ])

    assert vv_explorer.parse_dm_text(dm_text) == {
        "/obj/item/candle": ["lit"]
    }


@pytest.mark.parametrize(
    "corpus,expected",
    [
        ("// This is a comment", False),
        ("/obj/item/candle", True),
        ("/mob/living/proc/death()", False),
        ("/** check_damage_thresholds", False),
    ]
)
def test_typepath_regex(corpus, expected):
    assert bool(vv_explorer.TYPE_DEFINITION_REGEX.match(corpus)) is expected


@pytest.mark.parametrize(
    "corpus,expected",
    [
        ("// This is a comment", False),
        ("/obj/item/candle", False),
        ("/mob/living/proc/death()", True),
    ]
)
def test_proc_regex(corpus, expected):
    assert bool(vv_explorer.PROC_DEFINITION_REGEX.match(corpus)) is expected


@pytest.mark.parametrize(
    "corpus,expected",
    [
        ("// This is a comment", False),
        ("/obj/item/candle", False),
        ("/mob/living/proc/death()", False),
        ("\tvar/lit = TRUE", True),
    ]
)
def test_var_regex(corpus, expected):
    assert bool(vv_explorer.VAR_DEFINITION_REGEX.match(corpus)) is expected


def test_var_list_regex():
    line = "\tvar/list/food_reagents = list(/datum/reagent/consumable/nutriment = 5)"
    match = vv_explorer.VAR_DEFINITION_REGEX.match(line)
    assert match.group("varname") == "food_reagents"


@pytest.mark.parametrize(
    "typepath,parent_tree",
    [
        ("/datum/brain_trauma", ["/datum/brain_trauma", "/datum"]),
        ("/obj/item/candle", ["/obj/item/candle", "/obj/item", "/obj", "/atom/movable", "/atom", "/datum"]),
    ]
)
def test_parent_tree(typepath, parent_tree):
    assert vv_explorer.get_parent_tree(typepath) == parent_tree
