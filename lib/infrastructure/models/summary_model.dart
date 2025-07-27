import 'package:meetclic/domain/entities/movement.dart';

class MovementAmountModel extends MovementAmount {
  MovementAmountModel.fromJson(Map<String, dynamic> json)
    : super(
        totalInput: json['total_input'],
        totalOutput: json['total_output'],
        currentBalance: json['current_balance'],
      );
}

class ReputationSummaryModel extends ReputationSummary {
  ReputationSummaryModel.fromJson(Map<String, dynamic> json)
    : super(total: json['total']);
}

class TrophiesSummaryModel extends TrophiesSummary {
  TrophiesSummaryModel.fromJson(Map<String, dynamic> json)
    : super(total: json['total']);
}

class VisitsSummaryModel extends VisitsSummary {
  VisitsSummaryModel.fromJson(Map<String, dynamic> json)
    : super(total: json['total']);
}

class RatingSummaryModel extends RatingSummary {
  RatingSummaryModel.fromJson(Map<String, dynamic> json)
    : super(
        positiveClients: json['positiveClients'],
        averageStars: json['averageStars'],
        communityScore: json['communityScore'],
      );
}

class MovementSummaryModel extends MovementSummary {
  MovementSummaryModel.fromJson(Map<String, dynamic> json)
    : super(
        yapitas: MovementAmountModel.fromJson(json['yapitas']),
        yapitasPremium: MovementAmountModel.fromJson(json['yapitas-premium']),
        reputation: ReputationSummaryModel.fromJson(json['reputation']),
        trophies: TrophiesSummaryModel.fromJson(json['trophies']),
        visits: VisitsSummaryModel.fromJson(json['visits']),
        rating: RatingSummaryModel.fromJson(json['rating']),
      );
}
