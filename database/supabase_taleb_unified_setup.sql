-- ==============================================================================
-- منظومة "تطبيق طالب" الموحدة - Supabase Unified Setup (taleb_*)
-- منصة التعليم الذكية الشاملة لجميع مدارس العراق:
-- 1. المدارس الابتدائية (primary)
-- 2. المدارس المتوسطة (middle)
-- 3. المدارس الإعدادية الأكاديمية - علمي / أدبي (academic)
-- 4. المدارس الإعدادية المهنية - الورش والأقسام التخصصية (vocational)
-- ==============================================================================

-- ==============================================================================
-- 1. إنشاء الجداول الموحدة (taleb_*)
-- ==============================================================================

-- جدول المدارس الموحد
CREATE TABLE IF NOT EXISTS taleb_schools (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    school_code TEXT UNIQUE NOT NULL,
    school_type TEXT NOT NULL DEFAULT 'middle', -- 'primary', 'middle', 'academic', 'vocational'
    stage TEXT DEFAULT 'middle',
    governorate TEXT DEFAULT 'العراق',
    created_at TIMESTAMPTZ DEFAULT now()
);

-- جدول الأساتذة الموحد
CREATE TABLE IF NOT EXISTS taleb_school_teachers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    school_id UUID NOT NULL REFERENCES taleb_schools(id) ON DELETE CASCADE,
    teacher_name TEXT NOT NULL,
    teacher_code TEXT NOT NULL,
    subject TEXT,
    email TEXT,
    school_code TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(school_id, teacher_code)
);

-- جدول الصفوف والأقسام الموحد
CREATE TABLE IF NOT EXISTS taleb_classes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    school_id UUID NOT NULL REFERENCES taleb_schools(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    grade_level INT DEFAULT 1,
    "order" INT DEFAULT 0,
    schedule_image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(school_id, name)
);

-- جدول المواد الدراسية والورش
CREATE TABLE IF NOT EXISTS taleb_subjects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    class_id UUID NOT NULL REFERENCES taleb_classes(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    icon TEXT DEFAULT 'book',
    color TEXT DEFAULT '#1E40AF',
    is_baccalaureate BOOLEAN DEFAULT false,
    is_workshop BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(class_id, name)
);

-- جدول الواجبات والامتحانات
CREATE TABLE IF NOT EXISTS taleb_homework (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    class_id UUID NOT NULL REFERENCES taleb_classes(id) ON DELETE CASCADE,
    subject_id UUID NOT NULL REFERENCES taleb_subjects(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    due_date TIMESTAMPTZ,
    deadline TIMESTAMPTZ,
    image_url TEXT,
    is_current BOOLEAN DEFAULT true,
    is_deleted BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- جدول الإعلانات والتبليغات المدرسية
CREATE TABLE IF NOT EXISTS taleb_announcements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    school_id UUID NOT NULL REFERENCES taleb_schools(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    priority TEXT DEFAULT 'normal',
    image_url TEXT,
    is_pinned BOOLEAN DEFAULT false,
    is_deleted BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- جدول التعليقات
CREATE TABLE IF NOT EXISTS taleb_announcement_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    announcement_id UUID NOT NULL REFERENCES taleb_announcements(id) ON DELETE CASCADE,
    author_name TEXT NOT NULL,
    author_role TEXT DEFAULT 'student',
    content TEXT NOT NULL,
    is_approved BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- جدول الجداول الأسبوعية
CREATE TABLE IF NOT EXISTS taleb_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    class_id UUID UNIQUE NOT NULL REFERENCES taleb_classes(id) ON DELETE CASCADE,
    schedule_data JSONB NOT NULL DEFAULT '{}'::jsonb,
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- ==============================================================================
-- 2. تفعيل نظام الأمان المتقدم (RLS) وسياسات الوصول
-- ==============================================================================

ALTER TABLE taleb_schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE taleb_school_teachers ENABLE ROW LEVEL SECURITY;
ALTER TABLE taleb_classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE taleb_subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE taleb_homework ENABLE ROW LEVEL SECURITY;
ALTER TABLE taleb_announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE taleb_announcement_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE taleb_schedules ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    DROP POLICY IF EXISTS "Public access taleb_schools" ON taleb_schools;
    CREATE POLICY "Public access taleb_schools" ON taleb_schools FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Public access taleb_school_teachers" ON taleb_school_teachers;
    CREATE POLICY "Public access taleb_school_teachers" ON taleb_school_teachers FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Public access taleb_classes" ON taleb_classes;
    CREATE POLICY "Public access taleb_classes" ON taleb_classes FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Public access taleb_subjects" ON taleb_subjects;
    CREATE POLICY "Public access taleb_subjects" ON taleb_subjects FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Public access taleb_homework" ON taleb_homework;
    CREATE POLICY "Public access taleb_homework" ON taleb_homework FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Public access taleb_announcements" ON taleb_announcements;
    CREATE POLICY "Public access taleb_announcements" ON taleb_announcements FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Public access taleb_announcement_comments" ON taleb_announcement_comments;
    CREATE POLICY "Public access taleb_announcement_comments" ON taleb_announcement_comments FOR ALL USING (true) WITH CHECK (true);

    DROP POLICY IF EXISTS "Public access taleb_schedules" ON taleb_schedules;
    CREATE POLICY "Public access taleb_schedules" ON taleb_schedules FOR ALL USING (true) WITH CHECK (true);
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- ==============================================================================
-- 3. ترحيل البيانات السابقة بأمان (من madrasati_ و idadayati_ إلى taleb_)
-- ==============================================================================

-- ترحيل المدارس
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'madrasati_schools') THEN
        INSERT INTO taleb_schools (id, name, school_code, school_type, stage)
        SELECT id, name, school_code, COALESCE(stage, 'middle'), COALESCE(stage, 'middle')
        FROM madrasati_schools
        ON CONFLICT (id) DO NOTHING;
    END IF;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'idadayati_schools') THEN
        INSERT INTO taleb_schools (id, name, school_code, school_type, stage)
        SELECT id, name, school_code, 'vocational', 'vocational'
        FROM idadayati_schools
        ON CONFLICT (id) DO NOTHING;
    END IF;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- ترحيل الصفوف
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'madrasati_classes') THEN
        INSERT INTO taleb_classes (id, school_id, name)
        SELECT id, school_id, name
        FROM madrasati_classes
        ON CONFLICT (id) DO NOTHING;
    END IF;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'idadayati_classes') THEN
        INSERT INTO taleb_classes (id, school_id, name)
        SELECT id, school_id, name
        FROM idadayati_classes
        ON CONFLICT (id) DO NOTHING;
    END IF;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- ترحيل المواد
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'madrasati_subjects') THEN
        INSERT INTO taleb_subjects (id, class_id, name, icon, color)
        SELECT id, class_id, name, icon, color
        FROM madrasati_subjects
        ON CONFLICT (id) DO NOTHING;
    END IF;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'idadayati_subjects') THEN
        INSERT INTO taleb_subjects (id, class_id, name, icon, color)
        SELECT id, class_id, name, icon, color
        FROM idadayati_subjects
        ON CONFLICT (id) DO NOTHING;
    END IF;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- ترحيل الواجبات والإعلانات
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'madrasati_homework') THEN
        INSERT INTO taleb_homework (id, class_id, subject_id, title, description, image_url)
        SELECT id, class_id, subject_id, title, description, image_url
        FROM madrasati_homework
        ON CONFLICT (id) DO NOTHING;
    END IF;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'idadayati_homework') THEN
        INSERT INTO taleb_homework (id, class_id, subject_id, title, description, image_url)
        SELECT id, class_id, subject_id, title, description, image_url
        FROM idadayati_homework
        ON CONFLICT (id) DO NOTHING;
    END IF;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'madrasati_announcements') THEN
        INSERT INTO taleb_announcements (id, school_id, title, content)
        SELECT id, school_id, title, content
        FROM madrasati_announcements
        ON CONFLICT (id) DO NOTHING;
    END IF;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'idadayati_announcements') THEN
        INSERT INTO taleb_announcements (id, school_id, title, content)
        SELECT id, school_id, title, content
        FROM idadayati_announcements
        ON CONFLICT (id) DO NOTHING;
    END IF;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- ==============================================================================
-- 4. دالة ذكية لإضافة أو تسجيل أي مدرسة جديدة مع صفوفها وموادها حسب النوع
-- ==============================================================================

CREATE OR REPLACE FUNCTION register_taleb_school(
    p_name TEXT,
    p_code TEXT,
    p_type TEXT, -- 'primary', 'middle', 'academic', 'vocational'
    p_gov TEXT DEFAULT 'كركوك'
)
RETURNS UUID AS $$
DECLARE
    v_school_id UUID;
    v_class_id UUID;
    v_c1 UUID; v_c2 UUID; v_c3 UUID;
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
BEGIN
    -- 1. إضافة أو تحديث المدرسة
    INSERT INTO taleb_schools (name, school_code, school_type, stage, governorate)
    VALUES (p_name, UPPER(p_code), p_type, p_type, p_gov)
    ON CONFLICT (school_code) DO UPDATE SET
        name = EXCLUDED.name,
        school_type = EXCLUDED.school_type,
        stage = EXCLUDED.stage,
        governorate = EXCLUDED.governorate
    RETURNING id INTO v_school_id;

    -- 2. توليد الصفوف والمواد تلقائياً حسب نوع المدرسة:

    -- أ. مدرسة ابتدائية (primary)
    IF p_type = 'primary' THEN
        FOR g IN 1..6 LOOP
            INSERT INTO taleb_classes (school_id, name, grade_level, "order")
            VALUES (v_school_id, 
                CASE g 
                    WHEN 1 THEN 'الأول الابتدائي'
                    WHEN 2 THEN 'الثاني الابتدائي'
                    WHEN 3 THEN 'الثالث الابتدائي'
                    WHEN 4 THEN 'الرابع الابتدائي'
                    WHEN 5 THEN 'الخامس الابتدائي'
                    ELSE 'السادس الابتدائي (بكالوريا)'
                END, g, g)
            ON CONFLICT (school_id, name) DO NOTHING
            RETURNING id INTO v_class_id;

            IF v_class_id IS NOT NULL THEN
                INSERT INTO taleb_subjects (class_id, name, icon, color, is_baccalaureate) VALUES
                    (v_class_id, 'التربية الإسلامية', 'book', '#1E40AF', g = 6),
                    (v_class_id, 'اللغة العربية', 'menu_book', '#D97706', g = 6),
                    (v_class_id, 'اللغة الإنجليزية', 'language', '#2563EB', g = 6),
                    (v_class_id, 'الرياضيات', 'calculate', '#059669', g = 6),
                    (v_class_id, 'العلوم', 'science', '#7C3AED', g = 6)
                ON CONFLICT (class_id, name) DO NOTHING;
            END IF;
        END LOOP;

    -- ب. مدرسة متوسطة (middle)
    ELSIF p_type = 'middle' THEN
        FOR g IN 1..3 LOOP
            INSERT INTO taleb_classes (school_id, name, grade_level, "order")
            VALUES (v_school_id, 
                CASE g 
                    WHEN 1 THEN 'الأول المتوسط'
                    WHEN 2 THEN 'الثاني المتوسط'
                    ELSE 'الثالث المتوسط (وزاري)'
                END, g + 6, g)
            ON CONFLICT (school_id, name) DO NOTHING
            RETURNING id INTO v_class_id;

            IF v_class_id IS NOT NULL THEN
                INSERT INTO taleb_subjects (class_id, name, icon, color, is_baccalaureate) VALUES
                    (v_class_id, 'التربية الإسلامية', 'book', '#1E40AF', g = 3),
                    (v_class_id, 'اللغة العربية', 'menu_book', '#D97706', g = 3),
                    (v_class_id, 'اللغة الإنجليزية', 'language', '#2563EB', g = 3),
                    (v_class_id, 'الرياضيات', 'calculate', '#059669', g = 3),
                    (v_class_id, 'الفيزياء', 'science', '#7C3AED', g = 3),
                    (v_class_id, 'الكيمياء', 'biotech', '#EA580C', g = 3),
                    (v_class_id, 'الأحياء', 'eco', '#16A34A', g = 3),
                    (v_class_id, 'الاجتماعيات', 'public', '#4F46E5', g = 3),
                    (v_class_id, 'الحاسوب', 'computer', '#0D9488', false)
                ON CONFLICT (class_id, name) DO NOTHING;
            END IF;
        END LOOP;

    -- ج. إعدادية أكاديمية (academic: علمي / أدبي)
    ELSIF p_type = 'academic' THEN
        -- الرابع والخامس والسادس (علمي وأدبي)
        INSERT INTO taleb_classes (school_id, name, grade_level, "order") VALUES
            (v_school_id, 'الرابع العلمي', 10, 1),
            (v_school_id, 'الرابع الأدبي', 10, 2),
            (v_school_id, 'الخامس العلمي', 11, 3),
            (v_school_id, 'الخامس الأدبي', 11, 4),
            (v_school_id, 'السادس العلمي (وزاري)', 12, 5),
            (v_school_id, 'السادس الأدبي (وزاري)', 12, 6)
        ON CONFLICT (school_id, name) DO NOTHING;

    -- د. إعدادية مهنية (vocational: الـ 9 أقسام)
    ELSIF p_type = 'vocational' THEN
        FOREACH dept IN ARRAY dept_names
        LOOP
            INSERT INTO taleb_classes (school_id, name, grade_level, "order")
            VALUES (v_school_id, 'الأول مهني - ' || dept, 10, 1)
            ON CONFLICT (school_id, name) DO NOTHING RETURNING id INTO v_c1;

            INSERT INTO taleb_classes (school_id, name, grade_level, "order")
            VALUES (v_school_id, 'الثاني مهني - ' || dept, 11, 2)
            ON CONFLICT (school_id, name) DO NOTHING RETURNING id INTO v_c2;

            INSERT INTO taleb_classes (school_id, name, grade_level, "order")
            VALUES (v_school_id, 'الثالث مهني (وزاري) - ' || dept, 12, 3)
            ON CONFLICT (school_id, name) DO NOTHING RETURNING id INTO v_c3;

            IF v_c1 IS NOT NULL THEN
                INSERT INTO taleb_subjects (class_id, name, icon, color, is_workshop) VALUES
                    (v_c1, 'العلوم الصناعية التخصصية', 'engineering', '#B45309', false),
                    (v_c1, 'الرسم الهندسي والصناعي', 'architecture', '#0D9488', false),
                    (v_c1, 'التدريب العملي والورش', 'build', '#DC2626', true)
                ON CONFLICT (class_id, name) DO NOTHING;
            END IF;
            IF v_c3 IS NOT NULL THEN
                INSERT INTO taleb_subjects (class_id, name, icon, color, is_baccalaureate, is_workshop) VALUES
                    (v_c3, 'العلوم الصناعية (وزاري)', 'engineering', '#B45309', true, false),
                    (v_c3, 'الرسم الصناعي (وزاري)', 'architecture', '#0D9488', true, false),
                    (v_c3, 'التدريب العملي ومشاريع التخرج', 'workspace_premium', '#DC2626', true, true)
                ON CONFLICT (class_id, name) DO NOTHING;
            END IF;
        END LOOP;
    END IF;

    RETURN v_school_id;
END;
$$ LANGUAGE plpgsql;

-- ==============================================================================
-- 5. بذر المدارس النموذجية المعتمدة فورياً
-- ==============================================================================

-- 1. إعدادية كركوك المهنية (KIRKUK-VOC)
SELECT register_taleb_school('إعدادية كركوك المهنية', 'KIRKUK-VOC', 'vocational', 'كركوك');

-- 2. متوسطة العناوين للبنين (ANAWEEN-MID)
SELECT register_taleb_school('متوسطة العناوين للبنين', 'ANAWEEN-MID', 'middle', 'كركوك');

-- 3. إعدادية المتميزين النموذجية (MUTAMAYIZIN-ACAD)
SELECT register_taleb_school('إعدادية المتميزين للبنين', 'MUTAMAYIZIN-ACAD', 'academic', 'بغداد');

-- 4. مدرسة دجلة الابتدائية النموذجية (DIJLAH-PRI)
SELECT register_taleb_school('مدرسة دجلة الابتدائية للبنين', 'DIJLAH-PRI', 'primary', 'بغداد');
