import 'package:flutter/material.dart';
import '../../../domain/entities/status_item.dart';
import '../../../presentation/widgets/template/custom_app_bar.dart';
import 'package:meetclic/domain/entities/menu_tab_up_item.dart';

class FullScreenPage extends StatefulWidget {
  final String title;
  final List<MenuTabUpItem> itemsStatus;

  const FullScreenPage({
    super.key,
    required this.title,
    required this.itemsStatus,
  });

  @override
  State<FullScreenPage> createState() => _FullScreenPageState();
}

class _FullScreenPageState extends State<FullScreenPage> {
  String? myAnswer;
  String? theirAnswer;
  double priority = 0.5;
  bool isPublic = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorPrimary = theme.colorScheme.primary;
    final colorSecondary = theme.colorScheme.secondary;
    final colorOnSurface = theme.colorScheme.onSurface;
    final size = MediaQuery.of(context).size;

    final TextStyle titleStyle = theme.textTheme.titleSmall!.copyWith(
      color: colorPrimary,
      fontSize: size.width * 0.035,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: widget.title, items: widget.itemsStatus),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: size.height * 0.9),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Could you date people on drugs", style: titleStyle),
                const SizedBox(height: 16),
                _buildResponseRow("Yes", "Yes", titleStyle),
                _buildResponseRow("No", "No", titleStyle),
                const SizedBox(height: 24),

                Text("Priority", style: titleStyle),
                Slider(
                  value: priority,
                  onChanged: (val) => setState(() => priority = val),
                  activeColor: colorPrimary,
                  inactiveColor: colorPrimary.withOpacity(0.3),
                  thumbColor: colorSecondary,
                ),

                const SizedBox(height: 16),
                Text("Details", style: titleStyle),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text("Explanation", style: titleStyle),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: colorSecondary,
                    size: 18,
                  ),
                  onTap: () {},
                  hoverColor: colorPrimary.withOpacity(0.1),
                  splashColor: colorSecondary.withOpacity(0.2),
                ),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text("Answer in public", style: titleStyle),
                  value: isPublic,
                  onChanged: (val) => setState(() => isPublic = val),
                  activeColor: colorPrimary,
                  activeTrackColor: colorPrimary.withOpacity(0.5),
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey.withOpacity(0.4),
                ),

                const Spacer(),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorPrimary,
                      foregroundColor: colorOnSurface,
                      splashFactory: InkRipple.splashFactory,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ).copyWith(
                      overlayColor: MaterialStateProperty.resolveWith<Color?>(
                            (states) {
                          if (states.contains(MaterialState.hovered)) {
                            return colorSecondary.withOpacity(0.1);
                          }
                          if (states.contains(MaterialState.pressed)) {
                            return colorSecondary.withOpacity(0.2);
                          }
                          return null;
                        },
                      ),
                    ),
                    onPressed: () {},
                    child: Text("Submit answer", style: titleStyle.copyWith(color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colorPrimary),
                      foregroundColor: colorPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ).copyWith(
                      overlayColor: MaterialStateProperty.resolveWith<Color?>(
                            (states) {
                          if (states.contains(MaterialState.hovered)) {
                            return colorPrimary.withOpacity(0.1);
                          }
                          if (states.contains(MaterialState.pressed)) {
                            return colorPrimary.withOpacity(0.2);
                          }
                          return null;
                        },
                      ),
                    ),
                    onPressed: () {},
                    child: Text("Skip this question", style: titleStyle),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResponseRow(String valueMe, String valueThem, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(valueMe, style: style)),
          _buildRadio("Me", valueMe),
          _buildRadio("Them", valueThem, isThem: true),
        ],
      ),
    );
  }

  Widget _buildRadio(String type, String value, {bool isThem = false}) {
    final theme = Theme.of(context);
    final selected = isThem ? theirAnswer : myAnswer;

    return Radio<String>(
      value: value,
      groupValue: selected,
      onChanged: (val) {
        setState(() {
          if (isThem) {
            theirAnswer = val;
          } else {
            myAnswer = val;
          }
        });
      },
      activeColor: theme.colorScheme.primary,
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return theme.colorScheme.primary;
        }
        return theme.colorScheme.primary.withOpacity(0.4);
      }),
      overlayColor: MaterialStateProperty.all(
        theme.colorScheme.primary.withOpacity(0.1),
      ),
      splashRadius: 16,
    );
  }

  String _priorityLabel(double value) {
    if (value <= 0.3) return "Little";
    if (value <= 0.7) return "Some extent";
    return "High";
  }
}
