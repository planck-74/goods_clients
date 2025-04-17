import 'package:flutter/material.dart';

Widget customTextFormField(
    {required double width,
    TextEditingController? controller,
    required String labelText,
    String? validationText,
    required context,
    double? height,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      height: height ?? 60,
      width: width * 0.95,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9), 
        borderRadius: BorderRadius.circular(3), 
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.5), 
            spreadRadius: 2, 
            blurRadius: 5, 
            offset: const Offset(0, 3), 
          ),
        ],
      ),
      child: TextFormField(
        maxLength: 11,
        controller: controller,
        textInputAction: textInputAction ?? TextInputAction.done,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          counterText: "",
          focusedBorder: InputBorder.none,
          hintText: labelText,
          hintStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.blueGrey,
              fontSize: 18),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
        validator: validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return validationText;
              }
              return null;
            },
      ),
    ),
  );
}

Widget customTextField(
    {required double width,
    TextEditingController? controller,
    required String labelText,
    required context,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    ValueChanged<String>? onChanged}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      height: 40,
      width: width * 0.95,
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(3), 
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.5), 
            spreadRadius: 2, 
            blurRadius: 5, 
            offset: const Offset(0, 3), 
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        textInputAction: textInputAction ?? TextInputAction.done,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          icon: Container(
              padding: const EdgeInsets.fromLTRB(0, 6, 16, 0),
              child: const Icon(Icons.search)),
          hintText: labelText, 
          hintStyle: TextStyle(color: Colors.blueGrey.shade500, fontSize: 18),
          border: InputBorder.none, 
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0, vertical: 12.0), 
        ),
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    ),
  );
}
