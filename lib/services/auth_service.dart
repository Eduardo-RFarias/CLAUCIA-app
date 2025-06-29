import 'dart:convert';
import '../models/user_model.dart';

class AuthService {
  // Mock users for demonstration
  final List<Map<String, dynamic>> _mockUsers = [
    {
      'id': 1,
      'name': 'John Doe',
      'email': 'john@example.com',
      'password': 'password123',
      'profilePicture': "https://robohash.org/john_doe?set=set5",
    },
    {
      'id': 2,
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'password': 'password456',
      'profilePicture': "https://robohash.org/jane_smith?set=set5",
    },
    {
      'id': 3,
      'name': 'Test User',
      'email': 'test@test.com',
      'password': 'test123',
      'profilePicture': "https://robohash.org/test_user?set=set5",
    },
  ];

  Future<User> login(String email, String password) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock authentication logic
      final mockUser = _mockUsers.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
        orElse: () => throw Exception('Invalid credentials'),
      );

      // Generate a mock token
      final token = base64Encode(
        utf8.encode(
          '${mockUser['email']}:${DateTime.now().millisecondsSinceEpoch}',
        ),
      );

      return User(
        id: mockUser['id'],
        name: mockUser['name'],
        email: mockUser['email'],
        token: token,
        profilePicture: mockUser['profilePicture'],
      );
    } catch (e) {
      if (e.toString().contains('Invalid credentials')) {
        throw Exception('Invalid email or password');
      }
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // In real implementation, this would be:
      /*
      await _dio.post('$_baseUrl/auth/logout');
      */
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  Future<User> getCurrentUser(String token) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock user validation
      final decodedToken = utf8.decode(base64Decode(token));
      final email = decodedToken.split(':')[0];

      final mockUser = _mockUsers.firstWhere(
        (user) => user['email'] == email,
        orElse: () => throw Exception('Invalid token'),
      );

      return User(
        id: mockUser['id'],
        name: mockUser['name'],
        email: mockUser['email'],
        token: token,
        profilePicture: mockUser['profilePicture'],
      );

      // In real implementation, this would be:
      /*
      final response = await _dio.get(
        '$_baseUrl/auth/me',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      } else {
        throw Exception('Failed to get user info');
      }
      */
    } catch (e) {
      throw Exception('Failed to get user info: $e');
    }
  }

  Future<User> updateProfilePicture(String token, String imagePath) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock user validation
      final decodedToken = utf8.decode(base64Decode(token));
      final email = decodedToken.split(':')[0];

      final mockUserIndex = _mockUsers.indexWhere(
        (user) => user['email'] == email,
      );

      if (mockUserIndex == -1) {
        throw Exception('Invalid token');
      }

      // Update the mock user's profile picture
      _mockUsers[mockUserIndex]['profilePicture'] = imagePath;
      final updatedUser = _mockUsers[mockUserIndex];

      return User(
        id: updatedUser['id'],
        name: updatedUser['name'],
        email: updatedUser['email'],
        token: token,
        profilePicture: updatedUser['profilePicture'],
      );

      // In real implementation, this would be:
      /*
      final formData = FormData.fromMap({
        'profilePicture': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dio.put(
        '$_baseUrl/user/profile-picture',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      } else {
        throw Exception('Failed to update profile picture');
      }
      */
    } catch (e) {
      throw Exception('Failed to update profile picture: $e');
    }
  }

  Future<void> changePassword(
    String token,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock user validation
      final decodedToken = utf8.decode(base64Decode(token));
      final email = decodedToken.split(':')[0];

      final mockUserIndex = _mockUsers.indexWhere(
        (user) => user['email'] == email,
      );

      if (mockUserIndex == -1) {
        throw Exception('Invalid token');
      }

      // Verify current password
      if (_mockUsers[mockUserIndex]['password'] != currentPassword) {
        throw Exception('Current password is incorrect');
      }

      // Update password
      _mockUsers[mockUserIndex]['password'] = newPassword;

      // In real implementation, this would be:
      /*
      final response = await _dio.put(
        '$_baseUrl/user/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to change password');
      }
      */
    } catch (e) {
      if (e.toString().contains('Current password is incorrect')) {
        throw Exception('Current password is incorrect');
      }
      throw Exception('Failed to change password: $e');
    }
  }
}
