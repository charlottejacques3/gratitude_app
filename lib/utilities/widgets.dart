import 'package:flutter/material.dart';
import 'package:gratitude_app/logs_model.dart';
import 'package:provider/provider.dart';

class SwitchedColourButton extends StatelessWidget {
  const SwitchedColourButton({super.key, required this.text, required this.onClick});

  final String text; 
  final Function onClick;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onClick(),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll<Color>(Color.fromARGB(255, 125,78,125))
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Color.fromARGB(255, 249, 241, 237),
        ),
      ),
    );
  }
}


class LabeledRadio extends StatelessWidget {
  const LabeledRadio({
    super.key,
    required this.label,
    required this.groupValue,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool groupValue;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (value != groupValue) {
          onChanged(value);
        }
      },
      child: Row(
        children: <Widget>[
          Radio<bool>(
            groupValue: groupValue,
            value: value,
            onChanged: (bool? newValue) {
              onChanged(newValue!);
            },
          ),
          Text(label),
        ],
      ),
    );
  }
}


class YesNoRadio extends StatelessWidget {
  const YesNoRadio({
    super.key,
    required this.label,
    required this.radioSelected,
    required this.onChanged,
    this.largeText = false
  });

  final String label;
  final bool radioSelected;
  final ValueChanged<bool> onChanged;
  final bool largeText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30,),
        Text(
          label,
          style: largeText ? Theme.of(context).textTheme.bodyLarge! : Theme.of(context).textTheme.bodyMedium!,
        ),
        Row(
          children: [
            Expanded(
              child: LabeledRadio(
                label: 'Yes', 
                groupValue: radioSelected, 
                value: true, 
                onChanged: (bool? newValue) {
                  onChanged(newValue!);
                }
              ),
            ),
            Expanded(
              child: LabeledRadio(
                label: 'No', 
                groupValue: radioSelected, 
                value: false, 
                onChanged: (bool? newValue) {
                  onChanged(newValue!);
                }
              ),
            ),
          ],
        ),
      ],
    );
  }
}


class DynamicFormWidget extends StatelessWidget {

  const DynamicFormWidget({super.key, required this.logController});

  final TextEditingController logController; 
  // final dynamic manageFormList;

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
      
          //form entries
          Expanded(
            flex: 7,
            child: TextFormField(
              controller: logController,
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 3,
            ),
          ),
      
          //delete log button
          Expanded(
              child: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => Provider.of<LogsModel>(context, listen: false).removeTextLog(key) //manageFormList(key)
              ),
          )
        ],
      ),
    );
  }
}


void showLoginDialog({required BuildContext context, required String header, required Function onSubmit, required TextEditingController username, required TextEditingController pw, required String submitButton}) {
    showDialog(
      context: context, 
      barrierDismissible:  false,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(header,
                style: Theme.of(context).textTheme.titleMedium
              ),
              Row(
                children: [
                  Text('Username: '),
                  Expanded(
                    child: TextFormField(
                      controller: username,
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Text('Password: '),
                  Expanded(
                    child: TextFormField(
                      controller: pw,
                      obscureText: true,
                    ),
                  )
                ],
              ),
              SizedBox(height: 15,),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel',
                        textAlign: TextAlign.center,
                      )
                    ),
                  ),
                  SizedBox(width: 8,),
                  Expanded(
                    child: ElevatedButton(
                      style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                        backgroundColor: WidgetStatePropertyAll<Color>(Color.fromARGB(255, 209, 108, 103)),
                      ),
                      onPressed: () => onSubmit(username, pw),
                      child: Text(submitButton,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white
                        ),
                      )
                    ),
                  ),
                ],
              )
            ],
          ),
        )
      )
    );
  }


// class BottomNavBar extends StatelessWidget {

//   const BottomNavBar({super.key});

//   @override
//   Widget build(BuildContext context) {

//     return NavigationBar(
//         onDestinationSelected: (int index) {
//           //change currentIndex based on what's been selected
//           setState(() {
//             currentPageIndex = index;
//           });
//         },
//         selectedIndex: currentPageIndex,
//         destinations: 
//           Globals.group.compareTo('experimental') == 0 ? [  //experimental group
//             NavigationDestination(
//               icon: Icon(Icons.edit), 
//               label: 'Log',
//             ),
//             NavigationDestination(
//               icon: Icon(Icons.book), 
//               label: 'Past Logs',
//             ),
//             NavigationDestination(
//               icon: Icon(Icons.psychology), 
//               label: 'Reflect',
//             ),
//             NavigationDestination(
//               icon: Icon(Icons.show_chart), 
//               label: 'Statistics',
//             ),
//           ] : [ //control group
//             NavigationDestination(
//               icon: Icon(Icons.edit), 
//               label: 'Log',
//             ),
//             NavigationDestination(
//               icon: Icon(Icons.book), 
//               label: 'Past Logs',
//             ),
//           ],
//         );
//   }
// }