// pages 27-30
// PART II OF SPLITTING THE DATA.
// pulling name from the plays object

import 'package:intl/intl.dart';

String statement(Invoices invoice, Plays plays) {
  // 1) moved
  Play playFor(Performance data) {
    var result = plays.plays.firstWhere((play) => play.name == data.playID);
    return result;
  }

  // 2) moved
  int amountFor(Performance data) {
    int result = 0;
    switch (playFor(data).type) {
      case 'tragedy':
        result = 40000;
        if (data.audience > 30) {
          result += 1000 * (data.audience - 30);
        }
        break;
      case 'comedy':
        result = 30000;
        if (data.audience > 20) {
          result += 10000 + 500 * (data.audience - 20);
        }
        result += 300 * data.audience;
        break;
      default:
        throw 'unknown type: ${playFor(data).type}';
    }
    return result;
  }

  // 3) moved
  int volumeCreditsFor(Performance data) {
    var result = 0;
    result += data.audience - 30;
    if ('comedy' == playFor(data).type) {
      result += (data.audience / 5).floor();
    }
    return result;
  }

  // 4) moved
  int totalAmount(List<Performance> data) {
    var result = 0;

    for (var perf in data) {
      result += amountFor(perf);
    }
    return result;
  }

  // 5) moved
  int totalVolumeCredits(List<Performance> data) {
    var result = 0;

    for (var perf in data) {
      result += volumeCreditsFor(perf);
    }
    return result;
  }

// added EnrichedPerformance class
// added a new method to EnhancedPerformance class
// used a map to load the values into the new classes.
// same done for amount.
  StatementData statementData = StatementData(
    customer: invoice.customer,
    performances: invoice.performances
        .map((e) => EnrichPerformance(
              playId: e.playID,
              audience: e.audience,
              play: playFor(e),
              amount: amountFor(e),
              volumeCredits: volumeCreditsFor(e),
            ))
        .toList(),
    totalAmount: totalAmount(invoice.performances),
    totalVolumeCredits: totalVolumeCredits(invoice.performances),
  );

  return renderPlainText(statementData, plays);
}

String renderPlainText(StatementData data, Plays plays) {
  var result = 'Statement for ${data.customer}\n';

  String usd(aNumber) {
    var result = (NumberFormat.simpleCurrency().format)(aNumber / 100);
    return result;
  }

  for (EnrichPerformance perf in data.performances) {
    result +=
        ' ${perf.play.name}: ${usd(perf.amount)} (${perf.audience} seats) \n';
  }

  result += 'Amount owed is ${usd(data.totalAmount)}\n';
  result += 'You earned ${data.totalVolumeCredits} credits\n';
  return result;
}

class Plays {
  Plays({required this.plays});
  List<Play> plays = [];
}

class Play {
  Play({required this.name, required this.type});
  final String name;
  final String type;
}

class Invoices {
  Invoices({required this.performances});
  String customer = 'BigCo';
  List<Performance> performances = [];
}

class Performance {
  Performance({required this.playID, required this.audience});
  String playID;
  int audience;
}

class EnrichPerformance {
  EnrichPerformance({
    required this.playId,
    required this.audience,
    required this.play,
    required this.amount,
    required this.volumeCredits,
  });
  String playId;
  int audience;
  Play play;
  int amount;
  int volumeCredits;
}

class StatementData {
  StatementData({
    required this.customer,
    required this.performances,
    required this.totalAmount,
    required this.totalVolumeCredits,
  });
  String customer = '';
  List<EnrichPerformance> performances = [];
  int totalAmount;
  int totalVolumeCredits;
}

void main() {
  List<Performance> invoiceList = [
    Performance(playID: 'Hamlet', audience: 55),
    Performance(playID: 'As You Like It', audience: 35),
    Performance(playID: 'Othello', audience: 40),
  ];

  List<Play> playList = [
    Play(name: 'Hamlet', type: 'tragedy'),
    Play(name: 'As You Like It', type: 'comedy'),
    Play(name: 'Othello', type: 'tragedy'),
  ];

  Invoices invoices = Invoices(performances: invoiceList);

  Plays plays = Plays(plays: playList);

  print(statement(invoices, plays));
}
