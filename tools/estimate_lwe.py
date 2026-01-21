#!/usr/bin/env python3
"""
LWE Security Estimator for lwe-jump-table project.

Uses simplified Core-SVP model. For production, verify with:
https://github.com/malb/lattice-estimator

Parameters:
- n = 768 (dimension)
- q = 4096 (modulus, 12-bit)
- sigma ~ sqrt(k/2) where k=16 for centered binomial noise
"""

import math

def core_svp_cost(beta):
    """
    Core-SVP cost model: 2^(0.292 * beta) operations.
    This is the BKZ cost estimate used by lattice-estimator.
    """
    return 0.292 * beta

def primal_usvp_beta(n, q, sigma):
    """
    Estimate the required BKZ blocksize beta for uSVP attack.
    
    Uses the geometric series assumption (GSA) heuristic:
    beta satisfies: sigma * sqrt(beta) = q^(n/beta) * sqrt(beta / (2*pi*e))
    
    Simplified: beta ~ n * log(q) / log(q/sigma)
    """
    if sigma <= 0:
        return float('inf')
    
    # Iterative search for beta
    for beta in range(50, 2000):
        # GSA heuristic: delta^(beta-1) * q^(n/beta) ~ sigma * sqrt(n)
        delta = (beta / (2 * math.pi * math.e) * (math.pi * beta) ** (1/beta)) ** (1 / (2 * (beta - 1)))
        lhs = delta ** (beta - 1) * (q ** (n / beta))
        rhs = sigma * math.sqrt(n)
        if lhs <= rhs:
            return beta
    return 2000

def dual_distinguishing_beta(n, q, sigma):
    """
    Estimate beta for dual distinguishing attack.
    """
    alpha = sigma / q
    # From "On Dual Lattice Attacks Against Small-Secret LWE"
    # beta ~ n * alpha^2 * log(q)^2 ... simplified heuristic
    m = n  # number of samples
    for beta in range(50, 2000):
        delta = (beta / (2 * math.pi * math.e)) ** (1 / (2 * beta))
        bound = q ** (1 - n/m) * delta ** m * sigma
        if bound < 1:
            return beta
    return 2000

def estimate_security(n, q, sigma):
    """
    Estimate security level in bits for given LWE parameters.
    """
    beta_primal = primal_usvp_beta(n, q, sigma)
    beta_dual = dual_distinguishing_beta(n, q, sigma)
    beta = min(beta_primal, beta_dual)
    
    security_bits = core_svp_cost(beta)
    return security_bits, beta, beta_primal, beta_dual

def main():
    print("=" * 60)
    print("LWE Security Estimator for lwe-jump-table")
    print("=" * 60)
    print()
    
    # Current parameters
    n = 768
    q = 4096
    k = 16  # centered binomial parameter
    sigma = math.sqrt(k / 2)  # ~ 2.83
    
    print(f"Current Parameters:")
    print(f"  n (dimension)     : {n}")
    print(f"  q (modulus)       : {q} (12-bit)")
    print(f"  k (binomial param): {k}")
    print(f"  sigma (std dev)   : {sigma:.3f}")
    print()
    
    security, beta, beta_p, beta_d = estimate_security(n, q, sigma)
    
    print(f"Security Analysis:")
    print(f"  Primal uSVP beta  : {beta_p}")
    print(f"  Dual attack beta  : {beta_d}")
    print(f"  Min blocksize     : {beta}")
    print(f"  Security level    : {security:.1f} bits")
    print()
    
    if security >= 128:
        print("  [PASS] >= 128-bit security")
    elif security >= 80:
        print("  [WARN] 80-128 bit security")
    else:
        print("  [FAIL] < 80-bit security")
    
    print()
    print("-" * 60)
    print("Parameter sweep (q=4096, sigma=2.83):")
    print("-" * 60)
    print(f"{'n':>6} | {'beta':>6} | {'bits':>8} | {'status':>10}")
    print("-" * 60)
    
    for test_n in [256, 384, 512, 640, 768, 896, 1024]:
        sec, beta, _, _ = estimate_security(test_n, q, sigma)
        if sec >= 128:
            status = "[PASS]"
        elif sec >= 80:
            status = "[WARN]"
        else:
            status = "[FAIL]"
        print(f"{test_n:>6} | {beta:>6} | {sec:>8.1f} | {status:>10}")
    
    print()
    print("Note: For production, verify with lattice-estimator:")
    print("  sage: load('https://bitbucket.org/malb/lwe-estimator/raw/HEAD/estimator.py')")
    print(f"  sage: n, alpha, q = {n}, {sigma/q:.6f}, {q}")
    print("  sage: primal_usvp(n, alpha, q)")

if __name__ == "__main__":
    main()
