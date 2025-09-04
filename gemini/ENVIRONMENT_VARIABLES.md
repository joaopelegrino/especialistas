# Variáveis de Ambiente

O Gemini CLI utiliza variáveis de ambiente para configurar algumas de suas funcionalidades.

## Variáveis Importantes

- `GEMINI_API_KEY`: Chave de API para acesso à API do Gemini.
- `GEMINI_CONFIG_DIR`: Caminho para a pasta de configuração do Gemini CLI.

## Dicas

- **Segurança:** Não armazene a chave de API diretamente no código. Utilize um arquivo `.env` ou um gerenciador de segredos para carregar a chave de API como uma variável de ambiente.
- **Flexibilidade:** Utilize variáveis de ambiente para tornar suas configurações mais flexíveis e portáteis.
