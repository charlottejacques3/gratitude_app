import 'package:flutter/material.dart';
import 'package:gratitude_app/logs_model.dart';
import 'package:gratitude_app/study_pages/checkin_popup.dart';
import 'package:gratitude_app/study_pages/questionnaire_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final bool? groupValue;
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
  final bool? radioSelected;
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

class MoodButton extends StatelessWidget {
  const MoodButton({super.key, required this.moodNum, required this.icon, required this.onClick, required this.selectedMood, required this.iconColour, this.initial=false});

  final int moodNum;
  final IconData icon;
  final Function onClick;
  final int selectedMood;
  final Color iconColour;
  final bool initial;

  @override
  Widget build(BuildContext context) {
    
    WidgetStateProperty<Color> selectedColour = WidgetStatePropertyAll<Color>(Color.fromARGB(100, 150, 150, 150));
    WidgetStateProperty<Color> unselectedColour = WidgetStatePropertyAll<Color>(Color.fromARGB(255, 250, 240, 230));
    WidgetStateProperty<Color> initBg = WidgetStatePropertyAll<Color>(Color.fromARGB(250, 227, 196, 225));

    return Expanded(
      child: IconButton(
        style: ButtonStyle(
          backgroundColor: selectedMood == moodNum ? selectedColour : initial ? initBg : unselectedColour
        ),
        onPressed: () => onClick(),
        icon: Icon(icon,
          size: 40,
          color: iconColour,
        )
      ),
    );
  } 
}



void checkinDialog(context) async {
    //show checkin dialog/happiness questionnaire dialog if applicable
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastIso = prefs.getString('last_checkin');
    String? endDay = prefs.getString('end_day');

    if (endDay != null && DateTime.now().isAfter(DateTime.parse(endDay))) {
      //show final happiness questionnaires dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('The study period is over!',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10,),
                  Text('Thank you for your participation, we greatly appreciate it. ',
                    textAlign: TextAlign.center,
                  ),
                  Text('Please fill out this final set of questionnaires. After filling out these questionnaires, you will no longer be able to access the app.',
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setBool('final_questionnaires_started', true);
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => QuestionnairePage(number: 2,)));
                      },
                      child: Text('Continue to Questionnaires',
                        textAlign: TextAlign.center,
                      )
                    ),
                  )
                ],
              ),
            ),
          );
        }
      );
    } else if (lastIso == null || !DateUtils.isSameDay(DateTime.parse(lastIso), DateTime.now())) {

      //show the dialog
      showDialog(
        context: context,
        barrierDismissible: false, 
        builder: (BuildContext context)  {
          return CheckinPopup();
        }
      );

      //update that it's been seen
      prefs.setString('last_checkin', DateTime.now().toIso8601String());
    }
  }


void showLoginDialog({required BuildContext context, required String header, required Function onSubmit, required TextEditingController username, required TextEditingController pw, required String submitButton, bool newItem=false, TextEditingController? newCon}) {
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
                  newItem ? Text('Old Password: ') : Text('Password: '),
                  Expanded(
                    child: TextFormField(
                      controller: pw,
                      obscureText: true,
                    ),
                  )
                ],
              ),
              //change password if applicable
              newItem ? Row(
                children: [
                  Text('New Password: '),
                  Expanded(
                    child: TextFormField(
                      controller: newCon,
                      obscureText: true,
                    ),
                  )
                ],
              ) : Container(),
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
                      onPressed: () {
                        if (newCon != null) {
                          onSubmit(username, pw, newCon);
                        } else {
                          onSubmit(username, pw);
                        }
                      },
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