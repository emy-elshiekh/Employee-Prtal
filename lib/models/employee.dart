class Employee {
  const Employee({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.email,
    required this.jobTitle,
    required this.department,
  });

  final String id;
  final String employeeId;
  final String name;
  final String email;
  final String jobTitle;
  final String department;

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: '${json['id']}',
      employeeId: '${json['employee_id'] ?? json['employeeId'] ?? ''}',
      name: '${json['name'] ?? ''}',
      email: '${json['email'] ?? ''}',
      jobTitle: '${json['job_title'] ?? json['jobTitle'] ?? ''}',
      department: '${json['department'] ?? ''}',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'employee_id': employeeId,
        'name': name,
        'email': email,
        'job_title': jobTitle,
        'department': department,
      };
}
