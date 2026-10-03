# Project Rules & Instructions for AI Agents & Developers

This repository follows strict guidelines set by the product owner. Any AI agent or developer interacting with this codebase must adhere strictly to these rules.

---

## 1. Identity & Rebranding
* **App Name:** Moving to **«تطبيق مدرستي»** (Madrasati App) while strictly retaining the exact same logo and application icon.
* **Scope:** The platform caters to schools across Iraq:
  1. Primary Schools (ابتدائية)
  2. Middle Schools (متوسطة)
  3. Academic High Schools (إعدادية أكاديمية - علمي / أدبي)
  4. Vocational High Schools (إعدادية مهنية - بأقسامها المختلفة)

---

## 2. Mandatory Interaction & Confirmation Rules
* **Vocational School Request:** Whenever the user requests to add a "Vocational High School" (إعدادية مهنية), the agent **MUST PAUSE** and explicitly ask the user:
  > *"يرجى تزويدي بأقسام وتخصصات هذه الإعدادية المهنية لإضافتها بدقة"*
  Do NOT guess or add default departments without this explicit list.
* **Academic School Request:** Whenever the user requests to add an "Academic High School" (إعدادية أكاديمية), the agent **MUST PAUSE** and explicitly ask:
  > *"هل هذه الإعدادية الأكاديمية تقتصر على الفرع العلمي، أم الأدبي، أم كلاهما معاً؟"*

---

## 3. Strict Execution & Build Protocol
* **Strict Execution Rule:** DO NOT modify code or database records until the user explicitly says **«نفذ»** or **«أنشئ»**. Always analyze, propose, and confirm first.
* **No Unrequested Builds:** DO NOT run `flutter build` unless the user explicitly and directly commands it.
* **Output APK Naming:** Any generated APK must ALWAYS be named after the project (e.g. `Idadayati.apk` / `Talib.apk`). Never leave it as `app-release.apk`.
* **Git Commit & Push Rule:** Every code modification must be committed and pushed immediately to `origin main`:
  `https://github.com/aliblueprints410-svg/Idadayati_app_project.git`

---

## 4. UI & Visual Identity Guidelines
* **No Childish / Kindergarten Aesthetics:** Avoid candy/neon colors (hot pink, bright cartoon orange, neon purple) and childish clipart (soccer balls, toy calculators, paint palettes).
* **Mature Collegiate / Engineering Aesthetic:** Use deep, professional colors (Navy `#1E3A8A`, Deep Teal `#0F766E`, Slate Steel `#334155`, Copper `#9A3412`, Indigo `#4338CA`) and mature icons (Advanced Math functions $\sum$, CAD/architecture, precision manufacturing, cyber defense, server hubs, literature quills, holy book).
