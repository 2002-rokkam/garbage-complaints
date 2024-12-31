// authority/WagesSectionScreen.dart
// import 'package:flutter/material.dart';

// class WagesSectionScreen extends StatefulWidget {
//   const WagesSectionScreen({super.key});

//   @override
//   _WagesSectionScreenState createState() => _WagesSectionScreenState();
// }

// class _WagesSectionScreenState extends State<WagesSectionScreen> {
//   DateTime? _selectedMonth;
//   final List<Map<String, dynamic>> _wageReceipts = [];

//   final TextEditingController _amountController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();

//   void _selectMonth(BuildContext context) async {
//     final DateTime now = DateTime.now();
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedMonth ?? now,
//       firstDate: DateTime(now.year - 5),
//       lastDate: DateTime(now.year + 5),
//       initialDatePickerMode: DatePickerMode.year,
//     );
//     if (picked != null && picked != _selectedMonth) {
//       setState(() {
//         _selectedMonth = DateTime(picked.year, picked.month);
//       });
//     }
//   }

//   void _addReceipt() {
//     if (_amountController.text.isEmpty || _selectedMonth == null) {
//       _showError("Please enter all details.");
//       return;
//     }

//     setState(() {
//       _wageReceipts.add({
//         'month': _selectedMonth!,
//         'amount': double.tryParse(_amountController.text) ?? 0.0,
//         'description': _descriptionController.text,
//       });
//     });

//     _amountController.clear();
//     _descriptionController.clear();
//     _showSuccess("Receipt added successfully!");
//   }

//   void _showError(String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Error"),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("OK"),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showSuccess(String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Success"),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("OK"),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Wages Section"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const Text(
//               "Select Month:",
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//             const SizedBox(height: 8),
//             ElevatedButton(
//               onPressed: () => _selectMonth(context),
//               child: Text(_selectedMonth == null
//                   ? "Pick a Month"
//                   : "${_selectedMonth!.month}/${_selectedMonth!.year}"),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               "Add Wage Receipt:",
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _amountController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 labelText: "Amount",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _descriptionController,
//               decoration: const InputDecoration(
//                 labelText: "Description (Optional)",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _addReceipt,
//               child: const Text("Add Receipt"),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               "Wage Receipts:",
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//             const SizedBox(height: 8),
//             Expanded(
//               child: _wageReceipts.isEmpty
//                   ? const Center(child: Text("No receipts added yet."))
//                   : ListView.builder(
//                       itemCount: _wageReceipts.length,
//                       itemBuilder: (context, index) {
//                         final receipt = _wageReceipts[index];
//                         return Card(
//                           elevation: 4,
//                           margin: const EdgeInsets.symmetric(vertical: 8),
//                           child: ListTile(
//                             title: Text(
//                               "${receipt['month'].month}/${receipt['month'].year}",
//                               style:
//                                   const TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             subtitle: Text(
//                                 "Amount: \$${receipt['amount'].toStringAsFixed(2)}\n${receipt['description']}"),
//                           ),
//                         );
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
