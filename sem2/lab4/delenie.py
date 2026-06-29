import dd
from dd.cudd import BDD
import tqdm

def sub_bdd(n, bdd, A, B):

    result = [bdd.false for _ in range(n)]
    borrow = bdd.false
     
    for i in range(n):
        t = bdd.apply('xor', A[i], B[i])
        result[i] = bdd.apply('xor', t, borrow)
        
        borrow_ab = bdd.apply('&', bdd.apply('!', A[i]), B[i])
        borrow_ac = bdd.apply('&', bdd.apply('!', A[i]), borrow)
        borrow_bc = bdd.apply('&', B[i], borrow)
        
        borrow = bdd.apply('|', borrow_ab, borrow_ac)
        borrow = bdd.apply('|', borrow, borrow_bc)
    
    return result

def greater_bdd(n, bdd, A, B):

    gr = bdd.false
    for i in range(n-1, -1, -1):

        higher_bits_eq = bdd.true
        for j in range(n-1, i, -1):
            eq_bit = bdd.apply('xor', A[j], B[j])
            eq_bit = bdd.apply('not', eq_bit)
            higher_bits_eq = bdd.apply('&', higher_bits_eq, eq_bit)
        
        a_g_b = bdd.apply('&', bdd.apply('not', B[i]), A[i])
        gr = bdd.apply('|', gr, bdd.apply('&', higher_bits_eq, a_g_b))

    return gr

def equal_bdd(n, bdd, A, B):
    
    eq = bdd.true
    for i in range(n):
        eq_bit = bdd.apply('xor', A[i], B[i])
        eq_bit = bdd.apply('not', eq_bit)
        eq = bdd.apply('&', eq, eq_bit)

    return eq

def greater_or_equal_bdd(n, bdd, A, B):
    
    eq = equal_bdd(n, bdd, A, B)   
    gr = greater_bdd(n, bdd, A, B)

    gre = bdd.apply('|',  gr,  eq)
    
    return gre

def mux_bdd(n, bdd, A, B, chose):
    
    result = []
    for i in range(n):
        selected = bdd.apply('|', 
                            bdd.apply('&', chose, A[i]),
                            bdd.apply('&', bdd.apply('not', chose), B[i]))
        result.append(selected)
    
    return result

def ROBDD_div(n: int, order: str = "grouped"):
    
    bdd = BDD()
    bdd.configure(reordering=False)

    x_vars = [f'x{i}' for i in range(n)]
    y_vars = [f'y{i}' for i in range(n)]
    list = []
    if order == "grouped":
        list = x_vars + y_vars
    else:
        for i in range(n):
            list.append(x_vars[i])
            list.append(y_vars[i])

    bdd.declare(*list)
    
    x = []
    y = []
    for i in range(n):
        x.append(bdd.var('x' + str(i)))
        y.append(bdd.var('y' + str(i)))
    
    
    x.extend([bdd.false for _ in range(n)])        

    div = [bdd.false for _ in range(n)]

    for i in tqdm.tqdm(range(n-1, -1, -1)):
        div[i] = greater_or_equal_bdd(n, bdd, x[i:i+n], y)
        x[i:i+n] = mux_bdd(n, bdd, sub_bdd(n, bdd, x[i:i+n], y), x[i:i+n], div[i])

    return (bdd, div)

def calc_div(f, x: int, y: int, n: int) -> int:

    x_dir = {f'x{i}': bool((x >> i) & 1) for i in range(n)}
    y_dir = {f'y{i}': bool((y >> i) & 1) for i in range(n)}
    bdd = f[0].bdd
    
    z_val = 0
    for i in range(n):
        node = bdd.let(x_dir, f[i])
        node = bdd.let(y_dir, node)
        
        if (node == bdd.true):
            z_val += (1 << i)
    return z_val

def test_division(n):
    bdd, f = ROBDD_div(n)
    bdd2, g = ROBDD_div(n, "interleaved")
    success = True
    
    for x in tqdm.tqdm(range(2**n)):
        for y in range(1, 2**n): 
            expected = x // y
            computed = calc_div(f, x, y, n)
            if(expected != computed):
                success = False
                print(f"Error x={x}, y={y}: expected {expected}, got {computed}")
    for x in tqdm.tqdm(range(2**n)):
        for y in range(1, 2**n): 
            expected = x // y
            computed = calc_div(g, x, y, n)
            if(expected != computed):
                success = False
                print(f"Error x={x}, y={y}: expected {expected}, got {computed}")
    if(success):
        print("Tests success")
        
def greater_or_equal_value_bdd(n, bdd, A, value):
    value_bits = [ bdd.true if (value >> i) & 1 else bdd.false for i in range(n) ]

    gre = greater_or_equal_bdd(n, bdd, A, value_bits)
    
    return gre

def less_or_equal_value_bdd(n, bdd, A, value):
    value_bits = [ bdd.true if (value >> i) & 1 else bdd.false for i in range(n)  ]
    l = bdd.apply('not', greater_bdd(n, bdd, A, value_bits))
    eq = equal_bdd(n, bdd, A, value_bits)

    return bdd.apply('|', l, eq)

def res_in_I_division(a: int, b: int, n: int) -> dd.cudd.Function:
    bdd, f = ROBDD_div(n)

    max_val = (1 << n) - 1
    a = max(0, min(a, max_val))
    b = max(0, min(b, max_val))

    ge_a = greater_or_equal_value_bdd(n, bdd, f, a)

    le_b = less_or_equal_value_bdd(n, bdd, f, b)

    har = bdd.apply('&', ge_a, le_b)
    return har

from collections import defaultdict, deque

def robdd_width(bdd, f):

    visited = set()

    level_nodes = defaultdict(set)

    q = deque(f)

    while len(q):

        node = q.popleft()

        if node in visited:
            continue

        visited.add(node)

        if node == bdd.true or node == bdd.false:
            continue

        level = bdd.level_of_var(node.var)

        level_nodes[level].add(node)

        q.append(node.low)
        q.append(node.high)

    return max(len(v) for v in level_nodes.values())

import math
import numpy as np

def analyze_size(max_n):
    x_data = []
    y_data_nodes = []
    y_data_width = []
    for n in range(1, max_n):
        bdd, f = ROBDD_div(n)
        bdd2, g = ROBDD_div(n, "interleaved")
        #print(bdd.vars)
        stats = bdd.statistics()
        #print(stats)
        print(f"Bits {n} groped:")
        print(f"  Nodes: {len(bdd)}")
        print(f"  Max width: {robdd_width(bdd, f)}")
        print(f"Bits {n} interleaved:")
        print(f"  Nodes: {len(bdd2)}")
        print(f"  Max width: {robdd_width(bdd2, g)}")
        x_data.append(n)
        y_data_nodes.append(math.log2(len(bdd)))
        y_data_width.append(math.log2(robdd_width(bdd, f)))

def test_har(a, b, n):
    har = res_in_I_division(a, b, n)
    bdd, f = ROBDD_div(n)

    success = True
    for x in tqdm.tqdm(range(2**n)):
        for y in range(1, 2**n):
            substitution = {
                    **{f'x{i}': bool((x >> i) & 1) for i in range(n)},
                    **{f'y{i}': bool((y >> i) & 1) for i in range(n)}
                }
            bdd = har.bdd
            
            result = bdd.let(substitution, har)
            if(result == bdd.true):
                expected_z = calc_div(f, x, y, n)
                if not(expected_z >= a and expected_z <= b):
                    success = False
                    print(f"Error x={x} // y={y} does not lie in interval [a={a}, b={b}]")
    if(success):
        print("Haracteristics function is correct")

n = 10
a = 1
b = 2
analyze_size(n+3)
test_division(n)
test_har(a, b, n)
