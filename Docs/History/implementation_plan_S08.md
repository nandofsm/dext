# 📝 Plano de Implementação: Suporte a Porta 0 (S08)

Este plano detalha as alterações necessárias para suportar portas dinâmicas no Dext Framework, permitindo que o sistema operacional atribua uma porta livre automaticamente.

## 1. Problema
Atualmente, o Dext exige uma porta fixa ou assume valores padrão (5000/8080). Se a porta 0 é utilizada:
- O servidor faz o bind corretamente (o SO escolhe a porta), mas o framework não expõe qual porta foi escolhida.
- O log de console exibe `localhost:0`.
- Testes automatizados que rodam em paralelo sofrem conflitos de porta (Socket Error 10048).

## 2. Solução Proposta

### Phase 1: Evolução de Interfaces (`Sources/Web/Dext.Web.Interfaces.pas`)
- Adicionar `function GetPort: Integer;` à interface `IWebHost`.
- Adicionar propriedade `Port` à interface `IWebHost`.
- Adicionar propriedade `Port` à interface `IWebApplication`.

### Phase 2: Implementação no Adaptador Indy (`Sources/Web/Dext.Web.Indy.Server.pas`)
- Implementar `GetPort` em `TDextIndyWebServer`.
- No método `Start`, após ativar o `TIdHTTPServer`, verificar se a porta original era 0.
- Se for 0, recuperar a porta real via `FHTTPServer.Bindings[0].Port`.
- Atualizar o log de inicialização para mostrar a porta real.

### Phase 3: Integração no WebHost (`Sources/Web/Hosting/Dext.Web.WebApplication.pas`)
- Implementar a propriedade `Port` em `TWebApplication`, delegando para `FActiveHost.Port`.
- Garantir que métodos `Run` e `Start` aceitem 0 sem validações restritivas.

### Phase 4: Atualização da Base de Testes (`Tests/Web.FrameworkTests/WebFrameworkTests.Tests.Base.pas`)
- Alterar `FPort` padrão de `8081` para `0`.
- Após `FHost.Start`, atualizar `FPort := FHost.Port`.
- Isso garantirá que todos os testes existentes passem a usar portas dinâmicas, eliminando conflitos em CI.

## 3. Breaking Changes
- **IWebHost**: A adição de um membro à interface é um breaking change para compiladores Delphi que não usam interfaces fracas, mas como somos os donos do framework e todos os adaptadores (Indy, DCS, WebBroker) estão sob nosso controle, faremos a atualização em todos.

## 4. Arquivos a Modificar
- `Sources/Web/Dext.Web.Interfaces.pas`
- `Sources/Web/Dext.Web.Indy.Server.pas`
- `Sources/Web/Hosting/Dext.Web.WebApplication.pas`
- `Tests/Web.FrameworkTests/WebFrameworkTests.Tests.Base.pas`
- `Sources/Web/Dext.Web.WebBroker.pas` (para manter compatibilidade)

## 5. Plano de Testes
- **Teste de Unidade**: Criar `Dext.Web.Port.Tests.pas` verificando:
    1. Iniciar com porta 0.
    2. Verificar se `App.Port > 0`.
    3. Tentar conectar via `THttpClient` na porta retornada.
- **Teste de Regressão**: Executar `Web.FrameworkTests.dproj` completo.

---
*Assinado: Antigravity AI - 12 de Abril de 2026*
