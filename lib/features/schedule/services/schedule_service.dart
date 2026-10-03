import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_tables.dart';
import '../models/schedule.dart';

class ScheduleService {
  final SupabaseClient _supabase;

  ScheduleService(this._supabase);

  // Stream schedule for a specific class
  Stream<Schedule?> watchSchedule(String classId) {
    return _supabase
        .from(AppTables.schedules)
        .stream(primaryKey: ['id'])
        .eq('class_id', classId)
        .map((data) {
          if (data.isEmpty) return null;
          return Schedule.fromJson(data.first);
        });
  }

  // Update schedule (Teacher)
  Future<void> updateSchedule(Schedule schedule) async {
    try {
      final exists = await _supabase.from(AppTables.schedules).select('id').eq('class_id', schedule.classId).maybeSingle();
      
      if (exists != null) {
        // Update
        await _supabase.from(AppTables.schedules).update(schedule.toJson()).eq('class_id', schedule.classId);
      } else {
        // Insert
        await _supabase.from(AppTables.schedules).insert(schedule.toJson());
      }
    } catch (e) {
      throw Exception('فشل في حفظ الجدول: $e');
    }
  }
}
