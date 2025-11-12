import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../providers/auth_provider.dart';
import '../models/product.dart';
import '../widgets/product_image.dart';
import 'product_detail_screen.dart';
import 'widgets/filters_sidebar.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'relevance';
  bool _showFilters = false;
  bool _hasSearchText = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _hasSearchText = _searchController.text.isNotEmpty;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
      if (productsProvider.products.isEmpty && !productsProvider.isLoading) {
        productsProvider.loadProducts();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applySearch() {
    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    productsProvider.setFilters(
      name: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
    );
    productsProvider.loadProducts();
  }

  void _sortProducts(String value) {
    setState(() {
      _sortBy = value;
    });
  }

  List<Product> _getSortedProducts(List<Product> products) {
    switch (_sortBy) {
      case 'price_asc':
        return List.from(products)..sort((a, b) => a.price.compareTo(b.price));
      case 'price_desc':
        return List.from(products)..sort((a, b) => b.price.compareTo(a.price));
      case 'name_asc':
        return List.from(products)..sort((a, b) => a.name.compareTo(b.name));
      case 'name_desc':
        return List.from(products)..sort((a, b) => b.name.compareTo(a.name));
      default:
        return products;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1200;

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Commerce'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
            tooltip: 'Favoritos',
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {},
                tooltip: 'Carrinho',
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
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (mounted) {
                navigator.pushReplacementNamed('/login');
              }
            },
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'O que você está procurando?',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _hasSearchText
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _applySearch();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: (_) => _applySearch(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _applySearch,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text('Buscar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isWideScreen || _showFilters) ...[
                  Container(
                    width: isWideScreen ? 280 : MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        right: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: FiltersSidebar(
                      onFiltersChanged: () {
                        Provider.of<ProductsProvider>(context, listen: false).loadProducts();
                      },
                      onClose: () {
                        if (!isWideScreen) {
                          setState(() {
                            _showFilters = false;
                          });
                        }
                      },
                    ),
                  ),
                  if (!isWideScreen)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showFilters = false;
                        });
                      },
                      child: Container(
                        color: Colors.black54,
                        width: MediaQuery.of(context).size.width * 0.2,
                      ),
                    ),
                ],
                Expanded(
                  child: Consumer<ProductsProvider>(
                    builder: (context, productsProvider, child) {
                      if (productsProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (productsProvider.error != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                'Erro ao carregar produtos',
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                productsProvider.error ?? 'Erro desconhecido',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  productsProvider.clearError();
                                  productsProvider.loadProducts();
                                },
                                child: const Text('Tentar novamente'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (productsProvider.products.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhum produto encontrado',
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tente ajustar os filtros',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        );
                      }

                      final sortedProducts = _getSortedProducts(productsProvider.products);

                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            color: Colors.white,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Produtos',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (!isWideScreen)
                                  IconButton(
                                    icon: const Icon(Icons.filter_list),
                                    onPressed: () {
                                      setState(() {
                                        _showFilters = true;
                                      });
                                    },
                                  ),
                                Text(
                                  'Exibindo ${sortedProducts.length} de ${productsProvider.products.length} resultados',
                                  style: theme.textTheme.bodySmall,
                                ),
                                const SizedBox(width: 16),
                                DropdownButton<String>(
                                  value: _sortBy,
                                  items: const [
                                    DropdownMenuItem(value: 'relevance', child: Text('Mais Relevantes')),
                                    DropdownMenuItem(value: 'price_asc', child: Text('Menor Preço')),
                                    DropdownMenuItem(value: 'price_desc', child: Text('Maior Preço')),
                                    DropdownMenuItem(value: 'name_asc', child: Text('Nome A-Z')),
                                    DropdownMenuItem(value: 'name_desc', child: Text('Nome Z-A')),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      _sortProducts(value);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isWideScreen ? 3 : 2,
                                childAspectRatio: 0.65,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: sortedProducts.length,
                              itemBuilder: (context, index) {
                                final product = sortedProducts[index];
                                return _ProductCard(product: product);
                              },
                            ),
                          ),
                        ],
                      );
                    },
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

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: ProductImage(
                  imageUrl: product.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      'R\$ ${product.price.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} adicionado ao carrinho'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text('Adicionar ao Carrinho'),
                      ),
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
