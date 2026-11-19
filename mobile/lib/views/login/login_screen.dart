import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eventpass/localization/app_localization_context.dart';
import 'package:eventpass/models/request/auth/LoginRequest.dart';
import 'package:eventpass/models/response/auth/AuthResponse.dart';
import 'package:eventpass/models/states.dart';
import 'package:eventpass/network/api_state_model.dart';
import 'package:eventpass/providers/api_auth_notifier.dart';
import 'package:eventpass/providers/home_screen_notifier.dart';
import 'package:eventpass/route/routes.dart';
import 'package:eventpass/utils/colors.dart';
import 'package:eventpass/utils/utils.dart';
import 'package:eventpass/widgets/button_widget/elevated_button_widget.dart';
import 'package:eventpass/widgets/loading_widget.dart';
import 'package:eventpass/widgets/text_field_widget/customizable_textfield.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;
    ref.read(apiAuthNotifierProvider.notifier).apiLogin(
          LoginRequest(email: emailController.text.trim(), password: passwordController.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    // React to API state changes (side effects only — navigation, toasts, dialogs).
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
                Icon(Icons.confirmation_number_outlined, color: context.accent(primaryColor), size: 48.sp),
                SizedBox(height: 16.h),
                Text(loc.text_welcome_back, style: Theme.of(context).textTheme.headlineMedium),
                SizedBox(height: 8.h),
                Text(loc.text_login_description, style: Theme.of(context).textTheme.bodyMedium),
                SizedBox(height: 32.h),
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
                  validator: (v) => Utils.validateFields(v, errorText: loc.password_required),
                  onFieldSubmit: (_) => _submit(),
                ),
                SizedBox(height: 32.h),
                ElevatedButtonWithoutIcon(text: loc.text_login, onPressed: _submit),
                SizedBox(height: 12.h),
                Center(
                  child: TextButton(
                    // Replace, not push: only one auth screen listens to the auth notifier at a time.
                    onPressed: () => Navigator.of(context).pushReplacementNamed(Routes.REGISTER),
                    child: Text(loc.text_no_account),
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
