import 'package:indowater_mobile/services/api_service.dart';
import 'package:indowater_mobile/services/meter_service.dart';
import 'package:indowater_mobile/services/payment_service.dart';
import 'package:indowater_mobile/services/notification_service.dart';
import 'package:indowater_mobile/providers/auth_provider.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  ApiService,
  MeterService,
  PaymentService,
  NotificationService,
  AuthProvider,
])
void main() {}