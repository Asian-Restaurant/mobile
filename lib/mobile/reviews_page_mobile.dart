import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ReviewsPageMobile extends StatefulWidget {
  const ReviewsPageMobile({Key? key}) : super(key: key);

  @override
  _ReviewsPageMobileState createState() => _ReviewsPageMobileState();
}

class _ReviewsPageMobileState extends State<ReviewsPageMobile> {
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('http://192.168.0.101:5000/reviews'));
      if (response.statusCode == 200) {
        final List<dynamic> reviews = json.decode(response.body);
        setState(() {
          _reviews = reviews.map((review) {
            return {
              'name': review['name'] ?? 'Anonymous',
              'comment': review['comment'] ?? 'No comment',
            };
          }).toList();
        });
      } else {
        _showDialog('Error', 'Failed to load reviews: ${response.body}');
      }
    } catch (e) {
      _showDialog('Error', 'Failed to load reviews: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addReview() async {
    final email = _emailController.text.trim();
    final comment = _reviewController.text.trim();

    if (email.isEmpty || comment.isEmpty) {
      _showDialog('Error', 'Email and review text are required.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.101:5000/reviews'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'comment': comment,
        }),
      );

      if (response.statusCode == 201) {
        _reviewController.clear();
        _emailController.clear();
        await _loadReviews();
      } else {
        _showDialog('Error', 'Failed to add review: ${response.body}');
      }
    } catch (e) {
      _showDialog('Error', 'Failed to add review: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews', style: GoogleFonts.mali(fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.pink[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                hintText: 'Enter your email',
                labelText: 'Email',
                filled: true,
                fillColor: Colors.pink[50],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reviewController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                hintText: 'Enter your review',
                labelText: 'Review',
                filled: true,
                fillColor: Colors.pink[50],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[300],
                foregroundColor: Colors.black,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit Review'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildReviewList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewList() {
    if (_reviews.isEmpty) {
      return Center(
        child: Text(
          'No reviews yet. Be the first to leave one!',
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            title: Text(
              _reviews[index]['name'] ?? 'Anonymous',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(_reviews[index]['comment'] ?? 'No comment'),
          ),
        );
      },
    );
  }
}