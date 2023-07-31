#include "testplates.h"

static const int ARDUINO_PIN_START = 22;
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

void tester_print_test(struct tester *t) {
  char str[100];
  struct ge_testplates *plate = current_plate(t);

  snprintf(str, sizeof(str), "%s %s", plate->code, plate->name);
  Serial.println(str);

  if (t->current_test == 0) {
    snprintf(str, sizeof(str), "Config (%d tests)", plate->count - 1);
    Serial.println(str);  
  } else {
    snprintf(str, sizeof(str), "Test: %d of %d", t->current_test, plate->count - 1);
    Serial.println(str);
  }

  Serial.print("@");
}

void tester_set_pins(struct tester *t) {
  struct ge_testplates *plate = current_plate(t);
  uint32_t bits = plate->cases[t->current_test];

  for (uint32_t pin = 0; pin < PIN_COUNT; pin++) {
    uint32_t bit = !((1ull << (pin)) & bits);
    digitalWrite(ARDUINO_PIN_START + pin, bit);
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

const int debounce_delay = 50;

struct tester tester;

static const int PLATE_BUTTON_PIN = 52;
static const int TEST_BUTTON_PIN = 53;

int last_test_button = 1;
long last_test_debounce = 0;

int last_plate_button = 1;
long last_plate_debounce = 0;

void setup() {
  Serial.begin(9600);

  for (int i = 0; i < PIN_COUNT; i++) {
    pinMode(ARDUINO_PIN_START + i, OUTPUT);
  }
  
  pinMode(PLATE_BUTTON_PIN, INPUT_PULLUP);
  pinMode(TEST_BUTTON_PIN, INPUT_PULLUP);

  tester_init(&tester);
  tester_print_test(&tester);
  tester_set_pins(&tester);
}

void advance_test_button() {
  tester_next_test(&tester);
  tester_print_test(&tester);
  tester_set_pins(&tester);
}

void advance_plate_button() {
  tester_next_plate(&tester);
  tester_print_test(&tester);
  tester_set_pins(&tester);
}

void loop() {
  if (millis() > last_plate_debounce + debounce_delay) {
    int this_plate_button = digitalRead(PLATE_BUTTON_PIN);

    if (last_plate_button != this_plate_button) {
      last_plate_debounce = millis();

      if (this_plate_button) {
        advance_plate_button();
      }
    }

    last_plate_button = this_plate_button;
  }

  if (millis() > last_test_debounce + debounce_delay) {
    int this_test_button = digitalRead(TEST_BUTTON_PIN);

    if (last_test_button != this_test_button) {
      last_test_debounce = millis();

      if (this_test_button) {
        advance_test_button();
      }
    }

    last_test_button = this_test_button;
  }
}
