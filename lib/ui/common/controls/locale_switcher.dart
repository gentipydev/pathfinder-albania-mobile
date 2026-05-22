import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/features/settings/bloc/settings_bloc.dart';
import 'package:travel_buddy/features/settings/bloc/settings_event.dart';

class LocaleSwitcher extends StatelessWidget {
  const LocaleSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.select<SettingsBloc, String?>((b) => b.state.currentLocale);
    void handleSwapLocale() {
      final newLocale = Locale(locale == 'en' ? 'sq' : 'en');
      context.read<SettingsBloc>().add(SettingsLocaleChangeRequested(newLocale));
    }

    return AppBtn.from(
      text: $strings.localeSwapButton,
      onPressed: handleSwapLocale,
      padding: EdgeInsets.all($styles.insets.sm),
    );
  }
}
