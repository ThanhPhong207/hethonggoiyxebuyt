import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Singleton instance
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() => _instance;

  SupabaseService._internal();

  /// Initialize Supabase
  /// Gọi hàm này trong main.dart trước khi runApp()
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://nobvhzauelqfndcgseta.supabase.co',
      anonKey: 'sb_publishable_ePyyiU8nlTW7--WllSbbuQ_OcgmuLKf',
    );
  }

  /// Getter for the client
  static SupabaseClient get client => Supabase.instance.client;

  // --- Auth Methods ---

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUpWithEmail(String email, String password, {Map<String, dynamic>? data}) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  User? get currentUser => client.auth.currentUser;

  // --- Data Methods ---

  Future<List<Map<String, dynamic>>> getBusRoutes() async {
    final response = await client.from('bus_routes').select();
    return response;
  }

  /// Tìm kiếm tuyến theo tên hoặc mã
  Future<List<Map<String, dynamic>>> searchRoutes(String query) async {
    final response = await client
        .from('bus_routes')
        .select()
        .or('name.ilike.%$query%,route_code.ilike.%$query%');
    return response;
  }

  Future<void> insertBusRoute(Map<String, dynamic> data) async {
    await SupabaseService.client.from('bus_routes').insert(data);
  }

  Future<void> updateBusRoute(int id, Map<String, dynamic> data) async {
    await SupabaseService.client.from('bus_routes').update(data).eq('id', id);
  }

  Future<void> deleteBusRoute(int id) async {
    await SupabaseService.client.from('bus_routes').delete().eq('id', id);
  }
}
