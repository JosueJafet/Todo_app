import 'package:flutter/material.dart';
import '../models/task.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Task> _tasks = [];
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _dialogController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  DateTime? _selectedDate;

  void _addTask() {
    if (_inputController.text.isNotEmpty) {
      setState(() {
        _tasks.add(Task(_inputController.text));
        _inputController.clear();
      });
    }
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar eliminación"),
        content: Text(
          "¿Seguro que deseas eliminar la tarea '${_tasks[index].title}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _tasks.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }

  void _toggleTask(int index, bool? value) {
    setState(() {
      _tasks[index].done = value ?? false;
    });
  }

  void _editTask(int index) {
    _dialogController.text = _tasks[index].title;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar tarea"),
        content: TextField(controller: _dialogController, autofocus: true),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _dialogController.clear();
            },
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_dialogController.text.isNotEmpty) {
                setState(() {
                  _tasks[index].title = _dialogController.text;
                });
                _dialogController.clear();
                Navigator.of(context).pop();
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int pendingTasks = _tasks.where((t) => !t.done).length;

    return Scaffold(
      appBar: AppBar(
        title: Text("Mis Tareas ($pendingTasks pendientes)"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _tasks.isEmpty
                ? const Center(child: Text("No hay tareas agregadas !"))
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: _tasks[index].done,
                            onChanged: (value) => _toggleTask(index, value),
                          ),
                          title: Text(
                            _tasks[index].title.isNotEmpty
                                ? _tasks[index].title
                                : '(Sin título)',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              decoration: _tasks[index].done
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          subtitle: Text(
                            "${_tasks[index].description.isNotEmpty ? _tasks[index].description : 'Sin descripción'}\n"
                            "Fecha: ${_tasks[index].date.day}/${_tasks[index].date.month}/${_tasks[index].date.year}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          onTap: () => _editTask(index),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.info_outline,
                                  color: Colors.blue,
                                ),
                                tooltip: "Ver detalles",
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(
                                        _tasks[index].title.isNotEmpty
                                            ? _tasks[index].title
                                            : 'Detalle de la tarea',
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Descripción: ${_tasks[index].description.isEmpty ? 'Sin descripción' : _tasks[index].description}",
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            "Fecha: ${_tasks[index].date.day}/${_tasks[index].date.month}/${_tasks[index].date.year}",
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            "Estado: ${_tasks[index].done ? 'Completada' : 'Pendiente'}",
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text("Cerrar"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                tooltip: "Eliminar tarea",
                                onPressed: () => _confirmDelete(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          _dialogController.clear();
          _descController.clear();
          _selectedDate = null;

          showDialog(
            context: context,
            builder: (context) => StatefulBuilder(
              builder: (context, setStateDialog) => AlertDialog(
                title: const Text("Nueva tarea"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _dialogController,
                        decoration: const InputDecoration(labelText: "Título"),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _descController,
                        decoration: const InputDecoration(
                          labelText: "Descripción",
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            _selectedDate == null
                                ? "Sin fecha seleccionada"
                                : "Fecha: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setStateDialog(() {
                                  _selectedDate = picked;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancelar"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_dialogController.text.isNotEmpty &&
                          _selectedDate != null) {
                        setState(() {
                          _tasks.add(
                            Task(
                              _dialogController.text,
                              description: _descController.text,
                              date: _selectedDate!,
                            ),
                          );
                        });
                        _dialogController.clear();
                        _descController.clear();
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text("Agregar"),
                  ),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _dialogController.dispose();
    _descController.dispose();
    super.dispose();
  }
}
