import 'package:drift/web.dart';

import 'shared.dart';

SharedDatabase constructDb() {
  return SharedDatabase(WebDatabase('db'));
}
