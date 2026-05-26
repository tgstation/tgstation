/// Dodges our manual verb definition lint. You should almost never be using this,
/// verbs need to be shimmed by DEFINE_VERB() and friends to allow them to be queued
#define VERBLIKE_SET(key, value) set key = value
