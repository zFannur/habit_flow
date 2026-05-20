enum DeviceLinkFailReason {
  network,
  expired,
  consumed,
  rateLimited,
  unknown,
}

sealed class DeviceLinkState {
  const DeviceLinkState();

  const factory DeviceLinkState.idle() = DeviceLinkIdle;
  const factory DeviceLinkState.opening() = DeviceLinkOpening;
  const factory DeviceLinkState.waiting({
    required String token,
    required String deepLink,
    required DateTime expiresAt,
  }) = DeviceLinkWaiting;
  const factory DeviceLinkState.success() = DeviceLinkSuccess;
  const factory DeviceLinkState.failed(DeviceLinkFailReason reason) = DeviceLinkFailed;
}

final class DeviceLinkIdle extends DeviceLinkState {
  const DeviceLinkIdle();
}

final class DeviceLinkOpening extends DeviceLinkState {
  const DeviceLinkOpening();
}

final class DeviceLinkWaiting extends DeviceLinkState {
  const DeviceLinkWaiting({
    required this.token,
    required this.deepLink,
    required this.expiresAt,
  });

  final String token;
  final String deepLink;
  final DateTime expiresAt;
}

final class DeviceLinkSuccess extends DeviceLinkState {
  const DeviceLinkSuccess();
}

final class DeviceLinkFailed extends DeviceLinkState {
  const DeviceLinkFailed(this.reason);

  final DeviceLinkFailReason reason;
}
