-- ==============================================================================
-- إعداد نظام العزل الفيزيائي بالجداول المخصصة (Prefix Isolation)
-- لمشروع Supabase المشترك بين "تطبيق مدرستي" و "تطبيق إعداديتي"
-- ==============================================================================

-- ==============================================================================
-- أولاً: نقل وإعادة تسمية جداول تطبيق "مدرستي" لتصبح ببادئة madrasati_
-- ==============================================================================

-- 1. جدول المدارس
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'schools') AND
       NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'madrasati_schools') THEN
        ALTER TABLE schools RENAME TO madrasati_schools;
    END IF;
END $$;

-- 2. جدول أساتذة المدارس
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'school_teachers') AND
       NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'madrasati_school_teachers') THEN
        ALTER TABLE school_teachers RENAME TO madrasati_school_teachers;
    END IF;
END $$;

-- 3. جدول الصفوف والشعب
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'classes') AND
       NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'madrasati_classes') THEN
        ALTER TABLE classes RENAME TO madrasati_classes;
    END IF;
END $$;

-- 4. جدول المواد الدراسية
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'subjects') AND
       NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'madrasati_subjects') THEN
        ALTER TABLE subjects RENAME TO madrasati_subjects;
    END IF;
END $$;

-- 5. جدول الواجبات والامتحانات
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'homework') AND
       NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'madrasati_homework') THEN
        ALTER TABLE homework RENAME TO madrasati_homework;
    END IF;
END $$;

-- 6. جدول الإعلانات والتبليغات
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'announcements') AND
       NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'madrasati_announcements') THEN
        ALTER TABLE announcements RENAME TO madrasati_announcements;
    END IF;
END $$;

-- 7. جدول التعليقات
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'announcement_comments') AND
       NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'madrasati_announcement_comments') THEN
        ALTER TABLE announcement_comments RENAME TO madrasati_announcement_comments;
    END IF;
END $$;

-- 8. جدول الجداول الأسبوعية
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'schedules') AND
       NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'madrasati_schedules') THEN
        ALTER TABLE schedules RENAME TO madrasati_schedules;
    END IF;
END $$;

-- إنشاء Views للتوافق التام (Backward Compatibility)
CREATE OR REPLACE VIEW schools AS SELECT * FROM madrasati_schools;
CREATE OR REPLACE VIEW school_teachers AS SELECT * FROM madrasati_school_teachers;
CREATE OR REPLACE VIEW classes AS SELECT * FROM madrasati_classes;
CREATE OR REPLACE VIEW subjects AS SELECT * FROM madrasati_subjects;
CREATE OR REPLACE VIEW homework AS SELECT * FROM madrasati_homework;
CREATE OR REPLACE VIEW announcements AS SELECT * FROM madrasati_announcements;
CREATE OR REPLACE VIEW announcement_comments AS SELECT * FROM madrasati_announcement_comments;
CREATE OR REPLACE VIEW schedules AS SELECT * FROM madrasati_schedules;

-- تفعيل RLS والصلاحيات لجداول مدرستي
ALTER TABLE IF EXISTS madrasati_schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS madrasati_school_teachers ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS madrasati_classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS madrasati_subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS madrasati_homework ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS madrasati_announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS madrasati_announcement_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS madrasati_schedules ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    DROP POLICY IF EXISTS "Public access madrasati_schools" ON madrasati_schools;
    CREATE POLICY "Public access madrasati_schools" ON madrasati_schools FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Public access madrasati_school_teachers" ON madrasati_school_teachers;
    CREATE POLICY "Public access madrasati_school_teachers" ON madrasati_school_teachers FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Public access madrasati_classes" ON madrasati_classes;
    CREATE POLICY "Public access madrasati_classes" ON madrasati_classes FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Public access madrasati_subjects" ON madrasati_subjects;
    CREATE POLICY "Public access madrasati_subjects" ON madrasati_subjects FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Public access madrasati_homework" ON madrasati_homework;
    CREATE POLICY "Public access madrasati_homework" ON madrasati_homework FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Public access madrasati_announcements" ON madrasati_announcements;
    CREATE POLICY "Public access madrasati_announcements" ON madrasati_announcements FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Public access madrasati_announcement_comments" ON madrasati_announcement_comments;
    CREATE POLICY "Public access madrasati_announcement_comments" ON madrasati_announcement_comments FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Public access madrasati_schedules" ON madrasati_schedules;
    CREATE POLICY "Public access madrasati_schedules" ON madrasati_schedules FOR ALL USING (true) WITH CHECK (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;


-- ==============================================================================
-- ثانياً: إنشاء جداول تطبيق "إعداديتي" المستقلة ببادئة idadayati_
-- ==============================================================================

-- 1. جدول مدارس إعداديتي
CREATE TABLE IF NOT EXISTS idadayati_schools (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    school_code TEXT UNIQUE NOT NULL,
    stage TEXT DEFAULT 'vocational',
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. جدول أساتذة إعداديتي
CREATE TABLE IF NOT EXISTS idadayati_school_teachers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    school_id UUID NOT NULL REFERENCES idadayati_schools(id) ON DELETE CASCADE,
    teacher_name TEXT NOT NULL,
    teacher_code TEXT NOT NULL,
    subject TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(school_id, teacher_code)
);

-- 3. جدول الصفوف والأقسام المهنية
CREATE TABLE IF NOT EXISTS idadayati_classes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    school_id UUID NOT NULL REFERENCES idadayati_schools(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    grade_level INT DEFAULT 10,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(school_id, name)
);

-- 4. جدول المواد التخصصية
CREATE TABLE IF NOT EXISTS idadayati_subjects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    class_id UUID NOT NULL REFERENCES idadayati_classes(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    icon TEXT DEFAULT 'book',
    color TEXT DEFAULT '#1E40AF',
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(class_id, name)
);

-- 5. جدول الواجبات والورش التخصصية
CREATE TABLE IF NOT EXISTS idadayati_homework (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    class_id UUID NOT NULL REFERENCES idadayati_classes(id) ON DELETE CASCADE,
    subject_id UUID NOT NULL REFERENCES idadayati_subjects(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    due_date TIMESTAMPTZ,
    image_url TEXT,
    is_deleted BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 6. جدول الإعلانات والتوجيهات المهنية
CREATE TABLE IF NOT EXISTS idadayati_announcements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    school_id UUID NOT NULL REFERENCES idadayati_schools(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    priority TEXT DEFAULT 'normal',
    image_url TEXT,
    is_pinned BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 7. جدول التعليقات
CREATE TABLE IF NOT EXISTS idadayati_announcement_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    announcement_id UUID NOT NULL REFERENCES idadayati_announcements(id) ON DELETE CASCADE,
    author_name TEXT NOT NULL,
    author_role TEXT DEFAULT 'student',
    content TEXT NOT NULL,
    is_approved BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 8. جدول الجداول الأسبوعية ومواعيد الورش
CREATE TABLE IF NOT EXISTS idadayati_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    class_id UUID UNIQUE NOT NULL REFERENCES idadayati_classes(id) ON DELETE CASCADE,
    schedule_data JSONB NOT NULL DEFAULT '{}'::jsonb,
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- تفعيل RLS والصلاحيات لجداول إعداديتي
ALTER TABLE idadayati_schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE idadayati_school_teachers ENABLE ROW LEVEL SECURITY;
ALTER TABLE idadayati_classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE idadayati_subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE idadayati_homework ENABLE ROW LEVEL SECURITY;
ALTER TABLE idadayati_announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE idadayati_announcement_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE idadayati_schedules ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    DROP POLICY IF EXISTS "Public access idadayati_schools" ON idadayati_schools;
    CREATE POLICY "Public access idadayati_schools" ON idadayati_schools FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Public access idadayati_school_teachers" ON idadayati_school_teachers;
    CREATE POLICY "Public access idadayati_school_teachers" ON idadayati_school_teachers FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Public access idadayati_classes" ON idadayati_classes;
    CREATE POLICY "Public access idadayati_classes" ON idadayati_classes FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Public access idadayati_subjects" ON idadayati_subjects;
    CREATE POLICY "Public access idadayati_subjects" ON idadayati_subjects FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Public access idadayati_homework" ON idadayati_homework;
    CREATE POLICY "Public access idadayati_homework" ON idadayati_homework FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Public access idadayati_announcements" ON idadayati_announcements;
    CREATE POLICY "Public access idadayati_announcements" ON idadayati_announcements FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Public access idadayati_announcement_comments" ON idadayati_announcement_comments;
    CREATE POLICY "Public access idadayati_announcement_comments" ON idadayati_announcement_comments FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Public access idadayati_schedules" ON idadayati_schedules;
    CREATE POLICY "Public access idadayati_schedules" ON idadayati_schedules FOR ALL USING (true) WITH CHECK (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;


-- ==============================================================================
-- ثالثاً: بذر بيانات مدرسة إعدادية كركوك المهنية والأقسام الـ 9 في idadayati_
-- ==============================================================================

INSERT INTO idadayati_schools (id, name, school_code, stage)
VALUES (
    'f8e7d6c5-b4a3-4210-9876-543210abcdef'::uuid,
    'إعدادية كركوك المهنية',
    'KIRKUK-VOC',
    'vocational'
)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    school_code = EXCLUDED.school_code,
    stage = EXCLUDED.stage;

DO $$
DECLARE
    sch_id uuid := 'f8e7d6c5-b4a3-4210-9876-543210abcdef'::uuid;
    dept_names text[] := ARRAY[
        'تكنولوجيا المعلومات والحاسوب',
        'الكهرباء',
        'الميكانيك',
        'السيارات',
        'الإلكترونيك والسيطرة',
        'التبريد والتكييف',
        'البناء والإنشاءات',
        'الاتصالات',
        'الأجهزة الطبية'
    ];
    dept text;
    c1_id uuid;
    c2_id uuid;
    c3_id uuid;
BEGIN
    FOREACH dept IN ARRAY dept_names
    LOOP
        -- المرحلة الأولى (الصف العاشر مهني)
        INSERT INTO idadayati_classes (school_id, name, grade_level)
        VALUES (sch_id, 'الأول مهني - ' || dept, 10)
        ON CONFLICT (school_id, name) DO UPDATE SET grade_level = 10
        RETURNING id INTO c1_id;

        -- المرحلة الثانية (الصف الحادي عشر مهني)
        INSERT INTO idadayati_classes (school_id, name, grade_level)
        VALUES (sch_id, 'الثاني مهني - ' || dept, 11)
        ON CONFLICT (school_id, name) DO UPDATE SET grade_level = 11
        RETURNING id INTO c2_id;

        -- المرحلة الثالثة (الصف الثاني عشر مهني - وزاري)
        INSERT INTO idadayati_classes (school_id, name, grade_level)
        VALUES (sch_id, 'الثالث مهني - ' || dept, 12)
        ON CONFLICT (school_id, name) DO UPDATE SET grade_level = 12
        RETURNING id INTO c3_id;

        -- مواد المرحلة الأولى
        INSERT INTO idadayati_subjects (class_id, name, icon, color) VALUES
            (c1_id, 'التربية الإسلامية', 'book', '#1E40AF'),
            (c1_id, 'اللغة العربية', 'menu_book', '#D97706'),
            (c1_id, 'اللغة الإنجليزية', 'language', '#2563EB'),
            (c1_id, 'الرياضيات العامة', 'calculate', '#059669'),
            (c1_id, 'الفيزياء والطبيعيات', 'science', '#7C3AED'),
            (c1_id, 'العلوم الصناعية التخصصية', 'engineering', '#B45309'),
            (c1_id, 'الرسم الهندسي والصناعي', 'architecture', '#0D9488'),
            (c1_id, 'التدريب العملي والورش', 'build', '#DC2626')
        ON CONFLICT (class_id, name) DO NOTHING;

        -- مواد المرحلة الثانية
        INSERT INTO idadayati_subjects (class_id, name, icon, color) VALUES
            (c2_id, 'التربية الإسلامية', 'book', '#1E40AF'),
            (c2_id, 'اللغة العربية', 'menu_book', '#D97706'),
            (c2_id, 'اللغة الإنجليزية', 'language', '#2563EB'),
            (c2_id, 'الرياضيات التطبيقية', 'calculate', '#059669'),
            (c2_id, 'العلوم الصناعية التخصصية (2)', 'engineering', '#B45309'),
            (c2_id, 'الرسم الصناعي التخصصي', 'architecture', '#0D9488'),
            (c2_id, 'التدريب العملي والمشاريع', 'precision_manufacturing', '#DC2626')
        ON CONFLICT (class_id, name) DO NOTHING;

        -- مواد المرحلة الثالثة (البكالوريا الوزاري)
        INSERT INTO idadayati_subjects (class_id, name, icon, color) VALUES
            (c3_id, 'التربية الإسلامية', 'book', '#1E40AF'),
            (c3_id, 'اللغة العربية (وزاري)', 'menu_book', '#D97706'),
            (c3_id, 'اللغة الإنجليزية (وزاري)', 'language', '#2563EB'),
            (c3_id, 'الرياضيات المهنية (وزاري)', 'calculate', '#059669'),
            (c3_id, 'العلوم الصناعية التخصصية (وزاري)', 'engineering', '#B45309'),
            (c3_id, 'الرسم الصناعي (وزاري)', 'architecture', '#0D9488'),
            (c3_id, 'التدريب العملي ومشاريع التخرج', 'workspace_premium', '#DC2626')
        ON CONFLICT (class_id, name) DO NOTHING;
    END LOOP;
END $$;
