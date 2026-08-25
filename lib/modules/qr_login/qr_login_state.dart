enum QrLoginPhase { loading, waiting, scanned, expired, success }

class QrLoginState {
  const QrLoginState({
    required this.phase,
    required this.statusText,
    this.qrImageDataUri,
  });

  const QrLoginState.loading()
    : this(phase: QrLoginPhase.loading, statusText: '正在加载二维码…');

  final QrLoginPhase phase;
  final String statusText;
  final String? qrImageDataUri;

  QrLoginState copyWith({
    QrLoginPhase? phase,
    String? statusText,
    String? qrImageDataUri,
  }) {
    return QrLoginState(
      phase: phase ?? this.phase,
      statusText: statusText ?? this.statusText,
      qrImageDataUri: qrImageDataUri ?? this.qrImageDataUri,
    );
  }
}
