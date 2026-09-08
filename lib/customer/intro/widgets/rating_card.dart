import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingCard extends StatefulWidget {
  final String lpm;

  const RatingCard({super.key, required this.lpm});

  @override
  State<RatingCard> createState() => _RatingCardState();
}

class _RatingCardState extends State<RatingCard> {
  int _rating = 0;
  bool _isSubmitting = false;
  bool _alreadyRated = false;
  String _feedback = '';
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchExistingRating();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  // 👈 fetch existing rating from job document
  Future<void> _fetchExistingRating() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.lpm)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final existingRating = data['rating'];
        final existingFeedback = data['feedback'] ?? '';
        if (existingRating != null && existingRating > 0) {
          setState(() {
            _rating = existingRating;
            _feedback = existingFeedback;
            _alreadyRated = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching rating: $e');
    }
  }

  // 👈 save rating + feedback to job document
  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating!')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.lpm)
          .update({
        'rating': _rating,                      // 👈 1-5 stored here
        'feedback': _feedbackController.text.trim(),
        'ratedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _feedback = _feedbackController.text.trim();
        _alreadyRated = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your feedback!')),
      );
    } catch (e) {
      debugPrint('Error submitting rating: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit. Try again.')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _alreadyRated ? 'Your Ratings' : 'Rate your experience',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          _alreadyRated ? 'Your Feedback' : 'Rate the Product',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 12),

        // ⭐ STARS
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              return InkWell(
                onTap: _alreadyRated
                    ? null
                    : () => setState(() => _rating = starValue),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    _rating >= starValue ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 26,
                  ),
                ),
              );
            }),
          ),
        ),

        // 👈 BEFORE RATING — show feedback field + submit
        if (!_alreadyRated) ...[
          const SizedBox(height: 16),
          TextField(
            controller: _feedbackController,
            decoration: InputDecoration(
              hintText: 'Give Feedback here',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitRating,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF8D94B),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text(
                'Submit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],

        // 👈 AFTER RATING — show submitted feedback
        if (_alreadyRated && _feedback.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _feedback,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ],
    );
  }
}