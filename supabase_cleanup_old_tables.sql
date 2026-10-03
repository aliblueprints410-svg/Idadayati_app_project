-- ==============================================================================
-- تنظيف وحذف الجداول القديمة التي لم نعد نستخدمها نهائياً
-- (حذف جداول idadayati_* و madrasati_*)
-- والإبقاء حصرياً على جداول المنظومة الموحدة الجديدة (taleb_*)
-- ==============================================================================

-- 1. حذف جداول إعداديتي القديمة
DROP TABLE IF EXISTS idadayati_announcement_comments CASCADE;
DROP TABLE IF EXISTS idadayati_announcements CASCADE;
DROP TABLE IF EXISTS idadayati_homework CASCADE;
DROP TABLE IF EXISTS idadayati_subjects CASCADE;
DROP TABLE IF EXISTS idadayati_schedules CASCADE;
DROP TABLE IF EXISTS idadayati_classes CASCADE;
DROP TABLE IF EXISTS idadayati_school_teachers CASCADE;
DROP TABLE IF EXISTS idadayati_schools CASCADE;

-- 2. حذف جداول مدرستي القديمة
DROP TABLE IF EXISTS madrasati_announcement_comments CASCADE;
DROP TABLE IF EXISTS madrasati_announcements CASCADE;
DROP TABLE IF EXISTS madrasati_homework CASCADE;
DROP TABLE IF EXISTS madrasati_subjects CASCADE;
DROP TABLE IF EXISTS madrasati_schedules CASCADE;
DROP TABLE IF EXISTS madrasati_classes CASCADE;
DROP TABLE IF EXISTS madrasati_school_teachers CASCADE;
DROP TABLE IF EXISTS madrasati_schools CASCADE;
