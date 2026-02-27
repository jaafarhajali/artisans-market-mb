import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_theme.dart';

class CreditCardData {
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String cardholderName;

  CreditCardData({
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.cardholderName,
  });

  String get maskedNumber {
    final digits = cardNumber.replaceAll(' ', '');
    if (digits.length < 4) return cardNumber;
    return '**** **** **** ${digits.substring(digits.length - 4)}';
  }

  String get cardType {
    final digits = cardNumber.replaceAll(' ', '');
    if (digits.startsWith('4')) return 'Visa';
    if (digits.startsWith('5')) return 'Mastercard';
    if (digits.startsWith('3')) return 'Amex';
    return 'Card';
  }
}

class CreditCardForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final ValueChanged<CreditCardData> onCardChanged;

  const CreditCardForm({
    super.key,
    required this.formKey,
    required this.onCardChanged,
  });

  @override
  State<CreditCardForm> createState() => _CreditCardFormState();
}

class _CreditCardFormState extends State<CreditCardForm> {
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  String _cardType = '';

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onChanged() {
    widget.onCardChanged(CreditCardData(
      cardNumber: _cardNumberController.text,
      expiryDate: _expiryController.text,
      cvv: _cvvController.text,
      cardholderName: _nameController.text,
    ));
  }

  void _detectCardType(String value) {
    final digits = value.replaceAll(' ', '');
    setState(() {
      if (digits.startsWith('4')) {
        _cardType = 'Visa';
      } else if (digits.startsWith('5')) {
        _cardType = 'Mastercard';
      } else if (digits.startsWith('3')) {
        _cardType = 'Amex';
      } else {
        _cardType = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card preview
          _buildCardPreview(),
          const SizedBox(height: 20),

          // Cardholder Name
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: _inputDecoration(
              label: 'Cardholder Name',
              hint: 'John Doe',
              icon: Icons.person_outline,
            ),
            onChanged: (_) => _onChanged(),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Name is required';
              if (v.trim().length < 3) return 'Enter full name';
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Card Number
          TextFormField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CardNumberFormatter(),
              LengthLimitingTextInputFormatter(19),
            ],
            decoration: _inputDecoration(
              label: 'Card Number',
              hint: '4242 4242 4242 4242',
              icon: Icons.credit_card,
              suffix: _cardType.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        _cardType,
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : null,
            ),
            onChanged: (v) {
              _detectCardType(v);
              _onChanged();
            },
            validator: (v) {
              if (v == null || v.isEmpty) return 'Card number is required';
              final digits = v.replaceAll(' ', '');
              if (digits.length < 16) return 'Enter a valid 16-digit card number';
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Expiry + CVV row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _ExpiryDateFormatter(),
                    LengthLimitingTextInputFormatter(5),
                  ],
                  decoration: _inputDecoration(
                    label: 'Expiry',
                    hint: 'MM/YY',
                    icon: Icons.calendar_today_outlined,
                  ),
                  onChanged: (_) => _onChanged(),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(v)) return 'MM/YY';
                    final month = int.tryParse(v.substring(0, 2));
                    if (month == null || month < 1 || month > 12) return 'Invalid';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: _inputDecoration(
                    label: 'CVV',
                    hint: '123',
                    icon: Icons.lock_outline,
                  ),
                  onChanged: (_) => _onChanged(),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length < 3) return 'Invalid';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardPreview() {
    final number = _cardNumberController.text.isEmpty
        ? '**** **** **** ****'
        : _cardNumberController.text;
    final name = _nameController.text.isEmpty
        ? 'YOUR NAME'
        : _nameController.text.toUpperCase();
    final expiry =
        _expiryController.text.isEmpty ? 'MM/YY' : _expiryController.text;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(
                Icons.wifi_rounded,
                color: Colors.white70,
                size: 28,
              ),
              Text(
                _cardType.isEmpty ? 'CREDIT CARD' : _cardType.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CARD HOLDER',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'EXPIRES',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expiry,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: AppTheme.primary),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: const TextStyle(fontSize: 14, color: AppTheme.textLight),
      hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
    );
  }
}

/// Formats card number as "1234 5678 9012 3456"
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formats expiry as "MM/YY"
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(text[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
