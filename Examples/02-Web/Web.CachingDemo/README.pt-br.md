# 💾 Web.CachingDemo - Cache de Resposta

Este exemplo demonstra o **Middleware de Response Caching** no Dext Framework.

O cache de resposta permite armazenar respostas geradas em memória (ou outros armazenamentos) e servi-las para requisições subsequentes, melhorando significativamente o desempenho para endpoints de leitura frequente.

---

## ✨ Funcionalidades Demonstradas

- **Cache de Resposta**: Cacheamento de respostas de endpoint por uma duração específica.
- **Vary By Query**: Entradas de cache diferentes baseadas em parâmetros da query string.
- **Headers de Cache**: Tratamento automático dos headers `X-Cache` e `Cache-Control`.
- **Configuração Fluente**: API moderna para configurar o comportamento do cache.

---

## 🚀 Quick Start

### 1. Build do Projeto
Abra `Web.CachingDemo.dproj` no Delphi e compile (ou use MSBuild).

### 2. Executar Testes Automatizados
Usando PowerShell:
```powershell
.\Test.Web.CachingDemo.ps1
```

### 3. Teste Manual
Inicie o servidor:
```bash
Web.CachingDemo.exe
```

Teste com curl:
```bash
# Primeira requisição (MISS - Gera resposta)
curl -v http://localhost:8080/api/time

# Segunda requisição (HIT - Retorna resposta em cache)
curl -v http://localhost:8080/api/time

# Aguarde 30 segundos...
# Terceira requisição (MISS - Expirado, regenera)
curl -v http://localhost:8080/api/time
```

---

## 💡 Exemplo de Código

```pascal
// Configurar Caching
TApplicationBuilderCacheExtensions.UseResponseCache(Builder,
  procedure(Cache: TResponseCacheBuilder)
  begin
    Cache
      .WithDefaultDuration(30)
      .VaryByQueryString;
  end);

// Mapear Endpoint com Cache
Builder.MapGet('/api/time',
  procedure(Ctx: IHttpContext)
  begin
    // Operação custosa...
    Ctx.Response.Json(Format('{"time":"%s"}', [TimeToStr(Now)]));
  end);
```
