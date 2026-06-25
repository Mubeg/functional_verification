import json


def find_next_vert(vertex, edges):
    next = []
    for edge in edges:
        if edge[0] == vertex:
            next.append(edge[1:])
    return next


sorted_verticies = []
verticies_visited = []


def recurse_topological_sort(vertex, verticies, edges):
    global sorted_verticies
    global verticies_visited
    verticies_visited[vertex] = True
    next_verticies = find_next_vert(vertex, edges)
    for next in next_verticies:
        if not verticies_visited[next[0]]:
            recurse_topological_sort(next[0], verticies, edges)
    sorted_verticies.append(vertex)


def topological_sort(verticies, edges):
    global sorted_verticies
    global verticies_visited
    sorted_verticies = []

    verticies_visited = [False for vertex in verticies]
    for vertex in verticies:
        if not verticies_visited[vertex]:
            recurse_topological_sort(vertex, verticies, edges)
    return sorted_verticies


def translate_schema(filename_input, filename_output):
    data = dict()
    with open(filename_input, "r") as file:
        data = json.load(file)
    gates = data["gates"]
    schema = data["schematics"]
    gates_codenames = schema["gates"]

    schema_inputs_n = schema["inw"]
    schema_outputs_n = schema["outw"]
    schema_outputs = schema["output"]
    schema_connection = schema["drivers"]

    verticies = [i for i in range(schema_inputs_n)]

    gates_numbers = dict()
    gates_num_rev = dict()
    for i in range(len(gates_codenames.keys())):
        gates_numbers[list(gates_codenames.keys())[i]] = schema_inputs_n + i
        gates_num_rev[schema_inputs_n + i] = list(gates_codenames.keys())[i]
        verticies.append(schema_inputs_n + i)

    # print(verticies)

    edges = []
    for key in schema_connection:
        _from = key
        _to = schema_connection[key]
        _from_pos = -1
        _from_num = -1
        _to_pos = -1
        _to_num = 0
        for i in range(len(_from)):
            if _from[i].isnumeric():
                _from_pos = gates_numbers[_from[0:i]]
                _from_num = int(_from[i:])
                break
        if not isinstance(_to, int):
            for i in range(len(_to)):
                if _to[i].isnumeric():
                    _to_pos = gates_numbers[_to[0:i]]
                    _to_num = int(_to[i:])
                    break
        else:
            _to_pos = int(_to)
        edges.append([_from_pos, _to_pos, _from_num, _to_num])

    # print(edges)

    sorted_verticies = topological_sort(verticies, edges)

    # print(sorted_verticies)

    calc_array = []
    max_width = 1

    for i in range(0, schema_inputs_n):
        calc_array.append(f"temp[{i}][0] = in[{i//8}]&(0x1 << {i%8}) ? 1 : 0")

    for i in range(schema_inputs_n, len(sorted_verticies)):
        current_vertex = sorted_verticies[i]
        gate = gates_codenames[gates_num_rev[current_vertex]]
        gate_descr = gates[gate]
        max_width = max(max_width, gate_descr["outw"])
        next_verts = find_next_vert(current_vertex, edges)
        sorted_next = sorted(next_verts, key=lambda x: x[1])
        # print(sorted_next)

        string = f"__{gate}("
        for next in sorted_next:
            next_pos = sorted_verticies.index(next[0])
            if next_pos >= i:
                print("Loops are present")
                return
            string += f"&temp[{next[0]}][{next[2]}], "

        for j in range(0, gate_descr["outw"]):
            string += f"&temp[{current_vertex}][{j}]"
            if j != gate_descr["outw"] - 1:
                string += ", "
        string += ")"
        calc_array.append(string)

    outputs = []
    for i in range(len(schema_outputs)):
        output = schema_outputs[i]
        _output_pos = -1
        _output_num = -1
        if not isinstance(output, int):
            for j in range(len(output)):
                if output[j].isnumeric():
                    _output_pos = gates_numbers[output[0:j]]
                    _output_num = int(output[j:])
                    break
        else:
            _output_pos = int(output)
            _output_num = 0
        outputs.append(f"out[{i//8}] = temp[{_output_pos}][{_output_num}] ? out[{i//8}] | (0x1 << {i%8}) : out[{i//8}] & ~(0x1 << {i%8}) ")

    c_file = open(filename_output, "w")
    c_file.write('#include "stdint.h"\n\n')

    for gate in gates:
        gate_descr = gates[gate]
        c_file.write("\n")
        c_file.write(f"void __{gate}(")
        for i in range(0, gate_descr["inw"]):
            c_file.write(f"const uint8_t *in{i}, ")
        for i in range(0, gate_descr["outw"]):
            c_file.write(f"uint8_t *out{i}")
            if i != gate_descr["outw"] - 1:
                c_file.write(", ")
        c_file.write("){\n\n")
        c_file.write("\tuint8_t inw = ")

        for i in range(0, gate_descr["inw"]):
            c_file.write(f"(*in{i} << {i})")
            if i != gate_descr["inw"] - 1:
                c_file.write(" + ")
        c_file.write(";\n")

        table = gate_descr["table"]
        c_file.write(f"\tconst uint8_t table[{len(table)}] = ")
        c_file.write("{")
        for i in range(0, len(table)):
            c_file.write(f"{table[i]}")
            if i != len(table) - 1:
                c_file.write(", ")
        c_file.write("};\n")

        for i in range(0, gate_descr["outw"]):
            c_file.write(f"\t*out{i} = (table[inw] >> {i}) & 1;\n")

        c_file.write("\n}\n")

    c_file.write("\n")
    c_file.write("void calc(const uint8_t in [], uint8_t out []){\n\n")

    c_file.write(f"\tuint8_t temp [{len(calc_array)}][{max_width}];\n\n")

    for calc in calc_array:
        c_file.write(f"\t{calc};\n")

    c_file.write("\n")

    for output in outputs:
        c_file.write(f"\t{output};\n")

    c_file.write("\n}\n")

    c_file.write("\nint test_entry_point(void){\n\n")

    c_file.write(f"\tuint8_t out[{schema_outputs_n}];\n")

    c_file.write(f"\tuint8_t in[{schema_inputs_n}] = ")
    c_file.write("{")
    for i in range(schema_inputs_n):
        c_file.write("1")
        if i != schema_inputs_n - 1:
            c_file.write(", ")
    c_file.write("};\n")

    c_file.write("\n\tcalc(in, out);\n\n")

    c_file.write("\treturn 0;\n}\n")

    c_file.close()


if __name__ == "__main__":
    import sys

    input_file = "in.json"
    output_file = "out.c"
    if len(sys.argv) > 2:
        input_file = sys.argv[1]
        output_file = sys.argv[2]
    translate_schema(input_file, output_file)
