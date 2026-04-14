# Exemplo DextStore

Um exemplo abrangente de uma Web API construída com o Dext Framework, demonstrando como estruturar uma aplicação do mundo real.

## 🚀 Funcionalidades

*   **MVC Controllers**: API estruturada usando atributos `[DextController]`, `[DextGet]`, `[DextPost]`.
*   **Injeção de Dependência**: Uso completo do container DI para Serviços, Repositórios e Controllers.
*   **Autenticação JWT**: Endpoints seguros usando `[Authorize]` e tokens Bearer.
*   **Fluent API**: Sintaxe de configuração moderna para Middleware (CORS, Auth).
*   **Model Binding**: Mapeamento automático de corpos JSON para DTOs.
*   **Camada de Serviço**: Separação lógica em `Services`, `Models` e `Controllers`.

## 🛠️ Como Iniciar

1.  **Compile** o projeto `Web.DextStore.dproj` usando Delphi ou MSBuild.
2.  **Execute** o executável `Web.DextStore.exe`.
    *   O servidor iniciará em **http://localhost:9000**.
3.  **Teste** a API usando os scripts fornecidos:
    *   **Teste Completo (Recomendado)**: Login -> Produtos -> Carrinho -> Checkout.
        ```powershell
        .\Test.Web.DextStore.Full.ps1
        ```
    *   **Suite da API**: Teste abrangente de endpoints individuais.
        ```powershell
        .\Test.Web.DextStore.Api.ps1
        ```
    *   **Check de Saúde**: Verificação rápida para ver se o servidor está online.
        ```powershell
        .\Test.Web.DextStore.Health.ps1
        ```

## 📂 Estrutura

*   **Web.DextStore.dpr**: Ponto de entrada da aplicação e configuração (DI, Middleware).
*   **DextStore.Controllers.pas**: Definição dos Endpoints da API.
*   **DextStore.Services.pas**: Lógica de negócios e armazenamento de dados em memória (banco simulado).
*   **DextStore.Models.pas**: Objetos de Transferência de Dados (DTOs) e Entidades.

## 🔐 Credenciais (Demo)

*   **Usuário**: `user`
*   **Senha**: `password`
