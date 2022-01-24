// pages 37- 38.5
// CHANGE FUNCTION DECLARATION (124)

import 'package:intl/intl.dart';

String statement(Invoices invoice) {
  StatementData statementData = createStatementData(invoice);

  return renderPlainText(statementData);
}

StatementData createStatementData(Invoices invoice) {
  Play playFor(Performance data) {
    return Plays.shows.firstWhere((play) => play.name == data.playID);
  }

// 1a*) copy and move to PerformanceCalculator class.
  int amountFor(Performance data) {
    // 1c) get values from class instead of in function.
    PerformanceCalculator perfCalc =
        PerformanceCalculator(performance: data, play: playFor(data));
    return perfCalc.amount(data);
    // int result = 0;
    // switch (playFor(data).type) {
    //   case 'tragedy':
    //     result = 40000;
    //     if (data.audience > 30) {
    //       result += 1000 * (data.audience - 30);
    //     }
    //     break;
    //   case 'comedy':
    //     result = 30000;
    //     if (data.audience > 20) {
    //       result += 10000 + 500 * (data.audience - 20);
    //     }
    //     result += 300 * data.audience;
    //     break;
    //   default:
    //     throw 'unknown type: ${playFor(data).type}';
    // }
    // return result;
  }

  int volumeCreditsFor(Performance data) {
    var result = 0;
    result += data.audience - 30;
    if ('comedy' == playFor(data).type) {
      result += (data.audience / 5).floor();
    }
    return result;
  }

  int totalAmount(Invoices data) {
    return data.performances
        .map((perf) => amountFor(perf))
        .reduce((a, b) => a + b);
  }

  int totalVolumeCredits(Invoices data) {
    return data.performances
        .map((perf) => volumeCreditsFor(perf))
        .reduce((a, b) => a + b);
  }

  StatementData statementData = StatementData(
    customer: invoice.customer,
    performances: invoice.performances.map((performance) {
      PerformanceCalculator perfCalc = PerformanceCalculator(
        performance: performance,
        play: playFor(performance),
      );
      return EnrichPerformance(
        calculator:
            PerformanceCalculator(performance: performance, play: perfCalc),
        playId: performance.playID,
        audience: performance.audience,
        play: perfCalc.play,
        // 1b)
        amount: perfCalc.amount(performance),
        volumeCredits: volumeCreditsFor(performance),
      );
    }).toList(),
    totalAmount: totalAmount(invoice),
    totalVolumeCredits: totalVolumeCredits(invoice),
  );
  return statementData;
}

String renderPlainText(StatementData data) {
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
  static final List<Play> shows = [
    Play(name: 'Hamlet', type: 'tragedy'),
    Play(name: 'As You Like It', type: 'comedy'),
    Play(name: 'Othello', type: 'tragedy'),
  ];
}

class Play {
  Play({required this.name, required this.type});
  final String name;
  final String type;
}

class Invoices {
  String customer = 'BigCo';
  List<Performance> performances = [
    Performance(playID: 'Hamlet', audience: 55),
    Performance(playID: 'As You Like It', audience: 35),
    Performance(playID: 'Othello', audience: 40),
  ];
}

class Performance {
  Performance({required this.playID, required this.audience});
  String playID;
  int audience;
}

class PerformanceCalculator {
  PerformanceCalculator({required this.performance, required this.play});
  Performance performance;
  var play;

//1 a**)
  int amount(Performance data) {
    int result = 0;
    switch (play.type) {
      case 'tragedy':
        result = 40000;
        if (performance.audience > 30) {
          result += 1000 * (performance.audience - 30);
        }
        break;
      case 'comedy':
        result = 30000;
        if (performance.audience > 20) {
          result += 10000 + 500 * (performance.audience - 20);
        }
        result += 300 * performance.audience;
        break;
      default:
        throw 'unknown type: ${play.type}';
    }
    return result;
  }
}

class EnrichPerformance {
  EnrichPerformance({
    required this.calculator,
    required this.playId,
    required this.audience,
    required this.play,
    required this.amount,
    required this.volumeCredits,
  });
  PerformanceCalculator calculator;
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
  Invoices invoices = Invoices();

  print(statement(invoices));
}
