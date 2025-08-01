import 'package:flutter/material.dart';
import '../../widgets/atoms/scheduling/verified_label_atom.dart';
import '../../widgets/molecules/scheduling/schedule_row_molecule.dart';
import 'package:meetclic/domain/models/day_schedule.dart';

class ScheduleModalOrganism extends StatelessWidget {
  final List<DaySchedule> schedule;

  const ScheduleModalOrganism({
    super.key,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: const [
              Text("Horario",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(width: 12),
              VerifiedLabelAtom(text: "Verified 1 month ago"),
              Spacer(),
              Icon(Icons.close),
            ],
          ),
          const SizedBox(height: 24),
          ...schedule.map((item) => ScheduleRowMolecule(
            day: item.day,
            status: item.isOpen ? item.timeRange : "Cerrado",
            isToday: item.isToday,
          )),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              print("Sugerir edición clicado");
            },
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Sugerir una edición",
                style: TextStyle(color: Colors.teal),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


