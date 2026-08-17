#!/bin/sh
# run from repository root folder: /data/all/projects/git/krl_multimedia_dict
OUTPUT_FILE="out_gitingest/krl_multimedia_dict_android_v23.md"

mkdir -p out_gitingest

# 1) Основной сбор через gitingest (Groovy *.gradle сюда НЕ попадут — это баг/фича самого gitingest)
gitingest . \
  --include-pattern "lib/**/*.dart" \
  --include-pattern "test/**/*.dart" \
  --include-pattern "pubspec.yaml" \
  --include-pattern "pubspec.lock" \
  --include-pattern "analysis_options.yaml" \
  --include-pattern "android/gradle.properties" \
  --include-pattern "android/gradle/wrapper/gradle-wrapper.properties" \
  --include-pattern "android/app/src/**/AndroidManifest.xml" \
  --include-pattern "android/app/src/main/kotlin/**/*.kt" \
  --include-pattern "android/app/src/main/res/values*/*.xml" \
  --include-pattern "android/app/src/main/res/drawable*/*.xml" \
  --include-pattern "lib/l10n/*.arb" \
  --include-pattern "l10n.yaml" \
  --include-pattern "README.md" \
  --exclude-pattern "LICENSE" \
  --exclude-pattern "ios/*" \
  --exclude-pattern "macos/*" \
  --exclude-pattern "linux/*" \
  --exclude-pattern "windows/*" \
  --exclude-pattern "web/*" \
  --exclude-pattern "assets/*" \
  --exclude-pattern "*/build/*" \
  --exclude-pattern "*.png" \
  --exclude-pattern "*.jpg" \
  --exclude-pattern "*.wav" \
  --exclude-pattern "*.ttf" \
  --output "$OUTPUT_FILE"

# 2) Дописываем файлы *.gradle вручную — gitingest их принципиально игнорирует
#    (см. DEFAULT_IGNORE_PATTERNS в исходниках gitingest: "*.gradle" зашит намертво)
for f in android/settings.gradle android/build.gradle android/app/build.gradle; do
  {
    echo ""
    echo "================================================"
    echo "FILE: $f"
    echo "================================================"
    cat "$f"
    echo ""
  } >> "$OUTPUT_FILE"
done
