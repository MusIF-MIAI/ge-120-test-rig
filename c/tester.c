#include <stdio.h>
#include <stdint.h>

#include "testplates.h"

static const int PIN_COUNT = 30;

struct tester {
    int current_plate;
    int current_test;
};

void tester_init(struct tester *t) {
    t->current_plate = 0;
    t->current_test = 0;
}

struct ge_testplates *current_plate(const struct tester *t) {
    return tests[t->current_plate];
}

int plate_count(void) {
    return sizeof(tests) / sizeof(tests[0]);
}

void print_current_test(struct tester *t) {
    struct ge_testplates *plate = current_plate(t);
    printf("Board: %s - %s", plate->code, plate->name);
    printf(" (%d of %d)\n", t->current_plate, plate_count());
    printf("Test %d of %zu\n", t->current_test, plate->count);
}

void set_pins(struct tester *t) {
    struct ge_testplates *plate = current_plate(t);
    uint32_t bits = plate->cases[t->current_test];

    for (int pin = 0; pin < PIN_COUNT; pin++) {
        int bit = !!((1 << (29 - pin)) & bits);
        printf(" > setting pin %d to %d\n", pin, bit);
    }
}

void tester_next_test(struct tester *t) {
    t->current_test++;

    if (t->current_test >= current_plate(t)->count) {
        t->current_test = 0;
    }
}

void tester_next_plate(struct tester *t) {
    t->current_test = 0;
    t->current_plate++;

    if (t->current_plate >= plate_count()) {
        t->current_plate = 0;
    }
}

int command_prompt(struct tester *t) {
    int again = 1;

    printf("(n)ext test, ne(x)t plate, (q)uit: ");

    while (again) {
        char command;

        again = 0;
        scanf("%c", &command);

        switch (command) {
            case 'n': tester_next_test(t); break;
            case 'x': tester_next_plate(t); break;
            case 'q': return 1;
            default: again = 1;
        }
    }
    return 0;
}

int main(int argc, const char * argv[]) {
    struct tester t;

    int running = 1;

    tester_init(&t);

    while(running) {
        print_current_test(&t);
        set_pins(&t);

        if (command_prompt(&t)) {
            running = 0;
        }
    }

    return 0;
}
