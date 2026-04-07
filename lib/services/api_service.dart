import 'package:dio/dio.dart';
import 'storage_service.dart';

class ApiService {
  static const String _baseUrl = 'https://api.unibite.app/v1';

  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl:        _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept':       'application/json',
      },
    ));

    _dio.interceptors.addAll([
      _AuthInterceptor(),
      LogInterceptor(
        requestBody:  true,
        responseBody: true,
        logPrint: (o) => debugPrint(o.toString()),
      ),
    ]);
  }

  Future<Response> get(String path,
      {Map<String, dynamic>? params}) async {
    return _dio.get(path, queryParameters: params);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return _dio.delete(path);
  }
}

class _AuthInterceptor extends Interceptor {
  final _storage = StorageService();

  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler) async {
    final token = await _storage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _storage.clearToken();
    }
    handler.next(err);
  }
}

// ignore: avoid_print
void debugPrint(String msg) => print(msg);
