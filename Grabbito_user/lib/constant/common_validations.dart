class ValidationConstants {
  static String? kValidateEmail(String? value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern as String);
    if (value!.isEmpty) {
      return "Email is Required";
    } else if (!regex.hasMatch(value)) {
      return 'Enter valid email';
    } else {
      return null;
    }
  }

  static String? kValidatePassword(String? value) {
    Pattern pattern = r'^[A-Za-z0-9]+(?:[ _-][A-Za-z0-9]+)*$';
    RegExp regex = RegExp(pattern as String);

    if (value!.isEmpty) {
      return "Password is Required";
    } else if (value.length < 6) {
      return "Password must be at least 6 characters";
    } else if (!regex.hasMatch(value)) {
      return 'Password required';
    } else {
      return null;
    }
  }

  static String? kValidateName(String? value) {
    if (value!.trim().isEmpty) {
      return 'FullName is Required';
    } else {
      return null;
    }
  }

  static String? kValidatePickup(String? value) {
    if (value!.trim().isEmpty) {
      return 'Pickup Address is Required';
    } else {
      return null;
    }
  }

  static String? kValidateDrop(String? value) {
    if (value!.trim().isEmpty) {
      return 'Drop Address is Required';
    } else {
      return null;
    }
  }

  static String? kValidateContactNo(String? value) {
    Pattern pattern = r'^[0-9]*$';
    RegExp regex = RegExp(pattern as String);
    if (value!.isEmpty) {
      return 'Contact Number is Required';
    } else if (value.length > 10) {
      return 'Contact Number should be 10 letter';
    } else if (!regex.hasMatch(value)) {
      return 'letter should be in numbers';
    } else {
      return null;
    }
  }

  static String? kValidateWeight(String? value) {
    Pattern pattern = r'^[0-9]*$';
    RegExp regex = RegExp(pattern as String);
    if (value!.isEmpty) {
      return 'Weight is Required';
    } else if (!regex.hasMatch(value)) {
      return 'letter should be in numbers';
    } else {
      return null;
    }
  }
}
