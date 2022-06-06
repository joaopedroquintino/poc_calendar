import 'dart:io';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';

class CalendarAddPage extends StatefulWidget {
  const CalendarAddPage({Key? key}) : super(key: key);

  @override
  _CalendarAddPageState createState() {
    return _CalendarAddPageState();
  }
}

class _CalendarAddPageState extends State<CalendarAddPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late DeviceCalendarPlugin _deviceCalendarPlugin;

  AutovalidateMode _autovalidate = AutovalidateMode.disabled;
  String _calendarName = '';
  ColorChoice? _colorChoice;
  String _localAccountName = '';

  _CalendarAddPageState() {
    _deviceCalendarPlugin = DeviceCalendarPlugin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Create Calendar'),
      ),
      body: Form(
        autovalidateMode: _autovalidate,
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Calendar Name',
                  hintText: 'My New Calendar',
                ),
                validator: _validateCalendarName,
                onSaved: (String? value) => _calendarName = value ?? '',
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Calendar Color'),
                  DropdownButton<ColorChoice>(
                    onChanged: (selectedColor) {
                      setState(() => _colorChoice = selectedColor);
                    },
                    value: _colorChoice,
                    items: ColorChoice.values
                        .map((color) => DropdownMenuItem(
                              value: color,
                              child: Text(color.toString().split('.').last),
                            ))
                        .toList(),
                  ),
                ],
              ),
              if (Platform.isAndroid)
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Local Account Name',
                    hintText: 'Device Calendar',
                  ),
                  onSaved: (String? value) => _localAccountName = value ?? '',
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final form = _formKey.currentState;
          if (form?.validate() == false) {
            _autovalidate =
                AutovalidateMode.always; // Start validating on every change.
            showInSnackBar('Please fix the errors in red before submitting.');
          } else {
            form?.save();
            var result = await _deviceCalendarPlugin.createCalendar(
              _calendarName,
              calendarColor: _colorChoice?.value,
              localAccountName: _localAccountName,
            );

            if (result.isSuccess) {
              Navigator.pop(context, true);
            } else {
              showInSnackBar(result.errors
                  .map((err) => '[${err.errorCode}] ${err.errorMessage}')
                  .join(' | '));
            }
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }

  String? _validateCalendarName(String? value) {
    if (value == null) return null;
    if (value.isEmpty) {
      return 'Calendar name is required.';
    }

    return null;
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
    // _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(value)));
  }
}

enum ColorChoice {
  red,
  orange,
  yellow,
  green,
  blue,
  purple,
  brown,
  black,
  white
}

extension ColorChoiceExtension on ColorChoice {
  static Color _value(ColorChoice val) {
    switch (val) {
      case ColorChoice.red:
        return Colors.red;
      case ColorChoice.orange:
        return Colors.orange;
      case ColorChoice.yellow:
        return Colors.yellow;
      case ColorChoice.green:
        return Colors.green;
      case ColorChoice.blue:
        return Colors.blue;
      case ColorChoice.purple:
        return Colors.purple;
      case ColorChoice.brown:
        return Colors.brown;
      case ColorChoice.black:
        return Colors.black;
      case ColorChoice.white:
        return Colors.white;
      default:
        return Colors.red;
    }
  }

  Color get value => _value(this);
}
