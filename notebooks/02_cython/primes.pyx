# primes.pyx

import numpy as np
cimport numpy as np

def get_primes_cython(int n):
    cdef:
        np.ndarray[np.int32_t, ndim=1] primes = np.zeros(n, dtype=np.int32)
        int i = 0;
        int last_prime = 2;
        int candidate = 1;
        int is_ok = 1;
    
    while (i<n):
        candidate += 1;
        is_ok = 1;
        
        for c in range(i):
            if candidate % primes[c] == 0:
                is_ok = 0;
                break;

        if is_ok == 1:
            primes[i] = candidate;
            i += 1;
    
    return primes
