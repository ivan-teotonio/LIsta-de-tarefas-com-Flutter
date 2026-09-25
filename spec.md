# Aplicativo Móvel de Tarefas — Especificação de Implementação

Você atuará como agente de codificação responsável pela implementação deste projeto.

Seu objetivo é construir um aplicativo móvel completo de tarefas, de acordo com a especificação abaixo.

Você pode escolher bibliotecas, estrutura de projeto, arquitetura e detalhes de implementação apropriados, a menos que sejam explicitamente restringidos.

No entanto, você DEVE documentar o processo de desenvolvimento continuamente em um arquivo chamado:

`BUILD_LOG.md`.

Não espere até o final do projeto para criar este arquivo.

Mantenha-o atualizado durante todo o desenvolvimento.

---

# 1. Requisito de Registro de Desenvolvimento

Crie o arquivo `BUILD_LOG.md` no início do projeto.

Para cada interação de desenvolvimento relevante, decisão, etapa de implementação, bug ou correção, adicione uma nova entrada.

Cada entrada deve conter:

## Solicitação/Requisição

Registre a solicitação do usuário que levou à alteração.

Preserve a redação original sempre que possível.

## Resumo da Decisão

Explique brevemente:

- o que você decidiu fazer;
- quais bibliotecas ou APIs você selecionou;
- decisões arquitetônicas importantes;
- suposições que você fez;
- alternativas consideradas, quando relevantes.

Forneça apenas um resumo conciso do raciocínio.

Não exponha o raciocínio oculto e privado.

## Ações Executadas

Descreva o que mudou.

Exemplos:

- arquivos criados;
- arquivos modificados;
- dependências instaladas;
- esquema do banco de dados alterado;
- navegação adicionada;
- suporte a notificações adicionado;
- componentes refatorados.

## Resultado

Descreva o resultado da alteração.

Exemplos:

- recurso implementado com sucesso;
- compilação bem-sucedida;
- compilação falhou;
- recurso funcionando parcialmente; -
  ocorreu um erro de tempo de execução;
- notificação não acionada.

## Problemas/Erros

Registre os seguintes problemas relevantes:

- erros de compilação;
- erros de tempo de execução;
- suposições incorretas;
- bugs;
- comportamento inesperado.

## Tentativas de Correção

Registre as tentativas feitas para resolver os problemas, incluindo as tentativas malsucedidas, quando relevantes.

## Status Atual

Marque o recurso ou etapa como um dos seguintes:

- Concluído
- Parcialmente concluído
- Quebrado
- Precisa de testes
- Bloqueado

O objetivo do `BUILD_LOG.md` é preservar o histórico real do desenvolvimento.

Não reescreva entradas anteriores apenas para fazer o processo de desenvolvimento parecer mais limpo.

Se uma decisão anterior se revelar incorreta, mantenha a entrada antiga e crie uma nova entrada descrevendo a correção.

---

# 2. Objetivo do Projeto

Desenvolver um aplicativo móvel de lista de tarefas com:

- Persistência em SQLite;
- Múltiplas telas;
- Categorias de tarefas;
- Filtragem de tarefas;
- Data e hora de vencimento opcionais;
- Notificações locais agendadas.

O aplicativo deve continuar funcionando após ser fechado e reaberto.

---

# 3. Modelo de Dados da Tarefa

Uma tarefa deve conter pelo menos:

- `id`
- `title`
- `description`
- `completed`
- `dueDateTime`
- `createdAt`
- `categoryId`

Requisitos:

- `id` deve identificar a tarefa de forma única;
- `title` é obrigatório;
- `description` é opcional;
- `completed` indica se a tarefa foi concluída;
- `dueDateTime` é opcional;
- `createdAt` deve registrar quando a tarefa foi criada;
- `categoryId` é opcional.

Você pode adicionar campos adicionais se forem úteis para a implementação.

Documente quaisquer campos adicionais em `BUILD_LOG.md`.

---

# 4. Modelo de Dados de Categoria

Uma categoria deve conter pelo menos:

- `id`
- `name`

Exemplos:

- Pessoal
- Trabalho
- Estudo
- Compras

Você pode adicionar propriedades opcionais como:

- cor;
- ícone;
- descrição.

As categorias devem ser armazenadas persistentemente no SQLite.

---

# 5. Persistência no SQLite

Use o SQLite para persistência local.

No mínimo, o banco de dados deve persistir:

- tarefas;
- categorias.

Os dados devem permanecer disponíveis após:

- navegar entre telas;
- fechar o aplicativo;
- reabrir o aplicativo;
- reiniciar o emulador ou dispositivo.

Você pode escolher uma biblioteca SQLite apropriada, ORM, camada de abstração, DAO, repositório ou abordagem SQL direta.

Documente a abordagem selecionada em `BUILD_LOG.md`.

---

# 6. Telas Obrigatórias

O aplicativo deve conter pelo menos três telas.

---

## Tela 1 — Lista de Tarefas

Esta é a tela principal do aplicativo.

Exiba as tarefas armazenadas.

Cada tarefa deve mostrar visivelmente pelo menos:

- título;
- status concluído/pendente;
- categoria, se houver;
- Data/hora de vencimento, se houver.

A tela deve permitir que o usuário filtre as tarefas por status:

- Todas
- Pendentes
- Concluídas.

A tela também deve permitir a filtragem por categoria.

A interface exata fica a seu critério.

Exemplos:

- ícones;
- abas;
- menu suspenso;
- controle segmentado;
- botões.

O usuário deve poder:

- criar uma nova tarefa;
- abrir uma tarefa existente;
- marcar uma tarefa como concluída ou pendente;
- navegar até o gerenciamento de categorias.

---

## Tela 2 — Editor de Tarefas / Detalhes

Esta tela deve permitir a criação e edição de tarefas.

Campos editáveis:

- título;
- descrição;
- data de vencimento;
- horário de vencimento;
- categoria;
- status de conclusão.

Requisitos:

- título obrigatório;
- categoria opcional;
- data/horário de vencimento opcional.

Ao editar uma tarefa existente, preencha o formulário com seus valores atuais.

O usuário deve poder:

- salvar;
- cancelar;
- excluir uma tarefa existente.

---

## Tela 3 — Gerenciamento de Categorias

Esta tela deve permitir que o usuário:

- liste as categorias existentes;
- crie uma categoria;
- renomeie uma categoria;
- exclua uma categoria.

Você deve decidir o que acontece quando uma categoria que está sendo usada por tarefas é excluída.

Possíveis estratégias incluem:

- as tarefas ficam sem categoria;
- a exclusão é bloqueada;
- as tarefas são reatribuídas;
- Outra abordagem sensata.

Documente o comportamento selecionado em `BUILD_LOG.md`.

---

# 7. Navegação

Implemente a navegação entre as telas necessárias.

O aplicativo deve demonstrar a navegação entre:

1. Lista de Tarefas
2. Editor de Tarefas / Detalhes
3. Gerenciamento de Categorias

Ao abrir uma tarefa existente para edição, escolha uma estratégia apropriada para a transferência de dados.

Exemplos:

- passar apenas o ID da tarefa;
- passar o objeto completo da tarefa;
- usar o estado compartilhado do aplicativo;
- outra abordagem adequada.

Documente a estratégia escolhida em `BUILD_LOG.md`.

---

# 8. Operações de Tarefas

O aplicativo deve suportar:

## Criar

Criar uma nova tarefa e persistir as alterações no SQLite.

## Editar

Editar uma tarefa existente e persistir as alterações.

## Concluir / Reabrir

O usuário deve poder:

- marcar uma tarefa pendente como concluída;
- marcar uma tarefa concluída como pendente novamente.

## Excluir

Excluir uma tarefa do SQLite.

Se a tarefa tiver uma notificação agendada associada, cancelá-la.

---

# 9. Datas de Vencimento

As tarefas podem ter uma data e hora de vencimento opcionais.

Se nenhuma data/hora de vencimento for selecionada, a tarefa deve funcionar normalmente sem um lembrete.

Se uma data/hora futura for selecionada, agende uma notificação local.

---

# 10. Notificações Locais

Use notificações LOCAIS agendadas.

Não dependa de um servidor remoto de notificações push.

Quando uma tarefa tiver uma data/hora de vencimento futura, agende uma notificação.

Exemplo de texto da notificação:

`Lembrete da tarefa: Enviar tarefa de desenvolvimento mobile`

A redação exata pode variar.

Comportamento esperado:

## Tarefa criada com data de vencimento futura

Agende uma notificação.

## Data de vencimento da tarefa alterada

Cancele a notificação antiga e agende uma nova.

## Data de vencimento da tarefa removida

Cancele a notificação existente.

## Tarefa concluída

Cancele a notificação agendada.

## Tarefa concluída alterada de volta para pendente

Se a data/hora de vencimento ainda estiver no futuro, a notificação poderá ser agendada novamente.

## Tarefa excluída

Cancele a notificação.

Se útil, armazene um identificador de notificação associado à tarefa.

Documente a estratégia em `BUILD_LOG.md`.

---

# 11. Permissões de Notificação

Se o sistema operacional exigir permissão de notificação:

- solicite-a adequadamente;
- lide com a negação de forma adequada;
- Não trave se a permissão for negada.

Documente as decisões relacionadas a permissões em `BUILD_LOG.md`.

---

# 12. Suporte a Filtragem

Suporte para filtragem de tarefas por:

## Status

- Todas
- Pendentes
- Concluídas

## Categoria

Permita selecionar uma categoria para exibir apenas as tarefas dessa categoria.

Você pode implementar a filtragem:

- em memória;
- por meio de consultas SQLite;
- por meio de consultas reativas ao banco de dados;
- usando outra abordagem razoável.

Documente a abordagem escolhida em `BUILD_LOG.md`.

---

# 13. Tratamento de Erros

Trate erros comuns de forma adequada.

Exemplos:

- título inválido;
- erros do SQLite;
- datas inválidas;
- negação de permissão de notificação;
- erros de agendamento de notificação.

O aplicativo não deve travar desnecessariamente.

Forneça feedback ao usuário quando apropriado.

---

# 14. Requisitos de Interface do Usuário

Não há um design visual obrigatório.

A interface do usuário deve ser:

- utilizável;
- compreensível;
- razoavelmente consistente;
- adequada para um dispositivo móvel.

Você pode escolher o estilo visual.

Evite gastar esforços excessivos em aprimoramento visual antes que a funcionalidade necessária esteja funcionando.

---

# 15. Arquitetura

Você pode escolher uma arquitetura apropriada.

Exemplos possíveis incluem:

- MVVM;
- MVC;
- arquitetura baseada em repositório;
- organização baseada em funcionalidades;
- Arquitetura Limpa;
- convenções nativas do framework.

Não introduza complexidade desnecessária apenas para pureza arquitetural.

Prefira uma estrutura apropriada para uma pequena aplicação educacional.

Documente as principais escolhas arquiteturais em `BUILD_LOG.md`.

---

# 16. Gerenciamento de Estado

Escolha uma abordagem apropriada para o gerenciamento de estado.

A aplicação deve atualizar corretamente a interface do usuário após ações como:

- criar uma tarefa;
- editar uma tarefa;
- excluir uma tarefa;
- concluir uma tarefa;
- alterar um filtro;
- modificar categorias.

Documente a estratégia de gerenciamento de estado selecionada em `BUILD_LOG.md`.

---

# 17. Dependências

Você pode adicionar dependências quando forem úteis.

Para cada dependência importante adicionada, registre em `BUILD_LOG.md`:

- nome da dependência;
- finalidade;
- motivo da seleção.

Evite adicionar bibliotecas desnecessárias.

---

# 18. Estratégia de Implementação

Trabalhe incrementalmente.

Uma ordem sugerida é:

1. inicializar o projeto;
2. criar o arquivo `BUILD_LOG.md`;
3. criar a navegação básica;
4. definir os modelos;
5. configurar o SQLite;
6. implementar o CRUD de tarefas;
7. implementar o CRUD de categorias;
8. conectar a interface do usuário aos dados persistentes;
9. implementar a filtragem;
10. implementar datas de vencimento; 11.
    implementar notificações;
11. gerenciar permissões;
12. testar a persistência;
13. testar o comportamento das notificações;
14. revisar e limpar o projeto.

Você pode alterar esta ordem, se necessário.

Caso o faça, documente o motivo.

---

# 19. Validação

Não assuma que o código gerado está correto.

Sempre que possível:

- compile o projeto;
- execute-o;
- inspecione a saída do compilador;
- teste os fluxos de usuário importantes;
- corrija os erros encontrados.

Registre falhas e correções significativas no arquivo `BUILD_LOG.md`.

---

# 20. Critérios de Aceitação Funcional

Antes de considerar o projeto concluído, verifique:

- [ ] a aplicação compila com sucesso;
- [ ] o aplicativo inicia com sucesso;
- [ ] tarefas podem ser criadas;
- [ ] tarefas podem ser editadas;
- [ ] tarefas podem ser excluídas;
- [ ] tarefas podem ser marcadas como concluídas;
- [ ] tarefas concluídas podem voltar a ficar pendentes;
- [ ] As tarefas persistem no SQLite;
- [ ] É possível criar categorias;
- [ ] As categorias podem ser renomeadas;
- [ ] As categorias podem ser excluídas;
- [ ] As tarefas podem opcionalmente pertencer a categorias;
- [ ] A filtragem por status funciona;
- [ ] A filtragem por categoria funciona;
- [ ] A navegação entre as telas necessárias funciona;
- [ ] É possível atribuir datas de vencimento;
- [ ] As notificações locais podem ser agendadas;
- [ ] As notificações são atualizadas se as datas de vencimento mudarem;
- [ ] As notificações são canceladas quando as tarefas são excluídas;
- [ ] As notificações são canceladas quando as tarefas são concluídas;
- [ ] A permissão de notificação é gerenciada com segurança;
- [ ] Os dados permanecem disponíveis após a reinicialização do aplicativo;
- [ ] O arquivo `BUILD_LOG.md` contém o histórico de desenvolvimento.

---

# 21. Revisão Final

Quando a implementação parecer completa:

1. revise os critérios de aceitação;
2. identifique recursos incompletos ou parcialmente funcionais;
3. teste os fluxos de aplicativo mais importantes;
4. atualize o arquivo `BUILD_LOG.md`;
5. Forneça um resumo final conciso contendo:
   - arquitetura utilizada;
   - dependências importantes;
   - estratégia de SQLite;
   - estratégia de gerenciamento de estado;
   - estratégia de navegação;
   - estratégia de notificação;
   - limitações conhecidas;
   - bugs restantes.

Não remova ou reescreva entradas anteriores do arquivo `BUILD_LOG.md`.

---

# Instrução Importante

Ao longo de todo este projeto:

**MANTENHA o arquivo `BUILD_LOG.md` ATUALIZADO.**

Sempre que tomar uma decisão importante, fizer uma alteração, corrigir um problema ou descobrir um erro, adicione-o ao log.

O histórico de desenvolvimento é uma parte essencial da tarefa, não uma documentação opcional.
