import 'package:asian_paradise/api/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/сart.dart' as cart;
import '../mobile/reviews_page_mobile.dart' as reviews;
import '../mobile/address_page_mobile.dart' as address;
import '../mobile/main_page_mobile.dart';
import '../mobile/menu_page_mobile.dart';

class BasketPageMobile extends StatefulWidget {
  final cart.Cart cartData;

  const BasketPageMobile({super.key, required this.cartData});

  @override
  _BasketPageState createState() => _BasketPageState();
}

class _BasketPageState extends State<BasketPageMobile> {
  final TextEditingController _commentController = TextEditingController();
  String? _sendMessage;
  final ApiService apiService = ApiService('http://192.168.0.101:5000');

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  @override
  void dispose() {
    _saveCart();
    super.dispose();
  }

  void _loadCart() async {
    final response = await apiService.getCart();

    if (response != null) {
      setState(() {
        widget.cartData.items.clear();
        widget.cartData.items.addAll(
          response.map((item) => cart.CartItem.fromJson(item)).toList(),
        );
      });
    } else {
      print('Failed to load cart');
    }
  }

  void _saveCart() async {
    final cartItems = widget.cartData.items.map((item) {
      return {
        'name_dish': item.title,
        'price': item.price,
        'quantity': item.quantity,
        'comment': item.comment ?? '',
      };
    }).toList();

    final success = await apiService.saveCart(cartItems);

    if (!success) {
      print('Failed to save cart');
    }
  }

  void _sendComment() async {
    final success = await apiService.sendComment(_commentController.text);

    setState(() {
      _sendMessage = success ? "Sent!" : "Failed to send comment";
      _commentController.clear();
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _sendMessage = null;
      });
    });
  }

  void _increaseItemQuantity(int index) {
    setState(() {
      widget.cartData.items[index].quantity++;
    });
    _saveCart();
  }

  void _decreaseItemQuantity(int index) {
    setState(() {
      if (widget.cartData.items[index].quantity > 1) {
        widget.cartData.items[index].quantity--;
      } else {
        widget.cartData.items.removeAt(index);
      }
    });
    _saveCart();
  }

  void _navigateTo(String page) {
    _saveCart();

    switch (page) {
      case "Main Page":
        Navigator.push(context, MaterialPageRoute(builder: (context) => MainPageMobile()));
        break;
      case "Menu":
        Navigator.push(context, MaterialPageRoute(builder: (context) => MenuPageMobile()));
        break;
      case "Reviews":
        Navigator.push(context, MaterialPageRoute(builder: (context) => const reviews.ReviewsPageMobile()));
        break;
      case "Delivery":
        Navigator.push(context, MaterialPageRoute(builder: (context) => address.AddressPageMobile()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'ASIAN PARADISE',
          style: GoogleFonts.mali(color: Colors.black, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Colors.pink[100],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildNavButtons(context, isLargeScreen),
              const SizedBox(height: 16),
              _buildOrderList(),
              const SizedBox(height: 16),
              _buildTotalSum(),
              const SizedBox(height: 16),
              _buildCommentsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButtons(BuildContext context, bool isLargeScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (String title in ["Main Page", "Menu", "Reviews", "Delivery"])
          _buildNavButton(context, title, isLargeScreen),
      ],
    );
  }

  Widget _buildNavButton(BuildContext context, String text, bool isLargeScreen) {
    return SizedBox(
      width: isLargeScreen ? 120 : 80,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink[100],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: EdgeInsets.symmetric(vertical: isLargeScreen ? 8 : 4),
        ),
        onPressed: () => _navigateTo(text),
        child: Text(
          text,
          style: GoogleFonts.poppins(fontSize: isLargeScreen ? 18 : 13, fontWeight: FontWeight.w600, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildOrderList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pinkAccent, width: 5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Order",
            style: GoogleFonts.mali(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Divider(color: Colors.pinkAccent),
          if (widget.cartData.items.isEmpty)
            Text(
              "Your basket is empty.",
              style: GoogleFonts.mali(fontSize: 16, fontStyle: FontStyle.italic),
            )
          else
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: widget.cartData.items.length,
                itemBuilder: (context, index) {
                  final item = widget.cartData.items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: GoogleFonts.mali(fontSize: 16),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => _decreaseItemQuantity(index),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                "${item.quantity}",
                                style: GoogleFonts.mali(fontSize: 16),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => _increaseItemQuantity(index),
                            ),
                          ],
                        ),
                        Text(
                          "${(item.price * item.quantity).toStringAsFixed(2)} BYN",
                          style: GoogleFonts.mali(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
        ],
      ),
    );
  }

  Widget _buildTotalSum() {
    final totalSum = widget.cartData.items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pinkAccent, width: 5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Total sum:",
            style: GoogleFonts.mali(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            "${totalSum.toStringAsFixed(2)} BYN",
            style: GoogleFonts.mali(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pinkAccent, width: 5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Any comments?",
            style: GoogleFonts.mali(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Divider(color: Colors.pinkAccent),
          TextField(
            controller: _commentController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: "Write here...",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _sendComment,
            child: Text(
              "Send comment",
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          if (_sendMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _sendMessage!,
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.green),
              ),
            ),
        ],
      ),
    );
  }
}
