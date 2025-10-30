import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return ShimmerLoadingCard();
      },
    );
  }
}

class ShimmerLoadingCategory extends StatelessWidget {
  const ShimmerLoadingCategory({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90, // Height for horizontal avatar list
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // 👈 Horizontal scroll
        itemCount: 8,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade400, // 🩶 Silver base tone
              highlightColor: Colors.grey.shade100, // 💫 Soft light shimmer
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🟣 Circular avatar shimmer
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 🩶 Text shimmer below avatar
                  Container(
                    width: 50,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


class ShimmerLoadingBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180, // height of your banner
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5, // number of shimmer banners
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300, // silver base
              highlightColor: Colors.grey.shade100, // lighter highlight
              child: Container(
                width: 300, // width of each banner
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


class ShimmerLoadingFilter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Shimmer.fromColors(
            baseColor: Color(0xFF2B5D65),
            highlightColor: Color(0xFF01351E),
            child: Container(
              height: 80.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ShimmerLoadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Color(0xFF2B5D65),
      highlightColor: Color(0xFF01351E),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 80.0, // Adjust height as needed
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
              ),
            ),
            // Text placeholders
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 10.0, // Placeholder for title
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8.0),
                    Container(
                      height: 10.0, // Placeholder for price
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
