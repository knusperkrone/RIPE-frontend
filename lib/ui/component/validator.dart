typedef ValidatorFun = String Function(String);

class Validator {
  static String notEmpty(String value) {
    value = value?.trim() ?? '';
    if (value.isEmpty) {
      return 'Darf nicht leer sein';
    }
    return null;
  }

  static String number(String value) {
    if (int.tryParse(value) == null) {
      return 'Keine Zahl';
    }
    return null;
  }

  static String chain(String value, Iterable<ValidatorFun> validators) {
    for (final validator in validators) {
      final res = validator(value);
      if (res != null) {
        return res;
      }
    }
    return null;
  }
}
