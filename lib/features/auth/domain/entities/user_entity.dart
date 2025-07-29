import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

@freezed
class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String uid,
    required String email,
    String? displayName,
    String? photoURL,
    required bool emailVerified,
    String? phoneNumber,
    required DateTime createdAt,
    DateTime? lastSignInAt,
    Map<String, dynamic>? customClaims,
  }) = _UserEntity;
}
