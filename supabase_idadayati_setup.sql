-- ==============================================================
-- إعداد قاعدة بيانات تطبيق "إعداديتي" - إعدادية كركوك المهنية
-- منصة مستقلة تماماً للتعليم المهني والإعدادي
-- ==============================================================

-- 1. إضافة المدرسة برمز فريد وخاص (KIRKUK-VOC)
INSERT INTO schools (id, name, school_code, stage)
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

-- 2. إدخال الأقسام الـ 9 والمراحل الـ 3 (27 صفاً تخصصياً)
DO $$
DECLARE
    sch_id uuid := 'f8e7d6c5-b4a3-4210-9876-543210abcdef'::uuid;
    dept_names text[] := ARRAY[
        'ميكانيك',
        'أمن سيبراني',
        'نجارة',
        'بناء',
        'حاسوب',
        'تكييف',
        'تكرير نفط',
        'لحام',
        'بتروكيمياوي'
    ];
    dept text;
    c1_id uuid;
    c2_id uuid;
    c3_id uuid;
BEGIN
    FOREACH dept IN ARRAY dept_names
    LOOP
        -- المرحلة الأولى
        INSERT INTO classes (school_id, name, grade_level)
        VALUES (sch_id, 'الأول مهني - ' || dept, 10)
        ON CONFLICT (school_id, name) DO UPDATE SET grade_level = 10
        RETURNING id INTO c1_id;

        -- المرحلة الثانية
        INSERT INTO classes (school_id, name, grade_level)
        VALUES (sch_id, 'الثاني مهني - ' || dept, 11)
        ON CONFLICT (school_id, name) DO UPDATE SET grade_level = 11
        RETURNING id INTO c2_id;

        -- المرحلة الثالثة (وزاري)
        INSERT INTO classes (school_id, name, grade_level)
        VALUES (sch_id, 'الثالث مهني - ' || dept, 12)
        ON CONFLICT (school_id, name) DO UPDATE SET grade_level = 12
        RETURNING id INTO c3_id;

        -- المواد العامة والتخصصية لكل مرحلة
        -- مواد المرحلة الأولى
        INSERT INTO subjects (class_id, name, icon, color) VALUES
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
        INSERT INTO subjects (class_id, name, icon, color) VALUES
            (c2_id, 'التربية الإسلامية', 'book', '#1E40AF'),
            (c2_id, 'اللغة العربية', 'menu_book', '#D97706'),
            (c2_id, 'اللغة الإنجليزية', 'language', '#2563EB'),
            (c2_id, 'الرياضيات التطبيقية', 'calculate', '#059669'),
            (c2_id, 'العلوم الصناعية التخصصية (2)', 'engineering', '#B45309'),
            (c2_id, 'الرسم الصناعي التخصصي', 'architecture', '#0D9488'),
            (c2_id, 'التدريب العملي والمشاريع', 'precision_manufacturing', '#DC2626')
        ON CONFLICT (class_id, name) DO NOTHING;

        -- مواد المرحلة الثالثة (البكالوريا الوزاري)
        INSERT INTO subjects (class_id, name, icon, color) VALUES
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
