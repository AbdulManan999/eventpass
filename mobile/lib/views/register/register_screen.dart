import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eventpass/localization/app_localization_context.dart';
import 'package:eventpass/models/request/auth/RegisterRequest.dart';
import 'package:eventpass/models/response/auth/AuthResponse.dart';
import 'package:eventpass/models/states.dart';
import 'package:eventpass/network/api_state_model.dart';
import 'package:eventpass/providers/api_auth_notifier.dart';
import 'package:eventpass/providers/home_screen_notifier.dart';
import 'package:eventpass/route/routes.dart';
import 'package:eventpass/utils/utils.dart';
import 'package:eventpass/widgets/button_widget/elevated_button_widget.dart';
import 'package:eventpass/widgets/loading_widget.dart';
import 'package:eventpass/widgets/text_field_widget/customizable_textfield.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends ConsumerState<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;
    ref.read(apiAuthNotifierProvider.notifier).apiRegister(
          RegisterRequest(
            name: nameController.text.trim(),
            email: emailController.text.trim(),
            password: passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ApiStatesModel>(apiAuthNotifierProvider, (_, s) {
      switch (s.states) {
        case States.ERROR:
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.message)));
          break;
        case States.DATA:
          if (s.data is AuthResponse) {
            ref.read(currentUserProvider.notifier).state = (s.data as AuthResponse).user;
            Navigator.of(context).pushNamedAndRemoveUntil(Routes.HOME, (_) => false);
          }
          break;
        default:
          break;
      }
    });

    return Stack(children: [_mainLayout(), const LoadingWidget()]);
  }

  Widget _mainLayout() {
    final loc = context.loc;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 32.h),
                Text(loc.text_create_account, style: Theme.of(context).textTheme.headlineMedium),
                SizedBox(height: 8.h),
                Text(loc.text_register_description, style: Theme.of(context).textTheme.bodyMedium),
                SizedBox(height: 32.h),
                CustomizableTextField(
                  title: loc.name_label,
                  isRequired: true,
                  controller: nameController,
                  focusNode: nameFocusNode,
                  hintText: loc.name_hint,
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (v) => Utils.validateFields(v, errorText: loc.name_required),
                  onFieldSubmit: (_) => emailFocusNode.requestFocus(),
                ),
                SizedBox(height: 16.h),
                CustomizableTextField(
                  title: loc.email_label,
                  isRequired: true,
                  controller: emailController,
                  focusNode: emailFocusNode,
                  hintText: loc.email_hint,
                  prefixIcon: Icons.email_outlined,
                  textInputType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) => Utils.validateEmail(v, requiredText: loc.email_required, invalidText: loc.email_invalid),
                  onFieldSubmit: (_) => passwordFocusNode.requestFocus(),
                ),
                SizedBox(height: 16.h),
                CustomizableTextField(
                  title: loc.password_label,
                  isRequired: true,
                  controller: passwordController,
                  focusNode: passwordFocusNode,
                  hintText: '********',
                  prefixIcon: Icons.lock_outline,
                  hideText: ref.watch(isShowPasswordProvider),
                  suffixIcon: ref.watch(isShowPasswordProvider) ? Icons.visibility_off : Icons.visibility,
                  onSuffixIconPressed: () => ref.read(isShowPasswordProvider.notifier).update((v) => !v),
                  validator: (v) {
                    if (v == null || v.isEmpty) return loc.password_required;
                    return v.length < 8 ? loc.password_min : null;
                  },
                  onFieldSubmit: (_) => _submit(),
                ),
                SizedBox(height: 32.h),
                ElevatedButtonWithoutIcon(text: loc.text_register, onPressed: _submit),
                SizedBox(height: 12.h),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pushReplacementNamed(Routes.LOGIN),
                    child: Text(loc.text_have_account),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
