import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MonthSelector',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Content(),
    );
  }
}

class Content extends StatelessWidget {
  const Content({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MonthSelector'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('show'),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: SizedBox(
                  height: 330,
                  width: 300,
                  child: MonthSelector(
                    startDate: DateTime(2019, 4),
                    endDate: DateTime(2022, 10),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MonthSelector extends StatefulWidget {
  const MonthSelector({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  final DateTime startDate;
  final DateTime endDate;

  @override
  State<MonthSelector> createState() => _MonthSelectorState();
}

class _MonthSelectorState extends State<MonthSelector> {
  late DateTime selectedDate;

  List<DateTime> selectableMonthList = [];
  List<List<DateTime>> monthList = [];
  static final monthNumbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
  late List<int> yearList;
  int currentPageNumber = 0;

  void incrementPageNumber() {
    setState(() {
      currentPageNumber++;
    });
  }

  void decrementPageNumber() {
    setState(() {
      currentPageNumber--;
    });
  }

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime(2020, 1);
    var month = widget.startDate;
    while (!selectableMonthList.contains(widget.endDate)) {
      selectableMonthList.add(month);
      month = DateTime(month.year, month.month + 1, month.day);
    }
    yearList = selectableMonthList
        .map((month) => month.year)
        .toList()
        .toSet()
        .toList();
    monthList = yearList
        .map((year) =>
            monthNumbers.map((month) => DateTime(year, month, 1)).toList())
        .toList();
    final initialPageNumber = monthList.indexWhere(
        (months) => months.any((month) => month.year == selectedDate.year));
    currentPageNumber = initialPageNumber;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        YearGridHeader(
          year: monthList[currentPageNumber].first.year,
          canBack: currentPageNumber > 0,
          onPressedBackButton: decrementPageNumber,
          canForward: currentPageNumber < monthList.length - 1,
          onPressedForwardButton: incrementPageNumber,
        ),
        Expanded(
          child: YearGridBody(
            monthList: monthList[currentPageNumber],
            selectedMonth: selectedDate,
            onTapMonth: (date) {
              setState(() {
                selectedDate = date;
                currentPageNumber = monthList.indexWhere(
                    (months) => months.any((month) => month.year == date.year));
              });
            },
            selectableMonthList: selectableMonthList,
          ),
        ),
        Row(
          children: [
            const Spacer(),
            TextButton(
              child: const Text('TODAY'),
              onPressed: () {
                setState(() {
                  currentPageNumber = monthList.indexWhere((months) =>
                      months.any((month) => month.year == DateTime.now().year));
                  selectedDate =
                      DateTime(DateTime.now().year, DateTime.now().month, 1);
                });
              },
            )
          ],
        ),
      ],
    );
  }
}

class YearGridHeader extends StatelessWidget {
  const YearGridHeader({
    super.key,
    required this.year,
    required this.canBack,
    required this.onPressedBackButton,
    required this.canForward,
    required this.onPressedForwardButton,
  });
  final int year;
  final void Function() onPressedBackButton;
  final bool canBack;
  final bool canForward;
  final void Function() onPressedForwardButton;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(year.toString()),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up),
          onPressed: !canBack ? null : () => onPressedBackButton(),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: !canForward ? null : () => onPressedForwardButton(),
        ),
      ],
    );
  }
}

class YearGridBody extends StatelessWidget {
  const YearGridBody({
    super.key,
    required this.selectableMonthList,
    required this.monthList,
    required this.selectedMonth,
    required this.onTapMonth,
  });

  final List<DateTime> selectableMonthList;
  final List<DateTime> monthList;
  final DateTime selectedMonth;
  final void Function(DateTime) onTapMonth;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      children: monthList
          .map(
            (month) => GestureDetector(
              onTap: !selectableMonthList.contains(month)
                  ? null
                  : () => onTapMonth(month),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: selectedMonth == month
                        ? Theme.of(context).primaryColor
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${month.month.toString()}月',
                      style: selectableMonthList.contains(month)
                          ? Theme.of(context).textTheme.bodyMedium
                          : Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
