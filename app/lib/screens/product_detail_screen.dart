import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../widgets/product_image.dart';
import '../providers/products_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  int _selectedTabIndex = 0;
  int _quantity = 1;
  String? _selectedColor;
  String? _selectedStorage;

  List<String> get _allImages {
    final images = <String>[];
    if (widget.product.image != null) {
      images.add(widget.product.image!);
    }
    if (widget.product.gallery != null) {
      images.addAll(widget.product.gallery!.where((img) => img != widget.product.image));
    }
    return images;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Commerce'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Text(
                    '0',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'login', child: Text('Login')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[50],
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Home'),
                  ),
                  const Text('/'),
                  TextButton(
                    onPressed: () {},
                    child: Text(widget.product.category ?? 'Produtos'),
                  ),
                  const Text('/'),
                  Text(
                    widget.product.name,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // Main Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: isWideScreen
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Gallery
                        Expanded(
                          flex: 1,
                          child: _buildImageGallery(),
                        ),
                        const SizedBox(width: 32),
                        // Product Details
                        Expanded(
                          flex: 1,
                          child: _buildProductDetails(theme),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImageGallery(),
                        const SizedBox(height: 24),
                        _buildProductDetails(theme),
                      ],
                    ),
            ),
            // Product Information Tabs
            _buildProductTabs(theme),
            // Related Products
            _buildRelatedProducts(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    final images = _allImages;
    final mainImage = images.isNotEmpty ? images[_selectedImageIndex] : null;

    return Column(
      children: [
        // Main Image
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ProductImage(
                imageUrl: mainImage,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Thumbnail Gallery
        if (images.length > 1)
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedImageIndex = index;
                      });
                    },
                    child: Container(
                      width: 80,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedImageIndex == index
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[300]!,
                          width: _selectedImageIndex == index ? 3 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: ProductImage(
                          imageUrl: images[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildProductDetails(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Name
        Text(
          widget.product.name,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Rating
        Row(
          children: [
            ...List.generate(5, (index) {
              return Icon(
                index < 4 ? Icons.star : Icons.star_half,
                color: Colors.amber,
                size: 20,
              );
            }),
            const SizedBox(width: 8),
            Text(
              '4.5',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              ' (720 avaliações)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Price
        Row(
          children: [
            if (widget.product.hasDiscount == true) ...[
              Text(
                'R\$ ${(widget.product.price * 1.1).toStringAsFixed(2).replaceAll('.', ',')}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              'R\$ ${widget.product.price.toStringAsFixed(2).replaceAll('.', ',')}',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (widget.product.hasDiscount == true && widget.product.discountValue != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${widget.product.discountValue} OFF',
              style: TextStyle(
                color: Colors.red[800],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          'ou 12x de R\$ ${(widget.product.price / 12).toStringAsFixed(2).replaceAll('.', ',')} sem juros',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),
        // Color Selection
        if (widget.product.details != null) ...[
          const Text(
            'Cor:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildColorOption('Preto', Colors.black),
              const SizedBox(width: 8),
              _buildColorOption('Azul', Colors.blue),
              const SizedBox(width: 8),
              _buildColorOption('Vermelho', Colors.red),
            ],
          ),
          const SizedBox(height: 24),
        ],
        // Storage Selection
        const Text(
          'Armazenamento:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildStorageOption('128GB'),
            const SizedBox(width: 8),
            _buildStorageOption('256GB'),
            const SizedBox(width: 8),
            _buildStorageOption('512GB'),
          ],
        ),
        const SizedBox(height: 24),
        // Quantity Selector
        Row(
          children: [
            const Text(
              'Quantidade:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (_quantity > 1) {
                        setState(() {
                          _quantity--;
                        });
                      }
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '$_quantity',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        _quantity++;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Add to Cart Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$_quantity x ${widget.product.name} adicionado ao carrinho'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Adicionar ao Carrinho'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Stock Status
        Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(
              'Em estoque, envio imediato!',
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorOption(String colorName, Color color) {
    final isSelected = _selectedColor == colorName;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = colorName;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
        ),
      ),
    );
  }

  Widget _buildStorageOption(String storage) {
    final isSelected = _selectedStorage == storage;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStorage = storage;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.white,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          storage,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildProductTabs(ThemeData theme) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              _buildTab('Descrição', 0),
              _buildTab('Especificações', 1),
              _buildTab('Avaliações (120)', 2),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          child: _buildTabContent(),
        ),
      ],
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildDescription();
      case 1:
        return _buildSpecifications();
      case 2:
        return _buildReviews();
      default:
        return const SizedBox();
    }
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sobre o produto',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.product.description ??
              'Este produto oferece qualidade e confiabilidade. Desenvolvido com as melhores tecnologias disponíveis no mercado.',
          style: const TextStyle(fontSize: 14, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildSpecifications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Especificações',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (widget.product.category != null)
          _buildSpecRow('Categoria', widget.product.category!),
        if (widget.product.departamento != null)
          _buildSpecRow('Departamento', widget.product.departamento!),
        if (widget.product.material != null)
          _buildSpecRow('Material', widget.product.material!),
        if (widget.product.details != null)
          ...widget.product.details!.entries.map((entry) {
            return _buildSpecRow(entry.key, entry.value.toString());
          }),
      ],
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '4.5',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < 4 ? Icons.star : Icons.star_half,
                      color: Colors.amber,
                      size: 24,
                    );
                  }),
                ),
                const Text('Baseado em 120 avaliações'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Rating distribution
        _buildRatingBar(5, 72),
        _buildRatingBar(4, 15),
        _buildRatingBar(3, 5),
        _buildRatingBar(2, 5),
        _buildRatingBar(1, 2),
      ],
    );
  }

  Widget _buildRatingBar(int stars, int percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text('$stars estrelas'),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
          ),
          const SizedBox(width: 8),
          Text('$percentage%'),
        ],
      ),
    );
  }

  Widget _buildRelatedProducts() {
    return Consumer<ProductsProvider>(
      builder: (context, productsProvider, child) {
        // Get related products (same category, limit 4)
        final relatedProducts = productsProvider.products
            .where((p) =>
                p.category == widget.product.category &&
                p.id != widget.product.id)
            .take(4)
            .toList();

        if (relatedProducts.isEmpty) {
          return const SizedBox();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              child: const Text(
                'Produtos Relacionados',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 300,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: relatedProducts.length,
                itemBuilder: (context, index) {
                  final product = relatedProducts[index];
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 16),
                    child: _RelatedProductCard(product: product),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RelatedProductCard extends StatelessWidget {
  final Product product;

  const _RelatedProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ProductImage(
              imageUrl: product.image,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'R\$ ${product.price.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
