do
    local addonId = ...
    local languageTable = DetailsFramework.Language.RegisterLanguage(addonId, "arAR", true, "العربية", [[Interface\AddOns\Plater\fonts\NotoNaskhArabic-Regular.ttf]])
    local L = languageTable

    L["OPTIONS_NAMEPLATE_HIDE_FRIENDLY_HEALTH_DESC"] = [["عند القيام بالتحديات أو العمليات، إذا تم تمكين الصحون الخاصة بالأصدقاء فسيتم عرض اسم اللاعب فقط.
    إذا تم تعطيل أي وحدة من وحدات Plater، فسوف يؤثر هذا على هذه الصحون أيضًا.

    |cFFFF7700[*]|r |cFFa0a0a0CVar، يتم حفظها داخل ملف تعريف Plater واستعادتها عند تحميل الملف التعريفي.|r

    |cFFFF2200[*]|r |cFFa0a0a0قد يتطلب /reload للتأثير.|r]]

    L["OPTIONS_RANGECHECK_NOTMYTARGETOUTOFRANGE_DESC"] = [[يقلل من شفافية الوحدات التي ليست هدفك.
    يقلل أكثر إذا كانت الوحدة خارج نطاق الوصول.]]

    L["OPTIONS_CVAR_ENABLE_PERSONAL_BAR_DESC"] = [[يظهر أشرطة صغيرة للصحة والطاقة تحت شخصيتك.

    |cFFFF7700[*]|r |cFFa0a0a0CVar، يتم حفظها داخل ملف تعريف Plater واستعادتها عند تحميل الملف التعريفي.|r]]

    L["OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK"] = "فحص المدى"
    L["OPTIONS_GENERALSETTINGS_HEALTHBAR_ANCHOR_TITLE"] = "مظهر شريط الصحة"
    L["OPTIONS_AURAS_ENABLETEST"] = "تمكين هذا لإخفاء الأوامر الاختبارية التي تظهر عند التكوين."
    L["OPTIONS_GENERALSETTINGS_HEALTHBAR_BGCOLOR"] = "لون خلفية شريط الصحة والشفافية"
    L["OPTIONS_TABNAME_NPC_COLORNAME"] = "ألوان وأسماء الـNPC"
    L["OPTIONS_STACK_SIMILAR_AURAS"] = "تراكم الأوامر المشابهة"
    L["OPTIONS_THREAT_AGGROSTATE_HIGHTHREAT"] = "تهديد عالٍ"

    L["OPTIONS_TABNAME_ANIMATIONS"] = "ردود الفعل على الفعاليات السحرية"
    L["OPTIONS_PROFILE_CONFIG_MOREPROFILES"] = "احصل على ملفات تعريف إضافية على Wago.io"
    L["OPTIONS_PROFILE_CONFIG_IMPORTPROFILE"] = "استيراد ملف تعريف"
    L["OPTIONS_PROFILE_CONFIG_EXPORTPROFILE"] = "تصدير ملف تعريف"
    L["OPTIONS_PROFILE_CONFIG_EXPORTINGTASK"] = "يقوم برنامج Plater بتصدير الملف التعريفي الحالي"
    L["OPTIONS_ALPHABYFRAME_ALPHAMULTIPLIER"] = "مضاعف الشفافية"
    L["OPTIONS_ALPHABYFRAME_ENABLE_ENEMIES_DESC"] = "تطبيق إعدادات الشفافية على الوحدات العدوانية."
    L["OPTIONS_MOVE_HORIZONTAL"] = "التحريك أفقيًا."
    L["OPTIONS_BORDER_COLOR"] = "لون الحدود"
    L["OPTIONS_PROFILE_IMPORT_OVERWRITE"] = "الملف التعريفي '%s' موجود بالفعل، هل تريد الكتابة فوقه؟"
    L["OPTIONS_CLICK_SPACE_HEIGHT"] = "ارتفاع مساحة النقر التي تقبل النقر بالفأرة لتحديد الهدف"
    L["OPTIONS_TABNAME_ADVANCED"] = "متقدم"
    L["OPTIONS_ALPHABYFRAME_ENABLE_ENEMIES"] = "تمكين الإعدادات للأعداء"
    L["OPTIONS_MINOR_SCALE_DESC"] = "ضبط حجم لوحات الأسماء قليلاً عند عرض وحدة ثانوية (تتميز هذه الوحدات بلوحة اسم أصغر بشكل افتراضي)."
    L["OPTIONS_AURAS_SORT_DESC"] = "ترتيب الأفاتر بواسطة المدة المتبقية (افتراضي)."
    L["OPTIONS_AURAS_SORT"] = "فرز الأفاتر"
    L["OPTIONS_NAMEPLATE_SHOW_FRIENDLY"] = "إظهار لوحات الأسماء الودية|cFFFF7700*|r"
    L["OPTIONS_AMOUNT"] = "المبلغ"
    L["OPTIONS_NOCOMBATALPHA_AMOUNT_DESC"] = "مقدار الشفافية لـ 'لا توجد معارك'."
    L["OPTIONS_ICONROWSPACING"] = "مسافة بين صفوف الأيقونات"
    L["OPTIONS_SHOWTOOLTIP"] = "إظهار تلميح الأداة"
    L["OPTIONS_PET_SCALE_DESC"] = "ضبط حجم لوحات الأسماء قليلاً عند عرض حيوان أليف"
    L["OPTIONS_MINOR_SCALE_WIDTH"] = "مقياس عرض الوحدة الثانوية"

    L["OPTIONS_THREAT_COLOR_OVERRIDE_DESC"] = [[قم بتعديل الألوان الافتراضية التي يحددها اللعبة للوحدات المحايدة والمعادية والودية.

    أثناء المعارك، ستتم إعادة الألوان بما يتماشى مع ألوان التهديد إذا تم السماح بتغيير لون شريط الصحة.]]

    L["OPTIONS_HEALTHBAR_SIZE_GLOBAL_DESC"] = [[قم بتغيير حجم لوحات الأسماء الخاصة بالأعداء والأصدقاء للاعبين والوحوش، سواء كنت في المعركة أو خارجها.

    يمكن تغيير كل واحدة من هذه الخيارات بشكل فردي على علامة التبويب وحدات الوحوش واللاعبين العدائين واللاعبين الودودين.]]

    L["OPTIONS_NAMEPLATES_OVERLAP_DESC"] = [[المسافة بين كل لوحة اسم عموديًا عند تمكين تكديس اللوحات.

    |cFFFFFFFFالافتراضي: 1.10|r

    |cFFFF7700[*]|r |cFFa0a0a0التعديلات التي تم حفظها ضمن ملف تعريف Plater والتي يتم استعادتها عند تحميل الملف التعريفي.|r

    |cFFFFFF00مهم |r: إذا وجدت مشاكل مع هذا الإعداد، استخدم الأمر التالي:
    |cFFFFFFFF/run SetCVar ('nameplateOverlapV', '1.6')|r]]

    L["OPTIONS_NOCOMBATALPHA_ENABLED_DESC"] = [[يقوم بتغيير شفافية لوحات الأسماء عندما تكون في المعركة وليس الوحدة.

    |cFFFFFF00مهم |r: إذا لم يكن الوحدة في المعركة، فإنه يعدل الشفافية من مراقبة المدى.]]

    L["OPTIONS_PROFILE_ERROR_WRONGTAB"] = [[بيانات ملف التعريف غير صالحة.

    استورد البرامج النصية أو التعديلات على علامة التبويب البرمجة أو التعديلات.]]

    L["OPTIONS_CVAR_NAMEPLATES_ALWAYSSHOW_DESC"] = [[عرض لافتات الأسماء لجميع الوحدات القريبة منك. إذا تم تعطيل هذا الإعداد، يتم عرض الوحدات المتعلقة فقط عندما تكون في حالة قتالية.

    |cFFFF7700[*]|r |cFFa0a0a0CVar ، يتم حفظها داخل ملف تعريف Plater واستعادتها عند تحميل الملف.|r]]

    L["OPTIONS_PROFILE_CONFIG_PROFILENAME_DESC"] = [[يتم إنشاء ملف تعريف جديد بالسلسلة المستوردة.

    إدخال اسم ملف تعريف موجود بالفعل سيؤدي إلى استبداله.]]

    L["OPTIONS_TABNAME_GENERALSETTINGS"] = "الإعدادات العامة"
    L["OPTIONS_NAMEPLATES_OVERLAP"] = "تداخل الوحدات النمطية (V)|cFFFF7700*|r"
    L["OPTIONS_TABNAME_CASTCOLORS"] = "ألوان القدرات والأسماء"
    L["OPTIONS_TABNAME_BUFF_TRACKING"] = "تعقب المُعالجات"
    L["OPTIONS_TABNAME_BUFF_LIST"] = "قائمة القدرات"
    L["OPTIONS_STACK_SIMILAR_AURAS_DESC"] = "المُعالجات التي لديها نفس الاسم (مثل العرضة غير المستقرة للدواجن) تتراكم معًا."
    L["OPTIONS_TABNAME_AUTO"] = "تلقائي"
    L["OPTIONS_STATUSBAR_TEXT"] = "يمكنك الآن استيراد الإعدادات، والتعديلات، والنصوص البرمجية، والتحريكات، وجداول الألوان من |cFFFFAA00http://wago.io|r"
    L["OPTIONS_PROFILE_CONFIG_OPENSETTINGS"] = "فتح إعدادات الملف الشخصي"
    L["OPTIONS_ALPHABYFRAME_DEFAULT"] = "الشفافية الافتراضية"
    L["OPTIONS_FORMAT_NUMBER"] = "تنسيق الرقم"
    L["OPTIONS_BACKGROUND_ALWAYSSHOW_DESC"] = "تمكين خلفية تظهر منطقة النقر بداية من الإطار."
    L["OPTIONS_FRIENDLY"] = "صديقة"
    L["OPTIONS_HOSTILE"] = "معادية"
    L["OPTIONS_TABNAME_PLAYERFRIENDLY"] = "اللاعبون الأصدقاء"
    L["OPTIONS_ICONSPACING"] = "تباعد الرموز"
    L["OPTIONS_ALPHABYFRAME_TARGET_INRANGE_DESC"] = "شفافية الوحدات المستهدفة أو التي في المدى."

    L["OPTIONS_THREAT_AGGROSTATE_NOTINCOMBAT"] = "الوحدة ليست في القتال"
    L["OPTIONS_MOVE_VERTICAL"] = "تحريك بشكل عمودي."
    L["OPTIONS_THREAT_AGGROSTATE_NOTANK"] = "لا يوجد احتكاك بالدبابة"
    L["OPTIONS_THREAT_AGGROSTATE_ANOTHERTANK"] = "احتكاك بدبابة أخرى"
    L["OPTIONS_RANGECHECK_NONE"] = "لا شيء"
    L["OPTIONS_HEIGHT"] = "الارتفاع"
    L["OPTIONS_TABNAME_THREAT"] = "الألوان / التهديد"
    L["OPTIONS_RANGECHECK_OUTOFRANGE_DESC"] = "عندما تكون لوحة الاسم خارج مدى الرؤية ، يتم تقليل الشفافية."
    L["OPTIONS_TABNAME_TARGET"] = "الهدف"
    L["OPTIONS_TABNAME_STRATA"] = "المستوى والطبقة"
    L["OPTIONS_TABNAME_PROFILES"] = "الملفات الشخصية"
    L["OPTIONS_SETTINGS_FAIL_COPIED"] = "فشل في الحصول على الإعدادات لعلامة التبويب المحددة حاليًا."
    L["OPTIONS_TABNAME_PLAYERENEMY"] = "اللاعب العدو"
    L["OPTIONS_GENERALSETTINGS_HEALTHBAR_BGTEXTURE"] = "نسيج خلفية شريط الصحة"
    L["OPTIONS_TABNAME_PERSONAL"] = "شريط شخصي"
    L["OPTIONS_RESOURCES_TARGET"] = "عرض الموارد على الهدف"
    L["OPTIONS_TABNAME_NPCENEMY"] = "الشخصيات الغير لاعبة الأعداء"
    L["OPTIONS_NAMEPLATE_HIDE_FRIENDLY_HEALTH"] = "إخفاء شريط الصحة الافتراضي|cFFFF7700*|r"

    L["OPTIONS_RANGECHECK_OUTOFRANGE"] = "الوحدات خارج نطاقك"
    L["OPTIONS_BORDER_THICKNESS"] = "سمك الحدود"
    L["OPTIONS_SHOWTOOLTIP_DESC"] = "إظهار تلميح عند التحويم فوق رمز الهالة."
    L["OPTIONS_THREAT_DPS_CANCHECKNOTANK"] = "التحقق من عدم وجود أي اهتمام بالتهديد"
    L["OPTIONS_THREAT_COLOR_TAPPED_DESC"] = "عندما يتم الاحتياط للوحدة من شخص آخر (عندما لا تتلقى الخبرة أو الغنيمة عند قتلها)."
    L["OPTIONS_THREAT_COLOR_TANK_ONYOU_SOLID_DESC"] = "الوحدة تهاجمك ولديك اهتمامًا ثابتًا."
    L["OPTIONS_THREAT_COLOR_TANK_NOTINCOMBAT_DESC"] = "الوحدة ليست في المعركة."
    L["OPTIONS_GENERALSETTINGS_HEALTHBAR_TEXTURE"] = "قوام شريط الصحة"
    L["OPTIONS_RANGECHECK_NOTMYTARGET"] = "الوحدات التي ليست هدفك"
    L["OPTIONS_THREAT_COLOR_TANK_NOAGGRO_DESC"] = "الوحدة ليس لديها اهتمام بك."
    L["OPTIONS_THREAT_COLOR_TANK_ANCHOR_TITLE"] = "اللون عند اللعب كدبّاس"
    L["OPTIONS_THREAT_COLOR_OVERRIDE_ANCHOR_TITLE"] = "تجاوز الألوان الافتراضية"
    L["OPTIONS_THREAT_COLOR_DPS_NOTANK_DESC"] = "الوحدة لا تهاجمك أو الدبابة وعلى الأرجح تهاجم آخر من المعالجين أو الناشرين في مجموعتك."
    L["OPTIONS_TABNAME_MODDING"] = "تعديل"
    L["OPTIONS_THREAT_COLOR_DPS_NOAGGRO_DESC"] = "الوحدة لا تهاجمك."
    L["OPTIONS_CLICK_SPACE_WIDTH"] = "عرض مساحة النقر التي تقبل الفأرة لتحديد الهدف"
    L["OPTIONS_THREAT_COLOR_DPS_ANCHOR_TITLE"] = "اللون عند اللعب كدبّاس أو معالج"
    L["OPTIONS_THREAT_AGGROSTATE_ONYOU_SOLID"] = "اهتمام فيك"
    L["OPTIONS_THREAT_AGGROSTATE_ONYOU_LOWAGGRO_DESC"] = "الوحدة تهاجمك ولكن الآخرين على وشك سحب الاهتمام."
    L["OPTIONS_THREAT_AGGROSTATE_ONYOU_LOWAGGRO"] = "اهتمام فيك لكن ضعيف"
    L["OPTIONS_CVAR_NAMEPLATES_ALWAYSSHOW"] = "عرض الأسماء دائمًا|cFFFF7700*|r"

    L["OPTIONS_NAMEPLATE_SHOW_FRIENDLY_DESC"] = [[إظهار لوحة الاسم للاعبين الودودين.

    |cFFFF7700[*]|r |cFFa0a0a0متغير CVar، يتم حفظه داخل ملف تعريف Plater ويتم استعادته عند تحميل الملف الشخصي.|r]]

    L["OPTIONS_ANCHOR_TARGET_SIDE"] = "الجانب الذي يتصاعد فيه هذا العنصر إلى لوحة الاسم."
    L["OPTIONS_RANGECHECK_NOTMYTARGETOUTOFRANGE"] = "خارج المدى + ليس هدفك"
    L["OPTIONS_GENERALSETTINGS_TRANSPARENCY_ANCHOR_TITLE"] = "يتم استخدام الشفافية لـ"
    L["OPTIONS_PROFILE_ERROR_PROFILENAME"] = "اسم الملف غير صالح"
    L["OPTIONS_ALPHABYFRAME_TARGET_INRANGE"] = "شفافية الهدف / في المدى"
    L["OPTIONS_THREAT_AGGROSTATE_TAPPED"] = "تم لمس الوحدة"
    L["OPTIONS_BACKGROUND_ALWAYSSHOW"] = "إظهار الخلفية دائمًا"
    L["OPTIONS_ERROR_EXPORTSTRINGERROR"] = "فشل في التصدير"
    L["OPTIONS_CVAR_ENABLE_PERSONAL_BAR"] = "شريط الصحة الخاص والشريط الخاص للطاقة|cFFFF7700*|r"
    L["OPTIONS_RANGECHECK_NOTMYTARGET_DESC"] = "عندما لا تكون لوحة الاسم هدفك الحالي ، يتم تخفيض الشفافية."
    L["OPTIONS_NOCOMBATALPHA_ENABLED"] = "استخدام شفافية عدم القتال"
    L["OPTIONS_TABNAME_SCRIPTING"] = "البرمجة"
    L["OPTIONS_AURA_DEBUFF_HEIGHT"] = "ارتفاع رمز الإضرار السلبي."
    L["OPTIONS_POWERBAR"] = "شريط الطاقة"
    L["OPTIONS_SIZE"] = "الحجم"
    L["OPTIONS_THREAT_COLOR_TANK_ANOTHERTANK_DESC"] = "الوحدة تُعتبر مستهدفة من قبل مدافع آخر في مجموعتك."
    L["OPTIONS_THREAT_MODIFIERS_HEALTHBARCOLOR"] = "لون شريط الصحة"
    L["OPTIONS_NEUTRAL"] = "محايد"
    L["OPTIONS_THREAT_MODIFIERS_BORDERCOLOR"] = "لون الحدود"
    L["OPTIONS_THREAT_MODIFIERS_ANCHOR_TITLE"] = "يعدل التهديد"
    L["OPTIONS_THREAT_DPS_CANCHECKNOTANK_DESC"] = "عندما لا يكون لديك الهيمنة كمعالج أو قوس ، تحقق مما إذا كان العدو يهاجم وحدة أخرى ليست دبابة."


    L["OPTIONS_RESOURCES_TARGET_DESC"] = [[تظهر مواردك مثل نقاط الاتحاد فوق الهدف الحالي.
    يستخدم الموارد الافتراضية من Blizzard ويعطل الموارد الخاصة بـ Plater.

    إعدادات الشخصية!]]
    L["OPTIONS_TABNAME_BUFF_SETTINGS"] = " إعدادات التعزيزات"
    L["OPTIONS_ERROR_CVARMODIFY"] = " لا يمكن تغيير cvars أثناء القتال."
    L["OPTIONS_PROFILE_CONFIG_PROFILENAME"] = " اسم الملف الشخصي الجديد"
    L["OPTIONS_BUFFFRAMES"] = " إطارات التعزيزات"
    L["OPTIONS_NAMEPLATES_STACKING"] = " رصد الأسماء المتراكمة|cFFFF7700*|r"
    L["OPTIONS_STACK_AURATIME"] = " إظهار أقصر وقت للأصول المتكدسة"
    L["OPTIONS_WIDTH"] = " العرض"
    L["OPTIONS_THREAT_AGGROSTATE_NOAGGRO"] = " لا يوجد تهديد"
    L["OPTIONS_THREAT_COLOR_DPS_ONYOU_SOLID_DESC"] = " الوحدة تهاجمك."
    L["OPTIONS_ALPHABYFRAME_TITLE_FRIENDLY"] = " كمية الشفافية لكل إطار (للوحدات الصديقة)"
    L["OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK_SPEC_DESC"] = " تدقيق المدى لهذه التخصص."
    L["OPTIONS_SCALE"] = " الحجم"
    L["OPTIONS_RANGECHECK_NONE_DESC"] = " لا يتم تطبيق أي تعديلات للشفافية."
    L["OPTIONS_NAMEPLATE_SHOW_ENEMY"] = " إظهار أسماء الأعداء|cFFFF7700*|r"
    L["OPTIONS_PROFILE_ERROR_STRINGINVALID"] = " ملف الملف الشخصي غير صالح."
    L["OPTIONS_ALPHABYFRAME_TITLE_ENEMIES"] = " كمية الشفافية لكل إطار (للأعداء)"
    L["OPTIONS_HEALTHBAR"] = " شريط الصحة"

    L["OPTIONS_PET_SCALE_HEIGHT"] = "مقياس ارتفاع الحيوان الأليف"
    L["OPTIONS_TABNAME_NPCFRIENDLY"] = "الأعداء غير اللاعبين الودية"
    L["OPTIONS_THREAT_COLOR_DPS_HIGHTHREAT_DESC"] = "الوحدة تقوم بالهجوم عليك."
    L["OPTIONS_MINOR_SCALE_HEIGHT"] = "مقياس ارتفاع الوحدة الصغيرة"
    L["OPTIONS_SETTINGS_COPIED"] = "تم نسخ الإعدادات."
    L["OPTIONS_TABNAME_BUFF_SPECIAL"] = "تأثيرات الإيجابية الخاصة"

    L["OPTIONS_AURA_DEBUFF_WITH"] = "عرض أيقونة الضرر."
    L["OPTIONS_PET_SCALE_WIDTH"] = "مقياس عرض الحيوان الأليف."
    L["OPTIONS_HEALTHBAR_HEIGHT"] = "ارتفاع شريط الصحة."
    L["OPTIONS_THREAT_MODIFIERS_NAMECOLOR"] = "لون الاسم."
    L["OPTIONS_ALPHABYFRAME_ENABLE_FRIENDLY_DESC"] = "تطبيق إعدادات الشفافية على الوحدات الودية."
    L["OPTIONS_ALPHABYFRAME_ENABLE_FRIENDLY"] = "تمكين للوحدات الودية"
    L["OPTIONS_TABNAME_COMBOPOINTS"] = "نقاط القوة المتراكمة"
    L["OPTIONS_NAMEPLATE_SHOW_ENEMY_DESC"] = "عرض لوحة الاسم للوحدات العدوية والمحايدة."
    L["OPTIONS_NAMEPLATES_STACKING_DESC"] = [[إذا تم تمكين هذا الخيار ، فلن تتداخل لوحات الأسماء مع بعضها البعض.

|cFFFF7700[*]|r |cFFa0a0a0 متغير مُحفوظ داخل ملف تعريف Plater ويتم استعادته عند تحميل الملف التعريفي.|r

|cFFFFFF00مهم:|r لتحديد كمية المساحة بين كل لوحة اسم ، يرجى الرجوع إلى الخيار '|cFFFFFFFF البعد الرأسي للوحة الاسم|r' أدناه.
يرجى التحقق من إعدادات علامة التبويب التلقائية لإعداد التبديل التلقائي لهذا الخيار.]]


    L["OPTIONS_TABNAME_CASTBAR"] = " شريط البث"
    L["OPTIONS_TABNAME_SEARCH"] = " البحث"
    L["OPTIONS_NAMEPLATE_OFFSET"] = " تعديل بسيط للوحة الاسم بأكملها."
    L["OPTIONS_STACK_AURATIME_DESC"] = " عرض أقصر وقت للتأثيرات المكدسة أو الأطول ، عند تعطيله."
    L["OPTIONS_ALPHABYFRAME_DEFAULT_DESC"] = " كمية الشفافية المطبقة على جميع مكونات لوحة الاسم الواحدة."
    L["OPTIONS_HEALTHBAR_WIDTH"] = " عرض شريط الصحة"
    L["OPTIONS_SCRIPTING_REAPPLY"] = " إعادة تطبيق القيم الافتراضية"
    L["OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK_ALPHA"] = " ألفا"

    L["OPTIONS_ALPHA"] = "الألفا"
    L["OPTIONS_ANCHOR"] = "نقطة الإرساء"
    L["OPTIONS_ANCHOR_BOTTOM"] = "أسفل"
    L["OPTIONS_ANCHOR_BOTTOMLEFT"] = "أسفل اليسار"
    L["OPTIONS_ANCHOR_BOTTOMRIGHT"] = "أسفل اليمين"
    L["OPTIONS_ANCHOR_CENTER"] = "وسط"
    L["OPTIONS_ANCHOR_INNERBOTTOM"] = "أسفل الداخلي"
    L["OPTIONS_ANCHOR_INNERLEFT"] = "اليسار الداخلي"
    L["OPTIONS_ANCHOR_INNERRIGHT"] = "اليمين الداخلي"
    L["OPTIONS_ANCHOR_INNERTOP"] = "أعلى الداخلي"
    L["OPTIONS_ANCHOR_LEFT"] = "اليسار"
    L["OPTIONS_ANCHOR_RIGHT"] = "اليمين"
    L["OPTIONS_ANCHOR_TOP"] = "أعلى"
    L["OPTIONS_ANCHOR_TOPLEFT"] = "أعلى اليسار"
    L["OPTIONS_ANCHOR_TOPRIGHT"] = "أعلى اليمين"
    L["OPTIONS_CANCEL"] = "إلغاء"
    L["OPTIONS_CLOSE"] = "إغلاق"
    L["OPTIONS_COLOR"] = "اللون"
    L["OPTIONS_ENABLED"] = "مفعل"
    L["OPTIONS_FONT"] = "الخط"
    L["OPTIONS_FONTFACE"] = "نوع الخط"
    L["OPTIONS_FONTSIZE"] = "حجم الخط"
    L["OPTIONS_FONTSTYLE"] = "نمط الخط"
    L["OPTIONS_FONTSTYLE_DESC"] = "تغيير نمط الخط."
    L["OPTIONS_LOCK"] = "قفل"
    L["OPTIONS_LOCK_DESC"] = "قفل الإطار."
    L["OPTIONS_OKAY"] = "موافق"
    L["OPTIONS_OPEN"] = "فتح"
    L["OPTIONS_OUTLINE"] = "خط خارجي"
    L["OPTIONS_OUTLINE_DESC"] = "تغيير نمط الخط."
    L["OPTIONS_PLEASEWAIT"] = "يرجى الانتظار"
    L["OPTIONS_RESET"] = "إعادة تعيين"
    L["OPTIONS_RESET_DESC"] = "إعادة تعيين الإطار إلى الإعدادات الافتراضية."
    L["OPTIONS_SHADOWCOLOR"] = "لون الظل"
    L["OPTIONS_SHADOWCOLOR_DESC"] = "تغيير لون الظل."
    L["OPTIONS_STATUSBAR_ANCHOR_TITLE"] = "شريط الحالة"
    L["OPTIONS_STATUSBARCOLOR"] = "لون شريط الحالة"
    L["OPTIONS_STATUSBARCOLOR_DESC"] = "تغيير لون شريط الحالة."
    L["OPTIONS_STATUSBARTEXTURE"] = "نوع شريط الحالة"
    L["OPTIONS_STATUSBARTEXTURE_DESC"] = "تغيير نوع شريط الحالة."
    L["OPTIONS_STRETCH"] = "تمديد"
    L["OPTIONS_STRETCH_DESC"] = "تمديد الإطار ليغطي الشاشة."
    L["OPTIONS_TEXTURE"] = "النوع"
    L["OPTIONS_THICKOUTLINE"] = "خط خارجي سميك"
    L["OPTIONS_THICKOUTLINE_DESC"] = "تغيير نمط الخط."
    L["OPTIONS_TICKCOLOR"] = "لون الشريط"
    L["OPTIONS_TICKCOLOR_DESC"] = "تغيير لون الشريط."
    L["OPTIONS_TICKSIZE"] = "حجم الشريط"
    L["OPTIONS_TICKSIZE_DESC"] = "تغيير حجم الشريط."
    L["OPTIONS_TICKTEXTURE"] = "نوع الشريط"
    L["OPTIONS_TICKTEXTURE_DESC"] = "تغيير نوع الشريط."
    L["OPTIONS_TRANSPARENCY"] = "الشفافية"
    L["OPTIONS_TRANSPARENCY_DESC"] = "تغيير شفافية الإطار."
    L["OPTIONS_XOFFSET"] = "الإزاحة الأفقية"
    L["OPTIONS_YOFFSET"] = "الإزاحة العمودية"
    L["OPTIONS_INDICATORS"] = "المؤشرات"
    L["OPTIONS_ICON_PET"] = "أيقونة الحيوان الأليف"
    L["OPTIONS_ICON_WORLDBOSS"] = "أيقونة زعيم العالم"
    L["OPTIONS_ICON_ELITE"] = "أيقونة النخبة"
    L["OPTIONS_ICON_RARE"] = "أيقونة نادرة"
    L["OPTIONS_ICON_QUEST"] = "أيقونة المهمة"
    L["OPTIONS_ICON_ENEMYFACTION"] = "أيقونة فئة العدو"
    L["OPTIONS_ICON_ENEMYCLASS"] = "أيقونة فئة العدو"
    L["OPTIONS_ICON_ENEMYSPEC"] = "أيقونة تخصص العدو"
    L["OPTIONS_ICON_FRIENDLYFACTION"] = "أيقونة فئة الصديق"
    L["OPTIONS_ICON_FRIENDLYCLASS"] = "أيقونة فئة الصديق"
    L["OPTIONS_ICON_FRIENDLY_SPEC"] = "أيقونة تخصص الصديق"
    L["OPTIONS_SHIELD_BAR"] = "شريط الدرع"
    L["OPTIONS_EXECUTERANGE"] = "مدى التنفيذ"
    L["OPTIONS_EXECUTERANGE_DESC"] = "عرض مؤشر عندما يكون وحدة الهدف في مدى 'التنفيذ'.\n\nإذا لم يعمل الكشف بعد التحديث ، فاتصل بنا عبر الديسكورد."
    L["OPTIONS_EXECUTERANGE_HIGH_HEALTH"] = "مدى التنفيذ (الصحة العالية)"
    L["OPTIONS_EXECUTERANGE_HIGH_HEALTH_DESC"] = "عرض مؤشر التنفيذ للجزء العالي من الصحة.\n\nإذا لم يعمل الكشف بعد التحديث ، فاتصل بنا عبر الديسكور."

    L["TARGET_OVERLAY_TEXTURE"] = "نسيج التراكيب المستهدفة"
    L["TARGET_OVERLAY_TEXTURE_DESC"] = "يتم استخدامها فوق شريط الصحة عندما يكون الهدف الحالي."
    L["TARGET_OVERLAY_ALPHA"] = "شفافية التراكيب المستهدفة"
    L["TARGET_HIGHLIGHT"] = "تمييز الهدف"
    L["TARGET_HIGHLIGHT_DESC"] = "تأثير التمييز على لوحة الاسم للهدف الحالي."
    L["TARGET_HIGHLIGHT_TEXTURE"] = "نسيج تمييز الهدف"
    L["TARGET_HIGHLIGHT_ALPHA"] = "شفافية تمييز الهدف"
    L["TARGET_HIGHLIGHT_SIZE"] = "حجم تمييز الهدف"
    L["TARGET_HIGHLIGHT_COLOR"] = "لون تمييز الهدف"
    L["HIGHLIGHT_HOVEROVER"] = "تمييز التحويم"
    L["HIGHLIGHT_HOVEROVER_DESC"] = "تأثير التمييز عندما يكون المؤشر فوق لوحة الاسم."
    L["HIGHLIGHT_HOVEROVER_ALPHA"] = "شفافية تمييز التحويم"
    L["TARGET_CVAR_ALWAYSONSCREEN"] = "الهدف دائمًا على الشاشة |cFFFF7700*|r"
    L["TARGET_CVAR_ALWAYSONSCREEN_DESC"] = "عند التمكين، يتم عرض لوحة الاسم الخاصة بالهدف الخاص بك دائمًا حتى عندما لا يكون العدو في الشاشة.\n\n|cFFFF7700[]|r |cFFa0a0a0CVar، محفوظة داخل ملف تعريف Plater ومستعادة عند تحميل الملف التعريف.|r"
    L["TARGET_CVAR_LOCKTOSCREEN"] = "تأمين على الشاشة (الجانب العلوي) |cFFFF7700|r"
    L["TARGET_CVAR_LOCKTOSCREEN_DESC"] = "الحد الأدنى للمساحة بين لوحة الاسم والجزء العلوي من الشاشة. زد هذه القيمة إذا كانت بعض أجزاء لوحة الاسم تظهر خارج الشاشة.\n\n|cFFFFFFFFالإعداد الافتراضي: 0.065|r\n\n|cFFFFFF00 مهم |r: إذا واجهتك مشكلة، يمكنك تعيين القيم يدويا باستخدام هذه الأوامر:\n/run SetCVar ('nameplateOtherTopInset', '0.065')\n/run SetCVar ('nameplateLargeTopInset', '0.065')\n\n|cFFFFFF00 مهم |r: إعداد القيمة على 0 يعطل هذه الميزة.\n\n|cFFFF7700[*]|r |cFFa0a0a0الإعدادات المحفوظة في ملف التكوين (CVar) يتم استعادتها عند تحميل ملف التكوين الخاص بـPlater.|r"
end