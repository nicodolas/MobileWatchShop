import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class MomoPaymentService {
  Future<Map<String, dynamic>?> createMomoPayment(int amount) async {
    final url = Uri.parse('https://test-payment.momo.vn/v2/gateway/api/create');

    final partnerCode = 'MOMO';
    final accessKey = 'F8BBA842ECF85';
    final secretKey = 'K951B6PE1waDMi640xX08PD3vg6EkVlz';

    final orderId = DateTime.now().millisecondsSinceEpoch.toString();
    final requestId = orderId;

    final rawData =
        'accessKey=$accessKey&amount=$amount&extraData=&ipnUrl=https://httpbin.org/post&orderId=$orderId&orderInfo=Thanh toán đơn hàng AHTShop&partnerCode=$partnerCode&redirectUrl=https://httpbin.org/get&requestId=$requestId&requestType=captureWallet';

    final hmacSha256 = Hmac(sha256, utf8.encode(secretKey));
    final signature = hmacSha256.convert(utf8.encode(rawData)).toString();

    final body = {
      "partnerCode": partnerCode,
      "accessKey": accessKey,
      "requestId": requestId,
      "amount": "$amount",
      "orderId": orderId,
      "orderInfo": "Thanh toán đơn hàng AHTShop",
      "redirectUrl": "https://httpbin.org/get",
      "ipnUrl": "https://httpbin.org/post",
      "extraData": "",
      "requestType": "captureWallet",
      "signature": signature,
      "lang": "vi",
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Momo trả về: $data");
      return data;
    } else {
      print('Lỗi khi tạo đơn Momo: ${response.statusCode} - ${response.body}');
      return null;
    }
  }
}
