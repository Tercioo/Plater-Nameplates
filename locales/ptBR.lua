do
    local addonId = ...
    local languageTable = DetailsFramework.Language.RegisterLanguage(addonId, "ptBR")
    local L = languageTable

    L["OPTIONS_ALPHA"] = "Alpha"
    L["OPTIONS_ANCHOR"] = "Fixar"
    L["OPTIONS_ANCHOR_BOTTOM"] = "Inferior"
    L["OPTIONS_ANCHOR_BOTTOMLEFT"] = "Inferior Esquerdo"
    L["OPTIONS_ANCHOR_BOTTOMRIGHT"] = "Inferior Direito"
    L["OPTIONS_ANCHOR_CENTER"] = "Centro"
    L["OPTIONS_ANCHOR_INNERBOTTOM"] = "Interno Inferior"
    L["OPTIONS_ANCHOR_INNERLEFT"] = "Interno Esquerdo"
    L["OPTIONS_ANCHOR_INNERRIGHT"] = "Interno Direita"
    L["OPTIONS_ANCHOR_INNERTOP"] = "Interno Superior"
    L["OPTIONS_ANCHOR_LEFT"] = "Esquerda"
    L["OPTIONS_ANCHOR_RIGHT"] = "Direita"
    L["OPTIONS_ANCHOR_TOP"] = "Superior"
    L["OPTIONS_ANCHOR_TOPLEFT"] = "Superior Esquerdo"
    L["OPTIONS_ANCHOR_TOPRIGHT"] = "Superior Direito"
    L["OPTIONS_CANCEL"] = "Cancelar"
    L["OPTIONS_COLOR"] = "Cores"
    L["OPTIONS_ENABLED"] = "Habilitar"
    L["OPTIONS_ERROR_CVARMODIFY"] = "cvars não podem ser alterados durante o combate."
    L["OPTIONS_ERROR_EXPORTSTRINGERROR"] = "Falha ao exportar"
    L["OPTIONS_FONT"] = "Fonte"
    L["OPTIONS_FRIENDLY"] = "Amigável"
    L["OPTIONS_GENERALSETTINGS_HEALTHBAR_ANCHOR_TITLE"] = "Aparência da Barra de Vida"
    L["OPTIONS_GENERALSETTINGS_HEALTHBAR_BGCOLOR"] = "Barra de Vida: cor de fundo e Alpha"
    L["OPTIONS_GENERALSETTINGS_HEALTHBAR_BGTEXTURE"] = "Barra de Vida: Textura de Fundo"
    L["OPTIONS_GENERALSETTINGS_HEALTHBAR_TEXTURE"] = "Barra de Vida: Textura"
    L["OPTIONS_GENERALSETTINGS_TRANSPARENCY_ANCHOR_TITLE"] = "Transparência é Usada Para"
    L["OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK"] = "Verificação de Alcance"
    L["OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK_ALPHA"] = "Alpha"
    L["OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK_SPEC_DESC"] = "Feitiço para verificação de alcance nesta especialização."
    L["OPTIONS_HOSTILE"] = "Hostil"
    L["OPTIONS_NEUTRAL"] = "Neutro"
    L["OPTIONS_OKAY"] = "OK"
    L["OPTIONS_OUTLINE"] = "Contorno"
    L["OPTIONS_PLEASEWAIT"] = "Isso pode levar alguns segundos"
    L["OPTIONS_PROFILE_CONFIG_EXPORTINGTASK"] = "Plater está exportando o perfil atual"
    L["OPTIONS_PROFILE_CONFIG_EXPORTPROFILE"] = "Exportar Perfil"
    L["OPTIONS_PROFILE_CONFIG_IMPORTPROFILE"] = "Importar Perfil"
    L["OPTIONS_PROFILE_CONFIG_MOREPROFILES"] = "Obtenha mais perfis no Wago.io"
    L["OPTIONS_PROFILE_CONFIG_OPENSETTINGS"] = "Abrir configurações de perfil"
    L["OPTIONS_PROFILE_CONFIG_PROFILENAME"] = "Novo nome do perfil"
    L["OPTIONS_PROFILE_CONFIG_PROFILENAME_DESC"] = "Um novo perfil é criado com a String importada.  Inserir o nome de um perfil que já existe o substituirá."
    L["OPTIONS_PROFILE_ERROR_PROFILENAME"] = "Nome de perfil inválido"
    L["OPTIONS_PROFILE_ERROR_STRINGINVALID"] = "Arquivo de perfil inválido."
    L["OPTIONS_PROFILE_ERROR_WRONGTAB"] = "Arquivo de perfil inválido. Importe scripts ou mods na guia de scripts/mods."
    L["OPTIONS_PROFILE_IMPORT_OVERWRITE"] = "O perfil '%s' já existe, Deseja substituir?"
    L["OPTIONS_SETTINGS_COPIED"] = "configurações copiadas."
    L["OPTIONS_SETTINGS_FAIL_COPIED"] = "falha ao obter as configurações da guia selecionada."
    L["OPTIONS_SHADOWCOLOR"] = "Cor da Sombra"
    L["OPTIONS_SIZE"] = "Tamanho."
    L["OPTIONS_STATUSBAR_TEXT"] = "Agora você pode importar perfis, mods, scripts, animações e tabelas de cores de |cFFFFAA00http://wago.io|r"
    L["OPTIONS_TABNAME_ADVANCED"] = "Avançado"
    L["OPTIONS_TABNAME_ANIMATIONS"] = "Feedback de feitiços"
    L["OPTIONS_TABNAME_AUTO"] = "Automatizações"
    L["OPTIONS_TABNAME_BUFF_LIST"] = "Lista de Feitiços"
    L["OPTIONS_TABNAME_BUFF_SETTINGS"] = "Buff Config"
    L["OPTIONS_TABNAME_BUFF_SPECIAL"] = "Buff Especiais"
    L["OPTIONS_TABNAME_BUFF_TRACKING"] = "Rastreamento de Buff"
    L["OPTIONS_TABNAME_CASTBAR"] = "Barra de Lançamento"
    L["OPTIONS_TABNAME_CASTCOLORS"] = "Nomes e Cores de Cast"
    L["OPTIONS_TABNAME_COMBOPOINTS"] = "Pontos de Combo"
    L["OPTIONS_TABNAME_GENERALSETTINGS"] = "Config Gerais"
    L["OPTIONS_TABNAME_MODDING"] = "Mods"
    L["OPTIONS_TABNAME_NPC_COLORNAME"] = "Nomes e Cores de NPCs"
    L["OPTIONS_TABNAME_NPCENEMY"] = "NPC Inimigo"
    L["OPTIONS_TABNAME_NPCFRIENDLY"] = "NPC Amigo"
    L["OPTIONS_TABNAME_PERSONAL"] = "Barra pessoal"
    L["OPTIONS_TABNAME_PLAYERENEMY"] = "Jogador Inimigo"
    L["OPTIONS_TABNAME_PLAYERFRIENDLY"] = "Jogador Amigo"
    L["OPTIONS_TABNAME_PROFILES"] = "Perfis "
    L["OPTIONS_TABNAME_SCRIPTING"] = "Scripts"
    L["OPTIONS_TABNAME_SEARCH"] = "Pesquisar"
    L["OPTIONS_TABNAME_STRATA"] = "Nível e estratos"
    L["OPTIONS_TABNAME_TARGET"] = "Alvo"
    L["OPTIONS_TABNAME_THREAT"] = "Cores / Aggro"
    L["OPTIONS_TEXTURE"] = "Textura"
    L["OPTIONS_THREAT_AGGROSTATE_ANOTHERTANK"] = "Aggro em outro Tank"
    L["OPTIONS_THREAT_AGGROSTATE_HIGHTHREAT"] = "Ameaça alta"
    L["OPTIONS_THREAT_AGGROSTATE_NOAGGRO"] = "Sem Aggro"
    L["OPTIONS_THREAT_AGGROSTATE_NOTANK"] = "Sem Aggro nos Tanks"
    L["OPTIONS_THREAT_AGGROSTATE_NOTINCOMBAT"] = "Unidade fora de combate"
    L["OPTIONS_THREAT_AGGROSTATE_ONYOU_LOWAGGRO"] = "Aggro em você, mas é baixo"
    L["OPTIONS_THREAT_AGGROSTATE_ONYOU_LOWAGGRO_DESC"] = "a unidade está atacando você, mas outros podem tomar o Aggro."
    L["OPTIONS_THREAT_AGGROSTATE_ONYOU_SOLID"] = "Aggro em Você"
    L["OPTIONS_THREAT_AGGROSTATE_TAPPED"] = "Unidade Perdida"
    L["OPTIONS_THREAT_COLOR_DPS_ANCHOR_TITLE"] = "Cor ao Jogar como DPS ou HEALER"
    L["OPTIONS_THREAT_COLOR_DPS_HIGHTHREAT_DESC"] = "A unidade começa a atacar você."
    L["OPTIONS_THREAT_COLOR_DPS_NOAGGRO_DESC"] = "A unidade não está atacando você."
    L["OPTIONS_THREAT_COLOR_DPS_NOTANK_DESC"] = "A unidade não está atacando você ou outro tank e provavelmente está atacando o Healer ou dps do seu grupo."
    L["OPTIONS_THREAT_COLOR_DPS_ONYOU_SOLID_DESC"] = "A unidade está atacando você."
    L["OPTIONS_THREAT_COLOR_OVERRIDE_ANCHOR_TITLE"] = "Substituir cores padrão"
    L["OPTIONS_THREAT_COLOR_OVERRIDE_DESC"] = "Modifique as cores padrão definidas pelo jogo para unidades neutras, hostis e amigáveis. Durante o combate, essas cores serão substituídas também se as cores de ameaça puderem mudar a cor da barra de saúde."
    L["OPTIONS_THREAT_COLOR_TANK_ANCHOR_TITLE"] = "Cor ao Jogar como TANK"
    L["OPTIONS_THREAT_COLOR_TANK_ANOTHERTANK_DESC"] = "A unidade está com outro tank do seu grupo."
    L["OPTIONS_THREAT_COLOR_TANK_NOAGGRO_DESC"] = "A unidade não tem Aggro em você"
    L["OPTIONS_THREAT_COLOR_TANK_NOTINCOMBAT_DESC"] = "A unidade não está em combate."
    L["OPTIONS_THREAT_COLOR_TANK_ONYOU_SOLID_DESC"] = "A unidade está atacando você e você tem um aggro sólido."
    L["OPTIONS_THREAT_COLOR_TAPPED_DESC"] = "Quando alguém reivindicou a unidade (quando você não recebe experiência ou pilhagem por matá-la)."
    L["OPTIONS_THREAT_DPS_CANCHECKNOTANK"] = "Marque para Unidade sem Aggro no Tank"
    L["OPTIONS_THREAT_DPS_CANCHECKNOTANK_DESC"] = "Quando você não tem aggro como curandeiro ou dps, verifique se o inimigo está atacando outra unidade que não é um tank."
    L["OPTIONS_THREAT_MODIFIERS_ANCHOR_TITLE"] = "Modificações de Aggro"
    L["OPTIONS_THREAT_MODIFIERS_BORDERCOLOR"] = "Cor de Borda"
    L["OPTIONS_THREAT_MODIFIERS_HEALTHBARCOLOR"] = "Cor da Barra de Vida"
    L["OPTIONS_THREAT_MODIFIERS_NAMECOLOR"] = "Cor do Nome"
    L["OPTIONS_XOFFSET"] = "Deslocamento horizontal"
    L["OPTIONS_YOFFSET"] = "Deslocamento vertical"

    L["OPTIONS_NAMEPLATE_SHOW_ENEMY"] = "Mostrar placas de identificação de inimigos|cFFFF7700*|r"
    L["OPTIONS_BACKGROUND_ALWAYSSHOW_DESC"] = "Ativar um fundo mostrando a área da área clicável."
    L["OPTIONS_FORMAT_NUMBER"] = "Formato de número"
    L["OPTIONS_RESOURCES_TARGET_DESC"] = [[Mostra seus recursos, como pontos de combo, acima do seu alvo atual.
    Usa recursos padrão da Blizzard e desabilita os recursos próprios do Plater.

    Configuração específica do personagem!]]
    L["OPTIONS_ICON_QUEST"] = "Ícone de missão"
    L["OPTIONS_RANGECHECK_OUTOFRANGE"] = "Unidades fora de alcance"
    L["OPTIONS_CVAR_ENABLE_PERSONAL_BAR_DESC"] = [[Mostra barras de saúde e mana miniaturas sob o seu personagem.

    |cFFFF7700[]|r |cFFa0a0a0CVar, salva dentro do perfil do Plater e restaurada ao carregar o perfil.|r]]
    L["OPTIONS_ALPHABYFRAME_ALPHAMULTIPLIER"] = "Multiplicador de transparência."
    L["OPTIONS_MOVE_VERTICAL"] = "Mover verticalmente."
    L["OPTIONS_ICONSPACING"] = "Espaçamento de ícone"
    L["OPTIONS_ICON_RARE"] = "Ícone raro"
    L["OPTIONS_CLICK_SPACE_HEIGHT"] = "A altura da área que aceita cliques do mouse para selecionar o alvo"
    L["OPTIONS_ICON_ENEMYFACTION"] = "Ícone de facção inimiga"
    L["OPTIONS_CVAR_NAMEPLATES_ALWAYSSHOW"] = "Sempre mostrar placas de identificação|cFFFF7700|r"
    L["OPTIONS_ICON_ELITE"] = "Ícone de elite"
    L["OPTIONS_RANGECHECK_NOTMYTARGETOUTOFRANGE"] = "Fora do alcance + Não é seu alvo"
    L["OPTIONS_PET_SCALE_DESC"] = "Ajuste ligeiramente o tamanho das placas de identificação ao mostrar um ajudante"
    L["OPTIONS_AURAS_SORT"] = "Classificar auras"
    L["OPTIONS_MOVE_HORIZONTAL"] = "Mover horizontalmente."
    L["OPTIONS_NAMEPLATE_SHOW_FRIENDLY"] = "Mostrar placas de identificação amigáveis|cFFFF7700*|r"
    L["OPTIONS_NAMEPLATES_STACKING_DESC"] = [[Se ativado, as placas de identificação não se sobrepõem umas às outras.

    |cFFFF7700[*]|r |cFFa0a0a0CVar, salva dentro do perfil do Plater e restaurada ao carregar o perfil.|r

    |cFFFFFF00Importante |r: para definir a quantidade de espaço entre cada placa de identificação, veja a opção '|cFFFFFFFFPreenchimento vertical da placa de identificação|r' abaixo.
    Verifique as configurações da guia 'Auto' para configurar a alternância automática dessa opção.]]
    L["OPTIONS_ALPHABYFRAME_TARGET_INRANGE"] = "Alvo/No alcance da transparência"
    L["OPTIONS_INDICATORS"] = "Indicadores"
    L["OPTIONS_SHIELD_BAR"] = "Barra de escudo"
    L["OPTIONS_ALPHABYFRAME_ENABLE_ENEMIES_DESC"] = "Aplicar configurações de transparência a unidades inimigas."
    L["OPTIONS_ALPHABYFRAME_ENABLE_FRIENDLY"] = "Habilitar para aliados"
    L["OPTIONS_NAMEPLATE_SHOW_ENEMY"] = "Mostrar placas de identificação do Inimigo|cFFFF7700*|r"
    L["OPTIONS_BACKGROUND_ALWAYSSHOW_DESC"] = "Ativar um fundo que mostra a área da área clicável."
    L["OPTIONS_FORMAT_NUMBER"] = "Formato de Número"
    L["OPTIONS_RESOURCES_TARGET_DESC"] = [[Mostra seus recursos, como pontos de combo, acima do seu alvo atual.
    Usa os recursos padrão do Blizzard e desativa os recursos do Plater.

    Configuração específica do personagem!]]
    L["OPTIONS_ICON_QUEST"] = "Ícone da Missão"
    L["OPTIONS_RANGECHECK_OUTOFRANGE"] = "Unidades Fora do Seu Alcance"
    L["OPTIONS_CVAR_ENABLE_PERSONAL_BAR_DESC"] = [[Mostra uma mini barra de saúde e mana sob o seu personagem.

    |cFFFF7700[]|r |cFFa0a0a0CVar, salvo dentro do perfil do Plater e restaurado ao carregar o perfil.|r]]
    L["OPTIONS_ALPHABYFRAME_ALPHAMULTIPLIER"] = "Multiplicador de Transparência."
    L["OPTIONS_MOVE_VERTICAL"] = "Mover verticalmente."
    L["OPTIONS_ICONSPACING"] = "Espaçamento do Ícone"
    L["OPTIONS_ICON_RARE"] = "Ícone de Raro"
    L["OPTIONS_CLICK_SPACE_HEIGHT"] = "A altura da área que aceita cliques do mouse para selecionar o alvo."
    L["OPTIONS_ICON_ENEMYFACTION"] = "Ícone da Facção Inimiga"
    L["OPTIONS_CVAR_NAMEPLATES_ALWAYSSHOW"] = "Mostrar Sempre Placas de Identificação|cFFFF7700|r"
    L["OPTIONS_ICON_ELITE"] = "Ícone de Elite"
    L["OPTIONS_RANGECHECK_NOTMYTARGETOUTOFRANGE"] = "Fora do Alcance + Não é Seu Alvo"
    L["OPTIONS_PET_SCALE_DESC"] = "Ajuste levemente o tamanho das placas de identificação ao mostrar um ajudante."
    L["OPTIONS_AURAS_SORT"] = "Classificar Auras"
    L["OPTIONS_MOVE_HORIZONTAL"] = "Mover horizontalmente."
    L["OPTIONS_NAMEPLATE_SHOW_FRIENDLY"] = "Mostrar placas de identificação Amigáveis|cFFFF7700*|r"
    L["OPTIONS_NAMEPLATES_STACKING_DESC"] = [[Se ativado, as placas de identificação não se sobrepõem umas às outras.

    |cFFFF7700[*]|r |cFFa0a0a0CVar, salvo dentro do perfil do Plater e restaurado ao carregar o perfil.|r

    |cFFFFFF00Importante |r: para definir a quantidade de espaço entre cada placa de identificação, veja a opção '|cFFFFFFFFPreenchimento Vertical da Placa de Identificação|r' abaixo.
    Verifique as configurações da guia 'Auto' para configurar a alternância automática dessa opção.]]
    L["OPTIONS_ALPHABYFRAME_TARGET_INRANGE"] = "Alvo Alpha/Alcance"
    L["OPTIONS_INDICATORS"] = "Indicadores"
    L["OPTIONS_SHIELD_BAR"] = "Barra de Escudo"
    L["OPTIONS_ALPHABYFRAME_ENABLE_ENEMIES_DESC"] = "Aplica as configurações de transparência a unidades inimigas."
    L["OPTIONS_NAMEPLATE_SHOW_ENEMY"] = "Mostrar placas de identificação do Inimigo|cFFFF7700*|r"
    L["OPTIONS_BACKGROUND_ALWAYSSHOW_DESC"] = "Ativar um fundo que mostra a área da área clicável."
    L["OPTIONS_FORMAT_NUMBER"] = "Formato de Número"
    L["OPTIONS_RESOURCES_TARGET_DESC"] = [[Mostra seus recursos, como pontos de combo, acima do seu alvo atual.
    Usa os recursos padrão do Blizzard e desativa os recursos do Plater.

    Configuração específica do personagem!]]
    L["OPTIONS_ICON_QUEST"] = "Ícone da Missão"
    L["OPTIONS_RANGECHECK_OUTOFRANGE"] = "Unidades Fora do Seu Alcance"
    L["OPTIONS_CVAR_ENABLE_PERSONAL_BAR_DESC"] = [[Mostra uma mini barra de saúde e mana sob o seu personagem.

    |cFFFF7700[]|r |cFFa0a0a0CVar, salvo dentro do perfil do Plater e restaurado ao carregar o perfil.|r]]
    L["OPTIONS_ALPHABYFRAME_ALPHAMULTIPLIER"] = "Multiplicador de Transparência."
    L["OPTIONS_MOVE_VERTICAL"] = "Mover verticalmente."
    L["OPTIONS_ICONSPACING"] = "Espaçamento do Ícone"
    L["OPTIONS_ICON_RARE"] = "Ícone de Raro"
    L["OPTIONS_CLICK_SPACE_HEIGHT"] = "A altura da área que aceita cliques do mouse para selecionar o alvo."
    L["OPTIONS_ICON_ENEMYFACTION"] = "Ícone da Facção Inimiga"
    L["OPTIONS_CVAR_NAMEPLATES_ALWAYSSHOW"] = "Mostrar Sempre Placas de Identificação|cFFFF7700|r"
    L["OPTIONS_ICON_ELITE"] = "Ícone de Elite"
    L["OPTIONS_RANGECHECK_NOTMYTARGETOUTOFRANGE"] = "Fora do Alcance + Não é Seu Alvo"
    L["OPTIONS_PET_SCALE_DESC"] = "Ajuste levemente o tamanho das placas de identificação ao mostrar um ajudante."
    L["OPTIONS_AURAS_SORT"] = "Classificar Auras"
    L["OPTIONS_MOVE_HORIZONTAL"] = "Mover horizontalmente."
    L["OPTIONS_NAMEPLATE_SHOW_FRIENDLY"] = "Mostrar placas de identificação Amigáveis|cFFFF7700*|r"
    L["OPTIONS_NAMEPLATES_STACKING_DESC"] = [[Se ativado, as placas de identificação não se sobrepõem umas às outras.

    |cFFFF7700[*]|r |cFFa0a0a0CVar, salvo dentro do perfil do Plater e restaurado ao carregar o perfil.|r

    |cFFFFFF00Importante |r: para definir a quantidade de espaço entre cada placa de identificação, veja a opção '|cFFFFFFFFPreenchimento Vertical da Placa de Identificação|r' abaixo.
    Verifique as configurações da guia 'Auto' para configurar a alternância automática dessa opção.]]
    L["OPTIONS_ALPHABYFRAME_TARGET_INRANGE"] = "Alvo Alpha/Alcance"
    L["OPTIONS_INDICATORS"] = "Indicadores"
    L["OPTIONS_SHIELD_BAR"] = "Barra de Escudo"
    L["OPTIONS_ALPHABYFRAME_ENABLE_ENEMIES_DESC"] = "Aplica as configurações de transparência a unidades inimigas."

    L["OPTIONS_STACK_AURATIME_DESC"] = "Mostra o tempo mais curto das auras empilhadas ou o tempo mais longo, quando desativado."
    L["OPTIONS_ICON_ENEMYFACTION"] = "Ícone de Facção Inimiga"
    L["OPTIONS_AURAS_SORT_DESC"] = "As auras são ordenadas pelo tempo restante (padrão)."
    L["OPTIONS_ALPHABYFRAME_DEFAULT_DESC"] = "Quantidade de transparência aplicada a todos os componentes de uma única placa de identificação."
    L["OPTIONS_NAMEPLATE_OFFSET"] = "Ajuste levemente toda a placa de identificação."
    L["OPTIONS_BACKGROUND_ALWAYSSHOW"] = "Sempre Mostrar Fundo"
    L["OPTIONS_ICON_ELITE"] = "Ícone de Elite"
    L["OPTIONS_RANGECHECK_OUTOFRANGE"] = "Unidades Fora do Seu Alcance"
    L["OPTIONS_CVAR_ENABLE_PERSONAL_BAR_DESC"] = [[Mostra barras de saúde e mana miniaturas abaixo do seu personagem.

    |cFFFF7700[*]|r |cFFa0a0a0CVar, salvo dentro do perfil Plater e restaurado ao carregar o perfil.|r]]
    L["OPTIONS_ALPHABYFRAME_ALPHAMULTIPLIER"] = "Multiplicador de transparência."
    L["OPTIONS_RANGECHECK_NOTMYTARGETOUTOFRANGE"] = "Fora do Alcance + Não é Seu Alvo"
    L["OPTIONS_FORMAT_NUMBER"] = "Formato de Número"

    L["OPTIONS_POWERBAR"] = "Barra de Poder"
    L["OPTIONS_ICON_QUEST"] = "Ícone de Missão"
    L["OPTIONS_NAMEPLATE_SHOW_ENEMY_DESC"] = "Mostrar placa de identificação para unidades inimigas e neutras.\n\n|cFFFF7700[]|r |cFFa0a0a0CVar, salva dentro do perfil do Plater e restaurada ao carregar o perfil.|r"
    L["OPTIONS_ALPHABYFRAME_ENABLE_ENEMIES_DESC"] = "Aplicar configurações de transparência para unidades inimigas."
    L["OPTIONS_RANGECHECK_NONE"] = "Nada"
    L["OPTIONS_NAMEPLATE_SHOW_FRIENDLY_DESC"] = "Mostrar placa de identificação para jogadores amigáveis.\n\n|cFFFF7700[]|r |cFFa0a0a0CVar, salva dentro do perfil do Plater e restaurada ao carregar o perfil.|r"
    L["OPTIONS_ICON_RARE"] = "Ícone de Raro"
    L["OPTIONS_AURA_DEBUFF_WITH"] = "Largura do ícone da penalidade."
    L["OPTIONS_NAMEPLATES_STACKING"] = "Pilhas de Placas de Identificação|cFFFF7700*|r"
    L["OPTIONS_PET_SCALE_DESC"] = "Ajustar ligeiramente o tamanho das placas de identificação ao exibir um mascote"
    L["OPTIONS_AMOUNT"] = "Quantidade"
    L["OPTIONS_NAMEPLATES_OVERLAP_DESC"] = "O espaço entre cada placa de identificação verticalmente quando as pilhas estão habilitadas.\n\n|cFFFFFFFFPadrão: 1.10|r\n\n|cFFFF7700[]|r |cFFa0a0a0CVar, salva dentro do perfil do Plater e restaurada ao carregar o perfil.|r\n\n|cFFFFFF00Importante|r: Se você encontrar problemas com essa configuração, use:\n|cFFFFFFFF/run SetCVar('nameplateOverlapV', '1.6')|r"
    L["OPTIONS_EXECUTERANGE_HIGH_HEALTH_DESC"] = "Mostrar o indicador de execução para a parte alta da vida.\n\nSe a detecção não funcionar após uma atualização, comunique no Discord."
    L["OPTIONS_ICON_FRIENDLY_SPEC"] = "Ícone de Especialização Amigável"
    L["OPTIONS_CLICK_SPACE_WIDTH"] = "A largura da área que aceita cliques do mouse para selecionar o alvo"
    L["OPTIONS_ICON_PET"] = "Ícone de Mascote"
    L["OPTIONS_ICON_FRIENDLYFACTION"] = "Ícone de Facção Amigável"
    L["OPTIONS_ALPHABYFRAME_TITLE_ENEMIES"] = "Quantidade de transparência por quadro (inimigos)"
    L["OPTIONS_RANGECHECK_NOTMYTARGETOUTOFRANGE_DESC"] = "Reduz a transparência das unidades que não são seu alvo.\nReduz ainda mais se a unidade estiver fora de alcance."
    L["OPTIONS_HEALTHBAR_HEIGHT"] = "Altura da Barra de Vida"
    L["OPTIONS_CVAR_ENABLE_PERSONAL_BAR"] = "Barras de Vida e Mana Pessoais|cFFFF7700|r"
    L["OPTIONS_NAMEPLATES_OVERLAP"] = "Sobreposição de Placas de Identificação (V)|cFFFF7700*|r"

    L["OPTIONS_ICON_ENEMYCLASS"] = "Ícone de Classe do Inimigo"
    L["OPTIONS_HEALTHBAR_SIZE_GLOBAL_DESC"] = [[Altere o tamanho das placas de identificação do inimigo e do amigável para jogadores e PNJs em combate e fora de combate.

    Cada uma dessas opções pode ser alterada individualmente nas guias NPC Inimigo e Jogador Inimigo.]]
    L["OPTIONS_AURA_DEBUFF_HEIGHT"] = "Altura do Ícone de Debuff."
    L["OPTIONS_PET_SCALE_HEIGHT"] = "Escala de Altura do Pet"
    L["OPTIONS_RANGECHECK_OUTOFRANGE_DESC"] = "Quando uma placa de identificação está fora de alcance, a transparência é reduzida."
    L["OPTIONS_SCALE"] = "Escala"
    L["OPTIONS_ICON_WORLDBOSS"] = "Ícone de Chefe Mundial"
    L["OPTIONS_ICON_ENEMYSPEC"] = "Ícone de Especialização do Inimigo"
    L["OPTIONS_ALPHABYFRAME_TARGET_INRANGE_DESC"] = "Transparência para unidades que estão no alcance ou são o alvo."
    L["OPTIONS_ALPHABYFRAME_TITLE_FRIENDLY"] = "Quantidade de Transparência por Quadro (amigável)"
    L["OPTIONS_HEALTHBAR"] = "Barra de Vida"
    L["OPTIONS_STACK_AURATIME"] = "Mostrar o tempo mais curto das auras empilhadas"
    L["OPTIONS_CVAR_NAMEPLATES_ALWAYSSHOW_DESC"] = [[Mostra as placas de identificação para todas as unidades próximas. Se desativado, mostra apenas unidades relevantes quando você está em combate.

    |cFFFF7700[*]|r |cFFa0a0a0CVar, salvo no perfil do Plater e restaurado ao carregar o perfil.|r]]
    L["OPTIONS_STACK_SIMILAR_AURAS"] = "Agrupar Auras Semelhantes"
    L["OPTIONS_RESOURCES_TARGET"] = "Mostrar Recursos no Alvo"
    L["OPTIONS_EXECUTERANGE_HIGH_HEALTH"] = "Alcance de Execução (alta cura)"
    L["OPTIONS_PET_SCALE_WIDTH"] = "Escala de Largura do Pet"
    L["OPTIONS_MINOR_SCALE_WIDTH"] = "Escala de Largura de Unidades Menores"
    L["OPTIONS_BUFFFRAMES"] = "Quadros de Buff"
    L["OPTIONS_HEALTHBAR_WIDTH"] = "Largura da Barra de Vida"
    L["OPTIONS_ALPHABYFRAME_ENABLE_ENEMIES"] = "Ativar Para Inimigos"
    L["OPTIONS_EXECUTERANGE"] = "Alcance de Execução"
    L["OPTIONS_AURAS_ENABLETEST"] = "Habilitar para ocultar as auras de teste mostradas durante a configuração."
    L["OPTIONS_MINOR_SCALE_HEIGHT"] = "Escala de Altura de Unidades Menores"
end