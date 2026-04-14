# Exemplo de SSL/HTTPS no Dext

Este exemplo demonstra como habilitar e configurar o suporte a SSL (HTTPS) em uma aplicação Web Dext.

## Pré-requisitos

1.  **Dext.inc**: Certifique-se de que `DEXT_ENABLE_SSL` esteja definido em `Sources\Dext.inc`.
2.  **Bibliotecas**:
    *   Para **OpenSSL (Padrão)**: Você precisa das DLLs `libeay32.dll` e `ssleay32.dll` (OpenSSL 1.0.2u ou compatível) na pasta da sua aplicação.
    *   Para **Taurus TLS**: Você precisa das bibliotecas do Taurus TLS e as DLLs corretas do OpenSSL 1.1.x/3.x conforme especificado pelo projeto Taurus. Certifique-se de que `DEXT_ENABLE_TAURUS_TLS` esteja definido em `Dext.inc`.
3.  **Certificados**: Você precisa de um arquivo de certificado (`.crt` ou `.pem`) e um arquivo de chave privada (`.key`). Para testes locais, você pode gerar certificados autoassinados.

## Configuração

O SSL é configurado através da seção `Server` no arquivo `appsettings.json`:

```json
{
  "Server": {
    "Port": 8080,
    "UseHttps": "true",
    "SslProvider": "OpenSSL",
    "SslCert": "server.crt",
    "SslKey": "server.key",
    "SslRootCert": ""
  }
}
```

### Detalhes das Configurações
*   `UseHttps`: `true` para habilitar SSL, `false` para usar apenas HTTP.
*   `SslProvider`: 
    *   `OpenSSL` (Padrão): Utiliza a implementação nativa de OpenSSL 1.0.x do Indy.
    *   `Taurus`: Utiliza a implementação Taurus TLS (suporta OpenSSL 1.1.x / 3.x).
*   `SslCert`: Caminho para o seu arquivo de certificado.
*   `SslKey`: Caminho para o seu arquivo de chave privada.
*   `SslRootCert`: (Opcional) Caminho para o certificado raiz / bundle.

## Gerando um Certificado Autoassinado (Dica Rápida)

Você pode usar o OpenSSL para gerar um certificado autoassinado para testes:

```bash
openssl req -x509 -newkey rsa:4096 -keyout server.key -out server.crt -days 365 -nodes
```

## Executando o Exemplo

1.  Compile o projeto.
2.  Certifique-se de que as DLLs e os arquivos `.crt`/`.key` estejam no mesmo diretório do executável.
3.  Execute a aplicação.
4.  Acesse `https://localhost:8080`.

## Testando

Execute o script de teste (testa modo HTTP por padrão):
```powershell
.\Test.Web.SslDemo.ps1
```

## 🔗 Veja Também

- [Documentação do Dext Framework](../../README.pt-br.md)
- [Web.JwtAuthDemo](../Web.JwtAuthDemo) - Exemplo de autenticação JWT

## Problemas Conhecidos

- **ERR_SSL_PROTOCOL_ERROR / ERR_TIMED_OUT**: Algumas combinações de Windows/Indy/DLLs OpenSSL podem falhar no handshake mesmo com a configuração correta. Isso geralmente se deve a incompatibilidade estrita de versão TLS ou arquitetura de DLL (32 vs 64 bits).
- Se encontrar problemas persistentes, tente testar com o provedor **Taurus TLS**, que permite usar versões modernas e suportadas do OpenSSL.
