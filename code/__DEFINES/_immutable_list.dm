///Create an immutable list using a given list.
#define IMMUTABLE_LIST(list) __immutable_list(list)
///Create an immutable associative list. Only works for assoc lists with a depth of 1.
#define IMMUTABLE_ASSOC_LIST(list) __immutable_assoc_list(list)
///Create an immutable list where all of the elements are strings, which makes them faster to mutate.
#define IMMUTABLE_STRING_LIST(list) __immutable_string_list(list)
