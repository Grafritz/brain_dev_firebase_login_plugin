import 'package:brain_dev_tools/I10n/localization_constants.dart';
import 'package:brain_dev_tools/tools/my_elevated_button.dart';
import 'package:flutter/material.dart';

class DeleteProfilDialog extends StatefulWidget {
  const DeleteProfilDialog({super.key});

  @override
  State<DeleteProfilDialog> createState() => _DeleteProfilDialogState();
}

class _DeleteProfilDialogState extends State<DeleteProfilDialog> {
  String? raison = '';
  bool next = false;
  bool _showProgressBar = false;
  //late UserBloc userBloc = BlocProvider.of<UserBloc>(context);

  @override
  Widget build(BuildContext context) {
    //String groupValue = '${label_msg_douteConfidentiality}';
    return SimpleDialog(
      //backgroundColor: Colors.white70,
      title: Text(tr('label_avant_de_partir')),
      // textScaleFactor: 1.4,
      contentPadding: const EdgeInsets.all(10.0),
      children: <Widget>[
        if (!next)
          Column(
            children: [
              Text(tr('label_raisonDeleteAccountText')),
              RadioListTile<String>(
                title: Text('${tr('label_msg_douteConfidentiality')}'),
                value: '${tr('label_msg_douteConfidentiality')}',
                groupValue: raison,
                onChanged: (String? value) {
                  setState(() {
                    raison = value;
                  });
                },
              ),
              RadioListTile<String>(
                title: Text('${tr('label_msg_tropcomplique_tropLent')}'),
                value: '${tr('label_msg_tropcomplique_tropLent')}',
                groupValue: raison,
                onChanged: (String? value) {
                  setState(() {
                    raison = value;
                  });
                },
              ),
              RadioListTile<String>(
                title: Text('${tr('label_ne_pas_repondre')}'),
                value: '${tr('label_ne_pas_repondre')}',
                groupValue: raison,
                onChanged: (String? value) {
                  setState(() {
                    raison = value;
                  });
                },
              ),
            ],
          ),
        if (next) Text(tr('label_confirmationRaisonDeleteAccountTxt')),
        Container(
          height: 20.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MyElevatedButton(
              //style: ToolsWidget().elevatedButtonNormal(),
              child: Text(tr('label_Annuler').toUpperCase()),
              onPressed: () => Navigator.of(context).pop(),
            ),
            if (!next && raison != '')
              MyElevatedButton(
                style: elevatedButtonNormal(),
                child: Text(tr('label_suivant').toUpperCase()),
                onPressed: () {
                  setState(() {
                    next = true;
                  });
                },
              ),
            if (next)
              ElevatedButton.icon(
                style: elevatedButtonNormal(backgroundColor: Colors.teal),
                icon: (_showProgressBar)
                    ? const CircularProgressIndicator(
                        backgroundColor: Colors.white,
                        strokeWidth: 3,
                      )
                    : const Icon(Icons.send),
                label: Text(tr('label_Valider').toUpperCase()),
                onPressed: () {
                  Navigator.of(context).pop(raison);
                  //this.deleteAccount();
                },
              ),
          ],
        ),
      ],
    );
  }

  setShowCircularProgressIndicator({bool show = true}) {
    setState(() {
      _showProgressBar = show;
    });
  }
}
