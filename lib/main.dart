import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const ink = Color(0xFF17212B);
const muted = Color(0xFF718096);
const accent = Color(0xFF2D8CFF);
const surface = Color(0xFFF6F8FB);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
  await initializeDateFormatting('pt_BR');
  await Notifications.initialize();
  runApp(const TaskApp());
}

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.completed,
    required this.dueDateTime,
    required this.createdAt,
    this.categoryId,
  });
  final int id;
  final String title;
  final String description;
  final bool completed;
  final DateTime? dueDateTime;
  final DateTime createdAt;
  final int? categoryId;

  factory Task.fromMap(Map<String, Object?> map) => Task(
    id: map['id']! as int,
    title: map['title']! as String,
    description: map['description'] as String? ?? '',
    completed: (map['completed']! as int) == 1,
    dueDateTime: map['due_date_time'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(map['due_date_time']! as int),
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']! as int),
    categoryId: map['category_id'] as int?,
  );

  Map<String, Object?> toMap() => {
    'title': title,
    'description': description,
    'completed': completed ? 1 : 0,
    'due_date_time': dueDateTime?.millisecondsSinceEpoch,
    'created_at': createdAt.millisecondsSinceEpoch,
    'category_id': categoryId,
  };
}

class Category {
  const Category({required this.id, required this.name});
  final int id;
  final String name;
  factory Category.fromMap(Map<String, Object?> map) =>
      Category(id: map['id']! as int, name: map['name']! as String);
}

class DatabaseRepository {
  Database? _database;
  Future<Database> get database async => _database ??= await openDatabase(
    path.join(await getDatabasesPath(), 'listatarefas.db'),
    version: 1,
    onCreate: (db, _) async {
      await db.execute(
        'CREATE TABLE categories (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE)',
      );
      await db.execute(
        'CREATE TABLE tasks (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, description TEXT, completed INTEGER NOT NULL DEFAULT 0, due_date_time INTEGER, created_at INTEGER NOT NULL, category_id INTEGER)',
      );
    },
  );
  Future<List<Task>> tasks() async => (await (await database).query(
    'tasks',
    orderBy: 'completed ASC, due_date_time IS NULL, due_date_time ASC, created_at DESC',
  )).map(Task.fromMap).toList();
  Future<List<Category>> categories() async => (await (await database).query(
    'categories',
    orderBy: 'name ASC',
  )).map(Category.fromMap).toList();
  Future<int> saveTask(Task task) async {
    final db = await database;
    if (task.id == 0) return db.insert('tasks', task.toMap());
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    return task.id;
  }

  Future<void> deleteTask(int id) async =>
      (await database).delete('tasks', where: 'id = ?', whereArgs: [id]);
  Future<int> addCategory(String name) async =>
      (await database).insert('categories', {'name': name});
  Future<void> renameCategory(int id, String name) async => (await database)
      .update('categories', {'name': name}, where: 'id = ?', whereArgs: [id]);
  Future<void> deleteCategory(int id) async {
    final db = await database;
    await db.update(
      'tasks',
      {'category_id': null},
      where: 'category_id = ?',
      whereArgs: [id],
    );
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}

class CategoryDialog extends StatefulWidget {
  const CategoryDialog({super.key, this.category});

  final Category? category;

  @override
  State<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.category?.name);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.category == null ? 'Nova categoria' : 'Renomear categoria',
    ),
    content: TextField(
      controller: controller,
      autofocus: true,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(labelText: 'Nome'),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, controller.text.trim()),
        child: const Text('Salvar'),
      ),
    ],
  );
}

class Notifications {
  static final plugin = FlutterLocalNotificationsPlugin();
  static Future<void> initialize() async {
    await plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    await plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static Future<void> sync(Task task) async {
    await plugin.cancel(task.id);
    if (!task.completed &&
        task.dueDateTime != null &&
        task.dueDateTime!.isAfter(DateTime.now())) {
      await plugin.zonedSchedule(
        task.id,
        'Lembrete da tarefa',
        task.title,
        tz.TZDateTime.from(task.dueDateTime!, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'tasks',
            'Tarefas',
            channelDescription: 'Lembretes de tarefas',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }
}

class TaskApp extends StatelessWidget {
  const TaskApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Tarefas',
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: surface,
      colorScheme: ColorScheme.fromSeed(seedColor: accent),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    ),
    home: const HomePage(),
  );
}

enum TaskFilter { all, pending, completed }

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final repo = DatabaseRepository();
  List<Task> tasks = [];
  List<Category> categories = [];
  TaskFilter filter = TaskFilter.all;
  int? categoryFilter;
  bool loading = true;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final loadedTasks = await repo.tasks();
    final loadedCategories = await repo.categories();
    if (mounted) {
      setState(() {
        tasks = loadedTasks;
        categories = loadedCategories;
        loading = false;
      });
    }
  }

  List<Task> get visible => tasks
      .where(
        (task) =>
            (filter == TaskFilter.all ||
                (filter == TaskFilter.completed
                    ? task.completed
                    : !task.completed)) &&
            (categoryFilter == null || task.categoryId == categoryFilter),
      )
      .toList();
  Category? categoryFor(int? id) =>
      id == null ? null : categories.where((item) => item.id == id).firstOrNull;
  Future<void> openEditor([Task? task]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EditorPage(repo: repo, task: task, categories: categories),
      ),
    );
    await load();
  }

  Future<void> toggle(Task task) async {
    final changed = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      completed: !task.completed,
      dueDateTime: task.dueDateTime,
      createdAt: task.createdAt,
      categoryId: task.categoryId,
    );
    await repo.saveTask(changed);
    await Notifications.sync(changed);
    await load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Minhas tarefas',
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
      ),
      actions: [
        IconButton(
          tooltip: 'Categorias',
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CategoriesPage(repo: repo)),
            );
            await load();
          },
          icon: const Icon(Icons.sell_outlined),
        ),
      ],
    ),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              children: [
                summary(),
                const SizedBox(height: 22),
                filters(),
                const SizedBox(height: 18),
                if (visible.isEmpty) empty() else ...visible.map(taskTile),
              ],
            ),
          ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => openEditor(),
      icon: const Icon(Icons.add),
      label: const Text('Nova tarefa'),
    ),
  );
  Widget summary() => Row(
    children: [
      Expanded(
        child: Text(
          '${tasks.where((task) => !task.completed).length} pendentes',
          style: const TextStyle(color: muted, fontSize: 15),
        ),
      ),
      Text(
        DateFormat('EEE, d MMM', 'pt_BR').format(DateTime.now()),
        style: const TextStyle(color: muted, fontSize: 13),
      ),
    ],
  );
  Widget filters() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: TaskFilter.values
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      item == TaskFilter.all
                          ? 'Todas'
                          : item == TaskFilter.pending
                          ? 'Pendentes'
                          : 'Concluídas',
                    ),
                    selected: filter == item,
                    onSelected: (_) => setState(() => filter = item),
                  ),
                ),
              )
              .toList(),
        ),
      ),
      if (categories.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: DropdownButtonFormField<int?>(
            initialValue: categoryFilter,
            decoration: const InputDecoration(
              labelText: 'Filtrar por categoria',
              prefixIcon: Icon(Icons.sell_outlined),
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Todas as categorias'),
              ),
              ...categories.map(
                (category) => DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name),
                ),
              ),
            ],
            onChanged: (value) => setState(() => categoryFilter = value),
          ),
        ),
    ],
  );
  Widget taskTile(Task task) {
    final category = categoryFor(task.categoryId);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => openEditor(task),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: task.completed,
                onChanged: (_) => toggle(task),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.completed ? muted : ink,
                      ),
                    ),
                    if (task.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          task.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: muted),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (category != null)
                          meta(Icons.sell_outlined, category.name),
                        if (task.dueDateTime != null)
                          meta(
                            Icons.schedule,
                            DateFormat(
                              'd MMM, HH:mm',
                              'pt_BR',
                            ).format(task.dueDateTime!),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget meta(IconData icon, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: muted),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
  Widget empty() => Padding(
    padding: const EdgeInsets.only(top: 70),
    child: Column(
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 58,
          color: accent.withValues(alpha: .65),
        ),
        const SizedBox(height: 14),
        const Text(
          'Tudo em dia',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'Adicione uma tarefa para começar.',
          style: TextStyle(color: muted),
        ),
      ],
    ),
  );
}

class EditorPage extends StatefulWidget {
  const EditorPage({
    super.key,
    required this.repo,
    required this.categories,
    this.task,
  });
  final DatabaseRepository repo;
  final List<Category> categories;
  final Task? task;
  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late final TextEditingController title;
  late final TextEditingController description;
  DateTime? due;
  int? category;
  bool completed = false;
  bool saving = false;
  @override
  void initState() {
    super.initState();
    title = TextEditingController(text: widget.task?.title);
    description = TextEditingController(text: widget.task?.description);
    due = widget.task?.dueDateTime;
    category = widget.task?.categoryId;
    completed = widget.task?.completed ?? false;
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (title.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Dê um título à tarefa.')));
      return;
    }
    setState(() => saving = true);
    final task = Task(
      id: widget.task?.id ?? 0,
      title: title.text.trim(),
      description: description.text.trim(),
      completed: completed,
      dueDateTime: due,
      createdAt: widget.task?.createdAt ?? DateTime.now(),
      categoryId: category,
    );
    final id = await widget.repo.saveTask(task);
    await Notifications.sync(
      Task(
        id: id,
        title: task.title,
        description: task.description,
        completed: task.completed,
        dueDateTime: task.dueDateTime,
        createdAt: task.createdAt,
        categoryId: task.categoryId,
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  Future<void> delete() async {
    if (widget.task == null) return;
    await widget.repo.deleteTask(widget.task!.id);
    await Notifications.plugin.cancel(widget.task!.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.task == null ? 'Nova tarefa' : 'Editar tarefa'),
      actions: [
        if (widget.task != null)
          IconButton(
            tooltip: 'Excluir',
            onPressed: delete,
            icon: const Icon(Icons.delete_outline),
          ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextField(
          controller: title,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Título',
            hintText: 'O que precisa ser feito?',
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: description,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Descrição',
            hintText: 'Adicione detalhes (opcional)',
          ),
        ),
        const SizedBox(height: 18),
        DropdownButtonFormField<int?>(
          initialValue: category,
          decoration: const InputDecoration(
            labelText: 'Categoria',
            prefixIcon: Icon(Icons.sell_outlined),
          ),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('Sem categoria'),
            ),
            ...widget.categories.map(
              (item) =>
                  DropdownMenuItem(value: item.id, child: Text(item.name)),
            ),
          ],
          onChanged: (value) => setState(() => category = value),
        ),
        const SizedBox(height: 14),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.schedule, color: accent),
          title: Text(
            due == null
                ? 'Adicionar vencimento'
                : DateFormat('d MMMM yyyy, HH:mm', 'pt_BR').format(due!),
          ),
          subtitle: Text(
            due == null ? 'Receba um lembrete local' : 'Lembrete agendado',
          ),
          trailing: due == null
              ? null
              : IconButton(
                  tooltip: 'Remover vencimento',
                  onPressed: () => setState(() => due = null),
                  icon: const Icon(Icons.close),
                ),
          onTap: pickDue,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Concluída'),
          value: completed,
          onChanged: (value) => setState(() => completed = value),
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: saving ? null : save,
          icon: const Icon(Icons.check),
          label: Text(saving ? 'Salvando...' : 'Salvar tarefa'),
        ),
      ],
    ),
  );
  Future<void> pickDue() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: due ?? DateTime.now(),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: due == null ? TimeOfDay.now() : TimeOfDay.fromDateTime(due!),
    );
    if (time != null) {
      setState(
        () => due = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        ),
      );
    }
  }
}

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key, required this.repo});
  final DatabaseRepository repo;
  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<Category> categories = [];
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final result = await widget.repo.categories();
    if (mounted) setState(() => categories = result);
  }

  Future<void> edit([Category? category]) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => CategoryDialog(category: category),
    );
    if (name == null || name.isEmpty) return;
    try {
      if (category == null) {
        await widget.repo.addCategory(name);
      } else {
        await widget.repo.renameCategory(category.id, name);
      }
      await load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Essa categoria já existe.')),
        );
      }
    }
  }

  Future<void> delete(Category category) async {
    await widget.repo.deleteCategory(category.id);
    await load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarefas vinculadas ficaram sem categoria.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Categorias')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          '${categories.length} categorias',
          style: const TextStyle(color: muted),
        ),
        const SizedBox(height: 14),
        ...categories.map(
          (category) => Card(
            elevation: 0,
            color: Colors.white,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE5F0FF),
                child: Icon(Icons.sell_outlined, color: accent),
              ),
              title: Text(
                category.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) =>
                    value == 'edit' ? edit(category) : delete(category),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Renomear')),
                  PopupMenuItem(value: 'delete', child: Text('Excluir')),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => edit(),
      child: const Icon(Icons.add),
    ),
  );
}
