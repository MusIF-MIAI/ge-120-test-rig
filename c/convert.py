import os
import textwrap

from dataclasses import dataclass

@dataclass
class TestCase:
    name: str
    code: str
    cases: [int]

def read_conf(filename):
    path = os.path.join(conf_dir, filename)
    content = open(path, "r").read()

    case = TestCase('', '', [])

    for l in content.splitlines():
        if l.startswith('# '):
            name, code = l[1:].split(' - ')
            case.name = name.strip()
            case.code = code.strip()
        elif len(l) == 30:
            bit = int(l, 2)
            case.cases.append(bit)

    return case

def print_struct_definition():
    print(textwrap.dedent("""\
        struct ge_testplates {
            const char *code;
            const char *name;
            const size_t count;
            const uint32_t cases[];
        };
        """))

def print_struct(case):
    cases_text = [f"0x{bits:08x}, /* {bits:030b} */" for bits in case.cases]
    cases_text = '\n'.join(cases_text)
    cases_text = textwrap.indent(cases_text, '        ')

    print(textwrap.dedent(f"""\
        struct ge_testplates plate_{case.code} = {{
            "{case.code}", "{case.name}", {len(case.cases)}, {{"""))
    print(cases_text)
    print(textwrap.dedent(f"""\
            }},
        }};
        """))

def print_all_tests(cases):
    for case in cases:
        print_struct(case)

def print_tests_array(cases):
    print("struct ge_testplates * tests[] = {")

    for case in cases:
        print(f"    &plate_{case.code},")

    print("};")

conf_dir = '../conf'
conf_files = [ f for f in os.listdir(conf_dir) if f.endswith('.conf') ]
conf_files = sorted(conf_files)
cases = [read_conf(file) for file in conf_files]

print_struct_definition()
print_all_tests(cases)
print_tests_array(cases)
