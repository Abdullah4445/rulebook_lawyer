import 'package:epayco_dart/epayco_dart.dart';

class EpaycoController {
  late final EPayco _epaycoClient;


  EpaycoController({
    required String publicKey,
    required String privateKey,
  }) {
    _epaycoClient = EPayco.instance.configure(
      publicKey: publicKey,
      privateKey: privateKey,
    );
  }

  Future<void> init() async {
    await _epaycoClient.getToken();
  }

  Future<TcTransactionResponse> payByCreditCard({
    required String value,
    required String docType,
    required String docNumber,
    required String name,
    required String lastName,
    required String email,
    required String cellPhone,
    required String phone,
    required String cardNumber,
    required String cardExpYear,
    required String cardExpMonth,
    required String cardCvc,
    required String dues,
    required String extra1,
    required String extra2,
    String? currency,
    String? urlResponse,
    String? urlConfirmation,
    String? methodConfirmation,
    bool? testMode,
  }) async {
    try {
      final transaction = TcTransaction(
        value: value,
        docType: docType,
        docNumber: docNumber,
        name: name,
        lastName: lastName,
        email: email,
        cellPhone: cellPhone,
        phone: phone,
        cardNumber: cardNumber,
        cardExpYear: cardExpYear,
        cardExpMonth: cardExpMonth,
        cardCvc: cardCvc,
        dues: dues,
        extra1: extra1,
        extra2: extra2,
        currency: currency,
        urlResponse: urlResponse,
        urlConfirmation: urlConfirmation,
        methodConfirmation: methodConfirmation,
        testMode: testMode,
      );
      TcTransactionResponse response = await _epaycoClient.payByCreditCard(transaction);
      return response;
    } catch (e) {
      print("ePayco Credit Card Payment Failed: $e");
      return TcTransactionResponse();
    }
  }

  Future<void> payByPSE({
    required String bank,
    required String value,
    required String docType,
    required String docNumber,
    required String name,
    String? lastName,
    required String email,
    required String cellPhone,
    required String ip,
    required String urlResponse,
    String? phone,
    String? address,
    String? currency,
    String? description,
    String? invoice,
    String? methodConfimation,
    String? tax,
    String? taxBase,
    String? typePerson,
    String? urlConfirmation,
    required String extra1,
    required String extra2,
    bool? testMode,
  }) async {
    try {
      final transaction = PSETransactionModel(
        bank: bank,
        value: value,
        docType: docType,
        docNumber: docNumber,
        name: name,
        lastName: lastName,
        email: email,
        cellPhone: cellPhone,
        ip: ip,
        urlResponse: urlResponse,
        phone: phone,
        address: address,
        currency: currency,
        description: description,
        invoice: invoice,
        methodConfimation: methodConfimation,
        tax: tax,
        taxBase: taxBase,
        typePerson: typePerson,
        urlConfirmation: urlConfirmation,
        extra1: extra1,
        extra2: extra2,
        testMode: testMode,
      );

      final response = await _epaycoClient.createTransaction(transaction);
      print("ePayco PSE Payment Success: $response");
    } catch (e) {
      print("ePayco PSE Payment Failed: $e");
    }
  }
}
