import '../../../domain/entities/kichwa-ecuador/phoneme_unit.dart';
import '../../../domain/repositories/kichwa-ecuador/audio_bank_repository.dart';

class LocalAudioBank implements AudioBankRepository {//TODO CHAT
  static const String base = "assets/audio/phonemes";
  @override
  String resolveAsset(PhonemeUnit unit) {
    final name = unit.key.isEmpty ? "_beep" : unit.key;
    return "$base/$name.wav";
  }
}
