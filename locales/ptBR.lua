do
    local addonId = ...
    local languageTable = DetailsFramework.Language.RegisterLanguage(addonId, "ptBR")
    local L = languageTable

    --add to curseforge

    L["OPTIONS_"] = ""

    L["OPTIONS_AUDIOCUE_COOLDOWN"] = "Áudio do Resfriamento"
    L["OPTIONS_AUDIOCUE_COOLDOWN_DESC"] =
    "Quantidade de tempo em milissegundos de espera antes que o MESMO audio seja tocado novamente.\n\nEvita que sons altos sejam reproduzidos quando dois ou mais lançamentos estão acontecendo ao mesmo tempo.\n\nDefina para 0 para desabilitar a funcionalidade."

    --on curseforge
    L["OPTIONS_CASTBAR_APPEARANCE"] = "Aparência da Barra de Lançamento"
    L["OPTIONS_CASTBAR_SPARK_SETTINGS"] = "Configuração de Faísca"
    L["OPTIONS_CASTBAR_COLORS"] = "Cores da Barra de Lançamento"
    L["OPTIONS_CASTBAR_SPELLICON"] = "Ícone do Feitiço"
    L["OPTIONS_CASTBAR_BLIZZCASTBAR"] = "Barra de Lançamento da Blizzard"

    L["IMPORT_CAST_SOUNDS"] = "Importar Sons"
    L["EXPORT_CAST_SOUNDS"] = "Compartilhar Sons"
    L["OPTIONS_NOTHING_TO_EXPORT"] = "Não há nada para exportar."
    L["IMPORT"] = "Importar"
    L["EXPORT"] = "Exportar"
    L["IMPORT_CAST_COLORS"] = "Importar Cores"
    L["EXPORT_CAST_COLORS"] = "Compartilhar Cores"
    L["OPTIONS_SHOWOPTIONS"] = "Mostrar Opções"
    L["OPTIONS_SHOWSCRIPTS"] = "Mostrar Scripts"
    L["OPTIONS_CASTCOLORS_DISABLECOLORS"] = "Desabilita todas as Cores"
    L["OPTIONS_CASTCOLORS_DISABLECOLORS_CONFIRM"] = "Confirma a desativação de todas as cores de lançamento?"
    L["OPTIONS_CASTCOLORS_DISABLE_SOUNDS"] = "Remove Todos os Sons"
    L["OPTIONS_CASTCOLORS_DISABLE_SOUNDS_CONFIRM"] =
    "Você tem certeza que quer remover todas as configurações de sons de lançamento?"

    L["OPTIONS_NOESSENTIAL_TITLE"] = "Pular Patches de Script não Essenciais"
    L["OPTIONS_NOESSENTIAL_NAME"] =
    "Desabilita script de atualização não essencial durante atualização de versão do Plater."
    L["OPTIONS_NOESSENTIAL_DESC"] =
    "Ao atualizar o Plater, é comum que a nova versão também atualize os scripts na área de scripts.\nIsso pode às vezes, substituir as alterações feitas pelo criador do perfil. A opção abaixo impede que o Plater modifique scripts quando o addon recebe uma atualização.\n\nNote: Durante os principais patches e correções de bugs, o Plater ainda pode atualizar os scripts."
    L["OPTIONS_NOESSENTIAL_SKIP_ALERT"] = "Ignorar patch não essencial:"

    L["OPTIONS_COLOR_BACKGROUND"] = "Cor de Fundo"

    L["OPTIONS_CASTBAR_SPARK_HIDE_INTERRUPT"] = "Esconde Faísca Durante uma Interrupção"
    L["OPTIONS_CASTBAR_SPARK_HALF"] = "Meia Faísca"
    L["OPTIONS_CASTBAR_SPARK_HALF_DESC"] = "Mostra apenas metade da textura da faísca."
    L["OPTIONS_CASTBAR_FADE_ANIM_ENABLED"] = "Habilita Esmaecer nas Animações"
    L["OPTIONS_CASTBAR_FADE_ANIM_ENABLED_DESC"] = "Habilita animações de esmaecer quando um lançamento inicia e para."
    L["OPTIONS_CASTBAR_FADE_ANIM_TIME_START"] = "No Início"
    L["OPTIONS_CASTBAR_FADE_ANIM_TIME_START_DESC"] =
    "Quando um lançamento começa, isso é a quantidade de tempo que a barra de lançamento leva para passar de transparência zero para opaca total."
    L["OPTIONS_CASTBAR_FADE_ANIM_TIME_END"] = "Na Parada"
    L["OPTIONS_CASTBAR_FADE_ANIM_TIME_END_DESC"] =
    "Quando um lançamento finaliza, isso é a quantidade de tempo que a barra de lançamento leva para passar de 100% de transparência para completamente invisível."

    L["OPTIONS_CAST_COLOR_REGULAR"] = "Regular"
    L["OPTIONS_CAST_COLOR_CHANNELING"] = "Canalizado"
    L["OPTIONS_CAST_COLOR_UNINTERRUPTIBLE"] = "Ininterrupto"
    L["OPTIONS_CAST_COLOR_INTERRUPTED"] = "Interrompido"
    L["OPTIONS_CAST_COLOR_SUCCESS"] = "Sucesso"

    L["OPTIONS_CAST_SHOW_TARGETNAME"] = "Mostra o Nome do Alvo"
    L["OPTIONS_CAST_SHOW_TARGETNAME_DESC"] = "Mostra quem é o alvo do lançamento atual (se o alvo existir)"
    L["OPTIONS_CAST_SHOW_TARGETNAME_TANK"] = "[Tanque] Não Mostre Seu Nome"
    L["OPTIONS_CAST_SHOW_TARGETNAME_TANK_DESC"] =
    "Se você é o tanque não mostre o nome do alvo se o lançamento for em você."

    L["OPTIONS_THREAT_USE_SOLO_COLOR"] = "Cor Solo"
    L["OPTIONS_THREAT_USE_SOLO_COLOR_ENABLE"] = "Usa a cor 'Solo'"
    L["OPTIONS_THREAT_USE_SOLO_COLOR_DESC"] = "Usa a cor 'Solo' quando não estiver em grupo."

    L["OPTIONS_THREAT_PULL_FROM_ANOTHER_TANK"] = "Puxando Para Outro Tanque"
    L["OPTIONS_THREAT_PULL_FROM_ANOTHER_TANK_TANK"] =
    "A unidade está com aggro em outro tanque e você está prestes a puxar para você."

    L["OPTIONS_THREAT_CLASSIC_USE_TANK_COLORS"] = "Usa as Cores de Ameaça de Tanque"

    L["OPTIONS_THREAT_USE_AGGRO_GLOW"] = "Habilita o brilho do aggro"
    L["OPTIONS_THREAT_USE_AGGRO_GLOW_DESC"] =
    "Habilita o brilho da barra de saúde nas placas de identificação ao ganhar aggro como dps ou perder aggro como tanque."
    L["OPTIONS_THREAT_USE_AGGRO_FLASH"] = "Ativa clarão no aggro"
    L["OPTIONS_THREAT_USE_AGGRO_FLASH_DESC"] =
    "Ativa a animação de clarão do -AGGRO- nas placas de identificação ao ganhar o aggro como dps."

    L["OPTIONS_CASTBAR_ICON_CUSTOM_ENABLE"] = "Habilita Customização de Ícone"
    L["OPTIONS_CASTBAR_ICON_CUSTOM_ENABLE_DESC"] =
    "Se essa opção for desabilitada, Plater não irá modificar ícones de magia, deixe que os scripts façam isso."
    L["OPTIONS_CASTBAR_NO_SPELLNAME_LIMIT"] = "Sem Limitação de Comprimento no Nome do Feitiço"
    L["OPTIONS_CASTBAR_NO_SPELLNAME_LIMIT_DESC"] =
    "Nome do feitiço não será cortado para encaixar na largura da barra de lançamento."
    L["OPTIONS_INTERRUPT_SHOW_AUTHOR"] = "Mostra o Autor da Interrupção"
    L["OPTIONS_INTERRUPT_SHOW_ANIM"] = "Reproduz Animação de Interrupção"
    L["OPTIONS_INTERRUPT_FILLBAR"] = "Preenche a Barra de lançamento na Interrupção"
    L["OPTIONS_CASTBAR_QUICKHIDE"] = "Ocultação Rápida da Barra de Lançamento"
    L["OPTIONS_CASTBAR_QUICKHIDE_DESC"] =
    "Depois da finalização do lançamento, a barra de lançamento fica oculta imediatamente."
    L["OPTIONS_CASTBAR_HIDE_FRIENDLY"] = "Esconde a Barra de Lançamento de Aliados"
    L["OPTIONS_CASTBAR_HIDE_ENEMY"] = "Esconde a Barra de Lançamento de Inimigos"
    L["OPTIONS_CASTBAR_TOGGLE_TEST"] = "Ativa Barra de Lançamento Teste"
    L["OPTIONS_CASTBAR_TOGGLE_TEST_DESC"] = "Inicia a barra de lançamento teste, pressione de novo para parar."
    L["OPTIONS_ICON_SHOW"] = "Mostrar Ícone"
    L["OPTIONS_ICON_SIDE"] = "Mostrar Lateral"
    L["OPTIONS_ICON_SIZE"] = "Mostrar Tamanho"
    L["OPTIONS_TEXTURE_BACKGROUND"] = "Textura de Fundo"
    L["HIGHLIGHT_HOVEROVER"] = "Passe o Mouse Sobre o Destaque"
    L["HIGHLIGHT_HOVEROVER_ALPHA"] = "Passe o Mouse Sobre o Destaque Alfa"
    L["HIGHLIGHT_HOVEROVER_DESC"] = "Destaque os efeitos quando o mouse estiver em cima da placa de identificação."
    L["OPTIONS_ALPHA"] = "Alfa"
    L["OPTIONS_ALPHABYFRAME_ALPHAMULTIPLIER"] = "Transparência de multijogador."
    L["OPTIONS_ALPHABYFRAME_DEFAULT"] = "Transparência Padrão"
    L["OPTIONS_ALPHABYFRAME_DEFAULT_DESC"] =
    "Quantidade de transparência aplicada a todos os componentes de uma única placa de identificação."
    L["OPTIONS_ALPHABYFRAME_ENABLE_ENEMIES"] = "Habilitar para Inimigos"
    L["OPTIONS_ALPHABYFRAME_ENABLE_ENEMIES_DESC"] = "Aplicar configurações de transparência para unidades inimigas."
    L["OPTIONS_ALPHABYFRAME_ENABLE_FRIENDLY"] = "Habilitar para Aliados"
    L["OPTIONS_ALPHABYFRAME_ENABLE_FRIENDLY_DESC"] = "Aplicar configurações de transparência para unidades aliadas."
    L["OPTIONS_ALPHABYFRAME_TARGET_INRANGE"] = "Alvo Alfa/Em-Alcance"
    L["OPTIONS_ALPHABYFRAME_TARGET_INRANGE_DESC"] = "Transparência para alvos ou unidades ao alcance."
    L["OPTIONS_ALPHABYFRAME_TITLE_ENEMIES"] = "Quantidade de Transparência Por Frame (inimigos)"
    L["OPTIONS_ALPHABYFRAME_TITLE_FRIENDLY"] = "Quantidade de Transparência Por Frame (aliados)"
    L["OPTIONS_AMOUNT"] = "Quantidade"
    L["OPTIONS_ANCHOR"] = "Âncora"
    L["OPTIONS_ANCHOR_BOTTOM"] = "Inferior"
    L["OPTIONS_ANCHOR_BOTTOMLEFT"] = "Inferior Esquerdo"
    L["OPTIONS_ANCHOR_BOTTOMRIGHT"] = "Inferior Direito"
    L["OPTIONS_ANCHOR_CENTER"] = "Centro"
    L["OPTIONS_ANCHOR_INNERBOTTOM"] = "Interno Inferior"
    L["OPTIONS_ANCHOR_INNERLEFT"] = "Interno Esquerdo"
    L["OPTIONS_ANCHOR_INNERRIGHT"] = "Interno Direito"
    L["OPTIONS_ANCHOR_INNERTOP"] = "Interno Superior"
    L["OPTIONS_ANCHOR_LEFT"] = "Esquerda"
    L["OPTIONS_ANCHOR_RIGHT"] = "Direita"
    L["OPTIONS_ANCHOR_TARGET_SIDE"] = "De qual lado esse widget está preso."
    L["OPTIONS_ANCHOR_TOP"] = "Topo"
    L["OPTIONS_ANCHOR_TOPLEFT"] = "Canto Superior Esquerdo"
    L["OPTIONS_ANCHOR_TOPRIGHT"] = "Canto Superior Direito"
    L["OPTIONS_AURA_DEBUFF_HEIGHT"] = "Altura dos ícones de Debuff's."
    L["OPTIONS_AURA_DEBUFF_WITH"] = "Largura dos ícones de Debuff's."
    L["OPTIONS_AURA_HEIGHT"] = "Altura dos ícones de Debuff's."
    L["OPTIONS_AURA_SHOW_BUFFS"] = "Mostrar Buffs"
    L["OPTIONS_AURA_SHOW_BUFFS_DESC"] = "Mostrar seus buffs na sua barra pessoal."
    L["OPTIONS_AURA_SHOW_DEBUFFS"] = "Mostrar debuffs"
    L["OPTIONS_AURA_SHOW_DEBUFFS_DESC"] = "Mostrar seus debuffs na sua barra pessoal."
    L["OPTIONS_AURA_WIDTH"] = "Largura dos ícones de Debuff's."
    L["OPTIONS_AURAS_ENABLETEST"] = "Habilita para ocultar as auras de teste mostradas durante a configuração."
    L["OPTIONS_AURAS_SORT"] = "Organizar Áuras"
    L["OPTIONS_AURAS_SORT_DESC"] = "Auras são organizadas pelo tempo restante (padrão)."
    L["OPTIONS_BACKGROUND_ALWAYSSHOW"] = "Sempre Mostrar o Fundo"
    L["OPTIONS_BACKGROUND_ALWAYSSHOW_DESC"] = "Habilita um plano de fundo mostrando a área clicável."
    L["OPTIONS_BORDER_COLOR"] = "Cor das Bordas"
    L["OPTIONS_BORDER_THICKNESS"] = "Grossura das Bordas"
    L["OPTIONS_BUFFFRAMES"] = "Moldura do Buff"
    L["OPTIONS_CANCEL"] = "Cancelar"
    L["OPTIONS_CASTBAR_HEIGHT"] = "Altura da Barra de Lançamento."
    L["OPTIONS_CASTBAR_HIDEBLIZZARD"] = "Ocultar Barra de Lançamento de Jogadores da Blizzard"
    L["OPTIONS_CASTBAR_WIDTH"] = "Largura da barra de lançamento."
    L["OPTIONS_CLICK_SPACE_HEIGHT"] = "A altura da área que aceita mouse cliques para selecionar o alvo"
    L["OPTIONS_CLICK_SPACE_WIDTH"] = "A largura da área que aceita mouse cliques para selecionar o alvo"
    L["OPTIONS_COLOR"] = "Cor"
    L["OPTIONS_CVAR_ENABLE_PERSONAL_BAR"] = "Barra de Vida e Mana Pessoal|cFFFF7700*|r"
    L["OPTIONS_CVAR_ENABLE_PERSONAL_BAR_DESC"] = [=[Mostra uma mini barra de vida e mana abaixo do seu personagem.

        |cFFFF7700[*]|r |cFFa0a0a0CVar, salvo no perfil do Plater e restaurado quando o perfil for carregado.|r]=]
    L["OPTIONS_CVAR_NAMEPLATES_ALWAYSSHOW"] = "Sempre Mostrar Placas Identificadoras|cFFFF7700*|r"
    L["OPTIONS_CVAR_NAMEPLATES_ALWAYSSHOW_DESC"] =
    [=[Mostrar as placas identificadoras de todas as unidades próximas a você. Se desativar, somente mostrará as placas de unidades relevantes em combate.

        |cFFFF7700[*]|r |cFFa0a0a0CVar, salvo no perfil do Plater e restaurado quando o perfil é carregado.|r]=]
    L["OPTIONS_ENABLED"] = "Habilitado"
    L["OPTIONS_ERROR_CVARMODIFY"] = "cvars não podem ser alterados em combate."
    L["OPTIONS_ERROR_EXPORTSTRINGERROR"] = "falha ao exportar"
    L["OPTIONS_EXECUTERANGE"] = "Alcance de Execução"
    L["OPTIONS_EXECUTERANGE_DESC"] = [=[Mostra um indicador quando a unidade alvo está no alcance do 'execute'.

        Se detectar que não está funcionando após um patch, comunique no Discord.]=]
    L["OPTIONS_EXECUTERANGE_HIGH_HEALTH"] = "Alcance do Execute (cura alta)"
    L["OPTIONS_EXECUTERANGE_HIGH_HEALTH_DESC"] = [=[Mostra o indicador do execute para uma alta porção de vida.

        Se detectar que não está funcionando após um patch, comunique no Discord.]=]
    L["OPTIONS_FONT"] = "Fonte"
    L["OPTIONS_FORMAT_NUMBER"] = "Número da Fonte"
    L["OPTIONS_FRIENDLY"] = "Amigável"
    L["OPTIONS_GENERALSETTINGS_HEALTHBAR_ANCHOR_TITLE"] = "Aparência da Barra de Saúde"
    L["OPTIONS_GENERALSETTINGS_HEALTHBAR_BGCOLOR"] = "Cor de Fundo da Barra de Saúde e Alfa"
    L["OPTIONS_GENERALSETTINGS_HEALTHBAR_BGTEXTURE"] = "Textura de Fundo da Barra de Saúde"
    L["OPTIONS_GENERALSETTINGS_HEALTHBAR_TEXTURE"] = "Textura da Barra de Saúde"
    L["OPTIONS_GENERALSETTINGS_TRANSPARENCY_ANCHOR_TITLE"] = "A transparência é usada para"
    L["OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK"] = "Verificação de Alcance"
    L["OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK_ALPHA"] = "Alfa"
    L["OPTIONS_GENERALSETTINGS_TRANSPARENCY_RANGECHECK_SPEC_DESC"] =
    "Verificação de alcance para para feitiço nessa especialização."
    L["OPTIONS_HEALTHBAR"] = "Barra de Saúde"
    L["OPTIONS_HEALTHBAR_HEIGHT"] = "Altura da Barra de Saúde"
    L["OPTIONS_HEALTHBAR_SIZE_GLOBAL_DESC"] =
    [=[Alterar o tamanho das placas de identificação de inimigos e amigos para jogadores e NPCs em combate e fora de combate.

        Cada uma dessas opções pode ser alterada individualmente nas abas Enemy Npc, Enemy Player.]=]
    L["OPTIONS_HEALTHBAR_WIDTH"] = "Largura da Barra de Saúde"
    L["OPTIONS_HEIGHT"] = "Altura"
    L["OPTIONS_HOSTILE"] = "Hostilidade"
    L["OPTIONS_ICON_ELITE"] = "Ícone de Elite"
    L["OPTIONS_ICON_ENEMYCLASS"] = "Ícone de Classe Inimiga"
    L["OPTIONS_ICON_ENEMYFACTION"] = "Ícone de Facção Inimiga"
    L["OPTIONS_ICON_ENEMYSPEC"] = "Ícone de Spec Inimiga"
    L["OPTIONS_ICON_FRIENDLY_SPEC"] = "Ícone de Spec Aliada"
    L["OPTIONS_ICON_FRIENDLYCLASS"] = "Classe Aliada"
    L["OPTIONS_ICON_FRIENDLYFACTION"] = "Ícone de Facção Aliado"
    L["OPTIONS_ICON_PET"] = "Ícone de Pet"
    L["OPTIONS_ICON_QUEST"] = "Ícone de Quest"
    L["OPTIONS_ICON_RARE"] = "Ícone de Raros"
    L["OPTIONS_ICON_WORLDBOSS"] = "Ícone de Chefe Mundial"
    L["OPTIONS_ICONROWSPACING"] = "Espaçamento de Linha do Ícone"
    L["OPTIONS_ICONSPACING"] = "Espaçamento do Ícone"
    L["OPTIONS_INDICATORS"] = "Indicadores"
    L["OPTIONS_INTERACT_OBJECT_NAME_COLOR"] = "Cor do nome do objeto do jogo"
    L["OPTIONS_INTERACT_OBJECT_NAME_COLOR_DESC"] = "Nomes nesses objetos receberão esta cor."
    L["OPTIONS_MINOR_SCALE_DESC"] =
    "Ajuste ligeiramente o tamanho das placas de identificação ao exibir uma unidade menor (essas unidades têm uma placa de identificação menor por padrão)."
    L["OPTIONS_MINOR_SCALE_HEIGHT"] = "Escala de altura de unidade menor"
    L["OPTIONS_MINOR_SCALE_WIDTH"] = "Escala de largura de unidade menor"
    L["OPTIONS_MOVE_HORIZONTAL"] = "Move horizontalmente."
    L["OPTIONS_MOVE_VERTICAL"] = "Move verticalmente."
    L["OPTIONS_NAMEPLATE_HIDE_FRIENDLY_HEALTH"] = "Esconde a Barra de Vida da Blizzard|cFFFF7700*|r"
    L["OPTIONS_NAMEPLATE_HIDE_FRIENDLY_HEALTH_DESC"] =
    [=[Enquanto estiver em masmorras ou raids, se as placas de identificação de aliados ​​estiverem habilitadas, ele mostrará apenas o nome do jogador.
        Se algum modulo do Plater estiver desabilitado, isso irá afetar os efeitos dessas placas de identificação também.

        |cFFFF7700[*]|r |cFFa0a0a0CVar, salvo no perfil do Plater e restaurado quando o perfil é carregado.|r

        |cFFFF2200[*]|r |cFFa0a0a0A /reload pode ser necessario para aplicar os efeitos.|r]=]
    L["OPTIONS_NAMEPLATE_OFFSET"] = "Ajuste ligeiramente toda a placa de identificação"
    L["OPTIONS_NAMEPLATE_SHOW_ENEMY"] = "Mostra as Placas de Identificação|cFFFF7700*|r"
    L["OPTIONS_NAMEPLATE_SHOW_ENEMY_DESC"] = [=[Mostrar placa de identificação para unidades inimigas e neutras.

        |cFFFF7700[*]|r |cFFa0a0a0CVar, salvo no perfil do Plater e restaurado quando o perfil é carregado.|r]=]
    L["OPTIONS_NAMEPLATE_SHOW_FRIENDLY"] = "Mostra Placas de Identificação de Aliados|cFFFF7700*|r"
    L["OPTIONS_NAMEPLATE_SHOW_FRIENDLY_DESC"] = [=[Mostra placas de identificação para jogadores aliados.

        |cFFFF7700[*]|r |cFFa0a0a0CVar, salvo no perfil do Plater e restaurado quando o perfil é carregado.|r]=]
    L["OPTIONS_NAMEPLATES_OVERLAP"] = "Placas de Identificação Sobreposta (V)|cFFFF7700*|r"
    L["OPTIONS_NAMEPLATES_OVERLAP_DESC"] = [=[The space between each nameplate vertically when stacking is enabled.

        |cFFFFFFFFDefault: 1.10|r

        |cFFFF7700[*]|r |cFFa0a0a0CVar, salvo no perfil do Plater e restaurado quando o perfil é carregado.|r

        |cFFFFFF00Important |r: se você encontrar problemas com essa configuração, use:
        |cFFFFFFFF/run SetCVar ('nameplateOverlapV', '1.6')|r]=]
    L["OPTIONS_NAMEPLATES_STACKING"] = "Empilhar Placas de Identificação|cFFFF7700*|r"
    L["OPTIONS_NAMEPLATES_STACKING_DESC"] = [=[Se habilitar, as placas de identificação não irão se sobrepor.

        |cFFFF7700[*]|r |cFFa0a0a0CVar, salvo no perfil do Plater e restaurado quando o perfil é carregado.|r

        |cFFFFFF00Important |r: para definir a quantidade de espaços em cada placa de idenificação, veja '|cFFFFFFFFPreenchimento Vertical de Placas de Identificação|r' opções abaixo.
        Verifique as configurações da aba automática para configurar a alternância desta opção.]=]
    L["OPTIONS_NEUTRAL"] = "Neutro"
    L["OPTIONS_NOCOMBATALPHA_AMOUNT_DESC"] = "Quantidade de transparência para 'No Combat Alpha'."
    L["OPTIONS_NOCOMBATALPHA_ENABLED"] = "Usa Alfa Fora de Combate"
    L["OPTIONS_NOCOMBATALPHA_ENABLED_DESC"] =
    [=[Altere a placa de identificação Alfa quando você está em combate e a unidade não está.

        |cFFFFFF00 Importante |r:se a unidade não estiver em combate, ela sobescreve o alfa do alcance de verificação.]=]
    L["OPTIONS_OKAY"] = "Certo"
    L["OPTIONS_OUTLINE"] = "Contorno"
    L["OPTIONS_PERSONAL_HEALTHBAR_HEIGHT"] = "Altura da barra de vida."
    L["OPTIONS_PERSONAL_HEALTHBAR_WIDTH"] = "Largura da barra de vida."
    L["OPTIONS_PERSONAL_SHOW_HEALTHBAR"] = "Mostrar barra de vida."
    L["OPTIONS_PET_SCALE_DESC"] =
    "Ajusta ligeiramente o tamanho das placas de identificação ao mostrar um animal de estimação(pet)"
    L["OPTIONS_PET_SCALE_HEIGHT"] = "Escala de altura para animais de estimação(Pet)"
    L["OPTIONS_PET_SCALE_WIDTH"] = "Escala de largura para animais de estimação(Pet)"
    L["OPTIONS_PLEASEWAIT"] = "Isso pode levar apenas alguns segundos"
    L["OPTIONS_POWERBAR"] = "Barra de Força"
    L["OPTIONS_POWERBAR_HEIGHT"] = "Altura da barra de força."
    L["OPTIONS_POWERBAR_WIDTH"] = "Largura da barra de força."
    L["OPTIONS_PROFILE_CONFIG_EXPORTINGTASK"] = "O Plater está exportando o perfil atual"
    L["OPTIONS_PROFILE_CONFIG_EXPORTPROFILE"] = "Compartilhar Perfil"
    L["OPTIONS_PROFILE_CONFIG_IMPORTPROFILE"] = "Importar Perfil"
    L["OPTIONS_PROFILE_CONFIG_MOREPROFILES"] = "Buscar mais perfis em Wago.io"
    L["OPTIONS_PROFILE_CONFIG_OPENSETTINGS"] = "Abrir Configuração de Perfil"
    L["OPTIONS_PROFILE_CONFIG_PROFILENAME"] = "Novo nome para um Perfil"
    L["OPTIONS_PROFILE_CONFIG_PROFILENAME_DESC"] = [=[Um novo perfil foi criado com o código importado.

        Inserir um nome de perfil que ja existe, irá sobrescreve-lo.]=]
    L["OPTIONS_PROFILE_ERROR_PROFILENAME"] = "Nome de perfil inválido"
    L["OPTIONS_PROFILE_ERROR_STRINGINVALID"] = "Arquivo de perfil inválido."
    L["OPTIONS_PROFILE_ERROR_WRONGTAB"] = [=[Dados de perfil inválido.

        Importar scripts ou mods na aba de scripts ou modding.]=]
    L["OPTIONS_PROFILE_IMPORT_OVERWRITE"] = "O perfil '%s' já existe, quer substituir?"
    L["OPTIONS_RANGECHECK_NONE"] = "Nada"
    L["OPTIONS_RANGECHECK_NONE_DESC"] = "Nenhuma modificação de alfa foi aplicada."
    L["OPTIONS_RANGECHECK_NOTMYTARGET"] = "Unidades Que Não São Seu Alvo"
    L["OPTIONS_RANGECHECK_NOTMYTARGET_DESC"] = "Quando uma placa de identificação não é o seu alvo, o alfa é reduzido."
    L["OPTIONS_RANGECHECK_NOTMYTARGETOUTOFRANGE"] = "Fora de Alcance + Não é o Seu Alvo"
    L["OPTIONS_RANGECHECK_NOTMYTARGETOUTOFRANGE_DESC"] = [=[Reduz o alvo de unidades que não são o seu alvo.
        Reduz ainda mais de unidades que estão fora de alcance.]=]
    L["OPTIONS_RANGECHECK_OUTOFRANGE"] = "Unidades Fora do Seu Alcance"
    L["OPTIONS_RANGECHECK_OUTOFRANGE_DESC"] = "Quando a placa de identificação está fora de alcance, o alfa é reduzido."
    L["OPTIONS_RESOURCES_TARGET"] = "Mostra os Recursos do Alvo"
    L["OPTIONS_RESOURCES_TARGET_DESC"] = [=[Mostra seu recurso, como pontos de combinação acima do seu alvo atual.
        Usa os recrusos padrão da Blizzard e desabilita os recursos próprios do Plater.

        Configuração específica do personagem!]=]
    L["OPTIONS_SCALE"] = "Escala"
    L["OPTIONS_SCRIPTING_REAPPLY"] = "Aplicar Novamente os Valores Padrão"
    L["OPTIONS_SCRIPTING_ADDOPTION"] = "Selecione quais opções para adicionar"
    L["OPTIONS_SETTINGS_COPIED"] = "configuração copiada."
    L["OPTIONS_SETTINGS_FAIL_COPIED"] = "Falha ao obter as configurações a guia selecionada atual."
    L["OPTIONS_SHADOWCOLOR"] = "Cor das Sombras"
    L["OPTIONS_SHIELD_BAR"] = "Barra de Escudo"
    L["OPTIONS_SHOW_CASTBAR"] = "Mostrar barra de lançamento"
    L["OPTIONS_SHOW_POWERBAR"] = "Mostrar barra de força"
    L["OPTIONS_SHOWTOOLTIP"] = "Mostrar Informações"
    L["OPTIONS_SHOWTOOLTIP_DESC"] = "Mostrar informações ao passar o mouse sobre o ícone da aurea."
    L["OPTIONS_SIZE"] = "Tamanho"
    L["OPTIONS_STACK_AURATIME"] = "mostrar o menor tempo das auras empilhadas"
    L["OPTIONS_STACK_AURATIME_DESC"] = "Exibe o menor tempo de auras acumuladas ou o maior tempo, quando desativado"
    L["OPTIONS_STACK_SIMILAR_AURAS"] = "Empilha auras similares"
    L["OPTIONS_STACK_SIMILAR_AURAS_DESC"] =
    "Auras com o mesmo nome (e.g. warlock's unstable affliction debuff) serão empilhadas juntas."
    L["OPTIONS_STATUSBAR_TEXT"] =
    "Importar perfis, mods, scripts, animações e tabelas de cores de |cFFFFAA00http://wago.io|r"
    L["OPTIONS_TABNAME_ADVANCED"] = "Avançado"
    L["OPTIONS_TABNAME_ANIMATIONS"] = "Retorno do Feitiço"
    L["OPTIONS_TABNAME_AUTO"] = "Auto"
    L["OPTIONS_TABNAME_BUFF_LIST"] = "Lista de Feitiço"
    L["OPTIONS_TABNAME_BUFF_SETTINGS"] = "Configuração de Buff"
    L["OPTIONS_TABNAME_BUFF_SPECIAL"] = "Buff Especial"
    L["OPTIONS_TABNAME_BUFF_TRACKING"] = "Rastreio de Buff"
    L["OPTIONS_TABNAME_CASTBAR"] = "Barra de Lançamento"
    L["OPTIONS_TABNAME_CASTCOLORS"] = "Cor e Nome dos Lançamentos"
    L["OPTIONS_TABNAME_COMBOPOINTS"] = "Combinação de Pontos"
    L["OPTIONS_TABNAME_GENERALSETTINGS"] = "Configurações Gerais"
    L["OPTIONS_TABNAME_MODDING"] = "Modificação"
    L["OPTIONS_TABNAME_NPC_COLORNAME"] = "Cores e Nomes de Npc"
    L["OPTIONS_TABNAME_NPCENEMY"] = "Npc Inimigos"
    L["OPTIONS_TABNAME_NPCFRIENDLY"] = "Npc Aliado"
    L["OPTIONS_TABNAME_PERSONAL"] = "Barra Pessoal"
    L["OPTIONS_TABNAME_PLAYERENEMY"] = "Jogador Inimigo"
    L["OPTIONS_TABNAME_PLAYERFRIENDLY"] = "Jogador Aliado"
    L["OPTIONS_TABNAME_PROFILES"] = "Perfis"
    L["OPTIONS_TABNAME_SCRIPTING"] = "Scripting"
    L["OPTIONS_TABNAME_SEARCH"] = "Busca"
    L["OPTIONS_TABNAME_STRATA"] = "Nível e Estrato"
    L["OPTIONS_TABNAME_TARGET"] = "Alvo"
    L["OPTIONS_TABNAME_THREAT"] = "Cores / Ameaça"
    L["OPTIONS_TEXT_COLOR"] = "A cor do texto."
    L["OPTIONS_TEXT_FONT"] = "Fonte do texto."
    L["OPTIONS_TEXT_SIZE"] = "Tamanho do texto."
    L["OPTIONS_TEXTURE"] = "Textura"
    L["OPTIONS_THREAT_AGGROSTATE_ANOTHERTANK"] = "Aggro em outro Tanque"
    L["OPTIONS_THREAT_AGGROSTATE_HIGHTHREAT"] = "Ameaça Alta"
    L["OPTIONS_THREAT_AGGROSTATE_NOAGGRO"] = "Sem Aggro"
    L["OPTIONS_THREAT_AGGROSTATE_NOTANK"] = "Tanque sem Aggro"
    L["OPTIONS_THREAT_AGGROSTATE_NOTINCOMBAT"] = "Unidade fora de Combate"
    L["OPTIONS_THREAT_AGGROSTATE_ONYOU_LOWAGGRO"] = "Aggro em você, mas é baixo"
    L["OPTIONS_THREAT_AGGROSTATE_ONYOU_LOWAGGRO_DESC"] =
    "A unidade está atacando você, mas outros estão prestes a puxar o aggro"
    L["OPTIONS_THREAT_AGGROSTATE_ONYOU_SOLID"] = "Aggro em Você"
    L["OPTIONS_THREAT_AGGROSTATE_TAPPED"] = "Unidade Abatida"
    L["OPTIONS_THREAT_COLOR_DPS_ANCHOR_TITLE"] = "Cor quando o Jogador é DPS ou HEALER"
    L["OPTIONS_THREAT_COLOR_DPS_HIGHTHREAT_DESC"] = "A unidade esta prestes a atacar você."
    L["OPTIONS_THREAT_COLOR_DPS_NOAGGRO_DESC"] = "A unidade não está atacando você."
    L["OPTIONS_THREAT_COLOR_DPS_NOTANK_DESC"] =
    "A unidade não está atacando você ou um tanque e provavelmente está atacando outro HEAL ou DPS do seu grupo."
    L["OPTIONS_THREAT_COLOR_DPS_ONYOU_SOLID_DESC"] = "A unidade está atacando você."
    L["OPTIONS_THREAT_COLOR_OVERRIDE_ANCHOR_TITLE"] = "Sobrecreve as Cores Padrões"
    L["OPTIONS_THREAT_COLOR_OVERRIDE_DESC"] =
    [=[Modifique as cores padrão definidas pelo jogo para unidades neutras, hostis e amigáveis.

        Durante o combate, essas cores irão sobrescrever também se as cores de ameaça permitir mudar a cor da barra.]=]
    L["OPTIONS_THREAT_COLOR_TANK_ANCHOR_TITLE"] = "Cores quando você joga de TANQUE"
    L["OPTIONS_THREAT_COLOR_TANK_ANOTHERTANK_DESC"] = "A unidade está sendo tancada por outro tanque do seu grupo."
    L["OPTIONS_THREAT_COLOR_TANK_NOAGGRO_DESC"] = "A unidade não está com o aggro em você."
    L["OPTIONS_THREAT_COLOR_TANK_NOTINCOMBAT_DESC"] = "A unidade não está em combate."
    L["OPTIONS_THREAT_COLOR_TANK_ONYOU_SOLID_DESC"] = "A unidade está de atacando e você está com um aggro sólido."
    L["OPTIONS_THREAT_COLOR_TAPPED_DESC"] =
    "Quando outra pessoa reivindicou a unidade (quando você não recebe experiência ou saque por matá-la)"
    L["OPTIONS_THREAT_DPS_CANCHECKNOTANK"] = "Verifique se o Tanque está sem aggro"
    L["OPTIONS_THREAT_DPS_CANCHECKNOTANK_DESC"] =
    "Quando você não tem aggro como healer ou dps, verifique se o inimigo está atacando outra unidade que não seja um tanque"
    L["OPTIONS_THREAT_MODIFIERS_ANCHOR_TITLE"] = "Modificações da Ameaça"
    L["OPTIONS_THREAT_MODIFIERS_BORDERCOLOR"] = "Cor da Borda"
    L["OPTIONS_THREAT_MODIFIERS_HEALTHBARCOLOR"] = "Cor da Barra de Saúde"
    L["OPTIONS_THREAT_MODIFIERS_NAMECOLOR"] = "Nome da Cor"
    L["OPTIONS_TOGGLE_TO_CHANGE"] =
    "|cFFFFFF00 Importante |r: ocultar e mostrar as placas de identificação para ver as alterações."
    L["OPTIONS_WIDTH"] = "Largura"
    L["OPTIONS_XOFFSET"] = "X Offset"
    L["OPTIONS_XOFFSET_DESC"] = [=[Ajuste a posição do eixo X.

        *clique com botão direito para digitar um valor.]=]
    L["OPTIONS_YOFFSET"] = "Y Offset"
    L["OPTIONS_YOFFSET_DESC"] = [=[Ajuste a posição do eixo Y.

        *clique com botão direito para digitar um valor.]=]
    L["TARGET_CVAR_ALWAYSONSCREEN"] = "Alvo Sempre na Tela|cFFFF7700*|r"
    L["TARGET_CVAR_ALWAYSONSCREEN_DESC"] =
    [=[Quando habilitado, a placa de identificação do seu alvo é sempre exibida, mesmo que o inimigo não esteja na tela.

        |cFFFF7700[*]|r |cFFa0a0a0CVar, salvo no perfil do Plater e restaurado quando o perfil é carregado.|r]=]
    L["TARGET_CVAR_LOCKTOSCREEN"] = "Bloqueio de Tela (Lado Superior)|cFFFF7700*|r"
    L["TARGET_CVAR_LOCKTOSCREEN_DESC"] =
    [=[Espaço mínimo entre as placas de identificação e o topo da tela. Aumente se alguma parte das placa identificadora estiver ficando fora da tela.

        |cFFFFFFFFDefault: 0.065|r

        |cFFFFFF00 Important |r: se você tiver problemas, defina manualmente usando essas macros:
        /run SetCVar ('nameplateOtherTopInset', '0.065')
        /run SetCVar ('nameplateLargeTopInset', '0.065')

        |cFFFFFF00 Importante |r: configurar para 0 desabilita essa funcionalidade.

        |cFFFF7700[*]|r |cFFa0a0a0CVar, salvo no perfil do Plater e restaurado quando o perfil é carregado.|r]=]
    L["TARGET_HIGHLIGHT"] = "Destaque do Alvo"
    L["TARGET_HIGHLIGHT_ALPHA"] = "Destaque Alfa do Alvo"
    L["TARGET_HIGHLIGHT_COLOR"] = "Cor de Destaque do Alvo"
    L["TARGET_HIGHLIGHT_DESC"] = "Destaque os efeitos da placa de identificação do seu alvo atual."
    L["TARGET_HIGHLIGHT_TEXTURE"] = "Textura de Destaque do Alvo"
    L["TARGET_OVERLAY_ALPHA"] = "Textura de Sobreposição Alfa"
    L["TARGET_OVERLAY_TEXTURE"] = "Textura de Sobreposição de Alvo"
    L["TARGET_OVERLAY_TEXTURE_DESC"] = "Usado acima da barra de saúde quando é o alvo atual."
    ------------------------------------------------------------
    --@localization(locale="ptBR", format="lua_additive_table")@
end
