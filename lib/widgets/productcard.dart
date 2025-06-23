import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const ProductCard({
    Key? key,
    required this.product,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap ?? () => _navigateToProductDetails(context),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(),
              Expanded(child: _buildContentSection(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Container(
            height: 140,
            width: double.infinity,
            color: Colors.grey[100],
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                );
              },
            ),
          ),
        ),
        if (onFavorite != null)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onFavorite,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 18,
                  color: isFavorite ? Colors.red : Colors.grey[600],
                ),
              ),
            ),
          ),
        // Discount badge (optional - uncomment if you have discount data)
        // if (product.discount != null && product.discount! > 0)
        //   Positioned(
        //     top: 8,
        //     left: 8,
        //     child: Container(
        //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        //       decoration: BoxDecoration(
        //         color: Colors.red,
        //         borderRadius: BorderRadius.circular(12),
        //       ),
        //       child: Text(
        //         '-${product.discount}%',
        //         style: const TextStyle(
        //           color: Colors.white,
        //           fontSize: 10,
        //           fontWeight: FontWeight.bold,
        //         ),
        //       ),
        //     ),
        //   ),
      ],
    );
  }

  Widget _buildContentSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 6),

          // Price
          Row(
            children: [
              Text(
                'Rp ${_formatPrice(product.price)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              // Original price (if discounted - uncomment if needed)
              // if (product.originalPrice != null && product.originalPrice! > product.price)
              //   Padding(
              //     padding: const EdgeInsets.only(left: 8),
              //     child: Text(
              //       'Rp ${_formatPrice(product.originalPrice!)}',
              //       style: const TextStyle(
              //         fontSize: 12,
              //         color: Colors.grey,
              //         decoration: TextDecoration.lineThrough,
              //       ),
              //     ),
              //   ),
            ],
          ),

          const Spacer(),

          // Description
          Text(
            product.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.3,
            ),
          ),

          const SizedBox(height: 8),

          // Rating and additional info (optional - uncomment if you have rating data)
          // Row(
          //   children: [
          //     Icon(
          //       Icons.star,
          //       size: 14,
          //       color: Colors.amber,
          //     ),
          //     const SizedBox(width: 2),
          //     Text(
          //       '${product.rating ?? 0.0}',
          //       style: const TextStyle(
          //         fontSize: 12,
          //         fontWeight: FontWeight.w500,
          //       ),
          //     ),
          //     const SizedBox(width: 4),
          //     Text(
          //       '(${product.reviewCount ?? 0})',
          //       style: TextStyle(
          //         fontSize: 12,
          //         color: Colors.grey[600],
          //       ),
          //     ),
          //     const Spacer(),
          //     if (product.stock != null)
          //       Text(
          //         'Stok: ${product.stock}',
          //         style: TextStyle(
          //           fontSize: 10,
          //           color: product.stock! > 0 ? Colors.green : Colors.red,
          //           fontWeight: FontWeight.w500,
          //         ),
          //       ),
          //   ],
          // ),
        ],
      ),
    );
  }

  void _navigateToProductDetails(BuildContext context) {
    Navigator.pushNamed(context, '/productdetails_page', arguments: product);
  }

  String _formatPrice(double price) {
    // Improved number formatting for Indonesian currency
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
