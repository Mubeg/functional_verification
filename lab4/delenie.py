import dd
from dd.cudd import BDD

def ROBDD_div(n: int) -> dd.cudd.Function:
    bdd = BDD()
    bdd.configure(reordering=False)
    
    # Объявляем переменные
    x_vars = [f'x{i}' for i in range(n)]
    y_vars = [f'y{i}' for i in range(n)]
    z_vars = [f'z{i}' for i in range(n)]
    
    bdd.declare(x_vars + y_vars + z_vars)
    
    # Формируем условие корректности деления
    # z = x // y <=> x = y * z + r, где 0 <= r < y
    formula = []
    
    # Перебираем все возможные значения x, y, z
    for x in range(2**n):
        for y in range(1, 2**n):  # y не может быть 0
            z = x // y
            r = x % y
            
            # Формируем условие для текущего набора
            term = bdd.cube({
                **{f'x{i}': (x >> i) & 1 for i in range(n)},
                **{f'y{i}': (y >> i) & 1 for i in range(n)},
                **{f'z{i}': (z >> i) & 1 for i in range(n)}
            })
            formula.append(term)
    
    return bdd.add_expr(' | '.join(map(str, formula)))


def calc_div(f: dd.cudd.Function, x: int, y: int) -> int:
    n = f.node.var_num // 3  # Предполагаем равное количество бит для x, y, z
    
    # Создаем подстановку значений
    substitution = {
        f'x{i}': (x >> i) & 1 for i in range(n)
    }
    substitution.update({
        f'y{i}': (y >> i) & 1 for i in range(n)
    })
    
    # Применяем подстановку
    result = f.let(substitution)
    
    # Извлекаем значение z
    z_bits = [result.var(f'z{i}') for i in range(n)]
    return sum(bit << i for i, bit in enumerate(z_bits))

def test_division():
    n = 4  # разрядность
    bdd = BDD()
    f = ROBDD_div(n)
    
    for x in range(2**n):
        for y in range(1, 2**n):  # избегаем деления на 0
            expected = x // y
            computed = calc_div(f, x, y)
            assert expected == computed, f"Ошибка при x={x}, y={y}"
    
    print("Все тесты пройдены!")

def analyze_size():
    for n in range(1, 6):
        bdd = BDD()
        f = ROBDD_div(n)
        stats = bdd.statistics()
        print(f"Разрядность {n}:")
        print(f"  Узлов: {stats['nodes']}")
        print(f"  Максимальная ширина: {stats['max_width']}")

analyze_size()
test_division()