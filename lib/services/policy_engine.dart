
// Defines the available cryptographic algorithms
enum CryptoAlgorithm {
  ECC, // Elliptic Curve Cryptography (Classical)
  Kyber, // Post-Quantum Key Encapsulation
  Dilithium, // Post-Quantum Digital Signature
  None, // No encryption
}

// Represents the real-time context for making policy decisions
class PolicyContext {
  final double batteryLevel; // 0.0 to 1.0
  final double messageUrgency; // 0.0 to 1.0
  final double peerTrustLevel; // 0.0 to 1.0

  PolicyContext({
    this.batteryLevel = 1.0,
    this.messageUrgency = 0.2,
    this.peerTrustLevel = 0.5,
  });

  PolicyContext copyWith({
    double? batteryLevel,
    double? messageUrgency,
    double? peerTrustLevel,
  }) {
    return PolicyContext(
      batteryLevel: batteryLevel ?? this.batteryLevel,
      messageUrgency: messageUrgency ?? this.messageUrgency,
      peerTrustLevel: peerTrustLevel ?? this.peerTrustLevel,
    );
  }
}

// The engine that makes security decisions based on policy and context
class PolicyEngine {
  CryptoAlgorithm getPreferredAlgorithm(PolicyContext context) {
    // This is the core logic for crypto-agility.
    // It demonstrates how context factors can influence algorithm selection.

    // Rule 1: If battery is critically low, prioritize energy efficiency.
    if (context.batteryLevel < 0.2) {
      return CryptoAlgorithm.ECC;
    }

    // Rule 2: For high-urgency, high-trust messages, use the strongest PQC.
    if (context.messageUrgency > 0.8 && context.peerTrustLevel > 0.8) {
      return CryptoAlgorithm.Kyber; // Using Kyber for encapsulation as an example
    }

    // Rule 3: If urgency is moderate, balance performance and security.
    if (context.messageUrgency > 0.5) {
      return CryptoAlgorithm.ECC;
    }

    // Default Rule: Use a balanced, classical algorithm for routine communication.
    return CryptoAlgorithm.ECC;
  }

  // Helper to get a string representation for UI
  String getAlgorithmName(CryptoAlgorithm algorithm) {
    switch (algorithm) {
      case CryptoAlgorithm.ECC:
        return 'ECC (Classical)';
      case CryptoAlgorithm.Kyber:
        return 'PQC-Kyber';
      case CryptoAlgorithm.Dilithium:
        return 'PQC-Dilithium';
      case CryptoAlgorithm.None:
        return 'Unencrypted';
    }
  }
}
