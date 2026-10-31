import '../../domain/models/prediction_result.dart';

class AppStrings {
  AppStrings._();

  static String lang = 'id';
  static bool get isEn => lang == 'en';

  static String tr(String id, String en) => isEn ? en : id;

  static const Map<String, String> _enNames = {
    'berjerawat': 'Acne-Prone Skin (Acne)',
    'berminyak': 'Oily Skin (Seborrheic)',
    'dermatitis_perioral': 'Perioral Dermatitis',
    'kering': 'Dry Skin (Xerosis)',
    'normal': 'Normal Skin (Balanced)',
    'penuaan': 'Aging Skin (Photoaging)',
    'vitiligo': 'Vitiligo / Depigmentation',
  };

  static const Map<String, String> _enShortNames = {
    'berjerawat': 'Acne',
    'berminyak': 'Oily',
    'dermatitis_perioral': 'Dermatitis',
    'kering': 'Dry',
    'normal': 'Normal',
    'penuaan': 'Aging',
    'vitiligo': 'Vitiligo',
  };

  static String localizeClassName(String classId, [String? fallback]) {
    if (!isEn) return fallback ?? classId;
    return _enNames[classId] ?? fallback ?? classId;
  }

  static String localizeShortClassName(String classId, [String? fallback]) {
    if (!isEn) return fallback ?? classId;
    return _enShortNames[classId] ?? fallback ?? classId;
  }

  static ImageQualityInfo localizeImageQuality(ImageQualityInfo iq) {
    if (!isEn) return iq;
    const lightMap = {
      'Cukup': 'Optimal',
      'Terlalu Gelap': 'Too Dark',
      'Terlalu Terang': 'Overexposed',
    };
    const sharpMap = {
      'Tajam': 'Sharp',
      'Agak Buram (Blur)': 'Slightly Blurry',
    };
    return ImageQualityInfo(
      isOptimal: iq.isOptimal,
      status: iq.status,
      brightness: iq.brightness,
      lightingLabel: lightMap[iq.lightingLabel] ?? iq.lightingLabel,
      sharpness: iq.sharpness,
      sharpnessLabel: sharpMap[iq.sharpnessLabel] ?? iq.sharpnessLabel,
      title:
          iq.isOptimal ? 'Optimal Photo Quality' : 'Suboptimal Photo Quality',
      message: iq.isOptimal
          ? 'Facial lighting and sharpness are well-suited for CNN inference.'
          : 'Suboptimal lighting or focus detected; consider retaking in even lighting for higher confidence.',
    );
  }

  static TopDiagnosis localizeTopDiagnosis(TopDiagnosis top) {
    if (!isEn) return top;
    final meta = _enClinicalMeta[top.classId];
    if (meta == null) return top;
    return TopDiagnosis(
      classId: top.classId,
      label: meta.label,
      badge: meta.badge,
      color: top.color,
      colorHex: top.colorHex,
      confidence: top.confidence,
      summary: meta.summary,
      description: meta.description,
      characteristics: meta.characteristics,
      recommendations: meta.recommendations,
      avoidList: meta.avoidList,
      productRecommendations: meta.productRecommendations,
    );
  }

  static const Map<String, _EnClassClinicalMeta> _enClinicalMeta = {
    'berjerawat': _EnClassClinicalMeta(
      label: 'Acne-Prone Skin (Acne)',
      badge: 'Acne',
      summary:
          'Active acne lesions, comedones, or follicular inflammation detected.',
      description:
          'Skin condition characterized by clogged pores (comedones), erythematous papules, pustules, and follicular inflammation due to excess sebum and C. acnes bacteria.',
      characteristics: [
        'Erythematous papules, pustules, or open/closed comedones',
        'Localized redness around inflamed pores',
        'Risk of Post-Inflammatory Hyperpigmentation (PIH) or PIE',
      ],
      recommendations: [
        ActiveIngredient(
          ingredient: 'Salicylic Acid (BHA 0.5% - 2%)',
          desc:
              'Lipophilic beta-hydroxy acid that penetrates pores to dissolve sebum plugs and dead skin cells.',
        ),
        ActiveIngredient(
          ingredient: 'Niacinamide (2% - 5%)',
          desc:
              'Calms inflammation, regulates sebum output, and strengthens the epidermal barrier.',
        ),
        ActiveIngredient(
          ingredient: 'Centella Asiatica / Madecassoside',
          desc:
              'Soothing botanical active that accelerates healing of inflamed acne lesions.',
        ),
      ],
      avoidList: [
        'Avoid harsh physical scrubs (apricot/micro-beads) that rupture active pustules and spread bacteria.',
        'Avoid layering high-concentration AHA/BHA with Retinol in the same routine.',
        'Avoid heavy occlusive oils (Coconut Oil, Cocoa Butter, Mineral Oil) that are highly comedogenic.',
      ],
      productRecommendations: [
        SkincareProduct(
          category: 'Gentle Gel Cleanser',
          brand: 'COSRX',
          name: 'COSRX Low pH Good Morning Gel Cleanser',
          actives: 'Betaine Salicylate (BHA) + Tea Tree Oil',
          timeUsage: '☀️ AM & 🌙 PM',
          desc:
              'Maintains skin pH (5.0-6.0) while gently clearing excess sebum and pore impurities.',
        ),
        SkincareProduct(
          category: 'BHA Pore & Acne Serum',
          brand: 'Somethinc',
          name: 'Somethinc 2% BHA Salicylic Acid Liquid Perfector',
          actives: '2% Salicylic Acid + Natural Soothing Complex',
          timeUsage: '🌙 PM (2-3x / Week)',
          desc:
              'Unclogs congested pores, reduces active breakouts, and clears blackheads/whiteheads.',
        ),
        SkincareProduct(
          category: 'Barrier Gel Moisturizer',
          brand: 'Skintific',
          name: 'Skintific 5X Ceramide Barrier Moisture Gel',
          actives: '5X Ceramide + Centella Asiatica + Hyaluronic Acid',
          timeUsage: '☀️ AM & 🌙 PM',
          desc:
              'Lightweight oil-free hydration that calms redness and restores the skin barrier.',
        ),
        SkincareProduct(
          category: 'Non-Comedogenic Sunscreen',
          brand: 'Azarine',
          name: 'Azarine Hydrasoothe Sunscreen Gel SPF45 PA++++',
          actives: 'Royal Jelly + Aloe Vera + Green Tea + Propolis',
          timeUsage: '☀️ AM (Reapply every 3-4h)',
          desc:
              '0% alcohol & 0% oil water-based gel sunscreen that prevents post-acne dark marks (PIH).',
        ),
      ],
    ),
    'berminyak': _EnClassClinicalMeta(
      label: 'Oily Skin (Seborrheic)',
      badge: 'Oily',
      summary:
          'Excessive sebaceous gland hyperactivity with visible surface shine and enlarged pores.',
      description:
          'Characterized by overproduction of sebum across the T-zone and cheeks, resulting in surface shine, visibly dilated pores, and predisposition to comedogenesis.',
      characteristics: [
        'Prominent sebum shine across forehead, nose, and cheeks',
        'Visibly enlarged pores in the T-zone area',
        'Prone to sebaceous filaments and comedones',
      ],
      recommendations: [
        ActiveIngredient(
          ingredient: 'Niacinamide (4% - 5%) & Zinc PCA',
          desc: 'Balances sebaceous gland output and refines pore appearance.',
        ),
        ActiveIngredient(
          ingredient: 'LHA / Salicylic Acid',
          desc:
              'Keeps pores clear of oxidized sebum without over-drying the skin.',
        ),
        ActiveIngredient(
          ingredient: 'Green Tea Extract (EGCG)',
          desc: 'Antioxidant polyphenol that helps control excess surface oil.',
        ),
      ],
      avoidList: [
        'Rich occlusive creams containing petrolatum or heavy plant butters.',
        'Over-washing (>2-3 times daily) with harsh sulfate cleansers that trigger rebound oiliness.',
        'Skipping moisturizer—dehydrated oily skin produces even more sebum.',
      ],
      productRecommendations: [
        SkincareProduct(
          category: 'Sebum-Control Cleanser',
          brand: 'La Roche-Posay',
          name: 'La Roche-Posay Effaclar Purifying Foaming Gel',
          actives: 'Zinc Pidolate + Thermal Spring Water',
          timeUsage: '☀️ AM & 🌙 PM',
          desc:
              'Purifies oily skin and removes excess sebum while preserving physiological pH.',
        ),
        SkincareProduct(
          category: 'Sebum Balancing Serum',
          brand: 'The Originote',
          name: 'The Originote Bright B3 Serum',
          actives: 'Niacinamide 10% + Glutathione',
          timeUsage: '☀️ AM & 🌙 PM',
          desc:
              'Regulates daytime oil shine, tightens pore appearance, and brightens dullness.',
        ),
        SkincareProduct(
          category: 'Oil-Free Water Gel',
          brand: 'Neutrogena',
          name: 'Neutrogena Hydro Boost Hyaluronic Acid Water Gel',
          actives: 'Purified Hyaluronic Acid + Glycerin',
          timeUsage: '☀️ AM & 🌙 PM',
          desc:
              'Replenishes water hydration without adding oil or clogging pores.',
        ),
        SkincareProduct(
          category: 'Matte Finish Sunscreen',
          brand: 'Skin Aqua',
          name: 'Skin Aqua UV Moisture Gel SPF 30 PA++',
          actives: 'Hyaluronic Acid + Collagen + Vitamin B5 & E',
          timeUsage: '☀️ AM (Required)',
          desc:
              'Fast-absorbing gel sunscreen specifically formulated for normal-to-oily skin.',
        ),
      ],
    ),
    'dermatitis_perioral': _EnClassClinicalMeta(
      label: 'Perioral Dermatitis',
      badge: 'Perioral Dermatitis',
      summary:
          'Erythematous papular rash concentrated around the mouth, nasolabial folds, or chin.',
      description:
          'Inflammatory facial dermatosis presenting as clusters of small erythematous papules, scaling, and burning irritation around the perioral (mouth) and perinasal regions.',
      characteristics: [
        'Clustered micro-papules and redness around mouth/nostrils',
        'Dry, scaly, or stinging skin barrier sensitivity',
        'Often triggered by topical steroids or fluorinated toothpaste',
      ],
      recommendations: [
        ActiveIngredient(
          ingredient: 'Panthenol (Vitamin B5) & Bisabolol',
          desc:
              'Soothes stinging irritation and accelerates epidermal barrier recovery.',
        ),
        ActiveIngredient(
          ingredient: 'Multi-Ceramide & Cholesterol Complex',
          desc: 'Restores the compromised stratum corneum lipid matrix.',
        ),
        ActiveIngredient(
          ingredient: 'Azelaic Acid (Low-dose / Post-acute)',
          desc:
              'Anti-inflammatory active often used under dermatological supervision.',
        ),
      ],
      avoidList: [
        'Discontinue topical corticosteroid creams on the face unless directed by a dermatologist.',
        'Avoid fluoride/SLS toothpaste contacting the skin around the mouth.',
        'Zero-therapy phase: stop all exfoliants (AHA/BHA), retinoids, and fragranced cosmetics.',
      ],
      productRecommendations: [
        SkincareProduct(
          category: 'Ultra-Gentle Cleanser',
          brand: 'Cetaphil',
          name: 'Cetaphil Gentle Skin Cleanser',
          actives: 'Niacinamide + Panthenol + Glycerin',
          timeUsage: '☀️ AM & 🌙 PM',
          desc:
              'Soap-free, fragrance-free micellar emulsion that cleanses without irritating inflamed skin.',
        ),
        SkincareProduct(
          category: 'Barrier Repair Balm',
          brand: 'La Roche-Posay',
          name: 'La Roche-Posay Cicaplast Baume B5+',
          actives: '5% Panthenol + Madecassoside + Tribioma',
          timeUsage: '☀️ AM & 🌙 PM',
          desc:
              'Intensive soothing balm that calms perioral redness and repairs damaged skin barriers.',
        ),
        SkincareProduct(
          category: 'Hypoallergenic Cream',
          brand: 'Avene',
          name: 'Avene Tolerance Control Soothing Skin Recovery Cream',
          actives: 'D-Sensinose + Avene Thermal Spring Water',
          timeUsage: '☀️ AM & 🌙 PM',
          desc:
              'Calms skin hypersensitivity and stinging sensations within minutes.',
        ),
        SkincareProduct(
          category: '100% Mineral Sunscreen',
          brand: 'Labore',
          name: 'Labore BiomeProtect Physical Sunscreen SPF 45 PA+++',
          actives: '100% Mineral (Zinc Oxide & Titanium Dioxide)',
          timeUsage: '☀️ AM (Required)',
          desc:
              'Chemical-filter-free physical sunscreen safe for reactive dermatitis-prone skin.',
        ),
      ],
    ),
    'kering': _EnClassClinicalMeta(
      label: 'Dry Skin (Xerosis)',
      badge: 'Dry Skin',
      summary:
          'Depleted stratum corneum lipids and moisture resulting in rough, tight, or flaky texture.',
      description:
          'Skin condition marked by increased Transepidermal Water Loss (TEWL) and low natural moisturizing factors (NMF), leading to tightness, dullness, and fine scaling.',
      characteristics: [
        'Tight sensation especially after cleansing',
        'Rough, dull surface with fine desquamation (flaking)',
        'Weakened lipid barrier prone to micro-fissures',
      ],
      recommendations: [
        ActiveIngredient(
          ingredient: 'Multi-Molecular Hyaluronic Acid',
          desc: 'Attracts and binds water molecules across epidermal layers.',
        ),
        ActiveIngredient(
          ingredient: 'Ceramide Complex',
          desc:
              'Replenishes intercellular lipid matrix to prevent transepidermal water loss (TEWL).',
        ),
        ActiveIngredient(
          ingredient: 'Squalane / Shea Butter',
          desc:
              'Protective emollients that soften and restore skin suppleness.',
        ),
      ],
      avoidList: [
        'High-foaming cleansers with SLS/SLES or denatured alcohol that strip natural lipids.',
        'Prolonged face washing with hot water, which accelerates moisture evaporation.',
        'Oil-absorbing clay masks or astringent toners that worsen skin tightness.',
      ],
      productRecommendations: [
        SkincareProduct(
          category: 'Hydrating Facial Cleanser',
          brand: 'Hada Labo',
          name: 'Hada Labo Gokujyun Ultimate Moisturizing Face Wash',
          actives: '2 Types of Hyaluronic Acid',
          timeUsage: '☀️ AM & 🌙 PM',
          desc:
              'Cleanses impurities with soft foam without stripping natural moisture while maintaining balanced pH.',
        ),
        SkincareProduct(
          category: 'Intensive Hydration Serum',
          brand: 'Somethinc',
          name: 'Somethinc Supple Power Hyaluronic9+ Onsen Serum',
          actives: '9 Types of Hyaluronic Acid + Onsen Water',
          timeUsage: '☀️ AM & 🌙 PM',
          desc:
              'Deeply hydrates down to the lower epidermal layers to relieve rough and flaky skin.',
        ),
        SkincareProduct(
          category: 'Intensive Barrier Cream',
          brand: 'Illiyoon',
          name: 'Illiyoon Ceramide Ato Concentrate Cream',
          actives: 'Ceramide Skin Complex Capsules',
          timeUsage: '☀️ AM & 🌙 PM',
          desc:
              'Ceramide-rich cream that replenishes dry skin barriers and prevents chronic dehydration.',
        ),
        SkincareProduct(
          category: 'Moisturizing Sunscreen',
          brand: 'Biore',
          name: 'Biore UV Aqua Rich Watery Essence SPF 50+ PA++++',
          actives: 'Hyaluronic Acid + Royal Jelly Extract',
          timeUsage: '☀️ AM (Required)',
          desc:
              'High UV protection with watery micro-defense capsules that keep dry skin hydrated all day.',
        ),
      ],
    ),
    'normal': _EnClassClinicalMeta(
      label: 'Normal Skin (Balanced)',
      badge: 'Normal',
      summary:
          'Healthy eudermic skin with optimal hydration and sebum balance.',
      description:
          'Well-balanced eudermic skin condition with proportional water (hydration) and lipid (sebum) levels, smooth texture, good elasticity, and healthy circulation.',
      characteristics: [
        'Proportional sebum and moisture balance',
        'Smooth texture and healthy skin elasticity',
        'Free from significant inflammation or irritation',
      ],
      recommendations: [
        ActiveIngredient(
          ingredient: 'Broad-Spectrum Sunscreen SPF 30-50+',
          desc: 'Essential daily preventive step against UVA/UVB damage.',
        ),
        ActiveIngredient(
          ingredient: 'Hyaluronic Acid & Peptides',
          desc: 'Maintains skin plumpness and supports cellular turnover.',
        ),
        ActiveIngredient(
          ingredient: 'Antioxidants (Vitamin C / Green Tea)',
          desc:
              'Protects skin tissue from daily pollution and oxidative stress.',
        ),
      ],
      avoidList: [
        'Daily over-exfoliation that can disrupt an already healthy skin barrier.',
        'Skipping morning sunscreen even when indoors near windows.',
        'Sleeping without cleansing off sunscreen and daily pollutants at night.',
      ],
      productRecommendations: [
        SkincareProduct(
          category: 'Balanced Facial Cleanser',
          brand: 'Simple',
          name: 'Simple Kind to Skin Refreshing Facial Wash',
          actives: 'Pro-Vitamin B5 + Vitamin E',
          timeUsage: '☀️ AM & 🌙 PM',
          desc:
              '100% soap-free and dye-free gentle cleanser that maintains natural skin balance.',
        ),
        SkincareProduct(
          category: 'Antioxidant Daily Serum',
          brand: 'Avoskin',
          name: 'Avoskin Your Skin Bae Vitamin C 3% + Niacinamide 2%',
          actives: 'Vitamin C + Niacinamide + Mandarin Orange',
          timeUsage: '☀️ AM & 🌙 PM',
          desc:
              'Maintains natural radiance and protects healthy skin from free-radical damage.',
        ),
        SkincareProduct(
          category: 'Daily Protective Moisturizer',
          brand: 'CeraVe',
          name: 'CeraVe Daily Moisturizing Lotion',
          actives: '3 Essential Ceramides + MVE Technology',
          timeUsage: '☀️ AM & 🌙 PM',
          desc:
              'Releases steady 24-hour hydration to keep normal skin supple and resilient.',
        ),
        SkincareProduct(
          category: 'Daily Broad-Spectrum Sunscreen',
          brand: 'Wardah',
          name: 'Wardah UV Shield Essential Gel Sunscreen SPF 35 PA+++',
          actives: 'Vitamin C + Glutathione + Vitamin B3',
          timeUsage: '☀️ AM (Required)',
          desc:
              'Comfortable everyday protection against UV rays and blue light exposure.',
        ),
      ],
    ),
    'penuaan': _EnClassClinicalMeta(
      label: 'Aging Skin (Photoaging)',
      badge: 'Aging',
      summary:
          'Visible fine lines, wrinkles, or decreased dermal collagen elasticity.',
      description:
          'Intrinsic and extrinsic skin aging (photoaging) characterized by collagen and elastin degradation, resulting in dynamic/static wrinkles, fine lines, and uneven tone.',
      characteristics: [
        'Visible fine lines and expression wrinkles',
        'Decreased dermal firmness and elasticity',
        'Signs of cumulative UV photoaging',
      ],
      recommendations: [
        ActiveIngredient(
          ingredient: 'Retinoids (Retinol / Retinal)',
          desc:
              'Gold-standard active that stimulates dermal collagen synthesis and epidermal renewal.',
        ),
        ActiveIngredient(
          ingredient: 'Peptide Complex (Matrixyl / Argireline)',
          desc:
              'Supports extracellular matrix firmness and smooths fine lines.',
        ),
        ActiveIngredient(
          ingredient: 'Vitamin C (L-Ascorbic Acid) & Ferulic Acid',
          desc: 'Potent antioxidant that neutralizes UV-induced free radicals.',
        ),
      ],
      avoidList: [
        'Using Retinol in the morning without broad-spectrum SPF 50+ sunscreen.',
        'Combining Retinol with high-strength AHA/BHA in the same night routine.',
        'Chronic unprotected sun exposure, which accounts for up to 80% of premature skin aging.',
      ],
      productRecommendations: [
        SkincareProduct(
          category: 'Gentle Hydrating Cleanser',
          brand: 'CeraVe',
          name: 'CeraVe Hydrating Facial Cleanser',
          actives: '3 Essential Ceramides + Hyaluronic Acid',
          timeUsage: '☀️ AM & 🌙 PM',
          desc:
              'Non-foaming lotion cleanser that preserves moisture in mature skin.',
        ),
        SkincareProduct(
          category: 'Anti-Aging Night Serum',
          brand: 'Avoskin',
          name: 'Avoskin Miraculous Retinol Ampoule',
          actives: '3% Actosome Retinol + Peptide + Vitamin E',
          timeUsage: '🌙 PM Only (3-4x / Week)',
          desc:
              'Stimulates natural collagen regeneration to reduce fine lines and improve elasticity.',
        ),
        SkincareProduct(
          category: 'Firming Peptide Cream',
          brand: 'Olay',
          name: 'Olay Regenerist Micro-Sculpting Cream',
          actives: 'Amino-Peptide Complex II + Niacinamide',
          timeUsage: '☀️ AM & 🌙 PM',
          desc:
              'Deeply hydrates and firms skin contours to soften the appearance of wrinkles.',
        ),
        SkincareProduct(
          category: 'Anti-Photoaging Sunscreen',
          brand: 'Anessa',
          name: 'Anessa Perfect UV Sunscreen Skincare Milk SPF 50+ PA++++',
          actives: 'Auto Booster Technology + Super HA + Collagen',
          timeUsage: '☀️ AM (Required)',
          desc:
              'Maximum UVA/UVB defense to prevent further collagen breakdown and solar lentigines.',
        ),
      ],
    ),
    'vitiligo': _EnClassClinicalMeta(
      label: 'Vitiligo / Depigmentation',
      badge: 'Vitiligo',
      summary:
          'Well-demarcated depigmented macules/patches due to loss of functional melanocytes.',
      description:
          'Pigmentary disorder characterized by well-defined milky-white macules or patches resulting from selective loss of epidermal melanocytes. Requires high photoprotection and dermatological evaluation.',
      characteristics: [
        'Distinctive depigmented (chalk-white) macules or patches',
        'Complete absence of protective melanin in affected areas',
        'High susceptibility to actinic erythema (sunburn)',
      ],
      recommendations: [
        ActiveIngredient(
          ingredient: 'High-Protection Broad-Spectrum SPF 50+',
          desc:
              'Depigmented patches lack melanin protection and burn rapidly under UV exposure.',
        ),
        ActiveIngredient(
          ingredient: 'Hypoallergenic Barrier Emollients',
          desc:
              'Maintains stratum corneum integrity without triggering Koebner phenomenon.',
        ),
        ActiveIngredient(
          ingredient: 'Dermatologist Consultation',
          desc:
              'For clinical evaluation (topical calcineurin inhibitors, NB-UVB phototherapy).',
        ),
      ],
      avoidList: [
        'Direct midday sun exposure without SPF 50+—depigmented areas lack natural UV defense.',
        'Friction, scratching, or skin trauma that can trigger new lesions (Koebner phenomenon).',
        'Unverified bleaching/hydroquinone products that can cause chemical leukoderma.',
      ],
      productRecommendations: [
        SkincareProduct(
          category: 'Non-Irritating Cleanser',
          brand: 'Cetaphil',
          name: 'Cetaphil Gentle Skin Cleanser',
          actives: 'Hypoallergenic Fragrance-Free Formula',
          timeUsage: '☀️ AM & 🌙 PM',
          desc:
              'Ultra-mild dermatological cleanser that avoids inflammatory stress on melanocyte borders.',
        ),
        SkincareProduct(
          category: 'Biomimetic Barrier Cream',
          brand: 'Physiogel',
          name: 'Physiogel Hypoallergenic Daily Moisture Therapy Cream',
          actives: 'BioMimic Technology + Squalane',
          timeUsage: '☀️ AM & 🌙 PM',
          desc:
              'Mimics natural skin lipids to keep depigmented patches supple and protected.',
        ),
        SkincareProduct(
          category: 'Maximum UV Protection',
          brand: 'La Roche-Posay',
          name: 'La Roche-Posay Anthelios UVMune 400 Invisible Fluid SPF 50+',
          actives: 'Broad-Spectrum Mexoryl 400 Filter',
          timeUsage: '☀️ AM (Every 2-3 Hours)',
          desc:
              'Essential medical-grade UVA/UVB protection for depigmented skin lacking melanin.',
        ),
        SkincareProduct(
          category: 'Cellular Defense Sunscreen',
          brand: 'Eucerin',
          name: 'Eucerin Sun Gel-Cream Dry Touch SPF 50+',
          actives: 'Licochalcone A + Glycyrrhetinic Acid',
          timeUsage: '☀️ AM / Midday',
          desc:
              'Supports cellular DNA repair and provides high antioxidant defense against UV damage.',
        ),
      ],
    ),
  };
}

class _EnClassClinicalMeta {
  final String label;
  final String badge;
  final String summary;
  final String description;
  final List<String> characteristics;
  final List<ActiveIngredient> recommendations;
  final List<String> avoidList;
  final List<SkincareProduct> productRecommendations;

  const _EnClassClinicalMeta({
    required this.label,
    required this.badge,
    required this.summary,
    required this.description,
    required this.characteristics,
    required this.recommendations,
    required this.avoidList,
    required this.productRecommendations,
  });
}
