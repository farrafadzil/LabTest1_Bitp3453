import 'package:flutter/material.dart';
import '../Controller/SQLiteDB.dart';

void main() {
  runApp(BMICalculator());
}

class BMICalculator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BMICalculatorScreen(),
    );
  }
}

class BMICalculatorScreen extends StatefulWidget {
  @override
  _BMICalculatorScreenState createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> {
  late BMIDatabase _bmiDatabase;
  TextEditingController nameController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  double bmiResult = 0.0;
  String bmiStatus = '';

  int selectedGender = 0; // 0 for male, 1 for female

  @override
  void initState(){
    super.initState();
    _bmiDatabase = BMIDatabase();
    _retrievePreviousBMI();
  }

  Future<void> _retrievePreviousBMI() async {
    Map<String, dynamic>? previousBMI = await _bmiDatabase.getPreviousBMI();
    if (previousBMI != null) {
      setState(() {
        nameController.text = previousBMI['username'] ?? '';
        heightController.text = previousBMI['height'].toString() ?? '';
        weightController.text = previousBMI['weight'].toString() ?? '';
        selectedGender = previousBMI['gender'] == 'Male' ? 0 : 1;
        // You might also set other UI elements based on retrieved data
      });
    }
  }

  void calculateBMI() {
    double height = double.parse(heightController.text);
    double weight = double.parse(weightController.text);

    if (height > 0 && weight > 0) {
      double heightInMeters = height / 100; // Convert height to meters
      double bmi = weight / (heightInMeters * heightInMeters);

      setState(() {
        bmiResult = bmi;

        if (selectedGender == 0) {
          // Male BMI status
          if (bmi < 18.5) {
            bmiStatus = 'Underweight. Careful during strong wind!';
          } else if (bmi >= 18.5 && bmi < 25.0) {
            bmiStatus = 'That’s ideal! Please maintain';
          } else if (bmi >= 25.0 && bmi < 30.0) {
            bmiStatus = 'Overweight! Work out please';
          } else {
            bmiStatus = 'Whoa Obese! Dangerous mate!';
          }
        } else {
          // Female BMI status
          if (bmi < 16.0) {
            bmiStatus = 'Underweight. Careful during strong wind!';
          } else if (bmi >= 16.0 && bmi < 22.0) {
            bmiStatus = 'That’s ideal! Please maintain';
          } else if (bmi >= 22.0 && bmi < 27.0) {
            bmiStatus = 'Overweight! Work out please';
          } else {
            bmiStatus = 'Whoa Obese! Dangerous mate!';
          }
        }

        _bmiDatabase.saveBMI(
          nameController.text,
          double.parse(weightController.text),
          double.parse(heightController.text),
          selectedGender == 0 ? 'Male' : 'Female',
          bmiStatus,
        );
      });
    } else {
    setState(() {
    bmiResult = 0.0;
    bmiStatus = '';
    });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Enter Full Name',
              ),
            ),
            SizedBox(height: 3.0),
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter height in cm',
              ),
            ),
            SizedBox(height: 3.0),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter weight in kg',
              ),
            ),
            SizedBox(height: 3.0),
            Row(
              children: [
                Text('Gender'),
                SizedBox(width: 10),
                Radio(
                  value: 0,
                  groupValue: selectedGender,
                  onChanged: (int? value) {
                    setState(() {
                      selectedGender = value!;
                    });
                  },
                ),
                Text('Male'),
                Radio(
                  value: 1,
                  groupValue: selectedGender,
                  onChanged: (int? value) {
                    setState(() {
                      selectedGender = value!;
                    });
                  },
                ),
                Text('Female'),
              ],
            ),
            SizedBox(height: 5.0),
            ElevatedButton(
              onPressed: calculateBMI,
              child: Text('Calculate BMI'),
            ),
            SizedBox(height: 15),
            Text(
              'Your BMI is: ${bmiResult.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 5),
            Text(
              'BMI Status: $bmiStatus',
              style: TextStyle(fontSize: 18)
            )
          ],
        ),
      ),
    );
  }
}
