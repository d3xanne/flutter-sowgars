import 'package:sample/services/local_repository.dart';
import 'package:sample/models/sugar_record.dart';

void main() async {
  print('🧪 Testing Sugar Record Save...');
  
  final repo = LocalRepository.instance;
  
  try {
    // Test creating a new sugar record
    final testRecord = SugarRecord(
      id: 'test-${DateTime.now().millisecondsSinceEpoch}',
      date: '2025-01-15',
      variety: 'Test Variety',
      soilTest: 'pH 6.5, Good',
      fertilizer: 'NPK 14-14-14',
      heightCm: 50,
      notes: 'Test record for debugging',
    );
    
    print('📝 Creating test record: ${testRecord.variety}');
    
    // Get current records
    final currentRecords = await repo.getSugarRecords();
    print('📊 Current records count: ${currentRecords.length}');
    
    // Add new record
    currentRecords.add(testRecord);
    await repo.saveSugarRecords(currentRecords);
    print('✅ Record saved successfully');
    
    // Verify it was saved
    final updatedRecords = await repo.getSugarRecords();
    print('📊 Updated records count: ${updatedRecords.length}');
    
    final savedRecord = updatedRecords.firstWhere(
      (r) => r.id == testRecord.id,
      orElse: () => throw Exception('Record not found after saving'),
    );
    
    print('✅ Record verified: ${savedRecord.variety} - ${savedRecord.heightCm}cm');
    print('🎉 Sugar record save test completed successfully!');
    
  } catch (e) {
    print('❌ Error during sugar record save test: $e');
    print('Stack trace: ${StackTrace.current}');
  }
}
