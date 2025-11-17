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
  String _equation = "0"; // Biểu thức (dòng trên)
  String _result = "0"; // Kết quả (dòng dưới)
  
  // [MỚI] Biến cờ để kiểm tra xem có cần reset màn hình không
  bool _shouldReset = false; 

  /// Xử lý logic khi nhấn nút
  void _buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        // 1. Nút xóa tất cả (Clear)
        _equation = "0";
        _result = "0";
        _shouldReset = false; // Reset cờ
      } 
      else if (buttonText == "CE") {
        // [ĐÃ XÓA] - Logic này sẽ được thay thế bằng logic cho "()"
      }
      else if (buttonText == "()") {
        // 2. [MỚI] Xử lý nút ngoặc đơn
        if (_shouldReset) {
          _equation = "(";
          _result = "0";
          _shouldReset = false;
        } else if (_equation == "0") {
          _equation = "(";
        } else {
          int openParenCount = '('.allMatches(_equation).length;
          int closeParenCount = ')'.allMatches(_equation).length;
          String lastChar = _equation.substring(_equation.length - 1);

          if (openParenCount > closeParenCount && (RegExp(r'[0-9]').hasMatch(lastChar) || lastChar == ')')) {
            _equation += ')';
          } else {
            if (RegExp(r'[0-9]').hasMatch(lastChar) || lastChar == ')') {
              _equation += '×('; // Tự động thêm phép nhân
            } else {
              _equation += '(';
            }
          }
        }
      } 
      else if (buttonText == "=") {
        // 3. Nút Bằng (=) - Tính toán
        _calculate();
      } 
      else if (buttonText == "±") {
        // 4. Đổi dấu âm/dương
        if (_equation != "0") {
          // Nếu vừa tính xong, lấy kết quả làm phương trình mới để đổi dấu
          if (_shouldReset) {
             _equation = _result;
             _shouldReset = false;
          }

          if (_equation.startsWith('-')) {
            _equation = _equation.substring(1);
          } else {
            _equation = '-$_equation';
          }
        }
      } 
      else if (_isOperator(buttonText)) {
        // 5. Xử lý khi bấm Toán tử (+, -, x, /)
        
        if (_shouldReset) {
          // [LOGIC QUAN TRỌNG]: Nếu vừa tính xong (có kết quả 10), bấm "+":
          // Phương trình sẽ thành "10+" để tính tiếp
          _equation = _result + buttonText;
          _shouldReset = false;
        } else {
          // Xử lý thay thế toán tử nếu người dùng bấm nhầm (VD: 5+ rồi bấm - thành 5-)
          if (_equation.isNotEmpty) {
             String lastChar = _equation.substring(_equation.length - 1);
             if (_isOperator(lastChar)) {
               // Thay thế toán tử cuối
               _equation = _equation.substring(0, _equation.length - 1) + buttonText;
             } else {
               _equation += buttonText;
             }
          }
        }
      } 
      else {
        // 6. Xử lý khi bấm Số hoặc Dấu chấm
        
        if (_shouldReset) {
          // [LOGIC QUAN TRỌNG]: Nếu vừa tính xong (có kết quả 10), bấm "2":
          // Reset lại từ đầu, phương trình thành "2" (bắt đầu phép tính mới)
          _equation = buttonText;
          _result = "0"; // Reset kết quả hiển thị về 0
          _shouldReset = false;
        } else {
          // Logic bình thường
          if (_equation == "0" && buttonText != '.') {
            _equation = buttonText;
          } else {
            // Kiểm tra dấu chấm: Không cho nhập 2 dấu chấm trong 1 số
            if (buttonText == '.' && _hasDecimalPointInLastNumber(_equation)) {
               return; 
            }
            _equation += buttonText;
          }
        }
      }
    });
  }

  /// Hàm thực hiện tính toán
  void _calculate() {
    try {
      String finalEquation = _equation
          // Thêm logic để xử lý các trường hợp như (5)2 -> (5)*2
          .replaceAllMapped(RegExp(r'\)(\d)'), (match) => ')*${match.group(1)}')
          .replaceAllMapped(RegExp(r'(\d)\('), (match) => '${match.group(1)}*(')
          // Xử lý trường hợp (a)(b) -> (a)*(b)
          .replaceAll(')(', ')*(')
          // Thay thế các ký tự hiển thị bằng ký tự tính toán
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('−', '-'); // Đảm bảo dùng dấu trừ chuẩn

      // Xóa các toán tử thừa ở cuối (VD: "5+" thành "5")
      while (_isOperator(finalEquation.substring(finalEquation.length - 1))) {
        finalEquation = finalEquation.substring(0, finalEquation.length - 1);
      }

      Parser p = Parser();
      Expression exp = p.parse(finalEquation);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      // Làm tròn kết quả (Xóa .0 nếu là số nguyên)
      _result = eval.toStringAsFixed(eval.truncateToDouble() == eval ? 0 : 4);
      
      // Cắt bớt số 0 thừa ở phần thập phân (VD: 2.5000 -> 2.5)
      if (_result.contains('.')) {
          _result = double.parse(_result).toString();
          if (_result.endsWith(".0")) {
            _result = _result.substring(0, _result.length - 2);
          }
      }

      // [MỚI] Đặt cờ reset = true để lần bấm phím sau biết đường xử lý
      _shouldReset = true;
      
      // Cập nhật lại phương trình hiển thị để người dùng thấy kết quả vừa tính
      // (Tùy chọn: Một số app máy tính sẽ để _equation = _result luôn)
      // Ở đây giữ nguyên _equation cũ để người dùng đối chiếu, nhưng khi bấm phím mới sẽ reset.

    } catch (e) {
      _result = "Lỗi";
      _shouldReset = true;
    }
  }

  /// Hàm phụ trợ: Kiểm tra xem ký tự có phải toán tử không
  bool _isOperator(String char) {
    return ['+', '-', '−', '×', '*', '÷', '/'].contains(char);
  }

  /// Hàm phụ trợ: Kiểm tra số hiện tại đang nhập đã có dấu chấm chưa
  bool _hasDecimalPointInLastNumber(String text) {
    // Tách chuỗi theo toán tử để lấy số cuối cùng
    List<String> parts = text.split(RegExp(r'[+\-×÷]')); // Lưu ý dấu - và −
    if (parts.isEmpty) return false;
    return parts.last.contains('.');
  }

  final List<String> buttons = [
    'C', '( )', '%', '÷',
    '7', '8', '9', '×',
    '4', '5', '6', '−',
    '1', '2', '3', '+',
    '±', '0', '.', '=',
  ];

  Color _getButtonColor(String buttonText) {
    if (['÷', '×', '−', '+', '='].contains(buttonText)) {
      return accentColor; 
    }
    return secondaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 2, 
                child: Container(
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Dòng phương trình (nhỏ)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true, // Luôn hiển thị phần cuối của phương trình
                        child: Text(
                          _equation,
                          style: GoogleFonts.roboto(
                            fontSize: 24,
                            color: whiteColor.withOpacity(0.7),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Dòng kết quả (lớn)
                      SingleChildScrollView(
                         scrollDirection: Axis.horizontal,
                         reverse: true,
                         child: Text(
                          _result,
                          style: GoogleFonts.roboto(
                            fontSize: 56,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3, 
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
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