# Exemplo de Autenticação JWT

Uma demonstração de autenticação stateless usando JSON Web Tokens (JWT) no Dext Framework.

## 🚀 Funcionalidades

*   **Middleware JWT**: `TApplicationBuilderJwtExtensions.UseJwtAuthentication` valida tokens automaticamente
*   **Geração de Token**: Criação de tokens assinados com Claims (Roles, Nome, Email) usando `TJwtTokenHandler`
*   **Claims Builder**: API fluente para criar claims com `TClaimsBuilder`
*   **Endpoints Protegidos**: Proteção de rotas verificando `User.Identity.IsAuthenticated`
*   **Controle de Acesso Baseado em Função (RBAC)**: Restrição de acesso a roles usando `User.IsInRole`
*   **Extração de Claims**: Leitura de claims personalizados do payload do token

## 🛠️ Como Iniciar

1.  **Compile** `Web.JwtAuthDemo.dproj`
2.  **Execute** `Web.JwtAuthDemo.exe`
    *   O servidor inicia em **http://localhost:8080**
3.  **Teste**:
    ```powershell
    .\Test.Web.JwtAuthDemo.ps1
    ```

## 🔐 Endpoints

| Endpoint | Auth | Descrição |
|----------|------|-----------|
| `POST /api/auth/login` | Público | Autentica usuário e retorna token JWT |
| `GET /api/public` | Público | Acessível sem token |
| `GET /api/protected` | Bearer Token | Requer JWT válido no header `Authorization` |
| `GET /api/admin` | Bearer Token + Role | Requer token E role **Admin** |

## 📖 Exemplos de Código

### Configurando Middleware JWT

```pascal
// Adicionar middleware de autenticação JWT
TApplicationBuilderJwtExtensions.UseJwtAuthentication(
  Builder, 
  TJwtOptions.Create(SecretKey)
);
```

### Endpoint de Login (Geração de Token)

```pascal
TApplicationBuilderExtensions.MapPostR<TLoginRequest, IResult>(Builder, '/api/auth/login',
  function(Request: TLoginRequest): IResult
  var
    Claims: TArray<TClaim>;
    Token: string;
  begin
    if (Request.Username = 'admin') and (Request.Password = 'password') then
    begin
      // Criar claims usando API fluente
      Claims := TClaimsBuilder.Create
        .WithNameIdentifier('123')
        .WithName(Request.Username)
        .WithRole('Admin')
        .WithEmail('admin@example.com')
        .Build;

      Token := JwtHandler.GenerateToken(Claims);
      Result := Results.Ok(Format('{"token":"%s"}', [Token]));
    end
    else
      Result := Results.BadRequest('{"error":"Credenciais inválidas"}');
  end);
```

### Endpoint Protegido

```pascal
TApplicationBuilderExtensions.MapGetR<IHttpContext, IResult>(Builder, '/api/protected',
  function(Context: IHttpContext): IResult
  begin
    if (Context.User = nil) or not Context.User.Identity.IsAuthenticated then
      Exit(Results.StatusCode(401, '{"error":"Não autorizado"}'));

    Result := Results.Ok(Format('{"user":"%s"}', [Context.User.Identity.Name]));
  end);
```

### Autorização Baseada em Role

```pascal
// Verificar se o usuário tem role Admin
if not Context.User.IsInRole('Admin') then
  Exit(Results.StatusCode(403, '{"error":"Proibido"}'));
```

## 🧪 Testando com cURL

```bash
# 1. Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password"}'

# 2. Acessar endpoint protegido
curl http://localhost:8080/api/protected \
  -H "Authorization: Bearer SEU_TOKEN"

# 3. Acessar endpoint admin
curl http://localhost:8080/api/admin \
  -H "Authorization: Bearer SEU_TOKEN"
```

## 📚 Veja Também

- [Guia de Autenticação JWT](../../Docs/jwt-authentication.md) - Documentação completa
- [Exemplos de Claims Builder](../../Docs/claims-builder-examples.md) - Uso avançado de claims
- [Web.ControllerExample](../Web.ControllerExample) - Controllers com atributo `[Authorize]`
