import 'package:sample/services/supabase_service.dart';
import 'package:sample/models/sugar_record.dart';

void main() async {
  print('🧪 Testing Supabase Fix...');
  
  try {
    // Initialize Supabase
    await SupabaseService.initialize();
    print('✅ Supabase initialized');
    
    // Test creating a sugar record
    final testRecord = SugarRecord(
      id: 'test-${DateTime.now().millisecondsSinceEpoch}',
      date: '2025-01-15',
      variety: 'Test Variety',
      soilTest: 'pH 6.5, Good',
      fertilizer: 'NPK 14-14-14',
      heightCm: 50,
      notes: 'Test record for debugging',
    );
    
    print('📝 Testing sugar record save...');
    
    // Test saving a single record
    await SupabaseService.saveSugarRecords([testRecord]);
    print('✅ Single record saved successfully');
    
    // Test saving multiple records
    final testRecord2 = SugarRecord(
      id: 'test-${DateTime.now().millisecondsSinceEpoch + 1}',
      date: '2025-01-16',
      variety: 'Test Variety 2',
      soilTest: 'pH 6.8, Excellent',
      fertilizer: 'NPK 16-20-0',
      heightCm: 60,
      notes: 'Second test record',
    );
    
    await SupabaseService.saveSugarRecords([testRecord, testRecord2]);
    print('✅ Multiple records saved successfully');
    
    // Test fetching records
    final records = await SupabaseService.getSugarRecords();
    print('📊 Fetched ${records.length} records from Supabase');
    
    print('🎉 All tests passed! The DELETE WHERE clause issue is fixed!');
    
  } catch (e) {
    print('❌ Test failed: $e');
    print('Stack trace: ${StackTrace.current}');
  }
}
