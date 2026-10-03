-- ==============================================================================
-- سكريبت تنظيف وإزالة الصفوف المكررة من قاعدة بيانات تطبيق "مدرستي"
-- إزالة التكرار في جدول taleb_classes والاحتفاظ بنسخة فريدة واحدة لكل صف
-- ==============================================================================

-- 1. حذف التكرار في taleb_classes مع إبقاء الصف صاحب المعرّف الأحدث أو المحتوي على وسوم وزارية
DELETE FROM taleb_classes
WHERE id IN (
    SELECT id
    FROM (
        SELECT id,
               ROW_NUMBER() OVER (
                   PARTITION BY school_id, 
                                regexp_replace(regexp_replace(name, '\(وزاري\)', '', 'g'), '\(بكالوريا\)', '', 'g')
                   ORDER BY 
                       CASE WHEN name LIKE '%وزاري%' OR name LIKE '%بكالوريا%' THEN 1 ELSE 2 END,
                       created_at DESC
               ) AS rnum
        FROM taleb_classes
    ) t
    WHERE t.rnum > 1
);

-- 2. إزالة التكرار في جدول classes القديم إن وجد
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'classes') THEN
        DELETE FROM classes
        WHERE id IN (
            SELECT id
            FROM (
                SELECT id,
                       ROW_NUMBER() OVER (
                           PARTITION BY school_id, 
                                        regexp_replace(regexp_replace(name, '\(وزاري\)', '', 'g'), '\(بكالوريا\)', '', 'g')
                           ORDER BY id
                       ) AS rnum
                FROM classes
            ) c
            WHERE c.rnum > 1
        );
    END IF;
END $$;
