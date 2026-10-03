-- ==============================================================================
-- كود حذف الجداول والواجهات القديمة (taleb_) بعد التحويل الكامل إلى (madrasati_)
-- ==============================================================================
-- قم بنسخ هذا الكود ولصقه في SQL Editor داخل Supabase والضغط على Run

-- 1. حذف الواجهات القديمة (Views) في حال كانت واجهات:
DROP VIEW IF EXISTS public.taleb_announcement_comments CASCADE;
DROP VIEW IF EXISTS public.taleb_announcements CASCADE;
DROP VIEW IF EXISTS public.taleb_classes CASCADE;
DROP VIEW IF EXISTS public.taleb_homework CASCADE;
DROP VIEW IF EXISTS public.taleb_schedules CASCADE;
DROP VIEW IF EXISTS public.taleb_school_teachers CASCADE;
DROP VIEW IF EXISTS public.taleb_schools CASCADE;
DROP VIEW IF EXISTS public.taleb_subjects CASCADE;

-- 2. حذف الجداول القديمة (Tables) في حال كانت جداول منفصلة:
DROP TABLE IF EXISTS public.taleb_announcement_comments CASCADE;
DROP TABLE IF EXISTS public.taleb_announcements CASCADE;
DROP TABLE IF EXISTS public.taleb_classes CASCADE;
DROP TABLE IF EXISTS public.taleb_homework CASCADE;
DROP TABLE IF EXISTS public.taleb_schedules CASCADE;
DROP TABLE IF EXISTS public.taleb_school_teachers CASCADE;
DROP TABLE IF EXISTS public.taleb_schools CASCADE;
DROP TABLE IF EXISTS public.taleb_subjects CASCADE;
