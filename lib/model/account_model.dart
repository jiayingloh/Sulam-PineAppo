class Account {
  final int accID;
  final String email;
  final String username;
  final String password; 

  Account({
    required this.accID,
    required this.email,
    required this.username,
    required this.password,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    final accIdRaw = json['AccID'] ?? json['accID'] ?? json['AccId'];
    final emailRaw = json['Email'] ?? json['email'];
    final usernameRaw = json['UserName'] ?? json['username'] ?? json['userName'];
    final passwordRaw = json['Password'] ?? json['password'] ?? '';

    return Account(
      accID: int.parse(accIdRaw.toString()),
      email: emailRaw?.toString() ?? '',
      username: usernameRaw?.toString() ?? '',
      password: passwordRaw?.toString() ?? '',
    );
  }

  // Convert Account object to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'AccID': accID,
      'Email': email,
      'UserName': username,
      'Password': password,
    };
  }
}
