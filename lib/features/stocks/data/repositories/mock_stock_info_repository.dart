import 'package:pulsetrade_app/features/stocks/domain/models/stock_info.dart';
import 'package:pulsetrade_app/features/stocks/domain/repositories/stock_info_repository.dart';

/// Mock implementation of StockInfoRepository
/// Provides sample stock information data for development and testing
class MockStockInfoRepository implements StockInfoRepository {
  @override
  Future<StockInfo> getStockInfo(String ticker) async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // Mock data based on Figma design
    return StockInfo(
      keyRatios: const KeyRatios(
        marketCap: '\$2.75T',
        peRatio: '28.5',
        revenue: '\$60.92B',
        eps: '\$1.22',
        dividendYield: '0.04%',
        beta: '1.69',
      ),
      dividendInfo: const DividendInfo(
        earningRetainedPercent: 30.0,
        payoutRatioPercent: 70.0,
        lastPayment: null,
        lastExDate: 'Dec 02, 2025',
      ),
      financials: Financials(
        selectedType: FinancialStatementType.incomeStatement,
        incomeStatement: const [
          FinancialDataPoint(
            year: '2020',
            revenue: 75.0, // Percentage for chart
            netIncome: 20.0, // Percentage for chart
          ),
          FinancialDataPoint(
            year: '2021',
            revenue: 95.0,
            netIncome: 5.0,
          ),
          FinancialDataPoint(
            year: '2022',
            revenue: 85.0,
            netIncome: 25.0,
          ),
        ],
        balanceSheet: const [
          FinancialDataPoint(year: '2020', revenue: 70.0, netIncome: 18.0),
          FinancialDataPoint(year: '2021', revenue: 90.0, netIncome: 4.0),
          FinancialDataPoint(year: '2022', revenue: 80.0, netIncome: 22.0),
        ],
        cashFlow: const [
          FinancialDataPoint(year: '2020', revenue: 72.0, netIncome: 19.0),
          FinancialDataPoint(year: '2021', revenue: 92.0, netIncome: 4.5),
          FinancialDataPoint(year: '2022', revenue: 82.0, netIncome: 23.0),
        ],
      ),
    );
  }
}

