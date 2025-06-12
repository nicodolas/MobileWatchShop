import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class ReturnPolicyWidget extends StatelessWidget {
  const ReturnPolicyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng hằng số để lưu trữ chính sách trả hàng (dễ bảo trì hơn)
    const String returnPolicyText = """
    <h2>Chính sách trả hàng</h2>
    
    <h3>1. Điều kiện trả hàng</h3>
    <p>Khách hàng có thể yêu cầu trả hàng trong vòng 7 ngày kể từ ngày nhận sản phẩm nếu sản phẩm thuộc một trong các điều kiện sau:</p>
    <ul>
      <li>Sản phẩm bị lỗi do nhà sản xuất</li>
      <li>Sản phẩm không đúng với đơn hàng đã đặt (sai mẫu mã, số lượng, v.v.)</li>
      <li>Sản phẩm bị hư hỏng trong quá trình vận chuyển</li>
      <li>Sản phẩm không phù hợp nhưng còn nguyên vẹn, chưa qua sử dụng và còn đầy đủ tem mác, phụ kiện</li>
    </ul>
    
    <h3>2. Các trường hợp không được trả hàng</h3>
    <ul>
      <li>Sản phẩm đã qua sử dụng</li>
      <li>Sản phẩm bị hư hỏng do lỗi của người sử dụng</li>
      <li>Sản phẩm không còn nguyên vẹn tem mác, phụ kiện</li>
      <li>Sản phẩm nằm trong danh mục hàng hóa không được trả hàng (quà tặng).</li>
    </ul>
    
    <h3>3. Quy trình trả hàng</h3>
    <ul>
      <li><strong>Bước 1: Trả hàng</strong><br>
          Khách hàng gửi yêu cầu trả hàng trực tiếp trên đơn hàng. Sản phẩm trả hàng cần được đóng gói cẩn thận, đảm bảo còn nguyên vẹn và đầy đủ tem mác, phụ kiện.</li>
      <li><strong>Bước 2: Kiểm tra và xử lý</strong><br>
          Sau khi nhận được sản phẩm trả hàng, AHTShop sẽ tiến hành kiểm tra sản phẩm.<br>
          Nếu sản phẩm đáp ứng các điều kiện trả hàng, AHTShop sẽ tiến hành xử lý trả hàng theo quy định.</li>
    </ul>
    
    <h3>4. Hình thức hoàn tiền</h3>
    <p>Khách hàng có thể lựa chọn các hình thức hoàn tiền sau:</p>
    <ul>
      <li>Hoàn tiền vào tài khoản ngân hàng</li>
      <li>Hoàn tiền vào ví điện tử</li>
      <li>Đổi sản phẩm mới có giá trị tương đương hoặc cao hơn (khách hàng bù thêm tiền nếu có)</li>
    </ul>
    
    <h3>5. Thời gian xử lý</h3>
    <ul>
      <li>Thời gian kiểm tra và xử lý trả hàng: 2 ngày làm việc kể từ ngày nhận được sản phẩm trả hàng.</li>
      <li>Thời gian hoàn tiền: 2 ngày làm việc kể từ ngày hoàn tất xử lý trả hàng.</li>
    </ul>
    
    <h3>6. Chi phí trả hàng</h3>
    <ul>
      <li>Nếu sản phẩm bị lỗi do nhà sản xuất, không đúng đơn hàng hoặc bị hư hỏng trong quá trình vận chuyển, AHTShop sẽ chịu chi phí trả hàng.</li>
      <li>Trong các trường hợp khác, khách hàng sẽ chịu chi phí trả hàng.</li>
    </ul>
    
    <h3>7. Lưu ý</h3>
    <ul>
      <li>Khách hàng vui lòng giữ lại hóa đơn mua hàng hoặc các chứng từ liên quan để làm căn cứ trả hàng.</li>
      <li>AHTShop có quyền từ chối trả hàng nếu sản phẩm không đáp ứng các điều kiện trả hàng theo quy định.</li>
    </ul>
    
    <h3>8. Liên hệ</h3>
    <p>Nếu có bất kỳ thắc mắc nào về chính sách trả hàng, quý khách vui lòng nhắn tin trực tiếp với chúng tôi thông qua mục tin nhắn hỗ trợ.</p>
    <p>Giờ làm việc: 8:00 - 17:00</p>
    
    <p><strong>AHTShop xin chân thành cảm ơn quý khách hàng đã tin tưởng và ủng hộ!</strong></p>
    """;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Html(
        data: returnPolicyText,
        style: {
          'body': Style(
            fontFamily: 'Arial',
            fontSize: FontSize(16),
            color: Colors.black87,
            lineHeight: LineHeight.number(1.5), // Kc dòng
          ),
          'h2': Style(
            fontSize: FontSize(24),
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            margin: Margins.only(bottom: 10),
          ),
          'h3': Style(
            fontSize: FontSize(18),
            fontWeight: FontWeight.w600,
            color: Colors.teal,
            margin: Margins.only(bottom: 10),
          ),
          'p': Style(fontSize: FontSize(16), margin: Margins.only(bottom: 10)),
          'ul': Style(
            margin: Margins.only(left: 20, bottom: 10),
            listStyleType: ListStyleType.disc,
          ),
          'li': Style(fontSize: FontSize(16), margin: Margins.only(bottom: 5)),
        },
      ),
    );
  }
}
