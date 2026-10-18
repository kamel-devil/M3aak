import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:kk_thotix_m3aak/theme/app_palette.dart';
import 'package:kk_thotix_m3aak/common/glass/glass_widgets.dart';
import 'package:kk_thotix_m3aak/features/support/controllers/support_ticket_controller.dart';
import 'package:kk_thotix_m3aak/features/support/domain/models/support_ticket_body.dart';
import 'package:kk_thotix_m3aak/features/support/widgets/support_ticket_type_widget.dart';
import 'package:kk_thotix_m3aak/localization/language_constrants.dart';
import 'package:kk_thotix_m3aak/utill/custom_themes.dart';
import 'package:kk_thotix_m3aak/utill/dimensions.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_app_bar_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:kk_thotix_m3aak/common/basewidget/custom_textfield_widget.dart';
import 'package:provider/provider.dart';

class AddTicketScreen extends StatefulWidget {
  final TicketModel ticketModel;
  final int categoryIndex;
  const AddTicketScreen({super.key, required this.ticketModel, required this.categoryIndex});

  @override
  AddTicketScreenState createState() => AddTicketScreenState();
}

class AddTicketScreenState extends State<AddTicketScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _subjectNode = FocusNode();
  final FocusNode _descriptionNode = FocusNode();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final List<String> categories = ['Website problem', 'Partner request', 'Complaint', 'Info Inquiry'];

  @override
  void initState() {
    super.initState();
    Provider.of<SupportTicketController>(context, listen: false).setInitialSelectedPriority();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: getTranslated('add_new_ticket', context),
        onBackPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: Consumer<SupportTicketController>(
        builder: (context, supportTicketProvider, _) {
          return ListView(physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16), children: [


            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TypeButton(icon: widget.ticketModel.icon, title: widget.ticketModel.title),
            ),



            Text(getTranslated('priority', context) ?? '',
                style: textBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                for (int i = 0; i < supportTicketProvider.priority.length; i++)
                  ChoiceChip(
                    label: Text(getTranslated(supportTicketProvider.priority[i], context) ?? supportTicketProvider.priority[i]),
                    selected: supportTicketProvider.selectedPriorityIndex == i,
                    onSelected: (_) => supportTicketProvider.setSelectedPriority(i),
                    showCheckmark: false,
                    labelStyle: textBold.copyWith(
                      fontSize: Dimensions.fontSizeSmall + 1,
                      color: supportTicketProvider.selectedPriorityIndex == i ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    selectedColor: Theme.of(context).primaryColor,
                    backgroundColor: Theme.of(context).cardColor,
                    side: BorderSide(color: supportTicketProvider.selectedPriorityIndex == i
                        ? Theme.of(context).primaryColor : AppPalette.glassBorder(context)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  ),
              ]),
            ),


            CustomTextFieldWidget(
              focusNode: _subjectNode,
              nextFocus: _descriptionNode,
              required: true,
              inputAction: TextInputAction.next,
              labelText: '${getTranslated('subject', context)}',
              hintText: getTranslated('write_your_subject', context),
              controller: _subjectController,),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            CustomTextFieldWidget(
              required: true,
              focusNode: _descriptionNode,
              inputAction: TextInputAction.newline,
              hintText: getTranslated('issue_description', context),
              inputType: TextInputType.multiline,
              controller: _descriptionController,
              labelText: '${getTranslated('description', context)}',
              maxLines: 5),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),


            GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount : supportTicketProvider.pickedImageFileStored.length + 1 ,
                itemBuilder: (BuildContext context, index){
                  return index ==  supportTicketProvider.pickedImageFileStored.length ?
                  InkWell(onTap: ()=> supportTicketProvider.pickMultipleImage(false,),
                    child: DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        strokeWidth: 1.5,
                        dashPattern: const [6,4],
                        color: Theme.of(context).primaryColor.withValues(alpha: .5),
                        radius: const Radius.circular(16),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        color: AppPalette.tint(context),
                        child: Icon(Icons.add_photo_alternate_outlined, color: Theme.of(context).primaryColor, size: 26),
                      ))) :
                  Stack(children: [
                    Padding(padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                      child: Container(decoration: const BoxDecoration(color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(20)),),
                        child: ClipRRect(borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeExtraSmall)),
                          child:  Image.file(File(supportTicketProvider.pickedImageFileStored[index].path),
                            width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.width/4.3, fit: BoxFit.cover)))),


                    Positioned(top:0,right:0,
                      child: InkWell(onTap :() => supportTicketProvider.pickMultipleImage(true, index: index),
                        child: Container(decoration: const BoxDecoration(color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault))),
                            child: const Padding(padding: EdgeInsets.all(4.0),
                              child: Icon(Icons.delete_forever_rounded,color: Colors.red,size: 15)))))]);
                }, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10)),
          ]);
        }),

      bottomNavigationBar: Provider.of<SupportTicketController>(context).isLoading ?
      Row(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 40, height: 40, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))),
        ],
      ) :
      Consumer<SupportTicketController>(key: _scaffoldKey,
        builder: (context, supportTicketProvider, _) => SafeArea(top: false, child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withValues(alpha: .96),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(top: BorderSide(color: AppPalette.glassBorder(context))),
            ),
            child: PressableScale(
              onTap: () {
              if (_subjectController.text.isEmpty) {
                showCustomSnackBar(getTranslated('subject_is_required', context), context);
              } else if (_descriptionController.text.isEmpty) {
                showCustomSnackBar(getTranslated('description_is_required', context), context);
              } else if (supportTicketProvider.selectedPriorityIndex == -1) {
                showCustomSnackBar(getTranslated('priority_is_required', context), context);
              } else {
                SupportTicketBody supportTicketModel = SupportTicketBody(categories[widget.categoryIndex],
                    _subjectController.text, _descriptionController.text, supportTicketProvider.selectedPriorityEn);
                supportTicketProvider.createSupportTicket(supportTicketModel);
              }
            },
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppPalette.brandGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: AppPalette.primary.withValues(alpha: .35), blurRadius: 18, offset: const Offset(0, 8))],
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  
                  Text(getTranslated('submit', context) ?? '', style: textBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge)),
                ]),
              ),
            ),
          )),
      ),
    );
  }
}
