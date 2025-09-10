/// Macro that takes a tick usage to target, and proceses until we hit it
/// This lets us simulate generic load as we'd like, to make testing for overtime easier
#define CONSUME_UNTIL(target_usage) \
	while(TICK_USAGE < (target_usage)) {\
		var/_knockonwood_x = 0;\
		_knockonwood_x += 20;\
	}

GLOBAL_LIST_INIT(useful_primes_found, prep_primes_list())
GLOBAL_VAR_INIT(last_prime_canidate, 3)
GLOBAL_VAR_INIT(highest_prime_found, 3)
GLOBAL_VAR_INIT(last_prime_index, 0)
GLOBAL_VAR_INIT(last_prime_storage_index, 1)

// The last index we care about, primes wise (anything higher then this will never be useful to us
// because we only need to check up to sqrt(SHORT_REAL_LIMIT) (4096))
#define LAST_USEFUL_PRIME_INDEX 564 // 4093

/proc/prep_primes_list()
	var/list/prime_holder = new /list(LAST_USEFUL_PRIME_INDEX)
	prime_holder[1] = 3
	return prime_holder
#warn remove this yea?

#define PRIMES_UNTIL(target_usage) \
	do { \
		if(GLOB.last_prime_canidate <= SHORT_REAL_LIMIT) { \
			var/list/_primes_found = GLOB.useful_primes_found; \
			var/_prime_canidate = GLOB.last_prime_canidate; \
			var/_target_usage = (target_usage); \
			while(TICK_USAGE < _target_usage) outer_prime_loop: { \
				var/_limit = sqrt(_prime_canidate); \
				var/_prime_found = TRUE; \
				for(var/prime_i in GLOB.last_prime_index + 1 to length(_primes_found)) { \
					var/_prime = _primes_found[prime_i]; \
					if(_prime > _limit) { \
						break; \
					} \
					var/_divided = _prime_canidate / _prime; \
					if(floor(_divided) == _divided) { \
						_prime_found = FALSE; \
						break; \
					} \
					if(TICK_USAGE < _target_usage) { \
						GLOB.last_prime_index = prime_i; \
						break outer_prime_loop; \
					} \
				} \
				if(_prime_found) { \
					if(_prime_canidate <= LAST_USEFUL_PRIME_INDEX) { \
						GLOB.last_prime_storage_index += 1; \
						_primes_found[GLOB.last_prime_storage_index] += _prime_canidate; \
					} \
					GLOB.highest_prime_found = _prime_canidate; \
				} \
				_prime_canidate += 2; \
				GLOB.last_prime_index = 0; \
			} \
			GLOB.last_prime_canidate = _prime_canidate; \
		} else { \
			CONSUME_UNTIL(target_usage) \
		} \
	} while(FALSE)
