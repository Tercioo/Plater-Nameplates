do
    local addonId = ...
    local languageTable = DetailsFramework.Language.RegisterLanguage(addonId, "deDE")
    local L = languageTable

------------------------------------------------------------
L["A /reload may be required to take effect."] = "Möglicherweise ist ein /reload erforderlich, damit die Änderungen wirksam werden."
L["CVar, saved within Plater profile and restored when loading the profile."] = "CVar, wird im Plater-Profil gespeichert und beim Laden des Profils wiederhergestellt."
L["EXPORT"] = "Exportieren"
L["EXPORT_CAST_COLORS"] = "Farben teilen"
L["EXPORT_CAST_SOUNDS"] = "Sounds teilen"
L["HIGHLIGHT_HOVEROVER"] = "Hover-Hervorhebung"
L["HIGHLIGHT_HOVEROVER_ALPHA"] = "Hover-Hervorhebung-Alpha"
L["HIGHLIGHT_HOVEROVER_DESC"] = "Hervorhebungseffekt, wenn die Maus über dem Namensschild bewegt wird."
L["Hold Shift to change the sound of all casts with the audio %s to %s"] = "Halte Umschalt gedrückt, um den Sound aller Zauber mit dem Audio %s zu %s zu ändern"
L["IMPORT"] = "Importieren"
L["IMPORT_CAST_COLORS"] = "Farben importieren"
L["IMPORT_CAST_SOUNDS"] = "Sounds importieren"
L["OPTIONS_ALPHA"] = "Alpha"
L["OPTIONS_ALPHABYFRAME_ALPHAMULTIPLIER"] = "Transparenz-Multiplikator."
L["OPTIONS_ALPHABYFRAME_DEFAULT"] = "Standard-Transparenz"
L["OPTIONS_ALPHABYFRAME_DEFAULT_DESC"] = "Höhe der Transparenz, die auf alle Komponenten eines einzelnen Namensschilds angewendet wird."
L["OPTIONS_ALPHABYFRAME_ENABLE_ENEMIES"] = "Aktivieren für Feinde"
L["OPTIONS_ALPHABYFRAME_ENABLE_ENEMIES_DESC"] = "Transparenz-Einstellungen auf gegnerische Einheiten anwenden."
L["OPTIONS_ALPHABYFRAME_ENABLE_FRIENDLY"] = "Für freundliche Ziele Aktivieren"
L["OPTIONS_ALPHABYFRAME_ENABLE_FRIENDLY_DESC"] = "Transparenzeinstellungen auf befreundete Einheiten anwenden."
L["OPTIONS_ALPHABYFRAME_TARGET_INRANGE"] = "Ziel-Alpha/Reichweite"
L["OPTIONS_ALPHABYFRAME_TARGET_INRANGE_DESC"] = "Transparenz für Ziele oder Einheiten in Reichweite."
L["OPTIONS_ALPHABYFRAME_TITLE_ENEMIES"] = "Transparenzbetrag pro Frame (Feinde)"
L["OPTIONS_ALPHABYFRAME_TITLE_FRIENDLY"] = "Transparenzbetrag pro Frame (freundlich)"
L["OPTIONS_AMOUNT"] = "Menge"
L["OPTIONS_ANCHOR"] = "Ankerpunkt"
L["OPTIONS_ANCHOR_BOTTOM"] = "Unten"
L["OPTIONS_ANCHOR_BOTTOMLEFT"] = "Unten links"
L["OPTIONS_ANCHOR_BOTTOMRIGHT"] = "Unten rechts"
L["OPTIONS_ANCHOR_CENTER"] = "Mitte"
L["OPTIONS_ANCHOR_INNERBOTTOM"] = "Innen unten"
L["OPTIONS_ANCHOR_INNERLEFT"] = "Innen links"
L["OPTIONS_ANCHOR_INNERRIGHT"] = "Rechts innen"
L["OPTIONS_ANCHOR_INNERTOP"] = "Innen oben"
L["OPTIONS_ANCHOR_LEFT"] = "Links"
L["OPTIONS_ANCHOR_RIGHT"] = "Rechts"
L["OPTIONS_ANCHOR_TARGET_SIDE"] = "An welche Seite dieses Widget angehängt wird."
L["OPTIONS_ANCHOR_TOP"] = "Oben"
L["OPTIONS_ANCHOR_TOPLEFT"] = "Oben links"
L["OPTIONS_ANCHOR_TOPRIGHT"] = "Oben rechts"
L["OPTIONS_AUDIOCUE_COOLDOWN"] = "Audio-Cooldown"
L["OPTIONS_AUDIOCUE_COOLDOWN_DESC"] = [=[Wartezeit in Millisekunden, bevor derselbe Audio-Sound erneut abgespielt wird.

Verhindert laute Sounds, wenn zwei oder mehr Zauber gleichzeitig gewirkt werden.

Auf 0 setzen, um diese Funktion zu deaktivieren.]=]
L["OPTIONS_AURA_DEBUFF_HEIGHT"] = "Höhe des Debuff-Symbols."
L["OPTIONS_AURA_DEBUFF_WITH"] = "Breite des Debuff-Symbols."
L["OPTIONS_AURA_HEIGHT"] = "Höhe des Debuff-Symbols."
L["OPTIONS_AURA_SHOW_BUFFS"] = "Buffs anzeigen"
L["OPTIONS_AURA_SHOW_BUFFS_DESC"] = "Buffs auf dir in der Persönlichen Leiste anzeigen."
L["OPTIONS_AURA_SHOW_DEBUFFS"] = "Debuffs anzeigen"
L["OPTIONS_AURA_SHOW_DEBUFFS_DESC"] = "Debuffs auf dir in der Persönlichen Leiste anzeigen."
L["OPTIONS_AURA_WIDTH"] = "Breite des Debuff-Symbols."
L["OPTIONS_AURAS_ENABLETEST"] = "Aktiviere dies, um Test-Auren zu verstecken, die bei der Konfiguration angezeigt werden."
L["OPTIONS_AURAS_SORT"] = "Auren sortieren"
L["OPTIONS_AURAS_SORT_DESC"] = "Auren werden nach verbleibender Zeit sortiert (Standard)."
L["OPTIONS_BACKGROUND_ALWAYSSHOW"] = "Hintergrund immer anzeigen"
L["OPTIONS_BACKGROUND_ALWAYSSHOW_DESC"] = "Einen Hintergrund anzeigen, der den Bereich der klickbaren Fläche zeigt."
L["OPTIONS_BORDER_COLOR"] = "Rahmenfarbe"
L["OPTIONS_BORDER_THICKNESS"] = "Rahmendicke"
L["OPTIONS_BUFFFRAMES"] = "Buff-Frames"
L["OPTIONS_CANCEL"] = "Abbrechen"
L["OPTIONS_CAST_COLOR_CHANNELING"] = "Kanalisierte"
L["OPTIONS_CAST_COLOR_INTERRUPTED"] = "Unterbrochen"
L["OPTIONS_CAST_COLOR_REGULAR"] = "Normal"
L["OPTIONS_CAST_COLOR_SUCCESS"] = "Erfolgreich"
L["OPTIONS_CAST_COLOR_UNINTERRUPTIBLE"] = "Nicht unterbrechbar"
L["OPTIONS_CAST_SHOW_TARGETNAME"] = "Zielname anzeigen"
L["OPTIONS_CAST_SHOW_TARGETNAME_DESC"] = "Zeigt an, wer das Ziel des aktuellen Zaubers ist (wenn das Ziel existiert)"
L["OPTIONS_CAST_SHOW_TARGETNAME_TANK"] = "[Tank] Deinen Namen nicht anzeigen"
L["OPTIONS_CAST_SHOW_TARGETNAME_TANK_DESC"] = "Wenn du ein Tank bist, zeige den Zielnamen nicht an, wenn der Zauber auf dich gewirkt wird."
L["OPTIONS_CASTBAR_APPEARANCE"] = "Zauberleisten-Aussehen"
L["OPTIONS_CASTBAR_BLIZZCASTBAR"] = "Blizzard-Zauberleiste"
L["OPTIONS_CASTBAR_COLORS"] = "Zauberleisten-Farben"
L["OPTIONS_CASTBAR_FADE_ANIM_ENABLED"] = "Fade-Animationen aktivieren"
L["OPTIONS_CASTBAR_FADE_ANIM_ENABLED_DESC"] = "Fade-Animationen beim Start und Stopp des Zaubers aktivieren."
L["OPTIONS_CASTBAR_FADE_ANIM_TIME_END"] = "Beim Stopp"
L["OPTIONS_CASTBAR_FADE_ANIM_TIME_END_DESC"] = "Wenn ein Zauber endet, ist dies die Zeit, die die Zauberleiste braucht, um von 100% Transparenz bis gar nicht mehr sichtbar zu gehen."
L["OPTIONS_CASTBAR_FADE_ANIM_TIME_START"] = "Beim Start"
L["OPTIONS_CASTBAR_FADE_ANIM_TIME_START_DESC"] = "Wenn ein Zauber startet, ist dies die Zeit, die die Zauberleiste braucht, um von null Transparenz bis voll deckend zu gehen."
L["OPTIONS_CASTBAR_HEIGHT"] = "Höhe der Zauberleiste."
L["OPTIONS_CASTBAR_HIDE_ENEMY"] = "Feindliche Zauberleiste verstecken"
L["OPTIONS_CASTBAR_HIDE_FRIENDLY"] = "Freundliche Zauberleiste verstecken"
L["OPTIONS_CASTBAR_HIDEBLIZZARD"] = "Blizzard-Spieler-Zauberleiste verstecken"
L["OPTIONS_CASTBAR_ICON_CUSTOM_ENABLE"] = "Symbol-Anpassung aktivieren"
L["OPTIONS_CASTBAR_ICON_CUSTOM_ENABLE_DESC"] = "Wenn diese Option deaktiviert ist, wird Plater das Zaubersymbol nicht ändern und lässt es für Skripte tun."
L["OPTIONS_CASTBAR_NO_SPELLNAME_LIMIT"] = "Keine Zaubernamen-Längenbegrenzung"
L["OPTIONS_CASTBAR_NO_SPELLNAME_LIMIT_DESC"] = "Der Zaubernamentext wird nicht abgeschnitten, um innerhalb der Zauberleistenbreite zu passen."
L["OPTIONS_CASTBAR_QUICKHIDE"] = "Zauberleiste schnell verstecken"
L["OPTIONS_CASTBAR_QUICKHIDE_DESC"] = "Nach Abschluss des Zaubers wird die Zauberleiste sofort versteckt."
L["OPTIONS_CASTBAR_SPARK_HALF"] = "Halber Funken"
L["OPTIONS_CASTBAR_SPARK_HALF_DESC"] = "Zeigt nur die Hälfte der Funkentextur."
L["OPTIONS_CASTBAR_SPARK_HIDE_INTERRUPT"] = "Funken beim Unterbrechen verstecken"
L["OPTIONS_CASTBAR_SPARK_SETTINGS"] = "Funken-Einstellungen"
L["OPTIONS_CASTBAR_SPELLICON"] = "Zaubersymbol"
L["OPTIONS_CASTBAR_TOGGLE_TEST"] = "Zauberleisten-Test umschalten"
L["OPTIONS_CASTBAR_TOGGLE_TEST_DESC"] = "Zauberleisten-Test starten, erneut drücken zum Stoppen."
L["OPTIONS_CASTBAR_WIDTH"] = "Breite der Zauberleiste."
L["OPTIONS_CASTCOLORS_DISABLE_SOUNDS"] = "Alle Sounds entfernen"
L["OPTIONS_CASTCOLORS_DISABLE_SOUNDS_CONFIRM"] = "Möchtest du wirklich alle konfigurierten Zauber-Sounds entfernen?"
L["OPTIONS_CASTCOLORS_DISABLECOLORS"] = "Alle Farben deaktivieren"
L["OPTIONS_CASTCOLORS_DISABLECOLORS_CONFIRM"] = "Deaktivieren aller Zauberfarben bestätigen?"
L["OPTIONS_CLICK_SPACE_HEIGHT"] = "Die Höhe des Bereichs, der Mausklicks zum Auswählen des Ziels akzeptiert"
L["OPTIONS_CLICK_SPACE_WIDTH"] = "Die Breite des Bereichs, der Mausklicks zum Auswählen des Ziels akzeptiert"
L["OPTIONS_COLOR"] = "Farbe"
L["OPTIONS_COLOR_BACKGROUND"] = "Hintergrundfarbe"
L["OPTIONS_CVAR_ENABLE_PERSONAL_BAR"] = "Persönliche Lebens- und Manaleiste|cFFFF7700*|r"
L["OPTIONS_CVAR_ENABLE_PERSONAL_BAR_DESC"] = [=[Zeigt einen mini Lebens- und Manabalken unter deinem Charakter.

|cFFFF7700[*]|r |cFFa0a0a0CVar, wird im Plater-Profil gespeichert und beim Laden des Profils wiederhergestellt.|r]=]
L["OPTIONS_CVAR_NAMEPLATES_ALWAYSSHOW"] = "Namensschilder immer anzeigen|cFFFF7700*|r"
L["OPTIONS_CVAR_NAMEPLATES_ALWAYSSHOW_DESC"] = [=[Zeigt Namensschilder für alle Einheiten in deiner Nähe. Wenn deaktiviert, werden nur relevante Einheiten im Kampf angezeigt.

|cFFFF7700[*]|r |cFFa0a0a0CVar, wird im Plater-Profil gespeichert und beim Laden des Profils wiederhergestellt.|r]=]
L["OPTIONS_ENABLED"] = "Aktiviert"
L["OPTIONS_ERROR_CVARMODIFY"] = "CVars können im Kampf nicht verändert werden."
L["OPTIONS_ERROR_EXPORTSTRINGERROR"] = "Fehler beim Exportieren"
L["OPTIONS_EXECUTERANGE"] = "Hinrichtungsbereich"
L["OPTIONS_EXECUTERANGE_DESC"] = [=[Zeigt einen Indikator an, wenn die Zieleinheit im 'Hinrichtungs'-Bereich ist.

Wenn die Erkennung nach einem Patch nicht funktioniert, melde es auf Discord.]=]
L["OPTIONS_EXECUTERANGE_HIGH_HEALTH"] = "Hinrichtungsbereich (hohes Leben)"
L["OPTIONS_EXECUTERANGE_HIGH_HEALTH_DESC"] = [=[Zeigt den Hinrichtungsindikator für den hohen Teil der Lebenspunkte.

Wenn die Erkennung nach einem Patch nicht funktioniert, melde es auf Discord.]=]
L["OPTIONS_FONT"] = "Schriftart"
L["OPTIONS_FORMAT_NUMBER"] = "Zahlenformat"
L["OPTIONS_FRIENDLY"] = "Freundlich"
L["OPTIONS_GENERALSETTINGS_HEALTHBAR_ANCHOR_TITLE"] = "Lebensbalken-Aussehen"
L["OPTIONS_GENERALSETTINGS_HEALTHBAR_BGCOLOR"] = "Leistenbalken Hintergrundfarbe und -Alpha"
L["OPTIONS_GENERALSETTINGS_HEALTHBAR_BGTEXTURE"] = "Lebensbalken Hintergrundtextur"
L["OPTIONS_GENERALSETTINGS_HEALTHBAR_TEXTURE"] = "Lebensbalken-Textur"
L["OPTIONS_GENERALSETTINGS_TRANSPARENCY_ANCHOR_TITLE"] = "Transparenz-Einstellungen"
L["OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK"] = "Entfernungsprüfung"
L["OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK_ALPHA"] = "Entfernungs-Transparenz"
L["OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK_SPEC_DESC"] = "Für diese Spezialisierung verwendeter Zauber zur Entfernungsprüfung"
L["OPTIONS_HEALTHBAR"] = "Lebensbalken"
L["OPTIONS_HEALTHBAR_HEIGHT"] = "Lebensbalkenhöhe"
L["OPTIONS_HEALTHBAR_SIZE_GLOBAL_DESC"] = [=[Ändert die Größe von feindlichen und freundlichen Namensschildern für Spieler und NPCs im und außerhalb des Kampfes.

Jede dieser Optionen kann einzeln auf den Tabs Gegnerischer NPC, Gegnerischer Spieler geändert werden.]=]
L["OPTIONS_HEALTHBAR_WIDTH"] = "Leistenbalkenbreite"
L["OPTIONS_HEIGHT"] = "Höhe"
L["OPTIONS_HOSTILE"] = "Feindlich"
L["OPTIONS_ICON_ELITE"] = "Elite-Symbol"
L["OPTIONS_ICON_ENEMYCLASS"] = "Gegnerische-Klassen-Symbol"
L["OPTIONS_ICON_ENEMYFACTION"] = "Gegnerische-Fraktions-Symbol"
L["OPTIONS_ICON_ENEMYSPEC"] = "Gegnerische-Spezialisierungs-Symbol"
L["OPTIONS_ICON_FRIENDLY_SPEC"] = "Freundliche-Spezialisierungs-Symbol"
L["OPTIONS_ICON_FRIENDLYCLASS"] = "Freundliche-Klassen-Symbol"
L["OPTIONS_ICON_FRIENDLYFACTION"] = "Freundliche-Fraktions-Symbol"
L["OPTIONS_ICON_PET"] = "Begleiter-Symbol"
L["OPTIONS_ICON_QUEST"] = "Quest-Symbol"
L["OPTIONS_ICON_RARE"] = "Seltenes-Symbol"
L["OPTIONS_ICON_SHOW"] = "Symbol anzeigen"
L["OPTIONS_ICON_SIDE"] = "Seite anzeigen"
L["OPTIONS_ICON_SIZE"] = "Größe anzeigen"
L["OPTIONS_ICON_WORLDBOSS"] = "Weltboss-Symbol"
L["OPTIONS_ICONROWSPACING"] = "Symbol-Zeilenabstand"
L["OPTIONS_ICONSPACING"] = "Symbolabstand"
L["OPTIONS_INDICATORS"] = "Indikatoren"
L["OPTIONS_INTERACT_OBJECT_NAME_COLOR"] = "Objektname-Farbe"
L["OPTIONS_INTERACT_OBJECT_NAME_COLOR_DESC"] = "Namen auf Objekten erhalten diese Farbe."
L["OPTIONS_INTERRUPT_FILLBAR"] = "Zauberleiste beim Unterbrechen füllen"
L["OPTIONS_INTERRUPT_SHOW_ANIM"] = "Unterbrechungs-Animation abspielen"
L["OPTIONS_INTERRUPT_SHOW_AUTHOR"] = "Unterbrechungs-Autor anzeigen"
L["OPTIONS_MINOR_SCALE_DESC"] = "Passt die Größe der Namensschilder leicht an, wenn eine kleinere Einheit angezeigt wird (diese Einheiten haben standardmäßig ein kleineres Namensschild)."
L["OPTIONS_MINOR_SCALE_HEIGHT"] = "Höhen-Skalierung kleiner Einheiten"
L["OPTIONS_MINOR_SCALE_WIDTH"] = "Breiten-Skalierung kleiner Einheiten"
L["OPTIONS_MOVE_HORIZONTAL"] = "Horizontal bewegen."
L["OPTIONS_MOVE_VERTICAL"] = "Vertikal bewegen."
L["OPTIONS_NAMEPLATE_HIDE_FRIENDLY_HEALTH"] = "Blizzard-Lebensbalken verstecken|cFFFF7700*|r"
L["OPTIONS_NAMEPLATE_HIDE_FRIENDLY_HEALTH_DESC"] = [=[Wenn du dich in einem Dungeon oder Schlachtzug befindest und freundliche Namensschilder aktiviert sind, wird nur der Spielername angezeigt.
Wenn ein Plater-Modul deaktiviert ist, wirkt sich dies auch auf diese Namensschilder aus.

|cFFFF7700[*]|r |cFFa0a0a0CVar, wird im Plater-Profil gespeichert und beim Laden des Profils wiederhergestellt.|r

|cFFFF2200[*]|r |cFFa0a0a0Möglicherweise ist ein /reload erforderlich, damit die Änderungen wirksam werden.|r]=]
L["OPTIONS_NAMEPLATE_OFFSET"] = "Das gesamte Namensschild leicht anpassen."
L["OPTIONS_NAMEPLATE_SHOW_ENEMY"] = "Feindliche Namensschilder anzeigen|cFFFF7700*|r"
L["OPTIONS_NAMEPLATE_SHOW_ENEMY_DESC"] = [=[Zeigt Namensschilder für feindliche und neutrale Einheiten.

|cFFFF7700[*]|r |cFFa0a0a0CVar, wird im Plater-Profil gespeichert und beim Laden des Profils wiederhergestellt.|r]=]
L["OPTIONS_NAMEPLATE_SHOW_FRIENDLY"] = "Freundliche Namensschilder anzeigen|cFFFF7700*|r"
L["OPTIONS_NAMEPLATE_SHOW_FRIENDLY_DESC"] = [=[Zeigt Namensschilder für freundliche Spieler.

|cFFFF7700[*]|r |cFFa0a0a0CVar, wird im Plater-Profil gespeichert und beim Laden des Profils wiederhergestellt.|r]=]
L["OPTIONS_NAMEPLATES_OVERLAP"] = "Namensschild-Überlappung (V)|cFFFF7700*|r"
L["OPTIONS_NAMEPLATES_OVERLAP_DESC"] = [=[Der Abstand zwischen jedem Namensschild vertikal, wenn die Stapelung aktiviert ist.

|cFFFFFFFFStandard: 1,10|r

|cFFFF7700[*]|r |cFFa0a0a0CVar, wird im Plater-Profil gespeichert und beim Laden des Profils wiederhergestellt.|r

|cFFFFFF00Wichtig |r: Wenn du Probleme mit dieser Einstellung hast, benutze:
|cFFFFFFFF/run SetCVar ('nameplateOverlapV', '1.6')|r]=]
L["OPTIONS_NAMEPLATES_STACKING"] = "Namensschild-Stapelung|cFFFF7700*|r"
L["OPTIONS_NAMEPLATES_STACKING_DESC"] = [=[Wenn aktiviert, überlappen sich die Namensschilder nicht gegenseitig.

|cFFFF7700[*]|r |cFFa0a0a0CVar, wird im Plater-Profil gespeichert und beim Laden des Profils wiederhergestellt.|r

|cFFFFFF00Wichtig |r: Um den Abstand zwischen jedem Namensschild einzustellen, siehe die Option '|cFFFFFFFFNamensschild vertikaler Abstand|r' unten.
Bitte überprüfe die Auto-Tab-Einstellungen, um das automatische Umschalten dieser Option einzurichten.]=]
L["OPTIONS_NEUTRAL"] = "Neutral"
L["OPTIONS_NOCOMBATALPHA_AMOUNT_DESC"] = "Transparenzmenge für 'Keine-Kampf-Alpha'."
L["OPTIONS_NOCOMBATALPHA_ENABLED"] = "Keine-Kampf-Alpha verwenden"
L["OPTIONS_NOCOMBATALPHA_ENABLED_DESC"] = [=[Ändert das Alpha des Namensschilds, wenn du im Kampf bist und die Einheit nicht.

|cFFFFFF00 Wichtig |r: Wenn die Einheit nicht im Kampf ist, wird das Alpha aus der Entfernungsprüfung überschrieben.]=]
L["OPTIONS_NOESSENTIAL_DESC"] = [=[Bei einem Plater-Update ist es üblich, dass die neue Version auch Skripte aus dem Skripte-Tab aktualisiert.

Dies kann manchmal Änderungen überschreiben, die der Ersteller des Profils vorgenommen hat. Die folgende Option verhindert, dass Plater Skripte ändert, wenn das Addon ein Update erhält.

Hinweis: Bei größeren Patches und Bugfixes kann Plater dennoch Skripte aktualisieren.]=]
L["OPTIONS_NOESSENTIAL_NAME"] = "Nicht wesentliche Skript-Updates während Plater-Versions-Upgrades deaktivieren."
L["OPTIONS_NOESSENTIAL_SKIP_ALERT"] = "Nicht unwichtiger Patch übersprungen:"
L["OPTIONS_NOESSENTIAL_TITLE"] = "Nicht unwesentliche Skript-Patches überspringen"
L["OPTIONS_NOTHING_TO_EXPORT"] = "Es gibt nichts zu exportieren."
L["OPTIONS_OKAY"] = "Okay"
L["OPTIONS_OUTLINE"] = "Umriss"
L["OPTIONS_PERSONAL_HEALTHBAR_HEIGHT"] = "Höhe des Lebensbalkens."
L["OPTIONS_PERSONAL_HEALTHBAR_WIDTH"] = "Breite des Lebensbalkens."
L["OPTIONS_PERSONAL_SHOW_HEALTHBAR"] = "Lebensbalken anzeigen."
L["OPTIONS_PET_SCALE_DESC"] = "Passt die Größe der Namensschilder leicht an, wenn ein Begleiter angezeigt wird"
L["OPTIONS_PET_SCALE_HEIGHT"] = "Begleiter-Höhen-Skalierung"
L["OPTIONS_PET_SCALE_WIDTH"] = "Begleiter-Breiten-Skalierung"
L["OPTIONS_PLEASEWAIT"] = "Dies kann einige Sekunden dauern"
L["OPTIONS_POWERBAR"] = "Kraftleiste"
L["OPTIONS_POWERBAR_HEIGHT"] = "Höhe der Kraftleiste."
L["OPTIONS_POWERBAR_WIDTH"] = "Breite der Kraftleiste."
L["OPTIONS_PROFILE_CONFIG_EXPORTINGTASK"] = "Plater exportiert das aktuelle Profil"
L["OPTIONS_PROFILE_CONFIG_EXPORTPROFILE"] = "Profil exportieren"
L["OPTIONS_PROFILE_CONFIG_IMPORTPROFILE"] = "Profil importieren"
L["OPTIONS_PROFILE_CONFIG_MOREPROFILES"] = "Finde weitere Profile auf wago.io"
L["OPTIONS_PROFILE_CONFIG_OPENSETTINGS"] = "Profileinstellungen öffnen"
L["OPTIONS_PROFILE_CONFIG_PROFILENAME"] = "Name des neuen Profils"
L["OPTIONS_PROFILE_CONFIG_PROFILENAME_DESC"] = [=[Mit diesem Import-String wird ein neues Profil erstellt.

Die Angabe des Namens eines existierenden Profils wird dazu führen, dass das existierende Profil überschrieben wird.]=]
L["OPTIONS_PROFILE_ERROR_PROFILENAME"] = "Ungültiger Profilname"
L["OPTIONS_PROFILE_ERROR_STRINGINVALID"] = "Ungültige Profildatei."
L["OPTIONS_PROFILE_ERROR_WRONGTAB"] = "Ungültige Profildatei. Importiere Skripte oder Mods im Skript oder Mods-Tab."
L["OPTIONS_PROFILE_IMPORT_OVERWRITE"] = "Das Profil '%s' existiert bereits. Soll es überschrieben werden?"
L["OPTIONS_RANGECHECK_NONE"] = "Nichts"
L["OPTIONS_RANGECHECK_NONE_DESC"] = "Keine Alpha-Modifikationen werden angewendet."
L["OPTIONS_RANGECHECK_NOTMYTARGET"] = "Einheiten, die nicht dein Ziel sind"
L["OPTIONS_RANGECHECK_NOTMYTARGET_DESC"] = "Wenn ein Namensschild nicht dein aktuelles Ziel ist, wird das Alpha reduziert."
L["OPTIONS_RANGECHECK_NOTMYTARGETOUTOFRANGE"] = "Außer Reichweite + Nicht dein Ziel"
L["OPTIONS_RANGECHECK_NOTMYTARGETOUTOFRANGE_DESC"] = [=[Reduziert das Alpha von Einheiten, die nicht dein Ziel sind.
Reduziert noch mehr, wenn die Einheit außer Reichweite ist.]=]
L["OPTIONS_RANGECHECK_OUTOFRANGE"] = "Einheiten außerhalb deiner Reichweite"
L["OPTIONS_RANGECHECK_OUTOFRANGE_DESC"] = "Wenn ein Namensschild außer Reichweite ist, wird das Alpha reduziert."
L["OPTIONS_RESOURCES_TARGET"] = "Ressourcen auf Ziel anzeigen"
L["OPTIONS_RESOURCES_TARGET_DESC"] = [=[Zeigt deine Ressourcen wie Combopunkte über deinem aktuellen Ziel.
Verwendet die Standard-Ressourcen von Blizzard und deaktiviert Platers eigene Ressourcen.

Charakterspezifische Einstellung!]=]
L["OPTIONS_SCALE"] = "Skalierung"
L["OPTIONS_SCRIPTING_ADDOPTION"] = "Wähle, welche Option hinzugefügt werden soll"
L["OPTIONS_SCRIPTING_REAPPLY"] = "Standardwerte erneut anwenden"
L["OPTIONS_SETTINGS_COPIED"] = "Einstellungen kopiert."
L["OPTIONS_SETTINGS_FAIL_COPIED"] = "Fehler beim Kopieren der Einstellungen für den aktuell ausgewählten Reiter."
L["OPTIONS_SHADOWCOLOR"] = "Schatten-Farbe"
L["OPTIONS_SHIELD_BAR"] = "Schildleiste"
L["OPTIONS_SHOW_CASTBAR"] = "Zauberleiste anzeigen"
L["OPTIONS_SHOW_POWERBAR"] = "Kraftleiste anzeigen"
L["OPTIONS_SHOWOPTIONS"] = "Optionen anzeigen"
L["OPTIONS_SHOWSCRIPTS"] = "Skripte anzeigen"
L["OPTIONS_SHOWTOOLTIP"] = "Tooltip anzeigen"
L["OPTIONS_SHOWTOOLTIP_DESC"] = "Tooltip anzeigen, wenn der Mauszeiger über dem Aurensymbol bewegt wird."
L["OPTIONS_SIZE"] = "Größe"
L["OPTIONS_STACK_AURATIME"] = "Kürzeste Zeit gestapelter Auren anzeigen"
L["OPTIONS_STACK_AURATIME_DESC"] = "Zeigt die kürzeste Zeit gestapelter Auren oder, wenn deaktiviert, die längste Zeit."
L["OPTIONS_STACK_SIMILAR_AURAS"] = "Ähnliche Auren stapeln"
L["OPTIONS_STACK_SIMILAR_AURAS_DESC"] = "Auren mit demselben Namen (z.B. Hexenmeister-Unstabiliges Elend-Debuff) werden zusammen gestapelt."
L["OPTIONS_STATUSBAR_TEXT"] = "Profile, Mods, Skripte, Animationen und Farbtabellen können jetzt von |cFFFFAA00http://wago.io|r importiert werden."
L["OPTIONS_TABNAME_ADVANCED"] = "Erweitert"
L["OPTIONS_TABNAME_ANIMATIONS"] = "Zauberfeedback"
L["OPTIONS_TABNAME_AUTO"] = "Automatisierung"
L["OPTIONS_TABNAME_BUFF_LIST"] = "Zauberliste"
L["OPTIONS_TABNAME_BUFF_SETTINGS"] = "Buff-Einstellungen"
L["OPTIONS_TABNAME_BUFF_SPECIAL"] = "Spezielle Buffs"
L["OPTIONS_TABNAME_BUFF_TRACKING"] = "Buff-Verfolgung"
L["OPTIONS_TABNAME_CASTBAR"] = "Zauberleiste"
L["OPTIONS_TABNAME_CASTCOLORS"] = "Zauberfarben und Namen"
L["OPTIONS_TABNAME_COMBOPOINTS"] = "Combo-Punkte"
L["OPTIONS_TABNAME_GENERALSETTINGS"] = "Allg. Einstellungen"
L["OPTIONS_TABNAME_MODDING"] = "Modding"
L["OPTIONS_TABNAME_NPC_COLORNAME"] = "NPC-Farben und Namen"
L["OPTIONS_TABNAME_NPCENEMY"] = "Feindliche NPCs"
L["OPTIONS_TABNAME_NPCFRIENDLY"] = "Freundliche NPCs"
L["OPTIONS_TABNAME_PERSONAL"] = "Pers. Ressourcen"
L["OPTIONS_TABNAME_PLAYERENEMY"] = "Feindliche Spieler"
L["OPTIONS_TABNAME_PLAYERFRIENDLY"] = "Freundliche Spieler"
L["OPTIONS_TABNAME_PROFILES"] = "Profile"
L["OPTIONS_TABNAME_SCRIPTING"] = "Skripte"
L["OPTIONS_TABNAME_SEARCH"] = "Suche"
L["OPTIONS_TABNAME_STRATA"] = "Level & Strata"
L["OPTIONS_TABNAME_TARGET"] = "Ziel"
L["OPTIONS_TABNAME_THREAT"] = "Farben / Aggro"
L["OPTIONS_TEXT_COLOR"] = "Die Farbe des Textes."
L["OPTIONS_TEXT_FONT"] = "Schriftart des Textes."
L["OPTIONS_TEXT_SIZE"] = "Größe des Textes."
L["OPTIONS_TEXTURE"] = "Textur"
L["OPTIONS_TEXTURE_BACKGROUND"] = "Hintergrundtextur"
L["OPTIONS_THREAT_AGGROSTATE_ANOTHERTANK"] = "Greift anderen Tank an"
L["OPTIONS_THREAT_AGGROSTATE_HIGHTHREAT"] = "Hohe Bedrohung"
L["OPTIONS_THREAT_AGGROSTATE_NOAGGRO"] = "Keine Bedrohung"
L["OPTIONS_THREAT_AGGROSTATE_NOTANK"] = "Greift nicht-Tank-Spieler an"
L["OPTIONS_THREAT_AGGROSTATE_NOTINCOMBAT"] = "Einheit nicht im Kampf"
L["OPTIONS_THREAT_AGGROSTATE_ONYOU_LOWAGGRO"] = "Greift dich an - niedrige Bedrohung"
L["OPTIONS_THREAT_AGGROSTATE_ONYOU_LOWAGGRO_DESC"] = "Greift dich an - kurz vor Aggro-Verlust"
L["OPTIONS_THREAT_AGGROSTATE_ONYOU_SOLID"] = "Greift dich an"
L["OPTIONS_THREAT_AGGROSTATE_TAPPED"] = "Einheit getappt"
L["OPTIONS_THREAT_CLASSIC_USE_TANK_COLORS"] = "Tank-Bedrohungsfarben verwenden"
L["OPTIONS_THREAT_COLOR_DPS_ANCHOR_TITLE"] = "Farbe bei Spiel als DPS oder Heiler"
L["OPTIONS_THREAT_COLOR_DPS_HIGHTHREAT_DESC"] = "Die Einheit steht kurz davor, dich anzugreifen."
L["OPTIONS_THREAT_COLOR_DPS_NOAGGRO_DESC"] = "Die Einheit greift dich nicht an."
L["OPTIONS_THREAT_COLOR_DPS_NOTANK_DESC"] = "Die Einheit greift weder dich noch einen Tank an und greift höchstwahrscheinlich einen anderen Heiler oder DPS deiner Gruppe an."
L["OPTIONS_THREAT_COLOR_DPS_ONYOU_SOLID_DESC"] = "Die Einheit greift dich an."
L["OPTIONS_THREAT_COLOR_OVERRIDE_ANCHOR_TITLE"] = "Standardfarben überschreiben"
L["OPTIONS_THREAT_COLOR_OVERRIDE_DESC"] = [=[Ändert die Standardfarben, die das Spiel für neutrale, feindliche und freundliche Einheiten festlegt.

Im Kampf werden diese Farben ebenfalls überschrieben, wenn Bedrohungsfarben die Farbe des Lebensbalkens ändern dürfen.]=]
L["OPTIONS_THREAT_COLOR_TANK_ANCHOR_TITLE"] = "Farbe bei Spiel als TANK"
L["OPTIONS_THREAT_COLOR_TANK_ANOTHERTANK_DESC"] = "Die Einheit wird von einem anderen Tank in deiner Gruppe getankt."
L["OPTIONS_THREAT_COLOR_TANK_NOAGGRO_DESC"] = "Die Einheit hat keine Aggro auf dich."
L["OPTIONS_THREAT_COLOR_TANK_NOTINCOMBAT_DESC"] = "Die Einheit ist nicht im Kampf."
L["OPTIONS_THREAT_COLOR_TANK_ONYOU_SOLID_DESC"] = "Die Einheit greift dich an und du hast eine solide Aggro."
L["OPTIONS_THREAT_COLOR_TAPPED_DESC"] = "Wenn jemand anderes die Einheit beansprucht hat (wenn du keine Erfahrung oder Beute für das Töten erhältst)."
L["OPTIONS_THREAT_DPS_CANCHECKNOTANK"] = "Auf Keine-Tank-Aggro prüfen"
L["OPTIONS_THREAT_DPS_CANCHECKNOTANK_DESC"] = "Wenn du als Heiler oder DPS keine Aggro hast, prüfe, ob der Gegner eine andere Einheit angreift, die kein Tank ist."
L["OPTIONS_THREAT_MODIFIERS_ANCHOR_TITLE"] = "Bedrohungs-Modifikationen"
L["OPTIONS_THREAT_MODIFIERS_BORDERCOLOR"] = "Rahmenfarbe"
L["OPTIONS_THREAT_MODIFIERS_HEALTHBARCOLOR"] = "Lebensbalkenfarbe"
L["OPTIONS_THREAT_MODIFIERS_NAMECOLOR"] = "Namensfarbe"
L["OPTIONS_THREAT_PULL_FROM_ANOTHER_TANK"] = "Von anderem Tank übernehmen"
L["OPTIONS_THREAT_PULL_FROM_ANOTHER_TANK_TANK"] = "Die Einheit hat Aggro auf einen anderen Tank und du bist kurz davor, sie zu übernehmen."
L["OPTIONS_THREAT_USE_AGGRO_FLASH"] = "Aggro-Blitz aktivieren"
L["OPTIONS_THREAT_USE_AGGRO_FLASH_DESC"] = "Aktiviert die -AGGRO-Blitz-Animation auf den Namensschildern beim Erhalt von Aggro als DPS."
L["OPTIONS_THREAT_USE_AGGRO_GLOW"] = "Aggro-Glühen aktivieren"
L["OPTIONS_THREAT_USE_AGGRO_GLOW_DESC"] = "Aktiviert das Glühen des Lebensbalkens auf den Namensschildern beim Erhalt von Aggro als DPS oder Verlust von Aggro als Tank."
L["OPTIONS_THREAT_USE_SOLO_COLOR"] = "Solo-Farbe"
L["OPTIONS_THREAT_USE_SOLO_COLOR_DESC"] = "Verwendet die 'Solo'-Farbe, wenn du nicht in einer Gruppe bist."
L["OPTIONS_THREAT_USE_SOLO_COLOR_ENABLE"] = "'Solo'-Farbe verwenden"
L["OPTIONS_TOGGLE_TO_CHANGE"] = "|cFFFFFF00 Wichtig |r: Blende die Namensschilder aus und ein, um die Änderungen zu sehen."
L["OPTIONS_WIDTH"] = "Breite"
L["OPTIONS_XOFFSET"] = "X-Versatz"
L["OPTIONS_XOFFSET_DESC"] = [=[Position auf der X-Achse anpassen.

*Rechtsklick, um den Wert einzugeben.]=]
L["OPTIONS_YOFFSET"] = "Y-Versatz"
L["OPTIONS_YOFFSET_DESC"] = [=[Position auf der Y-Achse anpassen.

*Rechtsklick, um den Wert einzugeben.]=]
L[ [=[Show nameplate for friendly npcs.

|cFFFFFF00 Important |r: This option is dependent on the client`s nameplate state (on/off).

|cFFFFFF00 Important |r: when disabled but enabled on the client through (%s), the healthbar isn't visible but the nameplate is still clickable.]=] ] = [=[Namensschild für freundliche NPCs anzeigen.

|cFFFFFF00 Wichtig |r: Diese Option ist vom Namensschild-Status des Clients abhängig (an/aus).

|cFFFFFF00 Wichtig |r: Wenn deaktiviert, aber auf dem Client durch (%s) aktiviert, ist der Lebensbalken nicht sichtbar, aber das Namensschild ist immer noch klickbar.]=]
L["TARGET_CVAR_ALWAYSONSCREEN"] = "Ziel immer auf dem Bildschirm|cFFFF7700*|r"
L["TARGET_CVAR_ALWAYSONSCREEN_DESC"] = [=[Wenn aktiviert, wird das Namensschild deines Ziels immer angezeigt, auch wenn der Gegner nicht auf dem Bildschirm ist.

|cFFFF7700[*]|r |cFFa0a0a0CVar, wird im Plater-Profil gespeichert und beim Laden des Profils wiederhergestellt.|r]=]
L["TARGET_CVAR_LOCKTOSCREEN"] = "Am Bildschirm fixieren (Oberseite)|cFFFF7700*|r"
L["TARGET_CVAR_LOCKTOSCREEN_DESC"] = [=[Mindestabstand zwischen dem Namensschild und dem oberen Rand des Bildschirms. Erhöhe dies, wenn Teile des Namensschilds aus dem Bildschirm herausragen.

|cFFFFFFFFStandard: 0,065|r

|cFFFFFF00 Wichtig |r: Wenn du Probleme hast, stelle es manuell mit diesen Makros ein:
/run SetCVar ('nameplateOtherTopInset', '0.065')
/run SetCVar ('nameplateLargeTopInset', '0.065')

|cFFFFFF00 Wichtig |r: Ein Wert von 0 deaktiviert diese Funktion.

|cFFFF7700[*]|r |cFFa0a0a0CVar, wird im Plater-Profil gespeichert und beim Laden des Profils wiederhergestellt.|r]=]
L["TARGET_HIGHLIGHT"] = "Ziel-Hervorhebung"
L["TARGET_HIGHLIGHT_ALPHA"] = "Ziel-Hervorhebungs-Alpha"
L["TARGET_HIGHLIGHT_COLOR"] = "Ziel-Hervorhebungsfarbe"
L["TARGET_HIGHLIGHT_DESC"] = "Hervorhebungseffekt auf dem Namensschild deines aktuellen Ziels."
L["TARGET_HIGHLIGHT_SIZE"] = "Ziel-Hervorhebungsgröße"
L["TARGET_HIGHLIGHT_TEXTURE"] = "Ziel-Hervorhebungstextur"
L["TARGET_OVERLAY_ALPHA"] = "Ziel-Overlay-Alpha"
L["TARGET_OVERLAY_TEXTURE"] = "Ziel-Overlay-Textur"
L["TARGET_OVERLAY_TEXTURE_DESC"] = "Wird über dem Lebensbalken verwendet, wenn es das aktuelle Ziel ist."
L["DISABLE_TESTING_AURAS"] = "Test-Auren deaktivieren"

end
