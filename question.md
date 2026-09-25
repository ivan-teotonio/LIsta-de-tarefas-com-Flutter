## Ivan Teotonio
## Vitor

# Mobile App Reverse-Engineering Questions

Answer the following questions based on the code generated during the exercise.

You may use the coding agent to help investigate the project, but you must inspect the source code and verify the answers yourself.

Whenever possible, mention the relevant files, classes, functions, or components.

---

## 1. Project Structure

What are the main parts of the project, and where can you find:

- UI/screens;
  Em main.dart
- data models;
  Task: representa uma tarefa
  Category: representa uma categoria

- SQLite/database code;
  DatabaseRepository cuida de todo o acesso ao SQLite

- navigation;
  A navegação é feita com Navigator.push

- notification code?
  A classe Notificação ficam main.dart responsavel por agendar lembretes

Briefly describe how the project is organized.
O projeto está organizado como um app Flutter simples em um único arquivo principal main.dart

---

## 2. Architecture and State

How is application state managed?
Este app não usa uma biblioteca formal de gerenciamento de estado como Provider, Bloc, Riverpod ou Redux. A abordagem é bem simples e local: cada tela que precisa mudar visualmente é um StatefulWidget, e o estado fica guardado no objeto de estado correspondente, em main.dart.

Explain how the UI is updated after an operation such as:

- creating a task;
  o usuário abre EditorPage preenche title, description, due, category ao clicar em salvar, o método save() cria um Task

- editing a task;
  openEditor(task) abre a tela com os dados da tarefa

- marking a task as completed.
  cria uma cópia da tarefa com completed: !task.completed
  salva no banco com repo.saveTask(changed)

Does the project use any recognizable architectural pattern or state-management approach?
Não há um padrão arquitetural “formal” completo como MVC, MVVM ou Clean Architecture.

---

## 3. SQLite Persistence

How is SQLite used in the application?
O banco é gerenciado pela classe DatabaseRepository, localizada em main.dart. Ela encapsula toda a persistência local e serve como camada de acesso aos dados.

Identify:

- where the database is created;
  No getter database dentro de DatabaseRepository

- how tasks and categories are stored;
  As tarefas e categorias são mapeadas em classes Dart
- where create, read, update, and delete operations are implemented.
  As operações de CRUD estão todas em DatabaseRepository em main.dart

---

## 4. Follow One Operation

Trace what happens when the user creates a new task.

Start from pressing **Save** and follow the execution until:
Quando o usuário clica em “Salvar” na tela de criação de tarefa, o fluxo começa em EditorPage.save(), em main.dart

1. the task is stored in SQLite;
   A função save() faz o seguinte:
   valida se o título não está vazio
   cria um objeto Task

2. the task appears in the task list;
   A função saveTask(Task task) faz:
   acessa o banco via await database
   se a tarefa for nova (id == 0), faz db.insert('tasks', task.toMap())
   se for edição, faz db.update

3. a notification is scheduled, if a due date exists.
   Depois do save, a tela de edição fecha e a tela principal atualiza

Describe the main functions/components involved.
Salvar → Task.toMap() → DatabaseRepository.saveTask() → SQLite → HomePage.load() → setState() → UI atualiza → Notifications.sync() → notificação agendada

---

## 5. Navigation

How does navigation between screens work?
A navegação é feita com Navigator.push() e MaterialPageRoute, sem uso de rotas nomeadas ou framework de navegação mais avançado. Isso está em main.dart.

In particular:

- how does the app navigate from the task list to the task editor?
- when editing a task, what information is passed between screens?

For example: task ID, full object, shared state, or another approach.

1. Da lista de tarefas para o editor
   Na tela principal, HomePage, a ação de abrir um editor é:
   openEditor([Task? task])
   Isso executa:

await Navigator.push(...)
MaterialPageRoute(builder: (\_) => EditorPage(repo: repo, task: task, categories: categories))
Ou seja, a tela de edição é empilhada sobre a tela atual.

2. O que é passado para o editor
   O EditorPage recebe três valores:

repo: o repositório de banco
task: uma tarefa opcional (Task?)
categories: lista de categorias disponíveis

3. Quando é criar vs editar
   Se task == null, então a tela está no modo “nova tarefa”.

Se task != null, então a tela está em modo “editar tarefa”.

4. O que volta para a tela anterior
   Ao salvar, o editor chama:

final id = await widget.repo.saveTask(task);
e depois:

if (mounted) Navigator.pop(context);
Quando Navigator.pop(context) é chamado, a tela de edição fecha e retorna para HomePage.

A tela principal, em openEditor(), depois disso faz:

await load();
para recarregar os dados do banco e atualizar a lista.

---

## 6. Notifications

How are task reminders implemented?

Explain:

- how a notification is scheduled;
  Quando uma tarefa é salva, o app chama:
  await Notifications.sync(task)

- how it is associated with a task;
  Cada tarefa recebe um id único. Esse id também é usado como ID da notificação:

- what happens when the due date changes;
  Se a tarefa for editada e a data for alterada, o app salva a nova versão no SQLite

- what happens when the task is completed or deleted.
  Se a tarefa for concluída: sync(changed) é chamado com completed: true, e a condição !task.completed falha, então a notificação não é agendada.
  Se a tarefa for excluída: o código chama await Notifications.plugin.cancel(widget.task!.id); antes de remover a tarefa.

---

## 7. Agent Decisions

Identify at least **two important decisions made by the coding agent that were not explicitly specified in the assignment**.

Examples:

- architecture;
- libraries;
- state-management strategy;
- navigation approach;
- SQLite abstraction;
- project structure.

For each one, explain what the agent chose.

1. Arquitetura simples em um único arquivo
   O agente escolheu manter a lógica principal em main.dart, em vez de dividir em vários arquivos por camada. Isso deixa o projeto mais fácil de acompanhar para uma app pequena, mas menos escalável.

2. Estado local com StatefulWidget
   O agente usou estado local nas telas (StatefulWidget + setState) em vez de um gerenciador como Provider ou Bloc. Essa escolha simplifica o código e funciona bem para uma aplicação pequena com poucos fluxos.

---

## 8. BUILD_LOG Analysis

Using `BUILD_LOG.md`, identify:

- one problem or bug encountered during development;
- how the agent attempted to solve it;
- whether the first solution worked;
- what was eventually done.

Problema encontrado no log
No arquivo BUILD_LOG.md, o problema principal foi a exceção de locale/data ao abrir o app: LocaleDataException / Locale data has not been initialized.
omo o agente tentou resolver
O agente tentou corrigir em duas etapas:

Inicializou os dados do intl antes do runApp:
await initializeDateFormatting('pt_BR')
Depois, configurou o timezone local:
tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'))
Essas correções foram feitas em main.dart, antes das notificações e renderização da tela.

A primeira solução funcionou?
Parcialmente. A primeira correção resolveu o problema de locale, mas ainda restava um problema relacionado ao timezone. Então foi necessário um ajuste adicional.

Then answer:

**What did the build log help you understand that would have been harder to discover by looking only at the final code?**

Porque o log mostra a sequência real de problemas, correções e validações que aconteceram durante o desenvolvimento, e não só o estado final. Como não conheço a linguagem só olhar não ajuda, o que ajudou mesmo foi fazer engenharia reversa com a ia.
