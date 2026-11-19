import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/models/money.dart';

void main() {
  test('parses user input with comma or dot and at most 2 decimals', () {
    expect(Money.parseInput('150'), 15000);
    expect(Money.parseInput('150,5'), 15050);
    expect(Money.parseInput('150.50'), 15050);
    expect(Money.parseInput(' 0 '), 0);
    expect(Money.parseInput('1.234'), isNull);
    expect(Money.parseInput('-1'), isNull);
    expect(Money.parseInput('abc'), isNull);
    expect(Money.parseInput(''), isNull);
  });

  test('API strings ↔ cents without floating-point drift', () {
    expect(Money.centsFromApi('150.00'), 15000);
    expect(Money.centsFromApi('0.10'), 10);
    expect(Money.toApi(15000), 150);
    expect(Money.toApi(15050), 150.5);
    expect(Money.toApi(1), 0.01);
  });

  test('formats as Bs with es_BO separators', () {
    expect(Money.format(15000), 'Bs 150,00');
    expect(Money.format(150000), 'Bs 1.500,00');
    expect(Money.formatApi('40.00'), 'Bs 40,00');
    expect(Money.toInput(15050), '150.50');
    expect(Money.toInput(15000), '150');
  });
}
