class Task {
  String title;
  String description;
  DateTime date;
  bool done;

  Task(this.title, {this.description = '', DateTime? date, this.done = false})
    : date = date ?? DateTime.now();
}
