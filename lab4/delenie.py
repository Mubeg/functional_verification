import dd
from dd.cudd import BDD
import tqdm

def ROBDD_div(n: int): #-> dd.cudd.Function:
    bdd = BDD()
    bdd.configure(reordering=False)
    
    # Объявляем переменные
    x_vars = [f'x{i}' for i in range(n)]
    y_vars = [f'y{i}' for i in range(n)]
    z_vars = [f'z{i}' for i in range(n)]

    list = x_vars + y_vars + z_vars
    
    bdd.declare(*list)
    
    # Формируем условие корректности деления
    # z = x // y <=> x = y * z + r, где 0 <= r < y
    formula = bdd.false
    
    # Перебираем все возможные значения x, y, z
    for x in tqdm.tqdm(range(2**n)):
        for y in range(1, 2**n):  # y не может быть 0
            z = x // y
            r = x % y
            
            # Формируем условие для текущего набора
            some_dict = {
                **{f'x{i}': bool((x >> i) & 1) for i in range(n)},
                **{f'y{i}': bool((y >> i) & 1) for i in range(n)},
                **{f'z{i}': bool((z >> i) & 1) for i in range(n)}
            }
            #print(some_dict)
            term = bdd.cube(some_dict)
            formula |= term
    
    return (bdd, formula)


def calc_div(f, x: int, y: int, n: int) -> int:
    
    substitution = {
                **{f'x{i}': bool((x >> i) & 1) for i in range(n)},
                **{f'y{i}': bool((y >> i) & 1) for i in range(n)}
            }
    bdd = f.bdd
    
    result = bdd.let(substitution, f)

    z_val = 0
    for i in range(n):
        temp = bdd.let({f'z{i}': False}, result)
        if temp != bdd.false:
            result = temp
        else:
            z_val |= (1 << i)
            result = bdd.let({f'z{i}': True}, result)
    return z_val

def test_division(n):
    bdd, f = ROBDD_div(n)
    success = True
    
    for x in tqdm.tqdm(range(2**n)):
        for y in range(1, 2**n):  # избегаем деления на 0
            expected = x // y
            computed = calc_div(f, x, y, n)
            if(expected != computed):
                success = False
                print(f"Error x={x}, y={y}: expected {expected}, got {computed}")
    if(success):
        print("Все тесты пройдены!")

def analyze_size(max_n):
    for n in range(1, max_n):
        bdd, f = ROBDD_div(n)
        stats = bdd.statistics()
        #print(stats)
        print(f"Разрядность {n}:")
        print(f"  Узлов: {stats['n_nodes']}")
        print(f"  Максимальная ширина: {stats['peak_nodes']}")

analyze_size(10)
test_division(10)