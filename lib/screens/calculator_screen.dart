import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_expressions/math_expressions.dart';

import '../main.dart'; // Import để sử dụng các hằng số màu
import '../widgets/calculator_button.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _equation = "0"; // Biểu thức tính toán (dòng nhỏ ở trên)
  String _result = "0"; // Kết quả (dòng lớn ở dưới)

  /// Xử lý khi một nút được nhấn
  void _buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        // Xóa tất cả
        _equation = "0";
        _result = "0";
      } else if (buttonText == "CE") {
        // Xóa ký tự cuối cùng (Backspace)
        if (_equation.length > 1) {
          _equation = _equation.substring(0, _equation.length - 1);
        } else {
          _equation = "0";
        }
      } else if (buttonText == "=") {
        // Thực hiện tính toán
        try {
          // Thay thế các ký tự hiển thị bằng ký tự toán học chuẩn
          String finalEquation = _equation.replaceAll('×', '*').replaceAll('÷', '/');

          // Xử lý trường hợp biểu thức kết thúc bằng một toán tử (ví dụ: "5+")
          // hoặc nhiều toán tử (ví dụ: "5+*")
          // Bằng cách xóa các toán tử thừa ở cuối trước khi tính toán.
          while (finalEquation.endsWith('*') || finalEquation.endsWith('/') || finalEquation.endsWith('+') || finalEquation.endsWith('-')) {
            finalEquation = finalEquation.substring(0, finalEquation.length - 1);
          }

          // Sử dụng thư viện math_expressions để tính toán
          Parser p = Parser();
          Expression exp = p.parse(finalEquation);
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);

          // Hiển thị kết quả, nếu là số nguyên thì không hiển thị phần thập phân .0
          _result = eval.toStringAsFixed(eval.truncateToDouble() == eval ? 0 : 2);
        } catch (e) {
          // Xử lý lỗi, ví dụ chia cho 0 hoặc biểu thức không hợp lệ
          _result = "Lỗi";
        }
      } else if (buttonText == "±") {
        // Đổi dấu
        if (_equation != "0") {
          if (_equation.startsWith('-')) {
            _equation = _equation.substring(1);
          } else {
            _equation = '-$_equation';
          }
        }
      } else {
        // Xử lý nhập số và toán tử
        if (_equation == "0" && buttonText != '.') {
          _equation = buttonText;
        } else {
          // Ngăn không cho nhập nhiều dấu chấm trong một số
          if (buttonText == '.' && _equation.contains('.')) {
            // Tìm toán tử cuối cùng
            final operators = ['+', '−', '×', '÷'];
            int lastOperatorIndex = -1;
            for (var op in operators) {
              lastOperatorIndex = _equation.lastIndexOf(op) > lastOperatorIndex ? _equation.lastIndexOf(op) : lastOperatorIndex;
            }
            // Nếu không có dấu chấm nào sau toán tử cuối cùng, thì không làm gì cả
            if (_equation.substring(lastOperatorIndex + 1).contains('.')) {
              return;
            }
          }
          _equation += buttonText;
        }
      }
    });
  }

  /// Danh sách các nút trên máy tính
  final List<String> buttons = [
    'C', 'CE', '%', '÷',
    '7', '8', '9', '×',
    '4', '5', '6', '−',
    '1', '2', '3', '+',
    '±', '0', '.', '=',
  ];

  /// Xác định màu cho từng nút
  Color _getButtonColor(String buttonText) {
    if (['÷', '×', '−', '+', '='].contains(buttonText)) {
      return accentColor; // Màu cam cho toán tử và dấu bằng
    }
    return secondaryColor; // Màu xám cho các nút còn lại
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              // Vùng hiển thị kết quả và biểu thức
              Expanded(
                flex: 2, // Chiếm nhiều không gian hơn
                child: Container(
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Hiển thị biểu thức (lịch sử)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          _equation,
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            color: whiteColor.withOpacity(0.7),
                          ),
                          maxLines: 1,
                          // overflow is not needed with SingleChildScrollView
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Hiển thị kết quả
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          _result,
                          style: GoogleFonts.roboto(
                            fontSize: 48, // Tăng kích thước font cho dễ đọc
                            fontWeight: FontWeight.w500, // Medium
                          ),
                          maxLines: 1,
                          // overflow is not needed with SingleChildScrollView
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Vùng các nút bấm
              Expanded(
                flex: 3, // Chiếm nhiều không gian hơn
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(), // Vô hiệu hóa cuộn
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // 4 cột
                    crossAxisSpacing: 16.0, // Khoảng cách ngang
                    mainAxisSpacing: 16.0, // Khoảng cách dọc
                  ),
                  itemCount: buttons.length,
                  itemBuilder: (BuildContext context, int index) {
                    final buttonText = buttons[index];
                    return CalculatorButton(
                      label: buttonText,
                      onTap: () => _buttonPressed(buttonText),
                      backgroundColor: _getButtonColor(buttonText),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}