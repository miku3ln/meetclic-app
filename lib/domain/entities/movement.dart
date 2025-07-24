class Movement {
  final int id;
  final DateTime dateRegister;
  final String description;
  final String inputMovementName;
  final int inputMovementValue;
  final int tipoTransactionValue;
  final String tipoTransactionName;
  final int amount;
  final int typeMoneyValue;
  final String typeMoneyName;
  final String processName;
  final String sourceProcess;
  final String activityName;

  Movement({
    required this.id,
    required this.dateRegister,
    required this.description,
    required this.inputMovementName,
    required this.inputMovementValue,
    required this.tipoTransactionValue,
    required this.tipoTransactionName,
    required this.amount,
    required this.typeMoneyValue,
    required this.typeMoneyName,
    required this.processName,
    required this.sourceProcess,
    required this.activityName,
  });
}

class MovementSummary {
  final MovementAmount yapitas;
  final MovementAmount yapitasPremium;
  final ReputationSummary reputation;
  final TrophiesSummary trophies;

  MovementSummary({
    required this.yapitas,
    required this.yapitasPremium,
    required this.reputation,
    required this.trophies,

  });
}

class MovementAmount {
  final int totalInput;
  final int totalOutput;
  final int currentBalance;

  MovementAmount({
    required this.totalInput,
    required this.totalOutput,
    required this.currentBalance,
  });
}

class ReputationSummary {
  final int total;

  ReputationSummary({required this.total});
}
class TrophiesSummary {
  final int total;

  TrophiesSummary({required this.total});
}