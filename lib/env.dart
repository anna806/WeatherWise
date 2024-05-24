import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
final class Env {
  @EnviedField(varName: 'API_key', obfuscate: true)
  static String weatherApiKey = _Env.weatherApiKey;
}