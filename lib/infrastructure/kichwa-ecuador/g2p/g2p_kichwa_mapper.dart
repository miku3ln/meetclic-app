import '../../../domain/entities/kichwa-ecuador/audio_item.dart';
import '../../../domain/entities/kichwa-ecuador/g2p_output.dart';
import '../../../domain/entities/kichwa-ecuador/grapheme_token.dart'; //TODO CHAT
import '../../../domain/entities/kichwa-ecuador/phoneme_unit.dart';
import '../../../domain/services/kichwa-ecuador/g2p_service.dart';
import '../../../domain/value_objects/kichwa-ecuador/word_input.dart';
import '../../../infrastructure/kichwa-ecuador/audio/local_audio_bank.dart';
import 'segmenter.dart';

// --- Parámetros auto para KAMU ---
class _KAMUParams {
  final bool preKichwa;
  final bool amazonico;
  final int maxPerSegment;
  final int maxVariants;

  const _KAMUParams({
    required this.preKichwa,
    required this.amazonico,
    required this.maxPerSegment,
    required this.maxVariants,
  });
}

// Salida de variantes con audio
class VariantWithAudio {
  final String form;               // "ačupalya"
  final List<AudioItem> audioPlan; // rutas por fonema
  final String note;               // explicación corta
  const VariantWithAudio({
    required this.form,
    required this.audioPlan,
    required this.note,
  });
}

class G2PKichwaMapper implements G2PService {
  final Segmenter _segmenter;
  final LocalAudioBank? _audio;

  // flags “narrow”
  final bool enableNarrowPhonology;      // n→ŋ (final/ante velar)
  // reglas /k/ (si usas analyze() “básico”)
  final bool kVoicingAfterNasal;
  final bool kIntervocalicVoicing;
  final bool kSpirantizeBeforeT;
  final bool kSpirantizeBeforeCH;

  // símbolos configurables
  final String llSymbol; // "ʎ" o "ʝ"
  final String hSymbol;  // "h" o "x"
  final bool repairLyToLl;
  final bool mapXtoH;

  G2PKichwaMapper(
      this._segmenter, {
        LocalAudioBank? audioBank,
        this.enableNarrowPhonology = false,
        this.kVoicingAfterNasal = false,
        this.kIntervocalicVoicing = false,
        this.kSpirantizeBeforeT = false,
        this.kSpirantizeBeforeCH = false,
        this.llSymbol = "ʎ",
        this.hSymbol = "h",
        this.repairLyToLl = true,
        this.mapXtoH = true,
      }) : _audio = audioBank;

  // =======================
  // Utils de mapeo / audio
  // =======================

  String _replaceLlWithLy(String s) {
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final ch = s[i];
      if (ch == 'ʎ') {
        final next = (i + 1 < s.length) ? s[i + 1] : '';
        if ('aiueo'.contains(next)) {
          buf.write('ly');
          continue;
        } else {
          buf.write('ly');
        }
      } else {
        buf.write(ch);
      }
    }
    return buf.toString();
  }

  String _replaceLlWithILy(String s) {
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final ch = s[i];
      if (ch == 'ʎ') {
        final next = (i + 1 < s.length) ? s[i + 1] : '';
        if ('aiueo'.contains(next)) {
          buf.write('i');
          buf.write('ly');
          continue;
        } else {
          buf.write('i');
          buf.write('ly');
        }
      } else {
        buf.write(ch);
      }
    }
    return buf.toString();
  }

  List<AudioItem> _audioPlanFromPhonemic(String phonemic) {
    final plan = <AudioItem>[];
    int i = 0;
    while (i < phonemic.length) {
      if (i + 1 < phonemic.length &&
          phonemic[i] == 't' && phonemic[i + 1] == 's') {
        plan.add(_audioFromSymbol('ts'));
        i += 2;
        continue;
      }
      final ch = phonemic[i];
      plan.add(_audioFromSymbol(ch));
      i += 1;
    }
    return plan;
  }

  AudioItem _audioFromSymbol(String sym) {
    final keys = <String, String>{
      'a':'a','i':'i','u':'u','e':'e','o':'o',
      'p':'p','t':'t','k':'k','q':'q','g':'g',
      'm':'m','n':'n','l':'l','s':'s','z':'z','w':'w',
      'j':'y','y':'y','ɾ':'r','r':'rr',
      'č':'ch','š':'sh','ž':'zh','ɲ':'ny','ʎ':'ll','ʝ':'ll',
      'x':'h','ŋ':'n','ts':'ts',
    };
    final key = keys[sym] ?? sym;
    final asset = (_audio != null)
        ? _audio!.resolveAsset(
      PhonemeUnit(grapheme: sym, ipa: "/$sym/", symbol: sym, key: key),
    )
        : "assets/audio/phonemes/$key.wav";
    return AudioItem(grapheme: sym, ipa: "/$sym/", assetPath: asset);
  }

  List<VariantWithAudio> _dedupVariants(List<VariantWithAudio> items) {
    final seen = <String>{};
    final out = <VariantWithAudio>[];
    for (final v in items) {
      if (seen.add(v.form)) out.add(v);
    }
    return out;
  }

  // =======================
  // Auto–parámetros
  // =======================

  _KAMUParams _autoParams(String input) {
    final base = analyze(input);
    final canon = base.phonemic;           // ej: ačačay
    final toks  = _tokenizePhonemicSymbols(canon);

    // Heurística preKichwa
    bool inferPreKichwa = false;
    if (canon.contains('ts') || canon.contains('z') || canon.contains('ž')) {
      inferPreKichwa = true;
    } else if (RegExp(r'č[aiueo]?č').hasMatch(canon) && canon.length <= 7) {
      // p.ej. ačačay → atsatsay
      inferPreKichwa = true;
    }

    // Heurística dialecto amazónico (aw finales, ng ~ ŋg, etc.)
    final looksAmazon =
        canon.endsWith('aw') ||
            canon.contains('aw') && canon.length <= 7 ||
            canon.contains('ŋg') ||
            RegExp(r'kaŋg[auo]').hasMatch(canon);

    // abanico por segmento
    final hasRich = canon.contains('č') || canon.contains('ʎ') || canon.contains('ʝ');
    int mps = hasRich && canon.length <= 7 ? 3 : 2;
    if (canon.length >= 10) mps = 2;

    // estimar combinaciones (techo variantes)
    int est = 1;
    for (final t in toks) {
      final vList = _KAMU_VARIANTS[t] ?? [t];
      final contrib = (vList.length > 1) ? (vList.length.clamp(1, mps) as int) : 1;
      est *= contrib;
      if (est > 80) { est = 80; break; }
    }
    final maxVars = (est.clamp(12, 40) as int);

    return _KAMUParams(
      preKichwa: inferPreKichwa,
      amazonico: looksAmazon,
      maxPerSegment: mps,
      maxVariants: maxVars,
    );
  }

  // API: totalmente automático
  List<VariantWithAudio> analyzeSmart(String word) {
    final p = _autoParams(word);
    return analyzeWithVariantsAndAudioKAMU(
      word,
      preKichwa: p.preKichwa,
      maxPerSegment: p.maxPerSegment,
      maxVariants: p.maxVariants,
      amazonico: p.amazonico,
    );
  }

  // =======================
  // analyze() básico
  // =======================

  static const Map<String, ({String ipa, String symbol, String key})> _map = {
    "a": (ipa: "a", symbol: "a", key: "a"),
    "i": (ipa: "i", symbol: "i", key: "i"),
    "u": (ipa: "u", symbol: "u", key: "u"),
    "p": (ipa: "p", symbol: "p", key: "p"),
    "t": (ipa: "t", symbol: "t", key: "t"),
    "k": (ipa: "k", symbol: "k", key: "k"),
    "q": (ipa: "q", symbol: "q", key: "q"),
    "ch": (ipa: "ʧ", symbol: "č", key: "ch"),
    "h": (ipa: "h", symbol: "h", key: "h"),
    "s": (ipa: "s", symbol: "s", key: "s"),
    "sh": (ipa: "ʃ", symbol: "š", key: "sh"),
    "m": (ipa: "m", symbol: "m", key: "m"),
    "n": (ipa: "n", symbol: "n", key: "n"),
    "ñ": (ipa: "ɲ", symbol: "ɲ", key: "ny"),
    "l": (ipa: "l", symbol: "l", key: "l"),
    "ll": (ipa: "ʎ", symbol: "ʎ", key: "ll"),
    "r": (ipa: "ɾ", symbol: "ɾ", key: "r"),
    "rr": (ipa: "r", symbol: "r", key: "rr"),
    "w": (ipa: "w", symbol: "w", key: "w"),
    "y": (ipa: "j", symbol: "j", key: "y"),
    "ts": (ipa: "ts", symbol: "ts", key: "ts"),
    "z": (ipa: "z", symbol: "z", key: "z"),
    "zh": (ipa: "ʒ", symbol: "ž", key: "zh"),
    "e": (ipa: "e", symbol: "e", key: "e"),
    "o": (ipa: "o", symbol: "o", key: "o"),
  };

  @override
  G2POutput analyze(String word) {
    final normalized = _normalizeInput(word);
    final tokens = _segmenter.segment(WordInput(normalized));

    final units = <PhonemeUnit>[];
    final outTokens = <String>[];

    for (final t in tokens) {
      var spec = _map[t.value];
      if (spec == null) {
        units.add(PhonemeUnit(grapheme: t.value, ipa: "?", symbol: "�", key: "_beep"));
        outTokens.add(t.value);
        continue;
      }
      if (t.value == 'll') {
        spec = (ipa: spec.ipa, symbol: llSymbol, key: spec.key);
      } else if (t.value == 'h') {
        spec = (ipa: spec.ipa, symbol: hSymbol, key: spec.key);
      }
      units.add(PhonemeUnit(
        grapheme: t.value, ipa: "/${spec.ipa}/", symbol: spec.symbol, key: spec.key,
      ));
      outTokens.add(t.value);
    }

    final canonical = enableNarrowPhonology
        ? _applyNarrowPhonology(units)
        : units.map((u) => u.symbol).join();

    final withKAllophony = _applyKAllophony(units, canonical);

    final audioPlan = <AudioItem>[];
    if (_audio != null) {
      for (final u in units) {
        audioPlan.add(AudioItem(
          grapheme: u.grapheme,
          ipa: u.ipa,
          assetPath: _audio!.resolveAsset(u),
        ));
      }
    }

    return G2POutput(tokens: outTokens, phonemic: withKAllophony, audioPlan: audioPlan);
  }

  String _normalizeInput(String raw) {
    var s = raw.trim().toLowerCase();
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    s = s.replaceAll(' l y', ' ly').replaceAll('l y ', 'ly ').replaceAll('l y', 'ly');
    if (repairLyToLl) {
      s = s.replaceAllMapped(RegExp(r'(^|[aiueo])ly(?=[aiueo]|$)'), (m) => '${m.group(1)}ll');
    }
    if (mapXtoH) s = s.replaceAll('x', 'h');
    s = s.replaceAll('ž', 'zh').replaceAll('ʒ', 'zh');
    return s;
  }

  String _applyNarrowPhonology(List<PhonemeUnit> units) {
    final buf = StringBuffer();
    for (var i = 0; i < units.length; i++) {
      final cur = units[i];
      var sym = cur.symbol;
      if (cur.grapheme == 'n') {
        final hasNext = i + 1 < units.length;
        final next = hasNext ? units[i + 1] : null;
        final nextKey = next?.key ?? '';
        final isWordFinal = !hasNext;
        final beforeVelar = nextKey == 'k' || nextKey == 'q' || nextKey == 'g';
        if (isWordFinal || beforeVelar) sym = 'ŋ';
      }
      buf.write(sym);
    }
    return buf.toString();
  }

  String _applyKAllophony(List<PhonemeUnit> units, String current) {
    if (!(kVoicingAfterNasal || kIntervocalicVoicing || kSpirantizeBeforeT || kSpirantizeBeforeCH)) {
      return current;
    }
    final out = current.split('');
    for (int i = 0; i < units.length; i++) {
      if (units[i].grapheme != 'k') continue;
      final prevChar = i > 0 ? out[i - 1] : '';
      final nextChar = i + 1 < out.length ? out[i + 1] : '';
      final prevIsV = 'aiueo'.contains(prevChar);
      final nextIsV = 'aiueo'.contains(nextChar);
      final prevIsNasal = (prevChar == 'n' || prevChar == 'ŋ' || prevChar == 'ɲ');
      final nextIsT = (nextChar == 't');
      final nextIsC = (nextChar == 'č');
      if (kVoicingAfterNasal && prevIsNasal) {
        out[i] = 'g';
      } else if (kIntervocalicVoicing && prevIsV && nextIsV) {
        out[i] = 'g';
      } else if (kSpirantizeBeforeT && nextIsT) {
        out[i] = 'x';
      } else if (kSpirantizeBeforeCH && nextIsC) {
        out[i] = 'x';
      }
    }
    return out.join();
  }

  // =======================
  // Variantes “KAMU”
  // =======================

  List<VariantWithAudio> analyzeWithVariantsAndAudio(String word) {
    final base = analyze(word);
    final baseForm = base.phonemic;

    final out = <VariantWithAudio>[];
    out.add(VariantWithAudio(
      form: baseForm,
      audioPlan: _audioPlanFromPhonemic(baseForm),
      note: "Forma fonémica canónica.",
    ));

    final variants = <String>{};

    final withLl = baseForm.replaceAll('ʝ', 'ʎ');
    if (withLl.contains('ʎ')) {
      variants.add(_replaceLlWithLy(withLl));
      variants.add(withLl.replaceAll('ʎ', 'ž'));
      variants.add(_replaceLlWithILy(withLl));
    }

    final nasal = _applyNasalAllophonyString(baseForm);
    if (nasal != baseForm) variants.add(nasal);

    for (final v in generateKVariants(baseForm)) {
      variants.add(v);
    }

    if (baseForm.contains('h')) {
      variants.add(baseForm.replaceAll('h', 'x'));
    }

    variants.remove(baseForm);

    for (final v in variants) {
      out.add(VariantWithAudio(
        form: v,
        audioPlan: _audioPlanFromPhonemic(v),
        note: _shortNote(baseForm, v),
      ));
    }
    return _dedupVariants(out);
  }

  String _applyNasalAllophonyString(String s) {
    final chars = s.split('');
    for (int i = 0; i < chars.length; i++) {
      if (chars[i] != 'n') continue;
      final next = i + 1 < chars.length ? chars[i + 1] : '';
      final isFinal = i + 1 == chars.length;
      final beforeVelar = next == 'k' || next == 'q' || next == 'g';
      if (isFinal || beforeVelar) chars[i] = 'ŋ';
    }
    return chars.join();
  }

  String _shortNote(String base, String v) {
    if (v.contains('ly') && base.replaceAll('ʝ', 'ʎ').contains('ʎ')) return "ll→ly";
    if (v.contains('ž') && base.replaceAll('ʝ', 'ʎ').contains('ʎ')) return "ll→ž";
    if (v.contains('i') && v.contains('ly') && base.replaceAll('ʝ', 'ʎ').contains('ʎ')) return "ll→i·ly";
    if (v.contains('ŋ') && !base.contains('ŋ')) return "n→ŋ";
    if (v.contains('g') && !base.contains('g')) return "k→g";
    if (v.contains('x') && !base.contains('x')) return "k→x";
    if (v.contains('x') && base.contains('h')) return "h→x";
    return "variación fonética";
  }

  List<String> generateKVariants(String phonemicBase) {
    final chars = phonemicBase.split('');
    final variants = <String>{phonemicBase};

    for (int i = 0; i < chars.length; i++) {
      if (chars[i] != 'k') continue;
      final prev = i > 0 ? chars[i - 1] : '';
      final next = i + 1 < chars.length ? chars[i + 1] : '';
      final prevIsV = 'aiueo'.contains(prev);
      final nextIsV = 'aiueo'.contains(next);
      final prevIsNasal = (prev == 'n' || prev == 'ŋ' || prev == 'ɲ');
      final nextIsCH = (next == 'č');

      if ((prevIsV && (nextIsV || nextIsCH)) || prevIsNasal) {
        final v = [...chars];
        v[i] = 'g';
        variants.add(v.join());
      }
      if (next == 't' || nextIsCH || next == 'y' || next == 'ʎ' || next == 'l') {
        final v = [...chars];
        v[i] = 'x';
        variants.add(v.join());
      }
      if (next == 'm' || next == 'y' || next == 'ʎ' || next == 'l') {
        final v = [...chars];
        v[i] = '';
        variants.add(v.join());
      }
    }
    variants.remove(phonemicBase);
    return variants.toList();
  }

  // =======================
  // KAMU (PDF) – Catálogo y Reglas
  // =======================

  static const Map<String, List<String>> _KAMU_VARIANTS = {
    "p": ["p","ph","f","b"],
    "t": ["t","th","d","r"],
    "k": ["k","kh","x","g",""],
    "q": ["q","k","kh","x"],
    "č": ["č","š"],                  // 'ts' se agrega si preKichwa
    "h": ["h","x",""],
    "s": ["s","š"],
    "š": ["š","s"],
    "m": ["m","n"],
    "n": ["n","m"],
    "ñ": ["ñ","n"],
    "l": ["l"],
    "ʎ": ["ʎ","l"],                 // ly/ž/ily por reglas
    "ɾ": ["ɾ","r"],
    "r": ["r","ɾ"],
    "w": ["w","b",""],
    "y": ["y"],
    "i": ["i"],
    "u": ["u"],
    "a": ["a"],
  };

  static final List<_Rule> _RULES_KAMU = [
    _Rule(
      id: "Y_FINAL_AY_TO_AW",
      match: (seg, i, toks) {
        if (seg != "y" || i != toks.length - 1) return false;
        final prev = i > 0 ? toks[i - 1] : "";
        return prev == "a";
      },
      apply: (_) => ["y","w"],
      explain: "…ay → …aw",
      example: "ačačay → ačačaw",
    ),
    _Rule(
      id: "I_EPENTHESIS_CHK",
      match: (seg, i, toks) => seg == "č" && i + 1 < toks.length && toks[i + 1] == "k",
      apply: (_) => ["či"],
      explain: "epéntesis /i/ entre č y k",
      example: "ačka → ačika",
    ),
    _Rule(
      id: "K_FINAL_XG_DEL",
      match: (seg, i, toks) => seg == "k" && i == toks.length - 1,
      apply: (_) => ["x","g",""],
      explain: "k final → x/g/∅",
      example: "ačik → ačix / ačig / ači",
    ),
    _Rule(
      id: "K_BEFORE_Y_L_LY_LL",
      match: (seg, i, toks) {
        if (seg != "k" || i + 1 >= toks.length) return false;
        final next = toks[i + 1];
        return next == "y" || next == "ʎ" || next == "ly" || next == "l";
      },
      apply: (_) => ["x","g",""],
      explain: "k → x/g/∅ ante y/ʎ/ly/l",
      example: "…kʎa → …xʎa / …gʎa / …ʎa",
    ),
    _Rule(
      id: "K_BEFORE_CH",
      match: (seg, i, toks) => seg == "k" && i + 1 < toks.length && toks[i + 1] == "č",
      apply: (_) => ["x","g"],
      explain: "k → x/g ante č",
      example: "ačukča → ačuxča / ačugča",
    ),
    _Rule(
      id: "K_BEFORE_I",
      match: (seg, i, toks) => seg == "k" && i + 1 < toks.length && toks[i + 1] == "i",
      apply: (_) => ["x","k"],
      explain: "k → x ante i",
      example: "akichana → axičana",
    ),
    _Rule(
      id: "K_AFTER_NASAL_G",
      match: (seg, i, toks) {
        if (seg != "k" || i == 0) return false;
        final prev = toks[i - 1];
        return prev == "n" || prev == "ŋ" || prev == "ɲ";
      },
      apply: (_) => ["g","k"],
      explain: "k → g después de nasal",
      example: "kaŋkik → kaŋgik",
    ),
    _Rule(
      id: "K_BEFORE_M_DEL",
      match: (seg, i, toks) => seg == "k" && i + 1 < toks.length && toks[i + 1] == "m",
      apply: (_) => ["","k"],
      explain: "k → ∅ ante m",
      example: "ačikmama → ačimama",
    ),
    _Rule(
      id: "LL_TO_LY_ANY",
      match: (seg, i, toks) => seg == "ʎ",
      apply: (_) => ["ʎ","ly"],
      explain: "ll → ly (opción)",
      example: "…ʎa → …lya",
    ),
    _Rule(
      id: "LL_TO_ZH",
      match: (seg, i, toks) => seg == "ʎ",
      apply: (_) => ["ʎ","ž"],
      explain: "ll → ž (fricativa)",
      example: "ačupaʎa → ačupaža",
    ),
    _Rule(
      id: "LL_TO_ILY_BEFORE_V",
      match: (seg, i, toks) {
        if (seg != "ʎ" || i + 1 >= toks.length) return false;
        final nxt = toks[i + 1];
        return "aiueo".contains(nxt);
      },
      apply: (_) => ["ʎ","ily"],
      explain: "ʎV → i·ly·V",
      example: "…ʎa → …ilya",
    ),
    _Rule(
      id: "H_ALT",
      match: (seg, _, __) => seg == "h",
      apply: (_) => ["h","x",""],
      explain: "h ↔ x/∅",
      example: "hallmay → xallmay / 0allmay",
    ),
    _Rule(
      id: "S_SH",
      match: (seg, _, __) => seg == "s" || seg == "š",
      apply: (seg) => seg == "s" ? ["s","š"] : ["š","s"],
      explain: "s ↔ š",
      example: "maskay ~ maškay",
    ),
    _Rule(
      id: "I_TO_E_AFTER_AFF",
      match: (seg, i, toks) {
        if (seg != "i" || i == 0) return false;
        final prev = toks[i - 1];
        return prev == "č" || prev == "ts";
      },
      apply: (_) => ["i","e"],
      explain: "i ↔ e tras affricada",
      example: "ačira → ačera",
    ),
    _Rule(
      id: "PROTHESIS_X_AK",
      match: (seg, i, toks) => i == 0 && seg == "a" && (toks.length > 1 && toks[1] == "k"),
      apply: (_) => ["a","xa"],
      explain: "prótesis x- ante ak…",
      example: "akapana → xakapana",
    ),
    _Rule(
      id: "M_BEFORE_P",
      match: (seg, i, toks) =>
      (seg == "n" || seg == "m") && (i + 1 < toks.length && toks[i + 1] == "p"),
      apply: (_) => ["m"],
      explain: "…mp…",
      example: "…mp…",
    ),
  ];

  List<String> _tokenizePhonemicSymbols(String s) {
    final out = <String>[];
    int i = 0;
    while (i < s.length) {
      if (i + 1 < s.length && s[i] == 't' && s[i + 1] == 's') {
        out.add("ts"); i += 2; continue;
      }
      if (i + 1 < s.length && s[i] == 'l' && s[i + 1] == 'y') {
        out.add("ly"); i += 2; continue;
      }
      out.add(s[i]);
      i++;
    }
    return out;
  }

  List<(String, List<String>)> _segmentVariantsKAMU(
      String seg,
      int i,
      List<String> toks, {
        required bool preKichwa,
        required int maxPerSegment,
      }) {
    List<String> baseList = List.of(_KAMU_VARIANTS[seg] ?? [seg]);

    if (preKichwa && seg == "č") {
      if (!baseList.contains("ts")) baseList.add("ts");
    }

    if (seg == "k") {
      final isFinal = (i == toks.length - 1);
      final next = !isFinal ? toks[i + 1] : "";
      if (isFinal) {
        baseList = ["x","g","", "k","kh"];
      } else if (next == "y" || next == "ʎ" || next == "ly" || next == "l") {
        baseList = ["x","g","", "k","kh"];
      } else if (next == "č" || next == "i") {
        baseList = ["x","g","k","kh"];
      }
    }

    final out = <(String, List<String>)>[];

    int emitted = 0;
    for (final v in baseList) {
      out.add((v, const <String>[]));
      emitted++;
      if (emitted >= maxPerSegment) break;
    }

    for (final r in _RULES_KAMU) {
      if (r.match(seg, i, toks)) {
        int count = 0;
        for (final v in r.apply(seg)) {
          out.add((v, <String>[r.id]));
          count++;
          if (count >= maxPerSegment) break;
        }
      }
    }

    final seen = <String>{};
    return out.where((e) => seen.add(e.$1)).toList();
  }

  void _buildKAMU(
      List<String> toks,
      int i,
      String acc,
      List<String> rulesPath,
      List<_VarTmp> out, {
        required bool preKichwa,
        required int maxPerSegment,
        required int maxVariants,
      }) {
    if (out.length >= maxVariants) return;
    if (i == toks.length) {
      out.add(_VarTmp(acc, rulesPath));
      return;
    }
    final seg = toks[i];
    final alts = _segmentVariantsKAMU(
      seg, i, toks,
      preKichwa: preKichwa, maxPerSegment: maxPerSegment,
    );

    for (final alt in alts) {
      if (out.length >= maxVariants) break;
      final nextRules = alt.$2.isEmpty ? rulesPath : [...rulesPath, ...alt.$2];
      _buildKAMU(
        toks, i + 1, acc + alt.$1, nextRules, out,
        preKichwa: preKichwa,
        maxPerSegment: maxPerSegment,
        maxVariants: maxVariants,
      );
    }
  }

  // (opcional) post-expander amazónico …aw → …uy (+ alzamiento previo)
  List<_VarTmp> _postExpandDialect(List<_VarTmp> inVars, {bool amazonico = false}) {
    if (!amazonico) return inVars;
    final out = <_VarTmp>[...inVars];
    final seen = out.map((v) => v.form).toSet();

    for (final v in inVars) {
      if (v.form.endsWith("aw")) {
        final stem = v.form.substring(0, v.form.length - 2);
        String raised = stem;
        raised = raised.replaceAll(RegExp(r"čača$"), "čuču");
        final alt2 = raised + "uy";
        if (seen.add(alt2)) {
          out.add(_VarTmp(alt2, [...v.ruleIds, "AMZ_AW_TO_UY(+raise)"]));
        }
      }
    }
    return out;
  }

  // API pública KAMU
  List<VariantWithAudio> analyzeWithVariantsAndAudioKAMU(
      String word, {
        bool preKichwa = false,
        int maxPerSegment = 2,
        int maxVariants = 30,
        bool amazonico = false,
      }) {
    final base = analyze(word);
    final canon = base.phonemic;

    final results = <VariantWithAudio>[];
    results.add(VariantWithAudio(
      form: canon,
      audioPlan: _audioPlanFromPhonemic(canon),
      note: "Forma fonémica canónica (base).",
    ));

    final toks = _tokenizePhonemicSymbols(canon);
    var tmp = <_VarTmp>[];
    _buildKAMU(
      toks, 0, "", <String>[], tmp,
      preKichwa: preKichwa,
      maxPerSegment: maxPerSegment,
      maxVariants: maxVariants,
    );

    tmp = _postExpandDialect(tmp, amazonico: amazonico);

    final seen = <String>{canon};
    for (final v in tmp) {
      if (!seen.add(v.form)) continue;
      final note = v.ruleIds.isEmpty
          ? "Variante según catálogo KAMU."
          : "Variante KAMU: ${v.ruleIds.join(", ")}";
      results.add(VariantWithAudio(
        form: v.form,
        audioPlan: _audioPlanFromPhonemic(v.form),
        note: note,
      ));
    }
    return results;
  }
}

// Tipos para reglas
typedef _RuleMatch = bool Function(String seg, int idx, List<String> toks);
typedef _RuleApply = List<String> Function(String seg);

class _Rule {
  final String id;
  final _RuleMatch match;
  final _RuleApply apply;
  final String explain;
  final String? example;

  const _Rule({
    required this.id,
    required this.match,
    required this.apply,
    required this.explain,
    this.example,
  });
}

// Var temporal (DFS)
class _VarTmp {
  final String form;
  final List<String> ruleIds;
  _VarTmp(this.form, this.ruleIds);
}
