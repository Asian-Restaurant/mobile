import 'package:asian_paradise/mobile/address_page_mobile.dart';
import 'package:asian_paradise/mobile/basket_page_mobile.dart';
import 'package:asian_paradise/mobile/dish_page_mobile.dart';
import 'package:asian_paradise/mobile/main_page_mobile.dart';
import 'package:asian_paradise/mobile/reviews_page_mobile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../api/api_service.dart';
import '../database/url_utils.dart';
import '../database/сart.dart';

class MenuPageMobile extends StatelessWidget {
  MenuPageMobile({Key? key}) : super(key: key);

  final ApiService _apiService = ApiService('http://192.168.0.101:5000');

  @override
  Widget build(BuildContext context) {
    final cart = Cart();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.pink[100],
        elevation: 0,
        centerTitle: true,
        title: Text(
          'ASIAN PARADISE',
          style: GoogleFonts.mali(color: Colors.black, fontSize: 24),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<dynamic>>(
          future: _apiService.getMenu(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No menu items found.'));
            }

            final menuItems = snapshot.data!;
            final Map<String, List<Map<String, dynamic>>> groupedDishes = {};

            for (var item in menuItems) {
              final category = item['category'];
              if (!groupedDishes.containsKey(category)) {
                groupedDishes[category] = [];
              }
              groupedDishes[category]!.add({
                'dish_name': item['dish_name'],
                'image_url': item['image_url'],
              });
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildNavButton(context, "Main Page", () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => MainPageMobile()));
                        }),
                        const SizedBox(width: 8),
                        _buildNavButton(context, "Basket", () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => BasketPageMobile(cartData: cart)));
                        }),
                        const SizedBox(width: 8),
                        _buildNavButton(context, "Reviews", () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ReviewsPageMobile()));
                        }),
                        const SizedBox(width: 8),
                        _buildNavButton(context, "Delivery", () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressPageMobile()));
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Food grid
                  _buildFoodGrid(groupedDishes, context, cart),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFoodGrid(Map<String, List<Map<String, dynamic>>> groupedDishes, BuildContext context, Cart cart) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groupedDishes.keys.length,
      itemBuilder: (context, categoryIndex) {
        final category = groupedDishes.keys.elementAt(categoryIndex);
        final dishes = groupedDishes[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                category,
                style: GoogleFonts.mali(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: dishes.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, dishIndex) {
                final dish = dishes[dishIndex];
                return _buildFoodCard(
                  dish['image_url'] ?? '',
                  dish['dish_name'] ?? 'Unknown Title',
                  '',
                  0.0,
                  0.0,
                  context,
                  cart,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildFoodCard(String imagePath, String title, String description, double weight, double price, BuildContext context, Cart cart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.pink[300],
            borderRadius: BorderRadius.circular(16.0),
          ),
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11.0),
            child: imagePath.isNotEmpty
                ? Image.network(
              fixImageUrl(imagePath),
              fit: BoxFit.cover,
              width: 180,
              height: 160,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey,
                width: 180,
                height: 160,
                child: const Center(
                  child: Text('Image failed to load', style: TextStyle(color: Colors.red)),
                ),
              ),
            )
                : Container(
              width: 180,
              height: 160,
              color: Colors.grey,
              child: const Center(child: Text('No Image')),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DishPageMobile(
                  dishName: title,
                  cart: cart,
                ),
              ),
            );
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.pink[200],
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildNavButton(BuildContext context, String title, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: Colors.pink[100],
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 1.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
