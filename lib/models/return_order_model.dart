class ReturnOrderItem {
  final String productId;
  final String productName;
  final String selectedColor;
  final String selectedImageUrl;
  final int price;
  final int quantity;
  final int amount;
  final String? returnStatus; // optional

  ReturnOrderItem({
    required this.productId,
    required this.productName,
    required this.selectedColor,
    required this.selectedImageUrl,
    required this.price,
    required this.quantity,
    required this.amount,
    this.returnStatus,
  });

  factory ReturnOrderItem.fromMap(Map<String, dynamic> map) {
    return ReturnOrderItem(
      productId: map['productId'],
      productName: map['productName'],
      selectedColor: map['selectedColor'],
      selectedImageUrl: map['selectedImageUrl'],
      price: map['price'],
      quantity: map['quantity'],
      amount: map['amount'],
      returnStatus: map['returnStatus'], // optional
    );
  }
}
