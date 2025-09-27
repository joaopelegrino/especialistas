# Disclaimers Obrigatórios - Versão Final

## Disclaimer Principal (Obrigatório em todos os conteúdos)
```html
<div class="disclaimer-principal">
    <h4>⚠️ Informações Importantes</h4>
    <p>Este conteúdo é de caráter educativo e informativo e não substitui a consulta médica profissional. O diagnóstico e tratamento de qualquer condição de saúde devem ser realizados por profissionais habilitados. Sempre procure orientação médica para questões relacionadas à sua saúde.</p>
</div>
```

## Disclaimer CFM (Para conteúdo médico)
```html
<div class="disclaimer-cfm">
    <p><strong>Disclaimer CFM:</strong> As informações médicas apresentadas têm caráter educativo e não substituem a consulta presencial com médico especializado. Este profissional é registrado no Conselho Regional de Medicina (CRM) sob o número [CRM]. Para diagnóstico e tratamento adequados, agende uma consulta médica.</p>
</div>
```

## Disclaimer CRP (Para conteúdo psicológico)
```html
<div class="disclaimer-crp">
    <p><strong>Disclaimer CRP:</strong> O conteúdo sobre saúde mental tem finalidade educativa e não substitui o acompanhamento psicológico profissional. Este profissional é registrado no Conselho Regional de Psicologia (CRP) sob o número [CRP]. Para questões de saúde mental, procure um psicólogo qualificado.</p>
</div>
```

## Disclaimer ANVISA (Para procedimentos/medicamentos)
```html
<div class="disclaimer-anvisa">
    <p><strong>Disclaimer ANVISA:</strong> Procedimentos médicos e uso de medicamentos devem ser realizados exclusivamente por profissionais habilitados. Este estabelecimento é regularizado junto à ANVISA. Não pratique automedicação ou procedimentos sem supervisão profissional adequada.</p>
</div>
```

## Disclaimer Resultados (Para todos os conteúdos)
```html
<div class="disclaimer-resultados">
    <p><strong>Sobre Resultados:</strong> Os resultados podem variar individualmente e dependem de diversos fatores incluindo histórico médico, idade, estilo de vida e adesão ao tratamento. Não há garantia de resultados específicos. Consulte sempre um profissional para avaliar seu caso particular.</p>
</div>
```

## Disclaimer Emergência (Para conteúdo de saúde)
```html
<div class="disclaimer-emergencia">
    <p><strong>Em Caso de Emergência:</strong> Em situações de emergência médica, procure imediatamente um pronto-socorro ou ligue para o SAMU (192). Este conteúdo não oferece orientações para situações de urgência ou emergência médica.</p>
</div>
```

## Posicionamento dos Disclaimers
### Obrigatório no Início
- Disclaimer Principal (sempre)
- Disclaimer CFM/CRP (quando aplicável)

### Obrigatório no Final
- Disclaimer Resultados (sempre)
- Disclaimer Emergência (conteúdo médico)
- Disclaimer ANVISA (quando aplicável)

## Formato Visual
```css
.disclaimer-principal {
    background: #fff3cd;
    border-left: 4px solid #ffc107;
    padding: 15px;
    margin: 20px 0;
    border-radius: 4px;
}

.disclaimer-cfm, .disclaimer-crp, .disclaimer-anvisa {
    background: #e7f3ff;
    border: 1px solid #bee5eb;
    padding: 12px;
    margin: 15px 0;
    border-radius: 4px;
    font-size: 14px;
}

.disclaimer-resultados, .disclaimer-emergencia {
    background: #f8f9fa;
    border: 1px solid #dee2e6;
    padding: 12px;
    margin: 15px 0;
    border-radius: 4px;
    font-size: 14px;
}
```