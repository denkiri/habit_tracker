import 'package:flutter/material.dart';
import 'package:habit_tracker/constants/app.dart';

class _ModalAddHabit extends StatefulWidget {
  @override
  _ModalAddHabitState createState() => _ModalAddHabitState();
}

class _ModalAddHabitState extends State<_ModalAddHabit> {
  final inputController = TextEditingController();
  bool? isReminderActive = false;
  TimeOfDay selectedTime = TimeOfDay(hour: 07, minute: 00);
  DateTime? selectedStartDate; // Field for the selected start date
  List<int> activeDay = [1, 2, 3, 4, 5, 6, 7];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            'Get into a Habit',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _inputName(),
        _startDatePicker(context), // New Start Date Picker
        _reminder(context),
        _actionButton(context),
      ],
    );
  }

  Widget _startDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10,top:10 ),
          child: Text(
            'Start Date',
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.white10,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: selectedStartDate ?? DateTime.now(),
              firstDate: DateTime.now().subtract(Duration(days: 365)),
              lastDate: DateTime.now().add(Duration(days: 365)),
            );

            if (pickedDate != null) {
              setState(() {
                selectedStartDate = pickedDate;
              });
            }
          },
          child: Text(
            selectedStartDate != null
                ? "${selectedStartDate!.toLocal()}".split(' ')[0]
                : 'Select Start Date',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _reminder(BuildContext context) {
    Widget toggleButton = GestureDetector(
      onTap: () {
        setState(() {
          isReminderActive = !isReminderActive!;
        });
      },
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Checkbox(
              onChanged: (value) {
                setState(() {
                  isReminderActive = value;
                });
              },
              value: isReminderActive,
              activeColor: Colors.green[700],
              checkColor: Colors.white,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
              child: Text(
                'Reminder',
                style: TextStyle(fontSize: 15, color: Colors.white),
              )),
        ],
        mainAxisAlignment: MainAxisAlignment.start,
      ),
    );

    Widget dateList = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var item in dayShortName)
          _dayItem(
            text: item,
            active: activeDay.indexOf(dayShortName.indexOf(item) + 1) != -1,
            onTap: (value) {
              int week = dayShortName.indexOf(value) + 1;
              setState(() {
                if (activeDay.indexOf(week) == -1) {
                  activeDay.add(week);
                } else {
                  activeDay.remove(week);
                }
              });
            },
          ),
      ],
    );

    List<Widget> childrenList = [toggleButton];

    if (isReminderActive!) {
      childrenList.add(_timePicker(context));
      childrenList.add(SizedBox(height: 10));
      childrenList.add(dateList);
      childrenList.add(SizedBox(height: 20));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: childrenList,
    );
  }

  Widget _dayItem(
      {required String text, required bool active, Function? onTap}) {
    BoxDecoration decorationActive =
    BoxDecoration(color: Colors.white, shape: BoxShape.circle);

    BoxDecoration decorationInactive = BoxDecoration(shape: BoxShape.circle);
    return GestureDetector(
        onTap: () => onTap!(text),
        child: Container(
          decoration: active ? decorationActive : decorationInactive,
          width: 35,
          height: 35,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: active ? Colors.black : Colors.white,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ));
  }

  Widget _timePicker(BuildContext context) {
    return Center(
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
          backgroundColor: Colors.white10,
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          showTimePicker(
            context: context,
            initialTime: selectedTime,
          ).then(
                (value) {
              if (value == null) return;
              setState(() {
                selectedTime = value;
              });
            },
          );
        },
        child: Text(
          getTime(selectedTime),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String getTime(TimeOfDay time) {
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final hour = selectedTime.hourOfPeriod
        .toString()
        .padLeft(2, '0')
        .replaceAll('00', '12');
    final minute = selectedTime.minute.toString().padLeft(2, '0');
    return "$hour:$minute $period";
  }

  Widget _inputName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(
            'Name',
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
        SizedBox(
          height: 5.0,
        ),
        TextField(
          autofocus: true,
          controller: inputController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Color(0x33FFFFFF),
            border: OutlineInputBorder(borderSide: (BorderSide.none)),
            contentPadding: EdgeInsets.all(10),
          ),
          style: TextStyle(color: Color(0xFFFFFFFF)),
        ),
      ],
    );
  }

  Widget _actionButton(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Center(
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).primaryColor,
                disabledBackgroundColor: Colors.grey,
                disabledForegroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, {
                  'name': inputController.text,
                  'startDate': selectedStartDate, // Pass the selected start date
                  'isReminderActive': isReminderActive,
                  'time': activeDay.isNotEmpty ? selectedTime : null,
                  'daylist': activeDay,
                });
              },
              child: Text(
                "OK",
                style: TextStyle(fontSize: 15.0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Future<Map?> modalAddHabit(BuildContext context) async {
  return showModalBottomSheet(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(10.0),
      ),
    ),
    backgroundColor: Theme.of(context).primaryColor,
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(30),
      child: _ModalAddHabit(),
    ),
  );
}
